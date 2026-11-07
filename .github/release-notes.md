### PiliBabel v3.7.8

**Momentum release: the first-launch intro covers all three buttons, opening a video auto-starts danmaku pre-translation, danmaku pre-translation matches subtitle speed via the same concurrent worker pool, and cover vision requests are serialized in click order with retry — 504s heal themselves.**

**Three-button intro.** The first-launch popup now explains the danmaku, subtitle and cover-translation buttons (previously it described only two).

**Auto-start danmaku.** Opening a video now automatically starts danmaku pre-translation for that part, right next to the automatic subtitle pre-translation.

**Danmaku speed.** Danmaku pre-translation switches from sequential batch requests to the same concurrent worker pool that makes subtitles feel instant (up to 5 parallel batches).

**Cover vision reliability.** Vision requests are serialized in click order — tapping several covers at once no longer breaks the first ones — with automatic retries (2s/5s backoff) on 504/gateway timeouts and connection drops. Raw DioException dumps are no longer fed to the translation model; errors surface as short friendly messages.

Downloads are below.
