### PiliBabel v2.0.0

Two milestones since 1.0.0: the whole interface can now be read in your own language, and
image translation reaches every corner of the app. A round-up of what changed in between.

**Translation itself**

- **Built-in engine, no API key.** PiliBabel ships with Bilibili's own free Index-Translate
  model, so translation works the moment you install it. Your own API settings are kept and
  can be switched back to at any time. The language list grew from 29 to 157 entries,
  keeping regional and script variants as separate entries rather than merging them.
- **The whole player, not just its chrome.** The listen-video page, chapter names on the
  progress bar and roughly two hundred strings that used to reach the screen untranslated
  - settings subtitles, danmaku presets, the log viewer, context menus, publish dialogs and
  more - all go through the translation table now.
- **Subtitles follow your interface language.** Bilibili pre-generates translated subtitle
  tracks server-side; PiliBabel now picks the one matching your interface language by
  scoring, and attaches the other as a secondary track.

**Image translation**

- Tap the corner button on a cover, a comment picture or an article illustration and the
  text in it is read, translated and the picture described. Around seventy files were
  touched so that every video cover in the app carries it - the home feed, dynamics,
  favourites, search, subscriptions, music, downloads, rankings, member pages and the live
  lists. Animated images are skipped on purpose, and quoted videos in dynamics are covered
  too.

**Reading long titles**

- English, French, German and Japanese titles are longer than the Chinese original, so a
  two-line cap used to cut them off. A new option in AI translation settings stretches the
  card blocks vertically - the home feed, member pages, rankings, live and search grids -
  and gives titles up to four lines. It follows the translation switch and can be turned
  off by hand.

**Comment and dynamics reading**

- **Expand comments by default** and **expand dynamics by default**, two switches under
  Settings - Other, open every "show more" without a tap. Both are off by default.

**Playback and appearance**

- Audio output on Android now prefers AudioTrack, matching Bilibili's own app, which fixes
  the half-beat lag on Bluetooth headsets.
- A truncated video segment on some CDN hosts used to leave audio playing over a black
  picture; bad hosts are now excluded per host, with ffmpeg stream reconnection.
- A Material You style theme and colour page with live preview cards, and LXGW WenKai
  embedded as the default font for both interface and danmaku.

**Reliability**

- Fixed a GetX pitfall where a widget that read no observable rendered as a grey block, and
  hooked up `FlutterError.onError` so build failures are recorded and visible in the app log
  instead of disappearing.

Downloads are below.
