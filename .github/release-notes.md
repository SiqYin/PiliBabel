### PiliBabel v3.6.5

**Fixes a serious translation bug, makes the glossary screen follow your theme, restores the tables to on-by-default, and repairs a self-reported version mismatch that caused endless update prompts.**

**The translation bug.** Terms found *inside* a sentence used to be substituted in place, and that resulting string was returned as the finished translation. So with a Japanese interface and a Simplified-Chinese paragraph, a single embedded term became Japanese while the rest stayed Chinese — and because that mixed string now contained Japanese, later checks concluded it was already Japanese and never translated it at all. The whole paragraph was left untranslated.

Now an embedded term is no longer substituted. The paragraph goes to the model as normal, and the matched terms are injected into the prompt as forced translations, so the model uses the official names while translating the rest of the sentence properly.

**Short names are used in titles again.** A title containing 绝区零 was showing the full name ゼンレスゾーンゼロ instead of the short form ゼンゼロ. The glossary already picks short vs. full form by text width, but the prompt-injection step hard-coded the "normal" width and never received the caller's intent. The width is now threaded through, so narrow contexts such as titles keep using the short form.

**The glossary screen follows the theme.** It previously used a bare `Scaffold` with untinted switches, so under a dark theme or a custom palette it rendered as a white background with black text and purple buttons. It now uses the same `SimpleScaffold` + `ViewSafeArea` as the settings pages, and takes every colour from `Theme.of(context).colorScheme`.

**Glossary tables are on by default again.** All 15 are enabled out of the box; you can still switch off individual works on the glossary page.

**Fixed the version the app reports about itself.** v3.6.4.1 was tagged `v3.6.4.1` while `pubspec.yaml` still said `3.6.4`. The app derives its reported version only from pubspec, so it believed it was 3.6.4, saw a newer tag, and kept prompting to update forever. Flutter's `version:` field only accepts `x.y.z+build`, so the rule is that the tag's numeric part must equal pubspec's `x.y.z`. `build.ps1` now verifies this and fails the build when they disagree, so a self-contradictory release cannot ship again.

**Performance.** The term-injection scan now uses the same first-character bucketing as the in-sentence matcher. Its cost went from scaling with the glossary (54,000 comparisons per string) to scaling with the text (a few dozen), so a large glossary can no longer make translation slow or crash the app.

Downloads are below.
