### PiliBabel v3.5.3

**Fixed: "Cache audio" on the video page was actually caching video.**

- **Symptom.** Opening 音频缓存 from a video's ⋮ menu showed the same cache-video
  panel, and tapping an entry cached the video instead of producing an audio
  file. Only the 听视频 page's cache-audio button behaved correctly.
- **Root cause.** The cache panel (`DownloadPanel`) is shared by video and audio,
  but its `isAudio` flag was used **only** to choose which module the
  "view cache" button jumps to. The tap handler was hard-wired to
  `downloadVideo` / `downloadBangumi` — the audio path was never connected.
- **Fix.**
  - New `_onAudioCache()` shares `AudioCacheService` with the 听视频 page and
    writes a plain audio file (m4a/flac…) at the quality chosen in the panel.
    For multi-part videos the part inherits its parent episode's aid/bvid/cover,
    so episodes in a season no longer collapse onto the same video.
  - `_onDownload` routes to the audio path right after the "multi-part videos
    need an explicit part" check, so the interaction matches the video panel.
  - **Cache state is now checked per module**: audio against
    `AudioCacheService.isCached`, video against `cidSet` — previously an
    already-cached video made audio caching silently skip as "already cached".
  - The audio panel hides the **video** quality selector (it had no effect on
    the output and was misleading) and keeps only audio quality.
  - "Cache all" goes through the same entry point and follows the audio path.

中文摘要：修复视频页「音频缓存」实际缓存视频的问题。根因是视频/音频共用的缓存面板里，
`isAudio` 只用于「查看缓存」的跳转，点条目永远走视频下载分支，音频链路没接上。
现在音频走与「听视频」页相同的 `AudioCacheService`、按所选音质落盘纯音频文件；
分P 继承所属分集的 aid/bvid；缓存状态按模块分开判断；音频面板只保留音质选择。

Downloads are below.
