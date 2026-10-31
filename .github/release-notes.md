### PiliBabel v3.4.6

**The offline-cache screen is now four sibling tabs; translation gains a "parallel variants share one style" rule; the APK slimming takes effect.**

**Cache screen restructured.** "Mine → Offline cache" used to offer three entries — Cached videos / Cached audio / Download status — and the last one required another tap into a second-level page that held Download video / Download audio. All four are now **sibling tabs on one level**: **Cached videos / Cached audio / Download video / Download audio**. No more nested navigation. (The old "Download status" page is kept for existing entry points, but the main screen no longer requires it.)

**New translation rule: parallel variants must share one style.** The model previously rendered structurally parallel items in inconsistent styles — e.g. in Japanese it turned the "cache video" label into a verb phrase while rendering "cache audio" as a noun compound, so the two did not read as a set. The prompt now requires that structurally parallel items use **the same word-formation pattern** — same word order and same grammatical form, differing only in the object noun. If the source is "noun + noun", the translation is a noun compound; if it is "verb + object", the translation is verb + object. This applies to **every target language**, not just Japanese. Because the cache holds the old, inconsistent translations, `promptRevision` is bumped to 8 so those entries are re-translated once.

**APK slimming.** The release build now passes `--target-platform android-arm,android-arm64` (alongside `abiFilters`), dropping the x86/x86_64 FFmpeg native libraries. This release exists to verify the actual size reduction.

Downloads are below.