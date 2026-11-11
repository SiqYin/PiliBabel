### PiliBabel v3.8.9

**A full audit sweep: the two auto-translate switches now really work, translation caches are language-aware, and danmaku translation is faster.**

**The auto-translate switches are now complete.** In 3.8.8 they only stopped the background pre-translation on video open — the player could still start a live subtitle translation, loaded danmaku segments were still batch-translated, and the background kept pre-translating the next few videos. Switching either one off now stops **every** automatic translation of that kind. Manual actions (the subtitle/danmaku buttons, retry, picking a track) always work regardless of the switch.

**Caches are language-aware.** The reverse search cache is now split per language and persisted with a language tag, so changing language and restarting the app can no longer reuse a stale "translated word → Chinese original" mapping. A reverse index replaces the full-cache linear scan (O(n) → O(1)), all cache writes go through one helper that maintains that index, and each language bucket is capped at 5,000 entries so the persisted table cannot grow forever.

**Danmaku and subtitles.** Switching translation engines now recomputes the danmaku default; the AI subtitle track is found by content instead of a hard-coded index; in-flight danmaku text swapping is coalesced to one scan per frame; and the 15-second prediction window is pre-translated in one batch instead of one line at a time. Failed translation batches are retried once, and truncated model output is counted and logged.

**Tooling and docs.** The README consistency check now validates the "languages outside the official list" count in all 44 languages (five different numeral systems) — and the English master README, which had never actually been checked, is now part of the check. Old release notes are archived automatically. The glossary manifest check uses the app's own HTTP stack with cancellation, and its trust boundary is documented. 30 suspected empty `Obx` blocks were reviewed one by one and all turned out to be false positives (GetX Rx accessors register the subscription indirectly).

Full item-by-item list: `glossary/AUDIT-DEEP-3.8.8-2026-11-11.md`, Appendix D.

### PiliBabel v3.8.8

**The language search box works again, and auto-translating subtitles and danmaku is now your call.**

**The search box was dead.** It had been broken since 3.8.2: the listener updated the query but never triggered a rebuild, so the list was never filtered — typing did nothing, and pressing Enter did nothing either. That release's notes even claimed "results appear as you type, no Enter needed". The search field now lives in its own component that owns its state, so **the list filters as you type**, including while an IME is still composing.

**Two new switches, both on by default.** Opening a video no longer has to mean the app starts translating in the background on its own:

- **Auto-translate subtitles** — pre-translate subtitles in the background when a video opens. Turn it off and the automatic pass stops; the translate button on the cover still works exactly as before.
- **Auto-translate danmaku** — same for danmaku. Danmaku you open yourself are still translated as usual.

Both labels are translated like every other string in the app, and are pre-warmed with the rest of the settings copy.

**Tâi-gí moved.** The POJ-only Taiwanese Hokkien entry now sits right between "mainland Hokkien" and the Han-script Taiwanese entry, so it reads as the same language family in a different script — and it carries the same "outside the official list · consider your own API" note as the other extra languages.

**A test now guards the list.** The picker renders exactly the full language inventory (158 entries: bilibili's 151 plus our 7), and a regression test keeps it that way.

### PiliBabel v3.8.7

**The AI translation language list gains Tâi-gí — Taiwanese Hokkien written purely in POJ.**

Tâi-gí is the same language as the existing Taiwanese Hokkien entry, but in a different writing system: it uses only Pe̍h-ōe-jī (POJ) romanisation — Latin letters, tone marks, hyphens and punctuation — and **not a single Han character**. The prompt says that outright: no Han-and-roman mixing, no Han supplied in brackets, and proper nouns are respelled from their Hokkien reading rather than left in Chinese.

Because a stray Han character means the text was simply not translated, this target is deliberately **not** treated as a Chinese-family language: Han characters in a subtitle translation are rejected and the chunk retried — the exact opposite of the Han-script Taiwanese entry, whose output is allowed to contain them.

It sits with the other languages outside bilibili's official inventory, is marked as such, and can be found by searching `tâi-gí`, `tai-gi`, `taigi`, `Taiwanese`, `POJ`, `白话字` or `閩南語`.
