/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

// KWin script for allScreens mode. Plasmoids can't pass arguments,
// so it triggers two keyless KWin shortcuts by name: one picks a
// screen, the other switches that screen's desktop

let pickedScreen = 0;

// Left to right, then top to bottom, matching the Plasmoid's screen order
function sortedScreens() {
  return workspace.screens.slice().sort((a, b) =>
    a.geometry.x - b.geometry.x || a.geometry.y - b.geometry.y);
}

for (let i = 0; i < 8; ++i) {
  registerShortcut(
    "ADI Pick Screen " + (i + 1),
    "Advanced Desktop Indicator: pick screen " + (i + 1),
    "",
    () => { pickedScreen = i; }
  );
}

for (let i = 0; i < 20; ++i) {
  registerShortcut(
    "ADI Switch To Desktop " + (i + 1),
    "Advanced Desktop Indicator: switch picked screen to desktop " + (i + 1),
    "",
    () => {
      const screen = sortedScreens()[pickedScreen];
      const desktop = workspace.desktops[i];
      if (screen && desktop)
        workspace.setCurrentDesktopForScreen(desktop, screen);
    }
  );
}
