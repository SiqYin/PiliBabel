### PiliBabel v3.3.5

**Comment-section recovery, cached-audio fixes, and a cleaner analyze baseline.**

- The comment section no longer fails silently. Every request error now carries the gRPC status, `bili-status-code`, the HTTP status and the request URL, so a failure shows a real reason instead of an empty "tap to retry". The `oid` is read from the live player state on every request - a stale `0` snapshot made the server answer `-400 invalid oid` forever - and a manual retry now clears the prefetched first page instead of replaying the same broken entry.
- Cached audio is fixed. A finished cache task stayed in the in-progress list forever, which left a stuck 100% progress bar at the top of the download page; deleting that row then deleted the audio file that the finished entry still points at, so the cached track went silent, snapped back to 00:00 and rolled over to the next part. Finished tasks are removed from the list now, and an already-finished task is only unbound, never deleted. A failed audio-cache task can also be retried in place with the new "re-cache" action, and a failed video-cache entry exposes the same action in its menu.
- Analyze baseline: 16 warnings and a batch of low-risk infos were cleared (dead code, unused imports, cascade invocations, null-aware elements, missing `const` constructors and so on), plus two structural fixes in the member pages - the live-item widget is a standalone file again and the member-works grid uses a simple max-extent delegate.
- Selective upstream picking from the latest upstream: the per-item keyword-filter compilation, the storage keys/prefs, the result model and the member home/opus pages, merged item by item - still no wholesale merge.

Everything from v3.3.4 is included as well: the dynamic (P3) cards, the home-feed cover fix, and the upstream sync recorded at `b5694ccd`.

Downloads are below.
