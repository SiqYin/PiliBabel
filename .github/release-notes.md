### PiliBabel v3.9.5

**Every search box now works with Simplified and Traditional Chinese alike.**

Type either script, and the keyword is automatically searched in both script forms and the results are merged — 歷史 finds 历史 content and the other way around. Characters with several legitimate traditional forms (發/髮, 幹/乾, 臺/檯/颱) additionally get single-character substitute searches, so titles like 頭髮 or 乾隆 are not missed. The conversion table is generated from OpenCC's per-character dictionaries (Apache-2.0) and stays at the glyph level — vocabulary differences like 软件/軟體 are out of scope.

**Search boxes that still bypassed the AI keyword translation are now wired in.** Live search, UP-space search (videos and posts), in-video comment search, dynamic topic search and @mention search used to query the raw input directly; they now run through the same UI-language → Simplified-Chinese keyword resolution as the main search, plus the script variants. The three local filter boxes — download list, music video list, and settings search — match against the original titles with glyph folding, so typing the translated title you see on screen still finds the entry.

**Traditional input is no longer sent through the AI as if it were a foreign language.** It is recognized as Chinese-source text and searched directly; the simplified↔traditional bridge is deterministic glyph conversion, not a model call. The language picker's search folds script forms the same way.

Everything else is unchanged: suggestions, hot keywords, search history, and pagination follow the same behavior as before; the extra variant searches only apply to the first page and are merged with per-item de-duplication.
