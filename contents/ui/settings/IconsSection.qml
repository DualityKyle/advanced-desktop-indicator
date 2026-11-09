/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QC
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3
import org.kde.iconthemes as KIconThemes
import "../scripts/screenlists.js" as ScreenLists

Kirigami.FormLayout {
  id: section

  required property var page

  readonly property string defaultIcon: "desktop-symbolic"
  readonly property bool customTint: page.cfg_iconStyle === "customFlat" || page.cfg_iconStyle === "customTinted"
  readonly property bool boxesHighlight: page.cfg_iconHighlight === "boxes"
  readonly property bool customColors: page.cfg_iconColorMode === "custom"
  // All-screens view: each screen can have its own icons
  readonly property bool allScreens: page.allScreens
  readonly property int editScreen: allScreens && page.cfg_iconPerScreen ? screenTabs.currentIndex : 0

  // Desktop whose icon the picker is choosing
  property int pickingIndex: -1

  // What's typed for a desktop on the screen being edited; empty means unset
  function entryAt(index) {
    return editScreen > 0
      ? ScreenLists.listFor(page.cfg_iconNamesPerScreen, editScreen)[index] ?? ""
      : page.cfg_iconNames[index] ?? "";
  }

  // What an unset entry falls back to, matching the panel
  function fallbackAt(index) {
    return editScreen > 0
      ? page.cfg_iconNames[index] || defaultIcon
      : defaultIcon;
  }

  // What the reset button restores: the built-in icon on screen 1, unset on later screens
  function resetValueAt(index) {
    return editScreen > 0 ? "" : page.cfg_iconNamesDefault[index] ?? "";
  }

  // Assign a new array so the page notices the change
  function setIconEntry(index, name) {
    if (editScreen > 0) {
      page.cfg_iconNamesPerScreen = ScreenLists.withEntry(page.cfg_iconNamesPerScreen, editScreen, index, name);
      return;
    }
    const list = page.cfg_iconNames.slice();
    while (list.length <= index)
      list.push("");
    list[index] = name;
    page.cfg_iconNames = list;
  }

  KIconThemes.IconDialog {
    id: iconDialog
    onIconNameChanged: (name) => {
      if (section.pickingIndex >= 0 && name)
        section.setIconEntry(section.pickingIndex, name);
    }
  }

  RowLayout {
    Kirigami.FormData.label: i18n("Style:")

    QC.ComboBox {
      textRole: "text"
      valueRole: "value"
      model: [
        { text: i18n("Original colours"), value: "original" },
        { text: i18n("Greyscale when inactive"), value: "greyInactive" },
        { text: i18n("Greyscale"), value: "greyscale" },
        { text: i18n("Custom colour (flat)"), value: "customFlat" },
        { text: i18n("Custom colour (tinted)"), value: "customTinted" }
      ]
      Component.onCompleted: currentIndex = indexOfValue(section.page.cfg_iconStyle)
      onActivated: section.page.cfg_iconStyle = currentValue
    }
    Kirigami.ContextualHelpButton {
      toolTipText: i18n("<b>Flat:</b> fills the icon's shape with the colour.<br><br><b>Tinted:</b> keeps the icon's detail in shades of the colour.")
    }
  }
  RowLayout {
    Kirigami.FormData.label: i18n("Tint:")
    visible: section.customTint

    ColorPicker {
      label: i18n("Active")
      color: section.page.cfg_iconTintActive
      onAccepted: (color) => section.page.cfg_iconTintActive = color
    }
    ColorPicker {
      label: i18n("Inactive")
      color: section.page.cfg_iconTintInactive
      onAccepted: (color) => section.page.cfg_iconTintInactive = color
    }
  }
  FluidSlider {
    Kirigami.FormData.label: i18n("Inactive opacity:")
    from: 10
    to: 100
    step: 5
    value: section.page.cfg_iconOpacityInactive
    formatValue: (value) => i18n("%1%", value)
    onMoved: (value) => section.page.cfg_iconOpacityInactive = value
  }
  RowLayout {
    Kirigami.FormData.label: i18n("Multiple screens:")
    visible: section.allScreens

    QC.CheckBox {
      text: i18n("Different icons for each screen")
      checked: section.page.cfg_iconPerScreen
      onToggled: section.page.cfg_iconPerScreen = checked
    }
    Kirigami.ContextualHelpButton {
      toolTipText: i18n("Screens are numbered left to right, so if you rearrange your screens in Display settings, the icons follow the screen's position, not the physical monitor. Unset icons on other screens use screen 1's icons.")
    }
  }
  ScreenTabs {
    id: screenTabs
    visible: section.allScreens && section.page.cfg_iconPerScreen && Qt.application.screens.length > 1
  }
  Repeater {
    model: section.page.desktopInfo.numberOfDesktops

    RowLayout {
      required property int index

      Kirigami.FormData.label: i18n("%1:", section.page.desktopInfo.desktopNames[index])

      QC.Button {
        icon.name: section.entryAt(index) || section.fallbackAt(index)
        display: QC.AbstractButton.IconOnly
        QC.ToolTip.text: i18n("Choose icon…")
        QC.ToolTip.visible: hovered
        QC.ToolTip.delay: Kirigami.Units.toolTipDelay
        onClicked: {
          section.pickingIndex = index;
          iconDialog.open();
        }
      }
      QC.TextField {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 12
        placeholderText: section.fallbackAt(index)
        text: section.entryAt(index)
        QC.ToolTip.text: i18n("An icon name from your theme, or the path to an image.")
        QC.ToolTip.visible: hovered
        QC.ToolTip.delay: Kirigami.Units.toolTipDelay
        onTextEdited: section.setIconEntry(index, text.trim())
      }
      QC.ToolButton {
        icon.name: "edit-undo"
        display: QC.AbstractButton.IconOnly
        visible: section.entryAt(index) !== section.resetValueAt(index)
        QC.ToolTip.text: section.editScreen > 0
          ? i18n("Use screen 1's icon")
          : i18n("Use default icon")
        QC.ToolTip.visible: hovered
        QC.ToolTip.delay: Kirigami.Units.toolTipDelay
        onClicked: section.setIconEntry(index, section.resetValueAt(index))
      }
    }
  }

  Kirigami.Separator {
    Kirigami.FormData.isSection: true
    Kirigami.FormData.label: i18n("Size")
  }
  RowLayout {
    Kirigami.FormData.label: i18n("Size mode:")

    QC.RadioButton {
      text: i18n("Scale with panel")
      checked: section.page.cfg_iconScaleWithPanel
      onToggled: section.page.cfg_iconScaleWithPanel = checked
    }
    QC.RadioButton {
      text: i18n("Fixed")
      checked: !section.page.cfg_iconScaleWithPanel
      onToggled: section.page.cfg_iconScaleWithPanel = !checked
    }
  }
  RowLayout {
    spacing: 0
    Kirigami.FormData.label: i18n("Size:")
    visible: section.page.cfg_iconScaleWithPanel

    FluidSlider {
      from: 0.1
      to: 1
      step: 0.01
      value: section.page.cfg_iconPanelScale
      formatValue: (value) => i18n("%1%", Math.round(value * 100))
      onMoved: (value) => section.page.cfg_iconPanelScale = value
    }
    Kirigami.ContextualHelpButton {
      toolTipText: i18n("Percentage of the panel's thickness.")
    }
  }
  PC3.SpinBox {
    Kirigami.FormData.label: i18n("Size:")
    visible: !section.page.cfg_iconScaleWithPanel
    from: 8
    to: 128
    value: section.page.cfg_iconFixedSize
    onValueModified: section.page.cfg_iconFixedSize = value
  }

  Kirigami.Separator {
    Kirigami.FormData.isSection: true
    Kirigami.FormData.label: i18n("Width")
  }
  RowLayout {
    Kirigami.FormData.label: i18n("Width mode:")

    QC.RadioButton {
      text: i18n("Fit to icon")
      checked: section.page.cfg_iconAutoWidth
      onToggled: section.page.cfg_iconAutoWidth = checked
    }
    QC.RadioButton {
      text: i18n("Fixed")
      checked: !section.page.cfg_iconAutoWidth
      onToggled: section.page.cfg_iconAutoWidth = !checked
    }
  }
  Item {
    implicitHeight: Kirigami.Units.smallSpacing
  }
  FluidSlider {
    Kirigami.FormData.label: i18n("Padding:")
    visible: section.page.cfg_iconAutoWidth
    from: 0
    to: 20
    value: section.page.cfg_iconPadding
    formatValue: (value) => i18n("%1px", value)
    onMoved: (value) => section.page.cfg_iconPadding = value
  }
  FluidSlider {
    Kirigami.FormData.label: i18n("Width:")
    visible: !section.page.cfg_iconAutoWidth
    from: 20
    to: 160
    step: 5
    value: section.page.cfg_iconFixedWidth
    formatValue: (value) => i18n("%1px", value)
    onMoved: (value) => section.page.cfg_iconFixedWidth = value
  }
  Item {
    implicitHeight: Kirigami.Units.smallSpacing
  }
  RowLayout {
    Kirigami.FormData.label: i18n("Minimum width:")

    QC.CheckBox {
      text: i18n("Same as panel height")
      checked: section.page.cfg_iconMinWidthPanelHeight
      onToggled: section.page.cfg_iconMinWidthPanelHeight = checked
    }
    Kirigami.ContextualHelpButton {
      toolTipText: i18n("On vertical panels, this is the panel's width.")
    }
  }
  FluidSlider {
    Kirigami.FormData.label: i18n("Spacing:")
    from: 0
    to: 40
    value: section.page.cfg_iconSpacing
    formatValue: (value) => i18n("%1px", value)
    onMoved: (value) => section.page.cfg_iconSpacing = value
  }

  Kirigami.Separator {
    Kirigami.FormData.isSection: true
    Kirigami.FormData.label: i18n("Highlight")
  }
  QC.ComboBox {
    Kirigami.FormData.label: i18n("Type:")
    textRole: "text"
    valueRole: "value"
    model: [
      { text: i18n("Line"), value: "line" },
      { text: i18n("Fill"), value: "full" },
      { text: i18n("Fill + line"), value: "fullLine" },
      { text: i18n("Boxes"), value: "boxes" },
      { text: i18n("None"), value: "none" }
    ]
    Component.onCompleted: currentIndex = indexOfValue(section.page.cfg_iconHighlight)
    onActivated: section.page.cfg_iconHighlight = currentValue
  }
  QC.CheckBox {
    visible: section.boxesHighlight
    text: i18n("Show border")
    checked: section.page.cfg_iconBoxBorder
    onToggled: section.page.cfg_iconBoxBorder = checked
  }
  FluidSlider {
    Kirigami.FormData.label: i18n("Border thickness:")
    visible: section.boxesHighlight && section.page.cfg_iconBoxBorder
    from: 1
    to: 5
    value: section.page.cfg_iconBoxBorderWidth
    formatValue: (value) => i18n("%1px", value)
    onMoved: (value) => section.page.cfg_iconBoxBorderWidth = value
  }
  RowLayout {
    spacing: 0
    Kirigami.FormData.label: i18n("Box padding:")
    visible: section.boxesHighlight

    FluidSlider {
      from: 0
      to: 20
      value: section.page.cfg_iconBoxPadding
      formatValue: (value) => i18n("%1px", value)
      onMoved: (value) => section.page.cfg_iconBoxPadding = value
    }
    Kirigami.ContextualHelpButton {
      toolTipText: i18n("Space between the icon and the box, across the panel. Use the padding under Width for space at the ends.")
    }
  }
  FluidSlider {
    Kirigami.FormData.label: i18n("Corner radius:")
    visible: section.boxesHighlight
    from: 0
    to: 50
    step: 5
    value: section.page.cfg_iconBoxRadius
    formatValue: (value) => i18n("%1%", value)
    onMoved: (value) => section.page.cfg_iconBoxRadius = value
  }

  Kirigami.Separator {
    Kirigami.FormData.isSection: true
    Kirigami.FormData.label: i18n("Colours")
  }
  QC.ComboBox {
    Kirigami.FormData.label: i18n("Scheme:")
    textRole: "text"
    valueRole: "value"
    model: [
      { text: i18n("Follow theme"), value: "theme" },
      { text: i18n("Custom"), value: "custom" }
    ]
    Component.onCompleted: currentIndex = indexOfValue(section.page.cfg_iconColorMode)
    onActivated: section.page.cfg_iconColorMode = currentValue
  }
  QC.CheckBox {
    text: i18n("Mark desktops with open windows")
    checked: section.page.cfg_markOccupied
    onToggled: section.page.cfg_markOccupied = checked
  }
  RowLayout {
    Kirigami.FormData.label: i18n("Highlight:")
    visible: section.customColors

    ColorPicker {
      label: i18n("Active")
      color: section.page.cfg_iconColorHighlight
      onAccepted: (color) => section.page.cfg_iconColorHighlight = color
    }
    ColorPicker {
      enabled: section.page.cfg_markOccupied && !section.page.cfg_iconOccupiedMatchHighlight
      label: i18n("Open windows")
      color: section.page.cfg_iconColorOccupied
      onAccepted: (color) => section.page.cfg_iconColorOccupied = color
    }
    ColorPicker {
      visible: section.boxesHighlight && section.page.cfg_iconBoxBorder
      label: i18n("Border")
      color: section.page.cfg_iconColorBorder
      onAccepted: (color) => section.page.cfg_iconColorBorder = color
    }
  }
  QC.CheckBox {
    visible: section.customColors
    enabled: section.page.cfg_markOccupied
    text: i18n("Open windows use the highlight colour")
    checked: section.page.cfg_iconOccupiedMatchHighlight
    onToggled: section.page.cfg_iconOccupiedMatchHighlight = checked
  }
}
