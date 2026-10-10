<div align="center">
    <p><b>PiliBabel</b></p>
    <p><a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a></p>
    <p><sub>Pick your language above — the links jump within this page, no need to open another file.</sub></p>
</div>

<a id="readme-languages"></a>

---

<a id="readme-en"></a>

## English

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

<sub><a href="#readme-languages">↑ <a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a></a></sub>

---

<a id="readme-zh"></a>

## 中文

<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>具備 AI 翻譯功能的第三方嗶哩嗶哩（Bilibili）客戶端。</b></p>
    <p>巴別塔 —— 打破語言的高牆，讓每個人都能用屬於自己的語言享受 Bilibili。</p>
    <p>含 4 種中國少數民族語言與 3 種漢語方言的翻譯。</p>
    <p>內建 B 站官方免費翻譯模型，裝好即用，無需 API Key。</p>
</div>

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="首頁" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="動態" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="我的" />
</div>

<br/>

> **免責聲明。** PiliBabel 是一個**非官方、開源、第三方**客戶端，**與 bilibili 官方無任何隸屬、認可或贊助關係**。所有介面均取自官方公開介面，**不提供任何破解、越權或繞過付費的內容**。請完整閱讀 [免責聲明](#免責聲明) 與 [開源協議](#開源協議) 兩節。

## PiliBabel 是什麼？

PiliBabel 是**建立在 [PiliNara](https://github.com/Starfallan/PiliNara) 之上的獨立第三方分支**，完整繼承了 PiliNara 所繼承的一切：

```
bilibili（官方公開介面）
        ▲
   PiliPala / PiliPalaX        — 最初的專案
        ▲
   PiliPlus                    — 活躍分支
        ▲
   PiliNara                    — PiliPlus 的分支（個人改動）
        ▲
   PiliBabel  ← 你在這裡        — PiliNara 的分支
```

PiliBabel **保留 PiliNara / PiliPlus 的全部功能**（見文末[繼承功能清單](#繼承功能清單來自-pilinara--piliplus)），並加上了上游都沒有的核心能力：

> **AI 介面與內容翻譯** —— 整個應用（介面文案、影片標題、UP 主名字、評論、動態、資訊流，乃至直播彈幕）都用**你選擇的語言**呈現。

而且從 1.0 起，這件事**開箱即用**：翻譯模型是**內建**的。B 站開源了自己的翻譯模型家族 [Index-Translate](https://github.com/bilibili/Index-Translate)，並提供免費的公網介面；PiliBabel 預設就指向它，所以**裝好打開就能翻譯** —— 不用註冊、不用金鑰、不花錢。如果你更想用自己的模型，自備 API 的入口一直都在，一步之遙。

## 主要特性

- **翻譯覆蓋全應用。** 導覽列、影片卡片、詳情頁、評論、動態，以及「我的 / 收藏 / 歷史 / 訊息 / 搜尋」各介面 —— 全域替換覆蓋 **約 1650+ 條介面文案**，加上標題、UP 主名字、播放資料這類動態內容。
- **兩種引擎，一個開關。** *內建*（預設）走 B 站官方 **Index-Translate-35B-A3B** 的免費介面，無需任何設定；*自備 API* 保留原有行為，可指向任意 OpenAI 相容的 `/chat/completions` 介面，填自己的位址 / 金鑰 / 模型。AI 影片總結與 AI 翻譯**各自獨立**設定，都收在同一個**「AI 功能」**頁裡。
- **一份語言清單，兩個引擎共用。** 目標語言清單不按引擎拆分，選哪個引擎都是同一份清單。它把 B 站官方模型的 **150 種語言**與 PiliBabel 額外補上的 **4 種中國少數民族語言與 3 種漢語方言**合併在一起 —— 前者是藏語、維吾爾語、壯語、苗語，後者是粵語、吳語、閩南語 —— 再加上繁體中文。地區與字形變體**各佔一條、不合併** —— 摩洛哥 / 埃及 / 納吉迪 / 黎凡特阿拉伯語是各自獨立的選項，塞爾維亞語、烏茲別克語、烏爾都語的西里爾 / 拉丁字形同理。
- **如實標註覆蓋範圍。** 官方清單內的語言由 B 站模型負責；清單外的少數幾種（繁體中文，以及 B 站未收錄的上述漢語方言與少數民族語言）依然出現在清單裡，但會標註出來，讓你一眼知道想要更好的效果可能需要自備模型。
- **翻譯一次，永久固定。** 每條原文**只翻譯一次**，結果本地持久化，重進介面**不會重翻** —— 與官方客戶端同一原則，譯文穩定、可預期。
- **逐條評論的「原文 ⇄ 譯文」切換**（一個小圖示，不是一個中文詞）。`@某人 / [表情] / #話題# / 連結` 會作為整體保留，**含超連結的評論照樣翻譯，且連結依然可點**。
- **彈幕翻譯** —— 播放器右上角控制列裡的獨立開關，**預設關閉**，開啟前有一次內容本身也會被翻譯的確認。開啟後，播放頭之前的彈幕會按 **約 15 秒一批**提前預熱翻譯（跳到中間也能正確從該處開始，而不是從頭），通常彈幕飄到眼前時譯文已經就緒。
- **思考模式開關**（`enable_thinking`）用於在品質與速度之間取捨，設定頁另有**「測試翻譯」**與**清空快取**兩個按鈕。
- **切換語言夠快**：分批請求 + 限流併發 + 持久快取；切換語言時當前介面強制重建一次，不會讓你對著未翻譯的文字發愣。關閉 AI 翻譯會把整個介面恢復原文，並且**完全不發任何請求**。
- **首次啟動引導。** 第一次打開應用時會彈出一個英文對話框，詢問是否開啟翻譯。同意後會：開啟翻譯、選中內建模型、跳到 AI 設定頁，並立刻問你想要哪種語言 —— 新使用者兩次點擊就能從「剛裝好」到「已經翻譯好」。
- **全球可播放。** PiliBabel 會優先選用 B 站按 IP 就近下發的海外線路（全球 **Akamai**、`mirror*ov`、`cn-hk-eq-bcache`），而不是把你釘在中國大陸（阿里雲/深圳）節點上 —— 大陸以外的使用者不再出現「聲音在走、畫面卡住」。當然，你也可以在設定裡手動指定 CDN。

## 兩種翻譯引擎

| | 內建（預設） | 自備 API |
|---|---|---|
| 模型 | B 站 **Index-Translate-35B-A3B** | 任意 OpenAI 相容模型 |
| 介面 | `index-translate.bilibili.com/v1` | 你自己的位址 |
| API Key | **不需要** | 你自己的 |
| 花費 | 免費 | 取決於你的服務商 |
| 請求方式 | 每次一條 | 批次（每次 ≤ 16 條） |
| 額外語言 | — | 你的模型會的任何語言 |

**內建引擎為什麼逐條請求。** Index-Translate 是翻譯**專精**模型，其作者給出的呼叫約定就是單條模板（「請將以下文本翻譯為 X，直接輸出翻譯結果」）。因此在這個引擎上，PiliBabel 每次只發一條，而不是自備 API 那套「編號清單 + 要求回 JSON 陣列」的批次提示詞。介面是免費的，為省請求去賭批次輸出並不划算 —— 這是**拿多一點請求量換少一大截出錯面**的自覺取捨。

**從 0.3.x 升級上來。** 你自己配的 API —— 介面位址、金鑰、模型 —— **原樣保留，不會被改動**。引擎選擇預設落到內建模型，所以升級後第一次打開會使用 B 站的免費模型；到 *設定 → AI → AI 功能 → 翻譯引擎* 切回「自備 API」，即可立刻回到你原來的設定。

## AI 介面翻譯的實作（技術細節）

本倉庫**沒有任何 i18n / ARB 資源層** —— 介面文案全是硬編碼中文。PiliBabel 沒有重寫每個 widget，而是加了一層薄薄的翻譯層：

1. **全域取詞包裝。** `lib/services/ui_translate/` 對外暴露頂層函式 `uiTx(String src)`，原先寫 `Text('中文')` 的地方改成 `Text(uiTx('中文'))`。這步由**腳本化 codemod** 全專案鋪開（`tool/ui_translate_*.py`）—— 約 **223 個檔案 / 1650+ 條文案** —— 並自動去掉因此失效的 `const`（含 `const X<T>(...)` 這類泛型與 `const Positioned.fill(...)` 這類點號呼叫），把 `static const` 的列表/映射宣告改成 `static final`。
2. **`GetxService` 核心**（`ui_translate_service.dart`）：
   - 一份持久化的**原文 → 譯文**快取（落在 GetStorage），每條只翻一次、之後永久複用；
   - `tx()` 先讀一次 `RxInt revision`，再決定：未開啟 → 傳回原文；目標語言是**簡體中文（`zh-CN`）** → 直接傳回原文、**不發請求**（B 站內容絕大多數本就是簡體）。其它任何目標 —— 包括繁體中文、粵語、吳語、閩南語 —— 都會走引擎翻譯；**光看是否屬於中文家族並不足以跳過翻譯**。接著查快取，未命中則**入隊**；
   - 入隊文案由 **worker 池**消化，**按塊增量落庫**（每塊返回就自增 `revision`，文字漸進刷新），結果**節流持久化**。批次與併發跟隨引擎：內建模型**每次 1 條**，自備 API **每次 ≤ 16 條、併發 ≤ 10**。
3. **引擎解析。** `TranslateProvider`（`builtin` / `custom`）決定傳輸層用哪一套位址、金鑰與模型；除此之外兩個引擎共用同一條程式路徑、同一份語言清單 —— 所以切換引擎只是一個設定項，**不會變成兩套功能**。
4. **傳輸層**沿用與 AI 影片總結一致的、已驗證可用的**串流**通道 —— `AiChatService.streamChat` → `{base}/chat/completions`，帶 `stream: true`（相容只支援串流的閘道）—— 並擴展出翻譯**獨立**的 `apiUrl` / `apiKey` / `model` 與 `enable_thinking` 開關。該改動**向後相容**，影片總結不受影響。
5. **含佔位符的整句**走 `uiTxP(template, args)`：把帶 `{0}`/`{1}` 的整句作為一個穩定 key 送翻譯（提示詞要求模型保留佔位符），再把參數回填 —— `"共 {0} 條"` 這類句子因此不會把動態部分譯壞。
6. **語言表**（`app_language.dart`）：每個 `AppLanguage` 帶顯示用的自稱、編碼字形/地區規範的 `toModel` 提示詞串，以及一條「B 站官方清單是否覆蓋」的標記。字形硬約束（簡繁）與方言一致性要求**只經提示詞**傳給模型，客戶端之後再做一遍確定性的字形正規化兜底。
7. **評論**走 `uiTxComment(text, id)`，把 `@ / [表情] / #話題# / 連結` 作為完整 token 保留；帶連結的富文字分段照樣翻譯，同時保住連結辨識；每條評論的 id 集合驅動「原文 ⇄ 譯文」切換。
8. **彈幕**（`danmaku/view.dart`）：開關打開後，一個位置監聽器會以一秒一步走過 `[播放頭, 播放頭 + 15 秒]`，對每條彈幕內容預熱 `uiTx()`，讓它們在飄上螢幕前就譯好；開啟時清空並重繪畫布。
9. **儲存鍵**：`uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`。**設定介面**：一個統一的第一級頁「AI 功能」（`lib/pages/setting/ui_translate/`），影片總結與介面翻譯各自獨立成塊。

**全球 CDN（`VideoUtils.getCdnUrl`）。** 直鏈是簽過名的，改寫主機名會被 403 拒絕 —— 所以**播放側絕不改寫主機**。PiliBabel 直接採用 B 站按客戶端 IP 就近下發的位址；當候選清單裡本來就有海外線路（`*.akamaized.net`、`mirror(cos|ali|hw)ov`、`cn-hk-eq-bcache`）時優先選它。下載側因為換主機是安全的，會額外優先 Akamai 全球邊緣，並在某條線路卡住或拒絕續傳時輪換到下一條已簽名候選。裸 `/v/resource` 的 P2P 直鏈仍回退到既有中轉，避免 404。

**設計取捨 / 已知限制。** 因為是在原地包裝字串、而不是抽取成資源，少數非 `Text` 的字串參數與部分富文字分段仍在逐步補齊。那些**兼作邏輯鍵**的字串（用 `==` 比較、當作 `簡介` 這類標籤名、或用於 switch 的列舉標籤）**刻意不做**統一包裝，以免改壞行為。彈幕翻譯是在滾動畫布上的盡力而為 —— 彈幕極密時可能先看到原文、隨後才變成譯文。翻譯需要網路；沒有網路時非中文目標自然不生效。內建介面是 B 站營運的免費公共服務，若被限流或不可用，應用會明確提示，你可以切到自備 API。

## 建置與驗證

建置方式與 PiliNara / PiliPlus 完全一致：打補丁的 Flutter SDK + 打補丁的 `material_ui` / `cupertino_ui` 套件，經由 `lib/scripts/patch.ps1` 與 `lib/scripts/build.ps1`。GitHub Actions 在每次推送時產出**除錯版 APK**（`.github/workflows/ui-translate-debug.yml`）；**推送 `v*` 標籤會自動建置並發佈 Android / Windows / Linux** 三端產物（`.github/workflows/release.yml`、`win_x64.yml`、`linux_x64.yml`）。

<br/>

## 平台支援
- [x] Android
- [ ] iOS
- [ ] 平板
- [x] Windows
- [x] Linux

PiliBabel 在 Releases 提供 **Android（APK）、Windows 與 Linux** 建置；本分支暫未打包 iOS / 平板。

<br/>

## 下載

從 **Releases** 取一個建置，或複製倉庫本地建置。

### Arch Linux

感謝 [@nlsdt](https://github.com/nlsdt) 打包（PiliNara 的配方同樣適用於 PiliBabel）。

```bash
sudo pacman -S pilinara      # 來自 Arch Linux CN 倉庫
paru -S pilinara-bin         # 或經 AUR：pilinara-bin（預編譯）/ pilinara（原始碼）
```

<br/>

## 繼承功能清單（來自 PiliNara / PiliPlus）

以下全部繼承自 PiliNara（並向上追溯到 PiliPlus）；PiliBabel 在其上加了一層 AI 翻譯。

**介面與平台適配**
- [x] 依平台改套件名，多客戶端可共存（PiliBabel 可與 PiliNara 並存）
- [x] 修復小米 HyperOS 小窗下 Flutter 渲染異常（[#161086](https://github.com/flutter/flutter/issues/161086)，經 [venera#467](https://github.com/venera-app/venera/pull/467)）；Android 預測性返回動畫
- [x] 「我的」卡片順序/數量可自訂；歷史卡片預覽與「稍後再看」分區
- [x] 側邊欄自動切換與觸發寬度可調；長按/右鍵複製圖片；MD3E 風格大改版

**字型系統** —— 統一匯入池 + 內容雜湊去重，彈幕字型併入同一池，`loadFontFromList` 支援 ttc，純 ASCII 雜湊字族名。

**播放、小窗與畫質** —— 應用內小窗（拖動、縮放、SponsorBlock 跳過、自動系統 PIP、直播自救列），併發音訊播放，應用內音量最高 200%，自訂影片 CDN 網域與地區節點選擇（帶延遲測速），半屏/全屏獨立預設畫質，上滑鎖定倍速，平板鍵盤控制，直播 SuperChat 時間戳，直播粉絲親密度心跳。

**字幕、AI 與離線** —— 雙語字幕（副字幕樣式獨立），AI 字幕分析（自訂 OpenAI 相容介面、時間戳跳轉、模板、工作階段持久化、無字幕軟回退），WEBVTT/SRT 匯出，離線快取雙視圖（資料夾管理 + 中繼資料持久化），匯出下載到公共 Download 目錄（Android）。

**彈幕與封鎖** —— 合併彈幕增強縮放（[Pakku.js](https://github.com/xmcp/pakku.js) 風格），清單式視覺化正則封鎖（可匯入匯出），SponsorBlock 跳入片段，高斯核高能進度條。

**推薦 / 動態 / 評論過濾** —— 標題/UP/分區關鍵詞、時長、播放量、按讚率、已關注 UP 豁免、未授權/充電專屬過濾、共享白名單、帶貨/未授權動態、UP 自己的評論與置頂評論豁免、App+Web 合併資訊流模式。

**動態、搜尋與使用者資訊** —— UP 主備註，備註替換暱稱（覆蓋 13 處名字位），樓中樓獨立排序，本地關鍵詞搜尋過濾，b23.tv 短鏈跳轉，充電專屬徽章，隱藏推薦理由開關，硬幣經驗顯示。

**直播增強** —— 粉絲勳章佩戴面板，DLNA 投放優先 HLS，SuperChat 時間顯示，小窗底部自救控制列。

**系統整合與桌面端** —— Windows SMTC，Linux MPRIS（`audio_service_mpris`），重寫的音訊焦點處理。

<details>
<summary>完整原始功能清單（照搬自 PiliNara，點擊展開）</summary>

**feat**
編輯動態 · DLNA 投放 · 離線快取/播放 · 點擊彈幕懸停(按讚/複製/檢舉) · 播放音訊 · 跳過番劇片頭/片尾 · 安卓 `loudnorm` · Win/Mac 極驗/簡訊登入 · 影片截取動圖 · AI 原聲翻譯 · SuperChat · 播放課堂影片 · 發起投票 · 發佈動態/評論支援富文字/表情/@使用者 · 修改訊息/聊天設定 · 顯示摺疊訊息 · 檢視使用者圖文 · 動態話題 · 直播分區 · 分享至訊息 · 建立/修改/刪除關注分組 · 移除粉絲 · 直播彈幕發送表情 · 收藏夾排序 · 稍後再看分類 · WebDAV 備份/還原 · 儲存評論/動態 · 高級彈幕 · 取消/置頂評論 · 記筆記 · 多帳號支援 · 封鎖帶貨動態/評論 · 互動影片 · 發評/動態反詐 · 高能進度條 · 滑動跳轉預覽縮圖 · Live Photo · 複製/移動/排序收藏夾 · 超解析度 · 會員彩色彈幕 · 播放全部/繼續/倒序 · Cookie 登入 · 顯示影片分段資訊 · 調節字幕/全屏彈幕大小 · 收藏夾多選刪除 · 搜尋使用者動態 · 直播彈幕 · 修改資料 · 建立/編輯/刪除收藏夾 · 評論樓中樓對話/定位/排序 · 評論倒讚 · 私訊發圖 · 投幣動畫 · 取消/追番 · 取消/訂閱合集 · SponsorBlock · 顯示完整合集 · 三連/番劇三連動畫 · 帶圖評論 · 影片 TAG · 篩選搜尋 · 轉發動態 · 合集圖片 · 私訊刪除/置頂/撤回 · 檢舉 · 發佈/刪除/置頂動態

**opt**
專欄介面 · 私訊介面 · 收藏面板 · PIP · 影片封面 · 回覆介面 · 系統通知 · 評論顯示 · 亮度調節 · 影片播放 · 影片 staff · 防止 bottomsheet 遮擋全屏影片

**fix**
番劇分集按讚/投幣/收藏 · bugs

**功能**
推薦影片清單(app 端) · 最熱影片 · 熱門直播 · 番劇清單 · 黑名單封鎖 · 無痕模式 · 訪客模式；使用者(粉絲/關注/封鎖、主頁、關注取消、離線快取、稍後再看、觀看記錄、我的收藏、站內私訊)；動態(全部/投稿/番劇、評論與回覆)；播放(雙擊快進快退、播放暫停、亮度音量、上滑全屏、手勢快進、全屏方向、倍速、硬體加速、畫質/音質/解碼、彈幕、字幕、記憶播放、比例)；搜尋(熱搜、歷史、預設詞、投稿/番劇/直播/使用者、排序與時長篩選)；影片詳情(分 P 切換、按讚投幣收藏、相關影片、評論身分、排序與二樓、回覆、按讚、筆記圖)；設定(畫質/音質/解碼預設、圖片品質、主題、震動、高幀率、自動全屏、橫屏適配)

</details>

<br/>

## 免責聲明

PiliBabel 是個人興趣專案，**僅供學習與測試**；請在下載後 **24 小時內**刪除。

- PiliBabel 是**非官方第三方**客戶端，**與 bilibili 無隸屬、認可或贊助關係**。
- 所有介面均取自官方公開介面，**不提供任何破解、越權或繞過付費牆的內容**。
- **AI 翻譯執行在第三方模型介面上。** 預設是 B 站自己的免費公網 Index-Translate 服務；若你切換到自備 API，則是你所設定的那個介面。翻譯品質與合規性由使用者及其所選模型服務商負責；本專案**不託管任何模型、也不提供任何 API Key**。
- 請尊重版權與 B 站使用者協議，合理使用。

向以下開源專案的作者致敬：
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) —— PiliBabel 的直接上游
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) —— 內建引擎所呼叫的開源翻譯模型家族

若任何內容侵犯了你的權益，請聯絡我們刪除。

<br/>

## 開源協議

PiliBabel 採用 **GNU General Public License v3.0（GPL-3.0）** —— 與 PiliNara、PiliPlus、PiliPala 相同。作為衍生作品，**PiliBabel 也必須以 GPL-3.0 散佈**：你可以自由使用、研究、分享與修改，但必須保留同樣的協議、版權聲明與本協議文本。詳見 [`LICENSE`](./LICENSE)。

第三方元件（各類 Flutter 套件、[`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect)、[`media-kit`](https://github.com/media-kit/media-kit)、[`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer)、[`dio`](https://pub.dev/packages/dio) 等）仍遵循各自的協議。

<br/>

## 致謝

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) —— B 站開源的翻譯模型家族，也是內建引擎背後的免費公網介面
- 以及更多
- 靈感來自 B 站官方的「AI 介面翻譯」。

<sub><a href="#readme-languages">↑ <a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a></a></sub>

---

<a id="readme-yue"></a>

## 粵語

<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>一個有 AI 翻譯嘅第三方嗶哩嗶哩（Bilibili）客戶端。</b></p>
    <p>巴別塔 —— 拆咗語言嗰道牆，等每個人都可以用自己嘅語言睇 bilibili。</p>
    <p>含 4 種中國少數民族語言同 3 種漢語方言嘅翻譯。</p>
    <p>內置 B 站官方免費翻譯模型，裝好就即刻用得，唔使 API Key。</p>
</div>

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="主頁" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="動態" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="我嘅" />
</div>

<br/>

> **免責聲明。** PiliBabel 係一個**非官方、開源、第三方**客戶端，**同 bilibili 官方完全冇隸屬、認可或者贊助嘅關係**。所有接口都係由官方公開接口攞返嚟，**唔會提供任何破解、越權或者繞過付費嘅內容**。請完整睇 [免責聲明](#免責聲明) 同 [開源協議](#開源協議) 兩節。

## PiliBabel 係乜嘢？

PiliBabel 係**建基於 [PiliNara](https://github.com/Starfallan/PiliNara) 嘅獨立第三方分支**，完整繼承咗 PiliNara 所繼承嘅一切：

```
bilibili（官方公開接口）
        ▲
   PiliPala / PiliPalaX        — 最初嘅專案
        ▲
   PiliPlus                    — 活躍分支
        ▲
   PiliNara                    — PiliPlus 嘅分支（個人改動）
        ▲
   PiliBabel  ← 你喺呢度        — PiliNara 嘅分支
```

PiliBabel **保留晒 PiliNara / PiliPlus 嘅全部功能**（睇文末[繼承功能清單](#繼承功能清單來自-pilinara--piliplus)），再加咗上游都冇嘅一項核心能力：

> **AI 介面同內容翻譯** —— 成個應用（介面文案、影片標題、UP 主個名、評論、動態、資訊流，甚至直播彈幕）都會用**你揀嘅語言**顯示。

而且由 1.0 開始，呢件事**開箱即用**：翻譯模型係**內置**嘅。B 站開源咗自己嘅翻譯模型家族 [Index-Translate](https://github.com/bilibili/Index-Translate)，仲提供免費嘅公網接口；PiliBabel 預設就指住佢，所以**裝好一開就翻譯得** —— 唔使註冊、唔使金鑰、唔使畀錢。如果你想用自己嘅模型，自備 API 嘅入口一直都喺度，㩒一下就得。

## 主要功能

- **翻譯覆蓋成個應用。** 導覽列、影片卡片、詳情頁、評論、動態，仲有「我嘅 / 收藏 / 歷史 / 訊息 / 搜尋」各個介面 —— 全域替換覆蓋 **大約 1650+ 條介面文案**，加埋標題、UP 主個名、播放數據呢類動態內容。
- **兩個引擎，一個掣。** *內置*（預設）行 B 站官方 **Index-Translate-35B-A3B** 嘅免費接口，唔使任何設定；*自備 API* 保留本來嘅做法，可以指去任何 OpenAI 相容嘅 `/chat/completions` 接口，填自己嘅位址 / 金鑰 / 模型。AI 影片總結同 AI 翻譯**各自獨立**設定，兩個都收埋喺同一個**「AI 功能」**頁度。
- **一份語言清單，兩個引擎共用。** 目標語言清單唔會按引擎拆開，你揀邊個引擎都係同一份清單。佢將 B 站官方模型嘅 **150 種語言**同 PiliBabel 額外加嘅 **4 種中國少數民族語言同 3 種漢語方言**拼埋一齊 —— 前者係藏語、維吾爾語、壯語、苗語，後者係粵語、吳語、閩南語 —— 再加埋繁體中文。地區同字形變體**各自一條、唔會合埋**：摩洛哥 / 埃及 / 納吉迪 / 黎凡特阿拉伯語係分開嘅選項，塞爾維亞語、烏茲別克語、烏爾都語嘅西里爾 / 拉丁字形都一樣。
- **老實咁標明覆蓋範圍。** 官方清單以內嘅語言由 B 站模型負責；清單以外嗰幾隻（繁體中文，同埋 B 站冇收錄嘅上述漢語方言同少數民族語言）一樣會出現喺清單度，但會標明出嚟，等你一眼睇到想要更好嘅效果就可能要自備模型。
- **翻譯一次，之後就固定。** 每條原文**只會翻譯一次**，結果會喺本機持久儲存，再入返個介面**唔會重翻** —— 同官方客戶端同一個原則，譯文穩定、估得到。
- **逐條評論嘅「原文 ⇄ 譯文」切換**（一個細圖示，唔係一個中文字）。`@某人 / [表情] / #話題# / 連結` 會原條保留，**有超連結嘅評論一樣照譯，而條連結仲㩒得**。
- **彈幕翻譯** —— 播放器右上角控制列裏面嘅獨立開關，**預設熄咗**，開之前有一次連確認文字本身都會被翻譯嘅確認。開咗之後，播放位置之前嘅彈幕會按 **大約 15 秒一批**預先翻譯（跳去中間都會由嗰度開始，唔會由頭嚟過），通常彈幕飄到眼前嗰陣譯文已經準備好。
- **思考模式開關**（`enable_thinking`）用嚟喺質素同速度之間揀，設定頁另外有**「測試翻譯」**同**清空快取**兩個掣。
- **轉語言夠快**：分批請求 + 限流併發 + 持久快取；轉語言嗰陣當前介面會強制重建一次，唔會要你對住一堆未翻譯嘅字發呆。熄咗 AI 翻譯就會成個介面還原返原文，而且**完全唔會發任何請求**。
- **首次開機引導。** 第一次開應用嗰陣會彈一個英文對話框，問你開唔開翻譯。撳咗同意之後會：開翻譯、揀內置模型、跳去 AI 設定頁，然後即刻問你想要邊種語言 —— 新用戶㩒兩下就由「啱啱裝好」變到「已經翻譯好」。
- **全世界都播得到。** PiliBabel 會優先揀 B 站按 IP 就近派落嚟嘅海外線路（全球 **Akamai**、`mirror*ov`、`cn-hk-eq-bcache`），而唔係將你釘死喺中國大陸（阿里雲 / 深圳）節點 —— 中國大陸以外嘅用戶唔會再出現「聲仲行、畫面卡死」。當然，你都可以喺設定度自己指定 CDN。

## 兩個翻譯引擎

| | 內置（預設） | 自備 API |
|---|---|---|
| 模型 | B 站 **Index-Translate-35B-A3B** | 任何 OpenAI 相容模型 |
| 接口 | `index-translate.bilibili.com/v1` | 你自己嘅位址 |
| API Key | **唔使** | 你自己嘅 |
| 花費 | 免費 | 睇你嘅服務商 |
| 請求方式 | 每次一條 | 批次（每次 ≤ 16 條） |
| 額外語言 | — | 你嘅模型識嘅任何語言 |

**內置引擎點解要逐條請求。** Index-Translate 係翻譯**專精**模型，佢作者寫明嘅呼叫方式就係單條模板（「請將以下文本翻譯為 X，直接輸出翻譯結果」）。所以喺呢個引擎度，PiliBabel 每次都只發一條，而唔係自備 API 嗰套「編號清單 + 要求回 JSON 陣列」嘅批次提示詞。接口係免費嘅，為咗慳幾個請求而去賭批次輸出唔化算 —— 呢個係**用多少少請求量換少一大截出錯機會**嘅自覺取捨。

**由 0.3.x 升級上嚟。** 你自己配嘅 API —— 接口位址、金鑰、模型 —— **原封不動保留，唔會被改**。引擎選擇預設會落喺內置模型，所以升級之後第一次開會用 B 站嘅免費模型；去 *設定 → AI → AI 功能 → 翻譯引擎* 轉返「自備 API」，就即刻返到你原本嘅設定。

## AI 介面翻譯係點運作（技術細節）

本倉庫**完全冇 i18n / ARB 資源層** —— 介面文案全部係硬編碼中文。PiliBabel 冇重寫每個 widget，而係加咗一層薄薄嘅翻譯層喺上面：

1. **全域取詞包裝。** `lib/services/ui_translate/` 對外提供頂層函式 `uiTx(String src)`，本來寫 `Text('中文')` 嘅地方變成 `Text(uiTx('中文'))`。呢步由**腳本化 codemod** 喺全專案鋪開（`tool/ui_translate_*.py`）—— 大約 **223 個檔案 / 1650+ 條文案** —— 同時自動抆走因此失效嘅 `const`（包括 `const X<T>(...)` 呢類泛型同 `const Positioned.fill(...)` 呢類點號呼叫），並將 `static const` 嘅列表 / 映射宣告改成 `static final`。
2. **`GetxService` 核心**（`ui_translate_service.dart`）：
   - 一份持久化嘅**原文 → 譯文**快取（放喺 GetStorage），每條只翻一次、之後永久重用；
   - `tx()` 會先讀一次 `RxInt revision`，然後決定：未開 → 回原文；目標語言係**簡體中文（`zh-CN`）** → 直接回原文、**唔發請求**（B 站內容絕大多數本身就係簡體）。其他任何目標 —— 包括繁體中文、粵語、吳語、閩南語 —— 都會行引擎翻譯；**單單睇佢屬唔屬於中文家族並唔足以跳過翻譯**。跟住查快取，唔中就**入隊**；
   - 入咗隊嘅文案由 **worker 池**消化，**逐塊增量落庫**（每塊返嚟就自增 `revision`，文字遂步更新），結果**節流持久化**。批次同併發跟引擎：內置模型**每次 1 條**，自備 API **每次 ≤ 16 條、併發 ≤ 10**。
3. **引擎解析。** `TranslateProvider`（`builtin` / `custom`）決定傳輸層用邊一套位址、金鑰同模型；除此之外兩個引擎共用同一條程式路徑、同一份語言清單 —— 所以轉引擎只係一個設定項，**唔會變成兩套功能**。
4. **傳輸層**沿用同 AI 影片總結一樣、已經驗證過嘅**串流**通道 —— `AiChatService.streamChat` → `{base}/chat/completions`，帶 `stream: true`（同只支援串流嘅閘道都相容）—— 再擴展出翻譯**獨立**嘅 `apiUrl` / `apiKey` / `model` 同 `enable_thinking` 開關。呢個改動**向後相容**，影片總結唔會受影響。
5. **有佔位符嘅整句**行 `uiTxP(template, args)`：將帶 `{0}`/`{1}` 嘅整句當一個穩定 key 送去翻譯（提示詞會要求模型保留佔位符），然後再將參數填返入去 —— `"共 {0} 條"` 呢類句子就唔會譯壞啲動態部分。
6. **語言表**（`app_language.dart`）：每個 `AppLanguage` 帶顯示用嘅自稱、寫住字形 / 地區規範嘅 `toModel` 提示詞串，同一條「B 站官方清單有冇覆蓋」嘅標記。字形硬約束（簡繁）同方言一致性要求**只會經提示詞**傳畀模型，之後客戶端仲會做一次確定性嘅字形正規化執漏。
7. **評論**行 `uiTxComment(text, id)`，將 `@ / [表情] / #話題# / 連結` 當完整 token 保留；帶連結嘅富文字分段一樣照譯，同時保住連結辨識；每條評論嘅 id 集合驅動「原文 ⇄ 譯文」切換。
8. **彈幕**（`danmaku/view.dart`）：開關開咗之後，一個位置監聽器會以一秒一步行過 `[播放位置, 播放位置 + 15 秒]`，對每條彈幕內容預熱 `uiTx()`，等佢哋飄上螢幕之前就譯好；開啟嗰陣會清空同重繪畫布。
9. **儲存鍵**：`uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`。**設定介面**：一個統一嘅第一級頁「AI 功能」（`lib/pages/setting/ui_translate/`），影片總結同介面翻譯各自獨立成塊。

**全球 CDN（`VideoUtils.getCdnUrl`）。** 直鏈係簽過名嘅，改主機名會被 403 拒絕 —— 所以**播放側絕對唔會改主機**。PiliBabel 直接用 B 站按客戶端 IP 就近派落嚟嘅位址；如果候選清單本身已經有海外線路（`*.akamaized.net`、`mirror(cos|ali|hw)ov`、`cn-hk-eq-bcache`）就會優先揀佢。下載側因為換主機係安全嘅，會額外優先 Akamai 全球邊緣，並喺某條線卡死或者拒絕續傳嗰陣輪換去下一條已簽名候選。裸 `/v/resource` 嘅 P2P 直鏈照舊會退回既有中轉，避免 404。

**設計取捨 / 已知限制。** 因為係喺原地包裝字串、而唔係抽成資源，少數非 `Text` 嘅字串參數同部分富文字分段仲喺逐步補齊。嗰啲**同時做邏輯鍵**嘅字串（用 `==` 比較、當作 `简介` 呢類標籤名、或者用嚟 switch 嘅列舉標籤）**特登唔做**統一包裝，免得改壞行為。彈幕翻譯係喺滾動畫布上盡做 —— 彈幕好密嗰陣可能會先見到原文、跟住先變譯文。翻譯需要網絡；冇網絡嗰陣非中文目標自然唔會生效。內置接口係 B 站營運嘅免費公共服務，如果被限流或者用唔到，應用會明確話你知，你可以轉去自備 API。

## 建置同驗證

建置方式同 PiliNara / PiliPlus 完全一樣：打咗補丁嘅 Flutter SDK + 打咗補丁嘅 `material_ui` / `cupertino_ui` 套件，經 `lib/scripts/patch.ps1` 同 `lib/scripts/build.ps1` 處理。GitHub Actions 每次推送都會出**除錯版 APK**（`.github/workflows/ui-translate-debug.yml`）；**推送 `v*` 標籤就會自動建置同發佈 Android / Windows / Linux** 三端產物（`.github/workflows/release.yml`、`win_x64.yml`、`linux_x64.yml`）。

<br/>

## 平台支援
- [x] Android
- [ ] iOS
- [ ] 平板
- [x] Windows
- [x] Linux

PiliBabel 喺 Releases 提供 **Android（APK）、Windows 同 Linux** 建置；本分支暫時未打包 iOS / 平板。

<br/>

## 下載

去 **Releases** 攞一個建置，或者複製倉庫喺本機自己建置。

### Arch Linux

多謝 [@nlsdt](https://github.com/nlsdt) 打包（PiliNara 嘅配方一樣啱 PiliBabel 用）。

```bash
sudo pacman -S pilinara      # 由 Arch Linux CN 倉庫
paru -S pilinara-bin         # 或者經 AUR：pilinara-bin（預編譯）/ pilinara（原始碼）
```

<br/>

## 繼承功能清單（來自 PiliNara / PiliPlus）

以下全部繼承自 PiliNara（再向上追溯到 PiliPlus）；PiliBabel 喺上面加咗一層 AI 翻譯。

**介面同平台適配**
- [x] 按平台改套件名，多個客戶端可以共存（PiliBabel 可以同 PiliNara 一齊裝）
- [x] 修好小米 HyperOS 小窗下 Flutter 渲染異常（[#161086](https://github.com/flutter/flutter/issues/161086)，經 [venera#467](https://github.com/venera-app/venera/pull/467)）；Android 預測性返回動畫
- [x] 「我嘅」卡片次序 / 數量可以自訂；歷史卡片預覽同「稍後再看」分區
- [x] 側邊欄自動切換同觸發寬度可調；長㩒 / 右鍵複製圖片；MD3E 風格大改版

**字型系統** —— 統一匯入池 + 內容雜湊去重，彈幕字型併入同一個池，`loadFontFromList` 支援 ttc，純 ASCII 雜湊字族名。

**播放、小窗同畫質** —— 應用內小窗（拖動、縮放、SponsorBlock 跳過、自動系統 PIP、直播自救條），併發音訊播放，應用內音量最高 200%，自訂影片 CDN 網域同地區節點選擇（帶延遲測速），半屏 / 全屏獨立預設畫質，上滑鎖定倍速，平板鍵盤控制，直播 SuperChat 時間戳，直播粉絲親密度心跳。

**字幕、AI 同離線** —— 雙語字幕（副字幕樣式獨立），AI 字幕分析（自訂 OpenAI 相容接口、時間戳跳轉、模板、對話持久化、冇字幕軟回退），WEBVTT/SRT 匯出，離線快取雙視圖（資料夾管理 + 中繼資料持久化），匯出下載去公共 Download 目錄（Android）。

**彈幕同封鎖** —— 合併彈幕增強縮放（[Pakku.js](https://github.com/xmcp/pakku.js) 風格），清單式視覺化正則封鎖（可匯入匯出），SponsorBlock 跳入片段，高斯核高能進度條。

**推薦 / 動態 / 評論過濾** —— 標題 / UP / 分區關鍵詞、時長、播放量、讚好率、已關注 UP 豁免、未授權 / 充電專屬過濾、共享白名單、帶貨 / 未授權動態、UP 自己嘅評論同置頂評論豁免、App+Web 合併資訊流模式。

**動態、搜尋同用戶資訊** —— UP 主備註，備註替換暱稱（覆蓋 13 處名字位），樓中樓獨立排序，本地關鍵詞搜尋過濾，b23.tv 短鏈跳轉，充電專屬徽章，隱藏推薦理由開關，硬幣經驗顯示。

**直播增強** —— 粉絲勳章佩戴面板，DLNA 投放優先 HLS，SuperChat 時間顯示，小窗底部自救控制列。

**系統整合同桌面端** —— Windows SMTC，Linux MPRIS（`audio_service_mpris`），重寫嘅音訊焦點處理。

<details>
<summary>完整原始功能清單（照搬自 PiliNara，㩒開睇）</summary>

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

## 免責聲明

PiliBabel 係個人興趣專案，**只供學習同測試**；請喺下載之後 **24 小時內**刪咗佢。

- PiliBabel 係**非官方第三方**客戶端，**同 bilibili 冇隸屬、認可或者贊助關係**。
- 所有接口都係由官方公開接口攞返嚟，**唔會提供任何破解、越權或者繞過付費牆嘅內容**。
- **AI 翻譯行喺第三方模型接口上面。** 預設係 B 站自己嘅免費公網 Index-Translate 服務；如果你轉去自備 API，就係你所設定嗰個接口。翻譯質素同合規性由用戶同佢揀嘅模型服務商負責；本專案**唔會託管任何模型、亦都唔會提供任何 API Key**。
- 請尊重版權同 B 站用戶協議，合理使用。

向以下開源專案嘅作者致敬：
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) —— PiliBabel 嘅直接上游
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) —— 內置引擎所呼叫嘅開源翻譯模型家族

如果任何內容侵犯咗你嘅權益，請聯絡我哋刪除。

<br/>

## 開源協議

PiliBabel 採用 **GNU General Public License v3.0（GPL-3.0）** —— 同 PiliNara、PiliPlus、PiliPala 一樣。作為衍生作品，**PiliBabel 都必須以 GPL-3.0 散佈**：你可以自由使用、研究、分享同修改，但一定要保留同樣嘅協議、版權聲明同本協議文本。詳見 [`LICENSE`](./LICENSE)。

第三方組件（各種 Flutter 套件、[`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect)、[`media-kit`](https://github.com/media-kit/media-kit)、[`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer)、[`dio`](https://pub.dev/packages/dio) 等等）照舊跟返各自嘅協議。

<br/>

## 致謝

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) —— B 站開源嘅翻譯模型家族，亦係內置引擎背後嗰個免費公網接口
- 仲有更多
- 靈感嚟自 B 站官方嘅「AI 介面翻譯」。

<sub><a href="#readme-languages">↑ <a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a></a></sub>

---

<a id="readme-ja"></a>

## 日本語

<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>AI 翻訳機能を備えたサードパーティ製 Bilibili クライアント。</b></p>
    <p>Babel（バベル）—— 言語の壁を取り払い、誰もが自分の言語で bilibili を楽しめるように。</p>
    <p>中国の少数民族語 4 言語と中国語の方言 3 種の翻訳に対応しています。</p>
    <p>bilibili 公式の無料翻訳モデルを内蔵。インストールしたそのまま使え、API キーは不要です。</p>
</div>

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="ホーム" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="ダイナミック" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="マイページ" />
</div>

<br/>

> **免責事項。** PiliBabel は**非公式・オープンソースのサードパーティ**クライアントであり、**bilibili 社との提携・承認・スポンサー関係は一切ありません**。API はすべて公式の公開エンドポイントから取得しており、**有料コンテンツの解除やクラックは一切行いません**。[免責事項](#免責事項) と [ライセンス](#ライセンス) を必ずお読みください。

## PiliBabel とは？

PiliBabel は **[PiliNara](https://github.com/Starfallan/PiliNara) を土台にした独立したサードパーティ fork** で、PiliNara が受け継いだものすべてを引き継いでいます：

```
bilibili（公式公開 API）
        ▲
   PiliPala / PiliPalaX        — 原型プロジェクト
        ▲
   PiliPlus                    — 活発な fork
        ▲
   PiliNara                    — PiliPlus の fork（個人的な調整）
        ▲
   PiliBabel  ← ここ          — PiliNara の fork
```

PiliBabel は **PiliNara / PiliPlus の全機能をそのまま残し**（巻末の[継承機能一覧](#継承機能一覧pilinara--piliplus-由来)）、上流にはない中核機能を一つ追加しています：

> **AI による UI・コンテンツ翻訳** —— アプリ全体（UI 文言、動画タイトル、UP 主名、コメント、ダイナミック、フィード、さらにはライブの弾幕まで）を、**あなたが選んだ言語**で表示します。

しかも 1.0 以降は**インストールしたそのまま使えます**。翻訳モデルは**内蔵**です。bilibili は自社の翻訳モデルファミリー [Index-Translate](https://github.com/bilibili/Index-Translate) をオープンソース化し、無料の公開エンドポイントで提供しています。PiliBabel は最初からそこを指しているので、**入れて開けば翻訳が動きます** —— 登録もキーも課金も不要です。自分のモデルを使いたい場合も、自前 API の導線はそのまま残っていて、タップ一つで切り替えられます。

## 主な機能

- **アプリ全体を翻訳。** ナビゲーション、動画カード、詳細ページ、コメント、ダイナミック、そして「マイ / お気に入り / 履歴 / メッセージ / 検索」の各画面 —— 全体で **約 1,650 以上の UI 文字列**をカバーし、さらにタイトルや UP 主名、再生数などの動的コンテンツも対象です。
- **2 つのエンジン、1 つのスイッチ。** *内蔵*（既定）は bilibili 公式 **Index-Translate-35B-A3B** の無料エンドポイントで、設定は不要です。*自前 API* は従来どおりで、任意の OpenAI 互換 `/chat/completions` エンドポイントを、自分のベース URL / キー / モデルで使えます。AI 動画要約と AI 翻訳の設定は**完全に独立**したまま、ひとつの**「AI 機能」**ページにまとまっています。
- **言語リストは 1 つ、両エンジンで共通。** 翻訳先の言語リストはエンジンごとに分かれていません。どちらのエンジンを選んでも同じリストが使えます。bilibili 公式モデルの **150 言語**と、PiliBabel が独自に追加した **中国の少数民族語 4 言語と中国語の方言 3 種** を統合したものです —— 少数民族語はチベット語・ウイグル語・チワン語・ミャオ語、中国語の方言は広東語・呉語・閩南語 —— さらに繁體中文を加えたものです。地域・文字体系の変種は**まとめず別項目**として扱います —— モロッコ / エジプト / ナジュド / レバントのアラビア語はそれぞれ独立した選択肢で、セルビア語・ウズベク語・ウルドゥー語のキリル / ラテンも同様です。
- **対応範囲を正直に表示。** 公式リスト内の言語は bilibili のモデルが担当します。リスト外のわずかな言語（繁體中文、および bilibili が収録していない上記の中国語の方言と少数民族語）も一覧には出ますが、その旨が表示されるので、より良い結果が必要なら自前モデルが要ることが一目で分かります。
- **一度翻訳したら固定。** 各原文は**一度だけ**翻訳され、結果はローカルに永続化されるため、画面を開き直しても**再翻訳されません** —— 公式クライアントと同じ方針で、訳文が安定し予測できます。
- **コメントごとの「原文 ⇄ 訳文」切り替え**（中国語の単語ではなく小さなアイコン）。`@メンション / [絵文字] / #トピック# / リンク` はトークンとして保持され、**リンクを含むコメントも翻訳しつつリンクはクリック可能なまま**です。
- **弾幕（ダンマク）翻訳** —— プレイヤー右上のコントロール行にある独立トグルで、**既定はオフ**。有効化前に、その確認文自体も翻訳される確認ダイアログが出ます。オンにすると、再生位置より先の弾幕を **約 15 秒単位**で先読み翻訳します（途中へシークしても先頭からではなくその位置から処理します）。弾幕が流れてくる頃には訳文が用意できているのが通常です。
- **思考モードのスイッチ**（`enable_thinking`）で品質と速度を選べます。設定には**「翻訳テスト」**と**キャッシュ消去**も用意しています。
- **言語切り替えが速い**：バッチリクエスト + 同時実行数の制限 + 永続キャッシュ。言語を切り替えると現在の画面を一度だけ強制再構築するので、未翻訳のテキストを眺めたままになることはありません。AI 翻訳をオフにすると UI 全体が原文に戻り、リクエストは一切送信されません。
- **初回起動のご案内。** 初めてアプリを開いたとき、英語のダイアログで翻訳を有効にするか尋ねます。同意すると、翻訳を有効化し、内蔵モデルを選び、AI 設定ページを開き、そのまま言語を選ばせます —— 新規ユーザーは 2 タップで「インストール直後」から「翻訳済み」まで進めます。
- **世界どこでも再生できる。** PiliBabel は、あなたを中国本土（Alibaba Cloud / 深圳）ノードに固定するのではなく、bilibili が IP に応じて割り当てる海外エッジ（グローバル **Akamai**、`mirror*ov`、`cn-hk-eq-bcache`）を優先します。これにより中国本土以外のユーザーでも「音は進むのに映像が固まる」現象が起きません。設定で CDN を手動指定することもできます。

## 2 つの翻訳エンジン

| | 内蔵（既定） | 自前 API |
|---|---|---|
| モデル | bilibili **Index-Translate-35B-A3B** | OpenAI 互換なら何でも |
| エンドポイント | `index-translate.bilibili.com/v1` | あなたのベース URL |
| API キー | **不要** | あなたのもの |
| 費用 | 無料 | プロバイダの料金による |
| リクエスト | 1 回につき 1 件 | バッチ（1 回 ≤ 16 件） |
| 追加言語 | — | あなたのモデルが扱える言語 |

**内蔵エンジンが 1 件ずつ送る理由。** Index-Translate は翻訳**専用**モデルであり、作者が示す呼び出し規約は単一項目のテンプレート（「以下のテキストを X に翻訳し、翻訳結果だけを出力してください」）です。そのためこのエンジンでは、自前 API で使っている「番号付きリスト + JSON 配列で返す」バッチ用プロンプトではなく、1 回につき 1 件を送ります。エンドポイントは無料なので、リクエスト数を節約するためにバッチ出力へ賭ける価値はありません —— **リクエスト数を少し増やしてでも失敗する余地を大きく減らす**、意識的なトレードオフです。

**0.3.x からのアップグレード。** あなたが設定した API（ベース URL・キー・モデル）は**そのまま保持され、書き換えられません**。エンジンの選択は内蔵モデルが既定になるため、アップグレード後に初めて起動した時点では bilibili の無料モデルが使われます。*設定 → AI → AI 機能 → 翻訳エンジン* で「自前 API」に戻せば、元の構成に即座に復帰します。

## AI UI 翻訳の仕組み（技術的な詳細）

本リポジトリには **i18n / ARB のリソース層がありません** —— UI 文字列はすべて中国語のハードコードです。PiliBabel はすべてのウィジェットを書き換えるのではなく、薄い翻訳レイヤーを上に載せています：

1. **グローバルな取得ラッパー。** `lib/services/ui_translate/` がトップレベル関数 `uiTx(String src)` を公開します。`Text('中文')` だった箇所は `Text(uiTx('中文'))` になります。この適用は**スクリプト化された codemod**（`tool/ui_translate_*.py`）でプロジェクト全体に展開済み —— およそ **223 ファイル / 1,650 以上の文字列** —— 不要になった `const`（`const X<T>(...)` のようなジェネリクスや `const Positioned.fill(...)` のようなドット付き呼び出しを含む）を自動で外し、`static const` のリスト / マップ宣言は `static final` に変換しています。
2. **`GetxService` の中核**（`ui_translate_service.dart`）：
   - 永続的な**原文 → 訳文**キャッシュ（GetStorage 上）。各文字列は一度だけ翻訳され、以後は永久に再利用されます。
   - `tx()` はまず `RxInt revision` を読み、それから判断します：無効なら原文を返す。翻訳先が**簡体字中国語（`zh-CN`）**なら API を呼ばずに原文を返す（bilibili のコンテンツは圧倒的に簡体字のため）。それ以外の翻訳先 —— 繁體中文、広東語、呉語、閩南語を含む —— はすべてエンジンを通ります。**中国語ファミリーに属するかどうかだけでは翻訳をスキップしません。** 次にキャッシュを引き、無ければ**キューに積みます**。
   - キューに入った文字列は **worker プール**が処理し、**チャンク単位で逐次反映**します（チャンクが返るたびに `revision` を進めるのでテキストが段階的に更新されます）。結果は**スロットル付きで永続化**します。バッチサイズと同時実行数はエンジンに従います：内蔵モデルは**1 リクエスト 1 件**、自前 API は**1 回 ≤ 16 件・同時 ≤ 10**。
3. **エンジンの解決。** `TranslateProvider`（`builtin` / `custom`）が、トランスポートが使う URL・キー・モデルを決めます。それ以外のコードパスと言語リストは両エンジンで共通なので、エンジンの切り替えは設定項目ひとつであり、**機能セットが変わることはありません**。
4. **トランスポート**は AI 動画要約と同じ、実績のある**ストリーミング**経路を再利用します —— `AiChatService.streamChat` → `{base}/chat/completions` に `stream: true`（ストリーミングしかサポートしないゲートウェイとも互換）。翻訳**専用**の `apiUrl` / `apiKey` / `model` と `enable_thinking` フラグを扱えるよう拡張しています。この変更は**後方互換**で、動画要約はそのまま動作します。
5. **プレースホルダを含む文**は `uiTxP(template, args)` を使います。`{0}`/`{1}` を含む文をそのまま安定したキーとして翻訳し（プロンプトでプレースホルダの保持を指示）、後から値を差し戻します —— `"共 {0} 条"` のような文字列でも動的な部分を壊しません。
6. **言語テーブル**（`app_language.dart`）：各 `AppLanguage` は表示用の自称、文字体系・地域の規約を符号化した `toModel` プロンプト文字列、そして「bilibili 公式リストが対応しているか」のフラグを持ちます。文字体系のハード制約（簡体 / 繁体）と方言の一貫性指示は**プロンプト経由でのみ**モデルに伝わり、その後にクライアント側で決定的な字形正規化を一度かけて取りこぼしを直します。
7. **コメント**は `uiTxComment(text, id)` を通り、`@ / [絵文字] / #トピック# / リンク` をそのままトークンとして保持します。リンクを含むリッチテキストの断片も翻訳しつつリンク認識を維持し、コメントごとの id 集合が「原文 ⇄ 訳文」トグルを駆動します。
8. **弾幕**（`danmaku/view.dart`）：トグルがオンのとき、位置リスナーが `[再生位置, 再生位置 + 15 秒]` を 1 秒刻みで走査し、各弾幕の内容に対して `uiTx()` を温めます。これにより画面に流れてくる前に翻訳が済んでいます。有効化時にはキャンバスをクリアして再描画します。
9. **ストレージキー**：`uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`。**設定 UI**：ひとつの第一階層ページ「AI 機能」（`lib/pages/setting/ui_translate/`）に、AI 動画要約と AI 翻訳のブロックが独立して並びます。

**世界対応 CDN（`VideoUtils.getCdnUrl`）。** ストリーム URL は署名されており、ホスト名を書き換えると 403 で拒否されます —— そのため**再生側ではホストを絶対に書き換えません**。PiliBabel は bilibili がクライアント IP に応じて返す URL をそのまま使い、候補リストに海外エッジ（`*.akamaized.net`、`mirror(cos|ali|hw)ov`、`cn-hk-eq-bcache`）が含まれていればそれを優先します。ホスト差し替えが安全なダウンロードでは、追加でグローバル Akamai エッジを優先し、回線が止まったりレジュームを拒否された場合は次に署名済みの候補へローテーションします。生の `/v/resource`（P2P）リンクは 404 を避けるため既存の中継にフォールバックします。

**設計上のトレードオフ / 既知の制限。** 文字列をリソースへ抽出するのではなくその場で包んでいるため、`Text` 以外の文字列引数の一部とリッチテキストの一部は現在も順次対応中です。**ロジックキーを兼ねる**文字列（`==` で比較されるもの、`简介` のようなタブ名、switch で使う列挙ラベル）は、挙動を壊さないため**意図的に**一括ラップしていません。弾幕翻訳はスクロールするキャンバス上でのベストエフォートで、極端に密な弾幕では原文が一瞬見えてから訳文に変わる場合があります。翻訳にはネットワークが必要で、無ければ非中国語のターゲットは反映されません。内蔵エンドポイントは bilibili が運営する無料の公開サービスです。レート制限や停止があった場合はアプリが明示的に知らせ、自前 API へ切り替えられます。

## ビルドと検証

ビルド方法は PiliNara / PiliPlus と完全に同じです：パッチを当てた Flutter SDK と、パッチを当てた `material_ui` / `cupertino_ui` パッケージを、`lib/scripts/patch.ps1` と `lib/scripts/build.ps1` で扱います。GitHub Actions は push ごとに**デバッグ APK** を生成し（`.github/workflows/ui-translate-debug.yml`）、**`v*` タグを push すると Android / Windows / Linux の成果物を自動ビルドしてリリース**します（`.github/workflows/release.yml`、`win_x64.yml`、`linux_x64.yml`）。

<br/>

## 対応プラットフォーム
- [x] Android
- [ ] iOS
- [ ] タブレット
- [x] Windows
- [x] Linux

PiliBabel は Releases で **Android（APK）・Windows・Linux** を配布しています。本 fork では iOS / タブレットはまだパッケージしていません。

<br/>

## ダウンロード

**Releases** からビルドを取得するか、リポジトリを clone してローカルでビルドしてください。

### Arch Linux

パッケージングに感謝します（PiliNara のレシピが PiliBabel にもそのまま使えます）—— [@nlsdt](https://github.com/nlsdt)。

```bash
sudo pacman -S pilinara      # Arch Linux CN リポジトリから
paru -S pilinara-bin         # または AUR 経由：pilinara-bin（ビルド済）/ pilinara（ソース）
```

<br/>

## 継承機能一覧（PiliNara / PiliPlus 由来）

以下はすべて PiliNara（さらに遡って PiliPlus）から引き継いだものです。PiliBabel はその上に AI 翻訳レイヤーを追加しています。

**UI とプラットフォーム適応**
- [x] プラットフォームごとにパッケージ名を変更し、複数クライアントが共存可能（PiliBabel は PiliNara と並んでインストールできます）
- [x] Xiaomi HyperOS の小窓での Flutter 描画不具合を修正（[#161086](https://github.com/flutter/flutter/issues/161086)、[venera#467](https://github.com/venera-app/venera/pull/467) 経由）。Android の予測型バックアニメーション
- [x] 「マイ」カードの並び順・枚数をカスタマイズ可能。履歴カードのプレビューと「後で見る」セクション
- [x] サイドバーの自動切り替えとトリガー幅の調整。長押し / 右クリックで画像コピー。MD3E スタイルの大規模刷新

**フォントシステム** —— 統合インポートプールと内容ハッシュによる重複排除、弾幕フォントも同じプールへ統合、ttc 対応の `loadFontFromList`、純 ASCII のハッシュファミリー名。

**再生・小窓・画質** —— アプリ内小窓（ドラッグ、リサイズ、SponsorBlock スキップ、システム PIP 自動化、ライブ自救バー）、同時音声再生、アプリ内音量は最大 200%、カスタム動画 CDN ドメインと地域ノード選択（遅延測定付き）、半画面 / 全画面で別々の既定画質、上スワイプで倍速ロック、タブレットのキーボード操作、ライブ SuperChat の時刻表示、ライブのファン親密度ハートビート。

**字幕・AI・オフライン** —— 二言語字幕（副字幕のスタイルは独立）、AI 字幕解析（カスタム OpenAI 互換エンドポイント、タイムスタンプジャンプ、テンプレート、会話の永続化、字幕なしへのソフトフォールバック）、WEBVTT/SRT 書き出し、オフラインキャッシュの二面ビュー（フォルダ管理とメタデータ永続化）、書き出しを公開 Download フォルダへ保存（Android）。

**弾幕とブロック** —— 統合弾幕の拡大表示（[Pakku.js](https://github.com/xmcp/pakku.js) 風）、リスト形式の視覚的な正規表現ブロック（インポート / エクスポート対応）、SponsorBlock のセグメント内スキップ、ガウス核による高エネルギー進行バー。

**おすすめ / ダイナミック / コメントのフィルタ** —— タイトル / UP / チャンネルのキーワード、長さ、再生数、いいね率、フォロー中 UP の除外、未許諾 / 有料限定のフィルタ、共有ホワイトリスト、商用 / 未許諾ダイナミック、UP 自身のコメントとピン留めコメントの除外、App + Web 統合フィードモード。

**ダイナミック・検索・ユーザー情報** —— UP 主へのメモ、メモでニックネームを置換（13 か所の名前スロット）、ネスト返信の独立ソート、ローカルキーワード検索フィルタ、b23.tv 短縮リンクの遷移、有料限定バッジ、おすすめ理由を隠すトグル、コイン経験値の表示。

**ライブ強化** —— ファンメダル着用パネル、DLNA キャストの HLS 優先、SuperChat の時刻表示、小窓下部の自救コントロールバー。

**システム連携・デスクトップ** —— Windows SMTC、Linux MPRIS（`audio_service_mpris`）、音声フォーカス処理の再実装。

<details>
<summary>元の機能チェックリスト全文（PiliNara からそのまま、クリックで展開）</summary>

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

## 免責事項

PiliBabel は個人的な関心によるプロジェクトで、**学習と検証のみ**を目的としています。ダウンロード後 **24 時間以内**に削除してください。

- PiliBabel は**非公式のサードパーティ**クライアントであり、**bilibili との提携・承認・スポンサー関係はありません**。
- API はすべて公式の公開エンドポイントから取得しており、**クラック・過剰な権限・課金回避にあたるコンテンツは一切提供しません**。
- **AI 翻訳はサードパーティのモデルエンドポイント上で動作します。** 既定では bilibili 自身の無料公開 Index-Translate サービス、自前 API に切り替えた場合はあなたが設定したエンドポイントです。翻訳の品質とコンプライアンスは、ユーザーと選択したモデル提供者の責任です。本プロジェクトは**モデルを一切ホストせず、API キーも提供しません**。
- 著作権と bilibili の利用規約を尊重し、責任を持ってご利用ください。

以下のオープンソースプロジェクトとその作者に敬意を表します：
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) —— PiliBabel の直接の親プロジェクト
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) —— 内蔵エンジンが呼び出すオープンソースの翻訳モデルファミリー

権利を侵害する内容があれば、ご連絡いただければ削除します。

<br/>

## ライセンス

PiliBabel は **GNU General Public License v3.0（GPL-3.0）** でライセンスされています —— PiliNara、PiliPlus、PiliPala と同じです。派生作品であるため、**PiliBabel も GPL-3.0 で配布される必要があります**：同一のライセンス、著作権表示、および本ライセンス文を保持する限り、自由に使用・研究・共有・改変できます。詳しくは [`LICENSE`](./LICENSE) をご覧ください。

サードパーティのコンポーネント（各種 Flutter パッケージ、[`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect)、[`media-kit`](https://github.com/media-kit/media-kit)、[`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer)、[`dio`](https://pub.dev/packages/dio) など）は、それぞれのライセンスに従います。

<br/>

## 謝辞

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) —— bilibili がオープンソース化した翻訳モデルファミリーであり、内蔵エンジンの背後にある無料公開エンドポイント
- そのほか多数
- bilibili 公式の「AI インターフェース翻訳」に着想を得ています。

<sub><a href="#readme-languages">↑ <a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a></a></sub>
