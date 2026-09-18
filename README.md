<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>A third-party Bilibili client with AI-powered translation.</b></p>
    <p>Babel — tearing down the language barrier, so everyone can enjoy bilibili in their own language.</p>
</div>

<div align="center">
    <img src="assets/screenshots/main_screen.png" width="96%" alt="home" />
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

> **AI interface & content translation** — the whole app (UI labels, video titles, UP names, comments, dynamics, feed, and even live danmaku) is rendered in the language **you** choose, using an AI model that **you** bring.

The idea mirrors bilibili's official "AI interface translation", but it runs entirely on your own OpenAI-compatible endpoint — no vendor lock-in, works across the entire client, and supports a long list of target languages.

## Key features

- **AI translation, everywhere.** Navigation tabs, video cards, detail pages, comments, dynamics, and the Mine / Favorites / History / Messages / Search surfaces — a global sweep covers **~1,650+ UI strings**, plus dynamic content (titles, author names, action counts).
- **You bring the model.** Point it at any OpenAI-compatible endpoint (`/chat/completions`) with your own base URL / API key / model. The AI video-summary feature and the AI translation feature have **completely independent** endpoints and settings, both living under one **"AI features"** page.
- **Translate once, then it's fixed.** Each source string is translated **exactly once**; the result is persisted locally and **never re-translated** when you reopen a screen — the same principle as the official client, for stable, predictable translations.
- **Pick your app language.** Defaults to 简体中文. Choose from ~35 languages — English, 日本語, 한국어, Français, Deutsch, Español, Italiano, Русский, ไทย, Tiếng Việt, Bahasa Melayu / Bahasa Indonesia, Filipino, Türkçe, العربية, עברית, plus Chinese varieties (简体/繁体粤语, 吴语, 大陆/台湾闽南语, 藏语, 蒙古语, 维吾尔语, …).
  - With a **Chinese** variety selected, only **foreign → Chinese** is translated; your existing Chinese text is left untouched (this replaces and extends the native "comment foreign→Chinese" behaviour).
  - With a **non-Chinese** language selected, the **entire interface** is rendered in that language.
  - Language-specific writing rules (Simplified/Traditional script, Taiwan's Ministry-of-Education standard, regional wording) are encoded **only in the prompt sent to the model**, never cluttering the UI.
- **Per-comment Original ⇄ Translation toggle** (a small icon, not a Chinese word). `@mentions / [emoji] / #topics# / links` are preserved as tokens, and **comments containing hyperlinks still translate while keeping the link clickable**.
- **Danmaku (弹幕) translation** — an independent toggle in the player's top-right control row, **off by default** and gated behind a confirmation whose own text is translated. Once enabled, danmaku ahead of the playhead are pre-translated in **~15-second batches** (seeking to the middle is handled correctly, not from the start), so the translation is usually ready by the time it scrolls in.
- **Thinking-mode switch** (`enable_thinking`) for quality-vs-speed, plus **"test translation"** and **clear-cache** buttons in settings.
- **Fast language switching**: batched requests (≤ 40 strings per batch) with limited concurrency (≤ 8) against a persistent cache; switching language force-rebuilds the current screen once, so you are not left staring at untranslated text.

## How the AI interface translation works (technical)

The repository has **no i18n / ARB resource layer** — UI strings are hard-coded Chinese. Rather than rewriting every widget, PiliBabel adds a thin translation layer on top:

1. **A global lookup wrapper.** `lib/services/ui_translate/` exposes a top-level `uiTx(String src)`. Widget text that used to be `Text('中文')` becomes `Text(uiTx('中文'))`. A scripted **codemod** applied this across the project (`tool/ui_translate_*.py`) — about **223 files / ~1,650+ strings** — automatically dropping the now-invalid `const` keyword where required (including generics such as `const X<T>(...)` and dotted names such as `const Positioned.fill(...)`, and converting `static const` list/map declarations to `static final`).
2. **A `GetxService` core** (`ui_translate_service.dart`):
   - a persistent **source → translation** cache (backed by GetStorage), so every string is translated once and reused forever;
   - `tx()` reads an `RxInt revision` first, then decides: if disabled → return the original; if the target is a Chinese variety **and** the string already looks Chinese (`_looksChinese()` compares CJK ideographs against Latin / kana / hangul / Cyrillic / Arabic / Hebrew / Thai letters and skips when foreign letters are under ~25%) → return the original; otherwise serve from cache or **enqueue**;
   - enqueued strings are flushed in **batches (≤ 40)** with **limited concurrency (≤ 8)**; as translations land, `revision` / `contentRev` bump and the surrounding `Obx(...)` widgets rebuild in place.
3. **The transport** reuses the same verified **streaming** channel as AI video summary — `AiChatService.streamChat` → `{base}/chat/completions` with `stream: true` (compatible with gateways that only support streaming) — extended so translation can use its **own** `apiUrl` / `apiKey` / `model` and an `enable_thinking` flag. The change is **backward-compatible**, so video summary keeps working unchanged.
4. **Language table** (`app_language.dart`): each `AppLanguage` carries a display autonym and a `toModel` prompt string that encodes script/region conventions, which reach the model only through the prompt.
5. **Comments** go through `uiTxComment(text, id)`, keeping `@ / [emoji] / #topic# / link` as intact tokens; rich-text spans that carry links are translated while the link recognizer is preserved, and a per-comment id set drives the Original ⇄ Translation toggle.
6. **Danmaku** (`danmaku/view.dart`): when its toggle is on, a position listener walks `[playhead, playhead + 15s]` one second at a time and warms `uiTx()` on each danmaku's content, so items are pre-translated before they reach the screen; enabling it clears and repaints the canvas.
7. **Storage keys**: `uiTranslate{Enabled,Lang,Model,ApiUrl,ApiKey,Thinking,Cache}`. **Settings UI**: a single first-level "AI features" page (`lib/pages/setting/ui_translate/`) with independent blocks for AI video summary and AI translation.

**Design trade-offs / known limits.** Because strings are wrapped in place rather than extracted into resources, a few non-`Text` string parameters and some rich-text spans are still being filled in incrementally. Strings that double as **logic keys** (compared with `==`, used as tab names such as `简介`, or enum labels used in switches) are deliberately **not** blanket-wrapped, to avoid breaking behaviour. Danmaku translation is best-effort on a scrolling canvas — under extremely dense danmaku you may briefly see the original before the translation arrives. Translation needs network plus a configured model; without a translation endpoint, non-Chinese targets simply do not take effect.

## Build & verify

The app is built with a patched Flutter SDK plus patched `material_ui` / `cupertino_ui` packages via `lib/scripts/patch.ps1` and `lib/scripts/build.ps1` (exactly like PiliNara / PiliPlus). This repo ships a GitHub Actions workflow (`.github/workflows/ui-translate-debug.yml`) that produces a **debug APK** on every push, so the translation layer and the rebrand are continuously compile-verified.

<br/>

## Platforms / 适配平台
- [x] Android
- [x] iOS
- [x] Pad
- [x] Windows
- [x] Linux

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
- **AI translation runs entirely on the user's own third-party model endpoint.** Translation quality and compliance are the responsibility of the user and their chosen model provider; this project hosts **no model and no API key**.
- Respect copyright and bilibili's Terms of Service. Use responsibly.

With respect to the original and upstream authors for their open-source dedication:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — the direct parent project of PiliBabel

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
- and more
- Inspired by bilibili's official "AI interface translation".

<br/>

## Star History

<a href="https://star-history.dera.page/#SiqYin/PiliBabel">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://star-history.dera.page/svg?repos=SiqYin/PiliBabel&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://star-history.dera.page/svg?repos=SiqYin/PiliBabel" />
   <img alt="Star History Chart" src="https://star-history.dera.page/svg?repos=SiqYin/PiliBabel" />
 </picture>
</a>
