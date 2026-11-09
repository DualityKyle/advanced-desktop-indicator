/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "../backend"

// Loads the chosen highlight type for any indicator that uses highlights
Loader {
  id: highlighter

  property string type: "none"
  required property DesktopState desktop
  property real inactiveOpacity: 1
  property real contentThickness: 0
  property color color: Kirigami.Theme.highlightColor
  property color occupiedColor: color
  property color borderColor: Kirigami.Theme.textColor

  // How strongly the highlight shows (hover takes precedent)
  readonly property real intensity: {
    if (desktop.isHovered)
      return 0.35;
    if (desktop.isCurrent)
      return 1;
    if (desktop.isOccupied)
      return 0.55;
    return 0;
  }
  readonly property color stateColor: !desktop.isHovered && !desktop.isCurrent && desktop.isOccupied
    ? occupiedColor
    : color

  // Boxes-specific properties
  property int boxPadding: 4
  property int boxRadius: 25
  property bool boxBorder: true
  property int boxBorderWidth: 1

  readonly property bool animate: Plasmoid.configuration.animationsEnabled

  sourceComponent: {
    switch (type) {
      case "line": return lineComponent;
      case "full": return fullComponent;
      case "fullLine": return fullLineComponent;
      case "boxes": return boxesComponent;
      default: return null;
    }
  }

  Component {
    id: lineComponent

    HighlightLine { highlight: highlighter }
  }

  Component {
    id: fullComponent

    HighlightFull { highlight: highlighter }
  }

  Component {
    id: fullLineComponent

    HighlightFullLine { highlight: highlighter }
  }

  Component {
    id: boxesComponent

    HighlightBoxes { highlight: highlighter }
  }
}
