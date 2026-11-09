/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import "../components"

Item {
  id: highlightFull

  required property Highlighter highlight
  property real fillOpacity: 1

  Rectangle {
    anchors.fill: parent

    color: highlightFull.highlight.stateColor
    opacity: highlightFull.highlight.intensity * highlightFull.fillOpacity

    Behavior on opacity {
      enabled: highlightFull.highlight.animate
      NumberTransition {}
    }
  }
}
