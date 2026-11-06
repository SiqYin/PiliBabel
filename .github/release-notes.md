### PiliBabel v3.6.9

**Polish: subtitle button sizing, first-run auto-setup, segment info translation, audio track language sync, and toast translation fixes.**

**Subtitle button sizing.** The AI subtitle translation button on video card covers now matches the height of the cover translate button for a cleaner, more uniform look.

**First-run auto-setup.** New installs now automatically detect the system language and enable AI translation — no dialog, no manual setup. A guided animation walks through the settings page, then a simple confirmation dialog appears. This runs only on fresh installs; updates and existing users are unaffected.

**Segment info translation.** The segment name shown in the player's bottom control bar (when tapping the screen) is now translated consistently with the segment labels on the progress bar.

**Audio track language sync.** When the interface language changes, reopening a video now correctly re-evaluates which audio track to select. Previously the audio track was cached per-video and didn't follow language changes.

**Toast translation fixes.** Action feedback messages (like, coin, favorite, follow, pin, subscribe, mute, etc.) are now properly routed through the translation system. Server response messages are also translated. Added 16 new entries to the pre-translation list for instant display.

> **Acknowledgement:** The subtitle translation system was originally contributed by [saukhoai](https://github.com/saukhoai) via [PR #2](https://github.com/SiqYin/PiliBabel/pull/2).

Downloads are below.
