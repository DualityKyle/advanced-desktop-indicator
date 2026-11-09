/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "../components"

Item {
  id: highlightLine

  required property Highlighter highlight

  readonly property int thickness: 3
  readonly property bool onSideEdge: Plasmoid.location === PlasmaCore.Types.LeftEdge
    || Plasmoid.location === PlasmaCore.Types.RightEdge

  // Sits on the side facing away from the screen edge
  Rectangle {
    x: Plasmoid.location === PlasmaCore.Types.LeftEdge ? highlightLine.width - width : 0
    y: Plasmoid.location === PlasmaCore.Types.TopEdge ? highlightLine.height - height : 0
    width: highlightLine.onSideEdge ? highlightLine.thickness : highlightLine.width
    height: highlightLine.onSideEdge ? highlightLine.height : highlightLine.thickness

    color: highlightLine.highlight.stateColor
    opacity: highlightLine.highlight.intensity

    Behavior on opacity {
      enabled: highlightLine.highlight.animate
      NumberTransition {}
    }
  }
}
