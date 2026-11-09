# Advanced Desktop Indicator

A virtual desktop pager for KDE Plasma 6 that's minimal by default and highly customisable.

**Advanced Desktop Indicator** is the successor to Minimal Desktop Indicator, which I started as a recreation of GNOME's Workspace Indicator extension. The project has since outgrown its original intent, so it's being released under a new name.

The clean, minimal look is still the default - plus additional indicator types, along with true multi-monitor support, subtle animations, and TONS of customisation options.

## Features
* **Indicator Types:**
  * **Minimal:** Dots (the default look), GNOME-style pills that stretch for the active desktop, or any characters you like.
  * **Labels:** Desktop numbers or names, a template such as `D%n`, or your own list of labels.
  * **Icons:** Pick any icon from your icon theme for each desktop, with customisable shading options.
* **Highlight Styles:** Tons of highlight styles and customisations to fit any aesthetic.
* **Open Window Markers:** Desktops with open windows are marked, so you can see where your work is at a glance.
* **True Multi-Monitor Support:** You can have a shared widget that handles all desktops as one, or you can indepdently switch desktops on any screen all from one widget. It's been made to fit any workflow.
* **Desktop Switching** Customise how to switch desktops with the widget, whether by clicking the mouse or scrolling.
* **Sizing Control:** Scale with the panel or use a fixed size, fit the width to the content or fix it, and adjust spacing and inactive opacity.
* **Theme Colours:** Follow your Plasma theme's colours, or set your own.
* **Desktop Renaming:** Rename your virtual desktops straight from the widget's settings - no need to manually open up your system settings!
* **Pure QML:** No compiled plugins, nothing to build. Just install the widget and enjoy!

## Requirements
* KDE Plasma >= 6.0
* KDE Frameworks >= 6.0
* Multi-monitor support: Support for independent screen switching requires Wayland

## Installation
### Option 1: KDE Store (Recommended)
Install Advanced Desktop Indicator from the KDE Store using Discover, or the "Get New Widgets…" option in Plasma's "Add Widgets…" panel.

### Option 2: Manual Installation from Source
Clone the repository and install it with `kpackagetool6`:

```bash
# Clone the repository
git clone https://github.com/DualityKyle/advanced-desktop-indicator.git
cd advanced-desktop-indicator

# Install the widget
kpackagetool6 -t Plasma/Applet -i .

# To update an existing installation instead:
kpackagetool6 -t Plasma/Applet -u .
```

*(After installing or updating, you may need to restart Plasma or log out and back in before the widget shows up or updates.)*

## Multiple Screens
To use the per-screen multiple screen capabilities of the widget, ensure that the setting "Switch desktops independently for each screen" is enabled in your virtual desktop settings.

## Contributing
I'm always looking for new ideas to implement, or anything else you think might help improve the widget! If you find a bug or you want to request a new feature, please [submit an issue](https://github.com/DualityKyle/advanced-desktop-indicator/issues)!

## Licence
This project is licensed under the [GPL-3.0-or-later Licence](LICENSE).
