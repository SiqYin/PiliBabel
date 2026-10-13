### PiliBabel v1.7.0

**Interface translation now covers the whole player, not just the chrome.**

- **Listen-video page.** The audio page only translated its buttons and tooltips; the
  body it renders — video title, UP name, description, playlist entries — went out in
  the source language. All of it goes through the translation table now, and the panels
  refresh themselves the moment a translation lands.
- **Chapter names on the progress bar.** The segment labels an uploader writes are
  painted by a RenderBox that only repainted when the playback position moved, so the
  translation arrived after the last repaint and never showed. It repaints on the
  translation revision now.
- **The rest of the app.** A sweep of the tree added ~200 more strings that reached the
  screen without going through the translation table: settings subtitles, danmaku merge
  presets, log viewer, search include/exclude dialogs, history controls, player
  fullscreen and lock buttons, live danmaku block, favourite tabs, login tabs, the
  context menus, publish and repost dialogs, and the list goes on. Enum labels, static
  field initializers and interpolated strings were left alone on purpose — their values
  double as request parameters and comparison keys.
- **README language inventory corrected.** The old text claimed 150 official languages
  plus four minority languages and three dialects that PiliBabel added. Cantonese,
  Tibetan, Uyghur and Miao were already in the official list; the real split is 151
  official plus six the official list does not cover — Traditional Chinese, Simplified
  and Traditional Wu, mainland and Taiwan Hokkien, and Zhuang. All 12 translations of
  the README carry the corrected numbers now.

Downloads are below.
