### PiliBabel v3.4.10

**The real root cause: an invalid `4096` bit OR-ed into `fnval` made **every audio stream fetch** be rejected with `-400 请求错误`. This is why "video downloads all work, audio downloads all fail".**

**Symptom.** Every "download audio to local" attempt failed with `错误(-400): 请求错误`, with byte-identical text, while "download video to local" worked fine.

**Root cause.** The two audio fetch paths (download-audio and cache-audio) sent `fnval: 4048 | 4096` = **8144**. Per the bilibili playurl spec, `fnval` is a bitmask whose valid bits are only `1` (mp4) / `16` (dash) / `32` / `64` (HDR) / `128` (4K) / `256` (Dolby) — **`4096` is not a valid bit**. The video DASH path uses the default `4048` and always worked; adding `4096` makes the whole request invalid, so the server rejects it at the parameter-parsing stage with `-400`. That is also why it failed every single time with exactly the same message.

**Fix.** Both paths are back to `fnval: 4048` without the 4096 bit. Hi-Res tracks are delivered as part of the DASH response anyway; that bit was never needed.

Note: this has nothing to do with the audio/video merging feature — merging runs *after* a successful fetch, so a failed fetch never reaches it.

Downloads are below.