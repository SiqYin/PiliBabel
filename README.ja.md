<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>AI 翻訳機能を備えたサードパーティ製 Bilibili クライアント。</b></p>
    <p>Babel（バベル）—— 言語の壁を取り払い、誰もが自分の言語で bilibili を楽しめるように。</p>
    <p>中国の少数民族語 4 言語と中国語の方言 3 種の翻訳に対応しています。</p>
    <p>
      <a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <b>日本語</b>
    </p>
</div>

<div align="center">
    <img src="assets/screenshots/main_screen.png" width="96%" alt="home" />
</div>

<br/>

> **免責事項.** PiliBabel は**非公式・オープンソースのサードパーティ製**クライアントです。bilibili / bilibili 社とは**いかなる関係もなく、承認・協賛も受けていません**。すべての API は公式の公開エンドポイントから取得しており、**有料コンテンツの解錠やクラックは一切行いません**。詳しくは下記の[免責事項](#免責事項)と[ライセンス](#ライセンス)セクションをお読みください。

## PiliBabel とは？

PiliBabel は **[PiliNara](https://github.com/Starfallan/PiliNara) の上に構築された独立したサードパーティ製 fork** であり、PiliNara が受け継ぐものをすべて引き継いでいます：

```
bilibili（公式公開 API）
        ▲
   PiliPala / PiliPalaX        — 元プロジェクト
        ▲
   PiliPlus                    — 活発な fork
        ▲
   PiliNara                    — PiliPlus の fork（個人向け改変）
        ▲
   PiliBabel  ← ここ            — PiliNara の fork
```

PiliBabel は **PiliNara / PiliPlus の全機能**を保持し（下部の[継承機能一覧](#継承機能一覧pilinara--piliplus由来)参照）、さらに**上流クライアントにない目玉機能を一つ**追加しています：

> **AI インターフェース＆コンテンツ翻訳** —— アプリ全体（UI ラベル、動画タイトル、投稿者名、コメント、 dynamics、フィード、ライブの弾幕（danmaku）まで）を、**あなた**が選んだ言語で、**あなたが持ち込む** AI モデルで表示します。

アイデアは bilibili 公式の「AI インターフェース翻訳」をモデルにしていますが、完全に**あなた自身の** OpenAI 互換エンドポイントで動作します——ベンダーロックインなし、アプリ全体で機能し、多数の翻訳先言語に対応します。

## 主な特徴

- **あらゆる場所に AI 翻訳を。** ナビゲーションタブ、動画カード、詳細ページ、コメント、dynamics、そして「マイページ / Favorite / 履歴 / メッセージ / 検索」画面まで——グローバルな一括処理で**約 1,650 以上の UI 文字列**、加えて動的コンテンツ（タイトル、投稿者名、アクション数）をカバーします。
- **モデルは自分で用意。** 任意の OpenAI 互換エンドポイント（`/chat/completions`）に、あなたの base URL / API key / model を指定します。AI 動画要約と AI 翻訳は**完全に独立した**エンドポイントと設定を持ち、一つの「**AI 機能**」ページにまとまっています。
- **一度だけ翻訳、二度と同じものは訳さない。** 各原文は**ちょうど一度だけ**翻訳され、結果はローカルに永続化され、画面を開き直しても**再翻訳されません**——公式クライアントと同じ原理で、安定かつ予測可能な翻訳を提供します。
- **アプリの言語を選択。** デフォルトは簡体字中国語。約 35 言語から選べます——English、日本語、한국어、Français、Deutsch、Español、Italiano、Русский、ไทย、Tiếng Việt、Bahasa Melayu / Bahasa Indonesia、Filipino、Türkçe、العربية、עברית、བོད་སྐད་、Монгол хэл、ئۇيغۇرچە、Vahcuengh、広東語（簡体/繁体）、呉語、福建語（大陸/台湾）など。
- **コメント単位の「原文 ⇄ 翻訳」トグル**（漢字の単語ではなく小さなアイコン）。`@メンション / [絵文字] / #トピック# / リンク` はトークンとして保持され、**リンクを含むコメントも翻訳でき、リンクはクリック可能なまま維持**されます。
- **弾幕（danmaku）翻訳**——プレイヤー右上の操作列にある独立トグルで、**デフォルト OFF**、確認ダイアログ（その文言自体も翻訳）の後で有効化。有効にすると、再生位置の先約 **15 秒**分の弾幕を**バッチで事前翻訳**（途中でシークした場合も正しく処理、先頭からではない）するため、流れてくる頃には译文がほぼ準備できています。
- **思考モード切替**（`enable_thinking`）で品質と速度のバランスを調整、設定には**翻訳テスト**と**キャッシュ削除**ボタンも。
- **言語切替が速い**：バッチリクエスト（1 バッチ ≤ 16 文字列）に限定同時実行（≤ 10）と永続キャッシュを組み合わせ、逐次的に反映。言語を切り替えると現在の画面を一度強制リビルドし、未翻訳のまま表示されることがありません。
- **初回起動ガイド。** アプリを初めて開くと（英語の）ダイアログが表示され、AI 翻訳の使い方（**設定 → AI → AI インターフェース翻訳**）を説明し、そのページへ一键で飛べるショートカットを提供します。
- **世界中で再生がスムーズ。** 配信 URL は bilibili の IP ベース就近配信 playurl API から取得します。中国本土専用の **P2P / PCDN（mcdn）** エッジしか返されない場合、PiliBabel はそれを**グローバルの Akamai エッジ**へ書き換え、再生を本土（Aliyun / 深圳）ノードに固定しません——これにより中国本土以外での「音声が動き続け映像が止まる」カクつきが解消されます。（設定で CDN を手動指定することもできます。）

## AI インターフェース翻訳の仕組み（技術）

このリポジトリには **i18n / ARB のリソース層がありません**——UI 文字列はハードコードの中国語です。PiliBabel は全ウィジェットを書き直す代わりに、その上に薄い翻訳レイヤーを重ねます：

1. **グローバル検索ラッパ。** `lib/services/ui_translate/` が最上位関数 `uiTx(String src)` を公開します。かつて `Text('中文')` だった箇所は `Text(uiTx('中文'))` になります。**codemod** スクリプト（`tool/ui_translate_*.py`）でプロジェクト全体——約 **223 ファイル / 1,650 以上の文字列**——に一括適用し、`uiTx` の導入で無効になる `const` を自動除去（`const X<T>(...)` のようなジェネリクスや `const Positioned.fill(...)` のようなドット付き名、`static const` のリスト/マップ宣言を `static final` に変換することも含む）。
2. **`GetxService` コア**（`ui_translate_service.dart`）：
   - 永続的な**原文 → 訳文**キャッシュ（GetStorage）で、各文字列を一度だけ翻訳し永久に再利用；
   - `tx()` は最初に `RxInt revision` を読み、判断：無効なら原文を返す。翻訳先が中国語系**かつ**文字列が既に中文に見える（`_looksChinese()` は CJK 表意文字とラテン／仮名／ハングル／キリル／アラビア／ヘブライ／タイ文字を比較し、外国文字が約 25% 未満ならスキップ）なら原文を返す。それ以外はキャッシュから返すか**キューへ投入**；
   - キューは**ワーカープール**で処理し、**チャンク単位で逐次反映**（チャンクが返るたびに `revision` を上げ、译文が順次表示される。バッチ ≤ 16、同時 ≤ 10）、結果は**スロットル付きで永続化**。
3. **通信路**は AI 動画要約と同じ検証済みの**ストリーミング**チャネルを再利用——`AiChatService.streamChat` → `{base}/chat/completions`（`stream: true`、ストリーミングのみ対応のゲートウェイにも適合）——翻訳専用の `apiUrl` / `apiKey` / `model` と `enable_thinking` フラグを使えるよう拡張。**後方互換**で動画要約は従来どおり動作。
4. **可変を含む文**は `uiTxP(template, args)`：`{0}`/`{1}` プレースホルダ付きの文全体を一つの安定したキーとして翻訳（プロンプトで占位符保持を要求）し、後で値を埋め戻します。`共 {0} 条` 型の変数を含む文も壊れずに翻訳できます。
5. **言語テーブル**（`app_language.dart`）：各 `AppLanguage` は表示用の自名称と、書体系／地域の表記規範を符号化した `toModel` プロンプト文字列を持ち、これらの規範はプロンプト経由でのみモデルに届きます。
6. **コメント**は `uiTxComment(text, id)` を経由し、`@ / [絵文字] / #トピック# / リンク` を完全なトークンとして保持。リンクを含むリッチテキスト span も、リンク認識器を保ったまま翻訳され、コメント単位の id セットが「原文 ⇄ 訳文」トグルを駆動します。
7. **弾幕**（`danmaku/view.dart`）：トグル ON のとき位置リスナが毎秒 `[playhead, playhead + 15s]` を歩き、各弾幕内容に `uiTx()` をウォームアップして、画面上に流れる前に事前翻訳。有効化時は画面を消して再描画します。
8. **ストレージキー**：`uiTranslate{Enabled,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`。**設定 UI**：一段目の「AI 機能」ページ（`lib/pages/setting/ui_translate/`）に、AI 動画要約と AI 翻訳の独立ブロックを配置。

**グローバル CDN（`VideoUtils.getCdnUrl`）。** PiliBabel は bilibili の playurl がクライアント IP に応じて就近配信する URL を優先します（中国本土の固定ホストへ書き換えない）。手元に残るのが本土専用 P2P/PCDN（`mcdn`、`proxy-tf-*`）エッジのみの場合、ホストをグローバルの **Akamai** エッジ（`upos-hz-mirrorakam.akamaized.net`）へ書き換え、海外の視聴が中国専用ノードで停止しないようにします。生の `/v/resource` P2P リンクは 404 を避けるため既存のリレーに残します。

**設計上のトレードオフ／既知の制限。** 文字列をリソースへ抽出せずその場でラップしているため、一部の非 `Text` の文字列引数やリッチテキスト span は今も増分的に補完中です。**ロジックキー**として使われる文字列（`==` で比較、`简介` のようなタブ名、switch で比較される enum ラベル）は挙動を壊さないよう**意図的に**一括ラップしていません。弾幕翻訳はスクロールキャンバス上でのベストエフォートで、弾幕が極めて密集すると訳文が届くまで一瞬原文が見えることがあります。翻訳はネットワークと設定済みモデルが必要で、翻訳エンドポイント未設定なら非中国語の翻訳先は有効になりません。

## ビルド＆検証

本アプリは、パッチ済み Flutter SDK ＋ パッチ済み `material_ui` / `cupertino_ui` でビルドします（`lib/scripts/patch.ps1` と `lib/scripts/build.ps1`、PiliNara / PiliPlus とまったく同様）。GitHub Actions は push ごとに **debug APK** を生成（`.github/workflows/ui-translate-debug.yml`）し、**tag `v*` を押すと Android / Windows / Linux を自動ビルド＆リリース**します（`release.yml`、`win_x64.yml`、`linux_x64.yml`）。

<br/>

## 対応プラットフォーム
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

PiliBabel は Releases で **Android（APK）、Windows、Linux** ビルドを提供します。iOS/Pad は本フォークではまだパッケージしていません。

<br/>

## ダウンロード

**Releases** からビルドを入手するか、リポジトリを clone してローカルでビルドしてください。

### Arch Linux

パッケージングしていただいた [@nlsdt](https://github.com/nlsdt) 氏に感謝します（PiliNara のレシピは PiliBabel にも適用できます）。

```bash
sudo pacman -S pilinara      # Arch Linux 中国語（CN）リポジトリ経由
paru -S pilinara-bin         # または AUR：pilinara-bin（プリビルド）/ pilinara（ソース）
```

<br/>

## 継承機能一覧（PiliNara / PiliPlus 由来）

以下はすべて PiliNara（そして最終的に PiliPlus）から受け継いだもので、PiliBabel はその上に AI 翻訳レイヤーを追加しています。

**UI とプラットフォーム適応** — HyperOS 小窓での Flutter 描画修正と Android の予測的戻る操作、「マイページ」カードの並び/数のカスタム、ヒストリーカードのプレビューと「後で見る」、トリガー幅設定付きの自動サイドバー切替、長押し/右クリックでの画像コピー、MD3E への大規模刷新。

**フォントシステム** — 内容ハッシュで重複排除する統一インポートプール、弾幕フォントの同一プール統合、`loadFontFromList` による ttc 対応、純 ASCII ハッシュのファミリ名。

**再生・小窓・画質** — アプリ内小窓（ドラッグ、リサイズ、SponsorBlock スキップ、自動でシステム PIP、ライブ自救バー）、他アプリとの同時音声再生、アプリ内音量を最大 200%、動画 CDN ドメインと地域ノード選択（遅延テスト付き）、半画面/全画面それぞれの既定画質、上スワイプで倍速ロック、タブレットのキーボード操作、ライブ SuperChat のタイムスタンプ、親密度を積むライブハートビート。

**字幕・AI・オフライン** — 副字幕スタイル付きの二言語字幕、AI 字幕解析（OpenAI 互換エンドポイント、タイムスタンプジャンプ、テンプレート、会話の永続化、字幕なし時の軟性フォールバック）、WEBVTT/SRT エクスポート、フォルダ管理とメタデータ永続化付きのオフラインキャッシュ二ビュー、公開 Download フォルダへのエクスポート（Android のみ）。

**弾幕とブロック** — 強化されたマージ弾幕の拡大（[Pakku.js](https://github.com/xmcp/pakku.js) 風）、インポート/エクスポート付きリスト型視覚正規表現ブロック、SponsorBlock の区間シークスキップ、ガウシアンカーネル式ハイライト進捗バー。

**おすすめ / dynamics / コメント フィルタ** — タイトル/投稿者/チャンネルキーワード、尺、再生数、高評価率、既読投稿者の除外、無権/充電専用フィルタ、共有ホワイトリスト、物販/無権 dynamics、投稿者本人コメントと固定コメントの除外、App+Web 統合フィード。

**dynamics・検索・ユーザー情報** — 投稿者へのカスタムメモ、13 箇所の名前スロットに及ぶメモによるニックネーム置換、スレッド内コメントの独立ソート、ローカルキーワード検索フィルタ、b23.tv 短縮リンクジャンプ、充電専用バッジ、推薦理由の非表示トグル、コイン経験値表示。

**ライブ強化** — ファンメダルの着用パネル、HLS を優先する DLNA キャスト、SuperChat の時刻表示、自救用の小窓下部コントロールバー。

**システム統合とデスクトップ** — Windows SMTC、Linux MPRIS（`audio_service_mpris`）、音声フォーカス処理のリファクタ。

<details>
<summary>完全な元の機能一覧（PiliNara 原文、クリックで展開）</summary>

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

PiliBabel は個人の興味で作られたプロジェクトで、**学習とテストのみ**を目的としています。ダウンロード後 **24 時間以内**に削除してください。

- PiliBabel は**非公式のサードパーティ製**クライアントであり、bilibili と**いかなる関係もなく、承認や協賛も受けていません**。
- すべての API は公式の公開エンドポイントから取得しており、**クラック・権限越え・有料制限の回避コンテンツは一切提供しません**。
- **AI 翻訳は完全にユーザー自身のサードパーティ モデルエンドポイントで動作します。** 翻訳品質と法令遵守は、ユーザーとその選択したモデル提供事業者の責任です。本プロジェクトは**モデルも API キーもホストしません**。
- 著作権と bilibili の利用規約を尊重し、責任を持ってご利用ください。

原作者および上流作者のオープンソースへの無私の尽力に敬意を表します：
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — PiliBabel の直接の上位プロジェクト

もしコンテンツがあなたの権利を侵害している場合は、削除についてご連絡ください。

<br/>

## ライセンス

PiliBabel は **GNU 一般公衆化使用ライセンス v3.0（GPL-3.0）** のもとで提供されます——PiliNara、PiliPlus、PiliPala と同じライセンスです。派生作品であるため、**PiliBabel も GPL-3.0 で配布する必要があります**：同じライセンス、著作権表示、本文を保持する限り、自由に使用・研究・共有・改変できます。[`LICENSE`](./LICENSE) 参照。

サードパーティ製コンポーネント（Flutter パッケージ、[`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect)、[`media-kit`](https://github.com/media-kit/media-kit)、[`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer)、[`dio`](https://pub.dev/packages/dio) など）はそれぞれのライセンスのままです。

<br/>

## 謝辞

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- など
- bilibili 公式の「AI インターフェース翻訳」に触発されました。

<br/>

## Star History

<a href="https://star-history.dera.page/#SiqYin/PiliBabel">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://star-history.dera.page/svg?repos=SiqYin/PiliBabel&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://star-history.dera.page/svg?repos=SiqYin/PiliBabel" />
   <img alt="Star History Chart" src="https://star-history.dera.page/svg?repos=SiqYin/PiliBabel" />
 </picture>
</a>
