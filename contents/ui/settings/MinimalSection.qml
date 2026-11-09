/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QC
import org.kde.kquickcontrols as KQuickControls
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3
import "../scripts/screenlists.js" as ScreenLists

Kirigami.FormLayout {
  id: section

  required property var page

  readonly property bool customStyle: page.cfg_minimalStyle === "custom"
  readonly property bool pillStyle: page.cfg_minimalStyle === "pills"
  readonly property bool customColors: page.cfg_minimalColorMode === "custom"
  // All-screens view: each screen can have its own characters
  readonly property bool allScreens: page.allScreens
  readonly property int editScreen: allScreens && page.cfg_minimalCharPerScreen ? screenTabs.currentIndex : 0

  // Entry 0 is the active character, 1 the inactive one
  function charAt(entry) {
    if (editScreen > 0)
      return ScreenLists.listFor(page.cfg_minimalCharsPerScreen, editScreen)[entry] ?? "";
    return entry === 0 ? page.cfg_minimalCharActive : page.cfg_minimalCharInactive;
  }

  function setChar(entry, text) {
    if (editScreen > 0) {
      page.cfg_minimalCharsPerScreen = ScreenLists.withEntry(page.cfg_minimalCharsPerScreen, editScreen, entry, text);
      return;
    }
    if (entry === 0)
      page.cfg_minimalCharActive = text;
    else
      page.cfg_minimalCharInactive = text;
  }

  QC.ComboBox {
    Kirigami.FormData.label: i18n("Style:")
    textRole: "text"
    valueRole: "value"
    model: [
      { text: i18n("Dots"), value: "dots" },
      { text: i18n("GNOME-style pills"), value: "pills" },
      { text: i18n("Custom characters"), value: "custom" }
    ]
    Component.onCompleted: currentIndex = indexOfValue(section.page.cfg_minimalStyle)
    onActivated: section.page.cfg_minimalStyle = currentValue
  }
  QC.CheckBox {
    visible: !section.customStyle
    text: i18n("Show inactive desktops as outlines")
    checked: section.page.cfg_minimalInactiveOutline
    onToggled: section.page.cfg_minimalInactiveOutline = checked
  }
  FluidSlider {
    Kirigami.FormData.label: i18n("Active pill length:")
    visible: section.pillStyle
    from: 1
    to: 4
    step: 0.25
    widestValue: 3.75
    value: section.page.cfg_minimalPillLength
    formatValue: (value) => i18n("%1×", value)
    onMoved: (value) => section.page.cfg_minimalPillLength = value
  }

  Kirigami.Separator {
    Kirigami.FormData.isSection: true
    Kirigami.FormData.label: i18n("Size")
  }
  RowLayout {
    Kirigami.FormData.label: i18n("Size mode:")

    QC.RadioButton {
      text: i18n("Scale with panel")
      checked: section.page.cfg_minimalScaleWithPanel
      onToggled: section.page.cfg_minimalScaleWithPanel = checked
    }
    QC.RadioButton {
      text: i18n("Fixed")
      checked: !section.page.cfg_minimalScaleWithPanel
      onToggled: section.page.cfg_minimalScaleWithPanel = !checked
    }
  }
  Item {
    implicitHeight: Kirigami.Units.smallSpacing
    visible: section.page.cfg_minimalScaleWithPanel
  }
  RowLayout {
    spacing: 0
    Kirigami.FormData.label: i18n("Size:")
    visible: section.page.cfg_minimalScaleWithPanel

    FluidSlider {
      from: 0.1
      to: 1
      step: 0.01
      value: section.page.cfg_minimalPanelScale
      formatValue: (value) => i18n("%1%", Math.round(value * 100))
      onMoved: (value) => section.page.cfg_minimalPanelScale = value
    }
    Kirigami.ContextualHelpButton {
      toolTipText: i18n("Percentage of the panel's thickness.")
    }
  }
  PC3.SpinBox {
    Kirigami.FormData.label: i18n("Size:")
    visible: !section.page.cfg_minimalScaleWithPanel
    from: 10
    to: 72
    value: section.page.cfg_minimalFixedSize
    onValueModified: section.page.cfg_minimalFixedSize = value
  }
  Item {
    implicitHeight: Kirigami.Units.smallSpacing
    visible: !section.page.cfg_minimalScaleWithPanel
  }
  FluidSlider {
    Kirigami.FormData.label: i18n("Spacing:")
    from: 0
    to: 20
    value: section.page.cfg_minimalSpacing
    formatValue: (value) => i18n("%1px", value)
    onMoved: (value) => section.page.cfg_minimalSpacing = value
  }
  FluidSlider {
    Kirigami.FormData.label: i18n("Inactive opacity:")
    from: 10
    to: 100
    step: 5
    value: section.page.cfg_minimalOpacityInactive
    formatValue: (value) => i18n("%1%", value)
    onMoved: (value) => section.page.cfg_minimalOpacityInactive = value
  }

  Kirigami.Separator {
    Kirigami.FormData.isSection: true
    Kirigami.FormData.label: i18n("Custom Characters")
    visible: section.customStyle
  }
  RowLayout {
    Kirigami.FormData.label: i18n("Multiple screens:")
    visible: section.customStyle && section.allScreens

    QC.CheckBox {
      text: i18n("Different characters for each screen")
      checked: section.page.cfg_minimalCharPerScreen
      onToggled: section.page.cfg_minimalCharPerScreen = checked
    }
    Kirigami.ContextualHelpButton {
      toolTipText: i18n("Screens are numbered left to right, so if you rearrange your screens in Display settings, the characters follow the screen's position, not the physical monitor. Empty fields on other screens use screen 1's characters.")
    }
  }
  ScreenTabs {
    id: screenTabs
    visible: section.customStyle && section.allScreens && section.page.cfg_minimalCharPerScreen && Qt.application.screens.length > 1
  }
  RowLayout {
    visible: section.customStyle

    CharBox {
      label: i18n("Active")
      // Later screens fall back to screen 1's character
      placeholder: section.editScreen > 0 ? section.page.cfg_minimalCharActive || "●" : "●"
      value: section.charAt(0)
      onEdited: (text) => section.setChar(0, text)
    }
    CharBox {
      label: i18n("Inactive")
      placeholder: section.editScreen > 0 ? section.page.cfg_minimalCharInactive || "○" : "○"
      value: section.charAt(1)
      onEdited: (text) => section.setChar(1, text)
    }
  }

  Kirigami.Separator {
    Kirigami.FormData.isSection: true
    Kirigami.FormData.label: i18n("Colours")
  }
  RowLayout {
    Kirigami.FormData.label: i18n("Scheme:")

    QC.ComboBox {
      textRole: "text"
      valueRole: "value"
      model: [
        { text: i18n("Plain"), value: "plain" },
        { text: i18n("Follow theme"), value: "theme" },
        { text: i18n("Custom"), value: "custom" }
      ]
      Component.onCompleted: currentIndex = indexOfValue(section.page.cfg_minimalColorMode)
      onActivated: section.page.cfg_minimalColorMode = currentValue
    }
    Kirigami.ContextualHelpButton {
      toolTipText: i18n("Plain uses the text colour for every desktop. Follow theme uses the highlight colour for the active desktop. Both use the highlight colour for desktops with open windows.")
    }
  }
  QC.CheckBox {
    text: i18n("Mark desktops with open windows")
    checked: section.page.cfg_markOccupied
    onToggled: section.page.cfg_markOccupied = checked
  }
  RowLayout {
    visible: section.customColors

    ColorPicker {
      label: i18n("Active")
      color: section.page.cfg_minimalColorActive
      onAccepted: (color) => section.page.cfg_minimalColorActive = color
    }
    ColorPicker {
      label: i18n("Inactive")
      color: section.page.cfg_minimalColorInactive
      onAccepted: (color) => section.page.cfg_minimalColorInactive = color
    }
    ColorPicker {
      enabled: section.page.cfg_markOccupied
      label: i18n("Open windows")
      color: section.page.cfg_minimalColorOccupied
      onAccepted: (color) => section.page.cfg_minimalColorOccupied = color
    }
  }
}
