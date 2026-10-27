### PiliBabel v3.3.6

**gRPC host order fix - the comment section and the dynamic feed work again.**

- Every gRPC call was going to `grpc.biliapi.net` first. That is the official native gRPC host, and it reports `Grpc-Status` in HTTP/2 trailers; our client talks HTTP/1.1 through Dio, never sees trailers, so the status header was simply missing and every call was treated as a failure. The comment section sat on "tap to retry" forever and the dynamic feed's media never resolved.
- The host order is back to what it was before the network rework: `app.bilibili.com` first (the App-side host returns `Grpc-Status` in the response headers), with `grpc.biliapi.net` kept as the failover.
- The error text also spells out what actually came back now - `grpc-status`, `bili-status-code`, the HTTP status and the request URL - so a failure reads as a reason instead of an empty retry button.

Everything from v3.3.5 is included as well: the cached-audio fixes (a finished task no longer leaves a stuck 100% progress bar, and deleting a finished task no longer deletes the shared audio file), the re-cache / re-download actions on all four cache and download entries, the analyze cleanup, and the selective upstream picks.

Downloads are below.
