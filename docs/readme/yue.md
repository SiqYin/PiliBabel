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
