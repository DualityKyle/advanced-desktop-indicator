/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import org.kde.kcmutils as KCMUtils
import org.kde.plasma.workspace.dbus as DBus

QtObject {
  id: actions

  required property var info
  property var screenSwitcher: null
  property bool navigationWrap: true
  property bool scrollInverted: false

  readonly property int count: info.numberOfDesktops

  property real wheelDelta: 0

  function callDBus(message) {
    DBus.SessionBus.asyncCall(message, () => {}, (error) => {
      console.warn("Advanced Desktop Indicator:", message.member, "failed:", error.message);
    });
  }

  function callDesktopManager(member, args) {
    callDBus({
      service: "org.kde.KWin",
      path: "/VirtualDesktopManager",
      iface: "org.kde.KWin.VirtualDesktopManager",
      member: member,
      arguments: args
    });
  }

  function invokeShortcut(name) {
    callDBus({
      service: "org.kde.kglobalaccel",
      path: "/component/kwin",
      iface: "org.kde.kglobalaccel.Component",
      member: "invokeShortcut",
      arguments: [name]
    });
  }

  function addDesktop() {
    callDesktopManager("createDesktop", [new DBus.uint32(count), i18n("Desktop %1", count + 1)]);
  }

  function removeLastDesktop() {
    if (count <= 1)
      return;
    callDesktopManager("removeDesktop", [info.desktopIds[count - 1]]);
  }

  function renameDesktop(index, name) {
    const desktopId = info.desktopIds[index];
    if (!desktopId || !name)
      return;
    callDesktopManager("setDesktopName", [desktopId, name]);
  }

  function configureDesktops() {
    KCMUtils.KCMLauncher.openSystemSettings("kcm_kwin_virtualdesktops");
  }

  // screenIndex is only set in allScreens mode
  function activateDesktop(index, currentIndex, screenIndex = -1) {
    const desktopId = info.desktopIds[index];
    if (!desktopId || index === currentIndex)
      return;
    // A screen the mouse isn't on can only have its
    // desktop switched through the KWin script
    if (screenIndex >= 0 && screenSwitcher) {
      screenSwitcher.switchScreen(screenIndex, index);
      return;
    }
    callDBus({
      service: "org.kde.KWin",
      path: "/VirtualDesktopManager",
      iface: "org.freedesktop.DBus.Properties",
      member: "Set",
      arguments: ["org.kde.KWin.VirtualDesktopManager", "current", new DBus.variant(desktopId)]
    });
  }

  function navigateDesktop(delta, currentIndex, screenIndex = -1) {
    if (currentIndex < 0)
      return;
    let target = currentIndex + delta;
    // The extra count keeps all results positive when wrapping around
    if (navigationWrap)
      target = ((target % count) + count) % count;
    else
      target = Math.max(0, Math.min(count - 1, target));
    activateDesktop(target, currentIndex, screenIndex);
  }

  // 120 units is one mouse wheel notch, touchpads send many small units
  function wheelAction(delta, currentIndex, screenIndex = -1) {
    wheelDelta += scrollInverted ? -delta : delta;
    const steps = Math.trunc(wheelDelta / 120);
    if (steps === 0)
      return;
    wheelDelta -= steps * 120;
    navigateDesktop(-steps, currentIndex, screenIndex);
  }

  function clickAction(name, index, currentIndex, screenIndex = -1) {
    switch (name) {
      case "next": navigateDesktop(1, currentIndex, screenIndex); break;
      case "prev": navigateDesktop(-1, currentIndex, screenIndex); break;
      case "goto": activateDesktop(index, currentIndex, screenIndex); break;
      case "overview": invokeShortcut("Overview"); break;
      case "desktop": invokeShortcut("Show Desktop"); break;
    }
  }
}
