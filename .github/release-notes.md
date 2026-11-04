### PiliBabel v3.6.7

**Fixes "14/15 glossary tables enabled" showing even with all switches on, and audits every per-table count.**

**The 14/15 bug.** When v3.6.4 introduced "off by default", the migration wrote *every* embedded id prefix into the disabled set — including `game`, the prefix of the 8 game-title entries (`game|zzz`, `game|hsr`, …). The glossary screen only renders the 15 tables that appear in the manifest and has no switch for `game`, so turning all 15 switches on still left `game` stuck in the disabled set, and the counter (`tables − disabled.count`) sat permanently at 14/15. Worse, those 8 game-name rows (the short names like ゼンゼロ / スタレ) were silently disabled at runtime too.

Now the count no longer subtracts: it walks the manifest tables and checks each against the disabled set, shared by both the settings tile and the glossary page. `game` is always treated as enabled (it has no switch), and the page sanitises legacy leftovers from the stored set on load, so affected installs heal themselves.

**Per-table counts, audited one by one:**
- *Reverse: 1999* displayed **0 terms**: all 100 rows had their category reverted to `term` by an earlier rebuild and were excluded from embedding. Fixed — 100/100 now embedded.
- *BanG Dream!* was 3 rows short and *Neverness to Everness* 1 short: band and organisation names (CRYCHIC, sumimi, Glitter☆Green, 环) were filtered out by the category whitelist. They are exactly the proper nouns that appear in titles, so the whitelist now includes them; both tables match their harvested totals.
- Template residue scrubbed from values (`37}}`, `{{rubi`, a key containing a newline, 69 rows with `{{tt` tails) so junk can never surface as a translation.

Where a table embeds fewer terms than it was harvested with (Genshin Impact, Honkai: Star Rail, Zenless Zone Zero, Wuthering Waves), that is by design — only the core subset ships in-app. The subtitle now reads "N terms embedded" instead of "N terms", so the number matches what it actually measures.

Embedded terms: 11,637 → **11,741**.

Downloads are below.
