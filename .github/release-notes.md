### PiliBabel v3.3.8

**Faster cover loading, translated comment-sort labels, and a genuinely reliable update prompt.**

Images:

- **Cover loading is back to the v3.0.5 approach.** The home feed's first-screen covers were taking ~10 seconds to all appear — not failing, just being throttled. The 10s delay was introduced in v3.0.0, when cover prefetch was switched from "resolve everything immediately" to a bounded queue delivering at most 2 concurrent images 40 ms apart, so the first-screen covers queued behind that slow pacing. Prefetch is now the old foreach immediate-resolve implementation again. Home covers, dynamic covers, emotes and uploader avatars all follow this path. The comment section is not affected.

Comments:

- **Comment-sort labels are translated again.** The "Hottest comments / Newest" and "Hottest / Newest" labels in the top corners of every comment entry (video comments, the comment detail page, main reply list, and the dynamics comment section) are now routed through the AI translation again.

Updates:

- **The update prompt is actually reliable now.** The previous check was called once, over a single request, and silently swallowed any failure — if that one request hit a transient network/proxy hiccup at startup, you would never see the update prompt for the whole session. It now races the main link against a direct connection (whichever returns data first) and retries with backoff, so a momentary blip no longer hides an available update.

The empty-comment-section fixes from v3.3.7 are kept as is.

Downloads are below.