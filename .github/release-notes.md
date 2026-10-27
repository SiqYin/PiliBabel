### PiliBabel v3.3.7

**Three fixes: an empty comment section no longer pretends to be an error, images retry themselves instead of needing a refresh, and the update prompt actually appears again.**

Comments:

- **"0 comments" now reads as 0 comments.** When a video really has no comments, the section used to render the same "no comments yet" panel plus a **tap to retry** button that the load-failure state uses - so the only thing you could do was tap retry and get 0 comments again. A successful-but-empty response now gets its own empty state with no retry button, and the text shows the real count ("0 comments" / "N comments"). Same fix in the video comment panel, the comment detail page and the dynamics comment section.

Images:

- **Covers, avatars, dynamic images and emotes retry on their own.** The root cause is in Flutter's image cache, not the network: when an image fails to load, the failed entry is never removed from the cache, so every later request for the same image instantly receives the same error - it could only recover by rebuilding the widget (pull to refresh, switching pages, restarting the app). That is exactly the "loads only after a refresh" behaviour. Images now retry twice with backoff (600 ms, 1200 ms), clearing both the disk cache and the in-memory entries before each attempt (including the resize layer, whose cache key the image library could not evict by itself). When the network comes back, any image that had failed is retried too. Covers, uploader avatars, dynamic images, emotes and comment avatars all go through this path.
- **Cover prefetch no longer poisons the cache.** A failed prefetch used to leave the same dead entry behind, so the cover stayed blank when you scrolled to it. Failed prefetches are now cleared, and the prefetch queue can no longer stall after an error.

Updates:

- **The update prompt works again.** The old check decided "already up to date" by comparing the build timestamp against the release's creation time, which ignores version numbers entirely - any build newer than the latest release (a local build, a debug build, a CI re-run, a clock skew) would be considered newer forever and never prompt. It now compares version numbers (v3.3.7 vs the installed version), falling back to the timestamp only when a version cannot be parsed.
- **Update checks are no longer routed through the local resolver proxy.** They go through the app's HTTP/2 stack, whose sockets are pointed at the in-app DNS proxy; any hiccup in that proxy made the check fail silently, which reads as "no update prompt ever". A failed check now retries once over a direct connection.
- **Fixed a real race in the local DNS proxy.** While a CONNECT tunnel was being established, bytes the client sent in the meantime (the TLS ClientHello) were dropped, which made HTTPS requests through the proxy occasionally fail the handshake. They are now queued and forwarded in order.

Everything from v3.3.6 is included as well: the gRPC host order fix (comments and the dynamic feed), the cached-audio fixes, and the re-cache / re-download actions on all four cache and download entries.

Downloads are below.
