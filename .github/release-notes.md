### PiliBabel v3.7.7

**The cover buttons become a three-button column — danmaku, subtitles, cover — with uniform size states, smooth layout shifts, real progress on the cover ring, a dedicated danmaku button, and uploader names always in full glossary form.**

**Three-button column.** The cover now stacks three buttons top-to-bottom: danmaku, subtitles, cover translation. Every button is small at rest (13px icon), grows while loading (17px progress ring) and settles back to a small green checkmark when done. Whenever one button grows, the ones above it slide up smoothly to keep the edges from overlapping — any combination of the three loading at once stays clean.

**Danmaku pre-translation button.** Tapping the new top button fetches every 6-minute danmaku segment of the video up front and batch-translates all of it into the persistent cache; a green checkmark means entering the player shows bullet comments already translated. Completion state survives app restarts.

**Cover ring, real progress.** The cover translation ring now shows the actual download progress of the cover image (0–55%), then eases toward 95% while the vision model thinks, and completes the moment the result dialog opens — with the same green checkmark as the other two buttons.

**Full names for uploaders.** Uploader names always use the full glossary form now, while titles and comments keep the community short forms. スターレイル also gained its standalone short form スタレ (previously only the prefixed 崩壊:スターレイル was in the glossary, so the bare form never matched at all).

Downloads are below.
