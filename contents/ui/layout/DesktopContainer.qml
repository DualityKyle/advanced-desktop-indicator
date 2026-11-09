/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import "../backend"
import "../indicatorTypes"

// One desktop that owns its DesktopState and loads the indicator
Item {
  id: container

  required property int index

  readonly property DesktopState desktop: DesktopState {
    index: container.index
    panelThickness: container.desktop.vertical
      ? container.width
      : container.height
  }

  implicitWidth: desktop.vertical ? 0 : (indicator.item?.implicitWidth ?? 0)
  implicitHeight: desktop.vertical ? (indicator.item?.implicitHeight ?? 0) : 0
  Layout.fillWidth: desktop.vertical
  Layout.fillHeight: !desktop.vertical

  Loader {
    id: indicator
    anchors.centerIn: parent
    sourceComponent: {
      switch (Plasmoid.configuration.indicatorType) {
        case "labels": return labelsComponent;
        case "icons": return iconsComponent;
        default: return minimalComponent;
      }
    }
  }

  Component {
    id: minimalComponent
    Minimal { desktop: container.desktop }
  }

  Component {
    id: labelsComponent
    Labels { desktop: container.desktop }
  }

  Component {
    id: iconsComponent
    Icons { desktop: container.desktop }
  }
}
