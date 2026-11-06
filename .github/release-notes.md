### PiliBabel v3.7.3

**A twelve-point audit of the whole subtitle chain, fixing the corner cases that made a finished translation invisible or turned a success into a failure.**

**Anime (pgc) never saw its own finished translation.** The previous release unified the *read* side to `ep<episode>`, but the background job still wrote its cache and artifact under `bvid ?? 'av<aid>'`. Anime has no bvid, so the key collapsed to `avnull`: the job finished, the artifact was written, and the player looked for `ep<episode>` and found nothing — so opening the video translated it all over again. "Delete translation" also computed its cache key from `ep<episode>` and deleted nothing, leaving orphan JSON files behind. The whole chain now shares one identity key (bvid → aid → epId → seasonId), while ordinary videos keep bvid so existing caches and artifacts still match.

**Double-tapping the button could turn a success into a failure.** The start check ran before an `await`, so two taps both saw "not started yet" and attached the same job twice. Both ran the completion step — replace cache, then rename it onto the canonical file — and the second rename found no source file, threw, and overwrote a completed task with `failed`. An entry lock now ignores the duplicate start.

**Switching between Simplified, Traditional, Cantonese and Wu could mount the wrong script.** Downloaded translation tracks were named after the bare language tag (`zh-app-ai`), so all four scripts shared one name. They now carry the full target code (`zh-Hant-app-ai`); old Chinese-family caches are no longer treated as ready-made translations, while other languages keep using their existing cache.

**Out-of-order subtitles lost valid lines.** Timeline cleaning now sorts by start time (stably) before checking overlaps, so one long cue in an external or local VTT can no longer make every following sentence look like "the fourth overlap" and get dropped.

**An empty track is no longer reported as a successful download.** When nothing survives cleaning the converter returns an empty string instead of `"WEBVTT"`, so the player does not mount a subtitle track with no text in it, and "the player says there are subtitles, the background says there are none" cannot happen.

**Japanese and Korean targets were judged as "the model did not translate".** Kanji words are legitimately identical to the Chinese source, so the copied-block check now exempts targets that use Han characters (Chinese family, Japanese, Korean); English, Vietnamese and others are still rejected when copied.

**Multi-part videos no longer overwrite each other's state.** A video with several parts used a one-hop alias map, so the last part registered hid the others and the cover could show "done" while a part was still translating, or the reverse. State is now aggregated one-to-many.

**Subtitle feedback is fully pre-warmed.** The warm list grew from 16 to 60 strings, so the in-progress, verifying and failure messages shown the first time the cover button appears are no longer Chinese-only.

**"No Chinese subtitles" is no longer a dead button.** An empty subtitle list caused by being signed out used to grey the button out with no tap handler; after signing in you can now tap it to re-check.

Downloads are below.
