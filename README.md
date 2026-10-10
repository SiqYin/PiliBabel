<div align="center">
    <p><b>PiliBabel</b></p>
    <p><a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a> · <a href="#readme-fr">Français</a> · <a href="#readme-de">Deutsch</a> · <a href="#readme-es">Español</a> · <a href="#readme-ko">한국어</a> · <a href="#readme-ar">العربية</a> · <a href="#readme-vi">Tiếng Việt</a> · <a href="#readme-ms">Bahasa Melayu</a> · <a href="#readme-id">Bahasa Indonesia</a></p>
    <p><sub>Pick your language above — the links jump within this page, no need to open another file. Other languages are collapsed; click a language name to expand it.</sub></p>
</div>

<a id="readme-languages"></a>

---

<details open>
<summary><b>English</b></summary>

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

<sub><a href="#readme-languages">↑ <a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a> · <a href="#readme-fr">Français</a> · <a href="#readme-de">Deutsch</a> · <a href="#readme-es">Español</a> · <a href="#readme-ko">한국어</a> · <a href="#readme-ar">العربية</a> · <a href="#readme-vi">Tiếng Việt</a> · <a href="#readme-ms">Bahasa Melayu</a> · <a href="#readme-id">Bahasa Indonesia</a></a></sub>

</details>

---

<details>
<summary><b>中文</b></summary>

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
    <img src="assets/screenshots/readme_zh_home.jpg" width="32%" alt="首頁" />
    <img src="assets/screenshots/readme_zh_dynamics.jpg" width="32%" alt="動態" />
    <img src="assets/screenshots/readme_zh_mine.jpg" width="32%" alt="我的" />
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

<sub><a href="#readme-languages">↑ <a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a> · <a href="#readme-fr">Français</a> · <a href="#readme-de">Deutsch</a> · <a href="#readme-es">Español</a> · <a href="#readme-ko">한국어</a> · <a href="#readme-ar">العربية</a> · <a href="#readme-vi">Tiếng Việt</a> · <a href="#readme-ms">Bahasa Melayu</a> · <a href="#readme-id">Bahasa Indonesia</a></a></sub>

</details>

---

<details>
<summary><b>粵語</b></summary>

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
    <img src="assets/screenshots/readme_zh_home.jpg" width="32%" alt="主頁" />
    <img src="assets/screenshots/readme_zh_dynamics.jpg" width="32%" alt="動態" />
    <img src="assets/screenshots/readme_zh_mine.jpg" width="32%" alt="我嘅" />
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

<sub><a href="#readme-languages">↑ <a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a> · <a href="#readme-fr">Français</a> · <a href="#readme-de">Deutsch</a> · <a href="#readme-es">Español</a> · <a href="#readme-ko">한국어</a> · <a href="#readme-ar">العربية</a> · <a href="#readme-vi">Tiếng Việt</a> · <a href="#readme-ms">Bahasa Melayu</a> · <a href="#readme-id">Bahasa Indonesia</a></a></sub>

</details>

---

<details>
<summary><b>日本語</b></summary>

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
    <img src="assets/screenshots/readme_ja_home.jpg" width="32%" alt="ホーム" />
    <img src="assets/screenshots/readme_ja_dynamics.jpg" width="32%" alt="ダイナミック" />
    <img src="assets/screenshots/readme_ja_mine.jpg" width="32%" alt="マイページ" />
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

<sub><a href="#readme-languages">↑ <a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a> · <a href="#readme-fr">Français</a> · <a href="#readme-de">Deutsch</a> · <a href="#readme-es">Español</a> · <a href="#readme-ko">한국어</a> · <a href="#readme-ar">العربية</a> · <a href="#readme-vi">Tiếng Việt</a> · <a href="#readme-ms">Bahasa Melayu</a> · <a href="#readme-id">Bahasa Indonesia</a></a></sub>

</details>

---

<details>
<summary><b>Français</b></summary>

<a id="readme-fr"></a>

## Français

<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Un client Bilibili tiers avec traduction par IA.</b></p>
    <p>Babel — abattre la barrière de la langue, pour que chacun profite de bilibili dans la sienne.</p>
    <p>Comprend la traduction de 4 langues des minorités ethniques de Chine et de 3 dialectes chinois.</p>
    <p>La traduction fonctionne dès l'installation, sur le modèle gratuit de bilibili — aucune clé d'API requise.</p>
</div>

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Accueil" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dynamiques" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Moi" />
</div>

<br/>

> **Avertissement.** PiliBabel est un client **non officiel, open source et tiers**. Il n'est **ni affilié à, ni approuvé par, ni sponsorisé par** bilibili / bilibili Inc. Toutes les API proviennent des points d'accès publics officiels ; **aucun contenu payant n'est déverrouillé ni piraté**. Merci de lire en entier les sections [Avertissement](#avertissement) et [Licence](#licence).

## Qu'est-ce que PiliBabel ?

PiliBabel est un **fork tiers indépendant construit au-dessus de [PiliNara](https://github.com/Starfallan/PiliNara)**, et il hérite de tout ce dont PiliNara hérite :

```
bilibili (API publique officielle)
        ▲
   PiliPala / PiliPalaX        — le projet d'origine
        ▲
   PiliPlus                    — fork actif
        ▲
   PiliNara                    — fork de PiliPlus (ajustements personnels)
        ▲
   PiliBabel  ← vous êtes ici   — fork de PiliNara
```

PiliBabel conserve **toutes les fonctionnalités de PiliNara / PiliPlus** (voir le [journal des fonctionnalités héritées](#journal-des-fonctionnalités-héritées-de-pilinara--piliplus) en bas de page) et ajoute **une capacité phare que les clients amont n'ont pas** :

> **Traduction d'interface et de contenu par IA** — toute l'application (libellés d'interface, titres de vidéos, noms des UP, commentaires, dynamiques, fil d'actualité et même les danmaku en direct) s'affiche dans la langue **que vous** choisissez.

Et depuis la 1.0, cela fonctionne **dès l'installation** : le modèle de traduction est **intégré**. bilibili a ouvert son propre modèle de traduction, [Index-Translate](https://github.com/bilibili/Index-Translate), servi par un point d'accès public gratuit. PiliBabel pointe dessus par défaut : la traduction marche dès que vous installez l'application — sans inscription, sans clé, sans facture. Si vous préférez votre propre modèle, la voie « API personnelle » est toujours là, à un clic.

## Fonctionnalités principales

- **La traduction par IA, partout.** Barres de navigation, cartes vidéo, pages de détail, commentaires, dynamiques, ainsi que les écrans Moi / Favoris / Historique / Messages / Recherche — un balayage global couvre **environ 1 650 chaînes d'interface**, plus le contenu dynamique (titres, noms d'auteurs, compteurs).
- **Deux moteurs, un seul réglage.** *Intégré* (par défaut) utilise le point d'accès gratuit du modèle officiel **Index-Translate-35B-A3B** de bilibili — rien à configurer. *API personnelle* conserve le comportement précédent : pointez-le vers n'importe quel point d'accès `/chat/completions` compatible OpenAI, avec votre propre URL de base / clé / modèle. Le résumé vidéo par IA et la traduction par IA gardent des points d'accès et des réglages **totalement indépendants**, réunis dans une seule page **« Fonctions IA »**.
- **Une seule liste de langues, pour les deux moteurs.** La liste des langues cibles n'est pas scindée selon le moteur : c'est la même quel que soit celui que vous choisissez. Elle réunit les **150 langues** du modèle officiel de bilibili et les **4 langues des minorités ethniques de Chine et 3 dialectes chinois** que PiliBabel ajoute — tibétain, ouïghour, zhuang et hmong d'un côté ; cantonais, wu (shanghaïen) et minnan de l'autre — plus le chinois traditionnel. Les variantes régionales et d'écriture restent des **entrées distinctes** plutôt que d'être fusionnées : l'arabe marocain / égyptien / najdi / levantin sont chacun leur propre choix, tout comme le serbe, l'ouzbek et l'urdu en cyrillique ou en latin.
- **Franc sur la couverture.** Les langues incluses dans l'inventaire officiel sont couvertes par le modèle de bilibili. Les quelques-unes qui en sont absentes — chinois traditionnel, et les dialectes chinois et langues minoritaires ci-dessus que bilibili ne référence pas — apparaissent quand même dans la liste, signalées comme telles, pour que vous sachiez d'un coup d'œil qu'un meilleur résultat peut nécessiter votre propre modèle.
- **Traduit une fois, puis figé.** Chaque chaîne source est traduite **exactement une fois** ; le résultat est conservé localement et **jamais retraduit** quand vous rouvrez un écran — le même principe que le client officiel, pour des traductions stables et prévisibles.
- **Bascule Original ⇄ Traduction commentaire par commentaire** (une petite icône, pas un mot). Les `@mentions / [émojis] / #sujets# / liens` sont préservés comme jetons, et **les commentaires contenant des hyperliens sont traduits tout en gardant le lien cliquable**.
- **Traduction des danmaku** — un interrupteur indépendant dans la barre de contrôle en haut à droite du lecteur, **désactivé par défaut** et soumis à une confirmation dont le texte est lui-même traduit. Une fois activé, les danmaku en avance sur la tête de lecture sont prétraduits par **lots d'environ 15 secondes** (un saut au milieu est traité correctement, pas depuis le début), si bien que la traduction est généralement prête quand ils défilent.
- **Interrupteur du mode réflexion** (`enable_thinking`) pour arbitrer entre qualité et rapidité, plus des boutons **« tester la traduction »** et **vider le cache** dans les réglages.
- **Changement de langue rapide** : requêtes par lots avec concurrence limitée sur un cache persistant ; changer de langue reconstruit une fois l'écran courant, pour ne pas vous laisser devant du texte non traduit. Désactiver la traduction par IA restaure tout l'affichage en texte d'origine et n'envoie **absolument aucune requête**.
- **Prise en main au premier lancement.** À la première ouverture, une boîte de dialogue en anglais propose d'activer la traduction. En acceptant, elle active la traduction, sélectionne le modèle intégré, ouvre la page de réglages IA et demande immédiatement quelle langue vous voulez — un nouvel utilisateur passe de « tout juste installé » à « application traduite » en deux appuis.
- **Une lecture qui marche partout dans le monde.** PiliBabel sélectionne le point de terminaison étranger (global **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) que le `playurl` géo-routé de bilibili propose déjà, au lieu de vous épingler sur un nœud continental (Alibaba Cloud / Shenzhen) — les utilisateurs hors de Chine continentale ne subissent donc plus les blocages « le son continue, l'image se figent ». Vous pouvez toujours épingler un CDN manuellement dans les réglages.

## Les deux moteurs de traduction

| | Intégré (par défaut) | API personnelle |
|---|---|---|
| Modèle | bilibili **Index-Translate-35B-A3B** | n'importe quel modèle compatible OpenAI |
| Point d'accès | `index-translate.bilibili.com/v1` | votre URL de base |
| Clé d'API | **inutile** | la vôtre |
| Coût | gratuit | selon votre fournisseur |
| Requêtes | une chaîne par requête | par lots (≤ 16 par requête) |
| Langues supplémentaires | — | toute langue que votre modèle connaît |

**Pourquoi une requête par chaîne pour le moteur intégré.** Index-Translate est un modèle **spécialisé** en traduction, et la convention d'appel documentée par ses auteurs est un gabarit à un seul élément (« traduis le texte suivant en X, ne renvoie que la traduction »). PiliBabel envoie donc une chaîne par requête sur ce moteur, plutôt que le prompt par lots « liste numérotée / tableau JSON » utilisé pour une API personnelle. Le point d'accès est gratuit : il n'y a rien à gagner à parier sur une sortie par lots — c'est un compromis délibéré : quelques requêtes de plus contre beaucoup moins de façons d'échouer.

**Mise à niveau depuis la 0.3.x.** Vos réglages d'API personnelle — URL de base, clé et modèle — sont **laissés exactement tels que vous les avez configurés**. Le choix du moteur passe simplement au modèle intégré : au premier lancement après la mise à niveau, vous serez donc sur le modèle gratuit de bilibili ; ouvrez *Réglages → IA → Fonctions IA → moteur de traduction* et repassez à *API personnelle* pour revenir instantanément à votre configuration.

## Comment fonctionne la traduction d'interface (technique)

Le dépôt n'a **aucune couche de ressources i18n / ARB** — les chaînes d'interface sont en chinois en dur. Plutôt que de réécrire chaque widget, PiliBabel ajoute une fine couche de traduction par-dessus :

1. **Un habillage de recherche global.** `lib/services/ui_translate/` expose une fonction de premier niveau `uiTx(String src)`. Un `Text('中文')` devient `Text(uiTx('中文'))`. Un **codemod scripté** l'a appliqué à tout le projet (`tool/ui_translate_*.py`) — environ **223 fichiers / 1 650 chaînes** — en retirant automatiquement le mot-clé `const` devenu invalide là où c'était nécessaire (y compris les génériques comme `const X<T>(...)` et les noms pointés comme `const Positioned.fill(...)`), et en convertissant les déclarations `static const` de listes / maps en `static final`.
2. **Un cœur `GetxService`** (`ui_translate_service.dart`) :
   - un cache persistant **source → traduction** (adossé à GetStorage), donc chaque chaîne est traduite une fois et réutilisée pour toujours ;
   - `tx()` lit d'abord un `RxInt revision`, puis décide : si désactivé → retourne l'original ; si la cible est le **chinois simplifié (`zh-CN`)** → retourne l'original sans requête API (le contenu de bilibili est très majoritairement en chinois simplifié). Toute autre cible — y compris le chinois traditionnel, le cantonais, le wu et le minnan — passe par le moteur configuré ; appartenir à la famille chinoise ne suffit pas à sauter la traduction. Ensuite : servir depuis le cache ou **mettre en file** ;
   - les chaînes en file sont traitées par un **pool de workers** avec **application incrémentale par bloc** (chaque bloc renvoyé incrémente `revision`, le texte se met donc à jour progressivement), et les résultats sont **persistés** (avec limitation de fréquence). La taille des lots et la concurrence suivent le moteur : **1 par requête** sur le modèle intégré, **≤ 16 avec ≤ 10 en vol** sur votre propre API.
3. **Résolution du moteur.** `TranslateProvider` (`builtin` / `custom`) détermine l'URL, la clé et le modèle utilisés par la couche de transport ; à cela près, les deux moteurs partagent un seul chemin de code et une seule liste de langues — changer de moteur est donc un simple réglage, **jamais un autre jeu de fonctionnalités**.
4. **Le transport** réutilise le même canal **en flux** que le résumé vidéo par IA — `AiChatService.streamChat` → `{base}/chat/completions` avec `stream: true` (compatible avec les passerelles qui ne gèrent que le flux) — étendu pour que la traduction puisse utiliser ses **propres** `apiUrl` / `apiKey` / `model` et un drapeau `enable_thinking`. Le changement est **rétrocompatible**, le résumé vidéo continue de fonctionner tel quel.
5. **Les phrases interpolées** passent par `uiTxP(template, args)` : une phrase entière avec des marqueurs `{0}`/`{1}` est traduite comme une clé stable (le prompt demande au modèle de conserver les marqueurs), puis les valeurs sont réinjectées — les chaînes du type `"共 {0} 条"` se traduisent donc sans abîmer les parties dynamiques.
6. **Table des langues** (`app_language.dart`) : chaque `AppLanguage` porte un autonyme d'affichage, une chaîne de prompt `toModel` qui encode les conventions d'écriture et de région, et un indicateur précisant si l'inventaire officiel de bilibili la couvre. Les règles d'écriture (simplifié / traditionnel) et les consignes de cohérence dialectale n'atteignent le modèle **que par le prompt**, et une passe déterministe de normalisation côté client corrige ensuite les caractères récalcitrants.
7. **Les commentaires** passent par `uiTxComment(text, id)`, en gardant `@ / [émojis] / #sujet# / lien` comme jetons intacts ; les segments de texte riche portant des liens sont traduits tout en préservant la reconnaissance des liens, et un ensemble d'identifiants par commentaire pilote la bascule Original ⇄ Traduction.
8. **Danmaku** (`danmaku/view.dart`) : lorsque son interrupteur est activé, un écouteur de position parcourt `[tête de lecture, tête de lecture + 15 s]` seconde par seconde et préchauffe `uiTx()` sur le contenu de chaque danmaku, si bien que les éléments sont prétraduits avant d'atteindre l'écran ; l'activation vide et redessine le canevas.
9. **Clés de stockage** : `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Interface de réglages** : une seule page de premier niveau « Fonctions IA » (`lib/pages/setting/ui_translate/`), avec des blocs indépendants pour le résumé vidéo IA et la traduction d'interface.

**CDN mondial (`VideoUtils.getCdnUrl`).** Les URL de flux sont signées, et réécrire l'hôte d'une URL la fait rejeter en 403 — la lecture ne réécrit donc jamais l'hôte. PiliBabel renvoie l'URL géo-routée que bilibili remet à l'IP du client, et lorsque la liste de candidats contient déjà un point de terminaison étranger (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`) c'est celui-là qui est préféré. Les téléchargements, où un échange d'hôte est sans risque, préfèrent en plus le point de terminaison Akamai mondial et passent au candidat signé suivant lorsqu'une ligne se bloque ou refuse une reprise. Les liens P2P bruts `/v/resource` retombent toujours sur le relais existant pour éviter les 404.

**Compromis de conception / limites connues.** Comme les chaînes sont habillées sur place plutôt qu'extraites en ressources, quelques paramètres de chaîne non `Text` et certains segments de texte riche sont encore complétés progressivement. Les chaînes qui servent aussi de **clés logiques** (comparées avec `==`, utilisées comme noms d'onglet tels que `简介`, ou comme libellés d'énumération dans des switch) ne sont **délibérément pas** habillées en bloc, afin de ne pas casser le comportement. La traduction des danmaku est faite au mieux sur un canevas défilant — sous des danmaku très denses, vous pouvez brièvement voir l'original avant que la traduction n'arrive. La traduction nécessite un réseau ; sans lui, les cibles non chinoises ne prennent simplement pas effet. Le point d'accès intégré est un service public gratuit exploité par bilibili — s'il est un jour limité en débit ou indisponible, l'application vous le signale et vous pouvez passer à votre propre API.

## Compilation et vérification

L'application se compile avec un SDK Flutter patché ainsi que des paquets `material_ui` / `cupertino_ui` patchés, via `lib/scripts/patch.ps1` et `lib/scripts/build.ps1` (exactement comme PiliNara / PiliPlus). GitHub Actions produit un **APK de débogage** à chaque push (`.github/workflows/ui-translate-debug.yml`), et **publier un tag `v*` compile et publie automatiquement les artefacts Android, Windows et Linux** (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Plateformes
- [x] Android
- [ ] iOS
- [ ] Tablette
- [x] Windows
- [x] Linux

PiliBabel fournit des compilations **Android (APK), Windows et Linux** dans les Releases ; iOS et tablette ne sont pas encore empaquetés dans ce fork.

<br/>

## Téléchargement

Récupérez une compilation dans les **Releases**, ou clonez le dépôt et compilez-le localement.

### Arch Linux

Merci à [@nlsdt](https://github.com/nlsdt) pour l'empaquetage (la recette PiliNara vaut aussi pour PiliBabel).

```bash
sudo pacman -S pilinara      # via le dépôt Arch Linux CN
paru -S pilinara-bin         # ou via AUR : pilinara-bin (précompilé) / pilinara (source)
```

<br/>

## Journal des fonctionnalités héritées (de PiliNara / PiliPlus)

Tout ce qui suit provient de PiliNara (et, transitivement, de PiliPlus) ; PiliBabel ajoute la couche de traduction par IA par-dessus.

**Interface et adaptation aux plateformes**
- [x] Application renommée par plateforme pour que plusieurs clients coexistent (PiliBabel s'installe à côté de PiliNara)
- [x] Rendu Flutter corrigé sous la mini-fenêtre de Xiaomi HyperOS ([#161086](https://github.com/flutter/flutter/issues/161086), via [venera#467](https://github.com/venera-app/venera/pull/467)) ; animation de retour prédictif sous Android
- [x] Ordre et nombre des cartes « Moi » personnalisables ; aperçu des cartes d'historique et section « regarder plus tard »
- [x] Bascule automatique de la barre latérale avec largeur de déclenchement réglable ; copie d'image par appui long / clic droit ; grande refonte de style MD3E

**Système de polices** — un pool d'import unifié avec déduplication par hachage de contenu, les polices de danmaku fusionnées dans le même pool, `loadFontFromList` avec prise en charge des ttc, et des noms de famille de police en ASCII pur.

**Lecture, mini-fenêtre et qualité** — mini-fenêtre intégrée (glisser, redimensionner, saut SponsorBlock, PIP système automatique, barre d'auto-récupération pour le direct), lecture audio concurrente, volume intégré jusqu'à 200 %, domaine CDN vidéo personnalisé et sélection de nœud régional avec test de latence, qualité par défaut distincte en demi-écran et plein écran, verrouillage de la vitesse par balayage vers le haut, contrôle clavier sur tablette, horodatage des SuperChat en direct, battement de cœur pour l'intimité des fans en direct.

**Sous-titres, IA et hors ligne** — sous-titres bilingues avec style indépendant du sous-titre secondaire, analyse de sous-titres par IA (point d'accès compatible OpenAI personnalisé, saut à l'horodatage, gabarits, conversations persistées, repli doux sans sous-titre), export WEBVTT/SRT, double vue du cache hors ligne avec gestion des dossiers et persistance des métadonnées, export des téléchargements vers le dossier Download public (Android).

**Danmaku et blocage** — mise à l'échelle améliorée des danmaku fusionnés (à la [Pakku.js](https://github.com/xmcp/pakku.js)), blocage par expressions régulières visuelles sous forme de liste avec import/export, saut dans le segment SponsorBlock, barre de progression à haute énergie par noyau gaussien.

**Filtrage des recommandations / dynamiques / commentaires** — mots-clés de titre / UP / chaîne, durée, nombre de vues, taux de likes, exemption des UP suivis, filtrage des vidéos non autorisées / réservées aux abonnés, liste blanche partagée, dynamiques commerciales / non autorisées, exemption des commentaires de l'UP et des commentaires épinglés, mode de fil fusionné App + Web.

**Dynamiques, recherche et informations utilisateur** — notes personnalisées pour les UP, note remplaçant le pseudo sur 13 emplacements, tri indépendant des réponses imbriquées, filtre de recherche par mot-clé local, saut des liens courts b23.tv, badge « réservé aux abonnés », réglage pour masquer la raison de recommandation, affichage de l'XP des pièces.

**Améliorations du direct** — panneau de port du fan-medal, diffusion DLNA privilégiant HLS, affichage de l'heure des SuperChat, barre de contrôle inférieure de la mini-fenêtre pour l'auto-récupération.

**Intégration système et bureau** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), gestion du focus audio réécrite.

<details>
<summary>Liste complète des fonctionnalités d'origine (verbatim, de PiliNara — cliquez pour déplier)</summary>

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

## Avertissement

PiliBabel est un projet personnel, motivé par l'intérêt, fourni **à des fins d'apprentissage et de test uniquement** ; merci de le supprimer dans les **24 heures** suivant le téléchargement.

- PiliBabel est un client **tiers non officiel** et n'est **ni affilié à, ni approuvé par, ni sponsorisé par bilibili**.
- Toutes les API proviennent de points d'accès publics officiels ; **aucun contenu piraté, sur-privilégié ou contournant un paywall** n'est fourni.
- **La traduction par IA s'exécute sur un point d'accès de modèle tiers.** Par défaut, il s'agit du service public gratuit Index-Translate de bilibili lui-même ; si vous passez à votre propre API, il s'agit du point d'accès que vous avez configuré. La qualité et la conformité des traductions relèvent de l'utilisateur et du fournisseur de modèle choisi ; ce projet **n'héberge aucun modèle et aucune clé d'API**.
- Respectez le droit d'auteur et les conditions d'utilisation de bilibili. Utilisez-le de manière responsable.

Avec le respect dû aux auteurs d'origine et amont pour leur engagement open source :
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — le projet parent direct de PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — la famille de modèles de traduction open source appelée par le moteur intégré

Si un contenu porte atteinte à vos droits, contactez-nous pour son retrait.

<br/>

## Licence

PiliBabel est distribué sous **GNU General Public License v3.0 (GPL-3.0)** — la même licence que PiliNara, PiliPlus et PiliPala. Parce qu'il s'agit d'une œuvre dérivée, **PiliBabel doit également être distribué sous GPL-3.0** : vous êtes libre de l'utiliser, de l'étudier, de le partager et de le modifier, à condition de conserver la même licence, les mentions de copyright et ce texte de licence. Voir [`LICENSE`](./LICENSE).

Les composants tiers (paquets Flutter, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), etc.) restent sous leurs propres licences.

<br/>

## Remerciements

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — la famille de modèles de traduction open source de bilibili, et le point d'accès public gratuit derrière le moteur intégré
- et bien d'autres
- Inspiré par la « traduction d'interface par IA » officielle de bilibili.

<sub><a href="#readme-languages">↑ <a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a> · <a href="#readme-fr">Français</a> · <a href="#readme-de">Deutsch</a> · <a href="#readme-es">Español</a> · <a href="#readme-ko">한국어</a> · <a href="#readme-ar">العربية</a> · <a href="#readme-vi">Tiếng Việt</a> · <a href="#readme-ms">Bahasa Melayu</a> · <a href="#readme-id">Bahasa Indonesia</a></a></sub>

</details>

---

<details>
<summary><b>Deutsch</b></summary>

<a id="readme-de"></a>

## Deutsch

<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Ein Bilibili-Client von Drittanbietern mit KI-Übersetzung.</b></p>
    <p>Babel — die Sprachbarriere einreißen, damit jede und jeder bilibili in der eigenen Sprache genießen kann.</p>
    <p>Enthält Übersetzungen für 4 Sprachen der ethnischen Minderheiten Chinas und 3 chinesische Dialekte.</p>
    <p>Die Übersetzung läuft direkt nach der Installation über bilibilis kostenloses Modell — kein API-Schlüssel nötig.</p>
</div>

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Startseite" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dynamik" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Ich" />
</div>

<br/>

> **Haftungsausschluss.** PiliBabel ist ein **inoffizieller, quelloffener Client von Drittanbietern**. Er ist **weder mit bilibili / bilibili Inc. verbunden noch von ihnen unterstützt oder gesponsert**. Sämtliche APIs stammen aus offiziellen öffentlichen Endpunkten; **es werden keine kostenpflichtigen Inhalte freigeschaltet oder geknackt**. Bitte lies die Abschnitte [Haftungsausschluss](#haftungsausschluss) und [Lizenz](#lizenz) vollständig.

## Was ist PiliBabel?

PiliBabel ist ein **unabhängiger Fork von Drittanbietern auf Basis von [PiliNara](https://github.com/Starfallan/PiliNara)** und erbt alles, was PiliNara erbt:

```
bilibili (offizielle öffentliche API)
        ▲
   PiliPala / PiliPalaX        — das ursprüngliche Projekt
        ▲
   PiliPlus                    — aktiv gepflegter Fork
        ▲
   PiliNara                    — Fork von PiliPlus (persönliche Anpassungen)
        ▲
   PiliBabel  ← du bist hier    — Fork von PiliNara
```

PiliBabel behält **alle Funktionen von PiliNara / PiliPlus** (siehe das [Verzeichnis der übernommenen Funktionen](#verzeichnis-der-übernommenen-funktionen-aus-pilinara--piliplus) weiter unten) und fügt **eine Kernfähigkeit hinzu, die die vorgelagerten Clients nicht haben**:

> **KI-Übersetzung von Oberfläche und Inhalten** — die gesamte App (Beschriftungen, Videotitel, Namen der UP, Kommentare, Dynamik, Feed und sogar Live-Danmaku) erscheint in der Sprache, **die du** wählst.

Und seit 1.0 funktioniert das **direkt nach der Installation**: Das Übersetzungsmodell ist **eingebaut**. bilibili hat sein eigenes Übersetzungsmodell [Index-Translate](https://github.com/bilibili/Index-Translate) quelloffen veröffentlicht und betreibt es über einen kostenlosen öffentlichen Endpunkt. PiliBabel zeigt standardmäßig darauf — die Übersetzung läuft also, sobald du die App installierst: keine Anmeldung, kein Schlüssel, keine Rechnung. Wenn du lieber dein eigenes Modell nutzt, bleibt der Weg über die eigene API bestehen, einen Tipp entfernt.

## Hauptfunktionen

- **KI-Übersetzung, überall.** Navigationsleisten, Videokarten, Detailseiten, Kommentare, Dynamik sowie die Bereiche Ich / Favoriten / Verlauf / Nachrichten / Suche — ein globaler Durchlauf erfasst **rund 1.650 Oberflächentexte**, dazu dynamische Inhalte (Titel, Autorennamen, Zähler).
- **Zwei Engines, ein Schalter.** *Eingebaut* (Standard) nutzt den kostenlosen Endpunkt des offiziellen Modells **Index-Translate-35B-A3B** von bilibili — nichts einzurichten. *Eigene API* behält das bisherige Verhalten: Richte sie auf einen beliebigen OpenAI-kompatiblen `/chat/completions`-Endpunkt mit eigener Basis-URL / Schlüssel / Modell. Die KI-Videozusammenfassung und die KI-Übersetzung haben weiterhin **vollständig getrennte** Endpunkte und Einstellungen und liegen gemeinsam auf einer Seite **„KI-Funktionen“**.
- **Eine Sprachliste, beide Engines.** Die Liste der Zielsprachen ist nicht nach Engine getrennt — es ist dieselbe Liste, egal welche du wählst. Sie vereint die **150 Sprachen** des offiziellen bilibili-Modells mit den **4 Sprachen der ethnischen Minderheiten Chinas und 3 chinesischen Dialekten**, die PiliBabel ergänzt — Tibetisch, Uigurisch, Zhuang und Hmong auf der einen Seite; Kantonesisch, Wu (Shanghai) und Minnan auf der anderen — dazu Chinesisch in traditioneller Schrift. Regionale und schriftbezogene Varianten bleiben **eigene Einträge**, statt zusammengelegt zu werden: Marokkanisches / Ägyptisches / Nadschdi- / Levantinisches Arabisch sind jeweils eigene Optionen, ebenso Serbisch, Usbekisch und Urdu in kyrillischer bzw. lateinischer Schrift.
- **Ehrlich bei der Abdeckung.** Sprachen innerhalb des offiziellen Verzeichnisses deckt bilibilis Modell ab. Die wenigen außerhalb — traditionelles Chinesisch sowie die oben genannten chinesischen Dialekte und Minderheitensprachen, die bilibili nicht führt — erscheinen trotzdem in der Liste, entsprechend gekennzeichnet, damit du auf einen Blick siehst, dass ein besseres Ergebnis dein eigenes Modell erfordern kann.
- **Einmal übersetzt, dann festgeschrieben.** Jede Ausgangszeichenkette wird **genau einmal** übersetzt; das Ergebnis wird lokal gespeichert und **nie erneut übersetzt**, wenn du einen Bildschirm erneut öffnest — dasselbe Prinzip wie beim offiziellen Client, für stabile, vorhersehbare Übersetzungen.
- **Umschalter Original ⇄ Übersetzung pro Kommentar** (ein kleines Symbol, kein Wort). `@Erwähnungen / [Emojis] / #Themen# / Links` bleiben als Tokens erhalten, und **Kommentare mit Hyperlinks werden übersetzt, wobei der Link anklickbar bleibt**.
- **Danmaku-Übersetzung** — ein eigener Schalter in der oberen rechten Bedienleiste des Players, **standardmäßig aus** und hinter einer Bestätigung, deren Text selbst übersetzt wird. Einmal aktiviert, werden Danmaku vor der Abspielposition in **Paketen von etwa 15 Sekunden** vorübersetzt (ein Sprung in die Mitte wird korrekt behandelt, nicht von vorn), sodass die Übersetzung meist bereitsteht, wenn sie vorbeiziehen.
- **Schalter für den Denkmodus** (`enable_thinking`) für die Abwägung Qualität gegen Geschwindigkeit, plus die Schaltflächen **„Übersetzung testen“** und **Cache leeren** in den Einstellungen.
- **Schneller Sprachwechsel**: Anfragen in Stapeln mit begrenzter Nebenläufigkeit auf einem dauerhaften Cache; ein Sprachwechsel baut den aktuellen Bildschirm einmal neu auf, damit du nicht auf unübersetzten Text starrst. Wer die KI-Übersetzung abschaltet, bekommt die gesamte Oberfläche im Original zurück, und es werden **überhaupt keine Anfragen** gesendet.
- **Einführung beim ersten Start.** Beim ersten Öffnen der App schlägt ein englischer Dialog vor, die Übersetzung einzuschalten. Wer zustimmt, bekommt: Übersetzung aktiviert, eingebautes Modell ausgewählt, die KI-Einstellungen geöffnet und sofort die Frage nach der gewünschten Sprache — neue Nutzer kommen mit zwei Tipps von „gerade installiert“ zu „bereits übersetzt“.
- **Wiedergabe, die weltweit funktioniert.** PiliBabel wählt den ausländischen Endpunkt (globales **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`), den bilibilis geo-geroutetes `playurl` ohnehin anbietet, statt dich auf einen Festlandsknoten (Alibaba Cloud / Shenzhen) festzunageln — Nutzer außerhalb des chinesischen Festlands haben damit keine Hänger mehr nach dem Muster „Ton läuft, Bild steht“. Du kannst den CDN in den Einstellungen weiterhin manuell festlegen.

## Die beiden Übersetzungs-Engines

| | Eingebaut (Standard) | Eigene API |
|---|---|---|
| Modell | bilibili **Index-Translate-35B-A3B** | alles OpenAI-Kompatible |
| Endpunkt | `index-translate.bilibili.com/v1` | deine Basis-URL |
| API-Schlüssel | **nicht nötig** | deiner |
| Kosten | kostenlos | je nach Anbieter |
| Anfragen | eine Zeichenkette pro Anfrage | in Stapeln (≤ 16 pro Anfrage) |
| Zusätzliche Sprachen | — | jede Sprache, die dein Modell kennt |

**Warum pro Anfrage nur eine Zeichenkette, wenn die Engine eingebaut ist.** Index-Translate ist ein **spezialisiertes** Übersetzungsmodell, und die von seinen Autoren dokumentierte Aufrufkonvention ist eine Vorlage für einen einzelnen Eintrag („Übersetze den folgenden Text ins X, gib nur die Übersetzung aus“). PiliBabel sendet auf dieser Engine deshalb eine Zeichenkette pro Anfrage statt des Stapel-Prompts mit nummerierter Liste und JSON-Array, der für eigene APIs verwendet wird. Der Endpunkt ist kostenlos — es gibt nichts zu gewinnen, wenn man auf Stapelausgaben setzt. Das ist ein bewusster Tausch: ein paar Anfragen mehr gegen deutlich weniger Möglichkeiten zu scheitern.

**Upgrade von 0.3.x.** Deine eigenen API-Einstellungen — Basis-URL, Schlüssel und Modell — werden **genau so belassen, wie du sie eingerichtet hast**. Die Engine-Auswahl fällt lediglich auf das eingebaute Modell: Beim ersten Start nach dem Upgrade läuft also bilibilis kostenloses Modell. Öffne *Einstellungen → KI → KI-Funktionen → Übersetzungs-Engine* und stelle auf *Eigene API* zurück, um sofort wieder bei deiner Konfiguration zu sein.

## Wie die Oberflächenübersetzung funktioniert (technisch)

Das Repository hat **keine i18n- / ARB-Ressourcenschicht** — Oberflächentexte stehen fest im Code, auf Chinesisch. Statt jedes Widget neu zu schreiben, legt PiliBabel eine dünne Übersetzungsschicht darüber:

1. **Ein globaler Nachschlage-Wrapper.** `lib/services/ui_translate/` stellt die Funktion `uiTx(String src)` auf oberster Ebene bereit. Aus `Text('中文')` wird `Text(uiTx('中文'))`. Ein **geskriptetes Codemod** hat das im ganzen Projekt angewandt (`tool/ui_translate_*.py`) — rund **223 Dateien / 1.650 Zeichenketten** — und dabei das nun ungültige Schlüsselwort `const` automatisch entfernt, wo nötig (auch bei Generika wie `const X<T>(...)` und punktierten Namen wie `const Positioned.fill(...)`), und `static const`-Deklarationen von Listen und Maps in `static final` umgewandelt.
2. **Ein `GetxService`-Kern** (`ui_translate_service.dart`):
   - ein dauerhafter Cache **Ausgangstext → Übersetzung** (über GetStorage), sodass jede Zeichenkette einmal übersetzt und für immer wiederverwendet wird;
   - `tx()` liest zuerst ein `RxInt revision` und entscheidet dann: deaktiviert → Original zurückgeben; ist das Ziel **vereinfachtes Chinesisch (`zh-CN`)** → Original ohne API-Anfrage zurückgeben (bilibilis Inhalte sind überwiegend vereinfachtes Chinesisch). Jedes andere Ziel — auch traditionelles Chinesisch, Kantonesisch, Wu und Minnan — läuft über die konfigurierte Engine; die Zugehörigkeit zur chinesischen Sprachfamilie allein überspringt die Übersetzung nicht. Danach: aus dem Cache bedienen oder **einreihen**;
   - eingereihte Zeichenketten werden von einem **Worker-Pool** abgearbeitet, mit **inkrementeller Anwendung pro Block** (jeder zurückkommende Block erhöht `revision`, der Text aktualisiert sich also schrittweise), und die Ergebnisse werden **dauerhaft gespeichert** (gedrosselt). Stapelgröße und Nebenläufigkeit folgen der Engine: **1 pro Anfrage** beim eingebauten Modell, **≤ 16 mit ≤ 10 gleichzeitig** bei deiner eigenen API.
3. **Engine-Auflösung.** `TranslateProvider` (`builtin` / `custom`) bestimmt, welche URL, welcher Schlüssel und welches Modell in der Transportschicht verwendet werden; abgesehen davon teilen beide Engines einen Codepfad und eine Sprachliste — ein Engine-Wechsel ist also eine einzelne Einstellung und **nie ein anderer Funktionsumfang**.
4. **Die Transportschicht** nutzt denselben bewährten **Streaming**-Kanal wie die KI-Videozusammenfassung — `AiChatService.streamChat` → `{base}/chat/completions` mit `stream: true` (kompatibel mit Gateways, die nur Streaming unterstützen) — erweitert, damit die Übersetzung **eigene** `apiUrl` / `apiKey` / `model` und ein `enable_thinking`-Flag verwenden kann. Die Änderung ist **abwärtskompatibel**, die Videozusammenfassung funktioniert unverändert weiter.
5. **Sätze mit Platzhaltern** laufen über `uiTxP(template, args)`: Ein ganzer Satz mit `{0}`/`{1}` wird als eine stabile Schlüsselgröße übersetzt (der Prompt bittet das Modell, die Platzhalter zu erhalten), anschließend werden die Werte wieder eingesetzt — Zeichenketten wie `"共 {0} 条"` werden also übersetzt, ohne die dynamischen Teile zu verunstalten.
6. **Sprachtabelle** (`app_language.dart`): Jede `AppLanguage` trägt einen Anzeigenamen (Autonym), eine `toModel`-Prompt-Zeichenkette, die Schrift- und Regionskonventionen kodiert, und eine Angabe, ob bilibilis offizielles Verzeichnis sie abdeckt. Schriftregeln (vereinfacht / traditionell) und Vorgaben zur dialektalen Konsistenz erreichen das Modell **nur über den Prompt**; danach korrigiert ein deterministischer Normalisierungslauf auf Clientseite verirrte Zeichen.
7. **Kommentare** laufen über `uiTxComment(text, id)` und behalten `@ / [Emojis] / #Thema# / Link` als unversehrte Tokens; Rich-Text-Abschnitte mit Links werden übersetzt, während die Link-Erkennung erhalten bleibt, und eine Menge von IDs pro Kommentar steuert den Umschalter Original ⇄ Übersetzung.
8. **Danmaku** (`danmaku/view.dart`): Ist der Schalter an, läuft ein Positions-Listener `[Abspielposition, Abspielposition + 15 s]` Sekunde für Sekunde ab und wärmt `uiTx()` für jeden Danmaku-Inhalt vor, sodass die Einträge übersetzt sind, bevor sie auf den Bildschirm kommen; beim Aktivieren wird die Leinwand geleert und neu gezeichnet.
9. **Speicherschlüssel**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Einstellungsoberfläche**: eine einzelne Seite erster Ebene „KI-Funktionen“ (`lib/pages/setting/ui_translate/`) mit unabhängigen Blöcken für KI-Videozusammenfassung und Oberflächenübersetzung.

**Weltweites CDN (`VideoUtils.getCdnUrl`).** Stream-URLs sind signiert, und wer den Host einer URL umschreibt, bekommt ein 403 — die Wiedergabe schreibt den Host also nie um. PiliBabel gibt die geo-geroutete URL zurück, die bilibili der IP des Clients aushändigt, und wenn die Kandidatenliste bereits einen ausländischen Endpunkt enthält (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`), wird dieser bevorzugt. Downloads, bei denen ein Host-Tausch unbedenklich ist, bevorzugen zusätzlich den globalen Akamai-Endpunkt und wechseln zum nächsten signierten Kandidaten, wenn eine Leitung stockt oder eine Fortsetzung ablehnt. Rohe `/v/resource`-P2P-Links fallen weiterhin auf den bestehenden Relay zurück, um 404 zu vermeiden.

**Design-Kompromisse / bekannte Grenzen.** Weil Zeichenketten an Ort und Stelle umhüllt statt in Ressourcen ausgelagert werden, werden einige Nicht-`Text`-Zeichenkettenparameter und manche Rich-Text-Abschnitte noch schrittweise ergänzt. Zeichenketten, die zugleich **logische Schlüssel** sind (mit `==` verglichen, als Tab-Namen wie `简介` verwendet oder als Enum-Beschriftungen in Schaltern), werden **bewusst nicht** pauschal umhüllt, um das Verhalten nicht zu brechen. Die Danmaku-Übersetzung ist Best-Effort auf einer scrollenden Leinwand — bei extrem dichtem Danmaku siehst du den Originaltext kurz, bevor die Übersetzung eintrifft. Die Übersetzung braucht Netz; ohne Netz greifen nicht-chinesische Ziele schlicht nicht. Der eingebaute Endpunkt ist ein kostenloser öffentlicher Dienst von bilibili — sollte er gedrosselt oder nicht verfügbar sein, sagt dir die App das und du kannst auf deine eigene API wechseln.

## Bauen und prüfen

Die App wird mit einem gepatchten Flutter-SDK sowie gepatchten Paketen `material_ui` / `cupertino_ui` über `lib/scripts/patch.ps1` und `lib/scripts/build.ps1` gebaut (genau wie PiliNara / PiliPlus). GitHub Actions erzeugt bei jedem Push eine **Debug-APK** (`.github/workflows/ui-translate-debug.yml`), und **das Veröffentlichen eines Tags `v*` baut und veröffentlicht automatisch Android-, Windows- und Linux-Artefakte** (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Plattformen
- [x] Android
- [ ] iOS
- [ ] Tablet
- [x] Windows
- [x] Linux

PiliBabel liefert in den Releases Builds für **Android (APK), Windows und Linux**; iOS und Tablet sind in diesem Fork noch nicht gepackt.

<br/>

## Download

Hol dir einen Build aus den **Releases**, oder klone das Repository und baue es lokal.

### Arch Linux

Dank an [@nlsdt](https://github.com/nlsdt) fürs Paketieren (das PiliNara-Rezept gilt auch für PiliBabel).

```bash
sudo pacman -S pilinara      # über das Arch-Linux-CN-Repository
paru -S pilinara-bin         # oder über AUR: pilinara-bin (vorgebaut) / pilinara (Quelle)
```

<br/>

## Verzeichnis der übernommenen Funktionen (aus PiliNara / PiliPlus)

Alles Folgende stammt aus PiliNara (und mittelbar aus PiliPlus); PiliBabel legt die KI-Übersetzungsschicht darüber.

**Oberfläche und Plattformanpassung**
- [x] App je Plattform umbenannt, damit mehrere Clients koexistieren können (PiliBabel installiert sich neben PiliNara)
- [x] Flutter-Rendering im Xiaomi-HyperOS-Minifenster behoben ([#161086](https://github.com/flutter/flutter/issues/161086), via [venera#467](https://github.com/venera-app/venera/pull/467)); prädiktive Zurück-Animation unter Android
- [x] Reihenfolge und Anzahl der „Ich“-Karten anpassbar; Vorschau der Verlaufskarten und Abschnitt „Später ansehen“
- [x] Automatischer Wechsel der Seitenleiste mit einstellbarer Auslösebreite; Bildkopie per langem Druck / Rechtsklick; große MD3E-Stilüberarbeitung

**Schriftsystem** — ein einheitlicher Importpool mit Deduplizierung über Inhalts-Hashes, Danmaku-Schriften im selben Pool, `loadFontFromList` mit ttc-Unterstützung und reine ASCII-Namen für Schriftfamilien.

**Wiedergabe, Minifenster und Qualität** — Minifenster in der App (ziehen, skalieren, SponsorBlock-Sprung, automatisches System-PIP, Selbstrettungsleiste für Livestreams), gleichzeitige Audiowiedergabe, Lautstärke in der App bis 200 %, eigener Video-CDN-Domain und regionale Knotenauswahl mit Latenzmessung, getrennte Standardqualität für Halb- und Vollbild, Sperren der Geschwindigkeit per Wisch nach oben, Tastatursteuerung auf Tablets, SuperChat-Zeitstempel im Livestream, Herzschlag für die Fan-Intimität im Livestream.

**Untertitel, KI und Offline** — zweisprachige Untertitel mit unabhängigem Stil des Zweituntertitels, KI-Untertitelanalyse (eigener OpenAI-kompatibler Endpunkt, Sprung zum Zeitstempel, Vorlagen, gespeicherte Unterhaltungen, sanfter Rückfall ohne Untertitel), WEBVTT-/SRT-Export, Doppelansicht des Offline-Caches mit Ordnerverwaltung und Metadaten-Persistenz, Export von Downloads in den öffentlichen Download-Ordner (Android).

**Danmaku und Blockierung** — verbesserte Skalierung zusammengeführter Danmaku (im Stil von [Pakku.js](https://github.com/xmcp/pakku.js)), listenbasierte visuelle Regex-Blockierung mit Import und Export, SponsorBlock-Sprung in den Abschnitt, Hochenergie-Fortschrittsbalken mit Gauß-Kern.

**Filterung von Empfehlungen / Dynamik / Kommentaren** — Schlüsselwörter für Titel / UP / Kanal, Dauer, Aufrufzahl, Like-Rate, Ausnahme für gefolgte UPs, Filter für nicht autorisierte / nur für Abonnenten zugängliche Videos, geteilte Whitelist, kommerzielle / nicht autorisierte Dynamik, Ausnahme für eigene und angeheftete Kommentare des UPs, zusammengeführter App-+-Web-Feed.

**Dynamik, Suche und Nutzerinfo** — eigene Notizen zu UPs, Notiz ersetzt den Nicknamen an 13 Stellen, unabhängige Sortierung verschachtelter Antworten, lokaler Stichwortsuchfilter, Sprung über b23.tv-Kurzlinks, Abzeichen „nur für Abonnenten“, Schalter zum Ausblenden des Empfehlungsgrunds, Anzeige der Münz-EP.

**Livestream-Verbesserungen** — Panel zum Anlegen des Fan-Medaillons, DLNA-Casting mit Vorrang für HLS, Anzeige der SuperChat-Zeit, untere Bedienleiste des Minifensters zur Selbstrettung.

**Systemintegration und Desktop** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), neu geschriebene Handhabung des Audiofokus.

<details>
<summary>Vollständige ursprüngliche Funktionsliste (wortgetreu aus PiliNara — zum Aufklappen klicken)</summary>

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

## Haftungsausschluss

PiliBabel ist ein persönliches, aus Interesse betriebenes Projekt und wird **nur zum Lernen und Testen** bereitgestellt; bitte lösche es innerhalb von **24 Stunden** nach dem Download.

- PiliBabel ist ein **inoffizieller Client von Drittanbietern** und **weder mit bilibili verbunden noch von bilibili unterstützt oder gesponsert**.
- Alle APIs stammen aus offiziellen öffentlichen Endpunkten; **es werden keine geknackten, überprivilegierten oder Paywalls umgehenden Inhalte** bereitgestellt.
- **Die KI-Übersetzung läuft auf einem Modell-Endpunkt von Drittanbietern.** Standardmäßig ist das bilibilis eigener kostenloser öffentlicher Index-Translate-Dienst; wechselst du zu deiner eigenen API, ist es der von dir eingerichtete Endpunkt. Qualität und Konformität der Übersetzung liegen beim Nutzer und beim gewählten Modellanbieter; dieses Projekt **hostet kein Modell und stellt keinen API-Schlüssel bereit**.
- Respektiere das Urheberrecht und bilibilis Nutzungsbedingungen. Nutze es verantwortungsvoll.

Mit Respekt für die ursprünglichen und vorgelagerten Autorinnen und Autoren und ihr Engagement für Open Source:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — das direkte Elternprojekt von PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — die quelloffene Übersetzungsmodell-Familie, die die eingebaute Engine aufruft

Sollte ein Inhalt deine Rechte verletzen, kontaktiere uns bitte zur Entfernung.

<br/>

## Lizenz

PiliBabel steht unter der **GNU General Public License v3.0 (GPL-3.0)** — dieselbe Lizenz wie PiliNara, PiliPlus und PiliPala. Als abgeleitetes Werk **muss PiliBabel ebenfalls unter GPL-3.0 verbreitet werden**: Du darfst es frei nutzen, studieren, teilen und verändern, sofern du dieselbe Lizenz, die Urheberrechtshinweise und diesen Lizenztext beibehältst. Siehe [`LICENSE`](./LICENSE).

Komponenten von Drittanbietern (Flutter-Pakete, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio) usw.) bleiben unter ihren eigenen Lizenzen.

<br/>

## Danksagung

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — bilibilis quelloffene Übersetzungsmodell-Familie und der kostenlose öffentliche Endpunkt hinter der eingebauten Engine
- und weitere
- Inspiriert von bilibilis offizieller „KI-Oberflächenübersetzung“.

<sub><a href="#readme-languages">↑ <a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a> · <a href="#readme-fr">Français</a> · <a href="#readme-de">Deutsch</a> · <a href="#readme-es">Español</a> · <a href="#readme-ko">한국어</a> · <a href="#readme-ar">العربية</a> · <a href="#readme-vi">Tiếng Việt</a> · <a href="#readme-ms">Bahasa Melayu</a> · <a href="#readme-id">Bahasa Indonesia</a></a></sub>

</details>

---

<details>
<summary><b>Español</b></summary>

<a id="readme-es"></a>

## Español

<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Un cliente de Bilibili de terceros con traducción por IA.</b></p>
    <p>Babel — derribar la barrera del idioma, para que cada persona disfrute de bilibili en el suyo.</p>
    <p>Incluye traducción de 4 lenguas de las minorías étnicas de China y 3 dialectos chinos.</p>
    <p>La traducción funciona nada más instalar, con el modelo gratuito de bilibili: no hace falta clave de API.</p>
</div>

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Inicio" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dinámicas" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Yo" />
</div>

<br/>

> **Aviso legal.** PiliBabel es un cliente **no oficial, de código abierto y de terceros**. **No está afiliado a bilibili / bilibili Inc., ni cuenta con su respaldo o patrocinio**. Todas las API provienen de puntos de acceso públicos oficiales; **no se desbloquea ni se piratea ningún contenido de pago**. Lee íntegramente las secciones [Aviso legal](#aviso-legal) y [Licencia](#licencia).

## ¿Qué es PiliBabel?

PiliBabel es un **fork independiente de terceros construido sobre [PiliNara](https://github.com/Starfallan/PiliNara)**, y hereda todo lo que PiliNara hereda:

```
bilibili (API pública oficial)
        ▲
   PiliPala / PiliPalaX        — el proyecto original
        ▲
   PiliPlus                    — fork activo
        ▲
   PiliNara                    — fork de PiliPlus (ajustes personales)
        ▲
   PiliBabel  ← estás aquí      — fork de PiliNara
```

PiliBabel conserva **todas las funciones de PiliNara / PiliPlus** (consulta el [registro de funciones heredadas](#registro-de-funciones-heredadas-de-pilinara--piliplus) al final) y añade **una capacidad principal que los clientes originales no tienen**:

> **Traducción de interfaz y contenido por IA**: toda la aplicación (etiquetas de la interfaz, títulos de vídeos, nombres de los UP, comentarios, dinámicas, el feed e incluso los danmaku en directo) se muestra en el idioma **que tú** elijas.

Y desde la 1.0 funciona **nada más instalar**: el modelo de traducción viene **integrado**. bilibili publicó su propio modelo de traducción, [Index-Translate](https://github.com/bilibili/Index-Translate), servido desde un punto de acceso público y gratuito. PiliBabel apunta ahí por defecto, así que la traducción funciona en cuanto instalas la aplicación: sin registro, sin clave y sin factura. Si prefieres tu propio modelo, la vía de «API propia» sigue ahí, a un toque.

## Funciones principales

- **Traducción por IA, en todas partes.** Barras de navegación, tarjetas de vídeo, páginas de detalle, comentarios, dinámicas y las pantallas Yo / Favoritos / Historial / Mensajes / Búsqueda: un barrido global cubre **unos 1650 textos de interfaz**, más el contenido dinámico (títulos, nombres de autores, contadores).
- **Dos motores, un solo ajuste.** *Integrado* (por defecto) usa el punto de acceso gratuito del modelo oficial **Index-Translate-35B-A3B** de bilibili: nada que configurar. *API propia* mantiene el comportamiento anterior: apúntala a cualquier punto de acceso `/chat/completions` compatible con OpenAI, con tu propia URL base / clave / modelo. El resumen de vídeo por IA y la traducción por IA siguen teniendo puntos de acceso y ajustes **totalmente independientes**, reunidos en una sola página **«Funciones de IA»**.
- **Una sola lista de idiomas, para ambos motores.** La lista de idiomas de destino no se divide por motor: es la misma elijas el que elijas. Reúne los **150 idiomas** del modelo oficial de bilibili con las **4 lenguas de las minorías étnicas de China y 3 dialectos chinos** que añade PiliBabel — tibetano, uigur, zhuang y hmong por un lado; cantonés, wu (shanghainés) y minnan por otro — más el chino tradicional. Las variantes regionales y de escritura se mantienen como **entradas separadas** en lugar de fusionarse: el árabe marroquí / egipcio / najdí / levantino son cada uno su propia opción, igual que el serbio, el uzbeko y el urdu en cirílico o en latino.
- **Honesto con la cobertura.** Los idiomas dentro del inventario oficial los cubre el modelo de bilibili. Los pocos que quedan fuera —el chino tradicional y los dialectos chinos y lenguas minoritarias anteriores que bilibili no recoge— siguen apareciendo en la lista, marcados como tales, para que veas de un vistazo que un mejor resultado puede requerir tu propio modelo.
- **Se traduce una vez y queda fijado.** Cada cadena de origen se traduce **exactamente una vez**; el resultado se guarda en local y **nunca se vuelve a traducir** al reabrir una pantalla, el mismo principio que el cliente oficial, para conseguir traducciones estables y predecibles.
- **Conmutador Original ⇄ Traducción por comentario** (un icono pequeño, no una palabra). Las `@menciones / [emojis] / #temas# / enlaces` se conservan como tokens, y **los comentarios con hipervínculos se traducen manteniendo el enlace pulsable**.
- **Traducción de danmaku**: un interruptor independiente en la barra de control superior derecha del reproductor, **desactivado por defecto** y protegido por una confirmación cuyo propio texto también se traduce. Una vez activado, los danmaku por delante de la posición de reproducción se pretraducen en **lotes de unos 15 segundos** (un salto al medio se trata correctamente, no desde el principio), de modo que la traducción suele estar lista cuando pasan por pantalla.
- **Interruptor del modo de razonamiento** (`enable_thinking`) para elegir entre calidad y velocidad, más los botones **«probar traducción»** y **vaciar caché** en los ajustes.
- **Cambio de idioma rápido**: peticiones por lotes con concurrencia limitada sobre una caché persistente; cambiar de idioma reconstruye una vez la pantalla actual, para no dejarte mirando texto sin traducir. Desactivar la traducción por IA devuelve toda la interfaz al texto original y **no envía ninguna petición**.
- **Guía en el primer arranque.** La primera vez que abres la aplicación, un diálogo en inglés ofrece activar la traducción. Si aceptas, activa la traducción, selecciona el modelo integrado, abre la página de ajustes de IA y pregunta de inmediato qué idioma quieres: un usuario nuevo pasa de «recién instalado» a «ya traducido» con dos toques.
- **Reproducción que funciona en todo el mundo.** PiliBabel selecciona el nodo extranjero (global **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) que el `playurl` con enrutado geográfico de bilibili ya ofrece, en lugar de clavarte a un nodo de China continental (Alibaba Cloud / Shenzhen), así que quienes están fuera de China continental ya no sufren los bloqueos de «el audio sigue, la imagen se congela». Aun así, puedes fijar un CDN manualmente en los ajustes.

## Los dos motores de traducción

| | Integrado (por defecto) | API propia |
|---|---|---|
| Modelo | bilibili **Index-Translate-35B-A3B** | cualquiera compatible con OpenAI |
| Punto de acceso | `index-translate.bilibili.com/v1` | tu URL base |
| Clave de API | **no hace falta** | la tuya |
| Coste | gratuito | según tu proveedor |
| Peticiones | una cadena por petición | por lotes (≤ 16 por petición) |
| Idiomas adicionales | — | cualquier idioma que conozca tu modelo |

**Por qué una cadena por petición en el motor integrado.** Index-Translate es un modelo **especializado** en traducción, y la convención de llamada que documentan sus autores es una plantilla de un solo elemento («traduce el texto siguiente a X, devuelve solo la traducción»). Por eso PiliBabel envía una cadena por petición en este motor, en lugar del prompt por lotes con «lista numerada / array JSON» que usa para las API propias. El punto de acceso es gratuito, así que no hay nada que ganar apostando por una salida por lotes: es un intercambio deliberado de unas pocas peticiones más por muchas menos formas de fallar.

**Actualización desde la 0.3.x.** Tus ajustes de API propia —URL base, clave y modelo— se **dejan exactamente como los configuraste**. La selección de motor simplemente pasa al modelo integrado, así que en el primer arranque tras la actualización estarás con el modelo gratuito de bilibili; abre *Ajustes → IA → Funciones de IA → motor de traducción* y vuelve a *API propia* para regresar al instante a tu configuración.

## Cómo funciona la traducción de interfaz (técnico)

El repositorio **no tiene ninguna capa de recursos i18n / ARB**: los textos de la interfaz están escritos en chino directamente en el código. En lugar de reescribir cada widget, PiliBabel añade una fina capa de traducción por encima:

1. **Un envoltorio global de consulta.** `lib/services/ui_translate/` expone una función de nivel superior `uiTx(String src)`. Donde antes había `Text('中文')` ahora hay `Text(uiTx('中文'))`. Un **codemod con script** lo aplicó a todo el proyecto (`tool/ui_translate_*.py`): unos **223 archivos / 1650 cadenas**, quitando automáticamente la palabra clave `const` que dejaba de ser válida donde hacía falta (incluidos genéricos como `const X<T>(...)` y nombres con punto como `const Positioned.fill(...)`), y convirtiendo las declaraciones `static const` de listas y mapas en `static final`.
2. **Un núcleo `GetxService`** (`ui_translate_service.dart`):
   - una caché persistente **origen → traducción** (respaldada por GetStorage), de modo que cada cadena se traduce una vez y se reutiliza para siempre;
   - `tx()` lee primero un `RxInt revision` y luego decide: si está desactivado → devuelve el original; si el destino es el **chino simplificado (`zh-CN`)** → devuelve el original sin petición a la API (el contenido de bilibili es abrumadoramente chino simplificado). Cualquier otro destino —incluidos el chino tradicional, el cantonés, el wu y el minnan— pasa por el motor configurado; pertenecer a la familia china no basta para saltarse la traducción. Después: servir desde la caché o **encolar**;
   - las cadenas encoladas las procesa un **grupo de workers** con **aplicación incremental por bloque** (cada bloque devuelto incrementa `revision`, así que el texto se actualiza de forma progresiva), y los resultados se **persisten** (con limitación de frecuencia). El tamaño de lote y la concurrencia siguen al motor: **1 por petición** en el modelo integrado, **≤ 16 con ≤ 10 en vuelo** en tu propia API.
3. **Resolución del motor.** `TranslateProvider` (`builtin` / `custom`) determina qué URL, clave y modelo usa la capa de transporte; aparte de eso, ambos motores comparten una única ruta de código y una única lista de idiomas, así que cambiar de motor es un solo ajuste y **nunca un conjunto de funciones distinto**.
4. **El transporte** reutiliza el mismo canal **en streaming** ya probado que el resumen de vídeo por IA: `AiChatService.streamChat` → `{base}/chat/completions` con `stream: true` (compatible con pasarelas que solo admiten streaming), ampliado para que la traducción pueda usar sus **propios** `apiUrl` / `apiKey` / `model` y un indicador `enable_thinking`. El cambio es **retrocompatible**, así que el resumen de vídeo sigue funcionando igual.
5. **Las frases con marcadores** pasan por `uiTxP(template, args)`: una frase entera con marcadores `{0}`/`{1}` se traduce como una clave estable (el prompt pide al modelo que conserve los marcadores) y luego se sustituyen los valores, de modo que cadenas como `"共 {0} 条"` se traducen sin estropear las partes dinámicas.
6. **Tabla de idiomas** (`app_language.dart`): cada `AppLanguage` lleva un autónimo para mostrar, una cadena de prompt `toModel` que codifica convenciones de escritura y región, y un indicador de si el inventario oficial de bilibili la cubre. Las reglas de escritura (simplificado / tradicional) y las indicaciones de coherencia dialectal llegan al modelo **solo a través del prompt**, y después una pasada determinista de normalización en el cliente corrige los caracteres rebeldes.
7. **Los comentarios** pasan por `uiTxComment(text, id)`, manteniendo `@ / [emojis] / #tema# / enlace` como tokens intactos; los tramos de texto enriquecido con enlaces se traducen preservando el reconocimiento de enlaces, y un conjunto de identificadores por comentario gobierna el conmutador Original ⇄ Traducción.
8. **Danmaku** (`danmaku/view.dart`): cuando su interruptor está activado, un escucha de posición recorre `[posición de reproducción, posición de reproducción + 15 s]` segundo a segundo y precalienta `uiTx()` sobre el contenido de cada danmaku, de modo que los elementos llegan ya traducidos a la pantalla; al activarlo se vacía y se repinta el lienzo.
9. **Claves de almacenamiento**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Interfaz de ajustes**: una sola página de primer nivel «Funciones de IA» (`lib/pages/setting/ui_translate/`), con bloques independientes para el resumen de vídeo por IA y la traducción de interfaz.

**CDN global (`VideoUtils.getCdnUrl`).** Las URL de streaming van firmadas, y reescribir el host de una URL provoca un 403, así que la reproducción nunca reescribe el host. PiliBabel devuelve la URL con enrutado geográfico que bilibili entrega a la IP del cliente y, cuando la lista de candidatos ya incluye un nodo extranjero (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`), se prefiere ese. Las descargas, donde cambiar el host sí es seguro, además prefieren el nodo global de Akamai y rotan al siguiente candidato firmado cuando una línea se atasca o rechaza una reanudación. Los enlaces P2P directos `/v/resource` siguen recurriendo al relé existente para evitar errores 404.

**Compromisos de diseño / límites conocidos.** Como las cadenas se envuelven en su sitio en lugar de extraerse a recursos, algunos parámetros de cadena que no son `Text` y ciertos tramos de texto enriquecido aún se van completando poco a poco. Las cadenas que además sirven como **claves lógicas** (comparadas con `==`, usadas como nombres de pestaña como `简介`, o como etiquetas de enumeración en conmutadores) **deliberadamente no** se envuelven en bloque, para no romper el comportamiento. La traducción de danmaku es de mejor esfuerzo sobre un lienzo en movimiento: con danmaku muy densos puede que veas brevemente el original antes de que llegue la traducción. La traducción necesita red; sin ella, los destinos distintos del chino simplemente no surten efecto. El punto de acceso integrado es un servicio público gratuito operado por bilibili: si alguna vez se limita o deja de estar disponible, la aplicación te lo indica y puedes cambiar a tu propia API.

## Compilación y verificación

La aplicación se compila con un SDK de Flutter parcheado y paquetes `material_ui` / `cupertino_ui` parcheados, mediante `lib/scripts/patch.ps1` y `lib/scripts/build.ps1` (igual que PiliNara / PiliPlus). GitHub Actions produce un **APK de depuración** en cada push (`.github/workflows/ui-translate-debug.yml`), y **publicar una etiqueta `v*` compila y publica automáticamente los artefactos de Android, Windows y Linux** (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Plataformas
- [x] Android
- [ ] iOS
- [ ] Tableta
- [x] Windows
- [x] Linux

PiliBabel ofrece compilaciones de **Android (APK), Windows y Linux** en Releases; iOS y tableta aún no se empaquetan en este fork.

<br/>

## Descarga

Consigue una compilación en **Releases**, o clona el repositorio y compílalo en local.

### Arch Linux

Gracias a [@nlsdt](https://github.com/nlsdt) por el empaquetado (la receta de PiliNara sirve igual para PiliBabel).

```bash
sudo pacman -S pilinara      # desde el repositorio Arch Linux CN
paru -S pilinara-bin         # o vía AUR: pilinara-bin (precompilado) / pilinara (código fuente)
```

<br/>

## Registro de funciones heredadas (de PiliNara / PiliPlus)

Todo lo siguiente proviene de PiliNara (y, de forma transitiva, de PiliPlus); PiliBabel añade encima la capa de traducción por IA.

**Interfaz y adaptación a plataformas**
- [x] Aplicación renombrada por plataforma para que varios clientes convivan (PiliBabel se instala junto a PiliNara)
- [x] Renderizado de Flutter corregido en la miniventana de Xiaomi HyperOS ([#161086](https://github.com/flutter/flutter/issues/161086), vía [venera#467](https://github.com/venera-app/venera/pull/467)); animación de retroceso predictivo en Android
- [x] Orden y número de las tarjetas de «Yo» personalizables; vista previa de las tarjetas de historial y sección «ver más tarde»
- [x] Cambio automático de la barra lateral con ancho de activación configurable; copiar imagen con pulsación larga / clic derecho; gran renovación de estilo MD3E

**Sistema de fuentes** — un grupo de importación unificado con deduplicación por hash de contenido, fuentes de danmaku fusionadas en el mismo grupo, `loadFontFromList` con soporte de ttc y nombres de familia de fuente en ASCII puro.

**Reproducción, miniventana y calidad** — miniventana integrada (arrastrar, redimensionar, salto de SponsorBlock, PIP del sistema automático, barra de autorrescate en directo), reproducción de audio concurrente, volumen dentro de la app hasta el 200 %, dominio CDN de vídeo personalizado y selección de nodo regional con prueba de latencia, calidad predeterminada distinta en media pantalla y pantalla completa, bloqueo de velocidad con deslizamiento hacia arriba, control por teclado en tabletas, marcas de tiempo de SuperChat en directo, latido para la intimidad de los fans en directo.

**Subtítulos, IA y sin conexión** — subtítulos bilingües con estilo independiente del subtítulo secundario, análisis de subtítulos por IA (punto de acceso compatible con OpenAI personalizado, salto a la marca de tiempo, plantillas, conversaciones persistidas, reserva suave cuando no hay subtítulos), exportación a WEBVTT/SRT, doble vista de la caché sin conexión con gestión de carpetas y persistencia de metadatos, exportación de descargas a la carpeta Download pública (Android).

**Danmaku y bloqueo** — escalado mejorado de danmaku fusionados (estilo [Pakku.js](https://github.com/xmcp/pakku.js)), bloqueo visual por expresiones regulares en forma de lista con importación y exportación, salto dentro del segmento de SponsorBlock, barra de progreso de alta energía con núcleo gaussiano.

**Filtrado de recomendaciones / dinámicas / comentarios** — palabras clave de título / UP / sección, duración, número de reproducciones, tasa de «me gusta», exención de UP seguidos, filtrado de no autorizados / exclusivos para cargadores, lista blanca compartida, dinámicas comerciales / no autorizadas, exención de los comentarios propios del UP y de los fijados, modo de feed combinado App + Web.

**Dinámicas, búsqueda e información de usuario** — notas personalizadas para los UP, la nota sustituye el apodo en 13 posiciones, ordenación independiente de respuestas anidadas, filtro de búsqueda por palabra clave local, salto de enlaces cortos b23.tv, distintivo «exclusivo para cargadores», ajuste para ocultar el motivo de la recomendación, visualización de la experiencia de monedas.

**Mejoras del directo** — panel de colocación de la medalla de fan, emisión DLNA con preferencia por HLS, visualización de la hora de los SuperChat, barra de control inferior de la miniventana para el autorrescate.

**Integración con el sistema y escritorio** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), gestión del foco de audio reescrita.

<details>
<summary>Lista completa de funciones originales (literal, de PiliNara — pulsa para desplegar)</summary>

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

## Aviso legal

PiliBabel es un proyecto personal, movido por el interés, y se ofrece **solo para aprendizaje y pruebas**; elimínalo en las **24 horas** siguientes a su descarga.

- PiliBabel es un cliente **de terceros no oficial** y **no está afiliado a bilibili ni cuenta con su respaldo o patrocinio**.
- Todas las API provienen de puntos de acceso públicos oficiales; **no se ofrece contenido pirateado, con privilegios excesivos ni que eluda muros de pago**.
- **La traducción por IA se ejecuta en un punto de acceso de modelo de terceros.** Por defecto es el servicio público y gratuito Index-Translate de la propia bilibili; si cambias a tu propia API, es el punto de acceso que hayas configurado. La calidad y el cumplimiento de las traducciones son responsabilidad del usuario y del proveedor de modelo elegido; este proyecto **no aloja ningún modelo ni proporciona ninguna clave de API**.
- Respeta los derechos de autor y las condiciones de uso de bilibili. Úsalo con responsabilidad.

Con respeto a los autores originales y anteriores por su dedicación al código abierto:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — el proyecto padre directo de PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — la familia de modelos de traducción de código abierto que llama el motor integrado

Si algún contenido infringe tus derechos, contáctanos para retirarlo.

<br/>

## Licencia

PiliBabel se distribuye bajo la **GNU General Public License v3.0 (GPL-3.0)**, la misma licencia que PiliNara, PiliPlus y PiliPala. Al ser una obra derivada, **PiliBabel también debe distribuirse bajo GPL-3.0**: eres libre de usarlo, estudiarlo, compartirlo y modificarlo siempre que conserves la misma licencia, los avisos de copyright y este texto de licencia. Consulta [`LICENSE`](./LICENSE).

Los componentes de terceros (paquetes de Flutter, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), etc.) siguen bajo sus propias licencias.

<br/>

## Agradecimientos

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — la familia de modelos de traducción de código abierto de bilibili y el punto de acceso público gratuito que hay detrás del motor integrado
- y más
- Inspirado en la «traducción de interfaz por IA» oficial de bilibili.

<sub><a href="#readme-languages">↑ <a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a> · <a href="#readme-fr">Français</a> · <a href="#readme-de">Deutsch</a> · <a href="#readme-es">Español</a> · <a href="#readme-ko">한국어</a> · <a href="#readme-ar">العربية</a> · <a href="#readme-vi">Tiếng Việt</a> · <a href="#readme-ms">Bahasa Melayu</a> · <a href="#readme-id">Bahasa Indonesia</a></a></sub>

</details>

---

<details>
<summary><b>한국어</b></summary>

<a id="readme-ko"></a>

## 한국어

<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>AI 번역을 갖춘 서드파티 Bilibili 클라이언트.</b></p>
    <p>Babel — 언어의 벽을 허물어, 누구나 자기 언어로 bilibili를 즐길 수 있도록.</p>
    <p>중국의 소수민족 언어 4종과 중국어 방언 3종의 번역을 포함합니다.</p>
    <p>bilibili 공식 무료 모델을 내장해 설치하자마자 번역되며, API 키가 필요 없습니다.</p>
</div>

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="홈" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="동적" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="내 정보" />
</div>

<br/>

> **면책 조항.** PiliBabel은 **비공식 오픈소스 서드파티** 클라이언트이며, **bilibili / bilibili Inc.와 제휴·보증·후원 관계가 전혀 없습니다**. 모든 API는 공식 공개 엔드포인트에서 가져왔고, **유료 콘텐츠를 해제하거나 크랙하지 않습니다**. [면책 조항](#면책-조항)과 [라이선스](#라이선스) 두 절을 끝까지 읽어 주세요.

## PiliBabel이란?

PiliBabel은 **[PiliNara](https://github.com/Starfallan/PiliNara)를 기반으로 만들어진 독립적인 서드파티 포크**이며, PiliNara가 물려받은 모든 것을 그대로 물려받았습니다:

```
bilibili (공식 공개 API)
        ▲
   PiliPala / PiliPalaX        — 최초 프로젝트
        ▲
   PiliPlus                    — 활발한 포크
        ▲
   PiliNara                    — PiliPlus의 포크 (개인 조정)
        ▲
   PiliBabel  ← 여기          — PiliNara의 포크
```

PiliBabel은 **PiliNara / PiliPlus의 모든 기능을 그대로 유지**하고(아래 [상속된 기능 목록](#상속된-기능-목록-pilinara--piliplus-출처) 참고), 원본 클라이언트에는 없는 **핵심 기능 하나**를 더했습니다:

> **AI 인터페이스·콘텐츠 번역** — 앱 전체(인터페이스 문구, 영상 제목, UP 이름, 댓글, 동적, 피드, 나아가 라이브 탄막까지)가 **당신이** 고른 언어로 표시됩니다.

그리고 1.0부터는 이 기능이 **설치하자마자 바로 동작합니다**. 번역 모델이 **내장**되어 있기 때문입니다. bilibili는 자사의 번역 모델 [Index-Translate](https://github.com/bilibili/Index-Translate)를 오픈소스로 공개하고 무료 공개 엔드포인트로 제공합니다. PiliBabel은 기본적으로 그곳을 가리키므로 **앱을 설치하면 바로 번역이 됩니다** — 가입도, 키도, 요금도 필요 없습니다. 직접 만든 모델을 쓰고 싶다면 자체 API 경로가 그대로 남아 있고, 한 번의 터치로 전환할 수 있습니다.

## 주요 기능

- **앱 전체를 번역합니다.** 내비게이션 바, 영상 카드, 상세 페이지, 댓글, 동적, 그리고 내 정보 / 즐겨찾기 / 기록 / 메시지 / 검색 화면까지 — 전역 치환이 **약 1,650개 이상의 인터페이스 문구**를 덮고, 여기에 제목·작성자 이름·재생 수 같은 동적 콘텐츠가 더해집니다.
- **엔진 두 개, 스위치 하나.** *내장*(기본값)은 bilibili 공식 **Index-Translate-35B-A3B** 무료 엔드포인트를 사용하므로 설정할 것이 없습니다. *자체 API*는 기존 동작을 유지합니다. OpenAI 호환 `/chat/completions` 엔드포인트에 자신의 베이스 URL / 키 / 모델을 지정하면 됩니다. AI 영상 요약과 AI 번역은 여전히 **완전히 독립된** 엔드포인트와 설정을 가지며, 하나의 **"AI 기능"** 페이지에 함께 있습니다.
- **언어 목록 하나를 두 엔진이 공유합니다.** 번역 대상 언어 목록은 엔진별로 나뉘지 않습니다. 어느 엔진을 고르든 같은 목록을 씁니다. bilibili 공식 모델의 **150개 언어**와 PiliBabel이 추가로 넣은 **중국의 소수민족 언어 4종과 중국어 방언 3종**을 하나로 합친 것입니다 — 소수민족 언어는 티베트어·위구르어·좡어·먀오어, 중국어 방언은 광둥어·우어(상하이어)·민난어 — 여기에 번체 중국어가 더해집니다. 지역·문자 변종은 **합치지 않고 각각 별도 항목**으로 둡니다. 모로코 / 이집트 / 나지드 / 레반트 아랍어가 각각 독립된 선택지이고, 세르비아어·우즈베크어·우르두어의 키릴 / 라틴 표기도 마찬가지입니다.
- **지원 범위를 솔직하게 표시합니다.** 공식 목록 안의 언어는 bilibili 모델이 담당합니다. 목록 밖의 몇몇 — 번체 중국어, 그리고 bilibili가 수록하지 않은 위의 중국어 방언과 소수민족 언어 — 도 목록에 그대로 나오지만 그렇게 표시되므로, 더 나은 결과가 필요하면 자체 모델이 필요할 수 있음을 한눈에 알 수 있습니다.
- **한 번 번역하면 고정됩니다.** 각 원문은 **정확히 한 번** 번역되고, 결과는 로컬에 저장되어 화면을 다시 열어도 **다시 번역되지 않습니다** — 공식 클라이언트와 같은 원칙으로, 번역이 안정적이고 예측 가능합니다.
- **댓글별 원문 ⇄ 번역 전환**(중국어 단어가 아닌 작은 아이콘). `@멘션 / [이모지] / #토픽# / 링크`는 토큰으로 보존되며, **하이퍼링크가 있는 댓글도 번역되면서 링크는 계속 눌립니다**.
- **탄막 번역** — 플레이어 오른쪽 위 컨트롤 줄에 있는 독립 스위치로, **기본값은 꺼짐**이며 확인 문구 자체도 번역되는 확인 절차를 거칩니다. 켜면 재생 위치보다 앞선 탄막을 **약 15초 단위 묶음**으로 미리 번역합니다(중간으로 건너뛰어도 처음이 아니라 그 지점부터 처리합니다). 그래서 탄막이 화면을 지날 때쯤이면 번역이 준비되어 있습니다.
- **사고 모드 스위치**(`enable_thinking`)로 품질과 속도를 선택할 수 있고, 설정에 **"번역 테스트"**와 **캐시 비우기** 버튼도 있습니다.
- **빠른 언어 전환**: 지속 캐시 위에서 동시 실행 수를 제한한 묶음 요청을 사용하고, 언어를 바꾸면 현재 화면을 한 번 강제로 다시 그려서 번역되지 않은 텍스트를 멍하니 보게 되는 일이 없습니다. AI 번역을 끄면 인터페이스 전체가 원문으로 돌아가고 **요청을 전혀 보내지 않습니다**.
- **첫 실행 안내.** 앱을 처음 열면 영어 대화상자가 번역을 켤지 물어봅니다. 동의하면 번역을 켜고, 내장 모델을 선택하고, AI 설정 페이지를 연 뒤 곧바로 어떤 언어를 쓸지 묻습니다 — 새 사용자는 두 번의 터치로 "방금 설치"에서 "이미 번역됨"까지 갑니다.
- **전 세계에서 재생됩니다.** PiliBabel은 당신을 중국 본토(알리바바 클라우드 / 선전) 노드에 고정하는 대신, bilibili가 IP에 따라 내려주는 해외 엣지(글로벌 **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`)를 우선 선택합니다. 그래서 중국 본토 밖 사용자에게 나타나던 "소리는 나오는데 화면이 멈추는" 현상이 사라집니다. 물론 설정에서 CDN을 직접 지정할 수도 있습니다.

## 두 가지 번역 엔진

| | 내장(기본값) | 자체 API |
|---|---|---|
| 모델 | bilibili **Index-Translate-35B-A3B** | OpenAI 호환이면 무엇이든 |
| 엔드포인트 | `index-translate.bilibili.com/v1` | 당신의 베이스 URL |
| API 키 | **불필요** | 당신의 것 |
| 비용 | 무료 | 사용하는 제공자에 따름 |
| 요청 방식 | 요청당 한 건 | 묶음(요청당 ≤ 16건) |
| 추가 언어 | — | 당신의 모델이 아는 모든 언어 |

**내장 엔진이 왜 한 건씩 보내는가.** Index-Translate는 번역 **전문** 모델이고, 제작자가 문서화한 호출 방식은 단일 항목 템플릿("다음 텍스트를 X로 번역하고 번역문만 출력하세요")입니다. 그래서 이 엔진에서는 자체 API에 쓰는 "번호 목록 + JSON 배열 반환" 묶음 프롬프트 대신 요청당 한 건을 보냅니다. 엔드포인트가 무료이므로 요청 수를 아끼려고 묶음 출력에 걸 위험을 질 이유가 없습니다 — **요청을 조금 더 쓰고 실패할 여지를 크게 줄이는** 의도적인 맞바꿈입니다.

**0.3.x에서 업그레이드하는 경우.** 직접 설정한 API(베이스 URL, 키, 모델)는 **그대로 보존되며 덮어쓰지 않습니다**. 엔진 선택만 기본적으로 내장 모델로 바뀌므로, 업그레이드 후 처음 실행하면 bilibili의 무료 모델을 쓰게 됩니다. *설정 → AI → AI 기능 → 번역 엔진*에서 '자체 API'로 되돌리면 즉시 원래 설정으로 복귀합니다.

## AI 인터페이스 번역은 어떻게 동작하는가 (기술)

이 저장소에는 **i18n / ARB 리소스 계층이 전혀 없습니다** — 인터페이스 문구가 모두 중국어로 하드코딩되어 있습니다. PiliBabel은 모든 위젯을 다시 쓰는 대신 그 위에 얇은 번역 계층을 얹었습니다:

1. **전역 조회 래퍼.** `lib/services/ui_translate/`가 최상위 함수 `uiTx(String src)`를 제공합니다. `Text('中文')`이던 곳이 `Text(uiTx('中文'))`이 됩니다. **스크립트화된 codemod**가 프로젝트 전체에 적용했습니다(`tool/ui_translate_*.py`) — 약 **223개 파일 / 1,650개 문구** — 이 과정에서 무효가 된 `const` 키워드를 필요한 곳에서 자동으로 제거하고(제네릭 `const X<T>(...)`나 점 표기 `const Positioned.fill(...)` 포함), `static const` 목록 / 맵 선언을 `static final`로 바꿨습니다.
2. **`GetxService` 코어** (`ui_translate_service.dart`):
   - 영속적인 **원문 → 번역** 캐시(GetStorage 기반)로, 각 문구는 한 번만 번역되고 이후 영구히 재사용됩니다;
   - `tx()`는 먼저 `RxInt revision`을 읽고 판단합니다: 꺼져 있으면 → 원문 반환; 대상이 **중국어 간체(`zh-CN`)**면 → API 요청 없이 원문 반환(bilibili 콘텐츠는 압도적으로 간체입니다). 그 밖의 모든 대상 — 번체 중국어, 광둥어, 우어, 민난어 포함 — 은 설정된 엔진을 거칩니다. **중국어 계열이라는 사실만으로는 번역을 건너뛰지 않습니다.** 그다음 캐시를 확인하고, 없으면 **대기열에 넣습니다**;
   - 대기열에 들어간 문구는 **worker 풀**이 처리하며 **블록 단위로 점진 반영**합니다(블록이 돌아올 때마다 `revision`을 올려 텍스트가 차례로 갱신됩니다). 결과는 **스로틀링하여 영속화**합니다. 묶음 크기와 동시 실행 수는 엔진을 따릅니다: 내장 모델은 **요청당 1건**, 자체 API는 **요청당 ≤ 16건, 동시 ≤ 10**.
3. **엔진 결정.** `TranslateProvider`(`builtin` / `custom`)가 전송 계층이 쓸 URL·키·모델을 정합니다. 그 외에는 두 엔진이 같은 코드 경로와 같은 언어 목록을 공유하므로, 엔진 전환은 설정 하나일 뿐 **기능 집합이 달라지는 일은 없습니다**.
4. **전송 계층**은 AI 영상 요약과 동일한, 이미 검증된 **스트리밍** 경로를 재사용합니다 — `AiChatService.streamChat` → `{base}/chat/completions`에 `stream: true`(스트리밍만 지원하는 게이트웨이와도 호환) — 그리고 번역 **전용** `apiUrl` / `apiKey` / `model`과 `enable_thinking` 플래그를 쓸 수 있게 확장했습니다. 이 변경은 **하위 호환**이라 영상 요약은 그대로 동작합니다.
5. **자리표시자가 있는 문장**은 `uiTxP(template, args)`를 씁니다. `{0}`/`{1}`가 들어간 문장을 하나의 안정된 키로 번역하고(프롬프트에서 자리표시자를 보존하도록 요청), 이후 값을 되돌려 채웁니다 — `"共 {0} 条"` 같은 문구도 동적 부분을 망가뜨리지 않습니다.
6. **언어 표** (`app_language.dart`): 각 `AppLanguage`는 표시용 자기 이름, 문자·지역 규범을 담은 `toModel` 프롬프트 문자열, 그리고 bilibili 공식 목록이 이를 포함하는지 나타내는 표시를 가집니다. 문자 규칙(간체 / 번체)과 방언 일관성 지침은 **오직 프롬프트를 통해서만** 모델에 전달되고, 이후 클라이언트 측에서 결정론적 문자 정규화를 한 번 돌려 어긋난 글자를 바로잡습니다.
7. **댓글**은 `uiTxComment(text, id)`를 거치며 `@ / [이모지] / #토픽# / 링크`를 온전한 토큰으로 유지합니다. 링크가 있는 리치 텍스트 구간도 번역하면서 링크 인식을 보존하고, 댓글별 id 집합이 원문 ⇄ 번역 전환을 구동합니다.
8. **탄막** (`danmaku/view.dart`): 스위치가 켜져 있으면 위치 리스너가 `[재생 위치, 재생 위치 + 15초]`를 1초 단위로 훑으며 각 탄막 내용에 `uiTx()`를 미리 데웁니다. 그래서 화면에 올라오기 전에 번역이 끝나 있습니다. 켤 때는 캔버스를 비우고 다시 그립니다.
9. **저장 키**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **설정 UI**: 하나의 1차 페이지 "AI 기능"(`lib/pages/setting/ui_translate/`)에 AI 영상 요약과 인터페이스 번역 블록이 독립적으로 놓입니다.

**전 세계 CDN (`VideoUtils.getCdnUrl`).** 스트림 URL은 서명되어 있고 호스트를 바꾸면 403으로 거부되므로, **재생 측은 절대 호스트를 바꾸지 않습니다**. PiliBabel은 bilibili가 클라이언트 IP에 따라 내려주는 지리 라우팅 URL을 그대로 쓰고, 후보 목록에 이미 해외 엣지(`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`)가 있으면 그것을 우선합니다. 호스트 교체가 안전한 다운로드에서는 추가로 전역 Akamai 엣지를 우선하고, 회선이 멈추거나 이어받기를 거부하면 다음 서명된 후보로 넘어갑니다. 원시 `/v/resource`(P2P) 링크는 404를 피하기 위해 기존 중계로 폴백합니다.

**설계상의 맞바꿈 / 알려진 한계.** 문구를 리소스로 추출하지 않고 제자리에서 감싸기 때문에, `Text`가 아닌 일부 문자열 매개변수와 일부 리치 텍스트 구간은 아직 순차적으로 채워지고 있습니다. **논리 키를 겸하는** 문자열(`==`로 비교되거나 `简介` 같은 탭 이름, 스위치의 열거 라벨로 쓰이는 것)은 동작을 깨지 않기 위해 **의도적으로** 일괄 래핑하지 않았습니다. 탄막 번역은 움직이는 캔버스 위에서의 최선 노력 방식이라, 탄막이 극도로 빽빽하면 번역이 도착하기 전에 원문이 잠깐 보일 수 있습니다. 번역에는 네트워크가 필요하며, 없으면 중국어 이외 대상은 반영되지 않습니다. 내장 엔드포인트는 bilibili가 운영하는 무료 공개 서비스로, 만약 속도 제한이나 중단이 있으면 앱이 명확히 알려주고 자체 API로 전환할 수 있습니다.

## 빌드와 검증

빌드 방식은 PiliNara / PiliPlus와 완전히 같습니다. 패치된 Flutter SDK와 패치된 `material_ui` / `cupertino_ui` 패키지를 `lib/scripts/patch.ps1`과 `lib/scripts/build.ps1`로 처리합니다. GitHub Actions는 푸시마다 **디버그 APK**를 만들고(`.github/workflows/ui-translate-debug.yml`), **`v*` 태그를 푸시하면 Android / Windows / Linux 산출물을 자동으로 빌드·배포**합니다(`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## 플랫폼
- [x] Android
- [ ] iOS
- [ ] 태블릿
- [x] Windows
- [x] Linux

PiliBabel은 Releases에서 **Android(APK), Windows, Linux** 빌드를 제공합니다. 이 포크에서는 iOS와 태블릿은 아직 패키징하지 않습니다.

<br/>

## 다운로드

**Releases**에서 빌드를 받거나, 저장소를 복제해 직접 빌드하세요.

### Arch Linux

패키징해 주신 [@nlsdt](https://github.com/nlsdt)께 감사드립니다(PiliNara 레시피가 PiliBabel에도 그대로 적용됩니다).

```bash
sudo pacman -S pilinara      # Arch Linux CN 저장소에서
paru -S pilinara-bin         # 또는 AUR: pilinara-bin(미리 빌드됨) / pilinara(소스)
```

<br/>

## 상속된 기능 목록 (PiliNara / PiliPlus 출처)

아래는 모두 PiliNara(그리고 거슬러 올라가 PiliPlus)에서 물려받은 것입니다. PiliBabel은 그 위에 AI 번역 계층을 더했습니다.

**인터페이스와 플랫폼 적응**
- [x] 플랫폼별로 앱 이름을 바꿔 여러 클라이언트 공존 가능(PiliBabel은 PiliNara와 나란히 설치됩니다)
- [x] Xiaomi HyperOS 미니 창에서의 Flutter 렌더링 문제 수정([#161086](https://github.com/flutter/flutter/issues/161086), [venera#467](https://github.com/venera-app/venera/pull/467) 경유); Android 예측형 뒤로 가기 애니메이션
- [x] "내 정보" 카드 순서·개수 사용자 지정; 기록 카드 미리보기와 "나중에 볼" 섹션
- [x] 사이드바 자동 전환과 트리거 너비 조정; 길게 누르기 / 오른쪽 클릭으로 이미지 복사; MD3E 스타일 대규모 개편

**글꼴 시스템** — 콘텐츠 해시로 중복을 제거하는 통합 가져오기 풀, 탄막 글꼴도 같은 풀에 통합, ttc를 지원하는 `loadFontFromList`, 순수 ASCII 해시 글꼴 패밀리 이름.

**재생·미니 창·화질** — 앱 내 미니 창(드래그, 크기 조절, SponsorBlock 건너뛰기, 시스템 PIP 자동 전환, 라이브 자구제 바), 동시 오디오 재생, 앱 내 볼륨 최대 200%, 사용자 지정 영상 CDN 도메인과 지역 노드 선택(지연 측정 포함), 반화면 / 전체 화면 별도 기본 화질, 위로 밀어 속도 잠금, 태블릿 키보드 제어, 라이브 SuperChat 시각 표시, 라이브 팬 친밀도 하트비트.

**자막·AI·오프라인** — 이중 언어 자막(보조 자막 스타일 독립), AI 자막 분석(사용자 지정 OpenAI 호환 엔드포인트, 타임스탬프 이동, 템플릿, 대화 영속화, 자막 없음 소프트 폴백), WEBVTT/SRT 내보내기, 오프라인 캐시 이중 보기(폴더 관리와 메타데이터 영속화), 다운로드를 공용 Download 폴더로 내보내기(Android).

**탄막과 차단** — 병합 탄막 확대 개선([Pakku.js](https://github.com/xmcp/pakku.js) 스타일), 목록형 시각적 정규식 차단(가져오기 / 내보내기 지원), SponsorBlock 구간 내부 건너뛰기, 가우시안 커널 고에너지 진행 바.

**추천 / 동적 / 댓글 필터링** — 제목 / UP / 채널 키워드, 길이, 재생 수, 좋아요 비율, 팔로우한 UP 예외, 미인증 / 유료 전용 필터, 공유 화이트리스트, 상업 / 미인증 동적, UP 본인 댓글과 고정 댓글 예외, App + Web 통합 피드 모드.

**동적·검색·사용자 정보** — UP 메모, 메모로 닉네임 대체(13개 이름 슬롯), 중첩 답글 독립 정렬, 로컬 키워드 검색 필터, b23.tv 단축 링크 이동, 유료 전용 배지, 추천 이유 숨기기 스위치, 코인 경험치 표시.

**라이브 개선** — 팬 메달 착용 패널, DLNA 캐스팅의 HLS 우선, SuperChat 시각 표시, 미니 창 하단 자구제 컨트롤 바.

**시스템 통합·데스크톱** — Windows SMTC, Linux MPRIS(`audio_service_mpris`), 오디오 포커스 처리 재작성.

<details>
<summary>원래 기능 체크리스트 전문(PiliNara에서 그대로, 눌러서 펼치기)</summary>

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

## 면책 조항

PiliBabel은 개인적 흥미로 만든 프로젝트이며 **학습과 테스트 용도로만** 제공됩니다. 다운로드 후 **24시간 이내**에 삭제해 주세요.

- PiliBabel은 **비공식 서드파티** 클라이언트이며 **bilibili와 제휴·보증·후원 관계가 없습니다**.
- 모든 API는 공식 공개 엔드포인트에서 가져왔고, **크랙·과도한 권한·유료 장벽 우회 콘텐츠는 제공하지 않습니다**.
- **AI 번역은 서드파티 모델 엔드포인트에서 실행됩니다.** 기본값은 bilibili 자체의 무료 공개 Index-Translate 서비스이고, 자체 API로 바꾸면 당신이 설정한 엔드포인트입니다. 번역 품질과 규정 준수는 사용자와 선택한 모델 제공자의 책임입니다. 이 프로젝트는 **어떤 모델도 호스팅하지 않으며 API 키도 제공하지 않습니다**.
- 저작권과 bilibili 이용약관을 존중하고 책임 있게 사용해 주세요.

오픈소스에 헌신한 원작자와 상위 프로젝트 저자들에게 존경을 표합니다:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — PiliBabel의 직계 상위 프로젝트
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — 내장 엔진이 호출하는 오픈소스 번역 모델 패밀리

권리를 침해하는 내용이 있다면 알려 주시면 삭제하겠습니다.

<br/>

## 라이선스

PiliBabel은 **GNU General Public License v3.0(GPL-3.0)** 으로 배포됩니다 — PiliNara, PiliPlus, PiliPala와 같은 라이선스입니다. 파생 저작물이므로 **PiliBabel 역시 GPL-3.0으로 배포되어야 합니다**. 동일한 라이선스, 저작권 고지, 그리고 이 라이선스 전문을 유지하는 한 자유롭게 사용·연구·공유·수정할 수 있습니다. [`LICENSE`](./LICENSE)를 참고하세요.

서드파티 구성 요소(각종 Flutter 패키지, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio) 등)는 각자의 라이선스를 따릅니다.

<br/>

## 감사의 말

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — bilibili가 오픈소스로 공개한 번역 모델 패밀리이자, 내장 엔진 뒤에 있는 무료 공개 엔드포인트
- 그리고 더 많은 프로젝트
- bilibili 공식 "AI 인터페이스 번역"에서 영감을 받았습니다.

<sub><a href="#readme-languages">↑ <a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a> · <a href="#readme-fr">Français</a> · <a href="#readme-de">Deutsch</a> · <a href="#readme-es">Español</a> · <a href="#readme-ko">한국어</a> · <a href="#readme-ar">العربية</a> · <a href="#readme-vi">Tiếng Việt</a> · <a href="#readme-ms">Bahasa Melayu</a> · <a href="#readme-id">Bahasa Indonesia</a></a></sub>

</details>

---

<details>
<summary><b>العربية</b></summary>

<a id="readme-ar"></a>

## العربية

<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>عميل Bilibili غير رسمي مزوَّد بالترجمة بالذكاء الاصطناعي.</b></p>
    <p>بابل — إزالة حاجز اللغة، ليستمتع الجميع بـ bilibili بلغتهم.</p>
    <p>يتضمّن الترجمة من 4 لغات من الأقليات العرقية في الصين و3 لهجات صينية.</p>
    <p>الترجمة تعمل فور التثبيت عبر نموذج bilibili المجاني — دون حاجة إلى مفتاح API.</p>
</div>

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="الرئيسية" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="الديناميكيات" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="أنا" />
</div>

<br/>

> **إخلاء المسؤولية.** PiliBabel عميل **غير رسمي ومفتوح المصدر ومن طرف ثالث**. وهو **ليس تابعاً لـ bilibili / bilibili Inc. ولا معتمداً منها ولا مدعوماً منها**. جميع الواجهات البرمجية مأخوذة من نقاط الوصول العامة الرسمية؛ **ولا يتم فتح أي محتوى مدفوع أو كسره**. يُرجى قراءة قسمَي [إخلاء المسؤولية](#إخلاء-المسؤولية) و[الترخيص](#الترخيص) بالكامل.

## ما هو PiliBabel؟

PiliBabel هو **فرع مستقل من طرف ثالث مبني على [PiliNara](https://github.com/Starfallan/PiliNara)**، ويرث كل ما يرثه PiliNara:

```
bilibili (واجهة برمجية عامة رسمية)
        ▲
   PiliPala / PiliPalaX        — المشروع الأصلي
        ▲
   PiliPlus                    — فرع نشِط
        ▲
   PiliNara                    — فرع من PiliPlus (تعديلات شخصية)
        ▲
   PiliBabel  ← أنت هنا         — فرع من PiliNara
```

يحتفظ PiliBabel بـ **كل ميزات PiliNara / PiliPlus** (انظر [سجل الميزات الموروثة](#سجل-الميزات-الموروثة-من-pilinara--piliplus) في الأسفل)، ويضيف **قدرة رئيسية لا تملكها العملاء الأصلية**:

> **ترجمة الواجهة والمحتوى بالذكاء الاصطناعي** — التطبيق بأكمله (نصوص الواجهة، عناوين الفيديوهات، أسماء المبدعين، التعليقات، الديناميكيات، التغذية، وحتى دانماكو البث المباشر) يُعرض باللغة **التي تختارها أنت**.

ومنذ الإصدار 1.0 يعمل ذلك **فور التثبيت**: نموذج الترجمة **مدمج**. فقد أتاحت bilibili نموذج الترجمة الخاص بها [Index-Translate](https://github.com/bilibili/Index-Translate) كمصدر مفتوح وقدّمته عبر نقطة وصول عامة مجانية. ويشير PiliBabel إليها افتراضياً، فتعمل الترجمة لحظة تثبيت التطبيق: بلا تسجيل، وبلا مفتاح، وبلا فاتورة. وإن فضّلت نموذجك الخاص، فمسار «واجهتك الخاصة» ما زال موجوداً على بُعد لمسة واحدة.

## أبرز الميزات

- **ترجمة بالذكاء الاصطناعي في كل مكان.** أشرطة التنقّل، وبطاقات الفيديو، وصفحات التفاصيل، والتعليقات، والديناميكيات، وشاشات «أنا / المفضلة / السجل / الرسائل / البحث» — تغطّي المسحة الشاملة **نحو 1650 نصاً من نصوص الواجهة**، إضافةً إلى المحتوى الديناميكي (العناوين، أسماء المؤلفين، العدّادات).
- **محرّكان بمفتاح واحد.** *المدمج* (الافتراضي) يستخدم نقطة الوصول المجانية لنموذج bilibili الرسمي **Index-Translate-35B-A3B** — بلا أي إعداد. أما *واجهتك الخاصة* فتحتفظ بالسلوك السابق: وجّهها إلى أي نقطة وصول `/chat/completions` متوافقة مع OpenAI، مع عنوانك الأساسي ومفتاحك ونموذجك. ويظل ملخّص الفيديو بالذكاء الاصطناعي وترجمة الواجهة بنقاط وصول وإعدادات **مستقلّة تماماً**، مجتمعةً في صفحة واحدة هي **«ميزات الذكاء الاصطناعي»**.
- **قائمة لغات واحدة يشترك فيها المحرّكان.** قائمة اللغات الهدف ليست مقسّمة حسب المحرّك؛ إنها القائمة ذاتها أيّاً كان المحرّك الذي تختاره. وهي توحّد **150 لغة** من نموذج bilibili الرسمي مع **4 لغات من الأقليات العرقية في الصين و3 لهجات صينية** يضيفها PiliBabel — التبتية والأويغورية والزهوانغ والهمونغ من جهة؛ والكانتونية والوو (الشنغهايية) والمنانية من جهة أخرى — إضافة إلى الصينية التقليدية. وتبقى التنويعات الإقليمية وتنويعات الكتابة **مدخلات منفصلة** بدل دمجها: العربية المغربية والمصرية والنجدية والشامية كلٌّ خيار قائم بذاته، وكذلك الصربية والأوزبكية والأردية بالحرفين السيريلي واللاتيني.
- **صراحة في التغطية.** اللغات داخل الفهرس الرسمي يغطّيها نموذج bilibili. أما القليلة الخارجة عنه — الصينية التقليدية، واللهجات الصينية ولغات الأقليات أعلاه التي لا تدرجها bilibili — فتظهر أيضاً في القائمة، موسومةً بذلك، لتعرف بنظرة واحدة أن النتيجة الأفضل قد تتطلّب نموذجك الخاص.
- **تُترجم مرة واحدة ثم تثبت.** كل نص مصدري يُترجم **مرة واحدة بالضبط**، وتُحفظ النتيجة محلياً و**لا تُترجم مجدداً** عند إعادة فتح أي شاشة — المبدأ نفسه الذي يتبعه العميل الرسمي، لترجمات مستقرة وقابلة للتوقّع.
- **مفتاح تبديل «الأصل ⇄ الترجمة» لكل تعليق** (أيقونة صغيرة، لا كلمة). تُحفظ `@الإشارات / [الرموز] / #المواضيع# / الروابط` كوحدات كاملة، و**التعليقات التي تحوي روابط تُترجم مع بقاء الرابط قابلاً للنقر**.
- **ترجمة الدانماكو** — مفتاح مستقل في شريط التحكم أعلى يمين المشغّل، **مطفأ افتراضياً** ويسبقه تأكيد تُترجم نصوصه نفسها. وبمجرد تشغيله، تُترجم الدانماكو التي تسبق موضع التشغيل مسبقاً على **دفعات من نحو 15 ثانية** (والقفز إلى المنتصف يُعالج من موضعه لا من البداية)، فتجده جاهزاً عادةً حين يمرّ على الشاشة.
- **مفتاح وضع التفكير** (`enable_thinking`) للمفاضلة بين الجودة والسرعة، مع زرَّي **«اختبار الترجمة»** و**«إفراغ الذاكرة المؤقتة»** في الإعدادات.
- **تبديل سريع للغة**: طلبات على دفعات بتزامن محدود فوق ذاكرة مؤقتة دائمة؛ وتبديل اللغة يعيد بناء الشاشة الحالية مرة واحدة، فلا تبقى تحدّق في نص غير مترجم. وإطفاء الترجمة يعيد الواجهة كلها إلى النص الأصلي و**لا يرسل أي طلب على الإطلاق**.
- **إرشاد عند أول تشغيل.** عند أول فتح للتطبيق يعرض مربّع حوار بالإنجليزية تفعيل الترجمة. ومن يوافق يحصل على: تفعيل الترجمة، واختيار النموذج المدمج، وفتح إعدادات الذكاء الاصطناعي، والسؤال فوراً عن اللغة المطلوبة — فينتقل المستخدم الجديد بلمستين من «مثبَّت للتو» إلى «مترجم بالفعل».
- **تشغيل يعمل في كل أنحاء العالم.** يختار PiliBabel الطرف الخارجي (Akamai العالمي، `mirror*ov`، `cn-hk-eq-bcache`) الذي تقدّمه أصلاً خدمة `playurl` ذات التوجيه الجغرافي لدى bilibili، بدل تثبيتك على عقدة في البرّ الرئيسي الصيني (علي كلاود / شنتشن) — فلا يعاني المستخدمون خارج البرّ الرئيسي الصيني من توقّف من نوع «الصوت مستمرّ والصورة متجمّدة». ويمكنك دائماً تحديد CDN يدوياً في الإعدادات.

## محرّكا الترجمة

| | المدمج (الافتراضي) | واجهتك الخاصة |
|---|---|---|
| النموذج | bilibili **Index-Translate-35B-A3B** | أي نموذج متوافق مع OpenAI |
| نقطة الوصول | `index-translate.bilibili.com/v1` | عنوانك الأساسي |
| مفتاح API | **غير مطلوب** | مفتاحك |
| التكلفة | مجاني | حسب مزوّدك |
| نمط الطلب | نص واحد لكل طلب | على دفعات (≤ 16 لكل طلب) |
| لغات إضافية | — | أي لغة يعرفها نموذجك |

**لماذا نص واحد لكل طلب في المحرّك المدمج.** إن Index-Translate نموذج **متخصّص** في الترجمة، والطريقة الموثّقة من مؤلفيه هي قالب أحادي العنصر («ترجم النص التالي إلى اللغة X، وأخرِج الترجمة فقط»). لذلك يرسل PiliBabel نصاً واحداً لكل طلب في هذا المحرّك، بدل موجّه الدفعات ذي «القائمة المرقّمة / مصفوفة JSON» المستخدم مع الواجهات الخاصة. ونقطة الوصول مجانية، فلا شيء يُكسَب من المقامرة على مخرجات الدفعات — إنها مقايضة واعية: طلبات أكثر بقليل مقابل احتمالات فشل أقل بكثير.

**الترقية من 0.3.x.** إعدادات واجهتك الخاصة — العنوان الأساسي والمفتاح والنموذج — **تُترك كما ضبطتها تماماً**. أما اختيار المحرّك فيؤول افتراضياً إلى النموذج المدمج، لذا ستكون عند أول تشغيل بعد الترقية على نموذج bilibili المجاني؛ افتح *الإعدادات ← الذكاء الاصطناعي ← ميزات الذكاء الاصطناعي ← محرّك الترجمة* وعُد إلى *واجهتك الخاصة* لتعود فوراً إلى إعدادك السابق.

## كيف تعمل ترجمة الواجهة (تقنياً)

لا يضم المستودع **أي طبقة موارد i18n / ARB** — نصوص الواجهة مكتوبة بالصينية مباشرةً في الشيفرة. وبدل إعادة كتابة كل عنصر واجهة، يضيف PiliBabel طبقة ترجمة رقيقة فوقها:

1. **غلاف بحث شامل.** يوفّر `lib/services/ui_translate/` دالة عليا `uiTx(String src)`. فما كان `Text('中文')` يصبح `Text(uiTx('中文'))`. وقد طبّق **codemod برمجي** ذلك على المشروع كله (`tool/ui_translate_*.py`) — نحو **223 ملفاً / 1650 نصاً** — مع إزالة الكلمة المفتاحية `const` التي لم تعد صالحة حيث لزم (بما في ذلك الأنواع العامة مثل `const X<T>(...)` والأسماء المنقوطة مثل `const Positioned.fill(...)`)، وتحويل تصريحات `static const` للقوائم والخرائط إلى `static final`.
2. **نواة `GetxService`** (`ui_translate_service.dart`):
   - ذاكرة مؤقتة دائمة **نص أصلي ← ترجمة** (مدعومة بـ GetStorage)، فيُترجم كل نص مرة واحدة ويُعاد استخدامه للأبد؛
   - يقرأ `tx()` أولاً `RxInt revision` ثم يقرّر: إن كانت الترجمة مطفأة → إرجاع الأصل؛ وإن كانت اللغة الهدف **الصينية المبسّطة (`zh-CN`)** → إرجاع الأصل دون طلب واجهة (فمحتوى bilibili مبسّط في الغالب الساحق). وأي هدف آخر — بما في ذلك الصينية التقليدية والكانتونية والوو والمنانية — يمرّ عبر المحرّك المضبوط؛ **فمجرد الانتماء إلى الأسرة الصينية لا يكفي لتخطّي الترجمة**. ثم: الإرضاء من الذاكرة أو **الإدراج في الطابور**؛
   - تتولّى **مجموعة عمّال** معالجة النصوص المُدرَجة، مع **تطبيق تدريجي لكل كتلة** (كل كتلة تعود ترفع `revision`، فيتحدّث النص تدريجياً)، وتُحفظ النتائج **بشكل دائم** (مع تخفيف التكرار). ويتابع حجم الدفعة والتزامن المحرّك: **واحد لكل طلب** في النموذج المدمج، و**≤ 16 مع ≤ 10 قيد التنفيذ** في واجهتك الخاصة.
3. **تحديد المحرّك.** يحدّد `TranslateProvider` (`builtin` / `custom`) أي عنوان ومفتاح ونموذج تستخدمه طبقة النقل؛ وبخلاف ذلك يتشارك المحرّكان مسار شيفرة واحداً وقائمة لغات واحدة، فتبديل المحرّك إعداد واحد و**ليس أبداً مجموعة ميزات مختلفة**.
4. **طبقة النقل** تعيد استخدام مسار **البث** المجرَّب نفسه المستخدم في ملخّص الفيديو بالذكاء الاصطناعي — `AiChatService.streamChat` ← `{base}/chat/completions` مع `stream: true` (متوافق مع البوابات التي تدعم البث فقط) — موسَّعاً ليتمكّن مسار الترجمة من استخدام `apiUrl` / `apiKey` / `model` **الخاصة به** وراية `enable_thinking`. والتغيير **متوافق مع الإصدارات السابقة**، فيواصل ملخّص الفيديو عمله دون تغيير.
5. **الجمل ذات العناصر البديلة** تمرّ عبر `uiTxP(template, args)`: تُترجم الجملة كاملةً بما فيها `{0}`/`{1}` كمفتاح مستقر واحد (ويطلب الموجّه من النموذج الحفاظ على العناصر البديلة)، ثم تُعاد القيم إلى مواضعها — فجمل مثل `"共 {0} 条"` تُترجم دون إفساد الأجزاء الديناميكية.
6. **جدول اللغات** (`app_language.dart`): كل `AppLanguage` يحمل اسماً ذاتياً للعرض، وسلسلة موجّه `toModel` تُرمّز قواعد الكتابة والمنطقة، وإشارة إلى ما إذا كان الفهرس الرسمي لدى bilibili يغطّيها. وقواعد الكتابة (المبسّطة / التقليدية) وتوجيهات اتساق اللهجة تصل إلى النموذج **عبر الموجّه وحده**، ثم تُجري جهة العميل مسحة تطبيع حرفية حتمية لتصحيح الحروف الشاردة.
7. **التعليقات** تمرّ عبر `uiTxComment(text, id)`، مع الحفاظ على `@ / [الرموز] / #الموضوع# / الرابط` كوحدات سليمة؛ وتُترجم المقاطع النصية الغنية الحاملة للروابط مع صون التعرّف على الروابط، وتقود مجموعة معرّفات لكل تعليق مفتاح التبديل «الأصل ⇄ الترجمة».
8. **الدانماكو** (`danmaku/view.dart`): عند تشغيل مفتاحه، يمرّ مستمع موضع على `[موضع التشغيل، موضع التشغيل + 15 ثانية]` ثانيةً بثانية ويسخّن `uiTx()` على محتوى كل دانماكو، فتكون العناصر مترجمة قبل وصولها إلى الشاشة؛ وعند التشغيل تُفرَّغ اللوحة ويُعاد رسمها.
9. **مفاتيح التخزين**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. و**واجهة الإعدادات**: صفحة واحدة من المستوى الأول «ميزات الذكاء الاصطناعي» (`lib/pages/setting/ui_translate/`) بكتلتين مستقلّتين لملخّص الفيديو وترجمة الواجهة.

**CDN عالمي (`VideoUtils.getCdnUrl`).** روابط البث موقَّعة، وتغيير مضيف الرابط يؤدّي إلى رفض 403 — لذلك **لا يغيّر مسار التشغيل المضيف أبداً**. ويعيد PiliBabel الرابط ذا التوجيه الجغرافي الذي تسلّمه bilibili إلى عنوان العميل، وعندما تضمّ قائمة المرشّحين أصلاً طرفاً خارجياً (`*.akamaized.net`، `mirror(cos|ali|hw)ov`، `cn-hk-eq-bcache`) يُفضَّل ذاك. أما التنزيلات، حيث يكون تبديل المضيف آمناً، فتفضّل إضافةً طرف Akamai العالمي وتنتقل إلى المرشّح الموقَّع التالي عند توقّف خط أو رفض استئناف. وروابط `/v/resource` الخام (P2P) تظل ترتد إلى المُرحّل الحالي تفادياً لأخطاء 404.

**مقايضات التصميم / حدود معلومة.** لأن النصوص تُغلَّف في موضعها بدل استخراجها إلى موارد، فإن بعض معاملات النصوص غير `Text` وبعض مقاطع النص الغني ما زالت تُستكمل تدريجياً. والنصوص التي تعمل أيضاً **مفاتيح منطقية** (تُقارَن بـ `==`، أو تُستخدم أسماء تبويبات مثل `简介`، أو تصنيفات تعداد في المفاتيح) **لا تُغلَّف عمداً** بشكل شامل، تفادياً لكسر السلوك. وترجمة الدانماكو جهدٌ بذل أقصى على لوحة متحرّكة — ومع دانماكو كثيف جداً قد ترى الأصل لحظات قبل وصول الترجمة. وتحتاج الترجمة إلى شبكة؛ وبدونها لا تسري الأهداف غير الصينية. ونقطة الوصول المدمجة خدمة عامة مجانية تشغّلها bilibili — وإن خُدّت سرعتها أو تعذّرت، يخبرك التطبيق بذلك ويمكنك الانتقال إلى واجهتك الخاصة.

## البناء والتحقّق

يُبنى التطبيق بـ Flutter SDK مُرقَّع وحزمتَي `material_ui` / `cupertino_ui` مُرقَّعتين، عبر `lib/scripts/patch.ps1` و`lib/scripts/build.ps1` (تماماً كما في PiliNara / PiliPlus). وينتج GitHub Actions **APK للتنقيح** مع كل دفعة (`.github/workflows/ui-translate-debug.yml`)، كما أن **نشر وسم `v*` يبني وينشر تلقائياً مخرجات Android و Windows و Linux** (`.github/workflows/release.yml`، `win_x64.yml`، `linux_x64.yml`).

<br/>

## المنصّات
- [x] Android
- [ ] iOS
- [ ] الأجهزة اللوحية
- [x] Windows
- [x] Linux

يوفّر PiliBabel في الإصدارات بناءات **Android (APK) و Windows و Linux**؛ أما iOS والأجهزة اللوحية فلم تُحزَّم بعد في هذا الفرع.

<br/>

## التنزيل

احصل على بناء من **الإصدارات**، أو استنسخ المستودع وابنِه محلياً.

### Arch Linux

شكراً لـ [@nlsdt](https://github.com/nlsdt) على التحزيم (وصفة PiliNara تنطبق على PiliBabel أيضاً).

```bash
sudo pacman -S pilinara      # من مستودع Arch Linux CN
paru -S pilinara-bin         # أو عبر AUR: pilinara-bin (مبنياً مسبقاً) / pilinara (المصدر)
```

<br/>

## سجل الميزات الموروثة (من PiliNara / PiliPlus)

كل ما يلي موروث من PiliNara (وبالتبعية من PiliPlus)؛ ويضيف PiliBabel طبقة الترجمة بالذكاء الاصطناعي فوقه.

**الواجهة والتكيّف مع المنصّات**
- [x] إعادة تسمية التطبيق لكل منصّة ليتعايش عدة عملاء (يُثبَّت PiliBabel بجانب PiliNara)
- [x] إصلاح عرض Flutter في نافذة Xiaomi HyperOS المصغّرة ([#161086](https://github.com/flutter/flutter/issues/161086)، عبر [venera#467](https://github.com/venera-app/venera/pull/467))؛ حركة الرجوع التنبّؤية على Android
- [x] ترتيب وعدد بطاقات «أنا» قابلان للتخصيص؛ معاينة بطاقات السجل وقسم «المشاهدة لاحقاً»
- [x] تبديل تلقائي للشريط الجانبي بعرض تشغيل قابل للضبط؛ نسخ الصورة بالضغط المطوّل / النقر الأيمن؛ تحديث كبير بنمط MD3E

**نظام الخطوط** — مجمّع استيراد موحّد مع إزالة التكرار ببصمة المحتوى، وخطوط الدانماكو مدمجة في المجمّع نفسه، و`loadFontFromList` بدعم ttc، وأسماء عائلات خطوط بترميز ASCII خالص.

**التشغيل والنافذة المصغّرة والجودة** — نافذة مصغّرة داخل التطبيق (سحب، تغيير حجم، تخطّي SponsorBlock، PIP نظام تلقائي، شريط إنقاذ ذاتي للبث)، تشغيل صوتي متزامن، صوت داخل التطبيق حتى 200%، نطاق CDN مخصّص للفيديو واختيار عقدة إقليمية مع قياس الكمون، جودة افتراضية منفصلة لنصف الشاشة والشاشة الكاملة، قفل السرعة بالسحب للأعلى، تحكّم بلوحة المفاتيح على الأجهزة اللوحية، طوابع زمن SuperChat في البث، ونبض حميمية المعجبين في البث.

**الترجمات والذكاء الاصطناعي والعمل دون اتصال** — ترجمات ثنائية اللغة بنمط مستقل للترجمة الثانوية، وتحليل ترجمات بالذكاء الاصطناعي (نقطة وصول مخصّصة متوافقة مع OpenAI، انتقال إلى الطابع الزمني، قوالب، محادثات محفوظة، ارتداد لين عند غياب الترجمة)، وتصدير WEBVTT/SRT، وعرض مزدوج لذاكرة العمل دون اتصال مع إدارة مجلدات وحفظ البيانات الوصفية، وتصدير التنزيلات إلى مجلد Download العام (Android).

**الدانماكو والحجب** — تحسين تكبير الدانماكو المدمجة (بأسلوب [Pakku.js](https://github.com/xmcp/pakku.js))، وحجب بتعابير نمطية مرئية على شكل قائمة مع استيراد وتصدير، وتخطٍّ داخل مقطع SponsorBlock، وشريط تقدّم عالي الطاقة بنواة غاوسية.

**تصفية التوصيات / الديناميكيات / التعليقات** — كلمات مفتاحية للعنوان / المبدع / القسم، والمدة، وعدد المشاهدات، ونسبة الإعجاب، وإعفاء المبدعين المتابَعين، وتصفية غير المصرّح به / الحصري للداعمين، وقائمة بيضاء مشتركة، والديناميكيات التجارية / غير المصرّح بها، وإعفاء تعليقات المبدع وتعليقاته المثبَّتة، ووضع التغذية المدمج للتطبيق + الويب.

**الديناميكيات والبحث ومعلومات المستخدم** — ملاحظات مخصّصة للمبدعين، والملاحظة تحلّ محل الكنية في 13 موضعاً، وترتيب مستقل للردود المتداخلة، وتصفية بحث بالكلمات المفتاحية محلياً، وانتقال عبر روابط b23.tv القصيرة، وشارة «حصري للداعمين»، ومفتاح إخفاء سبب التوصية، وعرض خبرة العملات.

**تحسينات البث المباشر** — لوحة ارتداء ميدالية المعجب، وبثّ DLNA مع تفضيل HLS، وعرض وقت SuperChat، وشريط تحكّم سفلي في النافذة المصغّرة للإنقاذ الذاتي.

**التكامل مع النظام وسطح المكتب** — Windows SMTC، و Linux MPRIS (`audio_service_mpris`)، ومعالجة تركيز الصوت معادة الكتابة.

<details>
<summary>قائمة الميزات الأصلية الكاملة (حرفياً من PiliNara — انقر للفتح)</summary>

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

## إخلاء المسؤولية

PiliBabel مشروع شخصي مدفوع بالاهتمام، ويُقدَّم **للتعلّم والاختبار فقط**؛ يُرجى حذفه خلال **24 ساعة** من التنزيل.

- PiliBabel عميل **من طرف ثالث غير رسمي** و**ليس تابعاً لـ bilibili ولا معتمداً منها ولا مدعوماً منها**.
- جميع الواجهات البرمجية مأخوذة من نقاط وصول عامة رسمية؛ **ولا يُقدَّم أي محتوى مكسور أو مفرط الصلاحيات أو متجاوز لجدران الدفع**.
- **تعمل الترجمة بالذكاء الاصطناعي على نقطة وصول نموذج من طرف ثالث.** وهي افتراضياً خدمة Index-Translate العامة المجانية التي تشغّلها bilibili نفسها؛ وإن انتقلت إلى واجهتك الخاصة فهي النقطة التي ضبطتها. ومسؤولية جودة الترجمة والامتثال تقع على المستخدم ومزوّد النموذج المختار؛ وهذا المشروع **لا يستضيف أي نموذج ولا يوفّر أي مفتاح API**.
- احترم حقوق النشر وشروط استخدام bilibili. واستخدمه بمسؤولية.

مع التقدير للمؤلفين الأصليين والسابقين على تفانيهم في المصادر المفتوحة:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — المشروع الأب المباشر لـ PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — عائلة نماذج الترجمة مفتوحة المصدر التي يستدعيها المحرّك المدمج

إن كان أي محتوى ينتهك حقوقك، تواصل معنا لإزالته.

<br/>

## الترخيص

يُرخَّص PiliBabel تحت **GNU General Public License v3.0 (GPL-3.0)** — الترخيص نفسه الذي تتبعه PiliNara و PiliPlus و PiliPala. ولأنه عمل مشتق، **يجب توزيع PiliBabel أيضاً تحت GPL-3.0**: لك حرية استخدامه ودراسته ومشاركته وتعديله، شرط الحفاظ على الترخيص نفسه وإشعارات حقوق النشر ونص الترخيص هذا. انظر [`LICENSE`](./LICENSE).

المكوّنات من طرف ثالث (حزم Flutter، [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect)، [`media-kit`](https://github.com/media-kit/media-kit)، [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer)، [`dio`](https://pub.dev/packages/dio) وغيرها) تبقى تحت تراخيصها الخاصة.

<br/>

## شكر وتقدير

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — عائلة نماذج الترجمة مفتوحة المصدر من bilibili، ونقطة الوصول العامة المجانية خلف المحرّك المدمج
- وغيرها الكثير
- مستوحى من «ترجمة الواجهة بالذكاء الاصطناعي» الرسمية لدى bilibili.

<sub><a href="#readme-languages">↑ <a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a> · <a href="#readme-fr">Français</a> · <a href="#readme-de">Deutsch</a> · <a href="#readme-es">Español</a> · <a href="#readme-ko">한국어</a> · <a href="#readme-ar">العربية</a> · <a href="#readme-vi">Tiếng Việt</a> · <a href="#readme-ms">Bahasa Melayu</a> · <a href="#readme-id">Bahasa Indonesia</a></a></sub>

</details>

---

<details>
<summary><b>Tiếng Việt</b></summary>

<a id="readme-vi"></a>

## Tiếng Việt

<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Ứng dụng khách Bilibili của bên thứ ba, có dịch bằng AI.</b></p>
    <p>Babel — phá bỏ bức tường ngôn ngữ, để ai cũng được thưởng thức bilibili bằng tiếng của mình.</p>
    <p>Bao gồm dịch 4 ngôn ngữ dân tộc thiểu số của Trung Quốc và 3 phương ngữ tiếng Trung.</p>
    <p>Dịch hoạt động ngay sau khi cài, trên mô hình miễn phí của bilibili — không cần khóa API.</p>
</div>

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Trang chủ" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Động thái" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Của tôi" />
</div>

<br/>

> **Tuyên bố miễn trách.** PiliBabel là ứng dụng **không chính thức, mã nguồn mở, của bên thứ ba**. Nó **không liên kết, không được xác nhận và không được tài trợ bởi** bilibili / bilibili Inc. Mọi API đều lấy từ các điểm truy cập công khai chính thức; **không mở khóa hay bẻ khóa bất kỳ nội dung trả phí nào**. Vui lòng đọc trọn hai mục [Tuyên bố miễn trách](#tuyên-bố-miễn-trách) và [Giấy phép](#giấy-phép).

## PiliBabel là gì?

PiliBabel là một **bản fork độc lập của bên thứ ba, dựng trên [PiliNara](https://github.com/Starfallan/PiliNara)**, và thừa hưởng mọi thứ mà PiliNara thừa hưởng:

```
bilibili (API công khai chính thức)
        ▲
   PiliPala / PiliPalaX        — dự án gốc
        ▲
   PiliPlus                    — bản fork đang phát triển
        ▲
   PiliNara                    — bản fork của PiliPlus (chỉnh sửa cá nhân)
        ▲
   PiliBabel  ← bạn đang ở đây   — bản fork của PiliNara
```

PiliBabel giữ **toàn bộ tính năng của PiliNara / PiliPlus** (xem [danh sách tính năng kế thừa](#danh-sách-tính-năng-kế-thừa-từ-pilinara--piliplus) ở cuối) và bổ sung **một năng lực chủ đạo mà các ứng dụng gốc không có**:

> **Dịch giao diện và nội dung bằng AI** — toàn bộ ứng dụng (nhãn giao diện, tiêu đề video, tên chủ kênh, bình luận, động thái, bảng tin, và cả danmaku trực tiếp) hiển thị bằng ngôn ngữ **mà bạn** chọn.

Và từ phiên bản 1.0, việc đó chạy **ngay sau khi cài**: mô hình dịch đã được **tích hợp sẵn**. bilibili đã mở mã nguồn mô hình dịch của chính mình, [Index-Translate](https://github.com/bilibili/Index-Translate), và phục vụ nó qua một điểm truy cập công khai miễn phí. PiliBabel mặc định trỏ vào đó, nên bản dịch chạy ngay khi bạn cài ứng dụng — không đăng ký, không khóa, không hóa đơn. Nếu muốn dùng mô hình của riêng mình, đường dẫn «API riêng» vẫn còn nguyên, chỉ cách một lần chạm.

## Tính năng chính

- **Dịch bằng AI, ở khắp mọi nơi.** Thanh điều hướng, thẻ video, trang chi tiết, bình luận, động thái, cùng các màn hình Của tôi / Yêu thích / Lịch sử / Tin nhắn / Tìm kiếm — một lượt quét toàn cục bao phủ **khoảng 1650 chuỗi giao diện**, cộng thêm nội dung động (tiêu đề, tên tác giả, các bộ đếm).
- **Hai bộ máy, một công tắc.** *Tích hợp* (mặc định) dùng điểm truy cập miễn phí của mô hình chính thức **Index-Translate-35B-A3B** của bilibili — không cần cấu hình gì. *API riêng* giữ nguyên hành vi trước đây: trỏ tới bất kỳ điểm truy cập `/chat/completions` tương thích OpenAI nào, với URL gốc / khóa / mô hình của bạn. Tính năng tóm tắt video bằng AI và dịch bằng AI vẫn có điểm truy cập và cài đặt **hoàn toàn độc lập**, cùng nằm trong một trang **«Tính năng AI»**.
- **Một danh sách ngôn ngữ, dùng chung cho cả hai bộ máy.** Danh sách ngôn ngữ đích không chia theo bộ máy: bạn chọn bộ máy nào cũng là cùng một danh sách. Nó hợp nhất **150 ngôn ngữ** của mô hình chính thức bilibili với **4 ngôn ngữ dân tộc thiểu số của Trung Quốc và 3 phương ngữ tiếng Trung** mà PiliBabel bổ sung — tiếng Tây Tạng, Duy Ngô Nhĩ, Choang và H'Mông ở một phía; tiếng Quảng Đông, Ngô (Thượng Hải) và Mân Nam ở phía kia — cùng tiếng Trung phồn thể. Các biến thể vùng miền và chữ viết vẫn là **mục riêng biệt** thay vì gộp lại: tiếng Ả Rập Maroc / Ai Cập / Najd / Levant mỗi thứ là một lựa chọn riêng, tương tự tiếng Serbia, Uzbek và Urdu ở dạng chữ Kirin hoặc Latinh.
- **Nói thẳng về phạm vi bao phủ.** Những ngôn ngữ nằm trong danh mục chính thức do mô hình bilibili đảm nhiệm. Vài ngôn ngữ nằm ngoài — tiếng Trung phồn thể, cùng các phương ngữ tiếng Trung và ngôn ngữ dân tộc thiểu số nêu trên mà bilibili không liệt kê — vẫn xuất hiện trong danh sách, có đánh dấu rõ, để bạn thấy ngay rằng muốn kết quả tốt hơn có thể cần mô hình của riêng bạn.
- **Dịch một lần rồi cố định.** Mỗi chuỗi gốc được dịch **đúng một lần**; kết quả lưu cục bộ và **không bao giờ dịch lại** khi bạn mở lại màn hình — cùng nguyên tắc với ứng dụng chính thức, cho bản dịch ổn định và dễ đoán.
- **Nút chuyển «Nguyên văn ⇄ Bản dịch» cho từng bình luận** (một biểu tượng nhỏ, không phải một từ). `@lượt nhắc / [biểu tượng cảm xúc] / #chủ đề# / liên kết` được giữ nguyên như các token, và **bình luận chứa siêu liên kết vẫn được dịch trong khi liên kết vẫn bấm được**.
- **Dịch danmaku** — một công tắc riêng trong hàng điều khiển góc trên bên phải trình phát, **mặc định tắt** và có bước xác nhận mà chính nội dung xác nhận cũng được dịch. Khi đã bật, danmaku phía trước vị trí phát được dịch trước theo **từng lô khoảng 15 giây** (nhảy vào giữa được xử lý đúng chỗ, không phải từ đầu), nên bản dịch thường sẵn sàng khi chúng lướt qua.
- **Công tắc chế độ suy luận** (`enable_thinking`) để cân giữa chất lượng và tốc độ, kèm hai nút **«thử dịch»** và **xóa bộ nhớ đệm** trong cài đặt.
- **Đổi ngôn ngữ nhanh**: yêu cầu theo lô với số luồng đồng thời giới hạn trên bộ nhớ đệm lâu dài; đổi ngôn ngữ sẽ dựng lại màn hình hiện tại một lần, để bạn không phải nhìn mãi vào phần chữ chưa dịch. Tắt dịch bằng AI sẽ trả toàn bộ giao diện về nguyên văn và **không gửi bất kỳ yêu cầu nào**.
- **Hướng dẫn ở lần mở đầu tiên.** Lần đầu mở ứng dụng, một hộp thoại tiếng Anh đề nghị bật dịch. Nếu đồng ý, nó bật dịch, chọn mô hình tích hợp, mở trang cài đặt AI và hỏi ngay bạn muốn ngôn ngữ nào — người dùng mới đi từ «vừa cài xong» tới «đã dịch xong» chỉ với hai lần chạm.
- **Phát được ở mọi nơi trên thế giới.** PiliBabel chọn điểm biên ở nước ngoài (global **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) mà `playurl` định tuyến theo vị trí của bilibili vốn đã cung cấp, thay vì ghim bạn vào một nút ở Trung Quốc đại lục (Alibaba Cloud / Thâm Quyến) — nên người dùng ngoài Trung Quốc đại lục không còn gặp cảnh «tiếng vẫn chạy, hình đứng im». Bạn vẫn có thể chỉ định CDN thủ công trong cài đặt.

## Hai bộ máy dịch

| | Tích hợp (mặc định) | API riêng |
|---|---|---|
| Mô hình | bilibili **Index-Translate-35B-A3B** | bất kỳ mô hình tương thích OpenAI |
| Điểm truy cập | `index-translate.bilibili.com/v1` | URL gốc của bạn |
| Khóa API | **không cần** | của bạn |
| Chi phí | miễn phí | tùy nhà cung cấp |
| Cách gửi | một chuỗi mỗi yêu cầu | theo lô (≤ 16 mỗi yêu cầu) |
| Ngôn ngữ thêm | — | mọi ngôn ngữ mô hình của bạn biết |

**Vì sao bộ máy tích hợp gửi từng chuỗi một.** Index-Translate là mô hình **chuyên** dịch, và cách gọi mà chính tác giả tài liệu hóa là một mẫu đơn phần («dịch đoạn văn sau sang X, chỉ xuất bản dịch»). Vì vậy trên bộ máy này PiliBabel gửi một chuỗi mỗi yêu cầu, thay vì lời nhắc theo lô kiểu «danh sách đánh số / mảng JSON» dùng cho API riêng. Điểm truy cập miễn phí, nên chẳng có gì để được khi đánh cược vào đầu ra theo lô — đây là một đánh đổi có chủ đích: thêm vài yêu cầu để đổi lấy ít hơn hẳn khả năng thất bại.

**Nâng cấp từ 0.3.x.** Phần API riêng bạn đã cấu hình — URL gốc, khóa và mô hình — được **giữ nguyên xi, không bị ghi đè**. Việc chọn bộ máy chỉ mặc định sang mô hình tích hợp, nên lần mở đầu tiên sau khi nâng cấp bạn sẽ dùng mô hình miễn phí của bilibili; mở *Cài đặt → AI → Tính năng AI → bộ máy dịch* và chuyển về *API riêng* là quay lại cấu hình cũ ngay.

## Cách hoạt động của dịch giao diện (kỹ thuật)

Kho mã **không có lớp tài nguyên i18n / ARB nào** — chuỗi giao diện được viết cứng bằng tiếng Trung. Thay vì viết lại từng widget, PiliBabel phủ lên một lớp dịch mỏng:

1. **Một lớp bọc tra cứu toàn cục.** `lib/services/ui_translate/` cung cấp hàm cấp cao nhất `uiTx(String src)`. Chỗ từng là `Text('中文')` nay thành `Text(uiTx('中文'))`. Một **codemod bằng script** đã áp dụng điều này khắp dự án (`tool/ui_translate_*.py`) — khoảng **223 tệp / 1650 chuỗi** — đồng thời tự động bỏ từ khóa `const` đã trở nên không hợp lệ ở những chỗ cần thiết (kể cả generics như `const X<T>(...)` và tên có dấu chấm như `const Positioned.fill(...)`), và chuyển các khai báo `static const` dạng danh sách / map thành `static final`.
2. **Lõi `GetxService`** (`ui_translate_service.dart`):
   - một bộ nhớ đệm lâu dài **nguyên văn → bản dịch** (dựa trên GetStorage), nên mỗi chuỗi chỉ dịch một lần và dùng lại mãi mãi;
   - `tx()` đọc `RxInt revision` trước, rồi quyết định: nếu đang tắt → trả nguyên văn; nếu đích là **tiếng Trung giản thể (`zh-CN`)** → trả nguyên văn mà không gọi API (nội dung bilibili áp đảo là giản thể). Mọi đích khác — kể cả phồn thể, tiếng Quảng Đông, tiếng Ngô và Mân Nam — đều đi qua bộ máy đã cấu hình; **chỉ thuộc nhóm ngôn ngữ Trung Quốc là chưa đủ để bỏ qua dịch**. Sau đó: phục vụ từ bộ nhớ đệm hoặc **xếp hàng**;
   - các chuỗi trong hàng được một **nhóm worker** xử lý, với **áp dụng tăng dần theo từng khối** (mỗi khối trả về lại tăng `revision`, nên chữ cập nhật dần), và kết quả được **lưu bền** (có tiết chế tần suất). Cỡ lô và số luồng đồng thời đi theo bộ máy: **1 mỗi yêu cầu** trên mô hình tích hợp, **≤ 16 với ≤ 10 đang bay** trên API riêng.
3. **Xác định bộ máy.** `TranslateProvider` (`builtin` / `custom`) quyết định URL, khóa và mô hình mà lớp truyền tải dùng; ngoài điều đó, hai bộ máy chia sẻ một đường mã và một danh sách ngôn ngữ — nên đổi bộ máy chỉ là một cài đặt, **không bao giờ là một bộ tính năng khác**.
4. **Lớp truyền tải** dùng lại đúng kênh **truyền phát** đã được kiểm chứng của tính năng tóm tắt video bằng AI — `AiChatService.streamChat` → `{base}/chat/completions` với `stream: true` (tương thích cả với gateway chỉ hỗ trợ truyền phát) — mở rộng để phần dịch dùng được `apiUrl` / `apiKey` / `model` **riêng** và cờ `enable_thinking`. Thay đổi này **tương thích ngược**, nên tóm tắt video vẫn chạy như cũ.
5. **Câu có phần giữ chỗ** đi qua `uiTxP(template, args)`: một câu trọn vẹn chứa `{0}`/`{1}` được dịch như một khóa ổn định (lời nhắc yêu cầu mô hình giữ nguyên phần giữ chỗ), rồi các giá trị được đắp lại — nên những câu kiểu `"共 {0} 条"` được dịch mà không làm hỏng phần động.
6. **Bảng ngôn ngữ** (`app_language.dart`): mỗi `AppLanguage` mang một tên tự gọi để hiển thị, một chuỗi lời nhắc `toModel` mã hóa quy ước chữ viết và vùng miền, cùng một dấu cho biết danh mục chính thức của bilibili có bao phủ nó hay không. Quy tắc chữ viết (giản thể / phồn thể) và yêu cầu nhất quán phương ngữ chỉ **đi tới mô hình qua lời nhắc**, sau đó một lượt chuẩn hóa chữ viết tất định ở phía ứng dụng sẽ sửa những ký tự lạc.
7. **Bình luận** đi qua `uiTxComment(text, id)`, giữ `@ / [biểu tượng] / #chủ đề# / liên kết` nguyên vẹn như token; các đoạn văn bản giàu định dạng có liên kết vẫn được dịch mà vẫn nhận diện được liên kết, và một tập id theo từng bình luận điều khiển nút chuyển «Nguyên văn ⇄ Bản dịch».
8. **Danmaku** (`danmaku/view.dart`): khi công tắc bật, một bộ lắng nghe vị trí chạy qua `[vị trí phát, vị trí phát + 15 giây]` từng giây một và làm nóng `uiTx()` trên nội dung mỗi danmaku, nên chúng được dịch trước khi lên màn hình; khi bật sẽ xóa và vẽ lại khung vẽ.
9. **Khóa lưu trữ**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Giao diện cài đặt**: một trang cấp một duy nhất «Tính năng AI» (`lib/pages/setting/ui_translate/`) với các khối độc lập cho tóm tắt video AI và dịch giao diện.

**CDN toàn cầu (`VideoUtils.getCdnUrl`).** URL luồng được ký, và việc đổi máy chủ của một URL sẽ bị từ chối với 403 — nên phần phát **không bao giờ đổi máy chủ**. PiliBabel trả về URL đã định tuyến theo vị trí mà bilibili giao cho IP của ứng dụng, và khi danh sách ứng viên vốn đã có một điểm biên nước ngoài (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`) thì ưu tiên điểm đó. Với tải xuống, nơi việc đổi máy chủ là an toàn, hệ thống còn ưu tiên điểm biên Akamai toàn cầu và xoay sang ứng viên đã ký kế tiếp khi một tuyến đứng hoặc từ chối nối tiếp. Các liên kết P2P thô `/v/resource` vẫn quay về trung chuyển sẵn có để tránh lỗi 404.

**Đánh đổi thiết kế / giới hạn đã biết.** Vì các chuỗi được bọc tại chỗ thay vì tách ra thành tài nguyên, một số tham số chuỗi không phải `Text` và vài đoạn văn bản giàu định dạng vẫn đang được bổ sung dần. Những chuỗi đồng thời làm **khóa logic** (so sánh bằng `==`, dùng làm tên tab như `简介`, hoặc nhãn liệt kê trong công tắc) **cố ý không** được bọc hàng loạt, để khỏi phá vỡ hành vi. Dịch danmaku là nỗ lực hết mức trên một khung vẽ cuộn — với danmaku cực dày, bạn có thể thấy nguyên văn trong chốc lát trước khi bản dịch tới. Dịch cần mạng; không có mạng thì các đích ngoài tiếng Trung đơn giản là không hiện. Điểm truy cập tích hợp là dịch vụ công khai miễn phí do bilibili vận hành — nếu bị giới hạn tốc độ hay tạm ngưng, ứng dụng sẽ báo rõ và bạn có thể chuyển sang API riêng.

## Biên dịch và kiểm chứng

Ứng dụng được biên dịch bằng Flutter SDK đã vá cùng các gói `material_ui` / `cupertino_ui` đã vá, qua `lib/scripts/patch.ps1` và `lib/scripts/build.ps1` (giống hệt PiliNara / PiliPlus). GitHub Actions tạo **APK gỡ lỗi** sau mỗi lần đẩy mã (`.github/workflows/ui-translate-debug.yml`), và **phát hành thẻ `v*` sẽ tự động biên dịch và phát hành các gói cho Android, Windows và Linux** (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Nền tảng
- [x] Android
- [ ] iOS
- [ ] Máy tính bảng
- [x] Windows
- [x] Linux

PiliBabel phát hành bản dựng cho **Android (APK), Windows và Linux** trong Releases; bản fork này chưa đóng gói iOS và máy tính bảng.

<br/>

## Tải về

Lấy một bản dựng từ **Releases**, hoặc nhân bản kho mã và tự biên dịch tại máy.

### Arch Linux

Cảm ơn [@nlsdt](https://github.com/nlsdt) đã đóng gói (công thức của PiliNara dùng được luôn cho PiliBabel).

```bash
sudo pacman -S pilinara      # từ kho Arch Linux CN
paru -S pilinara-bin         # hoặc qua AUR: pilinara-bin (dựng sẵn) / pilinara (mã nguồn)
```

<br/>

## Danh sách tính năng kế thừa (từ PiliNara / PiliPlus)

Toàn bộ phần dưới đây được kế thừa từ PiliNara (và xa hơn nữa là PiliPlus); PiliBabel phủ thêm lớp dịch bằng AI lên trên.

**Giao diện và thích ứng nền tảng**
- [x] Đổi tên ứng dụng theo từng nền tảng để nhiều ứng dụng cùng tồn tại (PiliBabel cài song song với PiliNara)
- [x] Sửa lỗi hiển thị Flutter trong cửa sổ nhỏ của Xiaomi HyperOS ([#161086](https://github.com/flutter/flutter/issues/161086), qua [venera#467](https://github.com/venera-app/venera/pull/467)); hiệu ứng quay lại dự đoán trên Android
- [x] Tùy chỉnh thứ tự và số lượng thẻ «Của tôi»; xem trước thẻ lịch sử và mục «xem sau»
- [x] Tự động chuyển thanh bên với ngưỡng kích hoạt điều chỉnh được; sao chép ảnh bằng nhấn giữ / nhấp chuột phải; đổi mới diện mạo MD3E

**Hệ thống phông chữ** — một nhóm nhập thống nhất có khử trùng lặp bằng băm nội dung, phông danmaku gộp chung vào cùng nhóm, `loadFontFromList` hỗ trợ ttc, và tên họ phông thuần ASCII.

**Phát, cửa sổ nhỏ và chất lượng** — cửa sổ nhỏ trong ứng dụng (kéo, đổi kích thước, bỏ qua SponsorBlock, PIP hệ thống tự động, thanh tự cứu cho luồng trực tiếp), phát âm thanh đồng thời, âm lượng trong ứng dụng tới 200 %, tên miền CDN video tùy chỉnh và chọn nút theo vùng kèm đo độ trễ, chất lượng mặc định riêng cho nửa màn hình và toàn màn hình, khóa tốc độ khi vuốt lên, điều khiển bằng bàn phím trên máy tính bảng, mốc thời gian SuperChat trực tiếp, nhịp tim cho độ thân thiết của fan khi xem trực tiếp.

**Phụ đề, AI và ngoại tuyến** — phụ đề song ngữ với kiểu dáng phụ đề phụ độc lập, phân tích phụ đề bằng AI (điểm truy cập tương thích OpenAI tùy chỉnh, nhảy tới mốc thời gian, mẫu, hội thoại lưu bền, dự phòng mềm khi không có phụ đề), xuất WEBVTT/SRT, chế độ xem kép cho bộ nhớ đệm ngoại tuyến với quản lý thư mục và lưu bền siêu dữ liệu, xuất bản tải về thư mục Download công khai (Android).

**Danmaku và chặn** — cải thiện tỉ lệ phóng đại danmaku gộp (kiểu [Pakku.js](https://github.com/xmcp/pakku.js)), chặn bằng biểu thức chính quy trực quan dạng danh sách có nhập và xuất, bỏ qua vào trong đoạn SponsorBlock, thanh tiến trình năng lượng cao bằng nhân Gauss.

**Lọc gợi ý / động thái / bình luận** — từ khóa tiêu đề / chủ kênh / khu vực, thời lượng, số lượt xem, tỉ lệ thích, miễn trừ kênh đã theo dõi, lọc nội dung chưa cấp phép / chỉ dành cho người ủng hộ, danh sách trắng chia sẻ, động thái thương mại / chưa cấp phép, miễn trừ bình luận của chính chủ kênh và bình luận ghim, chế độ bảng tin hợp nhất App + Web.

**Động thái, tìm kiếm và thông tin người dùng** — ghi chú riêng cho chủ kênh, ghi chú thay thế biệt danh ở 13 vị trí, sắp xếp độc lập cho trả lời lồng nhau, lọc tìm kiếm bằng từ khóa cục bộ, nhảy qua liên kết rút gọn b23.tv, huy hiệu «chỉ dành cho người ủng hộ», công tắc ẩn lý do gợi ý, hiển thị kinh nghiệm xu.

**Cải thiện xem trực tiếp** — bảng đeo huy hiệu fan, truyền DLNA ưu tiên HLS, hiển thị thời gian SuperChat, thanh điều khiển dưới của cửa sổ nhỏ để tự cứu.

**Tích hợp hệ thống và máy tính để bàn** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), xử lý tiêu điểm âm thanh viết lại.

<details>
<summary>Danh sách tính năng gốc đầy đủ (nguyên văn từ PiliNara — bấm để mở)</summary>

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

## Tuyên bố miễn trách

PiliBabel là dự án cá nhân làm vì hứng thú, cung cấp **chỉ để học tập và thử nghiệm**; vui lòng xóa nó trong vòng **24 giờ** sau khi tải về.

- PiliBabel là ứng dụng **bên thứ ba không chính thức** và **không liên kết, không được xác nhận, không được tài trợ bởi bilibili**.
- Mọi API đều lấy từ các điểm truy cập công khai chính thức; **không cung cấp nội dung bẻ khóa, vượt quyền hay vượt tường trả phí**.
- **Dịch bằng AI chạy trên điểm truy cập mô hình của bên thứ ba.** Mặc định đó là dịch vụ Index-Translate công khai miễn phí của chính bilibili; nếu bạn chuyển sang API riêng thì đó là điểm truy cập bạn đã cấu hình. Chất lượng và tính tuân thủ của bản dịch thuộc trách nhiệm của người dùng và nhà cung cấp mô hình đã chọn; dự án này **không lưu trữ mô hình nào và không cung cấp khóa API nào**.
- Hãy tôn trọng bản quyền và điều khoản sử dụng của bilibili. Dùng một cách có trách nhiệm.

Tri ân các tác giả gốc và các dự án tiền nhiệm vì sự cống hiến cho mã nguồn mở:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — dự án cha trực tiếp của PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — họ mô hình dịch mã nguồn mở mà bộ máy tích hợp gọi tới

Nếu có nội dung nào xâm phạm quyền của bạn, hãy liên hệ để chúng tôi gỡ bỏ.

<br/>

## Giấy phép

PiliBabel được cấp phép theo **GNU General Public License v3.0 (GPL-3.0)** — cùng giấy phép với PiliNara, PiliPlus và PiliPala. Vì là tác phẩm phái sinh, **PiliBabel cũng phải được phân phối theo GPL-3.0**: bạn được tự do dùng, nghiên cứu, chia sẻ và sửa đổi, miễn là giữ nguyên giấy phép, các thông báo bản quyền và toàn văn giấy phép này. Xem [`LICENSE`](./LICENSE).

Các thành phần bên thứ ba (các gói Flutter, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), v.v.) vẫn theo giấy phép riêng của chúng.

<br/>

## Lời cảm ơn

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — họ mô hình dịch mã nguồn mở của bilibili, và là điểm truy cập công khai miễn phí đứng sau bộ máy tích hợp
- và nhiều dự án khác
- Lấy cảm hứng từ «dịch giao diện bằng AI» chính thức của bilibili.

<sub><a href="#readme-languages">↑ <a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a> · <a href="#readme-fr">Français</a> · <a href="#readme-de">Deutsch</a> · <a href="#readme-es">Español</a> · <a href="#readme-ko">한국어</a> · <a href="#readme-ar">العربية</a> · <a href="#readme-vi">Tiếng Việt</a> · <a href="#readme-ms">Bahasa Melayu</a> · <a href="#readme-id">Bahasa Indonesia</a></a></sub>

</details>

---

<details>
<summary><b>Bahasa Melayu</b></summary>

<a id="readme-ms"></a>

## Bahasa Melayu

<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Klien Bilibili pihak ketiga dengan terjemahan AI.</b></p>
    <p>Babel — meruntuhkan tembok bahasa, supaya setiap orang boleh menikmati bilibili dalam bahasanya sendiri.</p>
    <p>Merangkumi terjemahan 4 bahasa kaum minoriti etnik di China dan 3 dialek Cina.</p>
    <p>Terjemahan berfungsi sebaik sahaja dipasang, menggunakan model percuma bilibili — tanpa perlu kunci API.</p>
</div>

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Laman utama" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dinamik" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Saya" />
</div>

<br/>

> **Penafian.** PiliBabel ialah klien **tidak rasmi, sumber terbuka dan pihak ketiga**. Ia **tidak berkaitan dengan, tidak disahkan oleh, dan tidak ditaja oleh** bilibili / bilibili Inc. Semua API diambil daripada titik akhir awam rasmi; **tiada kandungan berbayar dibuka atau diceroboh**. Sila baca sepenuhnya bahagian [Penafian](#penafian) dan [Lesen](#lesen).

## Apakah PiliBabel?

PiliBabel ialah **cabang pihak ketiga yang bebas, dibina di atas [PiliNara](https://github.com/Starfallan/PiliNara)**, dan ia mewarisi segala yang diwarisi oleh PiliNara:

```
bilibili (API awam rasmi)
        ▲
   PiliPala / PiliPalaX        — projek asal
        ▲
   PiliPlus                    — cabang aktif
        ▲
   PiliNara                    — cabang PiliPlus (ubah suai peribadi)
        ▲
   PiliBabel  ← anda di sini    — cabang PiliNara
```

PiliBabel mengekalkan **semua ciri PiliNara / PiliPlus** (lihat [log ciri yang diwarisi](#log-ciri-yang-diwarisi-daripada-pilinara--piliplus) di bawah) dan menambah **satu keupayaan utama yang tiada pada klien huluan**:

> **Terjemahan antara muka dan kandungan dengan AI** — seluruh aplikasi (label antara muka, tajuk video, nama pencipta, komen, dinamik, suapan, malah danmaku siaran langsung) dipaparkan dalam bahasa **yang anda** pilih.

Dan sejak 1.0, ia berfungsi **sebaik sahaja dipasang**: model terjemahan **terbina dalam**. bilibili telah membuka sumber model terjemahannya sendiri, [Index-Translate](https://github.com/bilibili/Index-Translate), dan menyediakannya melalui titik akhir awam percuma. PiliBabel menghala ke sana secara lalai, jadi terjemahan berjalan sebaik anda memasang aplikasi — tanpa pendaftaran, tanpa kunci, tanpa bil. Jika anda lebih suka model sendiri, laluan «API sendiri» masih ada, hanya sejauh satu ketikan.

## Ciri utama

- **Terjemahan AI, di merata tempat.** Bar navigasi, kad video, halaman butiran, komen, dinamik, serta skrin Saya / Kegemaran / Sejarah / Mesej / Carian — satu sapuan global meliputi **kira-kira 1650 rentetan antara muka**, ditambah kandungan dinamik (tajuk, nama penulis, pengira).
- **Dua enjin, satu suis.** *Terbina dalam* (lalai) menggunakan titik akhir percuma model rasmi **Index-Translate-35B-A3B** bilibili — tiada apa perlu dikonfigurasi. *API sendiri* mengekalkan tingkah laku sebelum ini: halakan ke mana-mana titik akhir `/chat/completions` serasi OpenAI, dengan URL asas / kunci / model anda sendiri. Ringkasan video AI dan terjemahan AI masih mempunyai titik akhir serta tetapan yang **sepenuhnya bebas**, kedua-duanya di bawah satu halaman **«Ciri AI»**.
- **Satu senarai bahasa, dikongsi kedua-dua enjin.** Senarai bahasa sasaran tidak dipecahkan mengikut enjin: senarai yang sama digunakan walau enjin mana anda pilih. Ia menyatukan **150 bahasa** model rasmi bilibili dengan **4 bahasa kaum minoriti etnik di China dan 3 dialek Cina** yang ditambah PiliBabel — Tibet, Uyghur, Zhuang dan Hmong di satu pihak; Kantonis, Wu (Shanghai) dan Minnan di pihak yang lain — serta Cina Tradisional. Variasi serantau dan sistem tulisan kekal sebagai **entri berasingan** dan tidak digabungkan: Arab Maghribi / Mesir / Najdi / Levant masing-masing pilihan tersendiri, begitu juga Serbia, Uzbek dan Urdu dalam tulisan Cyrillic atau Latin.
- **Jujur tentang liputan.** Bahasa dalam senarai rasmi diliputi oleh model bilibili. Sebilangan kecil di luarnya — Cina Tradisional, serta dialek Cina dan bahasa minoriti di atas yang tidak disenaraikan bilibili — tetap muncul dalam senarai, ditanda sedemikian, supaya anda tahu sepintas lalu bahawa hasil yang lebih baik mungkin memerlukan model sendiri.
- **Diterjemah sekali, kemudian kekal.** Setiap rentetan sumber diterjemah **tepat sekali**; hasilnya disimpan secara setempat dan **tidak pernah diterjemah semula** apabila anda membuka semula skrin — prinsip yang sama seperti klien rasmi, untuk terjemahan yang stabil dan boleh dijangkakan.
- **Suis «Asal ⇄ Terjemahan» bagi setiap komen** (ikon kecil, bukan perkataan). `@sebutan / [emoji] / #topik# / pautan` dikekalkan sebagai token, dan **komen yang mengandungi hiperpautan tetap diterjemah sambil pautan kekal boleh diklik**.
- **Terjemahan danmaku** — suis berasingan pada bar kawalan kanan atas pemain, **mati secara lalai** dan didahului pengesahan yang teksnya sendiri juga diterjemah. Setelah dihidupkan, danmaku di hadapan kedudukan main akan diterjemah awal dalam **kelompok sekitar 15 saat** (melompat ke tengah dikendalikan dengan betul, bukan dari awal), jadi terjemahan biasanya sedia apabila ia melintas.
- **Suis mod penaakulan** (`enable_thinking`) untuk memilih antara kualiti dan kelajuan, serta butang **«uji terjemahan»** dan **kosongkan cache** dalam tetapan.
- **Tukar bahasa pantas**: permintaan berkumpulan dengan keserentakan terhad di atas cache kekal; menukar bahasa akan membina semula skrin semasa sekali, supaya anda tidak terus memandang teks yang belum diterjemah. Mematikan terjemahan AI akan mengembalikan seluruh antara muka kepada teks asal dan **tidak menghantar sebarang permintaan**.
- **Panduan pada pelancaran pertama.** Kali pertama anda membuka aplikasi, dialog bahasa Inggeris menawarkan untuk menghidupkan terjemahan. Jika bersetuju, ia menghidupkan terjemahan, memilih model terbina dalam, membuka halaman tetapan AI dan terus bertanya bahasa mana yang anda mahu — pengguna baharu bergerak daripada «baru dipasang» ke «sudah diterjemah» dengan dua ketikan.
- **Main balik yang berfungsi di seluruh dunia.** PiliBabel memilih nod luar negara (global **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) yang sudah ditawarkan oleh `playurl` berpenghalaan geo bilibili, bukannya memaku anda pada nod tanah besar China (Alibaba Cloud / Shenzhen) — jadi pengguna di luar tanah besar China tidak lagi mengalami «bunyi berjalan, gambar beku». Anda masih boleh menetapkan CDN secara manual dalam tetapan.

## Dua enjin terjemahan

| | Terbina dalam (lalai) | API sendiri |
|---|---|---|
| Model | bilibili **Index-Translate-35B-A3B** | apa-apa yang serasi OpenAI |
| Titik akhir | `index-translate.bilibili.com/v1` | URL asas anda |
| Kunci API | **tidak perlu** | milik anda |
| Kos | percuma | bergantung penyedia anda |
| Cara permintaan | satu rentetan setiap permintaan | berkumpulan (≤ 16 setiap permintaan) |
| Bahasa tambahan | — | apa-apa bahasa yang model anda tahu |

**Mengapa satu rentetan setiap permintaan pada enjin terbina dalam.** Index-Translate ialah model **pakar** terjemahan, dan cara panggilan yang didokumenkan penulisnya ialah templat satu item («terjemah teks berikut ke X, keluarkan terjemahan sahaja»). Jadi pada enjin ini PiliBabel menghantar satu rentetan setiap permintaan, bukan gesaan berkumpulan «senarai bernombor / tatasusunan JSON» yang digunakan untuk API sendiri. Titik akhirnya percuma, jadi tiada apa yang diperoleh dengan mempertaruhkan keluaran berkumpulan — ini pertukaran yang disengajakan: beberapa permintaan tambahan ditukar dengan jauh lebih sedikit cara untuk gagal.

**Naik taraf daripada 0.3.x.** Tetapan API sendiri anda — URL asas, kunci dan model — **dibiarkan tepat seperti yang anda tetapkan**. Pemilihan enjin hanya lalai kepada model terbina dalam, jadi pada pelancaran pertama selepas naik taraf anda akan berada pada model percuma bilibili; buka *Tetapan → AI → Ciri AI → enjin terjemahan* dan tukar kembali kepada *API sendiri* untuk kembali serta-merta kepada tetapan anda.

## Bagaimana terjemahan antara muka berfungsi (teknikal)

Repositori ini **tiada lapisan sumber i18n / ARB sama sekali** — rentetan antara muka dikodkan keras dalam bahasa Cina. Daripada menulis semula setiap widget, PiliBabel menambah lapisan terjemahan nipis di atasnya:

1. **Pembalut pencarian global.** `lib/services/ui_translate/` menyediakan fungsi peringkat atas `uiTx(String src)`. Tempat yang dahulunya `Text('中文')` kini menjadi `Text(uiTx('中文'))`. Satu **codemod berskrip** telah menerapkannya ke seluruh projek (`tool/ui_translate_*.py`) — kira-kira **223 fail / 1650 rentetan** — sambil membuang kata kunci `const` yang kini tidak sah di tempat yang perlu (termasuk generik seperti `const X<T>(...)` dan nama bertitik seperti `const Positioned.fill(...)`), dan menukar pengisytiharan `static const` bagi senarai / peta menjadi `static final`.
2. **Teras `GetxService`** (`ui_translate_service.dart`):
   - cache kekal **asal → terjemahan** (disokong GetStorage), jadi setiap rentetan diterjemah sekali dan digunakan semula selama-lamanya;
   - `tx()` membaca `RxInt revision` dahulu, kemudian memutuskan: jika dimatikan → pulangkan asal; jika sasaran ialah **Cina Ringkas (`zh-CN`)** → pulangkan asal tanpa permintaan API (kandungan bilibili sebahagian besarnya Cina Ringkas). Mana-mana sasaran lain — termasuk Cina Tradisional, Kantonis, Wu dan Minnan — melalui enjin yang dikonfigurasi; **keahlian dalam keluarga Cina sahaja tidak cukup untuk melangkau terjemahan**. Kemudian: hidangkan daripada cache atau **masukkan ke baris gilir**;
   - rentetan dalam baris gilir diproses oleh **kolam pekerja** dengan **penggunaan tambahan mengikut blok** (setiap blok yang kembali menaikkan `revision`, jadi teks dikemas kini secara beransur), dan hasilnya **disimpan kekal** (dengan pengehadan kadar). Saiz kelompok dan keserentakan mengikut enjin: **1 setiap permintaan** pada model terbina dalam, **≤ 16 dengan ≤ 10 serentak** pada API sendiri.
3. **Penentuan enjin.** `TranslateProvider` (`builtin` / `custom`) menentukan URL, kunci dan model yang digunakan lapisan pengangkutan; selain itu, kedua-dua enjin berkongsi satu laluan kod dan satu senarai bahasa — jadi menukar enjin hanyalah satu tetapan dan **tidak pernah menjadi set ciri yang berbeza**.
4. **Lapisan pengangkutan** menggunakan semula saluran **penstriman** yang sama dan telah disahkan seperti ringkasan video AI — `AiChatService.streamChat` → `{base}/chat/completions` dengan `stream: true` (serasi dengan gerbang yang hanya menyokong penstriman) — diperluas supaya terjemahan boleh menggunakan `apiUrl` / `apiKey` / `model` **sendiri** dan bendera `enable_thinking`. Perubahan ini **serasi ke belakang**, jadi ringkasan video terus berfungsi.
5. **Ayat dengan pemegang tempat** melalui `uiTxP(template, args)`: ayat penuh dengan `{0}`/`{1}` diterjemah sebagai satu kunci stabil (gesaan meminta model mengekalkan pemegang tempat), kemudian nilainya diisikan semula — jadi rentetan seperti `"共 {0} 条"` diterjemah tanpa merosakkan bahagian dinamik.
6. **Jadual bahasa** (`app_language.dart`): setiap `AppLanguage` membawa nama kendiri untuk paparan, rentetan gesaan `toModel` yang mengekod konvensyen tulisan dan wilayah, serta penanda sama ada senarai rasmi bilibili meliputinya. Peraturan tulisan (ringkas / tradisional) dan arahan ketekalan dialek sampai kepada model **hanya melalui gesaan**, dan selepas itu satu pusingan penormalan tulisan yang deterministik di pihak klien membetulkan aksara yang tersasar.
7. **Komen** melalui `uiTxComment(text, id)`, mengekalkan `@ / [emoji] / #topik# / pautan` sebagai token yang utuh; segmen teks kaya yang membawa pautan tetap diterjemah sambil pengecaman pautan dipelihara, dan set id bagi setiap komen memandu suis «Asal ⇄ Terjemahan».
8. **Danmaku** (`danmaku/view.dart`): apabila suisnya hidup, pendengar kedudukan menelusuri `[kedudukan main, kedudukan main + 15 saat]` satu saat demi satu saat dan memanaskan `uiTx()` pada kandungan setiap danmaku, jadi item sudah diterjemah sebelum sampai ke skrin; menghidupkannya mengosongkan dan melukis semula kanvas.
9. **Kunci storan**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Antara muka tetapan**: satu halaman peringkat pertama «Ciri AI» (`lib/pages/setting/ui_translate/`) dengan blok bebas untuk ringkasan video AI dan terjemahan antara muka.

**CDN global (`VideoUtils.getCdnUrl`).** URL strim ditandatangani, dan menulis semula hos sesuatu URL akan ditolak dengan 403 — jadi main balik **tidak pernah menulis semula hos**. PiliBabel memulangkan URL berpenghalaan geo yang bilibili berikan kepada IP klien, dan apabila senarai calon sudah mengandungi nod luar negara (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`) yang itu diutamakan. Muat turun, di mana menukar hos adalah selamat, turut mengutamakan nod global Akamai dan berpindah kepada calon bertandatangan seterusnya apabila satu talian tersekat atau menolak sambungan semula. Pautan P2P mentah `/v/resource` masih berpatah balik kepada penyampai sedia ada untuk mengelakkan 404.

**Tolak ansur reka bentuk / had yang diketahui.** Kerana rentetan dibalut di tempatnya dan bukan diekstrak menjadi sumber, beberapa parameter rentetan bukan `Text` dan sebahagian segmen teks kaya masih diisi secara beransur-ansur. Rentetan yang turut berfungsi sebagai **kunci logik** (dibandingkan dengan `==`, digunakan sebagai nama tab seperti `简介`, atau label enum dalam suis) **sengaja tidak** dibalut secara menyeluruh, supaya tingkah laku tidak terjejas. Terjemahan danmaku ialah usaha terbaik di atas kanvas yang bergerak — dengan danmaku yang sangat padat anda mungkin melihat teks asal seketika sebelum terjemahan tiba. Terjemahan memerlukan rangkaian; tanpanya, sasaran bukan Cina langsung tidak berkesan. Titik akhir terbina dalam ialah perkhidmatan awam percuma yang dikendalikan bilibili — jika ia pernah dihadkan kadar atau tidak tersedia, aplikasi akan memberitahu anda dan anda boleh bertukar kepada API sendiri.

## Bina dan sahkan

Aplikasi dibina dengan Flutter SDK yang ditampal serta pakej `material_ui` / `cupertino_ui` yang ditampal, melalui `lib/scripts/patch.ps1` dan `lib/scripts/build.ps1` (sama seperti PiliNara / PiliPlus). GitHub Actions menghasilkan **APK nyahpepijat** pada setiap tolakan (`.github/workflows/ui-translate-debug.yml`), dan **menerbitkan tag `v*` akan membina dan menerbitkan artifak Android, Windows dan Linux secara automatik** (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Platform
- [x] Android
- [ ] iOS
- [ ] Tablet
- [x] Windows
- [x] Linux

PiliBabel menyediakan binaan **Android (APK), Windows dan Linux** dalam Releases; iOS dan tablet belum dipakejkan dalam cabang ini.

<br/>

## Muat turun

Dapatkan binaan daripada **Releases**, atau klon repositori dan binanya sendiri.

### Arch Linux

Terima kasih kepada [@nlsdt](https://github.com/nlsdt) kerana memakejkan (resipi PiliNara juga terpakai untuk PiliBabel).

```bash
sudo pacman -S pilinara      # melalui repositori Arch Linux CN
paru -S pilinara-bin         # atau melalui AUR: pilinara-bin (siap bina) / pilinara (sumber)
```

<br/>

## Log ciri yang diwarisi (daripada PiliNara / PiliPlus)

Semua di bawah diwarisi daripada PiliNara (dan, secara tidak langsung, PiliPlus); PiliBabel menambah lapisan terjemahan AI di atasnya.

**Antara muka dan penyesuaian platform**
- [x] Aplikasi dinamakan semula mengikut platform supaya beberapa klien boleh wujud bersama (PiliBabel dipasang bersebelahan PiliNara)
- [x] Pembetulan pemaparan Flutter dalam tetingkap mini Xiaomi HyperOS ([#161086](https://github.com/flutter/flutter/issues/161086), melalui [venera#467](https://github.com/venera-app/venera/pull/467)); animasi kembali ramalan pada Android
- [x] Susunan dan bilangan kad «Saya» boleh disesuaikan; pratonton kad sejarah dan bahagian «tonton kemudian»
- [x] Penukaran bar sisi automatik dengan lebar pencetus boleh laras; salin imej dengan tekan lama / klik kanan; pembaharuan gaya MD3E yang besar

**Sistem fon** — kolam import bersatu dengan penyahduaan melalui cincang kandungan, fon danmaku digabungkan ke dalam kolam yang sama, `loadFontFromList` dengan sokongan ttc, dan nama keluarga fon ASCII tulen.

**Main balik, tetingkap mini dan kualiti** — tetingkap mini dalam aplikasi (seret, ubah saiz, langkau SponsorBlock, PIP sistem automatik, bar penyelamat diri untuk siaran langsung), main balik audio serentak, kelantangan dalam aplikasi sehingga 200 %, domain CDN video tersuai dan pemilihan nod serantau dengan ujian kependaman, kualiti lalai berasingan untuk separuh skrin dan skrin penuh, kunci kelajuan dengan leret ke atas, kawalan papan kekunci pada tablet, cap masa SuperChat siaran langsung, denyutan kemesraan peminat siaran langsung.

**Sari kata, AI dan luar talian** — sari kata dwibahasa dengan gaya sari kata kedua yang bebas, analisis sari kata AI (titik akhir serasi OpenAI tersuai, lompat ke cap masa, templat, perbualan disimpan kekal, sandaran lembut apabila tiada sari kata), eksport WEBVTT/SRT, paparan dwi cache luar talian dengan pengurusan folder dan penyimpanan metadata, eksport muat turun ke folder Download awam (Android).

**Danmaku dan penyekatan** — penambahbaikan skala danmaku gabungan (gaya [Pakku.js](https://github.com/xmcp/pakku.js)), penyekatan ungkapan nalar visual berbentuk senarai dengan import dan eksport, langkau ke dalam segmen SponsorBlock, bar kemajuan tenaga tinggi dengan kernel Gaussian.

**Penapisan saranan / dinamik / komen** — kata kunci tajuk / pencipta / saluran, tempoh, bilangan tontonan, kadar suka, pengecualian pencipta yang diikuti, penapisan kandungan tidak dibenarkan / khas penyokong, senarai putih dikongsi, dinamik komersial / tidak dibenarkan, pengecualian komen pencipta sendiri dan komen disemat, mod suapan gabungan App + Web.

**Dinamik, carian dan maklumat pengguna** — nota tersuai untuk pencipta, nota menggantikan nama panggilan pada 13 kedudukan, susunan bebas untuk balasan bersarang, penapis carian kata kunci setempat, lompatan pautan pendek b23.tv, lencana khas penyokong, suis sembunyikan sebab saranan, paparan pengalaman syiling.

**Penambahbaikan siaran langsung** — panel pemakaian medal peminat, penghantaran DLNA mengutamakan HLS, paparan masa SuperChat, bar kawalan bawah tetingkap mini untuk penyelamatan diri.

**Integrasi sistem dan desktop** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), pengendalian fokus audio yang ditulis semula.

<details>
<summary>Senarai ciri asal yang lengkap (sebagaimana adanya, daripada PiliNara — klik untuk buka)</summary>

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

## Penafian

PiliBabel ialah projek peribadi atas dasar minat, disediakan **untuk pembelajaran dan ujian sahaja**; sila hapuskannya dalam masa **24 jam** selepas dimuat turun.

- PiliBabel ialah klien **pihak ketiga tidak rasmi** dan **tidak berkaitan dengan, tidak disahkan oleh, dan tidak ditaja oleh bilibili**.
- Semua API diambil daripada titik akhir awam rasmi; **tiada kandungan yang diceroboh, melebihi keistimewaan atau memintas dinding bayaran** disediakan.
- **Terjemahan AI berjalan pada titik akhir model pihak ketiga.** Secara lalai ia ialah perkhidmatan Index-Translate awam percuma bilibili sendiri; jika anda bertukar kepada API sendiri, ia ialah titik akhir yang anda tetapkan. Kualiti dan pematuhan terjemahan menjadi tanggungjawab pengguna dan penyedia model yang dipilih; projek ini **tidak mengehos sebarang model dan tidak menyediakan sebarang kunci API**.
- Hormati hak cipta dan terma perkhidmatan bilibili. Gunakan dengan bertanggungjawab.

Dengan penghormatan kepada penulis asal dan huluan atas dedikasi sumber terbuka mereka:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — projek induk langsung PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — keluarga model terjemahan sumber terbuka yang dipanggil enjin terbina dalam

Jika mana-mana kandungan melanggar hak anda, hubungi kami untuk penyingkiran.

<br/>

## Lesen

PiliBabel dilesenkan di bawah **GNU General Public License v3.0 (GPL-3.0)** — lesen yang sama seperti PiliNara, PiliPlus dan PiliPala. Kerana ia karya terbitan, **PiliBabel juga mesti diedarkan di bawah GPL-3.0**: anda bebas menggunakannya, mengkajinya, berkongsinya dan mengubah suainya, dengan syarat anda mengekalkan lesen yang sama, notis hak cipta dan teks lesen ini. Lihat [`LICENSE`](./LICENSE).

Komponen pihak ketiga (pakej Flutter, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), dan lain-lain) kekal di bawah lesen masing-masing.

<br/>

## Penghargaan

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — keluarga model terjemahan sumber terbuka bilibili, dan titik akhir awam percuma di sebalik enjin terbina dalam
- dan banyak lagi
- Diilhamkan oleh «terjemahan antara muka AI» rasmi bilibili.

<sub><a href="#readme-languages">↑ <a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a> · <a href="#readme-fr">Français</a> · <a href="#readme-de">Deutsch</a> · <a href="#readme-es">Español</a> · <a href="#readme-ko">한국어</a> · <a href="#readme-ar">العربية</a> · <a href="#readme-vi">Tiếng Việt</a> · <a href="#readme-ms">Bahasa Melayu</a> · <a href="#readme-id">Bahasa Indonesia</a></a></sub>

</details>

---

<details>
<summary><b>Bahasa Indonesia</b></summary>

<a id="readme-id"></a>

## Bahasa Indonesia

<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Klien Bilibili pihak ketiga dengan terjemahan AI.</b></p>
    <p>Babel — meruntuhkan dinding bahasa, agar setiap orang dapat menikmati bilibili dalam bahasanya sendiri.</p>
    <p>Mencakup terjemahan 4 bahasa minoritas etnis di Tiongkok dan 3 dialek Tionghoa.</p>
    <p>Terjemahan langsung berfungsi begitu dipasang, memakai model gratis bilibili — tanpa perlu kunci API.</p>
</div>

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Beranda" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dinamika" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Saya" />
</div>

<br/>

> **Penafian.** PiliBabel adalah klien **tidak resmi, sumber terbuka, dan pihak ketiga**. Ia **tidak berafiliasi dengan, tidak disahkan oleh, maupun disponsori oleh** bilibili / bilibili Inc. Semua API diambil dari titik akhir publik resmi; **tidak ada konten berbayar yang dibuka atau dibajak**. Harap baca bagian [Penafian](#penafian) dan [Lisensi](#lisensi) selengkapnya.

## Apa itu PiliBabel?

PiliBabel adalah **fork pihak ketiga yang independen, dibangun di atas [PiliNara](https://github.com/Starfallan/PiliNara)**, dan mewarisi segala hal yang diwarisi PiliNara:

```
bilibili (API publik resmi)
        ▲
   PiliPala / PiliPalaX        — proyek awal
        ▲
   PiliPlus                    — fork aktif
        ▲
   PiliNara                    — fork PiliPlus (penyesuaian pribadi)
        ▲
   PiliBabel  ← Anda di sini    — fork PiliNara
```

PiliBabel mempertahankan **seluruh fitur PiliNara / PiliPlus** (lihat [daftar fitur warisan](#daftar-fitur-warisan-dari-pilinara--piliplus) di bawah) dan menambahkan **satu kemampuan utama yang tidak dimiliki klien hulu**:

> **Terjemahan antarmuka dan konten dengan AI** — seluruh aplikasi (label antarmuka, judul video, nama kreator, komentar, dinamika, feed, bahkan danmaku siaran langsung) ditampilkan dalam bahasa **yang Anda** pilih.

Dan sejak 1.0, hal itu **langsung bekerja begitu dipasang**: model terjemahannya **sudah terpasang di dalam**. bilibili membuka sumber model terjemahannya sendiri, [Index-Translate](https://github.com/bilibili/Index-Translate), dan menyediakannya lewat titik akhir publik gratis. PiliBabel secara bawaan menunjuk ke sana, jadi terjemahan berjalan begitu Anda memasang aplikasi — tanpa pendaftaran, tanpa kunci, tanpa tagihan. Kalau Anda lebih suka model sendiri, jalur «API sendiri» tetap ada, hanya sejauh satu ketukan.

## Fitur utama

- **Terjemahan AI di mana-mana.** Bilah navigasi, kartu video, halaman detail, komentar, dinamika, serta layar Saya / Favorit / Riwayat / Pesan / Pencarian — satu sapuan global mencakup **sekitar 1650 teks antarmuka**, ditambah konten dinamis (judul, nama penulis, penghitung).
- **Dua mesin, satu sakelar.** *Bawaan* (default) memakai titik akhir gratis model resmi **Index-Translate-35B-A3B** milik bilibili — tidak ada yang perlu dikonfigurasi. *API sendiri* mempertahankan perilaku sebelumnya: arahkan ke titik akhir `/chat/completions` yang kompatibel dengan OpenAI, dengan URL dasar / kunci / model Anda sendiri. Ringkasan video AI dan terjemahan AI tetap memiliki titik akhir dan pengaturan yang **sepenuhnya independen**, keduanya berada dalam satu halaman **«Fitur AI»**.
- **Satu daftar bahasa, dipakai kedua mesin.** Daftar bahasa tujuan tidak dipisah per mesin: daftarnya sama, mesin mana pun yang Anda pilih. Daftar itu menyatukan **150 bahasa** model resmi bilibili dengan **4 bahasa minoritas etnis di Tiongkok dan 3 dialek Tionghoa** yang ditambahkan PiliBabel — Tibet, Uighur, Zhuang, dan Hmong di satu sisi; Kanton, Wu (Shanghai), dan Minnan di sisi lain — plus Tionghoa Tradisional. Varian regional dan sistem tulisan tetap menjadi **entri tersendiri** alih-alih digabung: Arab Maroko / Mesir / Najdi / Levant masing-masing pilihan sendiri, begitu pula Serbia, Uzbek, dan Urdu dalam tulisan Kiril atau Latin.
- **Jujur soal cakupan.** Bahasa di dalam daftar resmi ditangani model bilibili. Beberapa yang di luarnya — Tionghoa Tradisional, serta dialek Tionghoa dan bahasa minoritas di atas yang tidak dicantumkan bilibili — tetap muncul di daftar, ditandai demikian, supaya Anda tahu sekilas bahwa hasil yang lebih baik mungkin memerlukan model sendiri.
- **Diterjemahkan sekali, lalu tetap.** Setiap teks sumber diterjemahkan **tepat satu kali**; hasilnya disimpan secara lokal dan **tidak pernah diterjemahkan ulang** saat Anda membuka layar itu lagi — prinsip yang sama dengan klien resmi, demi terjemahan yang stabil dan bisa diprediksi.
- **Sakelar «Asli ⇄ Terjemahan» per komentar** (ikon kecil, bukan kata). `@sebutan / [emoji] / #topik# / tautan` dipertahankan sebagai token, dan **komentar yang memuat tautan tetap diterjemahkan sementara tautannya tetap bisa diklik**.
- **Terjemahan danmaku** — sakelar terpisah di baris kontrol kanan atas pemutar, **mati secara bawaan** dan didahului konfirmasi yang teksnya sendiri juga diterjemahkan. Setelah dinyalakan, danmaku di depan posisi putar diterjemahkan lebih dulu dalam **kelompok sekitar 15 detik** (melompat ke tengah ditangani dengan benar, bukan dari awal), jadi terjemahannya biasanya sudah siap saat melintas.
- **Sakelar mode penalaran** (`enable_thinking`) untuk memilih antara kualitas dan kecepatan, plus tombol **«uji terjemahan»** dan **kosongkan cache** di pengaturan.
- **Ganti bahasa yang cepat**: permintaan berkelompok dengan konkurensi terbatas di atas cache permanen; mengganti bahasa membangun ulang layar saat ini sekali, supaya Anda tidak terus menatap teks yang belum diterjemahkan. Mematikan terjemahan AI mengembalikan seluruh antarmuka ke teks asli dan **tidak mengirim permintaan sama sekali**.
- **Panduan saat pertama dibuka.** Saat pertama kali membuka aplikasi, dialog berbahasa Inggris menawarkan untuk menyalakan terjemahan. Jika setuju, ia menyalakan terjemahan, memilih model bawaan, membuka halaman pengaturan AI, dan langsung menanyakan bahasa yang Anda inginkan — pengguna baru berpindah dari «baru dipasang» ke «sudah diterjemahkan» hanya dengan dua ketukan.
- **Pemutaran yang bekerja di seluruh dunia.** PiliBabel memilih simpul luar negeri (global **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) yang memang sudah ditawarkan `playurl` berperutean geo milik bilibili, alih-alih memaku Anda ke simpul daratan Tiongkok (Alibaba Cloud / Shenzhen) — sehingga pengguna di luar daratan Tiongkok tidak lagi mengalami «suara jalan, gambar membeku». Anda tetap bisa menetapkan CDN secara manual di pengaturan.

## Dua mesin terjemahan

| | Bawaan (default) | API sendiri |
|---|---|---|
| Model | bilibili **Index-Translate-35B-A3B** | apa pun yang kompatibel dengan OpenAI |
| Titik akhir | `index-translate.bilibili.com/v1` | URL dasar Anda |
| Kunci API | **tidak perlu** | milik Anda |
| Biaya | gratis | tergantung penyedia Anda |
| Cara permintaan | satu teks per permintaan | berkelompok (≤ 16 per permintaan) |
| Bahasa tambahan | — | bahasa apa pun yang diketahui model Anda |

**Mengapa satu teks per permintaan pada mesin bawaan.** Index-Translate adalah model **spesialis** terjemahan, dan cara pemanggilan yang didokumentasikan penulisnya adalah templat satu item («terjemahkan teks berikut ke X, keluarkan hanya terjemahannya»). Karena itu pada mesin ini PiliBabel mengirim satu teks per permintaan, bukan perintah berkelompok «daftar bernomor / larik JSON» yang dipakai untuk API sendiri. Titik akhirnya gratis, jadi tidak ada yang bisa didapat dari mempertaruhkan keluaran berkelompok — ini pertukaran yang disengaja: beberapa permintaan lebih banyak ditukar dengan jauh lebih sedikit cara untuk gagal.

**Peningkatan dari 0.3.x.** Pengaturan API sendiri Anda — URL dasar, kunci, dan model — **dibiarkan persis seperti yang Anda tetapkan**. Pemilihan mesin hanya beralih ke model bawaan, jadi pada pembukaan pertama setelah peningkatan Anda akan memakai model gratis bilibili; buka *Pengaturan → AI → Fitur AI → mesin terjemahan* dan kembali ke *API sendiri* untuk langsung kembali ke konfigurasi Anda.

## Bagaimana terjemahan antarmuka bekerja (teknis)

Repositori ini **tidak punya lapisan sumber daya i18n / ARB sama sekali** — teks antarmuka ditulis keras dalam bahasa Tionghoa. Alih-alih menulis ulang setiap widget, PiliBabel menambahkan lapisan terjemahan tipis di atasnya:

1. **Pembungkus pencarian global.** `lib/services/ui_translate/` menyediakan fungsi tingkat atas `uiTx(String src)`. Tempat yang dulu `Text('中文')` kini menjadi `Text(uiTx('中文'))`. Sebuah **codemod berskrip** menerapkannya ke seluruh proyek (`tool/ui_translate_*.py`) — sekitar **223 berkas / 1650 teks** — sekaligus membuang kata kunci `const` yang jadi tidak sah di tempat yang diperlukan (termasuk generik seperti `const X<T>(...)` dan nama bertitik seperti `const Positioned.fill(...)`), dan mengubah deklarasi `static const` untuk daftar / peta menjadi `static final`.
2. **Inti `GetxService`** (`ui_translate_service.dart`):
   - cache permanen **asal → terjemahan** (berbasis GetStorage), jadi setiap teks diterjemahkan sekali dan dipakai ulang selamanya;
   - `tx()` membaca `RxInt revision` lebih dulu, lalu memutuskan: jika dimatikan → kembalikan aslinya; jika tujuan adalah **Tionghoa Sederhana (`zh-CN`)** → kembalikan aslinya tanpa permintaan API (konten bilibili mayoritas besar Sederhana). Tujuan lain mana pun — termasuk Tionghoa Tradisional, Kanton, Wu, dan Minnan — melewati mesin yang dikonfigurasi; **sekadar termasuk rumpun Tionghoa tidak cukup untuk melewati terjemahan**. Setelah itu: sajikan dari cache atau **masukkan ke antrean**;
   - teks dalam antrean diproses oleh **kumpulan worker** dengan **penerapan bertahap per blok** (setiap blok yang kembali menaikkan `revision`, jadi teks diperbarui bertahap), dan hasilnya **disimpan permanen** (dengan pembatasan laju). Ukuran kelompok dan konkurensi mengikuti mesin: **1 per permintaan** pada model bawaan, **≤ 16 dengan ≤ 10 berjalan** pada API sendiri.
3. **Penentuan mesin.** `TranslateProvider` (`builtin` / `custom`) menentukan URL, kunci, dan model yang dipakai lapisan transportasi; selain itu kedua mesin berbagi satu jalur kode dan satu daftar bahasa — jadi mengganti mesin hanyalah satu pengaturan dan **tidak pernah menjadi kumpulan fitur yang berbeda**.
4. **Lapisan transportasi** memakai ulang kanal **streaming** yang sama dan sudah terbukti seperti ringkasan video AI — `AiChatService.streamChat` → `{base}/chat/completions` dengan `stream: true` (kompatibel dengan gateway yang hanya mendukung streaming) — diperluas agar terjemahan bisa memakai `apiUrl` / `apiKey` / `model` **sendiri** dan flag `enable_thinking`. Perubahan ini **kompatibel ke belakang**, jadi ringkasan video tetap berjalan.
5. **Kalimat dengan penanda** melewati `uiTxP(template, args)`: kalimat utuh berisi `{0}`/`{1}` diterjemahkan sebagai satu kunci stabil (perintah meminta model mempertahankan penandanya), lalu nilainya dimasukkan kembali — jadi teks seperti `"共 {0} 条"` diterjemahkan tanpa merusak bagian dinamisnya.
6. **Tabel bahasa** (`app_language.dart`): setiap `AppLanguage` membawa nama mandiri untuk ditampilkan, teks perintah `toModel` yang menyandikan konvensi tulisan dan wilayah, serta penanda apakah daftar resmi bilibili mencakupnya. Aturan tulisan (Sederhana / Tradisional) dan arahan konsistensi dialek sampai ke model **hanya lewat perintah**, lalu satu putaran penormalan tulisan yang deterministik di sisi klien membetulkan aksara yang menyimpang.
7. **Komentar** melewati `uiTxComment(text, id)`, menjaga `@ / [emoji] / #topik# / tautan` tetap utuh sebagai token; potongan teks kaya yang memuat tautan tetap diterjemahkan sementara pengenalan tautan dipertahankan, dan kumpulan id per komentar mengendalikan sakelar «Asli ⇄ Terjemahan».
8. **Danmaku** (`danmaku/view.dart`): saat sakelarnya menyala, pendengar posisi menyusuri `[posisi putar, posisi putar + 15 detik]` detik demi detik dan memanaskan `uiTx()` pada konten tiap danmaku, jadi itemnya sudah diterjemahkan sebelum sampai ke layar; menyalakannya mengosongkan dan menggambar ulang kanvas.
9. **Kunci penyimpanan**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Antarmuka pengaturan**: satu halaman tingkat pertama «Fitur AI» (`lib/pages/setting/ui_translate/`) dengan blok terpisah untuk ringkasan video AI dan terjemahan antarmuka.

**CDN global (`VideoUtils.getCdnUrl`).** URL stream ditandatangani, dan menulis ulang hos sebuah URL akan ditolak dengan 403 — jadi pemutaran **tidak pernah menulis ulang hos**. PiliBabel mengembalikan URL berperutean geo yang bilibili berikan ke IP klien, dan bila daftar kandidat sudah memuat simpul luar negeri (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`) maka itu yang diutamakan. Untuk unduhan, di mana menukar hos aman, sistem juga mengutamakan simpul global Akamai dan berpindah ke kandidat bertanda tangan berikutnya saat satu jalur macet atau menolak lanjutan. Tautan P2P mentah `/v/resource` tetap mundur ke perantara yang ada agar terhindar dari 404.

**Kompromi desain / batasan yang diketahui.** Karena teks dibungkus di tempatnya alih-alih diekstrak menjadi sumber daya, beberapa parameter teks non-`Text` dan sebagian potongan teks kaya masih dilengkapi bertahap. Teks yang sekaligus menjadi **kunci logika** (dibandingkan dengan `==`, dipakai sebagai nama tab seperti `简介`, atau label enum di sakelar) **sengaja tidak** dibungkus menyeluruh, agar perilakunya tidak rusak. Terjemahan danmaku adalah upaya terbaik di kanvas yang bergerak — pada danmaku yang sangat padat Anda mungkin sempat melihat teks aslinya sebelum terjemahan tiba. Terjemahan memerlukan jaringan; tanpanya, tujuan selain Tionghoa tidak akan berlaku. Titik akhir bawaan adalah layanan publik gratis yang dijalankan bilibili — jika suatu saat dibatasi lajunya atau tidak tersedia, aplikasi akan memberitahukan Anda dan Anda bisa beralih ke API sendiri.

## Membangun dan memverifikasi

Aplikasi dibangun dengan Flutter SDK yang ditambal serta paket `material_ui` / `cupertino_ui` yang ditambal, melalui `lib/scripts/patch.ps1` dan `lib/scripts/build.ps1` (persis seperti PiliNara / PiliPlus). GitHub Actions menghasilkan **APK debug** pada setiap push (`.github/workflows/ui-translate-debug.yml`), dan **menerbitkan tag `v*` akan otomatis membangun dan merilis artefak Android, Windows, dan Linux** (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Platform
- [x] Android
- [ ] iOS
- [ ] Tablet
- [x] Windows
- [x] Linux

PiliBabel menyediakan build **Android (APK), Windows, dan Linux** di Releases; iOS dan tablet belum dikemas dalam fork ini.

<br/>

## Unduhan

Ambil build dari **Releases**, atau klon repositori dan bangun sendiri.

### Arch Linux

Terima kasih kepada [@nlsdt](https://github.com/nlsdt) atas pengemasannya (resep PiliNara juga berlaku untuk PiliBabel).

```bash
sudo pacman -S pilinara      # dari repositori Arch Linux CN
paru -S pilinara-bin         # atau lewat AUR: pilinara-bin (siap pakai) / pilinara (sumber)
```

<br/>

## Daftar fitur warisan (dari PiliNara / PiliPlus)

Semua di bawah ini diwarisi dari PiliNara (dan, secara transitif, PiliPlus); PiliBabel menambahkan lapisan terjemahan AI di atasnya.

**Antarmuka dan adaptasi platform**
- [x] Aplikasi diganti nama per platform agar beberapa klien bisa hidup berdampingan (PiliBabel terpasang berdampingan dengan PiliNara)
- [x] Perbaikan rendering Flutter di jendela mini Xiaomi HyperOS ([#161086](https://github.com/flutter/flutter/issues/161086), lewat [venera#467](https://github.com/venera-app/venera/pull/467)); animasi kembali prediktif di Android
- [x] Urutan dan jumlah kartu «Saya» dapat disesuaikan; pratinjau kartu riwayat dan bagian «tonton nanti»
- [x] Peralihan bilah samping otomatis dengan lebar pemicu yang bisa diatur; salin gambar lewat tekan lama / klik kanan; pembaruan gaya MD3E besar

**Sistem fon** — kumpulan impor terpadu dengan deduplikasi lewat hash konten, fon danmaku digabung ke kumpulan yang sama, `loadFontFromList` dengan dukungan ttc, dan nama keluarga fon ASCII murni.

**Pemutaran, jendela mini, dan kualitas** — jendela mini dalam aplikasi (seret, ubah ukuran, lewati SponsorBlock, PIP sistem otomatis, bilah penyelamat diri untuk siaran langsung), pemutaran audio bersamaan, volume dalam aplikasi hingga 200 %, domain CDN video kustom dan pemilihan simpul regional dengan uji latensi, kualitas bawaan terpisah untuk setengah layar dan layar penuh, kunci kecepatan dengan geser ke atas, kendali papan tombol pada tablet, cap waktu SuperChat siaran langsung, detak keakraban penggemar siaran langsung.

**Subtitle, AI, dan luring** — subtitle dua bahasa dengan gaya subtitle kedua yang independen, analisis subtitle AI (titik akhir kompatibel OpenAI kustom, lompat ke cap waktu, templat, percakapan tersimpan, cadangan lembut saat tanpa subtitle), ekspor WEBVTT/SRT, tampilan ganda cache luring dengan manajemen folder dan penyimpanan metadata, ekspor unduhan ke folder Download publik (Android).

**Danmaku dan pemblokiran** — peningkatan skala danmaku gabungan (gaya [Pakku.js](https://github.com/xmcp/pakku.js)), pemblokiran ekspresi reguler visual berbentuk daftar dengan impor dan ekspor, lewati ke dalam segmen SponsorBlock, bilah kemajuan energi tinggi dengan kernel Gaussian.

**Penyaringan rekomendasi / dinamika / komentar** — kata kunci judul / kreator / kanal, durasi, jumlah tayangan, rasio suka, pengecualian kreator yang diikuti, penyaringan konten tak sah / khusus pendukung, daftar putih bersama, dinamika komersial / tak sah, pengecualian komentar milik kreator sendiri dan komentar yang disematkan, mode feed gabungan App + Web.

**Dinamika, pencarian, dan info pengguna** — catatan khusus untuk kreator, catatan menggantikan nama panggilan di 13 posisi, pengurutan independen untuk balasan bersarang, penyaring pencarian kata kunci lokal, lompatan tautan pendek b23.tv, lencana khusus pendukung, sakelar sembunyikan alasan rekomendasi, tampilan pengalaman koin.

**Peningkatan siaran langsung** — panel pemakaian medali penggemar, penyiaran DLNA yang mengutamakan HLS, tampilan waktu SuperChat, bilah kendali bawah jendela mini untuk penyelamatan diri.

**Integrasi sistem dan desktop** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), penanganan fokus audio yang ditulis ulang.

<details>
<summary>Daftar fitur asli selengkapnya (apa adanya, dari PiliNara — klik untuk membuka)</summary>

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

## Penafian

PiliBabel adalah proyek pribadi yang digerakkan minat, disediakan **hanya untuk pembelajaran dan pengujian**; mohon hapus dalam **24 jam** setelah diunduh.

- PiliBabel adalah klien **pihak ketiga tidak resmi** dan **tidak berafiliasi dengan, tidak disahkan oleh, maupun disponsori oleh bilibili**.
- Semua API diambil dari titik akhir publik resmi; **tidak ada konten yang dibajak, melebihi hak, atau menembus dinding pembayaran** yang disediakan.
- **Terjemahan AI berjalan pada titik akhir model pihak ketiga.** Secara bawaan itu adalah layanan Index-Translate publik gratis milik bilibili sendiri; jika Anda beralih ke API sendiri, itu adalah titik akhir yang Anda konfigurasi. Kualitas dan kepatuhan terjemahan menjadi tanggung jawab pengguna dan penyedia model yang dipilih; proyek ini **tidak menghosting model apa pun dan tidak menyediakan kunci API apa pun**.
- Hormati hak cipta dan ketentuan layanan bilibili. Gunakan dengan bertanggung jawab.

Dengan penghormatan kepada penulis asli dan hulu atas dedikasi sumber terbuka mereka:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — proyek induk langsung PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — keluarga model terjemahan sumber terbuka yang dipanggil mesin bawaan

Jika ada konten yang melanggar hak Anda, hubungi kami untuk menghapusnya.

<br/>

## Lisensi

PiliBabel dilisensikan di bawah **GNU General Public License v3.0 (GPL-3.0)** — lisensi yang sama dengan PiliNara, PiliPlus, dan PiliPala. Karena merupakan karya turunan, **PiliBabel juga harus didistribusikan di bawah GPL-3.0**: Anda bebas memakainya, mempelajarinya, membagikannya, dan memodifikasinya, asalkan mempertahankan lisensi yang sama, pemberitahuan hak cipta, dan teks lisensi ini. Lihat [`LICENSE`](./LICENSE).

Komponen pihak ketiga (paket Flutter, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), dan lain-lain) tetap tunduk pada lisensinya masing-masing.

<br/>

## Ucapan terima kasih

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — keluarga model terjemahan sumber terbuka bilibili, dan titik akhir publik gratis di balik mesin bawaan
- dan masih banyak lagi
- Terinspirasi oleh «terjemahan antarmuka AI» resmi bilibili.

<sub><a href="#readme-languages">↑ <a href="#readme-en">English</a> · <a href="#readme-zh">中文</a> · <a href="#readme-yue">粵語</a> · <a href="#readme-ja">日本語</a> · <a href="#readme-fr">Français</a> · <a href="#readme-de">Deutsch</a> · <a href="#readme-es">Español</a> · <a href="#readme-ko">한국어</a> · <a href="#readme-ar">العربية</a> · <a href="#readme-vi">Tiếng Việt</a> · <a href="#readme-ms">Bahasa Melayu</a> · <a href="#readme-id">Bahasa Indonesia</a></a></sub>

</details>
