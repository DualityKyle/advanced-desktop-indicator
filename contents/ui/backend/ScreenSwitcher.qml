/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import org.kde.plasma.workspace.dbus as DBus

// Switches any screen's desktop through a small
// KWin script when using allScreens
QtObject {
  id: switcher

  // Don't load the script unless it's needed
  property bool enabled: false

  readonly property string scriptName: "advanced-desktop-indicator-screenswitch"
  // Kwin wants a plaintext file path without escapes
  readonly property string scriptPath: decodeURIComponent(
    Qt.resolvedUrl("../scripts/screenswitch.js").toString().replace(/^file:\/\//, ""))

  function callDBus(message, onReply) {
    DBus.SessionBus.asyncCall(message, (reply) => onReply?.(reply.value), (error) => {
      console.warn("Advanced Desktop Indicator:", message.member, "failed:", error.message);
    });
  }

  function callScripting(member, args, onReply) {
    callDBus({
      service: "org.kde.KWin",
      path: "/Scripting",
      iface: "org.kde.kwin.Scripting",
      member: member,
      arguments: args
    }, onReply);
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

  // Reload on start so widget updates bring in the new script
  function loadScript() {
    callScripting("unloadScript", [scriptName], () => {
      callScripting("loadScript", [scriptPath, scriptName], (scriptId) => {
        // -1 means another instance of the Plasmoid loaded it, so there's nothing to run
        if (Number(scriptId) < 0)
          return;
        callDBus({
          service: "org.kde.KWin",
          path: "/Scripting/Script" + Number(scriptId),
          iface: "org.kde.kwin.Script",
          member: "run",
          arguments: []
        });
      });
    });
  }

  // Prefix our shortcut names to prevent collisions with KWin's own
  function switchScreen(screenIndex, desktopIndex) {
    invokeShortcut("ADI Pick Screen " + (screenIndex + 1));
    invokeShortcut("ADI Switch To Desktop " + (desktopIndex + 1));
  }

  Component.onCompleted: {
    if (enabled)
      loadScript();
  }
  onEnabledChanged: {
    if (enabled)
      loadScript();
  }
}
