/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

// One desktop grid for this screen, or one per screen in allScreens mode
GridLayout {
  id: groups

  readonly property var cfg: Plasmoid.configuration

  required property var info
  required property var actions
  property var occupiedDesktops: []
  property var occupiedByScreen: ({})

  readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
  readonly property bool allScreens: cfg.screenMode === "allScreens"
  readonly property bool perScreen: cfg.screenMode !== "shared"
  readonly property bool stacked: allScreens && cfg.screenLayout === "stacked"

  // Left to right then top to bottom (so screen numbers match KWin script)
  readonly property var screens: Array.from(Qt.application.screens)
    .sort((a, b) => a.virtualX - b.virtualX || a.virtualY - b.virtualY)
  readonly property var screenNames: allScreens
    ? screens.map((screen) => screen.name)
    : [Screen.name]

  // Multiple rows should fit as many as the panelThickness can accommodate
  readonly property real panelThickness: vertical ? width : height
  readonly property real minimumRowThickness: Kirigami.Units.gridUnit * 1.5
  readonly property int rowCount: stacked
    ? Math.max(1, Math.min(screenNames.length, Math.floor(panelThickness / minimumRowThickness)))
    : 1
  readonly property var screenRows: {
    const perRow = Math.ceil(screenNames.length / rowCount);
    const rows = [];
    for (let i = 0; i < screenNames.length; i += perRow)
      rows.push(screenNames.slice(i, i + perRow));
    return rows;
  }

  // Rows stack across the panel
  flow: vertical ? GridLayout.LeftToRight : GridLayout.TopToBottom
  rowSpacing: 0
  columnSpacing: 0

  Repeater {
    model: groups.screenRows

    // A single row of screens
    GridLayout {
      id: screenRow

      required property var modelData

      Layout.fillWidth: groups.vertical
      Layout.fillHeight: !groups.vertical
      flow: groups.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
      rowSpacing: 0
      columnSpacing: 0

      Repeater {
        model: screenRow.modelData

        GridLayout {
          id: group

          required property int index
          required property string modelData

          Layout.fillWidth: groups.vertical
          Layout.fillHeight: !groups.vertical
          flow: screenRow.flow
          rowSpacing: 0
          columnSpacing: 0

          // Screen group separator
          Item {
            visible: group.index > 0
            implicitWidth: Kirigami.Units.smallSpacing * 2 + 1
            implicitHeight: implicitWidth
            Layout.fillWidth: groups.vertical
            Layout.fillHeight: !groups.vertical

            Rectangle {
              anchors.centerIn: parent
              width: groups.vertical ? parent.width / 2 : 1
              height: groups.vertical ? 1 : parent.height / 2
              color: Kirigami.Theme.textColor
              opacity: 0.3
            }
          }
          PlasmaCore.ToolTipArea {
            id: tooltip

            Layout.fillWidth: groups.vertical
            Layout.fillHeight: !groups.vertical
            implicitWidth: desktopGrid.implicitWidth
            implicitHeight: desktopGrid.implicitHeight

            active: groups.cfg.showTooltip && desktopGrid.hoveredIndex >= 0
            mainText: groups.info.desktopNames[desktopGrid.hoveredIndex] ?? ""

            DesktopGrid {
              id: desktopGrid

              anchors.fill: parent
              info: groups.info
              actions: groups.actions
              // Only count windows on group's own screen if in a per-screen mode
              occupiedDesktops: groups.perScreen
                ? groups.occupiedByScreen[group.modelData] ?? []
                : groups.occupiedDesktops
              screenName: group.modelData
              screenIndex: groups.allScreens
                ? groups.screenNames.indexOf(group.modelData)
                : -1
            }
          }
        }
      }
    }
  }
}
