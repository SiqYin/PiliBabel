### PiliBabel v3.10.3

**Upstream sync completion: threaded comments, article ordering, proto updates and live migration.**

- **Threaded comments**: `ReplyThreadedIndentBox`, collapse/expand, and a foldable comment list driven by `FoldCard`/`FoldList`; `ReplyItemGrpc` gained depth/reason/collapsed/toggle/scroll-left parameters.
- **Article ordering**: article body supports reverse ordering via `SliverListReverse` in `ArticleOpus`/`OpusContent`; all 19 `/articlePage` entries now go through `PageUtils.toArticlePage`.
- **Proto / model**: `ReplyInfo` aligned with upstream f521 (fixing the tag-18 conflict), added `HotReplyInfo`, `HotspotCard`, `MixedCard.hotspot`, `FoldCard`/`FoldList`; `live_dm_block` migrated to `live_info_by_user`.
- **Live / shell**: live danmaku-filter management card with an enable switch; live trace start/stop service; `main` ESC back now uses `maybePop`.
- **Not included**: full 11-mixin live-controller split, `dmCount` (no danmaku-count statistic in this build), 68fb reduce-rebuilds (explicitly deferred), and upstream scaffold/tabs patches (require a newer material_ui dependency).
- **Verification**: `flutter analyze` reports 0 errors, the full `flutter test` suite passes 192/192, and `verify_readmes.py` reports 44/44 READMEs at 3.10.3.

### PiliBabel v3.10.2

**UI translation fixes for the “Likes received” page.**

- **Home → Messages → Likes received**: the “Latest”/“All” headers, “liked my danmaku/comment/video”, the liker’s nickname, my comment/danmaku content and the video title now go through the translation pipeline.
- **Like details page**: the business/title line, the liker nickname and “liked me” now translate as well.
- **Verification**: `flutter analyze` reports 0 errors, the full `flutter test` suite passes 192/192, and `verify_readmes.py` reports 44/44 READMEs at 3.10.2.