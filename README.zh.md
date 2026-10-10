<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>具備 AI 翻譯功能的第三方嗶哩嗶哩（Bilibili）客戶端。</b></p>
    <p>巴別塔 —— 打破語言的高牆，讓每個人都能用屬於自己的語言享受 Bilibili。</p>
    <p>含 4 種中國少數民族語言與 3 種漢語方言的翻譯。</p>
    <p>內建 B 站官方免費翻譯模型，裝好即用，無需 API Key。</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <b>中文</b> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a></p>
</div>
<!-- lang-switch:end -->

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
