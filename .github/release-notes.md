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
