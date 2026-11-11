### PiliBabel v3.8.12

**The first batch of upstream features lands, and the app goes back to the system font by default.**

**Search understands `#tag`.** A keyword that starts with `#` now matches against a video's tags instead of its title, case-insensitively and as a literal substring, so `#原神` finds videos tagged 原神 while a plain keyword keeps matching titles as before. Inclusion is still OR (title hit or tag hit), exclusion still wins over inclusion, and the two can be mixed in one query. The tag field is read straight from the search response, so nothing extra is requested.

**The sidebar can hide its labels.** A new switch under 外观 keeps only the icons: the desktop rail narrows to 56dp and the tablet drawer to 80dp, with the selection pill shrinking to match. It takes effect without a restart.

**Scroll wheel adjusts volume — and can be turned off.** The player already mapped wheel scrolling to volume; that behaviour now has its own switch (滚轮调节音量, on by default) next to the slide-brightness one, for people who scroll the page behind the player.

**The intro panel shows the av number.** Alongside the bvid it now prints `av…`, and tapping it copies that form — handy when a tool or a person asks for the aid rather than the bvid.

**Jumpscare segments are recognised.** SponsorBlock's `jumpscare` category is now a first-class segment type: red marker, auto-mute while it plays, listed with the other categories in the segment settings.

**System font is the default again.** 1.1.0 switched the default to the bundled LXGW WenKai; 3.8.12 puts the platform default back, matching the official app. 霞鹜文楷 is still there as an option and is still bundled — anyone who picked it explicitly keeps it, and it can be chosen at any time in 字体设置.

This release also carries the upstream fixes that came with the same batch: player seek handling, local subtitle read/update, audio session configuration, and several desktop window-sizing corrections.
