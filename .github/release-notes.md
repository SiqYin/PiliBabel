### PiliBabel v3.7.4

**Fixes the subtitle cache button that could spin forever — every path that left the button stuck is now closed.**

**Batch pre-translation could hang on "translating" forever.** Collection batches only cleaned up their timer when the queue ended, but a part taken over by the player's own task finished later — so the parent task stayed "translating" with no way out. Finalisation now follows the task states: the monitor keeps watching until every part reaches a terminal state, and a part without subtitles counts as "handled" instead of stalling the whole set on "checking video list".

**The same episode opened from different places was translated twice — and the player could not find the finished translation.** The cover card started work under `ep<episode>` while the player looked up bvid, so the two keys never matched. Identity resolution now promotes everything to one canonical key (bvid → aid → epId → seasonId), so cache, artifact, status and "delete translation" all agree.

**Completion and failure toasts could be lost — or pop twice.** Moving a task between keys used to drop its notification, while attaching to an already-running task re-announced it. Notifications now follow the task: exactly one, never lost.

**A failed verification left the button spinning.** The "translation incomplete" exit path never cleared the running state. Every exit now resets the button and offers a tappable retry.

**Vietnamese track names showed Chinese first — or forever.** When track labels moved to the shared translation pipeline, the offline dictionary and pre-warm list were not updated, so Vietnamese users saw raw Chinese labels (permanently without an AI provider). Fixed labels now resolve offline instantly and are back in both lists.

**Subtitle downloads ignored the v2 address.** Tracks that only ship `subtitle_url_v2` were skipped entirely; downloads and exports now try each candidate address. Damaged or stale-version translation artifacts are never copied into offline videos.

**Translator stall guard is now pinned by tests.** The "three rounds without progress must give up" rule has a regression test, so it cannot silently regress.

Downloads are below.
