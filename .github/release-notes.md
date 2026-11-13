### PiliBabel v3.9.3

**The built-in glossary nearly doubles — and 异环 finally has a name.**

The glossary tables were being cut down by two whitelists in the generator: a category filter and a second per-kind filter. Whole categories that had already been harvested — items, concepts, creatures, enemies, locations, materials — never reached the app. The result was 6,301 harvested Star Rail entries and only 368 shipped; 4,963 ZZZ and 303 shipped; 1,443 Wuthering Waves and 223.

Both filters are gone. The glossary now carries **19,482 entries** (up from 11,742):

| Table | Before | After |
|---|---|---|
| Genshin | 3,246 | 5,788 |
| Honkai: Star Rail | 368 | 2,823 |
| Zenless Zone Zero | 303 | 1,815 |
| Wuthering Waves | 223 | 1,443 |

**Game titles for all fifteen tables.** Title entries only ever came from a schema listing eight games, so 异环, Umamusume, BanG Dream!, Reverse: 1999, hololive, NIJISANJI and THE iDOLM@STER had no entry of their own — which is why 异环 was translated literally into Japanese instead of **NTE**. All seven are in now, and every one of them gets the same full-form / short-form treatment as the older tables (NTE, Umamusume/ウマ娘, Bandori/バンドリ, R1999/リバース, iM@S/アイマス, ホロ).

**New entries:** 丹妮卡 (Genshin 7.2), 浔 / 娜娜莉 (异环), plus 4.7's 阿哈 and 1.5's 曳尔沐 / Exe were already covered.

Index building is unchanged: one lazy pass, warmed 1.5 s after startup, O(1) lookups. Translation speed is still bound by the network round-trip, not by table size.
