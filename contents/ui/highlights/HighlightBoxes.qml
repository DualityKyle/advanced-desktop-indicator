/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import "../components"

Item {
  id: highlightBoxes

  required property Highlighter highlight

  Rectangle {
    id: box

    readonly property Highlighter highlight: highlightBoxes.highlight
    readonly property bool vertical: highlight.desktop.vertical
    readonly property real thickness: Math.min(
      vertical ? highlightBoxes.width : highlightBoxes.height,
      highlight.contentThickness + highlight.boxPadding * 2
    )

    anchors.centerIn: parent
    width: vertical ? thickness : highlightBoxes.width
    height: vertical ? highlightBoxes.height : thickness
    radius: thickness * highlight.boxRadius / 100

    color: Qt.rgba(highlight.stateColor.r, highlight.stateColor.g, highlight.stateColor.b, highlight.intensity)
    border.width: highlight.boxBorder ? highlight.boxBorderWidth : 0
    border.color: highlight.borderColor
    opacity: highlight.intensity === 1 ? 1 : highlight.inactiveOpacity

    Behavior on color {
      enabled: box.highlight.animate
      ColorTransition {}
    }
    Behavior on opacity {
      enabled: box.highlight.animate
      NumberTransition {}
    }
  }
}
