### PiliBabel v3.1.0

**Overseas network experience, part 2: the P1 and P2 items of the audit**

P1 — high value, low risk:

- **Network-change self-healing on every platform.** Rebuilding the HTTP/2 pool when the network changes used to happen on iOS only. Android and desktop now do the same, and they also drop the cached CDN speed scores and expire the region verdict, so the next stream re-detects its region instead of reusing a verdict from another network.
- **Region detection is now 1 day, not 7.** The CDN region verdict is re-detected daily, and immediately whenever the network changes. If an entire speed-test round comes back empty, the region is re-detected once, throttled to once per 10 minutes.
- **In-app "cache audio" now asks for Hi-Res.** The audio-only download path was missing `fnval 4096`, so a Hi-Res track silently fell back to 320K.
- **The retry interceptor covers 412 / 429 / 5xx.** A 412 (risk control) now refreshes the buvid once and retries the request; 429 and 5xx are retried too. The refresh is throttled to once a minute.
- **Pagination prefetch for feeds and comments.** The next page is requested while you are still 6 items away from the end of the list, instead of at the very end, so the tail no longer waits for a round trip.
- **One fingerprint and one connection pool for the whole image pipeline.** Images now share a single HTTP client with a fixed user-agent and referer, keep-alive, a per-host connection cap, and explicit connect / read timeouts, instead of each image doing its own thing.
- **Adaptive forward buffer by bitrate.** The player's forward buffer is now `max(your setting, bitrate/8 × 20s)`: a high-bitrate stream gets a deep enough buffer, while low-bitrate streams do not waste memory.

P2 — medium:

- **A failed refresh no longer wipes your list.** Comments, the dynamics tab and the space dynamics tab keep the data you already have when a refresh fails; you get a toast instead of an empty page.
- **Real per-install device fingerprints.** `fp_local` and `fp_remote` used to be the same all-1 placeholder for every user. They are now random per install and stable afterwards.
- **Media layer: connection reuse and DNS warm-up.** DASH streams are fetched with `multiple_requests=1` and `http-persistent=yes`, and both the video and audio host names are resolved before the player connects.
- **The speed-test probe no longer burns cellular data.** 512KB per candidate on Wi-Fi, 128KB on cellular.

Not in this release: the home feed still uses its REST endpoint, because its gRPC service definition is not publicly available. P3 of the audit (replacing the player stack, HTTPDNS, migrating dynamics / space / search to gRPC) is still investigation only.

Everything inherited from PiliNara / PiliPlus is unchanged.

Downloads are below.
