/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QC
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager
import org.kde.plasma.plasmoid
import "../backend"

KCM.SimpleKCM {
  id: appearancePage

  readonly property bool allScreens: Plasmoid.configuration.screenMode === "allScreens"

  property string cfg_indicatorType
  property bool cfg_markOccupied

  // Minimal
  property string cfg_minimalStyle
  property bool cfg_minimalScaleWithPanel
  property real cfg_minimalPanelScale
  property int cfg_minimalFixedSize
  property int cfg_minimalSpacing
  property bool cfg_minimalInactiveOutline
  property real cfg_minimalPillLength
  property string cfg_minimalCharActive
  property string cfg_minimalCharInactive
  property bool cfg_minimalCharPerScreen
  property string cfg_minimalCharsPerScreen
  property int cfg_minimalOpacityInactive
  property string cfg_minimalColorMode
  property color cfg_minimalColorActive
  property color cfg_minimalColorInactive
  property color cfg_minimalColorOccupied

  // Labels
  property string cfg_labelStyle
  property string cfg_labelTemplate
  property string cfg_labelTemplatePerScreen
  property var cfg_labelList: []
  property string cfg_labelListPerScreen
  property bool cfg_labelScaleWithPanel
  property real cfg_labelPanelScale
  property int cfg_labelFixedSize
  property bool cfg_labelAutoWidth
  property int cfg_labelFixedWidth
  property int cfg_labelPadding
  property bool cfg_labelMinWidthPanelHeight
  property int cfg_labelSpacing
  property bool cfg_labelWrap
  property bool cfg_labelBoldActive
  property bool cfg_labelItalicActive
  property bool cfg_labelBoldInactive
  property bool cfg_labelItalicInactive
  property bool cfg_labelActiveAsterisk
  property string cfg_labelHighlight
  property int cfg_labelBoxPadding
  property int cfg_labelBoxRadius
  property bool cfg_labelBoxBorder
  property int cfg_labelBoxBorderWidth
  property int cfg_labelOpacityInactive
  property string cfg_labelColorMode
  property color cfg_labelColorActive
  property color cfg_labelColorInactive
  property color cfg_labelColorHighlight
  property bool cfg_labelOccupiedMatchHighlight
  property color cfg_labelColorOccupied
  property color cfg_labelColorBorder

  // Icons
  property string cfg_iconStyle
  property color cfg_iconTintActive
  property color cfg_iconTintInactive
  property var cfg_iconNames: []
  property var cfg_iconNamesDefault: []
  property bool cfg_iconPerScreen
  property string cfg_iconNamesPerScreen
  property bool cfg_iconScaleWithPanel
  property real cfg_iconPanelScale
  property int cfg_iconFixedSize
  property bool cfg_iconAutoWidth
  property int cfg_iconFixedWidth
  property int cfg_iconPadding
  property bool cfg_iconMinWidthPanelHeight
  property int cfg_iconSpacing
  property string cfg_iconHighlight
  property int cfg_iconBoxPadding
  property int cfg_iconBoxRadius
  property bool cfg_iconBoxBorder
  property int cfg_iconBoxBorderWidth
  property int cfg_iconOpacityInactive
  property string cfg_iconColorMode
  property color cfg_iconColorHighlight
  property bool cfg_iconOccupiedMatchHighlight
  property color cfg_iconColorOccupied
  property color cfg_iconColorBorder

  // Desktop renames wait for Apply
  readonly property alias desktopInfo: virtualDesktopInfo
  property var pendingDesktopNames: ({})

  signal configurationChanged()

  function saveConfig() {
    for (const [index, name] of Object.entries(pendingDesktopNames))
      desktopActions.renameDesktop(Number(index), name);
    pendingDesktopNames = {};
  }

  TaskManager.VirtualDesktopInfo { id: virtualDesktopInfo }
  DesktopActions { id: desktopActions; info: virtualDesktopInfo }

  ColumnLayout {
    Kirigami.FormLayout {
      Layout.fillWidth: true
      twinFormLayouts: typeSection.item ? [typeSection.item] : []

      QC.ComboBox {
        Kirigami.FormData.label: i18n("Indicator type:")
        textRole: "text"
        valueRole: "value"
        model: [
          { text: i18n("Minimal"), value: "minimal" },
          { text: i18n("Labels"), value: "labels" },
          { text: i18n("Icons"), value: "icons" }
        ]
        Component.onCompleted: currentIndex = indexOfValue(cfg_indicatorType)
        onActivated: cfg_indicatorType = currentValue
      }
    }

    Loader {
      id: typeSection
      Layout.fillWidth: true
      sourceComponent: {
        switch (appearancePage.cfg_indicatorType) {
          case "minimal": return minimalSection;
          case "labels": return labelsSection;
          case "icons": return iconsSection;
          default: return null;
        }
      }
    }

    Component {
      id: minimalSection
      MinimalSection { page: appearancePage }
    }
    Component {
      id: labelsSection
      LabelsSection { page: appearancePage }
    }
    Component {
      id: iconsSection
      IconsSection { page: appearancePage }
    }
  }
}
