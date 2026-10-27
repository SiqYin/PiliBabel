### PiliBabel v3.3.15

**Urgent fix for the seek-to-unbuffered-position crash/black-screen introduced in v3.3.14**, plus stability follow-up and documentation completion.

**Seeking caused a crash / stuck-at-99% / "poor network" line switch jumping back to 00:00 (introduced in v3.3.14).** Two causes:

1. `MediaProxy`'s segmented requests previously only rejected responses with status ≥400 — they never verified that each range request actually returned **206 + the requested byte range**. bilibili's CDN occasionally answers a range request with **200 full content** (i.e. ignores the Range header), which made the whole file land in one segment, so the bytes written didn't match `Content-Length` / `Content-Range`. The player failed to parse it, treated it as a network problem, switched lines, and jumped back to 00:00. Range responses are now strictly validated as 206; if validation fails the request falls back to a plain single-connection pass-through.
2. Seeking re-issues a Range request for the same media URL while the old request is still reading upstream (stuck at "99%" or black screen), competing for bandwidth and pushing the new request into a timeout. Requests are now mutually exclusive per upstream URL: a new request terminates the older one for the same media URL.

**Media proxy upstream hard-wired to direct connections.** `MediaProxy`'s upstream client now explicitly sets `findProxy = DIRECT`, so turning off "network direct connection" can't turn its N concurrent range requests into N tunnels through the in-app resolver proxy (the same class of failure as v3.3.11).

**README documentation completed (backlog items 84–86).** All 44 language READMEs now carry an AI-translation note; also verified the offline audio cache / download-to-local sections exist in every language.

Downloads are below.