### PiliBabel v3.8.3

**Icon fix: the dynamics "all uploaders" avatar and the save panel's brand mark render the real logo again.**

The 3.8.0 icon refresh swapped the old mostly-transparent outline castle for the current full-bleed gradient logo but kept the monochrome tint the outline artwork required — tinting a full-bleed image paints every non-transparent pixel one color, so the dynamics "all uploaders" avatar turned into a blank white disc and the save panel's logo into a solid grey blob. The tint is removed in both places; they now show the actual full-color logo, exactly like the about page always did.

### PiliBabel v3.8.2

**Hotfix on top of 3.8.1: switching mirrored layouts no longer blanks the screen, and the language search gets a second round of polish.**

**Mirror-switch black screen fixed.** The flip transition introduced in 3.8.1 mounted the app twice during the animation — two live copies of the same navigator under one GlobalKey — which black-screened the app when switching into or out of mirrored languages, in both directions. The flip is now a single-tree two-phase animation: the current view rotates edge-on, the direction swaps in place at that instant, and the view unfolds again under the new direction. The navigator is never duplicated and no page state is lost.

**Language search, round two.** Pasted autonyms often carry invisible bidirectional control characters (RLM, isolates, zero-width spaces) that made matches fail even when the text looked right — they are stripped before comparison now. The search field also adapts its text direction to the typed content, so an RTL autonym aligns right even while the interface is still LTR; results update in realtime as you type, with no Enter needed; and the first-strong-direction detection no longer treats neutral characters (spaces, punctuation) as left-to-right.

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
