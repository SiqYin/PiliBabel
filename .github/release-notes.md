### PiliBabel v3.3.9

**This is an update-check test release. No app code or content changed from v3.3.8.**

This version is published on purpose so that installing it on a device running an older build will let you verify whether the update prompt appears: with v3.3.9 installed, the app should find this newer v3.3.9 release (or a newer one once it exists) and show the update dialog.

Why the update prompt was being missed, and what v3.3.8 fixed:

- The old check ran once, over a single request, and silently swallowed any failure — if that one request hit a transient network/proxy hiccup at startup, the update prompt would never appear for the whole session.
- v3.3.8 changed the check to race the main link against a direct connection (whichever returns data first) and retry with backoff (500 ms / 2000 ms / 4500 ms), so a momentary blip no longer hides an available update.

v3.3.9 keeps that behavior exactly — only the version number and release notes differ from v3.3.8.

If you are already on v3.3.8, this test build intentionally will not change anything in the app; it exists so an older install can confirm it detects and prompts for the new v3.3.9 (or newer) release.

Downloads are below.