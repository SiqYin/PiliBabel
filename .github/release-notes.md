### PiliBabel v3.8.7

**The AI translation language list gains Tâi-gí — Taiwanese Hokkien written purely in POJ.**

Tâi-gí is the same language as the existing Taiwanese Hokkien entry, but in a different writing system: it uses only Pe̍h-ōe-jī (POJ) romanisation — Latin letters, tone marks, hyphens and punctuation — and **not a single Han character**. The prompt says that outright: no Han-and-roman mixing, no Han supplied in brackets, and proper nouns are respelled from their Hokkien reading rather than left in Chinese.

Because a stray Han character means the text was simply not translated, this target is deliberately **not** treated as a Chinese-family language: Han characters in a subtitle translation are rejected and the chunk retried — the exact opposite of the Han-script Taiwanese entry, whose output is allowed to contain them.

It sits with the other languages outside bilibili's official inventory, is marked as such, and can be found by searching `tâi-gí`, `tai-gi`, `taigi`, `Taiwanese`, `POJ`, `白话字` or `閩南語`.

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
