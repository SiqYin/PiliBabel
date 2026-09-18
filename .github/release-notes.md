### PiliBabel

AI interface & content translation layered on top of **PiliNara / PiliPlus** — the whole app speaks your language.

**Install (Android)**
Download `PiliBabel.apk` below, allow “install unknown apps”, and open it. This initial preview is signed with a **debug key**, so it can be installed **alongside PiliNara**.

**What's new in this release**
- AI interface & content translation with **translate-once + local persistence** — never re-translated on reopen.
- ~35 target languages via **your own** OpenAI-compatible endpoint; the translation endpoint is fully **independent** from AI video summary.
- With a Chinese target, only foreign→Chinese is translated; a non-Chinese target renders the **entire** UI.
- Per-comment **Original ⇄ Translation** toggle; hyperlinks are preserved and stay clickable.
- **Danmaku translation** — an independent player toggle that pre-translates ahead of the playhead in ~15-second batches.
- **Thinking-mode** switch, **test-translate**, and a batched/concurrent pipeline (≤ 40 strings/batch, ≤ 8 concurrent).

**Fork lineage**: PiliBabel → PiliNara → PiliPlus → PiliPala. GPL-3.0, same as upstream.

> Unofficial third-party client, not affiliated with or endorsed by bilibili. For learning & testing; please delete within 24 hours of download.
