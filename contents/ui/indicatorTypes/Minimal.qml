/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "../backend"
import "../components"
import "../scripts/screenlists.js" as ScreenLists

Item {
  id: minimal

  readonly property var cfg: Plasmoid.configuration

  required property DesktopState desktop

  readonly property bool pills: cfg.minimalStyle === "pills"
  readonly property bool custom: cfg.minimalStyle === "custom"
  readonly property var screenChars: custom && cfg.minimalCharPerScreen && desktop.screenIndex > 0
    ? ScreenLists.listFor(cfg.minimalCharsPerScreen, desktop.screenIndex)
    : []
  readonly property bool animate: cfg.animationsEnabled

  readonly property real size: cfg.minimalScaleWithPanel
    ? Math.max(2, Math.round(desktop.panelThickness * cfg.minimalPanelScale))
    : Math.min(cfg.minimalFixedSize, desktop.panelThickness)
  readonly property real length: pills && desktop.isCurrent ? Math.round(size * cfg.minimalPillLength) : size
  readonly property real spacing: cfg.minimalSpacing
  readonly property real ringWidth: Math.max(1, Math.round(size * 0.15))
  readonly property real occupiedRingWidth: Math.max(1, Math.round(size * 0.25))
  readonly property bool outline: !custom && cfg.minimalInactiveOutline && !desktop.isCurrent
  readonly property bool occupiedRing: desktop.isOccupied && !desktop.isCurrent

  readonly property color activeColor: {
    switch (cfg.minimalColorMode) {
      case "theme": return Kirigami.Theme.highlightColor;
      case "custom": return cfg.minimalColorActive;
      default: return Kirigami.Theme.textColor;
    }
  }
  readonly property color inactiveColor: cfg.minimalColorMode === "custom"
    ? cfg.minimalColorInactive
    : Kirigami.Theme.textColor
  readonly property color occupiedColor: cfg.minimalColorMode === "custom"
    ? cfg.minimalColorOccupied
    : Kirigami.Theme.highlightColor
  // "transparent" is transparent black which would flash dark
  // mid-fade so fade to the inactive colour with no alpha
  readonly property color clearColor: Qt.rgba(inactiveColor.r, inactiveColor.g, inactiveColor.b, 0)

  readonly property Item shape: custom ? char : dot

  implicitWidth: shape.width + (desktop.vertical ? 0 : spacing)
  implicitHeight: shape.height + (desktop.vertical ? spacing : 0)
  opacity: desktop.isCurrent ? 1 : cfg.minimalOpacityInactive / 100

  Behavior on opacity {
    enabled: minimal.animate
    NumberTransition {}
  }

  Rectangle {
    id: dot

    visible: !minimal.custom
    anchors.centerIn: parent
    width: minimal.desktop.vertical ? minimal.size : minimal.length
    height: minimal.desktop.vertical ? minimal.length : minimal.size
    radius: Math.min(width, height) / 2
    color: minimal.desktop.isCurrent ? minimal.activeColor
      : minimal.outline ? minimal.clearColor
      : minimal.inactiveColor
    border.width: minimal.occupiedRing ? minimal.occupiedRingWidth
      : minimal.outline ? minimal.ringWidth
      : 0
    border.color: minimal.occupiedRing ? minimal.occupiedColor : minimal.inactiveColor

    Behavior on width {
      enabled: minimal.animate
      NumberTransition {}
    }
    Behavior on height {
      enabled: minimal.animate
      NumberTransition {}
    }
    Behavior on color {
      enabled: minimal.animate
      ColorTransition {}
    }
    Behavior on border.width {
      enabled: minimal.animate
      NumberTransition {}
    }
    Behavior on border.color {
      enabled: minimal.animate
      ColorTransition {}
    }
  }

  Item {
    id: char

    visible: minimal.custom
    anchors.centerIn: parent
    width: minimal.desktop.isSideways ? charText.implicitHeight : charText.implicitWidth
    height: minimal.desktop.isSideways ? charText.implicitWidth : charText.implicitHeight

    Text {
      id: charText

      anchors.centerIn: parent
      rotation: minimal.desktop.textRotation
      font.pixelSize: minimal.size
      // This screen's custom character, then screen 1, then the default
      text: minimal.desktop.isCurrent
        ? (minimal.screenChars[0] || minimal.cfg.minimalCharActive || "●")
        : (minimal.screenChars[1] || minimal.cfg.minimalCharInactive || "○")
      color: minimal.desktop.isCurrent ? minimal.activeColor
        : minimal.occupiedRing ? minimal.occupiedColor
        : minimal.inactiveColor

      Behavior on color {
        enabled: minimal.animate
        ColorTransition {}
      }
    }
  }
}
