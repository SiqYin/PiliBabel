### PiliBabel v3.3.3

**Hotfix: the comment section could not load.**

- Opening a video and scrolling to the comments showed a load failure, and tapping retry failed again immediately, every time, no matter how often you tapped. Video playback itself was fine.

The cause was in the first-page comment prefetch. When the prefetch result was handed to the reply controller, the code built `Success(cached)` and cast it to `LoadingState<R>`; since `cached` is typed `MainListReply?`, that produced a `Success<MainListReply?>` which cannot be cast to `LoadingState<MainListReply>` at runtime. The cast therefore threw the instant the prefetch resolved - before any network work - which is exactly the "instant failure" behaviour. On top of that the prefetch cache was never consumed, so every retry hit the same cached entry and threw again.

Two changes:

- A prefetch result whose type does not match the controller's expected type is now treated as a miss and falls back to a normal request instead of throwing.
- The prefetch cache is now single-use: a hit removes the entry, so a retry (or a pull-to-refresh) always issues a real request instead of replaying a stale result.

Everything from v3.3.2 is included as well: DNS resolution instrumentation and the encrypted-DNS fallback switch, the host table, speed scores shared with the connection layer, second-screen feed prefetch with generation-based de-duplication, feed `idx` semantics, the audio page's buffered range and cache statistics, host health in stream selection, and the "load more replies" wording.

Downloads are below.

