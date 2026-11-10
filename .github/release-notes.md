### PiliBabel v3.8.6

**The HiRes badge in the player bar finally shows up — and now works like the official app.**

**It was never actually visible.** The badge was added back in 3.7.0 complete with its own control type, but it read the current audio quality from a *plain field* inside an `Obx`. GetX throws outright — "improper use of a GetX has been detected" — when an `Obx` body registers no observable at all, so that widget blew up the moment it was built. The badge has therefore never rendered once since 3.7.0; it was not removed later.

**Now reactive.** The current audio quality is a proper `Rxn<AudioQuality>`, so the badge tracks track changes.

**Rebuilt to spec:**

- Sits to the **left of the segment info** in the player bar.
- Shows just **HiRes** — the official app's "无损" (lossless) suffix is dropped, and as a proper noun the label itself is not translated.
- **Hidden entirely** when the video has no HiRes audio track.
- **Lit** (theme-coloured outline and tint) while the playing track is HiRes; **dim** otherwise.
- **Tap to toggle.** Lit → dim shows "HiRes 音质已关闭" and drops to the highest non-HiRes quality available; dim → lit shows "HiRes 音质已开启" and switches back to HiRes.

**Dropping a step picks the best non-HiRes track the video actually has**, rather than stepping down by quality rank — a video may have no Dolby track at all, and stepping to a non-existent tier would silently fall back to an unrelated one. Only when HiRes is the sole track does it fall back to the rank ordering.

**Neither toast changes your default quality setting** — this is a one-off switch for the current video, so turning HiRes off once does not permanently downgrade you (and turning it on does not make HiRes your default).

Both toast strings are routed through AI translation and pre-warmed as soon as a video page opens, so they arrive already translated.

**Robustness:** the quality enum's strict `fromCode` uses a non-null assertion, so a new quality code from Bilibili would crash the player bar. A lenient `maybeFromCode` now guards every path that walks the track list.

### PiliBabel v3.8.5

**Subtitle translation now starts loading from the timestamp you actually begin playing at.**

When you open a video at 30:00, the translation queue used to start from 00:00 and grind through half an hour of dialogue before it reached the part you were watching — so resuming a long video meant a long wait with playback held back the whole time. Starting from the beginning was fast; starting from anywhere else was not.

**Why it happened.** Opening a video kicks off a background subtitle pre-translation from the video page's `onInit`, before the player has resolved a stream — so that job is created with position 0. When the player later attaches to the translator it uses the *same* cache identity key, and the coordinator simply reuses the existing session instead of building a new job, so the real start position the player passed in was silently dropped. The position listener was also registered without `fireImmediately`, and while playback is paused waiting for subtitles the position never changes — so there was no second chance to correct it. Both together pinned the queue to position 0.

**The fix.** A session can now be told where playback actually starts (`primePosition`), pushed in by the player right after it attaches, and the background job accepts the resume point up front (read from the launch timestamp or the saved position). Either path is enough, so both entrances are covered.

**What it looks like now.** With 20-sentence chunks and playback at 1500s, the queue runs: the overlap-context chunk (74) → the chunk you are watching (75) → 76 → 77 → 78 … → and only then the history at 0, 1, … Opening from 0:00 is unchanged — same order, same speed as before.

**Unchanged:** the pause on open while the first subtitles arrive, and the auto-pause when the realtime buffer falls behind. Only the loading order changed.

### PiliBabel v3.8.4

**Merge of hardening contributed by saukhoai (PRs #3 and #4), adapted to the current codebase.**

**Proxy routes can no longer jam.** Waiting for a translation proxy route now times out after 60 seconds; a timed-out request removes itself from the waiting queue, so an abandoned waiter can no longer steal a slot that was just released. The timeout is part of the shared pool identity, covered by a regression test.

**Realtime pause is now a setting.** A new switch — "auto-pause when realtime subtitles fall behind" (on by default, matching the previous behavior) — decides whether playback may pause while the translated track buffers ahead; turn it off and the video keeps playing, with gaps simply showing original subtitles. The blocking rules moved into one policy function, and playback always resumes when a subtitle translation job gives up instead of staying paused on a dead session.

**More Vietnamese labels.** Eleven fixed UI labels around subtitle context, waiting/prefetch settings and retry states now carry offline Vietnamese translations (contributed by saukhoai).

Not merged (already superseded by the 3.7.3+ subtitle rework in this codebase): his subtitle track-label decoupling and retry-ownership bounds — labels are already resolved without the GetX service and stuck sessions are already capped and surfaced as a retryable failure.

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
