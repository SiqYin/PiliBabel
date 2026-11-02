### PiliBabel v3.5.5

**Added: AI translation for the search page's trending keywords.**

- The two section titles - `大家都在搜` and `搜索发现` - were hard-coded Chinese; they now
  follow the app language.
- The trending keywords themselves are translated, as is the recommendation reason some
  entries carry (`recommend_reason`). Tapping an entry still searches the **original**
  keyword, so the translated display never changes the query.
- The same applies to the full ranking page (`完整榜单` / bilibili 热搜).
- The little badges next to entries are **not** translated, because they are images:
  `直播中` is a bundled animation (`assets/images/live/live.gif`), and `新` / `独家` / `梗`
  and friends are server-provided icon images (the `icon` field). Text baked into an image
  can't be swapped by text translation.
- All three spots are wrapped in `Obx`, so translations show up as soon as they come back
  instead of requiring a page reload.

中文摘要：本版把搜索页的热搜接入了 AI 翻译——「大家都在搜」「搜索发现」两个标题、热搜
条目的关键词、部分条目右侧的推荐理由，以及「完整榜单」页的榜单条目都会跟随界面语言；
点进去搜索仍然使用原文关键词。条目后面的小标签（「直播中」是内置动图，「新 / 独家 / 梗」
是服务端下发的图标图片）是图片，没有接翻译。三处都包了 `Obx`，译文回来后自动刷新。
