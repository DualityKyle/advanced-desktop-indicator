/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QC
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
  property string cfg_leftClickAction
  property string cfg_middleClickAction
  property string cfg_rightClickAction

  property alias cfg_scrollEnabled: scrollEnabled.checked
  property alias cfg_scrollInverted: scrollInverted.checked
  property alias cfg_scrollHorizontal: scrollHorizontal.checked

  property alias cfg_navigationWrap: navigationWrap.checked
  property alias cfg_hideOnSingleDesktop: hideOnSingleDesktop.checked
  property alias cfg_animationsEnabled: animationsEnabled.checked
  property alias cfg_showTooltip: showTooltip.checked

  component ActionComboBox: QC.ComboBox {
    property string noneText: i18n("Do nothing")

    textRole: "text"
    valueRole: "value"
    model: [
      { text: noneText, value: "none" },
      { text: i18n("Switch to next desktop"), value: "next" },
      { text: i18n("Switch to previous desktop"), value: "prev" },
      { text: i18n("Go to clicked desktop"), value: "goto" },
      { text: i18n("Show overview"), value: "overview" },
      { text: i18n("Peek at desktop"), value: "desktop" }
    ]
  }

  Kirigami.FormLayout {
    Kirigami.Separator {
      Kirigami.FormData.isSection: true
      Kirigami.FormData.label: i18n("Mouse Buttons")
    }
    ActionComboBox {
      Kirigami.FormData.label: i18n("Left click:")
      Component.onCompleted: currentIndex = indexOfValue(cfg_leftClickAction)
      onActivated: cfg_leftClickAction = currentValue
    }
    ActionComboBox {
      Kirigami.FormData.label: i18n("Middle click:")
      Component.onCompleted: currentIndex = indexOfValue(cfg_middleClickAction)
      onActivated: cfg_middleClickAction = currentValue
    }
    ActionComboBox {
      Kirigami.FormData.label: i18n("Right click:")
      noneText: i18n("Show context menu")
      Component.onCompleted: currentIndex = indexOfValue(cfg_rightClickAction)
      onActivated: cfg_rightClickAction = currentValue
    }

    Kirigami.Separator {
      Kirigami.FormData.isSection: true
      Kirigami.FormData.label: i18n("Scrolling")
    }
    QC.CheckBox {
      id: scrollEnabled
      text: i18n("Switch desktops by scrolling")
    }
    QC.CheckBox {
      id: scrollInverted
      enabled: scrollEnabled.checked
      text: i18n("Reverse scroll direction")
    }
    QC.CheckBox {
      id: scrollHorizontal
      enabled: scrollEnabled.checked
      text: i18n("Also switch with horizontal scrolling")
    }

    Kirigami.Separator {
      Kirigami.FormData.isSection: true
      Kirigami.FormData.label: i18n("Behaviour")
    }
    ColumnLayout {
      Kirigami.FormData.label: i18n("Desktop navigation:")
      Kirigami.FormData.buddyFor: navigationWrap

      QC.RadioButton {
        id: navigationWrap
        text: i18n("Wrap around")
      }
      QC.RadioButton {
        text: i18n("Stop at end")
        checked: !navigationWrap.checked
      }
    }
    QC.CheckBox {
      id: showTooltip
      text: i18n("Show desktop name on hover")
    }
    QC.CheckBox {
      id: animationsEnabled
      text: i18n("Enable animations")
    }
    QC.CheckBox {
      id: hideOnSingleDesktop
      text: i18n("Hide widget when there is only one desktop")
    }
  }
}
