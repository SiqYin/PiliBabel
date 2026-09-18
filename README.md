<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>A third-party Bilibili client with AI-powered translation.</b></p>
    <p>Babel — tearing down the language barrier, so everyone can enjoy bilibili in their own language.</p>
    <p>Includes translation for 4 languages of China's ethnic minorities and 3 Chinese dialects.</p>
    <p><b>具備 AI 翻譯功能的第三方嗶哩嗶哩（Bilibili）客戶端。</b></p>
    <p>巴別塔——打破語言的高牆，讓每個人都能用屬於自己的語言享受 Bilibili。</p>
    <p>含 4 種中國少數民族語言與 3 種漢語方言的翻譯。</p>
</div>

<div align="center">
    <img src="assets/screenshots/main_screen.png" width="96%" alt="home" />
</div>

<br/>

> **Disclaimer.** PiliBabel is an **unofficial, open-source, third-party** client. It is **not affiliated with, endorsed by, or sponsored by** bilibili / bilibili Inc. Every API is gathered from the official public endpoints; **no paid content is unlocked or cracked**. Please read the full [Disclaimer](#disclaimer) and [License](#license) sections.
>
> **免責聲明。** PiliBabel 是一款**非官方、開源、第三方**客戶端，與 Bilibili / 嗶哩嗶哩**無任何隸屬、授權或贊助關係**。所有 API 均取自官方公開介面，**不解鎖、不破解任何付費內容**。請完整閱讀下方的[免責聲明](#免責聲明-disclaimer)與[授權條款](#授權條款-license)章節。

## What is PiliBabel? / PiliBabel 是什麼？

PiliBabel is an **independent third-party fork built on top of [PiliNara](https://github.com/Starfallan/PiliNara)**, and it inherits everything PiliNara inherits:

PiliBabel 是**基於 [PiliNara](https://github.com/Starfallan/PiliNara) 打造、獨立運作的第三方 fork**，並繼承了 PiliNara 所繼承的一切：

```
bilibili (official public API)
bilibili（官方公開 API）
        ▲
   PiliPala / PiliPalaX        — the original project / 原始專案
        ▲
   PiliPlus                    — active fork / 活躍的分支
        ▲
   PiliNara                    — fork of PiliPlus (personal tweaks) / PiliPlus 的分支（個人化改動）
        ▲
   PiliBabel  ← you are here   — fork of PiliNara / PiliNara 的分支
```

PiliBabel keeps **every feature of PiliNara / PiliPlus** (see the [inherited feature log](#inherited-feature-log-from-pilinara--piliplus) near the bottom) and adds **one headline capability the upstream clients do not have**:

PiliBabel 保留了 **PiliNara / PiliPlus 的全部功能**（見下方[繼承功能清單](#繼承功能清單-inherited-feature-log-from-pilinara--piliplus)），並新增了**上游客戶端所沒有的招牌能力**：

> **AI interface & content translation** — the whole app (UI labels, video titles, UP names, comments, dynamics, feed, and even live danmaku) is rendered in the language **you** choose, using an AI model that **you** bring.
>
> **AI 介面／內容翻譯**——整個 App（介面標籤、影片標題、UP 主名稱、留言、動態、推薦流量，甚至直播彈幕）都會用**你**選擇的語言呈現，翻譯由**你自己**帶入的 AI 模型完成。

The idea mirrors bilibili's official "AI interface translation", but it runs entirely on your own OpenAI-compatible endpoint — no vendor lock-in, works across the entire client, and supports a long list of target languages.

其理念參照 bilibili 官方的「AI 介面翻譯」，但完全走**你自己**的 OpenAI 相容端點——沒有廠商鎖定、全 App 通用，並支援極多的目標語言。

## Key features / 主要特色

**EN**
- **AI translation, everywhere.** Navigation tabs, video cards, detail pages, comments, dynamics, and the Mine / Favorites / History / Messages / Search surfaces — a global sweep covers **~1,650+ UI strings**, plus dynamic content (titles, author names, action counts).
- **You bring the model.** Point it at any OpenAI-compatible endpoint (`/chat/completions`) with your own base URL / API key / model. The AI video-summary feature and the AI translation feature have **completely independent** endpoints and settings, both living under one **"AI features"** page.
- **Translate once, then it's fixed.** Each source string is translated **exactly once**; the result is persisted locally and **never re-translated** when you reopen a screen — the same principle as the official client, for stable, predictable translations.
- **Pick your app language.** Defaults to Simplified Chinese. About 35 languages, including English, 日本語, 한국어, Français, Deutsch, Español, Italiano, Русский, ไทย, Tiếng Việt, Bahasa Melayu / Bahasa Indonesia, Filipino, Türkçe, العربية, עברית, བོད་སྐད་, Монгол хэл, ئۇيغۇرچە, Vahcuengh, Simplified Cantonese, Traditional Cantonese, Shanghainese/Wu language, Hokkien, Taiwanese, etc.
- **Per-comment Original ⇄ Translation toggle** (a small icon, not a Chinese word). `@mentions / [emoji] / #topics# / links` are preserved as tokens, and **comments containing hyperlinks still translate while keeping the link clickable**.
- **Danmaku (弹幕) translation** — an independent toggle in the player's top-right control row, **off by default** and gated behind a confirmation whose own text is translated. Once enabled, danmaku ahead of the playhead are pre-translated in **~15-second batches** (seeking to the middle is handled correctly, not from the start), so the translation is usually ready by the time it scrolls in.
- **Thinking-mode switch** (`enable_thinking`) for quality-vs-speed, plus **"test translation"** and **clear-cache** buttons in settings.
- **Fast language switching**: batched requests (≤ 40 strings per batch) with limited concurrency (≤ 8) against a persistent cache; switching language force-rebuilds the current screen once, so you are not left staring at untranslated text.

**中文**
- **全面 AI 翻譯。** 導覽分頁、影片卡片、詳情頁、留言、動態，以及「我的／收藏／歷史／訊息／搜尋」等介面——全域掃描涵蓋**約 1,650+ 條介面字串**，並含動態內容（標題、作者名稱、互動計數）。
- **模型自備。** 填入你自己的 OpenAI 相容端點（`/chat/completions`）的網址／API 金鑰／模型即可。AI 影片摘要與 AI 翻譯兩者擁有**完全獨立**的端點與設定，統一收在一個「**AI 功能**」頁面下。
- **只翻一次，翻完即固定。** 每條原文**僅翻譯一次**，結果落地快取、重開畫面**絕不重翻**——與官方客戶端同原理，翻譯穩定且可預期。
- **選擇 App 語言。** 預設為簡體中文。約 35 種語言，包含English、日本語、한국어、Français、Deutsch、Español、Italiano、Русский、ไทย、Tiếng Việt、Bahasa Melayu／Bahasa Indonesia、Filipino、Türkçe、العربية、עברית、བོད་སྐད་、Монгол хэл、ئۇيغۇرچە、Vahcuengh、简体粤语、繁體粵語、吳語、大陆闽南语、臺灣閩南語等。
- **逐則留言的「原文 ⇄ 譯文」切換**（一個小圖示，不用中文詞）。`@提及 / [表情] / #話題# / 連結` 會作為 token 保留，**含超連結的留言也能翻譯且連結維持可點擊**。
- **彈幕翻譯**——播放器右上角控制列的獨立開關，**預設關閉**，開啟前需確認（確認文案本身也會翻譯）。開啟後，播放頭之後約 **15 秒**視窗內的彈幕會**分批預先翻譯**（拖曳到影片中段也能正確處理，而非從頭算起），滑入時譯文多半已就緒。
- **思考模式開關**（`enable_thinking`）供品質／速度取捨，設定裡並有**「測試翻譯」**與**清空快取**按鈕。
- **切換語言更快**：批次請求（每批 ≤ 40 條）配合有限併發（≤ 8）與持久快取；切換語言時強制重建當前畫面一次，不會讓你卡在還沒翻譯的原文上。

## How the AI interface translation works (technical) / AI 介面翻譯的技術實作

**EN**

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

**中文**

本倉庫**沒有 i18n / ARB 資源層**——介面字串都是硬編碼的中文。PiliBabel 不去重寫每個元件，而是在其上疊加一層薄薄的翻譯層：

1. **全域查詞包裝。** `lib/services/ui_translate/` 暴露頂層函式 `uiTx(String src)`。原本 `Text('中文')` 變成 `Text(uiTx('中文'))`。透過腳本 **codemod**（`tool/ui_translate_*.py`）對全專案套用——約 **223 個檔案 / 1,650+ 條字串**——並在必要處自動移除因而失效的 `const`（含泛型 `const X<T>(...)`、點號名 `const Positioned.fill(...)`，以及把 `static const` 的清單／映射宣告改成 `static final`）。
2. **`GetxService` 核心**（`ui_translate_service.dart`）：
   - 持久的**原文 → 譯文**快取（以 GetStorage 支撐），每條字串只翻一次並永久複用；
   - `tx()` 先讀 `RxInt revision`，再決定：未啟用→回傳原文；若目標為中文變體 **且** 字串本身就像中文（`_looksChinese()` 比對 CJK 表意字與拉丁／假名／諺文／西里爾／阿拉伯／希伯來／泰文字母，外文字母比例低於約 25% 即跳過）→回傳原文；否則走快取或**入佇列**；
   - 佇列內容以**批次（≤ 40）**、**有限併發（≤ 8）**送出；譯文回傳時提升 `revision` / `contentRev`，外圍的 `Obx(...)` 元件就地重建。
3. **傳輸通道**沿用與 AI 影片摘要同一條已驗證的**串流**通道——`AiChatService.streamChat` → `{base}/chat/completions`（`stream: true`，相容僅支援串流的閘道）——並擴充讓翻譯能用**自己**的 `apiUrl` / `apiKey` / `model` 與 `enable_thinking` 旗標。此改動**向後相容**，影片摘要照常運作。
4. **語言表**（`app_language.dart`）：每個 `AppLanguage` 帶有顯示用的自稱名，以及編入書寫／地域規範的 `toModel` 提示字串——這些規範只透過提示詞送達模型。
5. **留言**走 `uiTxComment(text, id)`，保留 `@ / [表情] / #話題# / 連結` 為完整 token；含連結的富文本 span 會翻譯且連結辨識器保留，並以逐則 id 集合驅動「原文 ⇄ 譯文」切換。
6. **彈幕**（`danmaku/view.dart`）：開關開啟時，位置監聽每秒走訪 `[playhead, playhead + 15s]`，對每條彈幕內容預熱 `uiTx()`，使其在滑入畫面前即已預翻；開啟時會清屏重繪。
7. **儲存鍵**：`uiTranslate{Enabled,Lang,Model,ApiUrl,ApiKey,Thinking,Cache}`。**設定介面**：單一第一層「AI 功能」頁（`lib/pages/setting/ui_translate/`），內含 AI 影片摘要與 AI 翻譯兩段各自獨立的設定。

**設計取捨／已知限制。** 由於字串就地包裝而非抽成資源，少數非 `Text` 的字串參數與部分富文本 span 仍持續增量補齊。被當作**邏輯鍵**使用的字串（以 `==` 比對、當作分頁名如 `简介`、或在 switch 中比較的列舉標籤）**刻意不**做整體包裝，以免破壞行為。彈幕翻譯在捲動畫布上屬盡力而為——彈幕極度密集時，你可能先短暫看到原文再看到譯文。翻譯需要網路與已設定的模型；未配置翻譯端點時，非中文目標語言是不會生效的。

## Build & verify / 建置與驗證

**EN.** The app is built with a patched Flutter SDK plus patched `material_ui` / `cupertino_ui` packages via `lib/scripts/patch.ps1` and `lib/scripts/build.ps1` (exactly like PiliNara / PiliPlus). This repo ships a GitHub Actions workflow (`.github/workflows/ui-translate-debug.yml`) that produces a **debug APK** on every push, so the translation layer and the rebrand are continuously compile-verified.

**中文。** 本 App 以「打了補丁的 Flutter SDK」加上補丁版 `material_ui` / `cupertino_ui` 套件建置，透過 `lib/scripts/patch.ps1` 與 `lib/scripts/build.ps1` 完成（與 PiliNara / PiliPlus 完全相同）。本倉庫附帶 GitHub Actions 工作流（`.github/workflows/ui-translate-debug.yml`），每次 push 即產出 **debug APK**，讓翻譯層與品牌改造持續通過編譯驗證。

<br/>

## Platforms / 適配平台
- [x] Android
- [ ] iOS
- [ ] Pad
- [ ] Windows
- [ ] Linux

**EN.** PiliBabel currently ships an **Android APK** only; the other platforms share the same codebase as upstream but aren't packaged in this fork yet.

**中文。** PiliBabel 目前僅產出 **Android APK**；其它平台與上游共用同一套代碼，惟此分支尚未打包。

<br/>

## Download / 下載

**EN.** Grab a build from **Releases**, or clone the repo and build it locally.

**中文。** 於 **Releases** 頁面下載建置產物，或將倉庫 clone 到本地自行編譯。

### Arch Linux

**EN.** Thanks to [@nlsdt](https://github.com/nlsdt) for packaging (the PiliNara recipe carries over to PiliBabel).

**中文。** 感謝 [@nlsdt](https://github.com/nlsdt) 打包（PiliNara 的打包配方同樣適用於 PiliBabel）。

```bash
sudo pacman -S pilinara      # via the Arch Linux CN repository / 經 Arch Linux 中文（CN）倉庫
paru -S pilinara-bin         # or via AUR: pilinara-bin (prebuilt) / pilinara (source) / 或經 AUR：pilinara-bin（預編譯）/ pilinara（原始碼）
```

<br/>

## Inherited feature log (from PiliNara / PiliPlus) / 繼承功能清單（來自 PiliNara / PiliPlus）

**EN.** Everything below is carried over from PiliNara (and, transitively, PiliPlus); PiliBabel adds the AI translation layer on top.

**中文。** 以下皆繼承自 PiliNara（並追溯繼承自 PiliPlus）；PiliBabel 在其上疊加了 AI 翻譯層。

**UI & platform adaptation / 基礎適配與介面**
- [x] App renamed per platform so multiple clients can coexist (PiliBabel installs alongside PiliNara) ／ 各平台更名以實現多客戶端共存（PiliBabel 可與 PiliNara 並存安裝）
- [x] Fixed Flutter rendering under Xiaomi HyperOS mini-window ([#161086](https://github.com/flutter/flutter/issues/161086), via [venera#467](https://github.com/venera-app/venera/pull/467)); predictive back animation on Android ／ 修正澎湃小窗下 Flutter 顯示問題；Android 支援預測性返回動畫
- [x] Customizable "Mine" card order/count; history-card preview & "watch later" sections ／ 自訂「我的」卡片順序與數量；歷史卡片預覽與「稍後再看」區塊
- [x] Auto sidebar switching with configurable trigger width; copy-image from long-press / right-click; large MD3E style refresh ／ 自動側欄切換且可設定觸發寬度；長按／右鍵選單支援複製圖片；大量介面升級 MD3E 風格

**Font system / 字型系統** — a unified import pool with content-hash de-duplication, danmaku fonts merged into the same pool, `loadFontFromList` with ttc support, and pure-ASCII hash family names. ／ 以內容雜湊去重的統一匯入池、彈幕字型併入同一池、`loadFontFromList` 支援 ttc、字型族名採純 ASCII 雜湊命名。

**Playback, mini-window & quality / 播放、小窗與畫質** — in-app mini-window (drag, resize, SponsorBlock skip, auto system PIP, live self-rescue bar), concurrent-audio playback, in-app volume up to 200%, custom video CDN domain & regional node selection with latency test, separate half/full-screen default quality, swipe-up speed lock, tablet keyboard control, live SuperChat timestamps, live heartbeat for fan-intimacy. ／ 應用內小窗（拖曳、縮放、SponsorBlock 跳段、自動進系統小窗、直播自救控制列）、可與其他 App 同時播放、應用內音量最高 200%、自訂影片 CDN 域名與區域節點（含測速）、半／全屏各自預設畫質、上滑鎖定倍速、平板鍵盤控制、直播 SC 時間戳、直播心跳累積親密度。

**Subtitles, AI & offline / 字幕、AI 與離線快取** — bilingual subtitles with independent secondary-subtitle styling, AI subtitle analysis (custom OpenAI-compatible endpoint, timestamp jump, templates, persisted conversations, soft no-subtitle fallback), WEBVTT/SRT export, offline-cache dual view with folder management & metadata persistence, export downloads to the public Download folder (Android). ／ 雙語字幕與副字幕獨立樣式、AI 字幕分析（自訂 OpenAI 相容端點、時間戳跳轉、模板、對話持久化、無字幕軟性降級）、WEBVTT/SRT 匯出、離線快取雙視圖與資料夾管理與中繼資料持久化、匯出至公共 Download 目錄（僅 Android）。

**Danmaku & blocking / 彈幕與封鎖** — enhanced merged-danmaku scaling ([Pakku.js](https://github.com/xmcp/pakku.js)-style), list-based visual regex blocking with import/export, SponsorBlock seek-into-segment skip, Gaussian-kernel high-energy progress bar. ／ 增強合併彈幕放大（類 Pakku.js）、列表式視覺化正規表達式封鎖與匯入/匯出、SponsorBlock 拖入片段時跳過、高斯核高能進度條。

**Recommendation / dynamic / comment filtering / 推薦、動態與留言過濾** — title/UP/channel keywords, duration, play-count, like-rate, followed-UP exemption, unauthorized/charge-only filtering, shared whitelist, commerce/unauthorized dynamics, UP-own-comment & pinned-comment exemptions, App+Web merged-feed mode. ／ 標題/UP/分區關鍵字、時長、播放量、點讚率、已關注 UP 豁免、無權/充電專屬過濾、共用白名單、帶貨/無權動態、UP 主本人留言與置頂豁免、App+Web 合併流量模式。

**Dynamics, search & user info / 動態、搜尋與使用者資訊** — custom notes for UPs, note-replaces-nickname across 13 name slots, independent nested-comment sort, local keyword search filter, b23.tv short-link jump, charge-only badge, hide-recommendation-reason toggle, coin XP display. ／ UP 主自訂備註、備註取代暱稱覆蓋 13 處名稱位、樓中樓獨立排序、本地關鍵字搜尋過濾、b23.tv 短鏈直達、充電專屬角標、可隱藏推薦理由、投幣經驗顯示。

**Live enhancements / 直播增強** — fan-medal wearing panel, DLNA cast preferring HLS, SuperChat time display, mini-window bottom control bar for self-rescue. ／ 粉絲勳章佩戴面板、DLNA 投屏優先 HLS、SC 時間顯示、小窗底部控制列自救。

**System integration & desktop / 系統整合與桌面** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), rebuilt audio-focus handling. ／ Windows SMTC、Linux MPRIS、音訊焦點處理重構。

<details>
<summary>Full original feature/checklist (verbatim, from PiliNara — click to expand) / 完整原始功能清單（PiliNara 原文，點擊展開）</summary>

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

## Disclaimer / 免責聲明

**EN.** PiliBabel is a personal, interest-driven project, provided **for learning and testing only**; please delete it within **24 hours** of download.

**中文。** 本專案（PiliBabel）為個人興趣開發，**僅供學習與測試**；請在下載後 **24 小時內**刪除。

**EN**
- PiliBabel is an **unofficial third-party** client and is **not affiliated with, endorsed by, or sponsored by bilibili**.
- All APIs are gathered from official public endpoints; **no cracked, over-privileged, or paywall-bypassing content** is provided.
- **AI translation runs entirely on the user's own third-party model endpoint.** Translation quality and compliance are the responsibility of the user and their chosen model provider; this project hosts **no model and no API key**.
- Respect copyright and bilibili's Terms of Service. Use responsibly.

**中文**
- PiliBabel 為**非官方第三方**客戶端，與 bilibili **無任何隸屬、授權或贊助關係**。
- 所有 API 均取自官方公開介面，**不提供任何破解、越權或繞過付費限制的內容**。
- **AI 翻譯完全由使用者自備的第三方模型端點驅動。** 翻譯品質與合規由使用者及其選用的模型服務商負責；本專案**不託管任何模型或 API 金鑰**。
- 請尊重智慧財產權與 bilibili 的服務條款，合理使用。

**EN.** With respect to the original and upstream authors for their open-source dedication:
**中文.** 謹此致敬原作者與上游作者對開源的無私奉獻：
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — the direct parent project of PiliBabel / PiliBabel 的直接父專案

**EN.** If any content infringes your rights, please contact us for takedown.
**中文.** 若任何內容侵犯了您的權益，請聯繫我們下架處理。

<br/>

## License / 授權條款

**EN.** PiliBabel is licensed under the **GNU General Public License v3.0 (GPL-3.0)** — the same license as PiliNara, PiliPlus and PiliPala. Because it is a derivative work, **PiliBabel must also be distributed under GPL-3.0**: you are free to use, study, share and modify it, provided you keep the same license, the copyright notices, and this license text. See [`LICENSE`](./LICENSE).

**中文.** PiliBabel 以 **GNU 通用公共授權條款 v3.0（GPL-3.0）** 授權——與 PiliNara、PiliPlus、PiliPala 相同。因其為衍生作品，**PiliBabel 亦須以 GPL-3.0 分發**：你可自由使用、研究、分享與修改，前提是保留相同授權、版權聲明與本授權全文。見 [`LICENSE`](./LICENSE)。

**EN.** Third-party components (Flutter packages, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), etc.) remain under their own licenses.

**中文.** 第三方元件（Flutter 套件、[`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect)、[`media-kit`](https://github.com/media-kit/media-kit)、[`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer)、[`dio`](https://pub.dev/packages/dio) 等）仍適用其各自授權條款。

<br/>

## Acknowledgements / 致謝

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- and more / 等等
- Inspired by bilibili's official "AI interface translation". / 靈感來自 bilibili 官方「AI 介面翻譯」。

<br/>

## Star History

<a href="https://star-history.dera.page/#SiqYin/PiliBabel">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://star-history.dera.page/svg?repos=SiqYin/PiliBabel&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://star-history.dera.page/svg?repos=SiqYin/PiliBabel" />
   <img alt="Star History Chart" src="https://star-history.dera.page/svg?repos=SiqYin/PiliBabel" />
 </picture>
</a>
