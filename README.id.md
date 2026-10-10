<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Klien Bilibili pihak ketiga dengan terjemahan AI.</b></p>
    <p>Babel — meruntuhkan dinding bahasa, agar setiap orang dapat menikmati bilibili dalam bahasanya sendiri.</p>
    <p>Mencakup terjemahan 4 bahasa minoritas etnis di Tiongkok dan 3 dialek Tionghoa.</p>
    <p>Terjemahan langsung berfungsi begitu dipasang, memakai model gratis bilibili — tanpa perlu kunci API.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <b>Bahasa Indonesia</b></p>
</div>
<!-- lang-switch:end -->

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
