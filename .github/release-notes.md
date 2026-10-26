### PiliBabel v3.0.5

**Fixed: videos that opened to a black screen and 0% forever, with no recovery**

- The player's stall watchdog only arms once playback position has advanced — deliberately, so that normal startup buffering isn't mistaken for a stall. The flip side: when the very first stream URL is unusable (403 / TLS failure / zero throughput), position never advances, so nothing ever recovered. You got a black screen, a 0% indicator, and an indefinite wait.
- A dedicated first-load watchdog now escalates: after 14 seconds without a first frame it switches to a **probe-verified** alternate line; after 16 more seconds it re-fetches the playback URLs; after 16 more it switches the indicator to a tappable "load failed, tap to retry" state.
- Each step leaves an 8-second grace window for the new connection and the ladder is capped at three steps, so it can never loop or thrash. It also stays out of the way if you paused during loading.
- Note: this is item P0 of the current overseas-network audit. The P1–P3 improvements are **not** part of this release.

Everything inherited from PiliNara / PiliPlus is unchanged.

Downloads are below.
