/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

GridLayout {
  id: grid

  readonly property var cfg: Plasmoid.configuration

  required property var info
  required property var actions
  property var occupiedDesktops: []

  readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
  readonly property real textRotation: {
    if (cfg.indicatorRotation !== "edge")
      return Number(cfg.indicatorRotation) || 0;

    switch (Plasmoid.location) {
      case PlasmaCore.Types.LeftEdge: return -90;
      case PlasmaCore.Types.RightEdge: return 90;
      case PlasmaCore.Types.BottomEdge: return 180;
      default: return 0;
    }
  }

  // Pills and stacked screens always use one row
  readonly property bool forceSingleRow: cfg.singleRow
    || (cfg.indicatorType === "minimal" && cfg.minimalStyle === "pills")
    || (cfg.screenMode === "allScreens" && cfg.screenLayout === "stacked")
  readonly property int desktopRows: forceSingleRow ? 1 : Math.max(1, info.desktopLayoutRows)
  readonly property int desktopsPerRow: Math.ceil(info.numberOfDesktops / desktopRows)

  readonly property bool perScreen: cfg.screenMode !== "shared"
  property string screenName: Screen.name
  property int screenIndex: -1
  property int screenSwitches: 0
  // currentDesktopByScreenName is a function so QML can't tell when it changes.
  // Reading screenSwitches forces this to re-run when a screen switches (with a
  // fallback for older Plasma versions without screen-independent switching)
  readonly property var currentDesktop: {
    screenSwitches;
    return perScreen && screenName && typeof info.currentDesktopByScreenName === "function"
      ? info.currentDesktopByScreenName(screenName)
      : info.currentDesktop;
  }
  readonly property int currentIndex: info.desktopIds.indexOf(currentDesktop)

  readonly property int hoveredIndex: hover.hovered ? indexAt(hover.point.position) : -1

  // Grid children are desktop containers which each know their own index
  function indexAt(point) {
    return childAt(point.x, point.y)?.index ?? -1;
  }

  function click(action, point) {
    actions.clickAction(action, indexAt(point), currentIndex, screenIndex);
  }

  flow: vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
  rows: vertical ? desktopsPerRow : desktopRows
  columns: vertical ? desktopRows : desktopsPerRow
  rowSpacing: 0
  columnSpacing: 0

  Connections {
    target: grid.info
    // support for older Plasma versions
    ignoreUnknownSignals: true

    function onCurrentDesktopForScreenChanged(screenName) {
      if (screenName === grid.screenName)
        grid.screenSwitches++;
    }
  }

  HoverHandler { id: hover }

  TapHandler {
    acceptedButtons: Qt.LeftButton
    enabled: grid.cfg.leftClickAction !== "none"
    onTapped: (event) => grid.click(grid.cfg.leftClickAction, event.position)
  }
  TapHandler {
    acceptedButtons: Qt.MiddleButton
    enabled: grid.cfg.middleClickAction !== "none"
    onTapped: (event) => grid.click(grid.cfg.middleClickAction, event.position)
  }
  TapHandler {
    acceptedButtons: Qt.RightButton
    enabled: grid.cfg.rightClickAction !== "none"
    onTapped: (event) => grid.click(grid.cfg.rightClickAction, event.position)
  }

  WheelHandler {
    enabled: grid.cfg.scrollEnabled
    orientation: Qt.Vertical
    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    onWheel: (event) => {
      const delta = event.angleDelta;
      if (!grid.cfg.scrollHorizontal || Math.abs(delta.y) >= Math.abs(delta.x))
        grid.actions.wheelAction(delta.y, grid.currentIndex, grid.screenIndex);
    }
  }
  WheelHandler {
    enabled: grid.cfg.scrollEnabled && grid.cfg.scrollHorizontal
    orientation: Qt.Horizontal
    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    onWheel: (event) => {
      const delta = event.angleDelta;
      if (Math.abs(delta.x) > Math.abs(delta.y))
        grid.actions.wheelAction(delta.x, grid.currentIndex, grid.screenIndex);
    }
  }

  Repeater {
    model: grid.info.numberOfDesktops

    DesktopContainer {
      desktop.name: grid.info.desktopNames[index] ?? ""
      desktop.screenIndex: grid.screenIndex
      desktop.isCurrent: index === grid.currentIndex
      desktop.isHovered: index === grid.hoveredIndex
      desktop.isOccupied: grid.cfg.markOccupied && grid.occupiedDesktops.includes(grid.info.desktopIds[index])
      desktop.vertical: grid.vertical
      desktop.textRotation: grid.textRotation
    }
  }
}
