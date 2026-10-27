### PiliBabel v3.3.11

Fixes the image-loading regressions that have shown up in every build since v3.3.0: on the homepage feed and in the dynamics feed (dynamics photos, emoji, and uploader avatars), many images failed to appear until you pulled-to-refresh — and some stayed grey even after refreshing. v3.0.5 had no such behavior.

**1. Image transport reverted to the v3.0.5 connection layer.** The earlier "unified image pipeline" change funneled all image downloads through one shared client capped at **6 concurrent connections per host** (the main data path allows 16, and v3.0.5 images had no such cap). On the first screen load, dozens of covers competing for a 6-slot pool would saturate it; requests that couldn't grab a connection within the 10s connect timeout fell back to a grey placeholder that never retried — only a manual pull-to-refresh (which rebuilt the widget) would reload them. That shared cap is now removed, restoring the v3.0.5 library-default connection parallelism so first-screen images load like they used to. The browser UA / Referer and DNS resolution keep being applied by the global HTTP overrides.

**2.** (No other changes in this build — this is a focused regression fix.)

Downloads are below.