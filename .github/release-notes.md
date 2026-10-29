### PiliBabel v3.4.1

**Three cache/download fixes, plus automatic collection sub-folders for local downloads.**

- **Failed cache items can be retried now.** Previously, tapping a failed item jumped to the "Currently caching" page — which only lists queued tasks, so a failed entry could do nothing there — while "Re-cache" was buried in the top-right menu. The result was exactly "there is no re-download button and tapping does nothing". Now:
  - tapping a failed item **re-caches it directly**;
  - the cover shows a **visible "Re-cache" button**, no menu needed.
- **Covers in "Currently caching / cache list" no longer grow.** `DetailItem`'s cover is also a `Row` + `AspectRatio` (width derived from available height), so it grew when "show full title" made the grid cell taller. It is now pinned to its original height.
- **The cache/download pages open on the tab that matches the entry point.**
  - "Cache video" → the cache screen opens on **Cached videos**; "Cache audio" → **Cached audio**. (Previously it always reused whatever module you last visited, so tapping "cache audio" could land on audio and tapping "cache video" could also land on audio.)
  - "Download video / Download audio" → the download screen opens on the matching tab.
- **Automatic collection sub-folders.** When downloading to a local folder, if the video belongs to a collection (`ugc_season`), a sub-folder named after the **collection title** is created inside your chosen folder; a plain multi-part video uses the video title instead. Later episodes of the same collection land in the same folder automatically. Collection names are sanitised (illegal characters such as `\ / : * ? " < > |` removed, over-long names truncated).

Downloads are below.