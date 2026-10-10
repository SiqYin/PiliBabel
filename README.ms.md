<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Klien Bilibili pihak ketiga dengan terjemahan AI.</b></p>
    <p>Babel — meruntuhkan tembok bahasa, supaya setiap orang boleh menikmati bilibili dalam bahasanya sendiri.</p>
    <p>Merangkumi terjemahan 4 bahasa kaum minoriti etnik di China dan 3 dialek Cina.</p>
    <p>Terjemahan berfungsi sebaik sahaja dipasang, menggunakan model percuma bilibili — tanpa perlu kunci API.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <b>Bahasa Melayu</b> · <a href="README.id.md">Bahasa Indonesia</a></p>
</div>
<!-- lang-switch:end -->

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
