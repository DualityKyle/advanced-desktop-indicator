/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "../backend"
import "../components"
import "../highlights"
import "../scripts/screenlists.js" as ScreenLists

Item {
  id: labels

  readonly property var cfg: Plasmoid.configuration

  required property DesktopState desktop

  readonly property string number: String(desktop.index + 1)
  // Later screens in allScreens mode can have their own template/defined list
  readonly property string listEntry: cfg.labelStyle === "list" && desktop.screenIndex > 0
    ? ScreenLists.listFor(cfg.labelListPerScreen, desktop.screenIndex)[desktop.index] ?? ""
    : ""
  readonly property string template: (cfg.labelStyle === "template" && desktop.screenIndex > 0
    ? ScreenLists.listFor(cfg.labelTemplatePerScreen, desktop.screenIndex)[0] ?? ""
    : "") || cfg.labelTemplate || "%n"
  readonly property string displayText: {
    switch (cfg.labelStyle) {
      case "name":
        return desktop.name || number;
      case "template":
        return template
          // A function so "$" in desktop names don't get read as replace patterns
          .replace(/%n/g, number)
          .replace(/%d/g, () => desktop.name || number);
      case "list":
        // settings save as user types so trim any start/end whitespace
        return listEntry.trim() || ((cfg.labelList ?? [])[desktop.index] ?? "").trim() || number;
      case "number":
      default:
        return number;
    }
  }
  readonly property string activeMarker: desktop.isCurrent && cfg.labelActiveAsterisk ? "*" : ""

  readonly property real textSize: cfg.labelScaleWithPanel
    ? Math.round(desktop.panelThickness * cfg.labelPanelScale)
    : Math.min(cfg.labelFixedSize, desktop.panelThickness)
  readonly property real spacing: cfg.labelSpacing
  readonly property real padding: fitText ? cfg.labelPadding : 0
  readonly property real minimumLength: cfg.labelMinWidthPanelHeight ? desktop.panelThickness : 0
  readonly property bool animate: cfg.animationsEnabled

  readonly property bool customColors: cfg.labelColorMode === "custom"
  readonly property color activeColor: customColors
    ? cfg.labelColorActive
    : Kirigami.Theme.textColor
  readonly property color inactiveColor: customColors
    ? cfg.labelColorInactive
    : Kirigami.Theme.textColor
  readonly property color highlightColor: customColors
    ? cfg.labelColorHighlight
    : Kirigami.Theme.highlightColor
  readonly property color occupiedColor: customColors && !cfg.labelOccupiedMatchHighlight
    ? cfg.labelColorOccupied
    : highlightColor
  readonly property color borderColor: customColors
    ? cfg.labelColorBorder
    : Kirigami.Theme.textColor
  // If no highlight is selected, open windows are shown by colouring the text
  readonly property bool occupiedText: desktop.isOccupied && cfg.labelHighlight === "none"

  // Fitting width to the text only makes sense if it's along the panel
  readonly property bool textAlongPanel: desktop.vertical === desktop.isSideways
  readonly property bool fitText: textAlongPanel && cfg.labelAutoWidth

  readonly property real textWidth: textAlongPanel
    ? cfg.labelFixedWidth
    : desktop.panelThickness

  implicitWidth: desktop.vertical
    ? desktop.panelThickness
    : Math.max(minimumLength, labelBox.width + padding * 2) + spacing
  implicitHeight: desktop.vertical
    ? Math.max(minimumLength, labelBox.height + padding * 2) + spacing
    : desktop.panelThickness

  // Covers the label but not the spacing so highlights don't touch
  Item {
    id: highlightArea

    anchors.centerIn: parent
    width: labels.desktop.vertical ? labels.width : labels.width - labels.spacing
    height: labels.desktop.vertical ? labels.height - labels.spacing : labels.height

    Highlighter {
      anchors.fill: parent
      type: labels.cfg.labelHighlight
      desktop: labels.desktop
      inactiveOpacity: labels.cfg.labelOpacityInactive / 100
      color: labels.highlightColor
      occupiedColor: labels.occupiedColor
      borderColor: labels.borderColor

      contentThickness: labels.desktop.vertical ? labelBox.width : labelBox.height
      boxPadding: labels.cfg.labelBoxPadding
      boxRadius: labels.cfg.labelBoxRadius
      boxBorder: labels.cfg.labelBoxBorder
      boxBorderWidth: labels.cfg.labelBoxBorderWidth
    }
  }

  Item {
    id: labelBox

    anchors.centerIn: parent
    width: labels.desktop.isSideways ? labelText.height : labelText.width
    height: labels.desktop.isSideways ? labelText.width : labelText.height

    Text {
      id: labelText

      anchors.centerIn: parent
      rotation: labels.desktop.textRotation
      width: labels.fitText ? implicitWidth : labels.textWidth
      // Wrapped text can't grow taller than the panel
      height: labels.textAlongPanel
        ? Math.min(implicitHeight, labels.desktop.panelThickness)
        : implicitHeight

      text: labels.displayText + labels.activeMarker
      wrapMode: labels.cfg.labelWrap ? Text.Wrap : Text.NoWrap
      elide: Text.ElideRight
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter

      color: {
        if (labels.desktop.isCurrent)
          return labels.activeColor;
        if (labels.occupiedText)
          return labels.occupiedColor;
        return labels.inactiveColor;
      }
      font.pixelSize: Math.max(6, labels.textSize)
      font.bold: labels.desktop.isCurrent
        ? labels.cfg.labelBoldActive
        : labels.cfg.labelBoldInactive
      font.italic: labels.desktop.isCurrent
        ? labels.cfg.labelItalicActive
        : labels.cfg.labelItalicInactive
      opacity: labels.desktop.isCurrent ? 1 : labels.cfg.labelOpacityInactive / 100

      Behavior on opacity {
        enabled: labels.animate
        NumberTransition {}
      }
      Behavior on color {
        enabled: labels.animate
        ColorTransition {}
      }
    }
  }
}
