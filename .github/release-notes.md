### PiliBabel v3.6.3

**Fixes the lag when AI translation is on, turns the glossary into a page with per-table switches, adds hololive / NIJISANJI / THE iDOLM@STER, and fills every table in five languages.**

**Fixed the lag (important).** With AI translation on, the UI felt sluggish; turning it off made it smooth again. The cause: every translation lookup ran a glossary search first, and on a miss that degraded into scanning 50,000+ term forms by substring — once per widget per frame. Now the translation cache is consulted first, the substring scan only runs on short strings (≤80 chars), and terms are bucketed by their first character: measured comparisons drop from 53,953 to 18–323 per title, i.e. 167–2,997× fewer.

**The glossary is now its own page.** The settings entry is renamed to "术语集" (Glossary) and opens a dedicated page that lists all 15 tables under two sections — games and franchises — each with its own switch, **all enabled by default**. You can turn off a game you don't play so its proper nouns are not applied to unrelated contexts.

**Three new tables:** hololive (83 talents), NIJISANJI (239 livers) and THE iDOLM@STER (282 characters).

**All 15 tables now cover five languages** (Simplified Chinese, Traditional Chinese, English, Japanese, Korean) with no gaps in the 769 newly added records. 1,236 of those values were filled in from community-standard names and are tagged with their provenance so they can be reviewed later.

**Fixed "Check for updates" always failing.** The manifest URL pointed at a `glossary` branch that never existed, so it always returned 404. It now ships with the main branch at `docs/glossary-manifest.json`.

**Fixed two untranslated strings:** the description under "Audio track follows UI language" and the note under the app-language selector. They did call the translation helper, but were not wrapped in the reactive `Obx` that rebuilds when a translation arrives, so they stayed Chinese forever.

Also repaired 36 BanG Dream rows whose Japanese name was the literal `{{ruby` — leftover template fragments from an earlier parse.

Downloads are below.
