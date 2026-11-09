/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick

Item {
  id: highlightFullLine

  required property Highlighter highlight

  HighlightFull {
    anchors.fill: parent
    highlight: highlightFullLine.highlight
    fillOpacity: 0.65
  }

  HighlightLine {
    anchors.fill: parent
    highlight: highlightFullLine.highlight
  }
}
