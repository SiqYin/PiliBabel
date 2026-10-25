<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>App ɗin Bilibili na ɓangare na uku mai fassara ta AI.</b></p>
    <p>Babel — rushe ganuwar harshe, domin kowa ya iya jin daɗin bilibili a cikin harshensa.</p>
    <p>Ya haɗa jerin harsuna 151 na hukuma na bilibili da wasu 6 da ba ta rufe su ba - Sinanci na Gargajiya, Wu mai sauƙaƙe da na Gargajiya, Hokkien na ƙasar China da na Taiwan, da Zhuang.</p>
    <p>Fassara tana aiki kai tsaye akan samfurin kyauta na bilibili kanta — babu buƙatar maɓallin API.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.nan.md">台語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.mn.md">Монгол</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.pt.md">Português</a> · <a href="README.bn.md">বাংলা</a> · <a href="README.th.md">ไทย</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.it.md">Italiano</a> · <a href="README.fa.md">فارسی</a> · <a href="README.fil.md">Filipino</a> · <a href="README.ur.md">اردو</a> · <a href="README.mr.md">मराठी</a> · <a href="README.te.md">తెలుగు</a> · <a href="README.ta.md">தமிழ்</a> · <a href="README.pa.md">ਪੰਜਾਬੀ</a> · <a href="README.gu.md">ગુજરાતી</a> · <b>Hausa</b> · <a href="README.sw.md">Kiswahili</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.my.md">မြန်မာ</a> · <a href="README.pl.md">Polski</a> · <a href="README.is.md">Íslenska</a> · <a href="README.nb.md">Norsk</a> · <a href="README.fi.md">Suomi</a> · <a href="README.sv.md">Svenska</a> · <a href="README.da.md">Dansk</a> · <a href="README.be.md">Беларуская</a> · <a href="README.ug.md">ئۇيغۇرچە</a> · <a href="README.kk.md">Қазақша</a> · <a href="README.bo.md">བོད་ཡིག</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Gida" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dinamik" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Ni" />
</div>

<br/>

> **Sanarwa.** PiliBabel app ɗin **mai zaman kanta, na tushen buɗe, na ɓangare na uku** ce. **Ba ta da alaƙa da, ba a amince da ita, kuma ba a tallafa mata ba** daga bilibili / bilibili Inc. Kowane API ana tattara shi daga manyan hanyoyin jama'a na hukuma; **babu abun ciki na biyan kuɗi da ake buɗewa ko warcewa**. Da fatan za ka karanta cikakkun sassan [Sanarwa](#sanarwa) da [Lasisi](#lasisi).

## Menene PiliBabel?

PiliBabel wata **fork ce mai zaman kanta ta ɓangare na uku, wadda aka gina a saman [PiliNara](https://github.com/Starfallan/PiliNara)**, kuma tana gaji da duk abin da PiliNara ke gado da shi:

```
bilibili (official public API)
        ▲
   PiliPala / PiliPalaX        — ainihin aikin
        ▲
   PiliPlus                    — fork mai aiki
        ▲
   PiliNara                    — fork ɗin PiliPlus (gyare-gyaren sirri)
        ▲
   PiliBabel  ← you are here   — fork ɗin PiliNara
```

PiliBabel tana kiyaye **kowane fasalin PiliNara / PiliPlus** (duba [rahoton fasalolin da aka gada](#rahoton-fasalolin-da-aka-gada-daga-pilinara--piliplus) kusa da ƙasa) kuma tana ƙara **manyu iyawa biyu da app ɗin upstream basu da su**:

> **Fassasar mahada da abun ciki ta AI** — dukkan app ɗin (lakabin UI, taken bidiyo, sunayen UP, tsokaci, dinamik, feed, har da danmaku na kai tsaye) ana nuna shi da harshen da **kai** ka zaɓa.

Kuma tun daga 1.0 tana yin hakan **kai tsaye daga akwati**: samfurin fassara **an haɗa shi cikin app**. bilibili ta buɗe tushen dangin samfuran fassara nata, [Index-Translate](https://github.com/bilibili/Index-Translate), kuma tana hidimarta daga endpoint ɗin jama'a kyauta. PiliBabel na zuwa tana mai da ita manufa, don haka fassara tana aiki da zarar ka shigar da app ɗin — babu rijista, babu maɓalli, babu kudin biyan. Idan kana son amfani da samfurin ka da kanka, hanyar API ɗin ka na nan, tana nesa da dannawa guda.

> **Sautin na kunnuwa wanda zaizai ya daidaita kwarai** — tare da na kunnuwa na Bluetooth ko na waya, sauti ba ya sake bin baya bayan hoton. App ɗin hukuma na daidaita wannan; PiliNara da PiliPlus ba sa yin haka daga farko. PiliBabel yanzu tana nema **AudioTrack** daga mpv da farko, wanda *ke auna* jinkirin fitar da sauti daidai yadda app ɗin hukuma ke yi, maimakon **OpenSL ES**, wanda kawai yake *kimanin* shi.

## Manyan fasaloli

- **Sautin na kunnuwa a daidaito.** Mai kunnawa yanzu yana amfani da baya ɗin **AudioTrack** na mpv a matsayin tsoho (tsari `audiotrack,aaudio,opensles`) maimakon **OpenSL ES**. AudioTrack na ba da rahoton jinkirin fitarwa *da aka auna* — yana karanta ƙididdigar firam da aka riga aka kunna da kuma lokacin gabatar da na'urar — wanda shine daidai yadda app ɗin bilibili na hukuma da `MediaSync` na Android kanta ke riƙe hoto da sauti tare. OpenSL ES kawai yana *kimanta* shi, don haka a kan na kunnuwa na Bluetooth agogon sauti ya kan rabu kuma ana nuna hoton da wuri. A gwaje-gwaje, jinkirin kusan ya ƙare. Za ka iya sake tsarawa a kowane lokaci a Saituna → Bidiyo → Na'urar fitar da sauti.

- **Fassara AI, ko'ina.** Kofofin kewayawa, katunan bidiyo, shafunan cikakken bayani, tsokaci, dinamik, da sauran Allon Nawa / Zaɓaɓɓu / Tarihi / Saƙonni / Bincike — sikwip ɗin duniya ya rufe **kirtani na UI kusan 1,650+**, tare da abun ciki mai canzawa (take, sunayen mawallafa, ƙididdigar ayyuka).
- **Injuna biyu, maɓalli guda.** *Na cikin gini* (tsoho) yana amfani da endpoint ɗin kyauta na hukuma **Index-Translate-35B-A3B** na bilibili — babu abin da za a daidaita. *API ɗin ka* yana ci gaba da hali na da: a miƙa shi zuwa kowane endpoint mai dacewa da OpenAI `/chat/completions` da tushen URL ɗinka / maɓallinka / samfurinka. Fasalin taƙaitaccen bidiyo na AI da fasalin fassara na AI har yanzu suna da endpoints da saituna **masu zaman kansu gaba ɗaya**, dukkansu na zaune a ƙarƙashin shafi guda **"Fasalolin AI"**.
- **Jerin harsuna guda, injuna biyu.** Jerin harsunan da ake fassara zuwa gare su ba a raba shi da inji ba — ana ba da jeri guda kamar haka duk wani inji da ka zaɓa. Ya haɗa **harsuna 151** na samfurin hukuma na bilibili da **wasu 6 da bai rufe su ba** — Sinanci na Gargajiya, Wu mai sauƙaƙe da na Gargajiya, Hokkien na Ƙasar China da na Taiwan, da Zhuang. Ana riƙe da ƙarin yanki da na rubutu a matsayin **shigarori daban** ba a haɗa su ba — Larabcin Morocco / Masar / Najdi / Levantine kowanne zaɓi ne na kansa, haka kuma Serbiya-Cyrillic-da-Latin, Uzbek da Urdu.
- **Gaskiya game da ɗaukar harsuna.** Harsunan da ke cikin jerin hukuma samfurin bilibili na ɗauke da su. Kaɗan daga cikin wadanda ke waje — Sinanci na Gargajiya, Wu mai sauƙaƙe da na Gargajiya, Hokkien na Ƙasar China da Taiwan da Zhuang — har yanzu suna fitowa a cikin jerin, an yi musu alama kamar haka, don ka san da hari-gari cewa sakamako mafi kyau na iya buƙatar samfurin ka.
- **Fassara sau ɗaya, to ya daidaita.** Kowane kirtanin tushen ana fassara shi **a daidai sau ɗaya kawai**; ana adana sakamakon a gida kuma **ba a sake fassarawa shi ba** idan ka sake buɗe allo — ka'ida ɗaya da app ɗin hukuma, don fassasori masu kwanciyar hankali da za a iya tsammani.
- **Maɓallin Asali ⇄ Fassara a kowane tsokaci** (aramin alama, ba kalmar Sinawa ce ba). Ana kiyaye `@mentions / [emoji] / #topics# / links` a matsayin tokens, kuma **tsokacin da ke ɗauke da hanyar haɗi har yanzu ana fassara shi tare da riƙe hanyar danne-danne**.
- **Fassara danmaku (弹幕)** — maɓalli mai zaman kansa a layin sarrafawa na sama-dama na mai kunnawa, **an kashe shi a tsoho** kuma a na ɗaure shi da tabbatawa wadda rubutunta da kanta ake fassara. Da zarar an kunna shi, a na fassara danmaku masu gaba da matsayin wasa a gaba **cikin gungu na daƙiƙa 15 kusan** (neman tsakiya a na bi da shi daidai, ba daga farko ba), don haka fassarar ta kan shiri kafin ta shiga allo.
- **Maɓallin yanayin tunani** (`enable_thinking`) don zaɓar inganci-ko-gudu, tare da maɓallan **"gwajin fassara"** da **share cache** a cikin saituna.
- **Saurin sauya harshe**: buƙatun da aka ɗora cikin gungu tare da iyakance yawan a lokaci guda akan cache mai ɗorewa; sauya harshe na tilasta sake gina allo na yanzu sau ɗaya, don ba a bar ka ka yi kallon rubutun da ba a fassara ba. Kashe fassarar AI na mayar da duk UI ɗin zuwa rubutun asali kuma baya aikata buƙatu kwata-kwata.
- **Maraba ta farko-buɗewa.** A karon farko da ka buɗe app ɗin, akwatin tattaunawar Turanci yana ba da shawarar kunna fassara. Karɓar sa yana kunna fassara, yana zaɓar samfurin cikin gini, yana buɗe shafin saitocin AI kuma nan take yana tambayar da wane harshe kake so — don haka sabon mai amfani na tafiya daga shigarwa zuwa app ɗin da aka fassara a dannawa biyu.
- **Kunnawa da ke aiki a duk duniya.** PiliBabel tana zaɓar gefen ƙasashen waje (**Akamai** na duniya, `mirror*ov`, `cn-hk-eq-bcache`) da `playurl` ɗin bilibili mai tsara-yanki ke riga ya bayar, maimakon a ɗaure ka zuwa node ɗin ƙasa (Aliyun/Shenzhen) — don haka masu amfani a wajen ƙasar Sin ba sa sake tsayawa ("sauti yana ci gaba, bidiyo yana daskarewa"). Har yanzu za ka iya ɗaure CDN da hannu a Saituna.
- **Shafin "Jigi & Launi", a salon Material You.** Haske / duhu / bi-tsarin ana zaɓen su daga **katunan gabatarwa masu rai uku** — kowacce tana zana ƙaramin kwatance na arshin na gaske da launuka iri ɗaya waɗanda wannan yanayin zai yi amfani da su (katun "bi tsarin" an raba ta a kwance-tsakuwa, haske a saman duhu). A ƙarƙashinsu: **launi mai canzawa** (daga bangon tsarin inda na'urar ke tallafawa), **duhu mai bambanci-girma** (fassoshin baƙar fata ta gaske, sauƙin idanu da dare) da **mai kunnawa mai-duhu-koyaushe**. Rabin launi yana riƙe da cikakken shirin launi na FlexScheme — **launukan tsaba 19** tare da **"salon shirin launi"** na daban wanda ke yanke hukuncin yadda ake samun launin kowane akwati daga tsaba, ba tare da damuwa da wace tsaba ka zaɓa ba.
- **LXGW WenKai na tare da app ɗin.** Font ɗin **LXGW WenKai (霞鹜文楷)** **an haɗa shi kuma an sa shi tsoho** — font ɗin Sinawa mai dumi kuma mai sauki a karantawa wanda kake da shi nan da ka shigar da, maimakon ka yi ta neman shi a cikin mai zaɓe. Yana shafar dukkan arshin *kuma* danmaku. Har yanzu za ka iya komawa ga font ɗin tsarin, zaɓi kowane font ɗin tsarin da aka shigar, ko ka shigo da `.ttf` / `.otf` / `.ttc` naka; font ɗin da ka riga ka zaɓa a bayyane ana kiyaye shi ta hanyar sabuntawa. Girma da girman har yanzu ana iya daidaita su kamar yadda ake yi.

## Ajiyar sauti ba tare da intanet ba & sauke zuwa babban fayil ɗin gida (na musamman ga PiliBabel)

Iyawa biyu da PiliNara / PiliPlus na upstream basu da su — duka biyu suna nufin ka mallaki kaɗaikinka na gaske ba tare da intanet ba.

### Ajiye sauti (ajiya ba tare da intanet ba, sauti kawai)

- **Waƙar, ba bidiyon ba.** Shigar *Ajiye sauti* na zaune a ƙasa da *Ajiye bidiyo* a cikin menu ɗin shafin bidiyo, tare da maɓallin ajiye-sauti na musamman a layin sama na shafin saurarar-bidiyo.
- **Zaɓi matakin inganci.** Hi-Res lossless, Dolby Atmos, 192K, 132K ko 64K — jerin farko ɗaya mai zaɓin ingancin bidiyo ke amfani da shi.
- **Kwandon asali, babu transcoding.** Ana rubuta fayil ɗin daidai yadda CDN ke ba da shi: `m4a`, `mp3`, `flac`, `wav`, `aac` ko `ogg`.
- **Module ɗinsa na kansa.** An raba shafin cache zuwa *Bidiyoyin da aka ajiye* / *Sautunan da aka ajiye* kuma yana ƙwaƙwalwar wane module ka kasance a karon da ya wuce.
- Dannun abin sautin da aka ajiye na buɗe mai kunna sauti kai tsaye; ana iya goge kaya ɗaya-ɗaya ko cikin gungu.

### Sauke zuwa babban fayil na gida

- **Shigar menu ɗin nasa.** *Sauke zuwa babban fayil na gida* shiga ce ta musamman a cikin menu ɗin shafin bidiyo, kai tsaye ƙarƙashin *Ajiye sauti* — ajiye a cikin app da adana zuwa babban fayil ayyuka biyu ne daban.
- **Sauke bidiyo ko sauke sauti.** Shigar ɗin da farko tana tambayar wane daga cikinsu, sannan tana neman matakin inganci (mai zaɓin ingancin bidiyo / sauti).
- **Babban fayilinka, dokarka.** Zaɓi kowane babban fayil ta hanyar manajan fayilolin tsarin (Saituna → *Sauke zuwa babban fayil na gida*), kuma ka canja shi ko ka share shi yadda kake so a kowane lokaci. Idan ban ka riga ka zaɓa ba, mai zaɓin babban fayil na buɗewa a wuri.
- **Fayilolin da za a iya kunna kai tsaye.** Ana jawo bidiyo a matsayin rafi guda mai muxed (`fnval=1`), don abin da ya sauka a diski MP4 mai tsabta ce za ka iya ba kowane mai kunnawa — babu rafukan gefe da ake ɗinurewa.
- **Sauti yana riƙe da tsarinsa na asali** — babu transcoding, daidai kamar cache ɗin cikin app.
- Ana kiran fayiloli da sunan taken bidiyo kuma ba sa taɓa maye gurbin saukewar da ta riga ta kasance.

## Injin fassara biyu

| | Na cikin gini (tsoho) | API ɗinka |
|---|---|---|
| Samfuri | **Index-Translate-35B-A3B** na bilibili | abin da ya dace da OpenAI |
| Endpoint | `index-translate.bilibili.com/v1` | tushen URL ɗinka |
| Maɓallin API | **ba a buƙata ba** | naka |
| Kudi | kyauta | duk abin da mai ba da sabis ɗinka ke cajinka |
| Bukatu | kirtani guda a kowane buƙata | a cikin gungu (≤ 16 a kowane buƙata) |
| Ƙarin harsuna | — | kowane harshe da samfurinka ya sani |

**Don me ake aikawa buƙata-guda a injin cikin gini.** Index-Translate ƙwararre ne a fassara, kuma tsarin kiran da marubuta suka rubuta siga ɗaya-kawai ce ("fassara rubutun da ke ƙasa zuwa X, ka fitar da fassarar kawai"). Don haka PiliBabel tana aikawa kirtani guda a kowane buƙata akan wannan inji, maimakon prompt ɗin jerin-lambobi/JSON-array da ake amfani da shi na saitin API-ɗinka. Endpoint ɗin kyauta ne, don babu abin za a ci nasara da caca a kan sakamakon gungu — wannan musaya ce da gangan: ƙarin buƙatu kaɗan don samun hanyoyin kuskure kaɗan sosai.

**Sabuntawa daga 0.3.x.** Saitunan API ɗinka — tushen URL, maɓalli da samfuri — **ana barin su daidai yadda ka sa su**. Zaɓin inji kawai na sa tsoho zuwa samfurin cikin gini, don haka a farkon buɗewa bayan sabuntawa zaka kasance akan samfurin kyauta na bilibili; buɗe *Saituna → AI → Fasalolin AI → injin fassara* ka koma *API ɗinka* don ka koma saiton ka na da kai tsaye.

## Yadda fassasar mahadar AI ke aiki (na fasaha)

Ma'ajiyar lamba ba ta da **tsarin albarkatun i18n / ARB** — ana rubuta kirtanin UI da Sinanci kai tsaye. Maimakon a sake rubuta kowane widget, PiliBabel ta ƙara wani ɓangaren fassara mai laushi a saman:

1. **Mai nema na duniya.** `lib/services/ui_translate/` na fallasa `uiTx(String src)` na matakin-sama. Rubutun widget ɗin da ya kasance `Text('中文')` yana zama `Text(uiTx('中文'))`. Wata **codemod** mai rubutu (script) ta yi wannan a duk fadin aikin (`tool/ui_translate_*.py`) — kimanin **fayiloli 223 / kirtani ~1,650+** — tana sauke kalmar `const` da ta zama mara inganci inda ake buƙata (ciki har da generic kamar `const X<T>(...)` da sunayen dabara kamar `const Positioned.fill(...)`, da kuma mayar da sanarwar list/map na `static const` zuwa `static final`).
2. **Cikakin `GetxService`** (`ui_translate_service.dart`):
   - cache na **tushen → fassara** mai ɗorewa (GetStorage ne ke bayansa), don kowane kirtani a fassara sau ɗaya a sake amfani da shi har abada;
   - `tx()` na karanta `RxInt revision` da farko, sannan ya yanke shawara: idan an kashe shi → mayar da asali; idan manufa ita ce **Sinanci Mai sauƙi (`zh-CN`)**, mayar da asali ba tare da buƙatar API ba (abun cikin tushen Bilibili Sinanci Mai sauƙi ne mafi yawa). Kowane wata manufa — ciki har da Sinanci na Gargajiya, Cantonese, Wu/Shanghainese, da Hokkien/Min Nan — tana wucewa ta injin da aka daidaita; kasancewa memba na dangin Sinawa kadai baya tsallake fassara. Sannan a yi hidima daga cache ko **a shigar da layi**;
   - ana zubar da kirtanin da aka shigar da layi ta **tarin ma'aikata** tare da **amfani a hankali a kowane gajeren yanki** (kowane gajeren yanki da ya koma yana ɗaga `revision` don rubutu sabunta a hankali), kuma ana adana sakamako (a hankali). Girman gungu da yawaita suna bin inji: **1 a kowane buƙata** akan samfurin cikin gini, **≤ 16 da ≤ 10 a lokaci guda** akan API ɗinka.
3. **Warware inji.** `TranslateProvider` (`builtin` / `custom`) yanke shawarar wane URL, maɓalli da samfuri sufuri ɗin ke amfani da su; injin biyu sai dai suna raba hanya guda ɗaya ta lamba da jerin harsuna guda, don sauya inji saitace guda ba saitin fasaloli daban ba.
4. **Sufuri ɗin** yana amfani da tashar **streaming** mai tabbatarwa ɗaya kamar taƙaitaccen bidiyo na AI — `AiChatService.streamChat` → `{base}/chat/completions` tare da `stream: true` (mai dacewa da kofofin da streaming kadai suke tallafawa) — an faɗaɗa shi don fassara za ta iya amfani da `apiUrl` / `apiKey` / `model` **nata** da tuta na `enable_thinking`. Canjin na **daidaitattun baya** ne, don taƙaitaccen bidiyo ya ci gaba da aiki ba canzawa ba.
5. **Jimlolin da aka shigar da cikin su** suna amfani da `uiTxP(template, args)`: jimla ɗaya mai masu wuri `{0}`/`{1}` ana fassara ta a matsayin maɓalli mai kwanciyar hankali (prompt ɗin na neman samfurin ya riƙe masu wuri), sannan a mayar da ƙimomi — don kirtani kamar `"共 {0} 条"` su fassara ba tare da lalata sauran canzawa ba.
6. **Teburin harsuna** (`app_language.dart`): kowane `AppLanguage` yana ɗauke da suna-mai-nuna, kirtanin prompt na `toModel` da ke ɗauke da ka'odin rubutu/yanki, da tuta ko jerin hukuma na bilibili ya ɗauke ta. Ka'odin rubutu (Mai sauƙi da Gargajiya, da kuma umarnin daidaiton yare) suna kai samfurin ne kawai ta prompt, kuma wani matakin tsabtacewa mai tabbatarwa a gefen mai amfani yana gyara haruffa masu ɓacewa bayan haka.
7. **Tsokaci** suna wucewa ta `uiTxComment(text, id)`, suna riƙe da `@ / [emoji] / #topic# / link` a matsayin tokens masu kwanciyar hankali; spans masu arziki waɗanda ke ɗauke da hanyoyi ana fassara su tare da riƙe mai gane hanyar, kuma saitin id na-kowane-tsokaci ne ke sarrafa maɓallin Asali ⇄ Fassara.
8. **Danmaku** (`danmaku/view.dart`): idan maɓallinsa yana kan, mai sauraron matsayi yana tafiya `[playhead, playhead + 15s]` daƙiƙa guda a lokaci, yana dumamar `uiTx()` a kan kowane abun cikin danmaku, don a riga an fassara su kafin su iso allo; kunna shi na share kuma sake zana canvas.
9. **Maɓallan ajiya**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **UI na Saituna**: shafi guda na matakin-farko "Fasalolin AI" (`lib/pages/setting/ui_translate/`) mai ɗauke da tubbai masu zaman kansu na taƙaitaccen bidiyo na AI da fassarar AI.

**CDN na duniya (`VideoUtils.getCdnUrl`).** Ana sa hannu kan URL ɗin rafi, kuma sake rubuta sunan mai wadata (host) na URL yana sa a ƙi shi da 403 — don haka kunnawa baya taɓa sake rubuta hosts. PiliBabel tana mayar da URL ɗin geo-routed da bilibili ke ba IP ɗin mai amfani, kuma idan jerin masu neman sun riga sun ƙunshi gefen ƙasashen waje (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`) ana fi son wannan. Saukewa, inda canza host ya zama lafiya, ƙari na fi son gefen Akamai na duniya kuma na juya zuwa wani mai nema mai sa-hanni idan layi ya tsaya ko ya ƙi ci gaba. Hanyoyin P2P na `/v/resource` har yanzu suna komawa ga relay ɗin da ake da shi don guje wa 404.

**Zaɓuɓɓukan ƙira / iyakokin da ake sani.** Domin ana sa kirtani a wurinsu maimakon a fitar da su cikin albarkatu, wasu paramitoci waɗanda ba na `Text` ba da wasu spans masu arziki har yanzu ana cika su a hankali. Kirtanin da suke maɓallan mantikawa (ana kwatanta su da `==`, ana amfani da su a matsayin sunayen kamar `简介`, ko lakabin enum da ake amfani da su a switches) da gangan **ba a sa musu sutura ba**, don guje wa lalata hali. Fassarar danmaku mafi kyau-a-ƙo'ina ce akan canvas mai gudu — a ƙarƙashin danmaku mai yawa sosai zaka iya ganin asali kaɗan kafin fassarar ta iso. Fassara na buƙatar hanyar sadarwa; idan babu, manufofin da ba Sinawa ba kawai basa aiki. Endpoint ɗin cikin gini sabis ɗin jama'a kyauta ne da bilibili ke gudanarwa — idan an taƙaita shi ko bai kasance ba, app ɗin na gaya maka kuma zaka iya komawa API ɗinka.

## Gini & tabbatarwa

Ana gina app ɗin da Flutter SDK mai patch da kuma kunshin `material_ui` / `cupertino_ui` mai patch ta `lib/scripts/patch.ps1` da `lib/scripts/build.ps1` (daidai kamar PiliNara / PiliPlus). GitHub Actions na samar da **APK na debug** a kowane push (`.github/workflows/ui-translate-debug.yml`), kuma **wallafa tag `v*` na ginawa da sakin Android, Windows da Linux** kai tsaye (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Dandamali
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

PiliBabel tana raba ginin **Android (APK), Windows da Linux** daga Releases; iOS/Pad ba a tattara su cikin wannan fork ba tukuna.

<br/>

## Saukewa

Ka ɗauki gini daga **Releases**, ko ka clone ma'ajiyar ka gina shi a gida.

### Arch Linux

Godiya ga [@nlsdt](https://github.com/nlsdt) game da kunshin (girke-girken PiliNara na wucewa zuwa PiliBabel).

```bash
sudo pacman -S pilinara      # ta hanyar ma'ajiyar Arch Linux CN
paru -S pilinara-bin         # ko ta hanyar AUR: pilinara-bin (wanda aka riga aka gina) / pilinara (tushen)
```

<br/>

## Rahoton fasalolin da aka gada (daga PiliNara / PiliPlus)

Abin da ke ƙasa duk ana ɗauke shi daga PiliNara (kuma, ta hanyar, PiliPlus); PiliBabel ta ƙara layin fassara na AI a saman.

**UI & daidaitawar dandamali**
- [x] An sake sunan app bisa dandamali don app da yawa su iya zama tare (PiliBabel na shiga tare da PiliNara)
- [x] An gyara rander Flutter a ƙarƙashin ɗakin-ƙarami na Xiaomi HyperOS ([#161086](https://github.com/flutter/flutter/issues/161086), ta [venera#467](https://github.com/venera-app/venera/pull/467)); motsin baya-mai-hasashen akan Android
- [x] Ana iya daidaita tsari/ƙidaya na katunan "Nawa"; gabatar da katunan-tarihi da sashin "kalla daga baya"
- [x] Sauya sidebar ta atomatik mai faɗin haɓakawa da za a iya daidaitawa; kwafi-hotuna daga dogon-danne / danna-dama; babban sabuntawa na salon MD3E

**Tsarin font** — tarin shigo-da-haɗaɗɗe mai jan gefe da content-hash, an haɗa fontunan danmaku cikin tarin guda, `loadFontFromList` tare da tallafin ttc, da sunayen dangi na hash-ASCII-mai-tsabta.

**Kunnawa, ɗakin-ƙarami & inganci** — ɗakin-ƙarami na cikin app (ja, gyara girma, tsalle SponsorBlock, PIP na tsarin atomatik, mashin ceto-kai na kai tsaye), kunnawar sauti-a-lokaci-guda, ƙara sauti a cikin app har zuwa 200%, yankin CDN na bidiyo na musamman da zaɓin node na yanki tare da gwajin jinkiri, ingancin tsoho na rabi/cikakken-allon daban, kullen gudu na hannu-sama, sarrafa madannin allo, lokutan SuperChat na kai tsaye, bugun zuciya na kai tsaye don kusancin magoya baya.

**Rubutun allo, AI & offline** — rubutun allo biyu-harshe da salo na biyu mai zaman kanta, nazarin rubutun allo na AI (endpoint na musamman mai dacewa da OpenAI, tsalle lokaci, samfuran, tattaunawar da aka adana, maida lafiya idan babu rubutu), fitar da WEBVTT/SRT, kallon cache-offline biyu tare da sarrafa babban fayil & adana metadata, fitar da saukewa zuwa babban fayil ɗin Download na jama'a (Android).

**Danmaku & toshe** — sikeli mai ƙarfi na danmaku-merge ([Pakku.js](https://github.com/xmcp/pakku.js)-salon), toshe regex na gani bisa-jeri tare da shigo/kaya fitar, tsalle-segment na SponsorBlock, mashin ci-gaba mai ƙarfin Gaussian-kernel.

**Tacewar Shawara / dinamik / tsokaci** — kalmomin take/UP/tasha, tsawon lokaci, ƙidayar-wasa, ƙimar-kauna, keɓancewar UP-da-ka-biyu, tacewar marar-izini/kuɗi-kawai, fararen jeri na rabawa, dinamik kasuwanci/marar-izini, keɓancewar tsokacin-UP-da-kanta da tsokacin-da-a-ɗaure, yanayin feed-merge na App+Web.

**Dinamik, bincike & bayanan mai amfani** — bayanan kanka na UP, mai-maye-suna-mai-bayanai a faɗin sarari 13 na suna, tsarin tsokaci-nested mai zaman kanta, tace kalmar maɓalli ta gida, tsalle gajeriyar-hanya b23.tv, badge kuɗi-kawai, maɓallin ɓoye-mai-fasa-shawara, nuni na XP na tsabar kudi.

**Inganta kai tsaye (Live)** — kwamandan sa tafiya-da-medal, DLNA cast mai son HLS, nuni lokaci SuperChat, layin sarrafawa na ƙasa na ɗakin-ƙarami don ceto-kai.

**Haɗin tsarin & kwamfuta** — SMTC na Windows, MPRIS na Linux (`audio_service_mpris`), sake ginin maganin audio-focus.

<details>
<summary>Cikakken fasalin/lissafin gwani na asali (kalmi-da-kalmi, daga PiliNara — danna don faɗaɗa)</summary>

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

## Sanarwa

PiliBabel aiki ne na sirri, mai sha'awa, ana bayar da shi **don koyo da gwadawa kawai**; da fatan za ka goge shi cikin **sa'o'i 24** na saukewa.

- PiliBabel app ce **ta ɓangare na uku mai zaman kanta kuma ba ta da hukuma** kuma **ba ta da alaƙa da, ba a amince da ita, kuma ba a tallafa mata ba daga bilibili**.
- An tattara dukkan API ɗin daga manyan hanyoyin jama'a na hukuma; **ba a samar da abun ciki na ɗan-karya, mai izini-fiye-da-kima, ko wucewar-biyan kuɗi ba**.
- **Fassarar AI na tafi a kan endpoint ɗin samfurin ɓangare na uku.** A tsoho, shi ne sabis ɗin Index-Translate na jama'a kyauta na bilibili; idan ka sauya zuwa API ɗinka, shi ne endpoint ɗin da ka daidaita. Ingancin fassara da biyayya alhakin mai amfani ne da mai ba da samfurin da aka zaɓa; wannan aikin **bai ɗauki samfuri ko maɓallin API ba**.
- Ka girmama haƙƙin mallaka da Sharuɗɗan Sabis ɗin bilibili. Ka yi amfani da hankali.

Da girmamawa ga marubutan asali da na upstream bisa gudunmawarsu ta tushen-buɗe:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — aikin iyaye na kai tsaye na PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — dangin samfurin fassara na tushen-buɗe da injin cikin gini ke kira

Idan wani abun ciki ya keta hakinka, da fatan za ka tuntuɓe mu don a cire shi.

<br/>

## Lasisi

PiliBabel na ƙarƙashin **GNU General Public License v3.0 (GPL-3.0)** — lasisi ɗaya da PiliNara, PiliPlus da PiliPala. Domin aiki ne mai tasowa, **PiliBabel dole ne a rarraba ta ƙarƙashin GPL-3.0**: ana iya amfani da ita, karatunta, rabawa da gyarawa, in ka riƙe lasisi ɗaya, sanarwar haƙƙin mallaka, da rubutun lasisin nan. Duba [`LICENSE`](./LICENSE).

Sassan ɓangare na uku (kunshin Flutter, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), da sauransu) suna ƙarƙashin lasisoshin nasu.

Font ɗin **LXGW WenKai** da aka haɗa yana da lasisi na daban ƙarƙashin **SIL Open Font License 1.1**; rubutun lasisinsa na cikin app a matsayin `assets/fonts/LXGWWenKai-OFL.txt`.

<br/>

## Godiya

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — dangin samfurin fassara na tushen-buɗe na bilibili, da endpoint ɗin jama'a kyauta mai bayan injin cikin gini
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — font ɗin Sinawa na tushen-buɗe da aka haɗa da app, ƙarƙashin SIL Open Font License 1.1
- da sauransu
- An yi wahayi daga "fassasar mahada ta AI" ta hukuma ta bilibili.
