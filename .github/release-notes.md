### PiliBabel v2.3.0

**Playback: measured CDN picking, a working reload button, and recovery when the picture freezes**

Four things, all aimed at the same complaint - overseas playback stalling and feeling far
slower than the official app.

- **CDN nodes are now measured, not assumed.** Overseas, B站 hands out several candidate
  URLs and the first one is often a mainland mirror that is throttled to roughly 100KB/s
  from abroad. The video stream starves while the much smaller audio stream keeps up, so
  the picture freezes and the sound carries on. The app used to just take the first
  overseas candidate and hope. It now probes the candidates (a ranged read of 64KB each),
  scores them on throughput and time-to-first-byte, and prefers the measured winner. The
  probe is asynchronous because the selection path cannot wait, so the first play still
  uses the original order and the following fetches, line switches and quality switches
  use the measured result. The existing "CDN speed test" switch - which until now did
  nothing at all - controls this.
- **The reload button no longer goes silent.** Reload is ignored while a previous stream
  request is still in flight, which is exactly what happens when the network is slow, and
  it was ignored without any feedback: no message, no spinner. It now tells you it is
  fetching the play address, and if the previous request has been outstanding for more
  than 20 seconds it is treated as stuck and the reload goes through.
- **A frozen picture recovers by switching lines.** When the audio plays on but no video
  frame comes out, the app already reopened the same source once. If that fails it now
  switches to another line even when the "switch line when stalling" option is off - that
  option is off by default, which left the picture frozen with nothing to do about it.
  The switch is still gated behind the availability probe, so it only moves to a line
  that actually answers with 200/206.
- **Buffering tuned toward the official app.** The start threshold was 10.6 seconds,
  meaning ten-plus seconds before anything appeared; it is now capped at 6. The backward
  cache is capped at 8MB instead of matching the forward cache, freeing memory for the
  buffer that actually prevents stalling.

A separate document assesses what replacing the playback engine would cost. Short version:
not worth it now - the stalling is a network-layer problem, not a decoding one.

Downloads are below.
