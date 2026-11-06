### PiliBabel v3.7.1

**A smaller subtitle button, an explanation the first time you open the app, and auto pre-translation when you tap a video.**

**Subtitle button, now icon-only.** The "translate subtitles" action on a cover used to be an icon-plus-label pill, twice the width of the cover-translate button next to it. It is now a single icon with exactly the same metrics as the cover button (28×28 hit area, 13px glyph, black54, radius 4) and sits directly above it. Progress shows as a ring, completion as a check, failure as a refresh icon; tapping the whole button retranslates.

**Why "translate subtitles" always failed.** Starting a translation re-fetches `/x/player/v2` for the track list, and **that endpoint returns an empty list when you are not signed in — even for videos that really do have CC subtitles**. The old code only checked for `null`, so the empty list fell through to "cannot download a source subtitle" and was reported as a failure. That is why it failed every time and retrying never helped: there was no source to retry. An empty list is now its own state: not a failure, no retry offered, a muted `subtitles_off` icon instead, with separate wording for "not signed in" and "this video has no subtitles".

**Failures no longer hide their cause.** The startup path used to swallow every exception behind one generic message. The message now carries the exception type, so a real fault becomes identifiable at a glance.

**First-run explainer.** The first time you reach the home feed, a dialog explains the two buttons at the bottom-left of a cover: the upper one pre-translates subtitles, the lower one reads the cover and translates the text on it. Dismissed with "Got it".

**"AI translation is on" dialog — English, translated first.** Both onboarding dialogs are written in English and queued at the highest translation priority, so they read in your own language the moment they appear instead of opening in Chinese.

**Tapping a video starts pre-translation.** As soon as the player page knows the bvid/aid/cid, the subtitle track is queued in the background — by the time the first frame is up, the translation is usually ready. Only the current part is queued; whole-collection batches stay on the cover button.

**Not shown when it cannot work.** With Simplified Chinese as the target language, or with AI translation off, the subtitle button is no longer rendered at all.

Downloads are below.
