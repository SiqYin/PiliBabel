### PiliBabel v3.6.4.1

**Urgent fix: v3.6.4 opened to a permanent black screen.**

**What happened.** To move glossary index construction off the first frame, v3.6.4 called `warmGlossary()` at the end of `UiTranslateService.onInit()`, and that method read the service's own settings through `to`. But `onInit` runs while the service is *still being registered* — resolving `to` at that moment throws. The exception escaped `onInit`, and `onInit` is invoked from a synchronous `..put()` inside `main()`, before `runApp()`. Startup therefore aborted before the first frame was ever built: a black screen that never goes away, and no crash either, because there is no frame loop left to crash.

**The fix.** `warmGlossary()` no longer touches `to`. It reads `Pref.uiTranslateEnabled` directly and wraps the whole warm-up in `try`, so a failed warm-up can never affect startup. Warm-up is purely an optimisation; it should never be able to break launching.

Also restored a doc comment that had been dropped from `rebuildGlossaryIndex`, and fixed a missing newline at end of file.

Everything from v3.6.4 is included, of course: the single-pass term scan, the background index warm-up, and all glossary tables defaulting to off.

Downloads are below.
