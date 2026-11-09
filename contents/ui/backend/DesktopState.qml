/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick

// These properties give indicators everything they need to know
// about their desktop. Each desktop gets their own copy
QtObject {
  property int index: 0
  property int screenIndex: -1
  property string name: ""
  property bool isCurrent: false
  property bool isHovered: false
  property bool isOccupied: false

  property bool vertical: false
  property real panelThickness: 0
  property real textRotation: 0

  readonly property bool isSideways: Math.abs(textRotation) % 180 === 90
}
