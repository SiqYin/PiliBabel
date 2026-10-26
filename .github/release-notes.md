### PiliBabel v3.3.0

**Overseas network experience, part 3: the network foundation, the feeds, audio, comments, and the P3 items**

Network foundation (A1-A5):

- **The app resolves bilibili host names itself and routes them through a local proxy.** A loopback CONNECT proxy (random port, per-process token) carries the HTTP/2 pool, with per-host health tracking, failover to the next host, and backoff on 412 / 429 / 5xx. If anything is off, the normal path still works.
- **Host health and request limiting.** Every host carries a health verdict, and requests are spread over the gRPC host set instead of hammering one; a per-host concurrency gate keeps one host from being flooded.
- **Layered timeouts and connection-pool parameters.** Connect, receive and idle timeouts are set separately, and the download path gets its own tier.
- **Per-host CDN speed scores and a cold probe.** Scores are stored per host, and a short probe runs before the first frame so the player does not start on a host that cannot deliver.
- **Network-change self-healing extended.** On top of the P1 work, the app now watches connectivity and refills the list you were looking at once the network comes back.
- **Unified network error classification**, so a failure picks retry / switch host / switch resolver / tell the user instead of guessing.

Feeds (B1-B4):

- **Playback URLs are prefetched** (TTL 5 minutes) the moment you open a video page, so the player does not wait for the playurl round trip.
- **Covers are prefetched through a bounded queue**, so scrolling to the second screen no longer shows empty blocks.
- **The first two items of the home feed are prefetched** on Wi-Fi before you tap anything.
- **Official feed parameters.** `open_event` (first feed request of the process) and `login_event` (first feed request after a login) are now sent, matching the official client.
- **Cold-start feed endpoint** (`/x/v2/feed/coldstart`, TTL 90 seconds) is used so a cold launch shows content sooner.

Audio (C1-C4):

- **Audio buffer raised to 60 s / 64 MB**, with the cached range painted on the progress bar, and the next track prefetched when you switch tracks.

Comments (D):

- **The first page of comments is prefetched** (2 retries, TTL 3 minutes, keyed by sort mode), so opening a video shows comments immediately; sub-replies prefetch their next page too, and the prefetch depth is 6 on Wi-Fi and 2 on cellular.
- **A failed comment refresh keeps the list** and shows a toast instead of an empty page.

P3 (E2 / E3):

- **Multi-connection media proxy** (off / 1 / 2 / 4 connections). A local loopback proxy fetches one media file over several ordered Range shards and streams them back in order; it falls back to the direct URL on any error, and sends the Referer the CDN requires.
- **Dynamics over gRPC** (DynAll / DynVideo / DynSpace). The gRPC cards are converted into the same structure the existing parser already eats, so no UI code changed. 14 card types are covered; anything else falls back to the REST endpoint for the whole page, so you never get a half-rendered list.

Two switches you may want:

- Settings - Playback - 媒体层多连接代理 (multi-connection media proxy): 0 / 1 / 2 / 4, default 0 (off).
- Settings - Other - 动态走 gRPC 接口 (dynamics over gRPC): default on.

Not in this release: `first_login` and `banner_hash` are not sent, because the official package only carries `first_login_time` (an account field, not a feed parameter) and `banner_hash` belongs to the home banner this client does not fetch; the newer `bilibili.main.dynamic.feed.v1` dynamics namespace is not migrated (v2 is what the current models are built on); the official HTTPDNS endpoint is not obtainable (it is in neither the dex nor the native libraries), so this fork only matches the behaviour; and the home feed still uses its REST endpoint, because its gRPC service definition is not publicly available.

Everything inherited from PiliNara / PiliPlus is unchanged.

Downloads are below.

