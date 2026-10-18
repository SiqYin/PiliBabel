### PiliBabel v2.3.6

Fixes "image download failed" errors in image translation.

- Image downloads now connect directly first and only fall back to the configured system proxy. They previously always went through the proxy, which could not reach the image CDN (`Network is unreachable`, errno 101) while covers, which load directly, worked fine at the same moment.
- API requests (the translation endpoint) still use the system proxy.
- A failed request still discards the HTTP client so the retry re-resolves DNS with a fresh connection.

Downloads are below.
