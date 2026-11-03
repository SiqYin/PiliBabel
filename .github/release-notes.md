### PiliBabel v3.6.4

**Urgent fix: with v3.6.3, turning AI translation on could leave pages blank and then crash the app. This release also switches every glossary table to off by default.**

**What went wrong.** v3.6.3 added in-sentence term matching using a loop that replaced a term, rescanned from the start, and repeated while anything still matched. But most glossary forms are *self-containing* — measured 45,601 out of 53,953 have a translation whose lowercase form still contains the source form (the key `genshin impact` translates to `Genshin Impact`, and Japanese names are often identical to the Japanese key). So the same form was found again after replacement, the loop never ended, and each pass allocated another growing string buffer until the process ran out of memory and was killed. That is what you saw: open a page, nothing loads, then it closes itself.

It now uses a **single-pass cursor scan**: on a hit the cursor jumps past the matched source, and text already written never takes part in further matching. Termination is guaranteed by construction rather than depending on the data.

**A second hazard, also fixed.** The glossary index and its buckets were built lazily on first use — which happened during the first frame of a page, synchronously, over 50,000 entries. That alone could freeze the frame. The index is now warmed up in the background shortly after launch, and the hot path simply skips the glossary until it is ready, so it can never block rendering.

**All glossary tables now default to off.** The 15 built-in tables are no longer enabled automatically; open Settings → Terms and turn on the ones you care about. This also removes the overhead of matching against tables you never asked for.

Downloads are below.
