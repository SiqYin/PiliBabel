### PiliBabel v2.6.5

**Premium-quality downloads actually work, and failed downloads can be retried in place**

**Fixed: downloading premium qualities (1080P60, 4K, Dolby, HDR, 8K) failed even with a logged-in premium account**

- The root cause is on the server side: above 1080P, those qualities exist **only as separate DASH streams**. The download-to-local path requested the single-muxed-MP4 endpoint (`fnval=1`), which tops out at 1080P even for premium accounts — for higher tiers it returns a downgraded stream, or no stream at all, which showed up as "download failed".
- Premium qualities now download through DASH: you get a **video track (`mp4`) plus an audio track (`m4a`)**, with the two downloads chained and their progress merged into one record tagged *split stream*. Players such as mpv / VLC can play the pair together or merge them later. 1080P and below remain a single, directly playable MP4 file exactly as before.
- The quality picker marks every above-1080P tier as *split-stream download* so there are no surprises.

**Fixed: Hi-Res audio could never be downloaded**

- The stream request was missing the Hi-Res flag (`fnval` bit 4096), so the Hi-Res (FLAC) track never appeared in the response — even for premium accounts, picking Hi-Res silently fell back to 320K.
- The flag is now sent; and whenever the chosen quality (video or audio) isn't available for your account, a toast tells you exactly which tier is being downloaded instead of failing silently.

**New: "Re-download" on the Download status page**

- On both the *Downloaded video* / *Downloaded audio* tabs, the three-dot menu now offers *Re-download* — visible only when the record is **failed** or its **local file is gone**.
- One tap restarts the download with the exact quality you picked last time: no need to find the video again or go through the quality pickers. Old records without stored quality fall back to 1080P / 192K.

Everything inherited from PiliNara / PiliPlus is unchanged.

Downloads are below.
