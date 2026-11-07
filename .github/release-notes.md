### PiliBabel v3.8.0

**Danmaku now switch from Chinese to their translation in place: a bullet comment that went out before its translation was ready flips to the translated text automatically the moment the translation lands — no replay, no restart. Plus: the three cover buttons become a horizontal row, and the first-launch intro describes them left/middle/right.**

**In-place danmaku swap.** The canvas_danmaku renderer is now vendored into the repo, letting a flying danmaku item replace its content mid-flight (paragraph rebuilt, flight path and timing untouched). The player scans live items whenever the translation cache updates and swaps any item still showing its Chinese source.

**Horizontal cover buttons.** The three buttons (cover, subtitles, danmaku) are now laid out left-to-right at the cover's bottom-left corner, with the grow/settle and push-aside animation adapted to the row; RTL languages mirror the row.

**Intro updated.** The first-launch popup now describes the buttons as left (cover translation), middle (subtitles) and right (danmaku).

**Icon refresh.** The green legacy castle badge shown on "submitted a video/article" entries in the feed (and the save panel) now uses the current black-blue gradient PiliBabel icon; the unused legacy asset was removed.

**Tablet landscape fix.** The left navigation drawer's width is now recomputed reactively as translations land — long translated labels (e.g. タイムライン) no longer overflow the selection pill.

Downloads are below.
