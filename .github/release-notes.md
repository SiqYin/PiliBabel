### PiliBabel v3.3.1

**Follow-up round on the network foundation, the home feed, audio and comments.**

Network:

- **DNS resolution is now instrumented.** The self-resolver counts successes, system-resolver failures, DoH fallbacks and how long each lookup took (average, last, slowest), so a slow or failing resolver is visible instead of silent.
- **DNS over HTTPS got its own switch** (Settings - Other - DNS encrypted fallback resolution, default on). It only runs when the system resolver has already failed, so the normal path is untouched.
- **The host list is now a real table.** Every host the app talks to carries its purpose, whether it speaks gRPC, and whether it takes part in failover - documented in one place instead of being scattered.
- **CDN speed scores are shared with the connection layer.** The measured throughput of each host now feeds the same health store the request layer uses, so a host that measured fast is also preferred for API traffic, and a host in cooldown is skipped when picking a stream URL (audio and video share that picker).

Home feed:

- **The second screen is prefetched.** After the first screen lands, the next page of feed data is fetched in the background, so scrolling to it renders immediately.
- **Prefetch and pull-to-refresh can no longer fight.** Refreshing bumps a generation counter, so a prefetch that was in flight before the refresh is dropped instead of overwriting the fresh list.
- **`idx` now follows the official semantics.** The app remembers the `idx` the server returned with the last item and sends that when loading more, instead of the page number; if the server gives no usable `idx`, it falls back to the old behaviour, so nothing changes on responses that do not carry it.

Audio:

- **The cached (buffered) range is actually drawn in the audio page** - it was never passed to the progress bar before - and a new "cache statistics" entry in the more menu shows how much is cached and what share of the track that is. (The official client reports cached bytes from its ijk player; a byte count needs kernel-side support, so this reports cached time.)

Comments:

- **"Load more replies" now matches the official wording and behaviour**: before expanding it shows the total ("N replies, tap to expand"), and once partially expanded it shows how many are left.

Downloads are below.

