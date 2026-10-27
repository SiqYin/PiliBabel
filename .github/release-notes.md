### PiliBabel v3.3.12

**Emergency fix for a severe regression introduced in v3.3.11:** the home feed, dynamics feed, "My Favourites", and watch history failed to load any data at all.

**Root cause.** v3.3.11 removed the concurrency cap on the image pipeline. Since v3.3.0, every `HttpClient` is routed by global `HttpOverrides` to the app's local DNS-resolver proxy (a 127.0.0.1 CONNECT tunnel). With the cap gone, the first screen load fired hundreds/thousands of image tunnels at once, overwhelming that local proxy's sockets and event loop — which starved the **API data requests that share the same proxy**. So not only images but the entire data layer went down. The previous "6 connections per host" cap had in fact been protecting the proxy all along.

**Fix.** The image client now explicitly sets `findProxy = DIRECT`, bypassing the local resolver proxy and connecting directly (image domains are fine with system DNS; they don't need self-resolution). The proxy is left exclusively for data requests. The per-host concurrency cap is raised from 6 to 32 — close to v3.0.5's image parallelism — so covers no longer need a pull-to-refresh, without dragging the proxy down again.

Downloads are below.