/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QC
import org.kde.kirigami as Kirigami

// Label above a one-character text field
ColumnLayout {
  id: charBox

  property alias label: labelText.text
  property alias value: field.text
  property alias placeholder: field.placeholderText

  signal edited(string text)

  spacing: Kirigami.Units.smallSpacing
  Layout.minimumWidth: Kirigami.Units.gridUnit * 5

  QC.Label {
    id: labelText
    Layout.alignment: Qt.AlignHCenter
  }
  QC.TextField {
    id: field
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredWidth: Kirigami.Units.gridUnit * 3
    maximumLength: 1
    horizontalAlignment: TextInput.AlignHCenter
    onTextEdited: charBox.edited(text)
  }
}
