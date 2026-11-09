/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QC
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
  property alias cfg_singleRow: singleRow.checked
  property string cfg_indicatorRotation
  property string cfg_screenMode
  property string cfg_screenLayout

  readonly property bool stackedScreens: cfg_screenMode === "allScreens" && cfg_screenLayout === "stacked"
  // Saved on the Appearance page, so this updates after Apply there
  readonly property bool pillStyle: Plasmoid.configuration.indicatorType === "minimal"
    && Plasmoid.configuration.minimalStyle === "pills"
  readonly property bool forcedSingleRow: stackedScreens || pillStyle
  readonly property bool separateScreens: cfg_screenMode !== "shared"
  property string separateMode: "thisScreen"

  Component.onCompleted: {
    if (separateScreens)
      separateMode = cfg_screenMode
  }

  Kirigami.FormLayout {
    Kirigami.Separator {
      Kirigami.FormData.isSection: true
      Kirigami.FormData.label: i18n("Desktops")
    }
    QC.ButtonGroup { id: desktopLayoutGroup }
    ColumnLayout {
      Kirigami.FormData.label: i18n("Desktop layout:")
      Kirigami.FormData.buddyFor: singleRow

      QC.RadioButton {
        id: singleRow
        QC.ButtonGroup.group: desktopLayoutGroup
        enabled: !forcedSingleRow
        text: i18n("Single row")
      }
      RowLayout {
        QC.RadioButton {
          QC.ButtonGroup.group: desktopLayoutGroup
          enabled: !forcedSingleRow
          text: i18n("Follow Plasma setting")
          checked: !singleRow.checked
        }
        Kirigami.ContextualHelpButton {
          visible: forcedSingleRow
          toolTipText: i18n("Pills and One row per screen always show desktops in a single row.")
        }
      }
    }
    RowLayout {
      Kirigami.FormData.label: i18n("Rotation:")

      QC.ComboBox {
        textRole: "text"
        valueRole: "value"
        model: [
          { text: i18n("None"), value: "none" },
          { text: i18n("Follow screen edge"), value: "edge" },
          { text: i18n("90° clockwise"), value: "90" },
          { text: i18n("180°"), value: "180" },
          { text: i18n("270° clockwise"), value: "270" }
        ]
        Component.onCompleted: currentIndex = indexOfValue(cfg_indicatorRotation)
        onActivated: cfg_indicatorRotation = currentValue
      }
      Kirigami.ContextualHelpButton {
        toolTipText: i18n("Follow screen edge turns indicators so the top of the indicator is against the screen edge. Has no effect on dots or pills.")
      }
    }

    Kirigami.Separator {
      Kirigami.FormData.isSection: true
      Kirigami.FormData.label: i18n("Screens")
    }
    RowLayout {
      Kirigami.FormData.label: i18n("Screens switch:")

      QC.RadioButton {
        text: i18n("Together")
        checked: !separateScreens
        onToggled: cfg_screenMode = "shared"
      }
      QC.RadioButton {
        text: i18n("Separately")
        checked: separateScreens
        onToggled: cfg_screenMode = separateMode
      }
      Kirigami.ContextualHelpButton {
        toolTipText: i18n("Match this to System Settings → Virtual Desktops. Choose Separately only if each screen can be on a different desktop.")
      }
    }
    RowLayout {
      Kirigami.FormData.label: i18n("Show:")
      visible: separateScreens

      QC.RadioButton {
        text: i18n("This screen")
        checked: cfg_screenMode === "thisScreen"
        onToggled: {
          separateMode = "thisScreen";
          cfg_screenMode = "thisScreen";
        }
      }
      QC.RadioButton {
        text: i18n("All screens")
        checked: cfg_screenMode === "allScreens"
        onToggled: {
          separateMode = "allScreens";
          cfg_screenMode = "allScreens";
        }
      }
      Kirigami.ContextualHelpButton {
        toolTipText: i18n("<b>This screen:</b> each widget shows only the screen it's on: that screen's current desktop and its open windows. Add the widget to a panel on every screen.<br><br><b>All screens:</b> one widget shows every screen's desktops side by side. Best with the widget on your main screen only.")
      }
    }
    RowLayout {
      Kirigami.FormData.label: i18n("Screen layout:")
      visible: cfg_screenMode === "allScreens"

      QC.ComboBox {
        textRole: "text"
        valueRole: "value"
        model: [
          { text: i18n("All in one row"), value: "row" },
          { text: i18n("One row per screen"), value: "stacked" }
        ]
        Component.onCompleted: currentIndex = indexOfValue(cfg_screenLayout)
        onActivated: cfg_screenLayout = currentValue
      }
      Kirigami.ContextualHelpButton {
        toolTipText: i18n("One row per screen stacks screens across the panel, using as many rows as the panel is thick enough for. Each screen's desktops are then shown in a single row.")
      }
    }
  }
}
