### PiliBabel v3.10.5

**Fullscreen layout danmaku-count control.**

- **Danmaku count**: the fullscreen player layout editor now offers a "danmaku count" control; when enabled, the video header shows the current part's danmaku total next to the watcher count. It reuses `DanmakuDensityTrend.fetchAll`, cached per part and refreshed (with cancellation) when entering or switching parts.
- **Verification**: `flutter analyze` reports 0 errors, the full `flutter test` suite passes 192/192, and `verify_readmes.py` reports 44/44 READMEs at 3.10.5.

### PiliBabel v3.10.4

**Live-controller mixin refactor and AI-translation coverage for new UI text.**

- **Live controller refactor**: `live_room/controller.dart` is split into eleven `controller_mixin` modules (`data`/`block`/`time`/`size`/`like`/`sc`/`dm`/`dm_stream`/`dm_trim`/`trace`/`medal`); the file shrinks from ~1330 to 554 lines with no behavior change.
- **UI translation**: newly added text across 9 pages/widgets (fans medal, threaded reply indent, fullscreen layout editor, player control face, dynamics rich-node panel, etc.) now goes through `uiTx`/`uiTxP`.
- **Verification**: `flutter analyze` reports 0 errors, the full `flutter test` suite passes 192/192, and `verify_readmes.py` reports 44/44 READMEs at 3.10.4.