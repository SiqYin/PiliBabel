### PiliBabel v3.8.1

**Wrap-up of the 3.7-era translation work, plus a flip transition for interface mirroring and a language-search fix.**

This release note covers everything from the 3.7 series through 3.8.1.

**Subtitles** — hardened end to end: identity keys unified between background jobs and the player, batch jobs always finish, double-taps can no longer turn success into failure, script-exact translated tracks, out-of-order cues sorted, and every feedback string translated.

**Danmaku** — whole segments batch pre-translated so bullet comments arrive already translated; pre-translation runs on the same concurrent worker pool as subtitles; danmaku that went out untranslated now flip to their translation in place when the translation lands; all three cover buttons gained cancel (while loading) and undo (when finished), wiping their caches.

**Cover vision** — real download progress on the ring, requests serialized in click order with automatic retries on gateway timeouts, and friendly error messages instead of raw exception dumps.

**RTL interface mirroring** — Arabic, Hebrew, Uyghur and other RTL-script languages mirror navigation, lists, alignment and paddings; images and video never flip and the player timeline stays left-to-right; switching to or from mirrored languages now plays a smooth flip transition.

**Language search fixed.** The language picker searched only the autonym as typed — keyboard variants of Arabic-script letters (ي/ی/ى, ك/ک, ه/ة/ە) made exact matches fail. Search now folds those letter variants and every language also has an English search alias: typing "Uyghur", "Arabic" or "Hebrew" finds them.

**Layout & icons** — cover buttons became a horizontal row, the first-launch intro describes them left/middle/right, the tablet landscape drawer resizes reactively with translations, and the feed's submission badges now use the current black-blue gradient icon.

Downloads are below.
