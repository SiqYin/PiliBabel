### PiliBabel v3.9.9

**Listening mode no longer waits on the video — it is a fallback for exactly the case where the video will not load.**

The “listen only” page used to open whatever audio URL the video page happened to have. When the video could not load, that URL was either missing or a link that the current network could not pull — so the fallback died the same way the video did. The page now always fetches its own stream and starts playing the moment the audio is ready; nothing about the video's loading state is inherited.

Entering the page also **voids the video side outright**: the stream request still in flight is discarded (it is re-fetched when you come back), subtitle jobs are stopped (this page has no subtitles to load), and a player stuck in “loading” has its media unloaded so the whole connection is handed to the audio. Videos that were already playing are left paused instead, and resume instantly on return.

If a line refuses to start, the next candidate address from the same response is tried, and after all of them are exhausted the stream is re-requested (up to twice). A ten-second watchdog decides a line is dead rather than leaving you staring at two frozen 00:00s, and the progress row now says “loading audio” / “switching to a backup line” / “re-fetching the stream” while it happens.

Two smaller things: a failed player creation no longer leaves the page permanently dead (it can retry), and both audio download entries can now build their request from this page's own playlist item, so they work even when the video page's details never arrived.

### PiliBabel v3.9.8

**Two font-setting bugs are fixed — both found and reported by @masktao (#5, #6). Thank you!**

On wide windows the settings page switches to a two-pane layout, and the font page was embedded without its app bar — which is where the “Reset” and “Apply” buttons lived. Embedded like that, font changes had no way to be saved at all and silently reverted after a restart (#5). The same pair of buttons now sits at the foot of the font page whenever it is embedded; saving also no longer pops the whole settings page, which the old back-then-apply flow would have done from the embedded position.

The settings search indexed only the entries inside the seven category pages, so the page-level entries — fonts, AI translation, theme & colors, WebDAV, About — could never be found, and searching for “font” returned nothing (#6). Those five page entries are now part of the search index and open their page when tapped.

### PiliBabel v3.9.7

**The app now follows your system language — with a switch to lock your own choice.**

Every launch compares the chosen app language (Settings → AI Translation → “Choose app language”) against the system language. When they differ, a guided animation walks you there step by step: the AI Translation page scrolls into view, then further to the language field, the picker opens so you can see the full list, and after a short pause the system language is selected for you — whatever you tap yourself in that window wins, and the whole interface rebuilds in the new language the moment the picker closes. This replaces the old first-launch-only onboarding: new installs still auto-enable AI translation silently on the built-in free model, but the language switch is now the same guided flow as everyone else's, and it re-runs on every launch whenever the languages drift apart — including after you change your system language.

A segmented toggle right below the picker controls it: **Follow system language** (default) keeps the behavior above and also aligns immediately when you switch back to it; **Lock my chosen language** opts out entirely — no detection, no switching, your pick stays untouched. All new labels are translated through the same AI translation as the rest of the interface. System-language detection also handles script subtags correctly (zh_Hant → Traditional Chinese) and no longer produces language codes retired in 3.8.10.
