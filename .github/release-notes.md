### PiliBabel v1.5.0

- **Headphone audio is back in sync.** The player used to ask mpv for OpenSL ES first, which only *estimates* the output latency; AudioTrack *measures* it, the same way the official Bilibili app does. The default order is now `audiotrack,aaudio,opensles` — reorder it in 设置 → 视频 → 音频输出设备.
- **A black picture with sound playing is no longer silent.** If the video track stops producing frames while audio keeps going, the loading indicator comes back with 画面加载中，点击重试, and the app reloads the same line and quality before switching anything.

Downloads are below.
