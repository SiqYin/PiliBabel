### PiliBabel v3.7.0

**Adds AI-powered subtitle translation: real-time Chinese→target-language subtitles with context-aware chunked translation, offline dictionary for Vietnamese, and optional proxy routing.**

**Core subtitle translation engine.** Chinese subtitles are split into 20-cue chunks with 4 lines of overlap context for consistent character names and pronouns. Each chunk is translated independently with retry, timeout, and quality validation (residual Han detection, timing integrity, context-echo rejection). Completed translations are checkpointed to disk and survive app restarts.

**Realtime buffering.** Playback starts when 60 seconds of translated subtitles are available ahead; auto-pauses if coverage drops below 15 seconds. The translation queue prioritizes the current playback position, then nearby chunks, then future segments. Seeking immediately reprioritizes work.

**Subtitle track management.** A new track list appears in the player's subtitle menu: Bilibili's own tracks (including official AI translations) plus a live AI-translated track with progress labels. Manual per-part selection is remembered for the session. A compact card-cover button on video cards shows translation status and offers one-tap retranslation.

**Vietnamese offline dictionary.** 309 common UI labels are instantly translated offline when Vietnamese is selected as the interface language — no API call, no network round trip. Falls through to the AI translation pipeline for dynamic content.

**Optional HTTP/SOCKS5 proxy routing.** Translation requests can be routed through user-configured proxies (6 concurrent slots per proxy) to accelerate subtitle translation. The device's direct connection is always available as a fallback; invalid proxy configuration never blocks translation.

**Settings.** New subtitle section: chunk size (10–40 cues), concurrency (1–5), context overlap (0–8 lines), wait-for-complete toggle, playlist prefetch (0–5 videos), and proxy configuration.

**Bonus fixes:** QR code refresh race condition, and video quality/codec selection tolerance when the DASH stream list doesn't match the declared formats.

> **Credit:** The subtitle translation system was originally contributed by [saukhoai](https://github.com/saukhoai) via [PR #2](https://github.com/SiqYin/PiliBabel/pull/2). We adapted and integrated the core engine, generalized it for all target languages, and merged the Vietnamese offline dictionary and proxy routing as optional features.

Downloads are below.
