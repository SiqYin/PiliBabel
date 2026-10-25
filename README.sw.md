<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Mteja wa Bilibili wa mtu wa tatu, wenye tafsiri inayotumia AI.</b></p>
    <p>Babel — kuvunja kikwazo cha lugha, ili kila mtu aweze kufurahia bilibili kwa lugha yake mwenyewe.</p>
    <p>Inaunganisha orodha rasmi ya lugha 151 za bilibili na lugha 6 nyingine ambazo hazingizi — Kichina cha Jadi, Kiu kilichorahisishwa na cha Jadi, Kihokkien cha bara na cha Taiwan, na Kizhuang.</p>
    <p>Tafsiri hufanya kazi mara moja kwenye modeli ya bure ya bilibili yenyewe — hakuna ufunguo wa API unaohitajika.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.nan.md">台語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.mn.md">Монгол</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.pt.md">Português</a> · <a href="README.bn.md">বাংলা</a> · <a href="README.th.md">ไทย</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.it.md">Italiano</a> · <a href="README.fa.md">فارسی</a> · <a href="README.fil.md">Filipino</a> · <a href="README.ur.md">اردو</a> · <a href="README.mr.md">मराठी</a> · <a href="README.te.md">తెలుగు</a> · <a href="README.ta.md">தமிழ்</a> · <a href="README.pa.md">ਪੰਜਾਬੀ</a> · <a href="README.gu.md">ગુજરાતી</a> · <a href="README.ha.md">Hausa</a> · <b>Kiswahili</b> · <a href="README.nl.md">Nederlands</a> · <a href="README.my.md">မြန်မာ</a> · <a href="README.pl.md">Polski</a> · <a href="README.is.md">Íslenska</a> · <a href="README.nb.md">Norsk</a> · <a href="README.fi.md">Suomi</a> · <a href="README.sv.md">Svenska</a> · <a href="README.da.md">Dansk</a> · <a href="README.be.md">Беларуская</a> · <a href="README.ug.md">ئۇيغۇرچە</a> · <a href="README.kk.md">Қазақша</a> · <a href="README.bo.md">བོད་ཡིག</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Nyumbani" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dinamiki" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Mimi" />
</div>

<br/>

> **Kanusho.** PiliBabel ni mteja **asiye rasmi, wa chanzo-wazi, wa mtu wa tatu**. **Haihusiani na, haijaungwa mkono na, wala haijasomwa na** bilibili / bilibili Inc. Kila API inakusanywa kutoka kwenye endpoints za umma rasmi; **hakuna maudhui ya malipo yanayofunguliwa wala kuvunjwa**. Tafadhali soma sehemu kamili za [Kanusho](#kanusho) na [Leseni](#leseni).

## PiliBabel ni nini?

PiliBabel ni **fork huru ya mtu wa tatu iliyojengwa juu ya [PiliNara](https://github.com/Starfallan/PiliNara)**, na inarithi kila kitu ambacho PiliNara inarithi:

```
bilibili (official public API)
        ▲
   PiliPala / PiliPalaX        — mradi wa asili
        ▲
   PiliPlus                    — fork hai
        ▲
   PiliNara                    — fork ya PiliPlus (marekebisho ya kibinafsi)
        ▲
   PiliBabel  ← you are here   — fork ya PiliNara
```

PiliBabel inahifadhi **kila kipengele cha PiliNara / PiliPlus** (ona [kumbukumbu za vipengele vilivyorithiwa](#kumbukumbu-za-vipengele-vilivyorithiwa-kutoka-pilinara--piliplus) karibu na mwisho) na inaongeza **uwezo mkuu wa mamlaka mbili ambao wateja wa upstream hawana**:

> **Tafsiri ya kiolesura na ya maudhui kwa AI** — programu nzima (lebo za UI, vichwa vya video, majina ya UP, maoni, dinamiki, feed, na hata danmaku za moja kwa moja) huonyeshwa kwa lugha ambayo **wewe** unachagua.

Na kuanzia 1.0 inafanya hivyo **mara moja kutoka kwenye kisanduku**: modeli ya tafsiri **imejengwa ndani**. bilibili iliweka wazi familia yake ya modeli za tafsiri, [Index-Translate](https://github.com/bilibili/Index-Translate), na inatoa huduma yake kupitia endpoint ya umma ya bure. PiliBabel inakuja ikiwa imeelekezwa kwake, hivyo tafsiri hufanya kazi mara tu unaposakinisha programu — hakuna usajili, hakuna ufunguo, hakuna bili. Kama unapendelea kutumia modeli yako mwenyewe, njia ya API yako bado ipo, kwa mguso mmoja tu.

> **Sauti ya headphone inayobaki katika ulinganifu kwa kweli** — kwa headphone za Bluetooth au za waya, sauti haitangulii nyuma ya picha tena. Programu rasmi inafanya hili sahihi; PiliNara na PiliPlus hazifanyi, bila mipangilio ya ziada. PiliBabel sasa inaomba **AudioTrack** kutoka mpv kwanza, ambayo *inapima* ucheleweshaji wa pato la sauti kwa njia ile ile ya mteja rasmi, badala ya **OpenSL ES**, ambayo inau*kadiria* tu.

## Vipengele muhimu

- **Sauti ya headphone sawa.** Kicheza sasa kinatumia backend ya **AudioTrack** ya mpv kwa chaguo-msingi (mpangilio `audiotrack,aaudio,opensles`) badala ya **OpenSL ES**. AudioTrack inaripoti ucheleweshaji wa pato *uliopimwa* — inasoma idadi ya fremu zilizochezwa na alama ya wakati ya kuonyesha ya kifaa — ambayo ni jinsi hasa programu rasmi ya bilibili na `MediaSync` ya Android yenyewe wanavyoshikilia picha na sauti pamoja. OpenSL ES inau*kadiria* tu, hivyo kwenye headphone za Bluetooth saa ya sauti ilitangulia na pichi ilitangazwa mapema. Katika majaribio, ucheleweshaji umekwisha kwa kiasi kikubwa. Unaweza kupanga upya wakati wowote kwenye Mipangilio → Video → Kifaa cha kutolea sauti.

- **Tafsiri ya AI, kila mahali.** Vikaratasi vya kusafirisha, kadi za video, kurasa za maelezo, maoni, dinamiki, na sehemu za Mimi / Vipendwa / Historia / Ujumbe / Utafutaji — uteuzi wa kina wa kimataifa unashughulikia **stringi za UI zaidi ya 1,650+**, pamoja na maudhui yanayobadilika (vichwa, majina ya waandishi, idadi za vitendo).
- **Injini mbili, swichi moja.** *Iliyojengwa-ndani* (chaguo-msingi) inatumia endpoint ya bure rasmi ya bilibili **Index-Translate-35B-A3B** — hakuna cha kusanidi. *API Yako* inabaki na tabia ya awali: ielekeze kwenye endpoint yoyote inayolingana na OpenAI `/chat/completions` kwa URL yako ya msingi / ufunguo / modeli. Kipengele cha muhtasari wa video wa AI na kipengele cha tafsiri ya AI bado zina endpoints na mipangilio **iliyojitenga kikamilifu**, zote mbili zikiishi chini ya ukurasa mmoja wa **"Vipengele vya AI"**.
- **Orodha moja ya lugha, injini zote mbili.** Orodha ya lugha lengwa haikugawanywa kulingana na injini — orodha ile ile hutokea kwa injini yoyote utakayochagua. Inaunganisha **lugha 151** za modeli rasmi ya bilibili na **lugha 6 nyingine ambazo hazingizi** — Kichina cha Jadi, Kiu kilichorahisishwa na cha Jadi, Kihokkien cha bara na cha Taiwan, na Kizhuang. Tofauti za kanda na za maandishi zinabaki **ingizo tofauti** badala ya kuunganishwa — Kiarabu cha Morocco / Misri / Najdi / Levantine kila kimoja ni chaguo chake chenyewe, na vivyo hivyo Kiserbia cha Kyrillic-dhidi-ya-Kilatini, Kiuzbeki na Kiurdu.
- **Uwazi kuhusu ufunikaji.** Lugha zilizo ndani ya orodha rasmi hufunikwa na modeli ya bilibili. Zile chache zilizo nje yake — Kichina cha Jadi, Kiu kilichorahisishwa na cha Jadi, Kihokkien cha bara na cha Taiwan na Kizhuang — bado zinaonekana kwenye orodha, zikiwa zimealama hivyo, ili ujue kwa mtazamo mmoja kwamba matokeo bora yanaweza kuhitaji modeli yako.
- **Tafsiri mara moja, kisha inakaa.** Kila stringi ya chanzo inatafsiriwa **mara moja kamili**; matokeo yanahifadhiwa kwenye kifaa na **hayatafsiriwi tena kamwe** unapofungua upya skrini — kanuni ile ile ya mteja rasmi, kwa tafsiri thabiti na zinazotabirika.
- **Geuzo la Asili ⇄ Tafsiri kwa kila maoni** (ikonu ndogo, si neno la Kichina). `@mentions / [emoji] / #topics# / links` zinahifadhiwa kama tokeni, na **maoni yenye viungo bado yanatafsiriwa huku kiungo kikibaki kinabonyezeka**.
- **Tafsiri ya danmaku (弹幕)** — geuzo la kujitegemea kwenye safu ya vidhibiti ya juu-kulia ya kicheza, **limezimwa kwa chaguo-msingi** na linalindwa na uthibitisho ambao maandishi yake yenyewe yanatafsiriwa. Ukiliwasha, danmaku zilizo mbele ya kiweko cha kucheza zinatafsiriwa mapema **kwa makundi ya sekunde ~15** (kutafuta katikati kushughulikiwa sahihi, si kutoka mwanzo), hivyo tafsiri kwa kawaida iko tayari muda inapoingia kwenye skrini.
- **Geuzo la hali ya kufikiri** (`enable_thinking`) kwa ubora-dhidi-ya-mbio, pamoja na vitufe vya **"jaribio la tafsiri"** na **kufuta cache** kwenye mipangilio.
- **Kubadilisha lugha kwa kasi**: maombi yaliyopangwa kwa makundi yenye ushindani mdogo dhidi ya cache ya kudumu; kubadilisha lugha kunajenga upya skrini ya sasa mara moja kwa lazima, ili usibaki ukitazama maandishi yasiyotafsiriwa. Kuzima tafsiri ya AI kunarejesha UI nzima kwenye maandishi ya asili na hakuna maombi yanayotumwa kabisa.
- **Mwongozo wa kuanza mara ya kwanza.** Mara ya kwanza unapofungua programu, kidirisha cha Kiingereza kinapendekeza kuwasha tafsiri. Kukikubali kunawasha tafsiri, kuchagua modeli iliyojengwa-ndani, kufungua ukurasa wa mipangilio ya AI na mara moja kuuliza ni lugha gani unayotaka — hivyo mtumiaji mpya anasafiri kutoka usakinishaji hadi programu iliyotafsiriwa kwa miguso miwili.
- **Kucheza kunakofanya kazi duniani kote.** PiliBabel inachagua ukingo wa nje ya nchi (**Akamai** ya kimataifa, `mirror*ov`, `cn-hk-eq-bcache`) ambao `playurl` ya bilibili yenye uelekezi-wa-kijiografia tayari inatoa, badala ya kukuweka wazi kwenye node ya bara (Aliyun/Shenzhen) — hivyo watumiaji walioko nje ya China bara hawatishiki tena ("sauti inaendelea kucheza, video inaganda"). Bado unaweza kushikilia CDN kwa mkono kwenye Mipangilio.
- **Ukurasa wa "Mandhari & Rangi" kwa mtindo wa Material You.** Mwanga / giza / fuata-mfumo huchaguliwa kutoka **kadi tatu za maonyesho ya moja kwa moja** — kila moja inaonyesha nakala ndogo ya kiolesura halisi kwa rangi kamili zile hali hiyo ingezitumia (kadi ya "fuata mfumo" imegawanywa kwa mweko, mwanga juu ya giza). Chini yao: **rangi badilifu** (inayochukuliwa kutoka wallpaper ya mfumo pale kifaa kinaungana nayo), **giza la utofautishaji wa juu** (uso wa weusi wa kweli, rahisi kwa macho usiku) na **kicheza giza-daima**. Nusu ya rangi inabaki na paleti kamili ya FlexScheme — **rangi mbegu 19** pamoja na **"mtindo wa paleti"** tofauti unaaoamua jinsi rangi ya kila kontena inapotokana na mbegu, bila kujali mbegu uliyochagua.
- **LXGW WenKai inakuja na programu.** Herufi ya **LXGW WenKai (霞鹜文楷)** **imejumuishwa na imewekwa kwa chaguo-msingi** — herufi ya Kichina ya kirafiki na rahisi kusomeka unayo mara unaposakinisha, badala ya kuikaribisha kwenye kichagua. Inatumika kwa kiolesura chote *na* kwa danmaku. Bado unaweza kurudi kwenye herufi ya mfumo, kuchagua herufi yoyote ya mfumo iliyosakinishwa, au kuingiza yako ya `.ttf` / `.otf` / `.ttc`; herufi uliyochagua wazi hapo awali inahifadhiwa kupitia uboreshaji. Uzito na ukubwa bado vinarekebishika kama awali.

## Kuhifadhi kache ya sauti nje ya mtandao na kupakua kwenye folda ya ndani (maalum kwa PiliBabel)

Uwezo wawili ambao PiliNara / PiliPlus za upstream hawana — wote mbili wenye lengo la kumiliki media yako nje ya mtandao kwa kweli.

### Hifadhi sauti (kache ya sauti-pekee nje ya mtandao)

- **Wimbo, si video.** Kipengele cha *Hifadhi sauti* kipo chini kabisa ya *Hifadhi video* kwenye menyu ya ukurasa wa video, pamoja na kitufe maalum cha kuhifadhi sauti kwenye upau wa juu wa ukurasa wa kusikiliza-video.
- **Chagua kiwango cha ubora.** Hi-Res lossless, Dolby Atmos, 192K, 132K au 64K — orodha ile ile ya awali anayotumia kichagua ubora wa video.
- **Chombo cha asili, hakuna ubadilishaji.** Faili inaandikwa kama CDN inavyoitoa: `m4a`, `mp3`, `flac`, `wav`, `aac` au `ogg`.
- **Moduli yake yenyewe.** Ukurasa wa kache umegawanywa katika *Video zilizohifadhiwa* / *Sauti zilizohifadhiwa* na unakumbuka ulikuwa kwenye moduli gani mara iliyopita.
- Kugusa kipengele cha sauti iliyohifadhiwa kinafungua kicheza sauti moja kwa moja; vipengele vinafutwa moja-moja au kwa wingi.

### Pakua kwenye folda ya ndani

- **Kipengele chake cha menyu.** *Pakua kwenye folda ya ndani* ni kipengele tofauti kwenye menyu ya ukurasa wa video, chini kabisa ya *Hifadhi sauti* — kuhifadhi ndani ya programu na kuhifadhi kwenye folda ni vitendo viwili tofauti.
- **Pakua video au pakua sauti.** Kipengele kwanza kinauliza ni kipi, kisha kinauliza kiwango cha ubora (kichagua ubora wa video / sauti).
- **Folda yako, sheria zako.** Chagua folda yoyote kupitia kidhibiti faili cha mfumo (Mipangilio → *Pakua kwenye folda ya ndani*), na uibadilishe au uiweke wazi unapotaka. Kama hujachagua bado, kichagua folda kinafunguka papo hapo.
- **Faili zinazoweza kucheza moja kwa moja.** Video inachukuliwa kama mkondo mmoja uliounganishwa (`fnval=1`), hivyo kinachofika kwenye diski ni MP4 ya kawaida unayoweza kutoa kwa kicheza yoyote — hakuna michondo ya pembeni ya kuunganisha.
- **Sauti inabaki na muundo wake wa asili** — hakuna ubadilishaji, kama kache ya ndani ya programu.
- Faili hupewa majina ya jina la video na hazifutii kamwe kupakuliwa lililopo.

## Injini mbili za tafsiri

| | Iliyojengwa-ndani (chaguo-msingi) | API Yako |
|---|---|---|
| Modeli | **Index-Translate-35B-A3B** ya bilibili | chochote kinacholingana na OpenAI |
| Endpoint | `index-translate.bilibili.com/v1` | URL yako ya msingi |
| Ufunguo wa API | **hauhitajiki** | wako |
| Gharama | bure | chochote mtoa-huduma wako anachokulipa |
| Maombi | stringi moja kwa kila ombi | kwa makundi (≤ 16 kwa ombi) |
| Lugha za ziada | — | lugha yoyote modeli yako inayoijua |

**Kwa nini stringi-moja-kwa-ombi kwa injini iliyojengwa-ndani.** Index-Translate ni *mtaalamu* wa tafsiri, na mkataba wa uitaji unaodokusishwa na waandishi wake ni kiolezo cha kipengele-kimoja ("tafsiri maandishi yafuatayo kwa X, toa tafsiri pekee"). PiliBabel hivyo basi inatuma stringi moja kwa kila ombi kwenye injini hii, badala ya prompt ya orodha-ya-namba/JSON-array inayotumika kwa mipangilio ya API yako. Endpoint ni ya bure, hivyo hakuna cha kupata kwa kubahatisha kwa pato la makundi — huu ni ubadilishanaji wa makusudi wa maombi machache zaidi kwa njia za kushindwa chache sana.

**Kupandisha kutoka 0.3.x.** Mipangilio yako ya API — URL ya msingi, ufunguo na modeli — **inaachwa kama ulivyoipanga**. Uchaguzi wa injini unarudi kwa chaguo-msingi kwenye modeli iliyojengwa-ndani, hivyo kwenye uzinduzi wa kwanza baada ya kupandisha utakuwa kwenye modeli ya bure ya bilibili; fungua *Mipangilio → AI → Vipengele vya AI → injini ya tafsiri* na rudi *API Yako* ili kurejea kwenye mipangilio yako ya awali mara moja.

## Jinsi tafsiri ya kiolesura ya AI inavyofanya kazi (kiufundi)

Hifadhi hii **ina safu ya rasilimali za i18n / ARB** — stringi za UI zimeandikwa kwa Kichina kwa mkataba. Badala ya kuandika upya kila widget, PiliBabel inaongeza safu nyepesi ya tafsiri juu yake:

1. **Kifungashio cha utafutaji wa kimataifa.** `lib/services/ui_translate/` inatoa `uiTx(String src)` ya kiwango-cha-juu. Maandishi ya widget yaliyokuwa `Text('中文')` yanakuwa `Text(uiTx('中文'))`. **Codemod** iliyoandikwa kwa skripti ilitumia hili kote kwenye mradi (`tool/ui_translate_*.py`) — takriban **faili 223 / stringi ~1,650+** — ikiondoa kiotomatiki neno la `const` lililokuwa batili pale lilipohitajika (ikiwemo generics kama `const X<T>(...)` na majina ya nukta kama `const Positioned.fill(...)`, na kubadilisha tamko la orodha/ramani la `static const` kuwa `static final`).
2. **Kiini cha `GetxService`** (`ui_translate_service.dart`):
   - kache ya kudumu ya **chanzo → tafsiri** (inaungwa mkono na GetStorage), hivyo kila stringi inatafsiriwa mara moja na kutumika tena milele;
   - `tx()` inasoma `RxInt revision` kwanza, kisha inaamua: kama imezimwa → rudisha asili; kama lengo ni **Kichina Kilichorahisishwa (`zh-CN`)**, rudisha asili bila ombi la API (maudhui ya chanzo ya Bilibili kwa kiasi kikubwa ni Kichina Kilichorahisishwa). Lengo lingine lolote — ikiwemo Kichina cha Jadi, Kikantoni, Kiu/Kishanghai, na Kihokkien/Kimin-Nan — linapita kwenye injini iliyosanidiwa; kuwa mwanachama wa familia ya Kichina peke yake hakupuuzi tafsiri. Kisha hudumu kutoka kwenye kache au **iliweke kwenye foleni**;
   - stringi zilizoingizwa kwenye foleni zinamwagwa na **dimbwi la wafanyakazi** lenye **utekelezaji wa hatua-kwa-hatua kwa kila kipande** (kipande kila kinarudishwa kinapandisha `revision` hivyo maandishi yanahuishika hatua kwa hatua), na matokeo **yanahifadhiwa** (kwa kupunguza mara). Ukubwa wa kundi na ushindani hufuata injini: **1 kwa ombi** kwenye modeli iliyojengwa-ndani, **≤ 16 na ≤ 10 zilizo ndani ya safari** kwenye API yako.
3. **Utatuzi wa injini.** `TranslateProvider` (`builtin` / `custom`) inaamua URL, ufunguo na modeli usafiri unazotumia; injini zote mbili kwa upande mwingine zinashiriki njia moja ya msimbo na orodha moja ya lugha, hivyo kubadilisha injini ni mpangilio mmoja na sio seti tofauti ya vipengele.
4. **Usafiri** unatumia upya chaneli ile ile ya **streaming** iliyothibitishwa inayotumika na muhtasari wa video wa AI — `AiChatService.streamChat` → `{base}/chat/completions` ikiwa na `stream: true` (inaungana na langozinazoungwa na streaming pekee) — imepanuliwa ili tafsiri iweze kutumia `apiUrl` / `apiKey` / `model` **zake** na bendera ya `enable_thinking`. Mabadiliko ni **yanayolingana na nyuma**, hivyo muhtasari wa video unaendelea kufanya kazi bila kubadilika.
5. **Sentensi zenye viingizaji** zinatumia `uiTxP(template, args)`: sentensi nzima yenye nafasi za `{0}`/`{1}` inatafsiriwa kama ufunguo thabiti mmoja (prompt inamuomba modeli kushikilia nafasi hizo), kisha thamani zinarudishwa ndani — hivyo stringi za mtindo wa `"共 {0} 条"` zinatafsiriwa bila kuharibu sehemu zinazobadilika.
6. **Jedwali la lugha** (`app_language.dart`): kila `AppLanguage` ina jina la kuonyesha lenye asili, stringi ya prompt ya `toModel` inayosimbisha mikataba ya maandishi/kanda, na bendera ya kama orodha rasmi ya bilibili inaifunika. Sheria za maandishi (Rahisi dhidi ya Jadi, na maagizo ya ulinganifu wa lahaja) hufikia modeli kupitia prompt pekee, na pasi ya kawaida ya uthabiti upande wa mteja inatatua glifu za makosa baadaye.
7. **Maoni** yanapita kwenye `uiTxComment(text, id)`, huku `@ / [emoji] / #topic# / link` zikibaki kama tokeni zisizoguswa; spans tajiri zenye viungo zinatafsiriwa huku kitambuashi cha kiungo kikihifadhiwa, na seti ya id kwa-kila-maoni inaendesha geuzo la Asili ⇄ Tafsiri.
8. **Danmaku** (`danmaku/view.dart`): geuzo lake likiwashwa, kisikilizi cha nafasi kinatembea `[playhead, playhead + 15s]` sekunde moja kwa wakati na kinapasha moto `uiTx()` kwa maudhui ya kila danmaku, hivyo vipengele vinatafsiriwa mapema kabla hayajafika skrini; kuviwasha kunafuta na kupaka upya kanfasi.
9. **Ufunguo wa hifadhi**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **UI ya mipangilio**: ukurasa mmoja wa ngazi-ya-kwanza "Vipengele vya AI" (`lib/pages/setting/ui_translate/`) wenye vitalu vinavyojitenga vya muhtasari wa video wa AI na tafsiri ya AI.

**CDN ya kimataifa (`VideoUtils.getCdnUrl`).** URL za mkondo zina sahihi ya kidijitali, na kuandika upya jina la mwenyeji wa URL kunaikatalisha kwa 403 — hivyo kucheza hakunaandiki upya mwenyeji kamwe. PiliBabel inarudisha URL ya uelekezi-wa-kijiografia ambayo bilibili inampa IP ya mteja, na orodha ya wagombea ikishatoka na ukingo wa nje ya nchi (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`) ile inapendelewa. Upakuaji, ambako kubadilisha mwenyeji ni salama, zaidi unapendelea ukingo wa Akamai wa kimataifa na kuzungusha kwa mgombea mwingine wenye sahihi mstari unaposimama au kunakataa kuendelea. Viungo vya P2P vya `/v/resource` bado vinarejea kwenye relay iliyopo kuepuka 404.

**Mambo ya usanifu / vikwazo vinavyojulikana.** Kwa kuwa stringi zimefungwa mahali zilipo badala ya kutohwa kwenye rasilimali, vigezo vichache vya stringi isiyo `Text` na baadhi ya spans tajiri bado vinajazwa hatua kwa hatua. Stringi zinazotumika pia kama **ufunguo wa mantiki** (zinazolinganishwa kwa `==`, zinazotumika kama majina ya tab kama `简介`, au lebo za enum zinazotumika kwenye switch) kwa makusudi **hazifungwi kwa blanketi**, kuepuza kuvuruga tabia. Tafsiri ya danmaku ni juhudi-bora kwenye kanfasi inayosonga — chini ya danmaku nzito mno unaweza kuona asili kwa muda mfupi kabla tafsiri hajafika. Tafsiri inahitaji mtandao; bila yake, lengo zisizo za Kichina hazitumiki. Endpoint iliyojengwa-ndani ni huduma ya umma ya bure inayoendeshwa na bilibili — ikipunguzwi kasi au ikikosekana, programu inakuambia na unaweza kubadilisha kwenda API yako.

## Kujenga na kuthibitisha

Programu inajengwa kwa Flutter SDK iliyo-rekebishwa pamoja na furushi za `material_ui` / `cupertino_ui` zilizorekebishwa kupitia `lib/scripts/patch.ps1` na `lib/scripts/build.ps1` (kama PiliNara / PiliPlus kabisa). GitHub Actions inatoa **APK ya debug** kwenye kila push (`.github/workflows/ui-translate-debug.yml`), na **kuchapisha tag `v*` hujenga na kutoa Android, Windows na Linux** kiotomatiki (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Majukwaa
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

PiliBabel inatoa majengo ya **Android (APK), Windows na Linux** kutoka Releases; iOS/Pad hazijawekwa kwenye furushi za fork hii bado.

<br/>

## Upakuaji

Chukua jengo kutoka **Releases**, au nakili hifadhi na uijenge kwenye kompyuta yako.

### Arch Linux

Shukrani kwa [@nlsdt](https://github.com/nlsdt) kwa ufungashaji furushi (mapishi ya PiliNara yanaendelea kutumika pia kwa PiliBabel).

```bash
sudo pacman -S pilinara      # kupitia hifadhi ya Arch Linux CN
paru -S pilinara-bin         # au kupitia AUR: pilinara-bin (iliyojengwa tayari) / pilinara (chanzo)
```

<br/>

## Kumbukumbu za vipengele vilivyorithiwa (kutoka PiliNara / PiliPlus)

Kila kitu hapa chini kimerithiwa kutoka PiliNara (na, kwa urithi, PiliPlus); PiliBabel inaongeza safu ya tafsiri ya AI juu yake.

**UI na urekebishaji wa jukwaa**
- [x] Programu imepewa jina jipya kwa kila jukwaa ili wateja wengi wawelee pamoja (PiliBabel inasakinishwa pamoja na PiliNara)
- [x] Imerekebisha uchoraji wa Flutter chini ya dirisha-ndogo ya Xiaomi HyperOS ([#161086](https://github.com/flutter/flutter/issues/161086), kupitia [venera#467](https://github.com/venera-app/venera/pull/467)); uhuishaji wa nyuma utabiri kwenye Android
- [x] Mpangilio/idadi ya kadi za "Mimi" inayorekebisheka; maonyesho ya kadi-ya-historia na sehemu za "angalia baadaye"
- [x] Kubadilisha upau-kando kiotomatiki kwa upana wa kuchocheza unaosanidiwa; kunakili-picha kutoka kwa kubofya-muda-mrefu / kubofya-kulia; uundaji upya mkubwa wa mtindo wa MD3E

**Mfumo wa herufi** — dimbwi moja ya kuingiza lenye kuondoa nakala kwa hash-ya-maudhui, herufi za danmaku zikiunganishwa kwenye dimbwi ile ile, `loadFontFromList` yenye utao wa ttc, na majina ya familia ya hash ya ASCII-safi.

**Kucheza, dirisha-ndogo na ubora** — dirisha-ndogo ndani ya programu (kuburuta, kubadilisha ukubwa, kuruka SponsorBlock, PIP ya mfumo kiotomatiki, upau wa kujinusuru wa moja kwa moja), kucheza sauti zinazofanana wakati mmoja, sauti ya ndani ya programu hadi 200%, kikoa cha CDN cha video cha kawaida & uteuzi wa node ya kanda na jaribio la ucheleweshaji, ubora wa chaguo-msingi wa nusu/skrini-kamili tofauti, kufunga kasi kwa kupanda kwa mkono, udhibiti wa kibodi ya kompyuta-kibao, alama za wakati za SuperChat za moja kwa moja, mapigo ya moyo ya moja kwa moja ya ukaribu wa mashabiki.

**Manukuu, AI na nje ya mtandao** — manukuu ya lugha mbili yenye mtindo huru wa manukuu ya pili, uchambuzi wa manukuu wa AI (endpoint ya kawaida inayolingana na OpenAI, kuruka kwa alama ya wakati, violezo, mazungumzo yanayohifadhiwa, kurudi nyuma taratibu bila manukuu), usafirishaji wa WEBVTT/SRT, mtazamo-wawili wa kache-nje-ya-mtandao wenye usimamizi wa folda & uhifadhi wa metadata, kusafirisha upakuaji kwenye folda ya Download ya umma (Android).

**Danmaku na kuzuia** — kupanua kwa mchanganyiko-danmaku ulioimarishwa (kwa mtindo wa [Pakku.js](https://github.com/xmcp/pakku.js)), kuzuia kwa regex za kuonekana zenye orodha na kuingiza/kutoa, kuruka-segmentu ya SponsorBlock ya kutafuta-ndani, upau wa maendeleo ya nishati-ya-juu kwa kiini cha Gaussian.

**Uchuuzi wa mapendekezo / dinamiki / maoni** — maneno-msingi ya kichwa/UP/kituo, muda, idadi-ya-kucheza, kiwango-cha-kupendwa, msamaha wa UP-unayemfuata, uchuuzi wa yasiyo-halali/malipo-pekee, orodha-nyeupe inayoshirikiwa, dinamiki za biashara/yasiyo-halali, msamaha wa maoni-ya-UP-mwenyewe na maoni-yaliyopachikwa, hali ya feed-iliyounganishwa ya App+Web.

**Dinamiki, utafutaji na taarifa za mtumiaji** — madokezo ya kawaida kwa UP, dokezo-linalobadilisha-jina-la-utani katika nafasi 13 za majina, upangaji huru wa maoni-ya-ndani-ya-maoni, kichujio cha utafutaji cha maneno-msingi cha kwenye kifaa, kuruka kwa kiungo-chafupi cha b23.tv, beji ya malipo-pekee, geuzo la kuficha-sababu-ya-pendekezo, onyesho la XP ya sarafu.

**Uboreshaji wa moja kwa moja** — jedwali la kuvaa-medali-ya-shabiki, uchapishaji DLNA unaopendelea HLS, onyesho la wakati la SuperChat, upau wa vidhibiti wa chini wa dirisha-ndogo wa kujinusuru.

**Uunganishaji wa mfumo na dawati** — SMTC ya Windows, MPRIS ya Linux (`audio_service_mpris`), udhibiti wa audio-focus uliojengwa upya.

<details>
<summary>Orodha kamili ya asili ya vipengele/ukaguzi (kwa maneno yake, kutoka PiliNara — bonyeza kupanua)</summary>

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

## Kanusho

PiliBabel ni mradi wa kibinafsi unaotokana na shauku, unaotolewa **kwa kujifunza na kujaribu tu**; tafadhali uifute ndani ya **saa 24** za kupakuwa.

- PiliBabel ni mteja **wa tatu asiye rasmi** na **haihusiani na, haijaungwa mkono na, wala haijasomwa na bilibili**.
- API zote zimekusanywa kutoka kwenye endpoints za umma rasmi; **hakuna maudhui yaliyovunjwa, yenye ruhusa nyingi mno, au yanayopuuza ukuta wa malipo** yanayotolewa.
- **Tafsiri ya AI inaendeshwa kwenye endpoint ya modeli ya mtu wa tatu.** Kwa chaguo-msingi hiyo ni huduma ya umma ya bure ya Index-Translate ya bilibili yenyewe; ukihamia kwenye API yako, ni endpoint uliyoisanidi. Ubora wa tafsiri na ustii ni jukumu la mtumiaji na mtoa modeli aliyeuchaguliwa; mradi huu **hauna modeli wala ufunguo wa API**.
- Heshimu hatimiliki na Masharti ya Huduma ya bilibili. Tumia kwa uwajibikaji.

Kwa heshima kwa waandishi wa asili na wa upstream kwa michango yao ya chanzo-wazi:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — mradi mzazi wa moja kwa moja wa PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — familia ya modeli ya tafsiri ya chanzo-wazi ambayo injini iliyojengwa-ndani inaiita

Ikiwa maudhui yoyote yanakiuka haki zako, tafadhali wasiliana nasi ili tuyadondoe.

<br/>

## Leseni

PiliBabel inatoa leseni chini ya **GNU General Public License v3.0 (GPL-3.0)** — leseni ile ile ya PiliNara, PiliPlus na PiliPala. Kwa kuwa ni kazi inayotokana, **PiliBabel lazima pia isambazwe chini ya GPL-3.0**: uko huru kuitumia, kuisoma, kuishirikisha na kuirekebisha, kwa sharti uweke leseni ile ile, taarifa za hatimiliki, na maandishi ya leseni hii. Ona [`LICENSE`](./LICENSE).

Vitu vya mtu wa tatu (furushi za Flutter, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), n.k.) zinabaki chini ya leseni zao.

Herufi ya **LXGW WenKai** iliyojumuishwa ina leseni tofauti chini ya **SIL Open Font License 1.1**; maandishi ya leseni yake yanakuja ndani ya programu kama `assets/fonts/LXGWWenKai-OFL.txt`.

<br/>

## Shukrani

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — familia ya modeli ya tafsiri ya chanzo-wazi ya bilibili, na endpoint ya umma ya bure inayosimama nyuma ya injini iliyojengwa-ndani
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — herufi ya Kichina ya chanzo-wazi iliyojumuishwa na programu, chini ya SIL Open Font License 1.1
- na mengineyo
- Imehamasishwa na "tafsiri ya kiolesura ya AI" rasmi ya bilibili.
