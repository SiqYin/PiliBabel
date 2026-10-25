<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>有 AI 翻譯功能的第三方嗶哩嗶哩（Bilibili）客戶端。</b></p>
    <p>巴別塔 —— 拍破言語的高牆，予逐家用家己的言語享受 bilibili。</p>
    <p>有 151 種 bilibili 官方支援的言語，閣加 6 種官方無的：傳統華語、簡體佮傳統吳語、中國大陸佮台灣的閩南語，閣有壯語。</p>
    <p>內建 B 站官方的免費翻譯模型，裝好就用，免 API Key。</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <b>台語</b> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.mn.md">Монгол</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.pt.md">Português</a> · <a href="README.bn.md">বাংলা</a> · <a href="README.th.md">ไทย</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.it.md">Italiano</a> · <a href="README.fa.md">فارسی</a> · <a href="README.fil.md">Filipino</a> · <a href="README.ur.md">اردو</a> · <a href="README.mr.md">मराठी</a> · <a href="README.te.md">తెలుగు</a> · <a href="README.ta.md">தமிழ்</a> · <a href="README.pa.md">ਪੰਜਾਬੀ</a> · <a href="README.gu.md">ગુજરાતી</a> · <a href="README.ha.md">Hausa</a> · <a href="README.sw.md">Kiswahili</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.my.md">မြန်မာ</a> · <a href="README.pl.md">Polski</a> · <a href="README.is.md">Íslenska</a> · <a href="README.nb.md">Norsk</a> · <a href="README.fi.md">Suomi</a> · <a href="README.sv.md">Svenska</a> · <a href="README.da.md">Dansk</a> · <a href="README.be.md">Беларуская</a> · <a href="README.ug.md">ئۇيغۇرچە</a> · <a href="README.kk.md">Қазақша</a> · <a href="README.bo.md">བོད་ཡིག</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_zh_home.jpg" width="32%" alt="首頁" />
    <img src="assets/screenshots/readme_zh_dynamics.jpg" width="32%" alt="動態" />
    <img src="assets/screenshots/readme_zh_mine.jpg" width="32%" alt="我的" />
</div>

<br/>

> **免責聲明。** PiliBabel 是**非官方的開源第三方**客戶端，**佮 bilibili / bilibili Inc. 無關係，嘛無受著認可抑是贊助**。所有的 API 攏是對官方公開的入口仔提著的；**付費內容無破解、嘛無解鎖**。請詳細看後壁的[免責聲明](#免責聲明)佮[開源協議](#開源協議)兩節。

## PiliBabel 是啥物？

PiliBabel 是一个**獨立、綴佇 [PiliNara](https://github.com/Starfallan/PiliNara) 頂懸的第三方分支**，伊繼承 PiliNara 所繼承的全部：

```
bilibili (官方公開 API)
        ▲
   PiliPala / PiliPalaX        — 上早的專案
        ▲
   PiliPlus                    — 猶閣咧維護的分支
        ▲
   PiliNara                    — PiliPlus 的分支（個人加的功能）
        ▲
   PiliBabel  ← 你佇遮          — PiliNara 的分支
```

PiliBabel 保留 PiliNara / PiliPlus **所有的功能**（請看後壁的[繼承功能清單](#繼承功能清單來自-pilinara--piliplus)），閣加怹無的**兩項關鍵功能**：

> **用 AI 翻譯介面佮內容** —— 規个應用程式（介面字、影片標題、UP 主名、評論、動態、搜揣，連咧走的彈幕）攏會用**你家己揀的言語**顯示出來。

而且對 1.0 版開始，**裝好就用**：翻譯模型是**內建**的。bilibili 共怹家己的翻譯模型 [Index-Translate](https://github.com/bilibili/Index-Translate) 開源，閣提供免費的公開入口仔。PiliBabel 預設就按呢設定好矣，所以裝好就會使翻譯 —— 免註冊、免 Key、免開錢。若你想欲用家己的模型，「自訂 API」彼條路嘛是一揤就會使。

> **掛耳機仔嘛袂落後** —— 用藍牙抑是有線耳機的時，聲袂閣較慢影片一步。官方應用程式做會著；PiliNara 佮 PiliPlus 預設做袂著。PiliBabel 這馬先問 mpv 的 **AudioTrack** —— 伊佮官方客戶端仝款，是真正**量**出來的音訊延遲 —— 毋是用干焦**臆**的 **OpenSL ES**。

## 主要功能

- **耳機的聲有對同。** 播放器這馬預設用 mpv 的 **AudioTrack** 後端（順序 `audiotrack,aaudio,opensles`），毋是用 **OpenSL ES**。AudioTrack 會報**量過的**輸出延遲 —— 伊讀真正播出去的影格數佮裝置的顯示時間戳 —— 官方 bilibili 應用程式佮 Android 家己的 `MediaSync` 就是按呢予聲佮影對同。OpenSL ES 干焦是**臆**的，所以藍牙耳機的聲的時鐘會走去，影就走到頭前。實測起來，落後的狀況差不多無去矣。順序若想欲換，隨時會使：設定 → 影片 → 音訊輸出裝置。

- **AI 翻譯，逐位攏有。** 導覽列、影片卡、詳細頁、評論、動態，閣有「我的」/「收藏」/「歷史」/「訊息」/「搜尋」攏有；全域處理蓋著**超過 ~1650 條介面字**，加減動態內容（標題、UP 主名、互動數字）。

- **兩个引擎，一个開關。** *內建*（預設）用 bilibili 官方模型 **Index-Translate-35B-A3B** 的免費入口仔 —— 免設定。*自訂 API* 保留進前的做法：任何 OpenAI 相容的 `/chat/completions` 入口，家己的 base URL / Key / 模型。AI 影片摘要佮 AI 翻譯是**完全分開**的入口佮設定，兩項攏囥佇仝一頁**「AI 功能」**。

- **兩種引擎，仝一份言語清單。** 目標言語的清單無分引擎 —— 揀佗一个引擎，看的是仝一份清單。伊共 bilibili 官方模型**支援的 151 種言語**佮**官方無的 6 種**（傳統華語、簡體佮傳統吳語、中國大陸佮台灣的閩南語、壯語）囥做伙。地區佮文字版本是**分開的項目**，無合做一个：摩洛哥 / 埃及 / 納吉德 / 黎凡特阿拉伯語逐个算一个，塞爾維亞語、烏茲別克語、烏爾都語的斯拉夫／拉丁、西里爾／拉丁嘛是按呢。

- **蓋的範圍講清楚。** 官方清單內面的言語，模型攏蓋會著。官方無的彼幾種 —— 傳統華語、簡體佮傳統吳語、中國大陸佮台灣的閩南語、壯語 —— 嘛囥佇清單內面閣加註記，予你隨知影：欲有較好的結果，可能著用家己的模型。

- **翻一遍就定去矣。** 每一條原文**干焦翻一遍**，結果囥佇本機，後擺開仝一个畫面**袂閣翻** —— 佮官方客戶端仝一个原則，予翻譯穩定、袂亂振動。

- **每一條評論攏有「原文 ⇄ 翻譯」開關**（是一个細細的圖示，毋是華語字）。`@標記 / [表情符號] / #主題# / 連結` 攏照原樣保留做完整的記號，**有連結的評論嘛會翻譯，而且連結猶原會使揤**。

- **彈幕翻譯** —— 佇播放器倒手爿的頂懸控制列有一个獨立開關，**預設是關的**，而且有一个確認視窗，彼个視窗的文字嘛會翻譯。開了後，佇播放位置的頭前會**一逝一逝（逐逝約 15 秒）**先翻譯，跳到中間嘛處理會著（毋是對頭開始），所以彈幕走出來的時，翻譯通常已經好矣。

- **思考模式開關**（`enable_thinking`），予你佇品質佮速度中間揀；設定頁閣有**「測試翻譯」**佮**清除快取**兩个掣。

- **換言語真緊**：分批請求 + 限制並行 + 永久快取；換言語的時，目前的畫面會強制重畫一遍，予你袂一直看著未翻譯的字。共 AI 翻譯關起來，規个介面就還原轉去原文，而且**完全袂發任何請求**。

- **頭一擺開起來有提示。** 頭一擺開應用程式的時，有一个英文視窗問你欲毋欲開翻譯。若應好，就會開翻譯、揀內建模型、開 AI 設定頁，隨問你欲佗一个言語 —— 按呢新用戶對裝好到有一个翻譯好的應用程式，兩揤爾爾。

- **全世界攏順的播放。** PiliBabel 揀 bilibili 的 `playurl` 照地理路線建議的海外節點（全球 **Akamai**、`mirror*ov`、`cn-hk-eq-bcache`），毋是硬縛佇中國大陸的節點（阿里雲／深圳）—— 所以中國大陸以外的用戶袂閣搪著「有聲無影」。CDN 嘛會使佇設定頁手動固定。

- **Material You 風的「主題佮色彩」頁。** 光／暗／綴系統用**三張會動的預覽卡**來揀 —— 逐張共真實介面的縮圖用彼个模式會用的色畫出來（「綴系統」彼張對角切開：光的疊佇暗的頂懸）。下跤閣有：**動態色彩**（佇支援的裝置提系統桌布的色彩）、**高對比的暗主題**（真正烏的背景，暗時較順目）、佮**播放器永遠暗色**。色彩的彼半爿保留 FlexScheme 全套 —— **19 種基本色**，閣有一个獨立的**「配色風格」**，決定基本色欲按怎生出所有的容器色，佮你揀佗一个基本色無關係。

- **LXGW WenKai 隨應用程式來。** 字體 **LXGW WenKai（霞鹜文楷）**是**內建而且預設**的 —— 一个燒烙、清清楚楚的華文字體，裝好就有，免去字體清單內面揣。伊會用在規个介面**佮**彈幕。你嘛會使換轉去系統字體、揀任何系統內底的字體，抑是家己匯入 `.ttf` / `.otf` / `.ttc`；進前明確揀過的字體，升級的時會保留。字重佮字大小照舊會使調。

## 離線音訊快取佮下載到本機（PiliBabel 獨有）

兩項 PiliNara / PiliPlus 無的功能 —— 兩項攏是欲予你真的共家己的媒體囥佇離線。

### 音訊快取（干焦快取音軌）

- **是音軌，毋是影片。** 「音訊快取」囥佇影片頁選單內面「影片快取」的下跤，聽影片頁的頂欄嘛有一个家己的音訊快取掣。
- **會使揀音質。** Hi-Res 無損、Dolby Atmos、192K、132K 抑是 64K —— 佮影片品質彼份清單仝款的選項。
- **照原本的容器，無轉檔。** 檔案照 CDN 送來的原樣寫落去：`m4a`、`mp3`、`flac`、`wav`、`aac` 抑是 `ogg`。
- **家己一个模組。** 快取頁分做「已快取影片」/「已快取音訊」，會記得你頂擺佇佗一个模組。
- 揤已快取音訊的項目，連鞭入去音訊播放器；會使一項一項刪，嘛會使幾項做一擺刪。

### 下載到本機資料夾

- **家己一个選單項。** 「下載到本機」佇影片頁選單內面是一个獨立的項，就佇「音訊快取」的下跤：應用程式內面的快取佮囥落本機資料夾是兩件無仝代誌。
- **下載影片抑是下載音訊。** 彼个項會先問你欲佗一个，才問品質（揀影片品質／音訊品質）。
- **你的資料夾，你作主。** 透過系統的檔案管理員揀任何資料夾（設定 → 「下載到本機資料夾」），隨時會使換抑是清掉。若猶未揀資料夾，檔案揀選器會隨開起來。
- **揣落來就會使播的檔案。** 影片是請求一个已經合起來的流（`fnval=1`），所以寫落去的是普通的 MP4，交予任何播放器攏會使 —— 免家己共兩條流接起來。
- **音訊保持原本的格式** —— 無轉檔，佮內部的快取完全仝款。
- 檔案用影片標題號名，袂共已經下載過的檔案蓋過去。

## 兩个翻譯引擎

| | 內建（預設） | 自訂 API |
|---|---|---|
| 模型 | bilibili **Index-Translate-35B-A3B** | 任何 OpenAI 相容的 |
| 入口仔 | `index-translate.bilibili.com/v1` | 你的 base URL |
| API Key | **免** | 你的 |
| 開銷 | 免費 | 照你的供應商 |
| 請求 | 一个請求一條 | 分批（一擺 ≤ 16 條） |
| 加言語 | — | 你的模型識的言語 |

**為啥物內建引擎是一條一个請求。** Index-Translate 是一个**專家**，伊的作者共呼叫做紀錄的是單項的模板（「共下面這段翻做 X，干焦輸出翻譯」）。所以佇彼个引擎頂懸，PiliBabel 是一條一个請求，毋是用自訂 API 彼套有編號清單佮 JSON 陣列的分批 prompt。彼个入口仔是免費的，用分批的輸出無啥通贏 —— 這是刻意的交換：加幾个請求，換來較少機會出錯。

**對 0.3.x 升級。** 你自訂 API 的設定 —— base URL、Key、模型 —— **攏照你原本輸入的保留**。只是預設引擎是內建模型，所以升級了後頭一擺開起來會佇免費的 bilibili 模型頂懸；開 *設定 → AI → AI 功能 → 翻譯引擎*，換轉去 *自訂 API* 就會隨轉去進前的設定。

## AI 介面翻譯是按怎運作的（技術細節）

這个 repo **無 i18n / ARB 彼層** —— 介面字是拍死佇華語內面的。PiliBabel 無共逐个 widget 重寫，是佇頂懸加一層薄薄的翻譯層：

1. **全域的搜揣包裝。** `lib/services/ui_translate/` 提供一个上層函式 `uiTx(String src)`。本來是 `Text('中文')` 的文字，變成 `Text(uiTx('中文'))`。一个**程式碼改寫腳本**共伊套佇規个專案（`tool/ui_translate_*.py`）—— 差不多 **223 个檔案 / ~1650+ 條** —— 自動共會拍死 `const` 的所在提掉（包含 `const X<T>(...)` 這種泛型佮 `const Positioned.fill(...)` 這種有點的號名，`static const` 的串列佮對照表改成 `static final`）。

2. **`GetxService` 核心**（`ui_translate_service.dart`）：
   - 一个**原文 → 譯文**的永久快取（用 GetStorage），所以每一條干焦翻一遍，後擺一直用；
   - `tx()` 先讀 `RxInt revision`，才判斷：關起來 → 還原原文；目標是**簡體華語（`zh-CN`）** → 直接還原原文，無發 API（bilibili 的內容大部份本來就是簡體華語）。其他目標 —— 包含傳統華語、粵語、吳語佮閩南語 —— 攏照你設定的引擎走；屬華語家族無代表免翻譯。紲落去就是對快取抑是入**排隊**；
   - 排隊的字由一个**工人池**處理，**一段一段照順序套用**（逐段轉來的部份會共 `revision` 加一，所以文字是漸漸換過去），結果**寫落去保存**（有節流）。批的大小佮並行數照引擎：內建模型**一个請求一條**，自訂 API **一擺 ≤ 16 條、上濟 10 條咧飛**。

3. **引擎的選擇。** `TranslateProvider`（`builtin` / `custom`）決定傳輸用佗一个 URL、Key 佮模型；其他的部份，兩種引擎共用仝一份程式碼佮仝一份言語清單，所以換引擎是一个設定爾爾，袂變成無仝的功能。

4. **傳輸**用仝一條經過驗證的**串流**管線，佮 AI 影片摘要仝款 —— `AiChatService.streamChat` → `{base}/chat/completions`，`stream: true`（相容干焦支援串流的閘道）—— 閣擴充予翻譯用**家己的** `apiUrl` / `apiKey` / `model` 佮 `enable_thinking` 開關。這个改變**向後相容**，所以影片摘要免改照舊會走。

5. **有替代字的字**用 `uiTxP(template, args)`：規句有 `{0}`/`{1}` 替代位的句子，用做一个完整的記號去翻譯（prompt 會要求模型共替代位留落來），才共值囥轉去 —— 按呢 `"共 {0} 條"` 這種字翻譯起來袂變形。

6. **言語表**（`app_language.dart`）：逐个 `AppLanguage` 有一个予人看的家己的名、一个 `toModel` 的 prompt 字（交代文字佮地區的慣例），閣有一个講伊敢是 bilibili 官方清單有蓋的。寫法規則（簡體佮傳統的差別、方言一致性的指示）是透過 prompt 到模型的，了後才由一个客戶端的確定性正規化步驟共走精的字改掉。

7. **評論**走 `uiTxComment(text, id)`，共 `@ / [表情符號] / #主題# / 連結` 當做完整的記號保留；有連結的格式化文字會翻譯，連結的辨識嘛留落來，逐个評論的 id 集合咧管「原文 ⇄ 翻譯」開關。

8. **彈幕**（`danmaku/view.dart`）：開關開了後，一个位置監聽器會一秒一秒行過 `[位置, 位置 + 15 秒]`，先共每一條彈幕的內容 `uiTx()` 起來，所以彈幕走出來的時就已經翻好；開關開起來會清掉閣重畫彼个畫布。

9. **儲存的 Key**：`uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`。**設定介面**：一个第一層的「AI 功能」頁（`lib/pages/setting/ui_translate/`），內面 AI 影片摘要佮 AI 翻譯各有獨立的區塊。

**全世界的 CDN（`VideoUtils.getCdnUrl`）。** 流的連結是有簽名的，改 URL 的 host 會予服務端用 403 拒絕 —— 所以播放永遠無改 host。PiliBabel 還原 bilibili 照 IP 發的彼个地理路線 URL，而且候選清單內面若有海外節點（`*.akamaized.net`、`mirror(cos|ali|hw)ov`、`cn-hk-eq-bcache`），就優先揀伊。下載的時陣，改 host 是安全的，所以閣較優先揀全球的 Akamai 節點，線若定去抑是拒絕接續下載，就換去下一条有簽名的候選。無處理的 P2P `/v/resource` 連結猶原走現有的 relay，避免 404。

**交換佮已知的限制。** 因為字是佇原位包起來，毋是抽去資源檔，所以一寡毋是 `Text` 的字參數佮一寡格式化的範圍猶是加減咧補。有一寡字**同時是程式的記號**（用 `==` 比、抑是當做 `简介` 這種頁籤名、抑是切換項的標籤）的，**刻意無**攏總包起來，才袂弄歹行為。彈幕翻譯是佇會當捲的畫布上盡量做：流若真密，你可能會看著一瞬間的原文，翻譯才到。翻譯需要網路；無網路，非華語的目標就袂生效。內建的入口仔是 bilibili 維護的免費公開服務；若有一日限制頻率抑是收起來，應用程式會共你講，你會使換去自訂 API。

## 建置佮驗證

應用程式用改過的 Flutter SDK 佮改過的 `material_ui` / `cupertino_ui` 套件，透過 `lib/scripts/patch.ps1` 佮 `lib/scripts/build.ps1` 建置（佮 PiliNara / PiliPlus 完全仝款）。GitHub Actions 逐擺 push 攏會做一个 **debug APK**（`.github/workflows/ui-translate-debug.yml`），**發 `v*` 的 tag 就會自動建置閣發佈 Android、Windows 佮 Linux 的產物**（`.github/workflows/release.yml`、`win_x64.yml`、`linux_x64.yml`）。

<br/>

## 平台支援
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

PiliBabel 佇 Releases 提供 **Android（APK）、Windows 佮 Linux** 的建置；這个分支這馬無包 iOS/Pad。

<br/>

## 下載

去 **Releases** 提建置，抑是 clone 落來家己建置。

### Arch Linux

感謝 [@nlsdt](https://github.com/nlsdt) 的打包（PiliNara 的 recipe 嘛搬會過 PiliBabel）。

```bash
sudo pacman -S pilinara      # 對 Arch Linux CN 的 repo
paru -S pilinara-bin         # 抑是對 AUR：pilinara-bin（現成的建置）/ pilinara（對原碼）
```

<br/>

## 繼承功能清單（來自 PiliNara / PiliPlus）

下跤全部是對 PiliNara 搬過來的（嘛所以是綴 PiliPlus 來的）；PiliBabel 佇頂懸加一層 AI 翻譯。

**介面佮各平台的適應**
- [x] 應用程式照平台改名，予幾个客戶端會使做伙蹛（PiliBabel 會使佮 PiliNara 做伙裝）
- [x] 修好 Flutter 佇小米 HyperOS 的迷你視窗的畫面（[#161086](https://github.com/flutter/flutter/issues/161086)，透過 [venera#467](https://github.com/venera-app/venera/pull/467)）；Android 的預測式轉去動畫
- [x] 「我的」頁卡的順序佮數量會使調；歷史頁卡的預覽佮「看後擺」的區塊
- [x] 側欄會自動開，開的闊度會使設；長揤／右鍵共圖囥落去；MD3E 風格大更新

**字體系統** —— 一个匯入池，照內容的雜湊去重，彈幕字體嘛併入仝一个池，`loadFontFromList` 支援 ttc，閣用雜湊做純 ASCII 的字體族名。

**播放、迷你視窗佮品質** —— 應用程式內面的迷你視窗（拖、改大細、SponsorBlock 跳過、系統 PIP 自動開、直播的救命控制列）、聲同時播、內建的音量到 200%、自訂的影片 CDN 網域佮地區節點揀選（有延遲測試）、半螢幕佮全螢幕有無仝的預設品質、向上滑鎖速度、平板鍵盤控制、直播 SuperChat 的時間標、直播的 heartbeat。

**字幕、AI 佮離線** —— 雙語字幕（第二字幕的樣式家己設）、AI 字幕分析（家己的 OpenAI 相容入口、照時間標跳、模板、存的對話、無字幕的時軟退）、匯出 WEBVTT/SRT、雙檢視的離線快取（有資料夾管理佮 metadata 保存）、下載匯出到 Android 公開的 Download 資料夾。

**彈幕佮封鎖** —— 改良的合併彈幕放大（[Pakku.js](https://github.com/xmcp/pakku.js) 的款式）、清單式的視覺 regex 封鎖（會使匯入匯出）、SponsorBlock 跳過兼入去彼段、用高斯核的「高能量」條。

**推薦／動態／評論的過濾** —— 照標題/作者/頻道的關鍵字、時長、觀看數、點讚比、有追蹤的作者例外、未授權佮付費的過濾、共同的白色名單、商業動態佮未授權動態、家己的佮作者釘頂的評論例外、App+Web 合流模式。

**動態、搜尋佮用戶資訊** —— 作者的家己筆記、佇 13 个所在共名換做筆記、逐層評論家己排序、搜尋的家己關鍵字過濾、b23.tv 短連結跳轉、「干焦付費」的標記、隱藏推薦理由的開關、顯示投幣的經驗。

**直播的改良** —— 粉絲牌的穿戴面板、DLNA 直播（優先 HLS）、SuperChat 的時間、迷你視窗的救命下控制列。

**系統整合佮桌頂** —— Windows SMTC、Linux MPRIS（`audio_service_mpris`）、重寫的音訊焦點處理。
<details>
<summary>PiliNara 原本的功能清單（華語，照原樣保留）</summary>

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

## 開源協議

PiliBabel is licensed under the **GNU General Public License v3.0 (GPL-3.0)** — the same license as PiliNara, PiliPlus and PiliPala. Because it is a derivative work, **PiliBabel must also be distributed under GPL-3.0**: you are free to use, study, share and modify it, provided you keep the same license, the copyright notices, and this license text. See [`LICENSE`](./LICENSE).

Third-party components (Flutter packages, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), etc.) remain under their own licenses.

The bundled **LXGW WenKai** typeface is licensed separately under the **SIL Open Font License 1.1**; its licence text ships inside the app as `assets/fonts/LXGWWenKai-OFL.txt`.

<br/>

## 致謝

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — bilibili's open-source translation model family, and the free public endpoint behind the built-in engine
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — the open-source Chinese typeface bundled with the app, under the SIL Open Font License 1.1
- and more
- Inspired by bilibili's official "AI interface translation".

## 註記

這份 README 是 AI 寫的，用詞佮文法可能會有疏誤。
