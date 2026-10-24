### PiliBabel v2.6.0

**Cache audio, and download to a folder you own**

Two things upstream PiliNara / PiliPlus don't do — and the main reason you might want this fork.

**Cache audio (audio-only offline cache)**

- A *Cache audio* entry sits right below *Cache video* in the video page menu, and in the *More* menu of the listen-video page.
- Pick the quality tier: Hi-Res lossless, Dolby Atmos, 192K, 132K or 64K — the same preset list the video quality picker uses.
- Files are written in their original container (`m4a` / `mp3` / `flac` / `wav` / `aac` / `ogg`) — no transcoding.
- The cache page is split into *Cached videos* / *Cached audio* and remembers the module you were on last time.
- Tapping a cached audio item opens the audio player; items delete one by one or in bulk.

**Download to local folder**

- The cache menu now offers two branches: keep it inside the app, or write it to a folder you own.
- Choose that folder through the system file manager (Settings → *Download to local folder*); change or clear it any time. If it isn't configured yet, the app takes you straight to that setting.
- Video is fetched as a single muxed stream (`fnval=1`), so what lands on disk is a plain MP4 that any player can open.
- Audio keeps its original format, same as the in-app cache.
- Files are named after the video title and never overwrite an existing download.

Everything inherited from PiliNara / PiliPlus is unchanged.

Downloads are below.
