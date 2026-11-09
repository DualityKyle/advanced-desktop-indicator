/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.taskmanager as TaskManager
import "backend"
import "layout"

PlasmoidItem {
  id: root

  readonly property var cfg: Plasmoid.configuration

  preferredRepresentation: fullRepresentation

  Plasmoid.status: cfg.hideOnSingleDesktop && desktopInfo.numberOfDesktops <= 1
    ? PlasmaCore.Types.HiddenStatus
    : PlasmaCore.Types.ActiveStatus

  TaskManager.VirtualDesktopInfo { id: desktopInfo }
  WindowTracker { id: windowTracker }

  // We only need to load the KWin script when we're in allScreens mode
  ScreenSwitcher {
    id: screenSwitcher

    enabled: root.cfg.screenMode === "allScreens"
  }

  DesktopActions {
    id: desktopActions

    info: desktopInfo
    screenSwitcher: screenSwitcher
    navigationWrap: root.cfg.navigationWrap
    scrollInverted: root.cfg.scrollInverted
  }

  fullRepresentation: ScreenGroups {
    info: desktopInfo
    actions: desktopActions
    occupiedDesktops: windowTracker.occupiedDesktops
    occupiedByScreen: windowTracker.occupiedByScreen
  }

  Plasmoid.contextualActions: [
    PlasmaCore.Action {
      text: i18n("Add Virtual Desktop")
      icon.name: "list-add"
      onTriggered: desktopActions.addDesktop()
    },
    PlasmaCore.Action {
      text: i18n("Remove Virtual Desktop")
      icon.name: "list-remove"
      enabled: desktopInfo.numberOfDesktops > 1
      onTriggered: desktopActions.removeLastDesktop()
    },
    PlasmaCore.Action {
      text: i18n("Configure Virtual Desktops")
      icon.name: "configure"
      onTriggered: desktopActions.configureDesktops()
    }
  ]
}
