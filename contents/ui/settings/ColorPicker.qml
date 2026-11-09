/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QC
import org.kde.kquickcontrols as KQuickControls
import org.kde.kirigami as Kirigami

// Label above a colour button, hex code below
ColumnLayout {
  id: picker

  property alias label: labelText.text
  property alias color: button.color

  signal accepted(color color)

  spacing: Kirigami.Units.smallSpacing
  Layout.minimumWidth: Kirigami.Units.gridUnit * 5

  QC.Label {
    id: labelText
    Layout.alignment: Qt.AlignHCenter
  }
  KQuickControls.ColorButton {
    id: button
    Layout.alignment: Qt.AlignHCenter
    showAlphaChannel: false
    onAccepted: (color) => picker.accepted(color)
  }
  QC.Label {
    Layout.alignment: Qt.AlignHCenter
    text: button.color.toString()
    font: Kirigami.Theme.smallFont
    opacity: 0.7
  }
}
