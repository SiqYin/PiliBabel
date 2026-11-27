### PiliBabel v3.10.2

**UI translation fixes for the “Likes received” page.**

- **Home → Messages → Likes received**: the “Latest”/“All” headers, “liked my danmaku/comment/video”, the liker’s nickname, my comment/danmaku content and the video title now go through the translation pipeline.
- **Like details page**: the business/title line, the liker nickname and “liked me” now translate as well.
- **Verification**: `flutter analyze` reports 0 errors, the full `flutter test` suite passes 192/192, and `verify_readmes.py` reports 44/44 READMEs at 3.10.2.

### PiliBabel v3.10.1

**Player layout editing, draggable split ratio, and portrait/macOS fixes.**

- **Fullscreen player layout editing**: controls can be dragged between the header/actions/bottom/left/right regions, hidden, and saved; the layout is restored per orientation. Edit it from the player’s “…” sheet.
- **Video page split ratio**: a draggable divider and a “Page ratio” entry let you resize the video and side panels; the ratio is persisted.
- **Portrait editor fixes**: safe-area handling, preview width (460), and hidden back-home/battery/clock items in the layout editor’s portrait preview.
- **macOS double-click fullscreen**: fullscreen now switches after the double tap is confirmed (Windows/Linux unchanged).
- **Download panel UI and dynamic fold_action**: synced the padding/connectivity layout and the fold_action finishing touches from upstream.
- **Compatibility/defaults**: the new layout remains compatible with the old lock/screenshot/battery/online switches; `dmCount` is not offered because this build has no danmaku-count statistic.
- **Verification**: `flutter analyze` reports 0 errors, the full `flutter test` suite passes 192/192, and `verify_readmes.py` reports 44/44 READMEs at 3.10.1.