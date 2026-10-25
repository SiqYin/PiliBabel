<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Isang third-party na Bilibili client na may pagsasaling pinapagana ng AI.</b></p>
    <p>Babel — binabasag ang hadlang ng wika, upang matamasa ng lahat ang bilibili sa sariling wika.</p>
    <p>Pinagsasama ang opisyal na imbentaryo ng 151 wika ng bilibili kasama ang 6 pang wika na hindi nito saklaw - Traditional Chinese, Simplified at Traditional na Wu, mainland at Taiwan Hokkien, at Zhuang.</p>
    <p>Gumagana agad ang pagsasalin sa sariling libreng modelo ng bilibili — walang kailangang API key.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.nan.md">台語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.mn.md">Монгол</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.pt.md">Português</a> · <a href="README.bn.md">বাংলা</a> · <a href="README.th.md">ไทย</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.it.md">Italiano</a> · <a href="README.fa.md">فارسی</a> · <b>Filipino</b> · <a href="README.ur.md">اردو</a> · <a href="README.mr.md">मराठी</a> · <a href="README.te.md">తెలుగు</a> · <a href="README.ta.md">தமிழ்</a> · <a href="README.pa.md">ਪੰਜਾਬੀ</a> · <a href="README.gu.md">ગુજરાતી</a> · <a href="README.ha.md">Hausa</a> · <a href="README.sw.md">Kiswahili</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.my.md">မြန်မာ</a> · <a href="README.pl.md">Polski</a> · <a href="README.is.md">Íslenska</a> · <a href="README.nb.md">Norsk</a> · <a href="README.fi.md">Suomi</a> · <a href="README.sv.md">Svenska</a> · <a href="README.da.md">Dansk</a> · <a href="README.be.md">Беларуская</a> · <a href="README.ug.md">ئۇيغۇرچە</a> · <a href="README.kk.md">Қазақша</a> · <a href="README.bo.md">བོད་ཡིག</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Home" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dynamics" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Akin" />
</div>

<br/>

> **Pagtatatwa.** Ang PiliBabel ay isang **hindi opisyal, open-source, third-party** na client. Ito ay **hindi kaugnay, hindi inendorso, at hindi sponsored ng** bilibili / bilibili Inc. Kinokolekta ang bawat API mula sa mga opisyal na pampublikong endpoint; **walang binubuksan o cinacrack na bayad na nilalaman**. Pakibasa ang buong mga seksyon ng [Pagtatatwa](#pagtatatwa) at [Lisensya](#lisensya).

## Ano ang PiliBabel?

Ang PiliBabel ay isang **independenteng third-party fork na binuo sa ibabaw ng [PiliNara](https://github.com/Starfallan/PiliNara)**, at namamana nito ang lahat ng minana ng PiliNara:

```
bilibili (opisyal na pampublikong API)
        ▲
   PiliPala / PiliPalaX        — ang orihinal na proyekto
        ▲
   PiliPlus                    — aktibong fork
        ▲
   PiliNara                    — fork ng PiliPlus (mga personal na tweak)
        ▲
   PiliBabel  ← nandito ka     — fork ng PiliNara
```

Pinapanatili ng PiliBabel ang **bawat tampok ng PiliNara / PiliPlus** (tingnan ang [talaan ng namana na tampok](#talaan-ng-namana-na-tampok-mula-sa-pilinara--piliplus) malapit sa ibaba) at nagdaragdag ng **dalawang pangunahing kakayahan na wala ang mga upstream na client**:

> **Pagsasalin ng interface at nilalaman ng AI** — ang buong app (mga label ng UI, pamagat ng video, pangalan ng UP, komento, dynamics, feed, at maging ang live na danmaku) ay nire-render sa wikang pinili **mo**.

At mula noong 1.0, ginagawa niya ito **agad pagkabukas ng kahon**: ang modelong pagsasalin ay **nakabuilt-in na**. Inopen-source ng bilibili ang sarili nitong pamilya ng modelo ng pagsasalin, ang [Index-Translate](https://github.com/bilibili/Index-Translate), at naghahatid nito mula sa isang libreng pampublikong endpoint. Dumarating ang PiliBabel na nakaturo dito, kaya gumagana ang pagsasalin sa mismong sandali ng pag-install mo ng app — walang sign-up, walang key, walang bayad. Kung mas gusto mong gamitin ang sarili mong modelo, nandoon pa rin ang daan ng sariling API, isang tap lang ang layo.

> **Audio ng headphone na talagang nananatiling naka-sync** — sa Bluetooth o wired na headphone, hindi na nauunahan ng tunog ang larawan. Tama ang ginagawa nito ng opisyal na app; hindi ito magawa ng PiliNara at PiliPlus sa default na anyo. Hinihingi na ngayon ng PiliBabel sa mpv ang **AudioTrack** muna, na *sinusukat* ang latency ng audio output nang pareho sa opisyal na client, sa halip na **OpenSL ES**, na nagtatantya lamang nito.

## Pangunahing mga tampok

- **Naka-sync na audio ng headphone.** Gumagamit na ngayon ang player ng **AudioTrack** backend ng mpv bilang default (ang order na `audiotrack,aaudio,opensles`) sa halip na **OpenSL ES**. Nag-uulat ang AudioTrack ng *sinukat* na output latency — binabasa nito ang bilang ng na-play na frame at ang presentation timestamp ng device — na eksaktong paraan ng pagkakasama ng larawan at tunog ng opisyal na app ng bilibili at ng sariling `MediaSync` ng Android. Nagtatantya lamang ang OpenSL ES, kaya sa mga Bluetooth na headphone, nag-drift ang orasan ng audio at naipapakita nang maaga ang larawan. Sa pagsubok, halos wala na ang lag. Maaari itong muling ayusin anumang oras sa Settings → Video → Audio output device.

- **Pagsasalin ng AI, kahit saan.** Mga navigation tab, card ng video, pahina ng detalye, komento, dynamics, at ang mga pahina ng Mine / Favorites / History / Messages / Search — isang pangkalahatang sweep ang sumasaklaw sa **~1,650+ na string ng UI**, pati na ang dinamikong nilalaman (mga pamagat, pangalan ng may-akda, bilang ng aksyon).
- **Dalawang engine, isang switch.** Ang *Built-in* (default) ay gumagamit ng opisyal at libreng endpoint ng bilibili na **Index-Translate-35B-A3B** — walang kailangang i-configure. Ang *Own API* ay pinapanatili ang dating ugali: ituro ito sa alinmang OpenAI-compatible na `/chat/completions` endpoint gamit ang sarili mong base URL / key / modelo. Ang tampok na AI video summary at ang tampok na AI translation ay mayroon pa rin ng **ganap na magkakahiwalay** na mga endpoint at setting, na parehong nakatira sa iisang pahina ng **"AI features"**.
- **Isang listahan ng wika, parehong engine.** Hindi nahahati ayon sa engine ang listahan ng target na wika — ang parehong listahan ang inaalok anuman ang engine na piliin mo. Pinagsasama nito ang **151 wika** ng opisyal na modelo ng bilibili kasama ang **6 pang hindi nito saklaw** — Traditional Chinese, Simplified at Traditional na Wu, mainland at Taiwan Hokkien, at Zhuang. Ang mga rehiyonal at script na variant ay pinapanatiling **hiwalay na entries** sa halip na pagsamahin — ang Moroccan / Egyptian / Najdi / Levantine Arabic ay bawat isa may sariling pagpipilian, gayundin ang Cyrillic-kumpara-Latin na Serbian, Uzbek at Urdu.
- **Matapat tungkol sa saklaw.** Ang mga wika sa loob ng opisyal na imbentaryo ay sakop ng modelo ng bilibili. Ang mga kaunti lang sa labas nito — Traditional Chinese, Simplified at Traditional na Wu, mainland at Taiwan Hokkien at Zhuang — ay lumalabas pa rin sa listahan, minarkahang ganoon, para alam mo agad na maaaring kailanganin ng mas magandang resulta ang sarili mong modelo.
- **Isang beses magsalin, ayos na magpakailanman.** Ang bawat source string ay isinasalin **eksaktong isang beses**; ang resulta ay naka-persist nang lokal at **hindi na kailanman isasalin muli** kapag binuksan mo muli ang isang screen — parehong prinsipyo ng opisyal na client, para sa matatag at maasahang mga pagsasalin.
- **Per-comment na Original ⇄ Translation toggle** (isang maliit na icon, hindi isang salitang Chinese). Ang `@mentions / [emoji] / #topics# / links` ay pinapanatili bilang token, at **ang mga komentong may hyperlink ay isinasalin pa rin habang nakaklikable ang link**.
- **Pagsasalin ng danmaku (弹幕)** — isang hiwalay na toggle sa itaas-kanang control row ng player, **naka-off bilang default** at naka-lock sa likod ng isang confirmation na ang mismong text ay isinalin. Kapag pinagana, ang mga danmaku sa unahan ng playhead ay pre-translated sa mga **batch na ~15 segundo** (ang seek sa gitna ay tama ang pagkakasagot, hindi mula sa simula), kaya kadalasang handa na ang pagsasalin sa pagpasok nito sa screen.
- **Thinking-mode switch** (`enable_thinking`) para sa quality-vs-speed, bukod pa ang mga button na **"test translation"** at **clear-cache** sa mga setting.
- **Mabilis na paglipat ng wika**: mga batched na request na may limitadong concurrency laban sa isang persistent na cache; ang paglipat ng wika ay minsang pinipilit muling itayo ang kasalukuyang screen, para hindi ka natitigil sa pagtitig sa hindi isinalin na text. Ang pag-off ng AI translation ay ibinabalik ang buong UI sa orihinal na text at hindi nagpapadala kahit isang request.
- **Onboarding sa unang pagbukas.** Sa unang pagbukas mo ng app, nag-aalok ang isang English na dialog na i-on ang pagsasalin. Ang pagtanggap nito ay pinapagana ang pagsasalin, pinipili ang built-in na modelo, binubuksan ang pahina ng AI setting at agad nagtatanong kung anong wika ang gusto mo — kaya mula sa install hanggang sa naisalin na app, dalawang tap lang ang kailangan ng bagong user.
- **Playback na gumagana sa buong mundo.** Pinipili ng PiliBabel ang overseas edge (global na **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) na inaalok na ng geo-routed na `playurl` ng bilibili, sa halip na i-pin ka sa isang mainland (Aliyun/Shenzhen) na node — kaya ang mga user sa labas ng mainland China ay hindi na natitigil ("tumutuloy ang audio, na-freeze ang video"). Maaari mo pa ring i-pin nang manu-mano ang isang CDN sa Settings.
- **Isang pahina ng "Theme & Colour", estilo ng Material You.** Ang Light / dark / follow-system ay pinipili mula sa **tatlong live na preview card** — bawat isa ay nagre-render ng miniatyura ng tunay na interface sa mismong mga kulay na iiral ng mode na iyon (ang "follow system" na card ay hiwalay nang pahilis, light sa ibabaw ng dark). Sa ilalim ng mga ito: **dynamic colour** (kinuha sa system wallpaper kung sinusuportahan ng device), **high-contrast dark** (tunay na itim na mga surface, mas madali sa mata sa gabi) at **always-dark player**. Ang kalahati ng kulay ay pinapanatili ang buong palette na FlexScheme — **19 seed colour** pati ang hiwalay na **"palette style"** na nagdedesisyon kung paano hinuhugot ang bawat kulay ng container mula sa seed, nang hiwalay sa kung aling seed ang piliin mo.
- **Kasama ng app ang LXGW WenKai.** Ang typeface na **LXGW WenKai (霞鹜文楷)** ay **nakabundle at nakatakdang default** — isang mainit-init, lubos na nababasang Chinese font na pag-aari mo na sa mismong pag-install, sa halip na maghanap ng isa sa isang picker. Nag-apply ito sa buong interface *at* sa danmaku. Maaari ka pa ring bumalik sa system font, pumili ng alinmang naka-install na system font, o i-import ang sarili mong `.ttf` / `.otf` / `.ttc`; ang font na malinaw mong napili noon ay pinapanatili sa kabila ng upgrade. Ang weight at size ay nananatiling adjustable gaya ng dati.

## Offline na audio caching at pag-download sa lokal na folder (tanging sa PiliBabel)

Dalawang kakayahang wala sa upstream na PiliNara / PiliPlus — parehong naglalayong talagang mabigyan ka ng pagmamay-ari ng iyong media nang offline.

### I-cache ang audio (offline cache na audio lamang)

- **Ang track, hindi ang video.** Nakalagay ang *Cache audio* na entry sa ilalim ng *Cache video* sa menu ng pahina ng video, bukod pa ang dedicated na cache-audio button sa itaas na bar ng listen-video page.
- **Piliin ang quality tier.** Hi-Res lossless, Dolby Atmos, 192K, 132K o 64K — ang parehong preset na listahang ginagamit ng video quality picker.
- **Orihinal na container, walang transcoding.** Ang file ay sinusulat eksaktong kung paano ito inihahatid ng CDN: `m4a`, `mp3`, `flac`, `wav`, `aac` o `ogg`.
- **Sariling module.** Nahahati ang cache page sa *Cached videos* / *Cached audio* at naalala nito kung saang module ka huling nandoon.
- Ang pag-tap sa isang naka-cache na audio ay bumubukas agad ng audio player; ang mga item ay nabubura nang isa-isa o nang maramihan.

### I-download sa lokal na folder

- **Sariling menu entry.** Ang *Download to local folder* ay hiwalay na entry sa menu ng pahina ng video, nasa ilalim lang ng *Cache audio* — ang pag-cache sa loob ng app at ang pag-save sa isang folder ay dalawang magkaibang aksyon.
- **I-download ang video o i-download ang audio.** Nagtatanong muna ang entry kung alin, pagkatapos ay nagtatanong ng quality tier (video quality / audio quality picker).
- **Ang folder mo, ang patakaran mo.** Pumili ng alinmang folder sa pamamagitan ng system file manager (Settings → *Download to local folder*), at baguhin o burahin ito anumang oras mo nais. Kung hindi ka pa nakakapili, bubukas agad ang folder picker.
- **Diretsong playable na mga file.** Ang video ay kinukuha bilang isang solong muxed stream (`fnval=1`), kaya ang natitik sa disk ay isang simpleng MP4 na maibibigay mo sa alinmang player — walang kasamang sidecar stream na kailangang pagsamahin.
- **Pinapanatili ng audio ang orihinal nitong format** — walang transcoding, eksakto gaya ng in-app cache.
- Ang mga file ay pinangangalanan ayon sa pamagat ng video at hindi kailanman nag-o-overwrite ng umiiral na download.

## Ang dalawang translation engine

| | Built-in (default) | Own API |
|---|---|---|
| Modelo | bilibili **Index-Translate-35B-A3B** | kahit ano na OpenAI-compatible |
| Endpoint | `index-translate.bilibili.com/v1` | sarili mong base URL |
| API key | **hindi kailangan** | sa iyo |
| Gastos | libre | kahit anong singilin ng provider mo |
| Mga request | isang string kada request | naka-batch (≤ 16 kada request) |
| Karagdagang mga wika | — | alinmang wika na alam ng modelo mo |

**Bakit isang string kada request para sa built-in na engine.** Espesyalista sa pagsasalin ang Index-Translate, at ang calling convention na naidokumento ng mga may-akda nito ay isang single-item na template ("isalin ang sumusunod na text sa X, i-output lamang ang pagsasalin"). Kaya nagpapadala ang PiliBabel ng isang string kada request sa engine na ito sa halip na numbered-list/JSON-array na batch prompt na ginagamit nito sa mga own-API na setup. Libre ang endpoint, kaya walang makukuha sa pagtaya sa batch output — ito ay isang sadyang pakikipagpalit ng ilang karagdagang request para sa mas kaunting paraan ng pagkabigo.

**Nag-a-upgrade mula sa 0.3.x.** Ang mga setting ng sarili mong API — base URL, key at modelo — ay **iniiwanang eksakto gaya ng pagkaka-configure mo**. Ang pagpili ng engine ay magde-default na lang sa built-in na modelo, kaya sa unang pagbukas pagkatapos ng upgrade, nasa libreng modelo ng bilibili ka; buksan ang *Settings → AI → AI features → translation engine* at ibalik sa *Own API* para agad makabalik sa dating setup mo.

## Paano gumagana ang AI interface translation (teknikal)

Walang **i18n / ARB resource layer** ang repositoryo — hard-coded na Chinese ang mga UI string. Sa halip na isulat muli ang bawat widget, nagdaragdag ang PiliBabel ng isang manipis na translation layer sa ibabaw:

1. **Isang global na lookup wrapper.** Inihahayag ng `lib/services/ui_translate/` ang isang top-level na `uiTx(String src)`. Ang widget text na dating `Text('中文')` ay nagiging `Text(uiTx('中文'))`. Isang scripted na **codemod** ang nag-apply nito sa buong proyekto (`tool/ui_translate_*.py`) — humigit-kumulang **223 file / ~1,650+ string** — kusang tinatanggal ang ngayon-ay-invalid na `const` keyword kung kinakailangan (kabilang ang mga generic gaya ng `const X<T>(...)` at mga dotted name gaya ng `const Positioned.fill(...)`, at ginagawang `static final` ang mga `static const` na list/map declaration).
2. **Isang `GetxService` core** (`ui_translate_service.dart`):
   - isang persistent na **source → translation** cache (suportado ng GetStorage), kaya ang bawat string ay isinasalin nang isang beses at ginagamit magpakailanman;
   - binabasa muna ng `tx()` ang isang `RxInt revision`, pagkatapos magdedesisyon: kung disabled → ibalik ang orihinal; kung ang target ay **Simplified Chinese (`zh-CN`)**, ibalik ang orihinal nang walang API request (pangingibabaw na Simplified Chinese ang source content ng Bilibili). Ang bawat iba pang target — kabilang ang Traditional Chinese, Cantonese, Wu/Shanghainese, at Hokkien/Min Nan — ay dumadaan sa naka-configure na engine; ang pagiging miyembro lang ng Chinese-family ay hindi lumilipat sa pagsasalin. Pagkatapos ay i-serve mula sa cache o **i-enqueue**;
   - ang mga na-enqueue na string ay fini-flush ng isang **worker pool** na may **per-chunk incremental apply** (ang bawat nagbalik na chunk ay nagtaas ng `revision` para unti-unting nag-a-update ang text), at ang mga resulta ay pine-persist (throttled). Ang batch size at concurrency ay sumusunod sa engine: **1 kada request** sa built-in na modelo, **≤ 16 na may ≤ 10 in flight** sa sarili mong API.
3. **Pagre-resolve ng engine.** Ang `TranslateProvider` (`builtin` / `custom`) ang nagdedesisyon kung aling URL, key at modelo ang gagamitin ng transport; ang dalawang engine ay kung hindi ay nagbabahagi ng isang code path at isang listahan ng wika, kaya ang paglipat ng engine ay isang setting lamang at hindi kailanman ibang set ng tampok.
4. **Ang transport** ay muling gumagamit ng parehong beripikadong **streaming** channel ng AI video summary — `AiChatService.streamChat` → `{base}/chat/completions` na may `stream: true` (compatible sa mga gateway na streaming lang ang sinusuportahan) — pina-extend para makagamit ang pagsasalin ng **sarili nitong** `apiUrl` / `apiKey` / `model` at ng isang `enable_thinking` flag. **Backward-compatible** ang pagbabago, kaya patuloy na gumagana nang hindi nagbabago ang video summary.
5. **Ang mga interpolated na pangungusap** ay gumagamit ng `uiTxP(template, args)`: ang isang buong pangungusap na may `{0}`/`{1}` placeholder ay isinasalin bilang isang matatag na key (hinahingi ng prompt sa modelo na panatilihin ang mga placeholder), pagkatapos ay isinasubstitut ang mga halaga — kaya ang mga string na gaya ng `"共 {0} 条"` ay naisasalin nang hindi sinusira ang mga dinamikong bahagi.
6. **Language table** (`app_language.dart`): ang bawat `AppLanguage` ay may dalang display autonym, isang `toModel` prompt string na nag-e-encode ng mga convention ng script/rehiyon, at isang flag kung sakop ito ng opisyal na imbentaryo ng bilibili. Ang mga patakaran ng script (Simplified kumpara Traditional, at ang mga instruction ng dialect-consistency) ay umaabot sa modelo lamang sa pamamagitan ng prompt, at isang deterministic na normalisation pass sa client ang nag-aayos ng mga ligaw na glyph pagkatapos.
7. **Ang mga komento** ay dumadaan sa `uiTxComment(text, id)`, na pinapanatiling buo ang `@ / [emoji] / #topic# / link` bilang token; isinasalin ang mga rich-text span na may link habang nakapreserba ang link recognizer, at isang per-comment na id set ang nagpapatakbo ng Original ⇄ Translation toggle.
8. **Danmaku** (`danmaku/view.dart`): kapag naka-on ang toggle nito, isang position listener ang naglalakad sa `[playhead, playhead + 15s]` isang segundo nang isang segundo at pinapa-init ang `uiTx()` sa nilalaman ng bawat danmaku, para pa-translate na ang mga item bago dumating sa screen; ang pag-enable nito ay naglilinis at nagre-repaint ng canvas.
9. **Storage keys**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Settings UI**: isang solong first-level na pahina ng "AI features" (`lib/pages/setting/ui_translate/`) na may mga hiwalay na block para sa AI video summary at AI translation.

**Worldwide CDN (`VideoUtils.getCdnUrl`).** Naka-sign ang mga stream URL, at ang pag-rewrite ng host ng isang URL ay nagdudulot ng pagtanggi nito na may 403 — kaya hindi kailanman nag-rewrite ng host ang playback. Ibinabalik ng PiliBabel ang geo-routed na URL na ibinibigay ng bilibili sa IP ng client, at kapag ang candidate list ay mayroon nang overseas edge (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`), iyon ang mas pinipili. Ang mga download, kung saan ligtas ang host swap, ay bukod pang mas pinipili ang global na Akamai edge at umiikot sa susunod na naka-sign na candidate kapag nag-stall ang linya o tumanggi sa resume. Ang mga raw na `/v/resource` P2P link ay bumabalik pa rin sa umiiral na relay para iwasan ang mga 404.

**Mga design trade-off / kilalang limitasyon.** Dahil ang mga string ay binabalot sa mismong lugar sa halip na i-extract sa mga resource, may ilang non-`Text` na string parameter at ilang rich-text span na unti-unting pinupunan pa lang. Ang mga string na nagsisilbing **logic key** (pinagbibigyang-alam ng `==`, ginagamit bilang mga pangalan ng tab gaya ng `简介`, o mga enum label na ginagamit sa mga switch) ay sadyang **hindi** pinapabalot nang blanket, upang hindi masira ang ugali. Best-effort ang pagsasalin ng danmaku sa isang nag-s-scroll na canvas — sa napakadense na danmaku, maaari mong makita nang sandali ang orihinal bago dumating ang pagsasalin. Kailangan ng network ang pagsasalin; kung wala, ang mga non-Chinese na target ay hindi lang magkakaroon ng bisa. Ang built-in na endpoint ay isang libreng pampublikong serbisyo na pinapatakbo ng bilibili — kapag ito ay na-rate-limit o hindi available, sasabihin sa iyo ng app at maaari kang lumipat sa sarili mong API.

## Build at pag-verify

Ang app ay binubuo gamit ang isang patched na Flutter SDK at mga patched na package na `material_ui` / `cupertino_ui` sa pamamagitan ng `lib/scripts/patch.ps1` at `lib/scripts/build.ps1` (eksakto gaya ng PiliNara / PiliPlus). Naglalabas ang GitHub Actions ng isang **debug APK** sa bawat push (`.github/workflows/ui-translate-debug.yml`), at **ang pag-publish ng tag na `v*` ay kusang nagbu-build at nagre-release ng Android, Windows at Linux** na mga artifact (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Mga Platform
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

Nagbibigay ang PiliBabel ng mga build na **Android (APK), Windows at Linux** mula sa Releases; hindi pa naka-package ang iOS/Pad sa fork na ito.

<br/>

## Download

Kunin ang isang build mula sa **Releases**, o i-clone ang repo at i-build ito nang lokal.

### Arch Linux

Salamat kay [@nlsdt](https://github.com/nlsdt) sa packaging (dala-dala ng PiliNara recipe sa PiliBabel).

```bash
sudo pacman -S pilinara      # sa pamamagitan ng Arch Linux CN repository
paru -S pilinara-bin         # o sa pamamagitan ng AUR: pilinara-bin (prebuilt) / pilinara (source)
```

<br/>

## Talaan ng namana na tampok (mula sa PiliNara / PiliPlus)

Ang lahat ng nasa ibaba ay dala-dala mula sa PiliNara (at, sa pagpapaabot, mula sa PiliPlus); ang PiliBabel ay nagdaragdag ng AI translation layer sa ibabaw.

**UI at platform adaptation**
- [x] Pinapalitan ang pangalan ng app ayon sa platform para magkasabay ang maraming client (kasama ng PiliNara nai-install ang PiliBabel)
- [x] Naayos na Flutter rendering sa ilalim ng Xiaomi HyperOS mini-window ([#161086](https://github.com/flutter/flutter/issues/161086), sa pamamagitan ng [venera#467](https://github.com/venera-app/venera/pull/467)); predictive back animation sa Android
- [x] Naka-customize na order/bilang ng card ng "Mine"; preview ng history-card at mga seksyon ng "watch later"
- [x] Auto na paglipat ng sidebar na may naka-configurable na trigger width; copy-image mula sa long-press / right-click; malaking MD3E style refresh

**Font system** — isang pinag-isang import pool na may content-hash de-duplication, mga danmaku font na isinama sa parehong pool, `loadFontFromList` na may ttc support, at pure-ASCII na hash family name.

**Playback, mini-window at quality** — in-app na mini-window (drag, resize, SponsorBlock skip, auto na system PIP, live self-rescue bar), concurrent-audio playback, in-app volume hanggang 200%, custom na video CDN domain at pagpili ng rehiyonal na node na may latency test, hiwalay na default quality ng half/full-screen, swipe-up speed lock, keyboard control sa tablet, live na SuperChat timestamp, live heartbeat para sa fan-intimacy.

**Subtitle, AI at offline** — bilingual na subtitle na may hiwalay na secondary-subtitle styling, AI subtitle analysis (custom na OpenAI-compatible endpoint, timestamp jump, mga template, persistent na conversation, soft na no-subtitle fallback), WEBVTT/SRT export, dual view ng offline-cache na may folder management at metadata persistence, pag-export ng download sa pampublikong Download folder (Android).

**Danmaku at blocking** — pinahusay na merged-danmaku scaling ([Pakku.js](https://github.com/xmcp/pakku.js)-style), list-based na visual regex blocking na may import/export, SponsorBlock seek-into-segment skip, Gaussian-kernel na high-energy progress bar.

**Pag-filter ng recommendation / dynamic / comment** — mga keyword ng title/UP/channel, duration, play-count, like-rate, exemption ng followed-UP, pag-filter ng unauthorized/charge-only, shared whitelist, commerce/unauthorized na dynamics, exemption ng UP-own-comment at pinned-comment, App+Web merged-feed mode.

**Dynamics, search at user info** — custom na note para sa mga UP, note-replaces-nickname sa 13 name slot, hiwalay na nested-comment sort, lokal na keyword search filter, b23.tv short-link jump, charge-only badge, hide-recommendation-reason toggle, coin XP display.

**Live enhancement** — fan-medal wearing panel, DLNA cast na mas pinipili ang HLS, SuperChat time display, mini-window bottom control bar para sa self-rescue.

**System integration at desktop** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), muling itinayong audio-focus handling.

<details>
<summary>Buong orihinal na feature/checklist (verbatim, mula sa PiliNara — i-click para palawakin)</summary>

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

## Pagtatatwa

Ang PiliBabel ay isang personal, interest-driven na proyekto, na ibinibigay **para sa pag-aaral at pagsubok lamang**; pakibura ito sa loob ng **24 oras** mula nang i-download.

- Ang PiliBabel ay isang **hindi opisyal na third-party** na client at **hindi kaugnay, hindi inendorso, o hindi sponsored ng bilibili**.
- Ang lahat ng API ay kinokolekta mula sa mga opisyal na pampublikong endpoint; **walang binibigay na cracked, over-privileged, o paywall-bypassing na nilalaman**.
- **Tumatakbo ang AI translation sa isang third-party na model endpoint.** Bilang default iyon ay sariling libreng pampublikong Index-Translate service ng bilibili; kung lumipat ka sa sarili mong API, iyon ang endpoint na ginawa mo. Ang kalidad ng pagsasalin at pagsunod sa mga alituntunin ay responsibilidad ng user at ng napiling model provider; ang proyektong ito ay **walang ina-host na modelo at walang API key**.
- Igalang ang copyright at ang Terms of Service ng bilibili. Gumamit nang responsable.

May paggalang sa mga orihinal at upstream na may-akda para sa kanilang dedikasyon sa open-source:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — ang direktang magulang na proyekto ng PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — ang open-source na pamilya ng modelo ng pagsasalin na tinatawag ng built-in na engine

Kung may nilalamang lumalabag sa iyong mga karapatan, mangyaring makipag-ugnayan sa amin para sa takedown.

<br/>

## Lisensya

Ang PiliBabel ay lisensyado sa ilalim ng **GNU General Public License v3.0 (GPL-3.0)** — ang parehong lisensya ng PiliNara, PiliPlus at PiliPala. Dahil ito ay isang derivative na gawain, **kailangan ding ipamahagi ang PiliBabel sa ilalim ng GPL-3.0**: malaya kang gumamit, mag-aral, magbahagi at baguhin ito, sa kondisyong panatilihin mo ang parehong lisensya, ang mga copyright notice, at ang text ng lisensyang ito. Tingnan ang [`LICENSE`](./LICENSE).

Ang mga third-party na bahagi (mga Flutter package, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), atbp.) ay nananatili sa ilalim ng sarili nilang mga lisensya.

Ang kasamang **LXGW WenKai** na typeface ay hiwalay na lisensyado sa ilalim ng **SIL Open Font License 1.1**; ang text ng lisensya nito ay kasama sa loob ng app bilang `assets/fonts/LXGWWenKai-OFL.txt`.

<br/>

## Pasasalamat

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — ang open-source na pamilya ng modelo ng pagsasalin ng bilibili, at ang libreng pampublikong endpoint sa likod ng built-in na engine
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — ang open-source na Chinese typeface na kasama ng app, sa ilalim ng SIL Open Font License 1.1
- at marami pang iba
- Inspired sa opisyal na "AI interface translation" ng bilibili.
