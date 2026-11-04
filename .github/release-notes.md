### PiliBabel v3.6.6

**Three fixes: a surname fragment translating as a full name, the glossary page rendering as two unclickable purple labels, and correct glossary names being masked by stale cache.**

**"马斯克" came out as "エラ・マスク".** Name fragments split out of a multi-part name were registered as aliases pointing at the *whole* record, so the fragment `马斯克` (Musk) resolved to the full name of `艾拉·马斯克` (Ella Musk) — every Elon Musk title turned into Ella Musk. Fragments now go through a dedicated table that maps each fragment to the *corresponding fragment* of the translation: `马斯克 → マスク`, `蕾法爱菈 → レファエラ`. A fragment only asserts one part of a name, so this is correct regardless of who the text is about.

The table is built conservatively: a mapping is only created when **every language in the record splits into the same number of parts** (otherwise we do not guess); a spelling that maps to more than one different translation is dropped entirely (e.g. `艾拉` is ambiguous, so it goes to the model); and a spelling that is itself a real entry is dropped so standalone entries always win (`菲欧妮` still resolves through its own record). 137,000 harmful fragment aliases were also cleaned out of the source data.

**The glossary page showed only two purple labels, and nothing was clickable.** That page mistakenly used `SwitchListTile.adaptive` from `flutter/material` inside a bare `Scaffold`, while the rest of the app uses `material_ui` — only its widgets follow the app's light/dark themes and colour palettes. It now uses `SimpleScaffold` with `material_ui`'s `SwitchListTile`, wraps the page in `Obx` so translations refresh as they arrive, and no longer hard-codes the section heading colour.

**"桑多涅" came out as "サンドロネ" instead of the glossary's "サンドローネ".** In 3.6.4 the lookup order was changed to cache-first for performance, which let an earlier wrong model translation permanently shadow the correct official name in the glossary — the cache is keyed by source text and returns on hit, so the glossary never got a chance. Since 3.6.5 removed the expensive substring scan, `_glossaryTranslate` is now a single O(1) lookup, so the original performance rationale no longer applies. The order is back to **glossary before cache**, in both `_tx` and `_txUrgent`.

Downloads are below.
