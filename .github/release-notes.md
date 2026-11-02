### PiliBabel v3.5.4

**Added: official "AI original-voice translation" audio tracks now follow the app
language. Fixed: switching tracks was silent; headphone pause key did nothing.**

- **New — audio track follows the app language.** When a video ships one of
  Bilibili's official AI-dubbed tracks (the player's `AI原声翻译（Beta）` list) and
  that list contains a track matching the app language, the track is selected
  automatically when the video opens, with a one-time toast. Toggle:
  Settings → AI translation → **声轨跟随界面语言** (on by default).
  - **Rule**: if Bilibili doesn't offer the app language, playback stays on the
    original audio. A Korean interface with only English/Japanese available does
    **not** fall back to "the closest language", and no local dubbing is
    synthesized (evaluated and deliberately rejected). The reverse also works: a
    foreign-language video carrying an AI Chinese track switches to Chinese when
    the interface is Chinese.
  - No auto-switch while logged out: anonymous `cur_language` is silently ignored
    by the server, so switching would only make the UI lie about the audio. We
    also trust **only the server's echo** — if `cur_language` doesn't come back
    equal to the language we asked for, playback stays on the original audio.
  - The switch happens **before playback starts** (you never hear the original
    track first), is attempted once per part, respects a manual choice
    (including "关闭翻译"), and carries the chosen language across parts.
- **Fixed: switching the audio track produced no audio change.** By default the
  media URLs come from the official APP source (gRPC `PlayView`), and
  `PlayViewReq` has **no language parameter at all** — Web's `language` metadata
  was merely copied onto the APP result. So the UI said "English" while the
  audio stayed Mandarin: the feature was broken under default settings. When a
  language is requested we now stay on the Web source (the two token families
  require opposite request fingerprints — APP links must not send `Referer`, Web
  links must — so video-from-APP + audio-from-Web is not an option either).
- **Fixed: the headphone play/pause key could play but never pause.**
  `audio_service`'s Android side routes `KEYCODE_MEDIA_PLAY`, `PAUSE`,
  `PLAY_PAUSE` and `HEADSETHOOK` all into `handler.click(MediaButton.media)`
  (the key always means "toggle", never "pause"), and the default implementation
  decides using `playbackState.playing` — the state we **report to the system**,
  which is only updated when `setPlaybackState` passes three gates (background
  playback enabled, a media item registered, a `PlPlayerController` instance
  alive). The 听视频 (listen-only) page drives its own media_kit `Player` and has
  no `PlPlayerController`, so that reported value stayed at its initial `false`
  and every key press took the `play()` branch. We now override `click()` and
  read the **actual** player state.

中文摘要：本版新增「声轨跟随界面语言」——稿件带官方 AI 原声翻译声轨且有与界面语言一致
的一轨时，开播前自动选中（AI 翻译设置页，默认开）；官方没有对应语种就保持原声，不做
就近兜底、不做本地合成。同时修两个问题：① 默认「直链走 APP 同源」时 `PlayViewReq`
没有语言参数，导致切换声轨后界面显示已切、声音仍是原声（现在指定语言就不走 APP 同源）；
② 戴耳机时播放/暂停键按得出播放、按不出暂停——`audio_service` 把这几种按键全部路由到
`click()`，而默认实现看的是「上报给系统」的播放状态，听视频页没有 `PlPlayerController`
实例、那份状态永远停在初始的 `false`，现在改读真实播放状态。
