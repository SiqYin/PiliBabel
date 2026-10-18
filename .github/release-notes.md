### PiliBabel v2.3.3

Fixes an intermittent "image download failed" error in image translation.

- Image translation now uses one shared HTTP client that honours the app's proxy settings and is rebuilt when the network changes. Previously each request created a bare `Dio()` that ignored the configured proxy and was never reset, so after a network switch or proxy reconnect it could keep failing with `SocketException: No route to host` (errno 113) until the app was restarted.
- Image downloads now set a connect timeout.
- Image downloads now retry each candidate URL once before giving up.

Downloads are below.
