/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Effects
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "../backend"
import "../components"
import "../highlights"
import "../scripts/screenlists.js" as ScreenLists

Item {
  id: icons

  readonly property var cfg: Plasmoid.configuration

  required property DesktopState desktop

  readonly property string defaultIcon: "desktop-symbolic"
  readonly property string screenIcon: cfg.iconPerScreen && desktop.screenIndex > 0
    ? ScreenLists.listFor(cfg.iconNamesPerScreen, desktop.screenIndex)[desktop.index] ?? ""
    : ""
  // This screen's icon, then screen 1, then the default
  readonly property string iconName: screenIcon || (cfg.iconNames ?? [])[desktop.index] || defaultIcon

  readonly property real iconSize: cfg.iconScaleWithPanel
    ? Math.round(desktop.panelThickness * cfg.iconPanelScale)
    : Math.min(cfg.iconFixedSize, desktop.panelThickness)
  readonly property real spacing: cfg.iconSpacing
  readonly property real padding: cfg.iconAutoWidth ? cfg.iconPadding : 0
  readonly property real minimumLength: cfg.iconMinWidthPanelHeight ? desktop.panelThickness : 0
  // Size along the panel, before spacing
  readonly property real length: Math.max(
    minimumLength,
    cfg.iconAutoWidth ? icon.width + padding * 2 : cfg.iconFixedWidth
  )
  readonly property bool animate: cfg.animationsEnabled

  // Icon styles
  readonly property string style: cfg.iconStyle
  readonly property bool flat: style === "customFlat"
  readonly property bool tinted: style === "customTinted"
  readonly property bool greyed: style === "greyscale"
    || (style === "greyInactive" && !desktop.isCurrent)
  // Greyscale and tinted styles need a shader
  readonly property bool usesShader: tinted || style === "greyscale" || style === "greyInactive"
  readonly property color tintColor: desktop.isCurrent
    ? cfg.iconTintActive
    : cfg.iconTintInactive

  // Colours for highlights and the open-windows dot
  readonly property bool customColors: cfg.iconColorMode === "custom"
  readonly property color highlightColor: customColors
    ? cfg.iconColorHighlight
    : Kirigami.Theme.highlightColor
  readonly property color occupiedColor: customColors && !cfg.iconOccupiedMatchHighlight
    ? cfg.iconColorOccupied
    : highlightColor
  readonly property color borderColor: customColors
    ? cfg.iconColorBorder
    : Kirigami.Theme.textColor

  implicitWidth: desktop.vertical ? desktop.panelThickness : length + spacing
  implicitHeight: desktop.vertical ? length + spacing : desktop.panelThickness

  // Covers the cell but not the spacing so highlights don't touch
  Item {
    id: highlightArea

    anchors.centerIn: parent
    width: icons.desktop.vertical ? icons.width : icons.width - icons.spacing
    height: icons.desktop.vertical ? icons.height - icons.spacing : icons.height

    Highlighter {
      anchors.fill: parent
      type: icons.cfg.iconHighlight
      desktop: icons.desktop
      inactiveOpacity: icons.cfg.iconOpacityInactive / 100
      color: icons.highlightColor
      occupiedColor: icons.occupiedColor
      borderColor: icons.borderColor

      contentThickness: icon.width
      boxPadding: icons.cfg.iconBoxPadding
      boxRadius: icons.cfg.iconBoxRadius
      boxBorder: icons.cfg.iconBoxBorder
      boxBorderWidth: icons.cfg.iconBoxBorderWidth
    }
  }

  Kirigami.Icon {
    id: icon

    anchors.centerIn: parent
    width: Math.max(8, icons.iconSize)
    height: width
    rotation: icons.desktop.textRotation

    source: icons.iconName
    // Fallback in case the selected icon isn't in the theme
    fallback: icons.defaultIcon

    isMask: icons.flat
    color: icons.flat ? icons.tintColor : "transparent"
    opacity: icons.desktop.isCurrent ? 1 : icons.cfg.iconOpacityInactive / 100

    Behavior on opacity {
      enabled: icons.animate
      NumberTransition {}
    }

    // Greyscale and tinted styles need a shader; others skip it
    layer.enabled: icons.usesShader
    layer.effect: MultiEffect {
      saturation: icons.greyed ? -1 : 0
      colorization: icons.tinted ? 1 : 0
      colorizationColor: icons.tintColor

      Behavior on saturation {
        enabled: icons.animate
        NumberTransition {}
      }
    }
  }

  // Show a small indicator dot for open windows if no highlight is selected
  Rectangle {
    id: occupiedDot

    // Halfway between the icon's edge and the panel's edge
    readonly property real offset: (icon.width + icons.desktop.panelThickness) / 4

    anchors.centerIn: parent
    anchors.horizontalCenterOffset: {
      switch (Plasmoid.location) {
        case PlasmaCore.Types.LeftEdge: return offset;
        case PlasmaCore.Types.RightEdge: return -offset;
        default: return 0;
      }
    }
    anchors.verticalCenterOffset: {
      switch (Plasmoid.location) {
        case PlasmaCore.Types.TopEdge: return offset;
        case PlasmaCore.Types.LeftEdge:
        case PlasmaCore.Types.RightEdge: return 0;
        default: return -offset;
      }
    }
    width: Math.max(3, Math.round(icon.width * 0.15))
    height: width
    radius: width / 2

    color: icons.occupiedColor
    opacity: icons.desktop.isOccupied && !icons.desktop.isCurrent && icons.cfg.iconHighlight === "none" ? 1 : 0

    Behavior on opacity {
      enabled: icons.animate
      NumberTransition {}
    }
  }
}
