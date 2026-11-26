### PiliBabel v3.10.0

**A large upstream sync from PiliPlus 2.2.1 / PiliNara (stages 1–4), plus a batch of download, playback and account fixes.**

- **Player / danmaku**: on/off switch and pause banner for personal danmaku filters, with loaded-rule restore; danmaku-density progress for cached videos; threaded comments (simplified indentation/collapse); dynamic `fold_action` “read more” links and a unified `ArticleType` article entry.
- **Content pages**: commenter-name keyword filtering, reverse article lists, simplified `parseRedirectUrl`, and a fix for first-time channel/title blocking on empty lists.
- **Download / offline**: offline volume normalization (save, update, read on playback), download queue refresh after a quality change, empty-DASH protection, and volume data in download entries.
- **Live**: viewing trace reports; a fans-medal management page (`/fansMedal`, entry in the profile menu); automatic wearing of the room’s fans medal (off by default, with the `lookupV2` fix); `UinfoMedal` equality.
- **Account / network**: anonymous buvid fetch fix; mpris switched to the upstream fork; updated Material patches; a hand-added `ParentReplyMember` proto field; the revamped floating bottom bar; a show/hide switch for the intro cache button.
- **Compatibility notes**: fans-medal management is landed in a compatible way — the controller was not split into mixins and `live_dm_block` was not migrated; threaded comments use a simplified implementation instead of upstream’s indentation/collapse widgets; stage 5 (fullscreen layout editor / pane ratio) is not included in this release.
- **Verification**: `flutter analyze` reports 0 errors, the full `flutter test` suite passes 192/192, and `verify_readmes.py` reports 44/44 READMEs at 3.10.0.

### PiliBabel v3.9.10

**Two player and desktop fixes — both found and reported by @masktao (#7, #8). Thank you!**

**The player's time readout was too small and could not be adjusted (#7).** The current position and the total duration were drawn at a hard-coded 10px, so changing the app's font size (Settings → Font → Size) had no effect on them and there was nowhere else to adjust them. The baseline is now 12px, and it scales with that setting — the position and duration grow and shrink together with the rest of the interface.

**A borderless window could not be moved (#8).** Once “Show window title bar” was turned off there was no system title bar left to grab, so the window stayed stuck in place (the only way out was to open Settings again). A transparent strip along the top edge now moves the window when dragged and maximizes or restores it on a double-click; in in-app fullscreen (right-click the video) or desktop picture-in-picture, the picture itself can also be dragged to move the window.

Verification: `flutter analyze` reports 0 errors, the full `flutter test` suite passes 192/192, and `verify_readmes.py` reports 44/44 READMEs at 3.9.10. The drag gestures and the new time size have not been verified on a physical desktop yet.

### PiliBabel v3.9.9

**Listening mode no longer waits on the video — it is a fallback for exactly the case where the video will not load.**

The “listen only” page used to open whatever audio URL the video page happened to have. When the video could not load, that URL was either missing or a link that the current network could not pull — so the fallback died the same way the video did. The page now always fetches its own stream and starts playing the moment the audio is ready; nothing about the video's loading state is inherited.

Entering the page also **voids the video side outright**: the stream request still in flight is discarded (it is re-fetched when you come back), subtitle jobs are stopped (this page has no subtitles to load), and a player stuck in “loading” has its media unloaded so the whole connection is handed to the audio. Videos that were already playing are left paused instead, and resume instantly on return.

If a line refuses to start, the next candidate address from the same response is tried, and after all of them are exhausted the stream is re-requested (up to twice). A ten-second watchdog decides a line is dead rather than leaving you staring at two frozen 00:00s, and the progress row now says “loading audio” / “switching to a backup line” / “re-fetching the stream” while it happens.

Two smaller things: a failed player creation no longer leaves the page permanently dead (it can retry), and both audio download entries can now build their request from this page's own playlist item, so they work even when the video page's details never arrived.
