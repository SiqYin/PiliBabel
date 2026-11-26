### PiliBabel v3.10.1

**Player layout editing, draggable split ratio, and portrait/macOS fixes.**

- **Fullscreen player layout editing**: controls can be dragged between the header/actions/bottom/left/right regions, hidden, and saved; the layout is restored per orientation. Edit it from the player’s “…” sheet.
- **Video page split ratio**: a draggable divider and a “Page ratio” entry let you resize the video and side panels; the ratio is persisted.
- **Portrait editor fixes**: safe-area handling, preview width (460), and hidden back-home/battery/clock items in the layout editor’s portrait preview.
- **macOS double-click fullscreen**: fullscreen now switches after the double tap is confirmed (Windows/Linux unchanged).
- **Download panel UI and dynamic fold_action**: synced the padding/connectivity layout and the fold_action finishing touches from upstream.
- **Compatibility/defaults**: the new layout remains compatible with the old lock/screenshot/battery/online switches; `dmCount` is not offered because this build has no danmaku-count statistic.
- **Verification**: `flutter analyze` reports 0 errors, the full `flutter test` suite passes 192/192, and `verify_readmes.py` reports 44/44 READMEs at 3.10.1.

### PiliBabel v3.10.0

**A large upstream sync from PiliPlus 2.2.1 / PiliNara (stages 1–4), plus a batch of download, playback and account fixes.**

- **Player / danmaku**: on/off switch and pause banner for personal danmaku filters, with loaded-rule restore; danmaku-density progress for cached videos; threaded comments (simplified indentation/collapse); dynamic `fold_action` “read more” links and a unified `ArticleType` article entry.
- **Content pages**: commenter-name keyword filtering, reverse article lists, simplified `parseRedirectUrl`, and a fix for first-time channel/title blocking on empty lists.
- **Download / offline**: offline volume normalization (save, update, read on playback), download queue refresh after a quality change, empty-DASH protection, and volume data in download entries.
- **Live**: viewing trace reports; a fans-medal management page (`/fansMedal`, entry in the profile menu); automatic wearing of the room’s fans medal (off by default, with the `lookupV2` fix); `UinfoMedal` equality.
- **Account / network**: anonymous buvid fetch fix; mpris switched to the upstream fork; updated Material patches; a hand-added `ParentReplyMember` proto field; the revamped floating bottom bar; a show/hide switch for the intro cache button.
- **Compatibility notes**: fans-medal management is landed in a compatible way — the controller was not split into mixins and `live_dm_block` was not migrated; threaded comments use a simplified implementation instead of upstream’s indentation/collapse widgets; stage 5 (fullscreen layout editor / pane ratio) is not included in this release.
- **Verification**: `flutter analyze` reports 0 errors, the full `flutter test` suite passes 192/192, and `verify_readmes.py` reports 44/44 READMEs at 3.10.0.