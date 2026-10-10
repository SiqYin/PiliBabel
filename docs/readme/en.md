<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>A third-party Bilibili client with AI-powered translation.</b></p>
    <p>Babel — tearing down the language barrier, so everyone can enjoy bilibili in their own language.</p>
    <p>Includes translation for 4 languages of China's ethnic minorities and 3 Chinese dialects.</p>
    <p>Translation works out of the box on bilibili's own free model — no API key required.</p>
</div>

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Home" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dynamics" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Me" />
</div>

<br/>

> **Disclaimer.** PiliBabel is an **unofficial, open-source, third-party** client. It is **not affiliated with, endorsed by, or sponsored by** bilibili / bilibili Inc. Every API is gathered from the official public endpoints; **no paid content is unlocked or cracked**. Please read the full [Disclaimer](#disclaimer) and [License](#license) sections.

## What is PiliBabel?

PiliBabel is an **independent third-party fork built on top of [PiliNara](https://github.com/Starfallan/PiliNara)**, and it inherits everything PiliNara inherits:

```
bilibili (official public API)
        ▲
   PiliPala / PiliPalaX        — the original project
        ▲
   PiliPlus                    — active fork
        ▲
   PiliNara                    — fork of PiliPlus (personal tweaks)
        ▲
   PiliBabel  ← you are here   — fork of PiliNara
```

PiliBabel keeps **every feature of PiliNara / PiliPlus** (see the [inherited feature log](#inherited-feature-log-from-pilinara--piliplus) near the bottom) and adds **one headline capability the upstream clients do not have**:

> **AI interface & content translation** — the whole app (UI labels, video titles, UP names, comments, dynamics, feed, and even live danmaku) is rendered in the language **you** choose.

And since 1.0 it does so **out of the box**: the translation model is **built in**. bilibili open-sourced its own translation model family, [Index-Translate](https://github.com/bilibili/Index-Translate), and serves it from a free public endpoint. PiliBabel ships pointed at it, so translation works the moment you install the app — no sign-up, no key, no bill. If you would rather use your own model, the own-API path is still there, one tap away.

## Key features

- **AI translation, everywhere.** Navigation tabs, video cards, detail pages, comments, dynamics, and the Mine / Favorites / History / Messages / Search surfaces — a global sweep covers **~1,650+ UI strings**, plus dynamic content (titles, author names, action counts).
- **Two engines, one switch.** *Built-in* (default) uses bilibili's official **Index-Translate-35B-A3B** free endpoint — nothing to configure. *Own API* keeps the previous behaviour: point it at any OpenAI-compatible `/chat/completions` endpoint with your own base URL / key / model. The AI video-summary feature and the AI translation feature still have **completely independent** endpoints and settings, both living under one **"AI features"** page.
- **One language list, both engines.** The target-language list is not split by engine — the same list is offered whichever engine you pick. It unifies the **150 languages** of bilibili's official model with the **4 languages of China's ethnic minorities and 3 Chinese dialects** PiliBabel adds on top — Tibetan, Uyghur, Zhuang and Hmong on one side; Cantonese, Shanghai-based Wu and Hokkien on the other — plus Traditional Chinese. Regional and script variants are kept **separate entries** rather than folded together — Moroccan / Egyptian / Najdi / Levantine Arabic are each their own choice, as are Cyrillic-vs-Latin Serbian, Uzbek and Urdu.
- **Honest about coverage.** Languages inside the official inventory are covered by bilibili's model. The handful outside it — Traditional Chinese, and the Chinese dialects and ethnic-minority languages above that bilibili does not list — still appear in the list, marked as such, so you know at a glance that a better result may need your own model.
- **Translate once, then it's fixed.** Each source string is translated **exactly once**; the result is persisted locally and **never re-translated** when you reopen a screen — the same principle as the official client, for stable, predictable translations.
- **Per-comment Original ⇄ Translation toggle** (a small icon, not a Chinese word). `@mentions / [emoji] / #topics# / links` are preserved as tokens, and **comments containing hyperlinks still translate while keeping the link clickable**.
- **Danmaku (弹幕) translation** — an independent toggle in the player's top-right control row, **off by default** and gated behind a confirmation whose own text is translated. Once enabled, danmaku ahead of the playhead are pre-translated in **~15-second batches** (seeking to the middle is handled correctly, not from the start), so the translation is usually ready by the time it scrolls in.
- **Thinking-mode switch** (`enable_thinking`) for quality-vs-speed, plus **"test translation"** and **clear-cache** buttons in settings.
- **Fast language switching**: batched requests with limited concurrency against a persistent cache; switching language force-rebuilds the current screen once, so you are not left staring at untranslated text. Turning AI translation off reverts the whole UI to the original text and issues no requests at all.
- **First-launch onboarding.** The first time you open the app, an English dialog offers to turn translation on. Accepting it enables translation, selects the built-in model, opens the AI settings page and immediately asks which language you want — so a new user goes from install to translated app in two taps.
- **Playback that works worldwide.** PiliBabel selects the overseas edge (global **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) that bilibili's geo-routed `playurl` already offers instead of pinning you to a mainland (Aliyun/Shenzhen) node — so users outside mainland China no longer stall ("audio keeps playing, video freezes"). You can still pin a CDN manually in Settings.

## The two translation engines

| | Built-in (default) | Own API |
|---|---|---|
| Model | bilibili **Index-Translate-35B-A3B** | anything OpenAI-compatible |
| Endpoint | `index-translate.bilibili.com/v1` | your base URL |
| API key | **not needed** | yours |
| Cost | free | whatever your provider charges |
| Requests | one string per request | batched (≤ 16 per request) |
| Extra languages | — | any language your model knows |

**Why per-request for the built-in engine.** Index-Translate is a translation *specialist*, and the calling convention its authors document is a single-item template ("translate the following text into X, output only the translation"). PiliBabel therefore sends one string per request on this engine instead of the numbered-list/JSON-array batch prompt it uses for own-API setups. The endpoint is free, so there is nothing to gain by gambling on batch output — this is a deliberate trade of a few more requests for far fewer ways to fail.

**Upgrading from 0.3.x.** Your own API settings — base URL, key and model — are **left exactly as you configured them**. The engine selection simply defaults to the built-in model, so on first launch after upgrading you will be on bilibili's free model; open *Settings → AI → AI features → translation engine* and switch back to *Own API* to return to your previous setup instantly.

## How the AI interface translation works (technical)

The repository has **no i18n / ARB resource layer** — UI strings are hard-coded Chinese. Rather than rewriting every widget, PiliBabel adds a thin translation layer on top:

1. **A global lookup wrapper.** `lib/services/ui_translate/` exposes a top-level `uiTx(String src)`. Widget text that used to be `Text('中文')` becomes `Text(uiTx('中文'))`. A scripted **codemod** applied this across the project (`tool/ui_translate_*.py`) — about **223 files / ~1,650+ strings** — automatically dropping the now-invalid `const` keyword where required (including generics such as `const X<T>(...)` and dotted names such as `const Positioned.fill(...)`, and converting `static const` list/map declarations to `static final`).
2. **A `GetxService` core** (`ui_translate_service.dart`):
   - a persistent **source → translation** cache (backed by GetStorage), so every string is translated once and reused forever;
   - `tx()` reads an `RxInt revision` first, then decides: if disabled → return the original; if the target is **Simplified Chinese (`zh-CN`)**, return the original without an API request (Bilibili's source content is overwhelmingly Simplified Chinese). Every other target — including Traditional Chinese, Cantonese, Wu/Shanghainese, and Hokkien/Min Nan — goes through the configured engine; Chinese-family membership alone does not skip translation. Then serve from cache or **enqueue**;
   - enqueued strings are flushed by a **worker pool** with **per-chunk incremental apply** (each returned chunk bumps `revision` so text updates progressively), and results are **persisted** (throttled). Batch size and concurrency follow the engine: **1 per request** on the built-in model, **≤ 16 with ≤ 10 in flight** on your own API.
3. **Engine resolution.** `TranslateProvider` (`builtin` / `custom`) decides which URL, key and model the transport uses; both engines otherwise share one code path and one language list, so switching engines is a single setting and never a different feature set.
4. **The transport** reuses the same verified **streaming** channel as AI video summary — `AiChatService.streamChat` → `{base}/chat/completions` with `stream: true` (compatible with gateways that only support streaming) — extended so translation can use its **own** `apiUrl` / `apiKey` / `model` and an `enable_thinking` flag. The change is **backward-compatible**, so video summary keeps working unchanged.
5. **Interpolated sentences** use `uiTxP(template, args)`: a whole sentence with `{0}`/`{1}` placeholders is translated as one stable key (the prompt asks the model to keep the placeholders), then the values are substituted back — so `"共 {0} 条"`-style strings translate without mangling the dynamic parts.
6. **Language table** (`app_language.dart`): each `AppLanguage` carries a display autonym, a `toModel` prompt string that encodes script/region conventions, and a flag for whether bilibili's official inventory covers it. Script rules (Simplified vs Traditional, and the dialect-consistency instructions) reach the model only through the prompt, and a deterministic normalisation pass on the client fixes stray glyphs afterwards.
7. **Comments** go through `uiTxComment(text, id)`, keeping `@ / [emoji] / #topic# / link` as intact tokens; rich-text spans that carry links are translated while the link recognizer is preserved, and a per-comment id set drives the Original ⇄ Translation toggle.
8. **Danmaku** (`danmaku/view.dart`): when its toggle is on, a position listener walks `[playhead, playhead + 15s]` one second at a time and warms `uiTx()` on each danmaku's content, so items are pre-translated before they reach the screen; enabling it clears and repaints the canvas.
9. **Storage keys**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Settings UI**: a single first-level "AI features" page (`lib/pages/setting/ui_translate/`) with independent blocks for AI video summary and AI translation.

**Worldwide CDN (`VideoUtils.getCdnUrl`).** Stream URLs are signed, and rewriting a URL's host gets it rejected with 403 — so playback never rewrites hosts. PiliBabel returns the geo-routed URL bilibili hands the client's IP, and when the candidate list already contains an overseas edge (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`) that one is preferred. Downloads, where a host swap is safe, additionally prefer the global Akamai edge and rotate to the next signed candidate when a line stalls or rejects a resume. Raw `/v/resource` P2P links still fall back to the existing relay to avoid 404s.

**Design trade-offs / known limits.** Because strings are wrapped in place rather than extracted into resources, a few non-`Text` string parameters and some rich-text spans are still being filled in incrementally. Strings that double as **logic keys** (compared with `==`, used as tab names such as `简介`, or enum labels used in switches) are deliberately **not** blanket-wrapped, to avoid breaking behaviour. Danmaku translation is best-effort on a scrolling canvas — under extremely dense danmaku you may briefly see the original before the translation arrives. Translation needs network; without one, non-Chinese targets simply do not take effect. The built-in endpoint is a free public service run by bilibili — if it is ever rate-limited or unavailable, the app tells you so and you can switch to your own API.

## Build & verify

The app is built with a patched Flutter SDK plus patched `material_ui` / `cupertino_ui` packages via `lib/scripts/patch.ps1` and `lib/scripts/build.ps1` (exactly like PiliNara / PiliPlus). GitHub Actions produces a **debug APK** on every push (`.github/workflows/ui-translate-debug.yml`), and **publishing a tag `v*` auto-builds & releases Android, Windows and Linux** artifacts (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Platforms
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

PiliBabel ships **Android (APK), Windows and Linux** builds from Releases; iOS/Pad aren't packaged in this fork yet.

<br/>

## Download

Grab a build from **Releases**, or clone the repo and build it locally.

### Arch Linux

Thanks to [@nlsdt](https://github.com/nlsdt) for packaging (the PiliNara recipe carries over to PiliBabel).

```bash
sudo pacman -S pilinara      # via the Arch Linux CN repository
paru -S pilinara-bin         # or via AUR: pilinara-bin (prebuilt) / pilinara (source)
```

<br/>

## Inherited feature log (from PiliNara / PiliPlus)

Everything below is carried over from PiliNara (and, transitively, PiliPlus); PiliBabel adds the AI translation layer on top.

**UI & platform adaptation**
- [x] App renamed per platform so multiple clients can coexist (PiliBabel installs alongside PiliNara)
- [x] Fixed Flutter rendering under Xiaomi HyperOS mini-window ([#161086](https://github.com/flutter/flutter/issues/161086), via [venera#467](https://github.com/venera-app/venera/pull/467)); predictive back animation on Android
- [x] Customizable "Mine" card order/count; history-card preview & "watch later" sections
- [x] Auto sidebar switching with configurable trigger width; copy-image from long-press / right-click; large MD3E style refresh

**Font system** — a unified import pool with content-hash de-duplication, danmaku fonts merged into the same pool, `loadFontFromList` with ttc support, and pure-ASCII hash family names.

**Playback, mini-window & quality** — in-app mini-window (drag, resize, SponsorBlock skip, auto system PIP, live self-rescue bar), concurrent-audio playback, in-app volume up to 200%, custom video CDN domain & regional node selection with latency test, separate half/full-screen default quality, swipe-up speed lock, tablet keyboard control, live SuperChat timestamps, live heartbeat for fan-intimacy.

**Subtitles, AI & offline** — bilingual subtitles with independent secondary-subtitle styling, AI subtitle analysis (custom OpenAI-compatible endpoint, timestamp jump, templates, persisted conversations, soft no-subtitle fallback), WEBVTT/SRT export, offline-cache dual view with folder management & metadata persistence, export downloads to the public Download folder (Android).

**Danmaku & blocking** — enhanced merged-danmaku scaling ([Pakku.js](https://github.com/xmcp/pakku.js)-style), list-based visual regex blocking with import/export, SponsorBlock seek-into-segment skip, Gaussian-kernel high-energy progress bar.

**Recommendation / dynamic / comment filtering** — title/UP/channel keywords, duration, play-count, like-rate, followed-UP exemption, unauthorized/charge-only filtering, shared whitelist, commerce/unauthorized dynamics, UP-own-comment & pinned-comment exemptions, App+Web merged-feed mode.

**Dynamics, search & user info** — custom notes for UPs, note-replaces-nickname across 13 name slots, independent nested-comment sort, local keyword search filter, b23.tv short-link jump, charge-only badge, hide-recommendation-reason toggle, coin XP display.

**Live enhancements** — fan-medal wearing panel, DLNA cast preferring HLS, SuperChat time display, mini-window bottom control bar for self-rescue.

**System integration & desktop** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), rebuilt audio-focus handling.

<details>
<summary>Full original feature/checklist (verbatim, from PiliNara — click to expand)</summary>

**feat**
编辑动态 · DLNA 投屏 · 离线缓存/播放 · 点击弹幕悬停(点赞/复制/举报) · 播放音频 · 跳过番剧片头/片尾 · 安卓 `loudnorm` · Win/Mac 极验/短信登录 · 视频截取动图 · AI 原声翻译 · SuperChat · 播放课堂视频 · 发起投票 · 发布动态/评论支持富文本/表情/@用户 · 修改消息/聊天设置 · 展示折叠消息 · 查看用户图文 · 动态话题 · 直播分区 · 分享至消息 · 创建/修改/删除关注分组 · 移除粉丝 · 直播弹幕发送表情 · 收藏夹排序 · 稍后再看分类 · WebDAV 备份/恢复 · 保存评论/动态 · 高级弹幕 · 取消/置顶评论 · 记笔记 · 多账号支持 · 屏蔽带货动态/评论 · 互动视频 · 发评/动态反诈 · 高能进度条 · 滑动跳转预览缩略图 · Live Photo · 复制/移动/排序收藏夹 · 超分辨率 · 会员彩色弹幕 · 播放全部/继续/倒序 · Cookie 登录 · 显示视频分段信息 · 调节字幕/全屏弹幕大小 · 收藏夹多选删除 · 搜索用户动态 · 直播弹幕 · 修改资料 · 创建/编辑/删除收藏夹 · 评论楼中楼对话/定位/排序 · 评论点踩 · 私信发图 · 投币动画 · 取消/追番 · 取消/订阅合集 · SponsorBlock · 显示完整合集 · 三连/番剧三连动画 · 带图评论 · 视频 TAG · 筛选搜索 · 转发动态 · 合集图片 · 私信删除/置顶/撤回 · 举报 · 发布/删除/置顶动态

**opt**
专栏界面 · 私信界面 · 收藏面板 · PIP · 视频封面 · 回复界面 · 系统通知 · 评论显示 · 亮度调节 · 视频播放 · 视频 staff · 防止 bottomsheet 遮挡全屏视频

**fix**
番剧分集点赞/投币/收藏 · bugs

**功能**
推荐视频列表(app 端) · 最热视频 · 热门直播 · 番剧列表 · 黑名单屏蔽 · 无痕模式 · 游客模式；用户(粉丝/关注/拉黑、主页、关注取关、离线缓存、稍后再看、观看记录、我的收藏、站内私信)；动态(全部/投稿/番剧、评论与回复)；播放(双击快进快退、播放暂停、亮度音量、上滑全屏、手势快进、全屏方向、倍速、硬件加速、画质/音质/解码、弹幕、字幕、记忆播放、比例)；搜索(热搜、历史、默认词、投稿/番剧/直播/用户、排序与时长筛选)；视频详情(分 P 切换、点赞投币收藏、相关视频、评论身份、排序与二楼、回复、点赞、笔记图)；设置(画质/音质/解码预设、图片质量、主题、震动、高帧率、自动全屏、横屏适配)

</details>

<br/>

## Disclaimer

PiliBabel is a personal, interest-driven project, provided **for learning and testing only**; please delete it within **24 hours** of download.

- PiliBabel is an **unofficial third-party** client and is **not affiliated with, endorsed by, or sponsored by bilibili**.
- All APIs are gathered from official public endpoints; **no cracked, over-privileged, or paywall-bypassing content** is provided.
- **AI translation runs on a third-party model endpoint.** By default that is bilibili's own free public Index-Translate service; if you switch to your own API, it is the endpoint you configured. Translation quality and compliance are the responsibility of the user and the chosen model provider; this project hosts **no model and no API key**.
- Respect copyright and bilibili's Terms of Service. Use responsibly.

With respect to the original and upstream authors for their open-source dedication:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — the direct parent project of PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — the open-source translation model family the built-in engine calls

If any content infringes your rights, please contact us for takedown.

<br/>

## License

PiliBabel is licensed under the **GNU General Public License v3.0 (GPL-3.0)** — the same license as PiliNara, PiliPlus and PiliPala. Because it is a derivative work, **PiliBabel must also be distributed under GPL-3.0**: you are free to use, study, share and modify it, provided you keep the same license, the copyright notices, and this license text. See [`LICENSE`](./LICENSE).

Third-party components (Flutter packages, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), etc.) remain under their own licenses.

<br/>

## Acknowledgements

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — bilibili's open-source translation model family, and the free public endpoint behind the built-in engine
- and more
- Inspired by bilibili's official "AI interface translation".
