### PiliBabel v2.4.1

**Fixes**

- Android launcher icon: the adaptive icon was still taking its colours from the system theme on Android 12+ (`system_neutral2_700` foreground, `system_accent1_100` background) and shipped a `<monochrome>` layer, so devices showed a themed grey tower on a light purple tile instead of the new artwork. The adaptive icon is now fixed: a vector diagonal gradient from black (`#000000`) to blue (`#3a6da2`) with a pure white tower, and the Android 12+ colour overrides plus the monochrome layer are gone. Every device now shows the same icon.

Downloads are below.
