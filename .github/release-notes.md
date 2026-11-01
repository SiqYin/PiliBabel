### PiliBabel v3.4.7

**Fixes "failed to fetch stream" when downloading audio/video to a local folder; failed fetches now leave a retryable record; Japanese "绝区零" is pinned to "ゼンゼロ".**

**Root cause of the stream-fetch failure (a genuine bug).** All three fetch paths in the download service (single-file video / DASH high-quality video / audio) hard-coded `videoType: VideoType.ugc` and **never passed `seasonId` / `epid`**. A bangumi (PGC) item requires `ep_id` / `season_id` when requesting `playurl`; without them the server simply returns no stream — so the whole download fails at the very first step and the user sees "failed to fetch stream, cannot download locally". This explains why **some** videos always failed: every bangumi-type item hit it. All three paths now use `epId == null ? ugc : pgc` and carry `epid` / `seasonId`; the video page passes them down as well (null for UGC).

**Failed fetches now leave a record.** Previously a fetch failure only showed a toast — nothing appeared in the list, so the user could neither see "this one was attempted and failed" nor retry. A `failed` record is now written, visible under "Offline cache → Download video / Download audio", where the user can tap "Re-download" to retry. (The placeholder path never creates a real file; the record's `failed` flag is what the list keys on.)

**Japanese pinned translation:** `绝区零` → `ゼンゼロ` (a game proper noun; the model tends to produce long, inconsistent renderings like 「ゼンレスゾーンゼロ」, so it is pinned via the manual translation table).

Downloads are below.