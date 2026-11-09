/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QC
import org.kde.kirigami as Kirigami

// Slider without stepSize and tickmarks, but still
// behaves like a stepped slider
RowLayout {
  id: field

  property alias from: slider.from
  property alias to: slider.to
  property real step: 1
  property real value
  property real widestValue: to
  property var formatValue: (value) => value

  signal moved(real value)

  QC.Slider {
    id: slider
    Layout.preferredWidth: Kirigami.Units.gridUnit * 8
    value: field.value
    onMoved: field.moved(Number((Math.round(value / field.step) * field.step).toFixed(2)))
  }
  QC.Label {
    id: valueLabel
    Layout.minimumWidth: valueMetrics.width
    horizontalAlignment: Text.AlignLeft
    text: field.formatValue(field.value)

    TextMetrics {
      id: valueMetrics
      font: valueLabel.font
      text: field.formatValue(field.widestValue)
    }
  }
}
