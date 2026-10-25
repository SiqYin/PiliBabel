### PiliBabel v3.0.1

**The overseas performance release: closing the gap with the official app at the transport layer**

If you use PiliBabel outside mainland China, this release targets the single biggest reason it felt slower than the official app in *every* network area — video loading, comments, feed refresh, dynamics:

**HTTP/2 multiplexing is now on by default**

- Every request the app makes — including the app-API feeds and gRPC comments — used to run over HTTP/1.1, where each concurrent request builds its own connection: on a high-latency overseas link that's 2–3 extra round trips before the first byte of every single request.
- The official app multiplexes everything over a few long-lived HTTP/2 connections. PiliBabel now does the same, app-wide. This is the change that makes comments, feeds, dynamics and playback startup feel dramatically closer to the official client abroad.
- Users who explicitly turned HTTP/2 off in settings keep their choice.

**Connection pre-warm on launch**

- 1.5 seconds after startup the app quietly opens connections to `api.bilibili.com` and `app.bilibili.com` (DNS + TCP + TLS), so your first feed refresh and everything after reuse warm connections instead of paying handshake costs again.

**A real browser User-Agent on web endpoints**

- Web-facing requests previously identified themselves as a bare `Dart/3.6` client — an obvious non-browser fingerprint that overseas IPs get rate-limited on. They now present a standard browser UA, matching the player's web fingerprint.

**Feed cover prefetch**

- Each page of the home feed prefetches the next ~10 covers into the image cache, so scrolling hits warm cache instead of waiting on overseas image requests.

**Also fixed**

- Vote badges in comments ("voted 'xxx'") now go through AI translation, matching the already-translated red/blue team prefixes.

**A note on dynamics**

- Migrating the dynamics feed to the gRPC endpoint was evaluated and deliberately skipped: the accessible gRPC dynamics API serves plain-text bodies (no rich text / emotes), which would *downgrade* content. The dynamics endpoint already sits on the main API domain and benefits from everything above.

Everything inherited from PiliNara / PiliPlus is unchanged.

Downloads are below.
