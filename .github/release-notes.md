### PiliBabel v3.6.2

**Glossary overhaul: short forms and name fragments now resolve, terms inside sentences match, four new games, consistent word formation for grouped labels, and pre-translated dialogs on sub-screens.**

**Short names and every name fragment now resolve** — this was the real cause of "Phoenix still comes out wrong in Japanese". The glossary used to store exactly one standard name per language, while titles and comments use short forms. The harvester did collect aliases, but the generator silently dropped them. Full names are now split into **every fragment**: `菲欧妮・蕾法爱菈` → `菲欧妮` + `蕾法爱菈` + the full name, likewise for `フィオニー・レファエラ` and `Phoenix Reffaella`. 12,280 aliases ship (ambiguous common words are filtered out to avoid false hits).

**Terms inside sentences match too.** Previously the whole string had to equal a term, so titles like "【绝区零】菲欧妮实战演示" never matched and went straight to the model. It now tries exact match first, then scans the sentence for known terms (longest form first) and substitutes them.

**Four new games.** Umamusume (321 entries), BanG Dream! (101 — MyGO and Ave Mujica are bands inside that game, so one source covers them), Reverse: 1999 (100) and Neverness to Everness (25).

**Grouped labels share one word-formation pattern.** Chinese "缓存视频 / 缓存音频" is "action + object", so the translation must be structurally identical. The model used to mix "動画をキャッシュ" (verb + object) with "キャッシュ音響" (noun compound); the whole group is now pinned to the noun-compound form, and the prompt rule was rewritten into something checkable.

**Dialogs on sub-screens are pre-translated.** Opening the offline-cache, settings or "Mine" hubs now queues the menu items and confirm dialogs that only appear on tap (maintained in a new `PrewarmStrings` file), so they are already translated when the user opens them.

The Zenless Zone Zero table also went from 2,907 rows (634 empty placeholders) to **4,965 rows at 99.8% coverage in four languages**.

Downloads are below.
