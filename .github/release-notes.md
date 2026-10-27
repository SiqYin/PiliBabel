### PiliBabel v3.3.10

This release addresses the issues reported after v3.3.8 / v3.3.9. No code has been removed compared to the test release — this is a regular feature/fix update on top of v3.3.9.

**1. Update prompt appears much sooner.** The update check previously raced two network paths but used `Future.wait`, which waits for the slowest path (the direct connection can take up to ~15s) — that is why the dialog only popped about 5–10 seconds after entering the app. It now truly settles on whichever path returns data first, so an available update is announced promptly.

**2. Comment-sort wording AI translation hardened.** Strings such as 「最热评论/最新评论」 (Hottest/Newest) and 「最热/最新」 are now in the translation pre-warm cache so they don't show the untranslated text on first view. If a language other than Simplified Chinese is the target and these still appear in Chinese, please report it — it likely means that entry point wasn't routed through the translator and I'll track it down one by one.

**3. AI translation enabled across the cache / download screens.** Local video titles, uploader (UP) names, status text of in-progress downloads (including 「获取播放地址」/Get play URL), folder empty-state and folder titles, audio-cache items, and the delete-cache confirmation dialog are all now translated.

**4. Download no longer freezes on "获取播放地址".** The play-url fetch now has a hard 45-second timeout per attempt, retries, and finally fails with a clear "Get play URL failed" toast instead of hanging silently with no feedback.

**5. Homepage covers load more reliably.** Cover pre-fetch no longer skips the first screen's lazy-loading; the whole batch is pre-fetched concurrently, reducing the case where many covers stay blank until you pull-to-refresh.

Downloads are below.