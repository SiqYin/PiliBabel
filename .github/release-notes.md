### PiliBabel v3.3.14

**Smoother playback: audio and video now use multi-connection segmented transfer by default, closer to the official app's "keep buffering ahead while playing, seek instantly" behavior.**

**Problem.** The player used a single TCP connection to pull the stream sequentially. On high-latency links one connection can't saturate the available bandwidth, so the buffer gets drained by playback and you get periodic stalls; seeking to a not-yet-buffered position had to re-pull on that same single connection, taking several seconds — sometimes timing out and triggering a line switch. The official app uses multi-connection segmentation to saturate bandwidth, keeping the buffer ahead of the playhead.

**Fix.** `MediaProxy` (an in-app local proxy that splits one GET into 2–4 concurrent range requests, aborts in-flight upstream connections on seek, and falls back with a 302 to the source on any error) now defaults to **2 connections instead of 0**, and applies to both video and audio.

**Audio wired up.** Audio previously didn't use this proxy at all; it now does. Audio was also missing lavf reconnect parameters (a dropped stream could only be restarted by reopening), which is now fixed.

**Faster reconnect.** `reconnect_delay_max` lowered from 10s to 2s, so a dropped connection no longer means waiting up to 10 seconds.

You can still turn "media multi-connection proxy" off in Settings.

Downloads are below.