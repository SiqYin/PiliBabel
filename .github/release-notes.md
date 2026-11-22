### PiliBabel v3.9.8

**Two font-setting bugs are fixed — both found and reported by @masktao (#5, #6). Thank you!**

On wide windows the settings page switches to a two-pane layout, and the font page was embedded without its app bar — which is where the “Reset” and “Apply” buttons lived. Embedded like that, font changes had no way to be saved at all and silently reverted after a restart (#5). The same pair of buttons now sits at the foot of the font page whenever it is embedded; saving also no longer pops the whole settings page, which the old back-then-apply flow would have done from the embedded position.

The settings search indexed only the entries inside the seven category pages, so the page-level entries — fonts, AI translation, theme & colors, WebDAV, About — could never be found, and searching for “font” returned nothing (#6). Those five page entries are now part of the search index and open their page when tapped.

### PiliBabel v3.9.7

**The app now follows your system language — with a switch to lock your own choice.**

Every launch compares the chosen app language (Settings → AI Translation → “Choose app language”) against the system language. When they differ, a guided animation walks you there step by step: the AI Translation page scrolls into view, then further to the language field, the picker opens so you can see the full list, and after a short pause the system language is selected for you — whatever you tap yourself in that window wins, and the whole interface rebuilds in the new language the moment the picker closes. This replaces the old first-launch-only onboarding: new installs still auto-enable AI translation silently on the built-in free model, but the language switch is now the same guided flow as everyone else's, and it re-runs on every launch whenever the languages drift apart — including after you change your system language.

A segmented toggle right below the picker controls it: **Follow system language** (default) keeps the behavior above and also aligns immediately when you switch back to it; **Lock my chosen language** opts out entirely — no detection, no switching, your pick stays untouched. All new labels are translated through the same AI translation as the rest of the interface. System-language detection also handles script subtags correctly (zh_Hant → Traditional Chinese) and no longer produces language codes retired in 3.8.10.

### PiliBabel v3.9.6

**Every search box outside the home screen now shows results as you type — no Enter needed.**

History, favorites, watch-later, followed users, and the download list used to wait for you to press Enter; they now fire a debounced search (200 ms) right after you stop typing, and clear back to the initial state when you empty the box. The two-tab search screens — live, UP space (videos and posts), and in-video comments — behave the same way. Enter still works as an instant search; on live search, a digits-only query is deliberately left to Enter so typing a room number doesn't jump rooms mid-typing. Keyword resolution and the simplified/traditional variant search from 3.9.5 run unchanged under the hood, with per-word caching so continuous typing doesn't multiply requests.

**The chapter (segment) bar under the video no longer shrinks its text into unreadability.** When a segment title is wider than its segment, the bar used to scale the whole label down proportionally — with long original titles and even longer translations, the glyphs ended up a few pixels tall. It now wraps the title automatically inside its own segment, up to 3 lines (ellipsis beyond that), at a fixed, readable font size; the bar simply grows taller to fit the tallest segment, and looks exactly like before when everything fits on one line. Translated titles re-layout as soon as they arrive.

Nothing else changed: the home screen search keeps its suggestion-as-you-type flow, and all variant searches stay first-page-only with per-item de-duplication.
