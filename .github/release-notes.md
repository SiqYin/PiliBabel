### PiliBabel v3.3.4

**Dynamics cards, a home-feed cover fix, and an upstream sync.**

- The dynamics (P3) timeline now renders four card types that were previously dropped or shown as blanks: paid/charging posts, applets, topic sets, and subscription cards.
- Fixed the home feed's first screen showing no covers at all. The cold-start prefetch entries are consumed as the first page, and those entries do not always carry a top-level `cover`; the cover is now read from the item's `args`/`pic` fallbacks, and a prefetch page that yields no cover at all is treated as a miss so the normal feed request runs instead.
- Upstream PiliNara changes are in: the status bar going dark when the app opens, downloads that were waiting resuming after the process is killed, the media-kit and companion package upgrade, the Wayland black-video workaround, and selectable audio quality when caching a video.
- AI-translation audit of every interface string added since 3.0.5. One string was missing: the "audio quality" label and the quality menu items in the download panel now go through the same AI translation path as the rest of the UI.
- The README changelog was rewritten from scratch for all 44 language versions, covering everything from 2.6.x through 3.3.4.
- Upstream sync baseline for this release: Starfallan/PiliNara at commit `b5694ccd` (2026-10-24). The baseline is written down in `UPSTREAM-SYNC.md` so the next sync knows where to start.

Everything from v3.3.3 is included as well: the comment-section hotfix (the first-page prefetch was casting `Success<MainListReply?>` to `LoadingState<MainListReply>`, so the cast threw before any network work and every retry replayed the same broken cache entry), the v3.3.2 DNS resolution instrumentation and encrypted-DNS fallback switch, the host table, speed scores shared with the connection layer, second-screen feed prefetch with generation-based de-duplication, feed `idx` semantics, the audio page's buffered range and cache statistics, host health in stream selection, and the "load more replies" wording.

Downloads are below.
