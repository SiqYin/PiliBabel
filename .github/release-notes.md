### PiliBabel v3.4.9

**Fixes `-400 请求错误` when downloading video/audio to a local folder: play-url parameters now come from the authoritative video-detail response.**

The v3.4.8 diagnostic release revealed the real error: `错误(-400): 请求错误` — meaning the **request parameters themselves were invalid**, not a login or risk-control problem.

**Root cause.** The working "cache audio" path uses the authoritative values returned by the video-detail API (`videoDetail.aid / bvid / cid`). "Download to local" instead used page state — `aid`, `bvid`, and `seasonCid ?? cid.value`. Here `seasonCid` is the **item selected inside a collection**, which is not always the cid currently being played. Whenever the two fall out of sync (just switched part, just tapped a collection entry, detail not loaded yet), `cid` no longer matches `bvid`, and the server rejects the request with `-400 请求错误`.

**Fix.** Both download calls now **prefer the authoritative `aid` / `bvid` / `cid` from the detail response**, falling back to page state only when unavailable. `cid` no longer uses `seasonCid` but the currently playing one — matching where the audio-cache path gets its parameters.

Downloads are below.