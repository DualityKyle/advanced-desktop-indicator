/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Controls as QC

// One tab per screen, for editing per-screen settings in the all-screens view
QC.TabBar {
  Repeater {
    model: Qt.application.screens.length

    QC.TabButton {
      required property int index
      text: i18n("Screen %1", index + 1)
      width: implicitWidth
    }
  }
}
