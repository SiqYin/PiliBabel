### PiliBabel v2.6.2

**Cache audio, and download to a folder you own**

Two things upstream PiliNara / PiliPlus don't do — and the main reason you might want this fork.

**Cache audio (audio-only offline cache)**

- A *Cache audio* entry sits right below *Cache video* in the video page menu, and a dedicated cache-audio button sits left of the sort / sleep-timer / more buttons in the listen-video page top bar.
- Pick the quality tier: Hi-Res lossless, Dolby Atmos, 192K, 132K or 64K — the same preset list the video quality picker uses.
- Files are written in their original container (`m4a` / `mp3` / `flac` / `wav` / `aac` / `ogg`) — no transcoding.
- The cache page is split into *Cached videos* / *Cached audio* and remembers the module you were on last time.
- Tapping a cached audio item opens the audio player; items delete one by one or in bulk.

**Download to local folder**

- *Download to local folder* is its own entry in the video page menu, right under *Cache audio* — caching inside the app and saving to a folder are two separate actions.
- It first asks *Download video* or *Download audio*, then asks for the quality tier (video quality / audio quality picker).
- Choose the target folder through the system file manager (Settings → *Download to local folder*); change or clear it any time. If it isn't configured yet, the folder picker opens on the spot.
- Video is fetched as a single muxed stream (`fnval=1`), so what lands on disk is a plain MP4 that any player can open.
- Audio keeps its original format, same as the in-app cache.
- Files are named after the video title and never overwrite an existing download.

Everything inherited from PiliNara / PiliPlus is unchanged.

Downloads are below.
