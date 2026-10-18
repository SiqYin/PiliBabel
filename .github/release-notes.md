### PiliBabel v2.3.4

Fixes recurring "image download failed" errors in image translation.

- The image translation HTTP client is now discarded as soon as a download or request fails, so the next retry rebuilds it and re-resolves DNS with a fresh connection. Version 2.3.3 made the client long-lived, which meant a single unreachable address got reused for the rest of the session (`Network is unreachable`, errno 101) and only an app restart recovered.
- The client is still rebuilt when the network changes.

Downloads are below.
