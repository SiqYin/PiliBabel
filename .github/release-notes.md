### PiliBabel v3.8.11

**The HiRes badge now means what it says: it only appears on videos that actually offer Hi-Res audio.**

Bilibili ships the Hi-Res track inside the DASH response, and the badge has checked for it since 3.8.6 — but that check read the playback data through a plain getter. The playback data is replaced whenever you change episode or open another video from the related list, and the getter was not observable, so the badge's `Obx` only ever subscribed to the current audio quality. Two consecutive videos very often land on the same quality level, so nothing changed, nothing rebuilt, and the badge simply kept the previous video's verdict: watch something with Hi-Res, then open a video without it, and the badge stayed on — dim, tappable, and doing nothing.

The availability flag is now a reactive state of its own, re-evaluated the moment a new playurl arrives and again when the badge is tapped, so it always describes the video that is on screen. A video whose audio-quality list has no Hi-Res entry gets no badge at all; a video that has one gets the badge as a toggle — lit while Hi-Res is playing, dim while it is not.
