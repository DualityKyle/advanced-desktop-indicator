/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import org.kde.kirigami as Kirigami

// Shared timing so every animation has the same feel
NumberAnimation {
  duration: Kirigami.Units.longDuration
  easing.type: Easing.OutCubic
}
