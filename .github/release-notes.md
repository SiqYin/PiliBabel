### PiliBabel v3.10.4

**Live-controller mixin refactor and AI-translation coverage for new UI text.**

- **Live controller refactor**: `live_room/controller.dart` is split into eleven `controller_mixin` modules (`data`/`block`/`time`/`size`/`like`/`sc`/`dm`/`dm_stream`/`dm_trim`/`trace`/`medal`); the file shrinks from ~1330 to 554 lines with no behavior change.
- **UI translation**: newly added text across 9 pages/widgets (fans medal, threaded reply indent, fullscreen layout editor, player control face, dynamics rich-node panel, etc.) now goes through `uiTx`/`uiTxP`.
- **Verification**: `flutter analyze` reports 0 errors, the full `flutter test` suite passes 192/192, and `verify_readmes.py` reports 44/44 READMEs at 3.10.4.

### PiliBabel v3.10.3

**Upstream sync completion: threaded comments, article ordering, proto updates and live migration.**

- **Threaded comments**: `ReplyThreadedIndentBox`, collapse/expand, and a foldable comment list driven by `FoldCard`/`FoldList`; `ReplyItemGrpc` gained depth/reason/collapsed/toggle/scroll-left parameters.
- **Article ordering**: article body supports reverse ordering via `SliverListReverse` in `ArticleOpus`/`OpusContent`; all 19 `/articlePage` entries now go through `PageUtils.toArticlePage`.
- **Proto / model**: `ReplyInfo` aligned with upstream f521 (fixing the tag-18 conflict), added `HotReplyInfo`, `HotspotCard`, `MixedCard.hotspot`, `FoldCard`/`FoldList`; `live_dm_block` migrated to `live_info_by_user`.
- **Live / shell**: live danmaku-filter management card with an enable switch; live trace start/stop service; `main` ESC back now uses `maybePop`.
- **Not included**: `dmCount` (no danmaku-count statistic in this build), 68fb reduce-rebuilds (explicitly deferred), and upstream scaffold/tabs patches (require a newer material_ui dependency).
- **Verification**: `flutter analyze` reports 0 errors, the full `flutter test` suite passes 192/192, and `verify_readmes.py` reports 44/44 READMEs at 3.10.3.