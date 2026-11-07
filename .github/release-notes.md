### PiliBabel v3.7.10

**Re-release of v3.7.9 (right-to-left interface mirroring) — the v3.7.9 build failed in CI's Flutter setup step (infrastructure), so the same content ships as v3.7.10.**

**Right-to-left interface mirroring: when the interface language is written RTL (Arabic, Hebrew, Uyghur and other Arabic/Hebrew-script variants), navigation, lists, alignment and paddings mirror automatically — while images and video content never flip and the player timeline stays left-to-right.**

**Automatic mirroring.** The whole app switches to RTL layout for RTL languages: Flutter mirrors navigation bars, lists, text alignment and paddings. Switching the interface language takes effect immediately.

**Content never flips.** Images, cover art and video are content, not chrome — they are excluded from mirroring. The player (timeline, gestures, controls) is pinned left-to-right, following the universal convention for video playback.

**Direction-aware overlays.** The cover's three-button translate column and duration badges are anchored to the reading side of the card, switching sides in RTL.

Downloads are below.
