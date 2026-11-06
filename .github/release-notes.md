### PiliBabel v3.7.2

**Subtitle translation could never succeed. This release fixes the whole failure chain, and makes progress and outcome visible.**

**Why every chunk failed.** The result validator rejected any output line that was identical to its source line. But simplified → traditional Chinese, Chinese → Japanese kanji words, names and numbers legitimately translate to the same string, so virtually every chunk threw and the track never finished. The per-line identity check is gone; only empty output is rejected. "The model just copied everything" is now judged per chunk (at least two lines with Han characters, 80% or more copied), and Chinese-family targets — Simplified, Traditional, Cantonese, Wu and Minnan — are exempt entirely.

**The batch fast path no longer kills a whole block.** An HTTP error, a proxy hiccup or a broken stream on the JSON-array request used to abort the block. It now falls back to the per-line template. Per-line output that gets stripped down to nothing no longer quietly returns the original text: it reports the failure instead.

**A single bad cue no longer invalidates the entire track.** Zero-length and reversed timestamps are dropped while parsing, so one corrupt cue cannot trip the track-wide timeline check and make the app say "no usable subtitles".

**No more endless spinner after the red ring.** When no chunk could be produced, the coordinator kept retrying forever and never completed, leaving the UI spinning with neither an error nor a result. It now gives up after three consecutive rounds with no newly validated chunk. Startup failures also carry the real exception type (401, timeout, validation rejection) instead of one generic message.

**You can now tell when it is done.** A single video shows a toast when pre-translation completes or fails; a whole collection reports once at the end ("all N parts pre-translated") instead of once per part.

**Signed-out error pages are translated.** "Account not signed in" and "Tap to retry" came straight from the Bilibili API as Chinese and were shown verbatim; they now go through the interface translator.

Downloads are below.
