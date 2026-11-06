### PiliBabel v3.7.0

**HiRes badge, audio player seek fixes, and video playback audio/progress recovery.**

**HiRes badge.** A "HiRes" indicator now appears in the player's bottom control bar between the episode list and aspect-ratio buttons. It turns from grey to the theme color when the current audio track is Hi-Res lossless.

**Audio player seek fix.** Dragging the progress bar no longer triggers premature auto-advance or unexpected pausing. The `completed` event is now ignored during drag operations.

**Audio player re-entry fix.** Exiting and re-entering the audio-only player now correctly initializes the player, fixing the "00:00 and can't play" issue caused by the initialization flag not being reset.

**Video playback audio recovery.** Added automatic audio track loss detection: when video is playing but audio silently drops (DASH EDL audio stream failure), the player performs a lossless reopen to restore audio. Combined with the progress bar seek fix below.

**Video progress bar seek fix.** Seeking during playback no longer causes the progress bar to flash to the far right or flicker wildly. The `completed` event and position updates are now properly guarded during seek operations.

Downloads are below.
