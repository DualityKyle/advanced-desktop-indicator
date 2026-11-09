/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QC
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3
import "../scripts/screenlists.js" as ScreenLists

Kirigami.FormLayout {
  id: section

  required property var page

  readonly property bool listStyle: page.cfg_labelStyle === "list"
  readonly property bool templateStyle: page.cfg_labelStyle === "template"
  readonly property bool nameStyle: page.cfg_labelStyle === "name"
  readonly property bool boxesHighlight: page.cfg_labelHighlight === "boxes"
  readonly property bool customColors: page.cfg_labelColorMode === "custom"
  // All-screens view: each screen can have its own template or list
  readonly property bool perScreen: (listStyle || templateStyle) && page.allScreens
  readonly property int editScreen: perScreen ? screenTabs.currentIndex : 0

  function templateText() {
    return editScreen > 0
      ? ScreenLists.listFor(page.cfg_labelTemplatePerScreen, editScreen)[0] ?? ""
      : page.cfg_labelTemplate;
  }

  function setTemplate(text) {
    if (editScreen > 0)
      page.cfg_labelTemplatePerScreen = ScreenLists.withEntry(page.cfg_labelTemplatePerScreen, editScreen, 0, text);
    else
      page.cfg_labelTemplate = text;
  }

  function listEntry(index) {
    return editScreen > 0
      ? ScreenLists.listFor(page.cfg_labelListPerScreen, editScreen)[index] ?? ""
      : page.cfg_labelList[index] ?? "";
  }

  // Assign a new array so the page notices the change
  function setListEntry(index, text) {
    if (editScreen > 0) {
      page.cfg_labelListPerScreen = ScreenLists.withEntry(page.cfg_labelListPerScreen, editScreen, index, text);
      return;
    }
    const list = page.cfg_labelList.slice();
    while (list.length <= index)
      list.push("");
    list[index] = text;
    page.cfg_labelList = list;
  }

  function setDesktopName(index, text) {
    const name = text.trim() || i18n("Desktop %1", index + 1);
    if (name !== page.desktopInfo.desktopNames[index])
      page.pendingDesktopNames[index] = name;
    else
      delete page.pendingDesktopNames[index];
    page.configurationChanged();
  }

  component FormatButton: QC.ToolButton {
    display: QC.AbstractButton.IconOnly
    checkable: true
    QC.ToolTip.text: text
    QC.ToolTip.visible: hovered
    QC.ToolTip.delay: Kirigami.Units.toolTipDelay
  }

  QC.ComboBox {
    Kirigami.FormData.label: i18n("Style:")
    textRole: "text"
    valueRole: "value"
    model: [
      { text: i18n("Desktop number"), value: "number" },
      { text: i18n("Desktop name"), value: "name" },
      { text: i18n("Template"), value: "template" },
      { text: i18n("Custom list"), value: "list" }
    ]
    Component.onCompleted: currentIndex = indexOfValue(section.page.cfg_labelStyle)
    onActivated: section.page.cfg_labelStyle = currentValue
  }
  RowLayout {
    visible: section.perScreen && Qt.application.screens.length > 1

    ScreenTabs {
      id: screenTabs
    }
    Kirigami.ContextualHelpButton {
      toolTipText: i18n("Screens are numbered left to right, so if you rearrange your screens in Display settings, the labels follow the screen's position, not the physical monitor. Empty entries on other screens use screen 1's.")
    }
  }
  QC.TextField {
    Kirigami.FormData.label: i18n("Template:")
    visible: section.templateStyle
    // Later screens fall back to screen 1's template
    placeholderText: section.editScreen > 0 ? section.page.cfg_labelTemplate || "%n" : "%n"
    text: section.templateText()
    onTextEdited: section.setTemplate(text)
  }
  QC.Label {
    Kirigami.FormData.label: i18n("Placeholders:")
    Kirigami.FormData.labelAlignment: Qt.AlignTop
    visible: section.templateStyle
    text: i18n("<b>%1</b>: desktop number<br><b>%2</b>: desktop name", "%n", "%d")
  }
  QC.Label {
    visible: section.nameStyle
    Layout.maximumWidth: Kirigami.Units.gridUnit * 16
    wrapMode: Text.Wrap
    opacity: 0.7
    text: i18n("Changing a name here renames the virtual desktop.")
  }
  Repeater {
    model: section.page.desktopInfo.numberOfDesktops

    QC.TextField {
      required property int index

      Kirigami.FormData.label: i18n("%1:", section.page.desktopInfo.desktopNames[index])
      visible: section.listStyle
      // Later screens fall back to screen 1's entry
      placeholderText: section.editScreen > 0
        ? section.page.cfg_labelList[index] || index + 1
        : index + 1
      text: section.listEntry(index)
      onTextEdited: section.setListEntry(index, text)
    }
  }
  Repeater {
    model: section.page.desktopInfo.numberOfDesktops

    QC.TextField {
      required property int index

      Kirigami.FormData.label: i18n("Desktop %1:", index + 1)
      visible: section.nameStyle
      text: section.page.desktopInfo.desktopNames[index] ?? ""
      placeholderText: i18n("Desktop %1", index + 1)
      onTextEdited: section.setDesktopName(index, text)
    }
  }

  Kirigami.Separator {
    Kirigami.FormData.isSection: true
    Kirigami.FormData.label: i18n("Text Options")
  }
  RowLayout {
    Kirigami.FormData.label: i18n("Size mode:")

    QC.RadioButton {
      text: i18n("Scale with panel")
      checked: section.page.cfg_labelScaleWithPanel
      onToggled: section.page.cfg_labelScaleWithPanel = checked
    }
    QC.RadioButton {
      text: i18n("Fixed")
      checked: !section.page.cfg_labelScaleWithPanel
      onToggled: section.page.cfg_labelScaleWithPanel = !checked
    }
  }
  RowLayout {
    spacing: 0
    Kirigami.FormData.label: i18n("Size:")
    visible: section.page.cfg_labelScaleWithPanel

    FluidSlider {
      from: 0.1
      to: 1
      step: 0.01
      value: section.page.cfg_labelPanelScale
      formatValue: (value) => i18n("%1%", Math.round(value * 100))
      onMoved: (value) => section.page.cfg_labelPanelScale = value
    }
    Kirigami.ContextualHelpButton {
      toolTipText: i18n("Percentage of the panel's thickness.")
    }
  }
  PC3.SpinBox {
    Kirigami.FormData.label: i18n("Size:")
    visible: !section.page.cfg_labelScaleWithPanel
    from: 8
    to: 72
    value: section.page.cfg_labelFixedSize
    onValueModified: section.page.cfg_labelFixedSize = value
  }
  RowLayout {
    Kirigami.FormData.label: i18n("Active:")

    FormatButton {
      icon.name: "format-text-bold"
      text: i18n("Bold")
      checked: section.page.cfg_labelBoldActive
      onToggled: section.page.cfg_labelBoldActive = checked
    }
    FormatButton {
      icon.name: "format-text-italic"
      text: i18n("Italic")
      checked: section.page.cfg_labelItalicActive
      onToggled: section.page.cfg_labelItalicActive = checked
    }
  }
  RowLayout {
    Kirigami.FormData.label: i18n("Inactive:")

    FormatButton {
      icon.name: "format-text-bold"
      text: i18n("Bold")
      checked: section.page.cfg_labelBoldInactive
      onToggled: section.page.cfg_labelBoldInactive = checked
    }
    FormatButton {
      icon.name: "format-text-italic"
      text: i18n("Italic")
      checked: section.page.cfg_labelItalicInactive
      onToggled: section.page.cfg_labelItalicInactive = checked
    }
  }
  QC.CheckBox {
    text: i18n("Add * to the active label")
    checked: section.page.cfg_labelActiveAsterisk
    onToggled: section.page.cfg_labelActiveAsterisk = checked
  }
  FluidSlider {
    Kirigami.FormData.label: i18n("Inactive opacity:")
    from: 10
    to: 100
    step: 5
    value: section.page.cfg_labelOpacityInactive
    formatValue: (value) => i18n("%1%", value)
    onMoved: (value) => section.page.cfg_labelOpacityInactive = value
  }

  Kirigami.Separator {
    Kirigami.FormData.isSection: true
    Kirigami.FormData.label: i18n("Width")
  }
  RowLayout {
    Kirigami.FormData.label: i18n("Width mode:")

    QC.RadioButton {
      text: i18n("Fit to text")
      checked: section.page.cfg_labelAutoWidth
      onToggled: section.page.cfg_labelAutoWidth = checked
    }
    QC.RadioButton {
      text: i18n("Fixed")
      checked: !section.page.cfg_labelAutoWidth
      onToggled: section.page.cfg_labelAutoWidth = !checked
    }
  }
  Item {
    implicitHeight: Kirigami.Units.smallSpacing
  }
  FluidSlider {
    Kirigami.FormData.label: i18n("Padding:")
    visible: section.page.cfg_labelAutoWidth
    from: 0
    to: 20
    value: section.page.cfg_labelPadding
    formatValue: (value) => i18n("%1px", value)
    onMoved: (value) => section.page.cfg_labelPadding = value
  }
  FluidSlider {
    Kirigami.FormData.label: i18n("Width:")
    visible: !section.page.cfg_labelAutoWidth
    from: 20
    to: 160
    step: 5
    value: section.page.cfg_labelFixedWidth
    formatValue: (value) => i18n("%1px", value)
    onMoved: (value) => section.page.cfg_labelFixedWidth = value
  }
  QC.CheckBox {
    visible: !section.page.cfg_labelAutoWidth
    text: i18n("Wrap long labels onto multiple lines")
    checked: section.page.cfg_labelWrap
    onToggled: section.page.cfg_labelWrap = checked
  }
  Item {
    implicitHeight: Kirigami.Units.smallSpacing
  }
  RowLayout {
    Kirigami.FormData.label: i18n("Minimum width:")

    QC.CheckBox {
      text: i18n("Same as panel height")
      checked: section.page.cfg_labelMinWidthPanelHeight
      onToggled: section.page.cfg_labelMinWidthPanelHeight = checked
    }
    Kirigami.ContextualHelpButton {
      toolTipText: i18n("On vertical panels, this is the panel's width.")
    }
  }
  FluidSlider {
    Kirigami.FormData.label: i18n("Spacing:")
    from: 0
    to: 40
    value: section.page.cfg_labelSpacing
    formatValue: (value) => i18n("%1px", value)
    onMoved: (value) => section.page.cfg_labelSpacing = value
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
    Component.onCompleted: currentIndex = indexOfValue(section.page.cfg_labelHighlight)
    onActivated: section.page.cfg_labelHighlight = currentValue
  }
  QC.CheckBox {
    visible: section.boxesHighlight
    text: i18n("Show border")
    checked: section.page.cfg_labelBoxBorder
    onToggled: section.page.cfg_labelBoxBorder = checked
  }
  FluidSlider {
    Kirigami.FormData.label: i18n("Border thickness:")
    visible: section.boxesHighlight && section.page.cfg_labelBoxBorder
    from: 1
    to: 5
    value: section.page.cfg_labelBoxBorderWidth
    formatValue: (value) => i18n("%1px", value)
    onMoved: (value) => section.page.cfg_labelBoxBorderWidth = value
  }
  RowLayout {
    spacing: 0
    Kirigami.FormData.label: i18n("Box padding:")
    visible: section.boxesHighlight

    FluidSlider {
      from: 0
      to: 20
      value: section.page.cfg_labelBoxPadding
      formatValue: (value) => i18n("%1px", value)
      onMoved: (value) => section.page.cfg_labelBoxPadding = value
    }
    Kirigami.ContextualHelpButton {
      toolTipText: i18n("Padding between the top and bottom of the label and the box border.")
    }
  }
  FluidSlider {
    Kirigami.FormData.label: i18n("Corner radius:")
    visible: section.boxesHighlight
    from: 0
    to: 50
    step: 5
    value: section.page.cfg_labelBoxRadius
    formatValue: (value) => i18n("%1%", value)
    onMoved: (value) => section.page.cfg_labelBoxRadius = value
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
    Component.onCompleted: currentIndex = indexOfValue(section.page.cfg_labelColorMode)
    onActivated: section.page.cfg_labelColorMode = currentValue
  }
  QC.CheckBox {
    text: i18n("Mark desktops with open windows")
    checked: section.page.cfg_markOccupied
    onToggled: section.page.cfg_markOccupied = checked
  }
  RowLayout {
    Kirigami.FormData.label: i18n("Text:")
    visible: section.customColors

    ColorPicker {
      label: i18n("Active")
      color: section.page.cfg_labelColorActive
      onAccepted: (color) => section.page.cfg_labelColorActive = color
    }
    ColorPicker {
      label: i18n("Inactive")
      color: section.page.cfg_labelColorInactive
      onAccepted: (color) => section.page.cfg_labelColorInactive = color
    }
  }
  RowLayout {
    Kirigami.FormData.label: i18n("Highlight:")
    visible: section.customColors

    ColorPicker {
      label: i18n("Active")
      color: section.page.cfg_labelColorHighlight
      onAccepted: (color) => section.page.cfg_labelColorHighlight = color
    }
    ColorPicker {
      enabled: section.page.cfg_markOccupied && !section.page.cfg_labelOccupiedMatchHighlight
      label: i18n("Open windows")
      color: section.page.cfg_labelColorOccupied
      onAccepted: (color) => section.page.cfg_labelColorOccupied = color
    }
    ColorPicker {
      visible: section.boxesHighlight && section.page.cfg_labelBoxBorder
      label: i18n("Border")
      color: section.page.cfg_labelColorBorder
      onAccepted: (color) => section.page.cfg_labelColorBorder = color
    }
  }
  QC.CheckBox {
    visible: section.customColors
    enabled: section.page.cfg_markOccupied
    text: i18n("Open windows use the highlight colour")
    checked: section.page.cfg_labelOccupiedMatchHighlight
    onToggled: section.page.cfg_labelOccupiedMatchHighlight = checked
  }
}
