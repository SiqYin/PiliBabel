<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>具備 AI 翻譯功能的第三方嗶哩嗶哩（Bilibili）客戶端。</b></p>
    <p>巴別塔——打破語言的高牆，讓每個人都能用屬於自己的語言享受 Bilibili。</p>
    <p>含 4 種中國少數民族語言與 3 種漢語方言的翻譯。</p>
    <p>
      <a href="README.md">English</a> · <b>中文</b>
    </p>
</div>

<div align="center">
    <img src="assets/screenshots/main_screen.png" width="96%" alt="home" />
</div>

<br/>

> **免責聲明。** PiliBabel 是一款**非官方、開源、第三方**客戶端，與 Bilibili / 嗶哩嗶哩**無任何隸屬、授權或贊助關係**。所有 API 均取自官方公開介面，**不解鎖、不破解任何付費內容**。請完整閱讀下方的[免責聲明](#免責聲明)與[授權條款](#授權條款)章節。

## PiliBabel 是什麼？

PiliBabel 是**基於 [PiliNara](https://github.com/Starfallan/PiliNara) 打造、獨立運作的第三方 fork**，並繼承了 PiliNara 所繼承的一切：

```
bilibili（官方公開 API）
        ▲
   PiliPala / PiliPalaX        — 原始專案
        ▲
   PiliPlus                    — 活躍的分支
        ▲
   PiliNara                    — PiliPlus 的分支（個人化改動）
        ▲
   PiliBabel  ← 你在這裡        — PiliNara 的分支
```

PiliBabel 保留了 **PiliNara / PiliPlus 的全部功能**（見下方[繼承功能清單](#繼承功能清單來自-pilinara--piliplus)），並新增了**上游客戶端所沒有的招牌能力**：

> **AI 介面／內容翻譯**——整個 App（介面標籤、影片標題、UP 主名稱、留言、動態、推薦流量，甚至直播彈幕）都會用**你**選擇的語言呈現，翻譯由**你自己**帶入的 AI 模型完成。

其理念參照 bilibili 官方的「AI 介面翻譯」，但完全走**你自己**的 OpenAI 相容端點——沒有廠商鎖定、全 App 通用，並支援極多的目標語言。

## 主要特色

- **全面 AI 翻譯。** 導覽分頁、影片卡片、詳情頁、留言、動態，以及「我的／收藏／歷史／訊息／搜尋」等介面——全域掃描涵蓋**約 1,650+ 條介面字串**，並含動態內容（標題、作者名稱、互動計數）。
- **模型自備。** 填入你自己的 OpenAI 相容端點（`/chat/completions`）的網址／API 金鑰／模型即可。AI 影片摘要與 AI 翻譯兩者擁有**完全獨立**的端點與設定，統一收在一個「**AI 功能**」頁面下。
- **只翻一次，翻完即固定。** 每條原文**僅翻譯一次**，結果落地快取、重開畫面**絕不重翻**——與官方客戶端同原理，翻譯穩定且可預期。
- **選擇 App 語言。** 預設為簡體中文。約 35 種語言，包含English、日本語、한국어、Français、Deutsch、Español、Italiano、Русский、ไทย、Tiếng Việt、Bahasa Melayu／Bahasa Indonesia、Filipino、Türkçe、العربية、עברית、བོད་སྐད་、Монгол хэл、ئۇيغۇرچە、Vahcuengh、简体粤语、繁體粵語、吳語、大陆闽南语、臺灣閩南語等。
- **逐則留言的「原文 ⇄ 譯文」切換**（一個小圖示，不用中文詞）。`@提及 / [表情] / #話題# / 連結` 會作為 token 保留，**含超連結的留言也能翻譯且連結維持可點擊**。
- **彈幕翻譯**——播放器右上角控制列的獨立開關，**預設關閉**，開啟前需確認（確認文案本身也會翻譯）。開啟後，播放頭之後約 **15 秒**視窗內的彈幕會**分批預先翻譯**（拖曳到影片中段也能正確處理，而非從頭算起），滑入時譯文多半已就緒。
- **思考模式開關**（`enable_thinking`）供品質／速度取捨，設定裡並有**「測試翻譯」**與**清空快取**按鈕。
- **切換語言更快**：批次請求配合有限併發與持久快取；切換語言時強制重建當前畫面一次，不會讓你卡在還沒翻譯的原文上。
- **首次啟動引導。** 第一次開啟 App 時會跳出（英文）說明如何開啟 AI 翻譯（**設定 → AI → AI 介面翻譯**），並提供一鍵直達該設定頁的按鈕。
- **全球都能順暢播放。** 播放地址取自 B 站按你 IP 就近下發的 playurl；當原本只會拿到國內 **P2P／PCDN(mcdn)** 節點時，PiliBabel 會把它改寫到 **Akamai 全球邊緣**，也不再將播放鎖死在國內（阿里雲／深圳）節點——海外用戶不會再遇到「音訊還在走、視頻卡住」。（仍可在設定中手動指定 CDN。）

## AI 介面翻譯的技術實作

本倉庫**沒有 i18n / ARB 資源層**——介面字串都是硬編碼的中文。PiliBabel 不去重寫每個元件，而是在其上疊加一層薄薄的翻譯層：

1. **全域查詞包裝。** `lib/services/ui_translate/` 暴露頂層函式 `uiTx(String src)`。原本 `Text('中文')` 變成 `Text(uiTx('中文'))`。透過腳本 **codemod**（`tool/ui_translate_*.py`）對全專案套用——約 **223 個檔案 / 1,650+ 條字串**——並在必要處自動移除因而失效的 `const`（含泛型 `const X<T>(...)`、點號名 `const Positioned.fill(...)`，以及把 `static const` 的清單／映射宣告改成 `static final`）。
2. **`GetxService` 核心**（`ui_translate_service.dart`）：
   - 持久的**原文 → 譯文**快取（以 GetStorage 支撐），每條字串只翻一次並永久複用；
   - `tx()` 先讀 `RxInt revision`，再決定：未啟用→回傳原文；若目標為中文變體 **且** 字串本身就像中文（`_looksChinese()` 比對 CJK 表意字與拉丁／假名／諺文／西里爾／阿拉伯／希伯來／泰文字母，外文字母比例低於約 25% 即跳過）→回傳原文；否則走快取或**入佇列**；
   - 佇列由 **worker 執行池**處理，**逐塊遞迴套用**（每塊一返回即提升 `revision`，讓译文渐进出现；批次 ≤ 16、併發 ≤ 10），結果**節流持久化**。
3. **傳輸通道**沿用與 AI 影片摘要同一條已驗證的**串流**通道——`AiChatService.streamChat` → `{base}/chat/completions`（`stream: true`，相容僅支援串流的閘道）——並擴充讓翻譯能用**自己**的 `apiUrl` / `apiKey` / `model` 與 `enable_thinking` 旗標。此改動**向後相容**，影片摘要照常運作。
4. **含變數的句子**走 `uiTxP(template, args)`：把帶 `{0}`/`{1}` 佔位符的整句作為一個穩定 key 送翻譯（提示詞要求保留佔位符），再把值回填——像 `共 {0} 條` 這種句子也能翻，且不動變數部分。
5. **語言表**（`app_language.dart`）：每個 `AppLanguage` 帶有顯示用的自稱名，以及編入書寫／地域規範的 `toModel` 提示字串——這些規範只透過提示詞送達模型。
6. **留言**走 `uiTxComment(text, id)`，保留 `@ / [表情] / #話題# / 連結` 為完整 token；含連結的富文本 span 會翻譯且連結辨識器保留，並以逐則 id 集合驅動「原文 ⇄ 譯文」切換。
7. **彈幕**（`danmaku/view.dart`）：開關開啟時，位置監聽每秒走訪 `[playhead, playhead + 15s]`，對每條彈幕內容預熱 `uiTx()`，使其在滑入畫面前即已預翻；開啟時會清屏重繪。
8. **儲存鍵**：`uiTranslate{Enabled,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`。**設定介面**：單一第一層「AI 功能」頁（`lib/pages/setting/ui_translate/`），內含 AI 影片摘要與 AI 翻譯兩段各自獨立的設定。

**全球 CDN（`VideoUtils.getCdnUrl`）。** PiliBabel 優先採用 B 站 playurl 依客戶端 IP 就近返回的地址（不再改寫成國內固定主機）。若只剩國內 P2P/PCDN（`mcdn`、`proxy-tf-*`）節點，則把主機改寫到全球 **Akamai** 邊緣（`upos-hz-mirrorakam.akamaized.net`），讓海外從就近節點取流而非卡在國內節點。純 `/v/resource` 的 P2P 連結仍沿用既有中繼以避免 404。

**設計取捨／已知限制。** 由於字串就地包裝而非抽成資源，少數非 `Text` 的字串參數與部分富文本 span 仍持續增量補齊。被當作**邏輯鍵**使用的字串（以 `==` 比對、當作分頁名如 `简介`、或在 switch 中比較的列舉標籤）**刻意不**做整體包裝，以免破壞行為。彈幕翻譯在捲動畫布上屬盡力而為——彈幕極度密集時，你可能先短暫看到原文再看到譯文。翻譯需要網路與已設定的模型；未配置翻譯端點時，非中文目標語言是不會生效的。

## 建置與驗證

本 App 以「打了補丁的 Flutter SDK」加上補丁版 `material_ui` / `cupertino_ui` 套件建置，透過 `lib/scripts/patch.ps1` 與 `lib/scripts/build.ps1` 完成（與 PiliNara / PiliPlus 完全相同）。GitHub Actions 每次 push 產出 **debug APK**（`.github/workflows/ui-translate-debug.yml`）；**推送 tag `v*` 會自動建置並發布 Android、Windows、Linux 产物**（`release.yml`、`win_x64.yml`、`linux_x64.yml`）。

<br/>

## 適配平台
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

PiliBabel 從 Releases 提供 **Android（APK）、Windows 與 Linux** 版本；iOS/Pad 此分支尚未打包。

<br/>

## 下載

於 **Releases** 頁面下載建置產物，或將倉庫 clone 到本地自行編譯。

### Arch Linux

感謝 [@nlsdt](https://github.com/nlsdt) 打包（PiliNara 的打包配方同樣適用於 PiliBabel）。

```bash
sudo pacman -S pilinara      # 經 Arch Linux 中文（CN）倉庫
paru -S pilinara-bin         # 或經 AUR：pilinara-bin（預編譯）/ pilinara（原始碼）
```

<br/>

## 繼承功能清單（來自 PiliNara / PiliPlus）

以下皆繼承自 PiliNara（並追溯繼承自 PiliPlus）；PiliBabel 在其上疊加了 AI 翻譯層。

**基礎適配與介面**
- [x] 各平台更名以實現多客戶端共存（PiliBabel 可與 PiliNara 並存安裝）
- [x] 修正澎湃小窗下 Flutter 顯示問題（[#161086](https://github.com/flutter/flutter/issues/161086)，參考 [venera#467](https://github.com/venera-app/venera/pull/467)）；Android 支援預測性返回動畫
- [x] 自訂「我的」卡片順序與數量；歷史卡片預覽與「稍後再看」區塊
- [x] 自動側欄切換且可設定觸發寬度；長按／右鍵選單支援複製圖片；大量介面升級 MD3E 風格

**字型系統** — 以內容雜湊去重的統一匯入池、彈幕字型併入同一池、`loadFontFromList` 支援 ttc、字型族名採純 ASCII 雜湊命名。

**播放、小窗與畫質** — 應用內小窗（拖曳、縮放、SponsorBlock 跳段、自動進系統小窗、直播自救控制列）、可與其他 App 同時播放、應用內音量最高 200%、自訂影片 CDN 域名與區域節點（含測速）、半／全屏各自預設畫質、上滑鎖定倍速、平板鍵盤控制、直播 SC 時間戳、直播心跳累積親密度。

**字幕、AI 與離線快取** — 雙語字幕與副字幕獨立樣式、AI 字幕分析（自訂 OpenAI 相容端點、時間戳跳轉、模板、對話持久化、無字幕軟性降級）、WEBVTT/SRT 匯出、離線快取雙視圖與資料夾管理與中繼資料持久化、匯出至公共 Download 目錄（僅 Android）。

**彈幕與封鎖** — 增強合併彈幕放大（類 [Pakku.js](https://github.com/xmcp/pakku.js)）、列表式視覺化正規表達式封鎖與匯入/匯出、SponsorBlock 拖入片段時跳過、高斯核高能進度條。

**推薦、動態與留言過濾** — 標題/UP/分區關鍵字、時長、播放量、點讚率、已關注 UP 豁免、無權/充電專屬過濾、共用白名單、帶貨/無權動態、UP 主本人留言與置頂豁免、App+Web 合併流量模式。

**動態、搜尋與使用者資訊** — UP 主自訂備註、備註取代暱稱覆蓋 13 處名稱位、樓中樓獨立排序、本地關鍵字搜尋過濾、b23.tv 短鏈直達、充電專屬角標、可隱藏推薦理由、投幣經驗顯示。

**直播增強** — 粉絲勳章佩戴面板、DLNA 投屏優先 HLS、SC 時間顯示、小窗底部控制列自救。

**系統整合與桌面** — Windows SMTC、Linux MPRIS（`audio_service_mpris`）、音訊焦點處理重構。

<details>
<summary>完整原始功能清單（PiliNara 原文，點擊展開）</summary>

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

本專案（PiliBabel）為個人興趣開發，**僅供學習與測試**；請在下載後 **24 小時內**刪除。

- PiliBabel 為**非官方第三方**客戶端，與 bilibili **無任何隸屬、授權或贊助關係**。
- 所有 API 均取自官方公開介面，**不提供任何破解、越權或繞過付費限制的內容**。
- **AI 翻譯完全由使用者自備的第三方模型端點驅動。** 翻譯品質與合規由使用者及其選用的模型服務商負責；本專案**不託管任何模型或 API 金鑰**。
- 請尊重智慧財產權與 bilibili 的服務條款，合理使用。

謹此致敬原作者與上游作者對開源的無私奉獻：
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — PiliBabel 的直接父專案

若任何內容侵犯了您的權益，請聯繫我們下架處理。

<br/>

## 授權條款

PiliBabel 以 **GNU 通用公共授權條款 v3.0（GPL-3.0）** 授權——與 PiliNara、PiliPlus、PiliPala 相同。因其為衍生作品，**PiliBabel 亦須以 GPL-3.0 分發**：你可自由使用、研究、分享與修改，前提是保留相同授權、版權聲明與本授權全文。見 [`LICENSE`](./LICENSE)。

第三方元件（Flutter 套件、[`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect)、[`media-kit`](https://github.com/media-kit/media-kit)、[`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer)、[`dio`](https://pub.dev/packages/dio) 等）仍適用其各自授權條款。

<br/>

## 致謝

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- 等等
- 靈感來自 bilibili 官方「AI 介面翻譯」。

<br/>

## Star History

<a href="https://star-history.dera.page/#SiqYin/PiliBabel">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://star-history.dera.page/svg?repos=SiqYin/PiliBabel&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://star-history.dera.page/svg?repos=SiqYin/PiliBabel" />
   <img alt="Star History Chart" src="https://star-history.dera.page/svg?repos=SiqYin/PiliBabel" />
 </picture>
</a>
