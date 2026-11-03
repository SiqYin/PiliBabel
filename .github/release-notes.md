### PiliBabel v3.6.5

**Fixes a serious one: a glossary term inside a Chinese paragraph could stop the whole paragraph from being translated. The glossary screen now follows your theme, and the tables are back to being on by default.**

**The translation bug.** Terms found *inside* a sentence used to be substituted in place, and that resulting string was returned as the finished translation. So with a Japanese interface and a Simplified-Chinese paragraph, a single embedded term became Japanese while the rest stayed Chinese — and because that mixed string now contained Japanese, later checks concluded it was already Japanese and never translated it at all. The whole paragraph was left untranslated.

Now an embedded term is no longer substituted. The paragraph goes to the model as normal, and the matched terms are injected into the prompt as forced translations, so the model uses the official names while translating the rest of the sentence properly.

**The glossary screen follows the theme.** It previously used a bare `Scaffold` with untinted switches, so under a dark theme or a custom palette it rendered as a white background with black text and purple buttons — visibly out of place. It now uses the same `SimpleScaffold` + `ViewSafeArea` as the settings pages, and takes every colour from `Theme.of(context).colorScheme`, so it matches your chosen theme and palette.

**Glossary tables are on by default again.** All 15 are enabled out of the box as before; you can still switch off individual works on the glossary page.

**Performance.** The term-injection scan now uses the same first-character bucketing as the in-sentence matcher. Its cost went from scaling with the glossary (54,000 comparisons per string, about a million per batch) to scaling with the text (a few dozen), so a large glossary can no longer make translation slow or crash the app.

Downloads are below.
