<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Þriðja aðila-biðlari fyrir bilibili með gervigreindarþýðingu.</b></p>
    <p>Babel — rífur niður tungmálamúrinn, svo allir geti njótt bilibili á sínu eigin tungmáli.</p>
    <p>Sameinar opinbera 151-tungmálaskrá bilibili við 6 tungmál til viðbótar sem hún nær ekki yfir - hefðbundna kínversku, Wu á einföldu og hefðbundnu ritmáli, Hokkien frá meginlandinu og Taívan, og Zhuang.</p>
    <p>Þýðingin virkar strax úr kassanum á eigin ókeypis líkani bilibili — enginn API-lykill nauðsynlegur.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.nan.md">台語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.mn.md">Монгол</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.pt.md">Português</a> · <a href="README.bn.md">বাংলা</a> · <a href="README.th.md">ไทย</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.it.md">Italiano</a> · <a href="README.fa.md">فارسی</a> · <a href="README.fil.md">Filipino</a> · <a href="README.ur.md">اردو</a> · <a href="README.mr.md">मराठी</a> · <a href="README.te.md">తెలుగు</a> · <a href="README.ta.md">தமிழ்</a> · <a href="README.pa.md">ਪੰਜਾਬੀ</a> · <a href="README.gu.md">ગુજરાતી</a> · <a href="README.ha.md">Hausa</a> · <a href="README.sw.md">Kiswahili</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.my.md">မြန်မာ</a> · <a href="README.pl.md">Polski</a> · <b>Íslenska</b> · <a href="README.nb.md">Norsk</a> · <a href="README.fi.md">Suomi</a> · <a href="README.sv.md">Svenska</a> · <a href="README.da.md">Dansk</a> · <a href="README.be.md">Беларуская</a> · <a href="README.ug.md">ئۇيغۇرچە</a> · <a href="README.kk.md">Қазақша</a> · <a href="README.bo.md">བོད་ཡིག</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Heim" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Færslur" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Mitt" />
</div>

<br/>

> **Ábyrgðarlýsing.** PiliBabel er **óopinber, opins-grunnkóða, þriðja aðila** biðlari. Hann er **ekki tengdur, ekki styddur né kostaður af** bilibili / bilibili Inc. Hvert API er safnað frá opinberum opinberum endastöðvum; **engu greiddu efni er opnað né það brotið**. Vinsamlegast lestu fullu [Ábyrgðarlýsinguna](#ábyrgðarlýsing) og [Notkunarleyfishlutanum](#notkunarleyfi).

## Hvað er PiliBabel?

PiliBabel er **sjálfstæður þriðja aðila-fork byggður ofan á [PiliNara](https://github.com/Starfallan/PiliNara)**, og er hann um allt það sem PiliNara er:

```
bilibili (opinbert almennings-API)
        ▲
   PiliPala / PiliPalaX        — upphaflega verkefnið
        ▲
   PiliPlus                    — virkur fork
        ▲
   PiliNara                    — fork af PiliPlus (persónulegar breytingar)
        ▲
   PiliBabel  ← þú ert hér   — fork af PiliNara
```

PiliBabel varðveitir **hvern einasta eiginleika PiliNara / PiliPlus** (sjá [erfða eiginleikayfirlitið](#erfða-eiginleikayfirlit-frá-pilinara--piliplus) neðst) og bætir við **tveimur aðalhæfileika sem upphaflegu biðlararnir hafa ekki**:

> **Gervigreindarþýðing viðmóts og efnis** — allt forritið (viðmótstitlar, myndbandstitlar, nöfn UP-höfunda, athugasemdir, færslur, straumar og jafnvel danmaku (flakandi skjáummæli) í beinni útsendingu) er teiknað á því tungmáli sem **þú** velur.

Og frá og með 1.0 gerir hann það **beint úr kassanum**: þýðingarlíkanið er **innbyggt**. bilibili gaf út eigin fjölskyldu þýðingarlíkana, [Index-Translate](https://github.com/bilibili/Index-Translate), og birtir hana á ókeypis almenningsendastöð. PiliBabel kemur stilltur á hana, svo þýðingin virkar um leið og þú setur forritið upp — engin skráning, enginn lykill, enginn reikningur. Ef þú vilt heldur nota eigið líkan er eigin-API-leiðin enn til staðar, einni snertingu í burtu.

> **Hljóð í heyrnartólum sem í alvörunni heldur samstöðu** — með Bluetooth- eða þráðuðum heyrnartólum seinkar hljóðið ekki lengur eftir myndinni. Opinbera forritið fær þetta rétt fyrir sér; PiliNara og PiliPlus gera það ekki, úr kassanum. PiliBabel bidur mpv nú fyrst um **AudioTrack**, sem *mælir* töf hljóðúttaksins á sama hátt og opinberi biðlarinn, í stað **OpenSL ES**, sem aðeins *áætlar* hana.

## Aðaleiginleikar

- **Samstígað hljóð í heyrnartólum.** Spilarinn notar nú að sjálfgefnu **AudioTrack**-bakenda mpv (röðin `audiotrack,aaudio,opensles`) í stað **OpenSL ES**. AudioTrack tilkynnir *mælda* úttakstöf — hann les fjölda útspilaðra ramma og kynningartímastimpil tækisins — og það er nákvæmlega þannig sem opinbera bilibili-forritið og eigin `MediaSync` Android halda mynd og hljóði saman. OpenSL ES *áætlar* hana aðeins, svo á Bluetooth-heyrnartólum villaðist hljóðklukkan og myndin birtist of snemma. Í prófunum er seinkunin í raun horfin. Endurröððu henni hvenær sem er í Stillingar → Myndband → Hljóðúttakstæki.

- **Gervigreindarþýðing alls staðar.** Flakkflipar, myndbandaspjöld, upplýsingasíður, athugasemdir, færslur og svæðin Mitt / Uppáhald / Ferill / Skilaboð / Leit — víðtæk yfirferð nær yfir **~1.650+ viðmótsstrengi**, auk breytilegs efnis (titla, höfundarnöfn, fjölda aðgerða).
- **Tvær vélar, einn rofi.** *Innbyggt* (sjálfgefið) notar opinbera ókeypis endastöð bilibili, **Index-Translate-35B-A3B** — ekkert sem þarf að stilla. *Eigið API* heldur fyrri hegðun: beindu því að hvaða OpenAI-samhæfðri `/chat/completions` endastöð sem er, með eigin grunnslóð / lykli / líkani. Gervigreindareiginleikinn fyrir myndbandayfirlit og gervigreindarþýðingin hafa enn **algjörlega óháðar** endastöðvar og stillingar, bæði undir einni síðu fyrir **„Gervigreindareiginleika“**.
- **Einn tungmálalisti fyrir báðar vélar.** Marktungmálalistinn er ekki skiptur eftir vél — sami listi er boðinn hvora vélina sem þú velur. Hann sameinar **151 tungmál** opinbera líkansins hjá bilibili við **6 tungmál í viðbót sem það nær ekki yfir** — hefðbundna kínversku, Wu á einföldu og hefðbundnu ritmáli, Hokkien frá meginlandinu og Taívan, og Zhuang. Svæðis- og ritmálsafbrigði eru höfð **sem aðskildar færslur** í stað þess að vera sameinuð — marokkósk / egypsk / najdí / levantínsk arabíska er hvort um sig eigin valkostur, eins og kýrillísk-á-móti-latnesk serbíska, úsbekska og úrdú.
- **Samviskusamur um þekju.** Tungmál sem eru innan opinberu skrárinnar eru þekkt af líkani bilibili. Handfyllin utan hennar — hefðbundin kínverska, Wu á einföldu og hefðbundnu ritmáli, Hokkien frá meginlandinu og Taívan og Zhuang — birtast samt á listanum, merkt sem slík, svo þú vitir í einu glitti að betri niðurstaða gæti kallað á eigið líkan.
- **Þýddu einu sinni, svo er fast.** Hver upprunastrengur er þýddur **nákvæmlega einu sinni**; niðurstaðan er geymd staðbundið og **aldrei endurþýdd** þegar þú opnar skjá aftur — sama reglan og hjá opinbera biðlaranum, fyrir stöðugar, spáanlegar þýðingar.
- **Upprunalegt ⇄ Þýðing-víxl fyrir hverja athugasemd** (lítil táknmynd, ekki kínverskt orð). `@tilvísanir / [emoji] / #efni# / tenglar` eru varðveitt sem tákn, og **athugasemdir sem innihalda tengla þýðast samt á meðan tengillinn helst smellanlegur**.
- **Danmaku-þýðing (弹幕)** — sérstakur rofi í efstu hægri stjórnarröð spilarans, **slökkt sjálfgefið** og á bak við staðfestingu sem sjálf er þýdd. Þegar kveikt er á honum eru danmaku fyrir framan spilunarhausinn þýdd fyrirfram í **~15 sekúndna bylgjum** (að hoppa í miðjuna er meðhöndlað rétt, ekki frá byrjun), svo þýðingin er yfirleitt til reiðu þegar hún flakar inn á skjáinn.
- **Rofi fyrir hugsaða ham** (`enable_thinking`) til að velja milli gæða og hraða, auk hnappa fyrir **„prófa þýðingu“** og **hreinsa skyndiminni** í stillingunum.
- **Hröð tungmálaskipting**: magnbeiðnir með takmarkaðri samhliða vinnu gegn varanlegu skyndiminni; tungmálaskipting þvingar endurbyggingu núverandi skjás einu sinni, svo þú sért ekki skilin eftir að horfa á óþýddan texta. Slökkt á gervigreindarþýðingu endurheimtir allt viðmótið í upphaflegan texta og sendir engar beiðnir.
- **Kynning við fyrstu ræsingu.** Fyrsta skipti sem þú opnar forritið birtist ensk gluggi sem býðst til að kveikja á þýðingu. Samþykki kveikir á þýðingu, velur innbyggða líkanið, opnar stillingarsíðu gervigreindarinnar og spyr strax hvaða tungmál þú vilt — svo nýr notandi fer frá uppsetningu til þýdds forrits í tveimur snertingum.
- **Afspilun sem virkar um allan heim.** PiliBabel velur erlendu brúnina (altæka **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) sem staðsetningarleiðaða `playurl` bilibili býður þegar upp á, í stað þess að festa þig við meginlandshnút (Aliyun/Shenzhen) — svo notendur utan meginlands Kína stöðvast ekki lengur („hljóðið heldur áfram að spila, myndin frýs“). Þú getur samt stillt CDN handvirkt í Stillingum.
- **Síðan „Þema og litir“ í Material You-stíl.** Ljóst / dökkt / fylgja kerfi er valið af **þremur lifandi forsýnarkortum** — hvert þeirra teiknar smámætta útgáfu af raunverulegu viðmóti í nákvæmlega þeim litum sem hamurinn myndi nota („fylgja kerfi“-kortið er skipt á ská, ljóst yfir dömpu). Fyrir neðan þau: **breytilegur litur** (tekinn af veggfóðri kerfisins þar sem tækið styður það), **dökkt með miklum birtuskilum** (alveg svört yfirborð, auðveldara fyrir augun um nótt) og **alltaf-dökkur spilari**. Liturhlutinn varðveitir alla FlexScheme-litapölettuna — **19 grunnliti** auk sérstaks **„pölettustíls“** sem ákvarðar hvernig hver geymslulitur er leiddur af grunnlitnum, óháð því hvaða grunnlit þú velur.
- **LXGW WenKai fylgir forritinu.** Leturgerðin **LXGW WenKai (霞鹜文楷)** er **pakkað með og sett sem sjálfgefin** — hlý, mjög læsileg kínversk leturgerð sem þú færð um leið og þú setur upp, í stað þess að leita að einni í veljara. Hún gildir um allt viðmótið *og* um danmaku. Þú getur samt skipt aftur yfir í kerfisleturgerðina, valið hvaða uppsetta kerfisleturgerð sem er, eða flutt inn eigin `.ttf` / `.otf` / `.ttc`; leturgerð sem þú hafðir valið sérstaklega áður er varðveitt í gegnum uppfærsluna. Þykkt og stærð eru enn stillanlegar eins og áður.

## Staðbært hljóðskyndiminni og niðurhal í möppu (eingöngu í PiliBabel)

Tveir eiginleikar sem PiliNara / PiliPlus uppstreymis hafa ekki — báðir ætlaðir til að þú eigir fjölmiðlana þína virkilega án nettengingar.

### Vista hljóð í skyndiminni (hljóðeitt staðbært skyndiminni)

- **Lagið, ekki myndbandið.** Færslan *Vista hljóð í skyndiminni* situr beint fyrir neðan *Vista myndband í skyndiminni* í valmynd myndbandasíðunnar, auk sérstaks hnapps fyrir hljóðskyndiminni í efstu stiku hlustunarsíðunnar.
- **Veldu gæðaflokk.** Hi-Res tapslaust, Dolby Atmos, 192K, 132K eða 64K — sami fyrirstillti listi og gæðaveljari myndbandanna notar.
- **Upprunalegt gagnasafn, engin umkóðun.** Skránni er skrifað nákvæmlega eins CDN þjónar henni: `m4a`, `mp3`, `flac`, `wav`, `aac` eða `ogg`.
- **Eigin eining.** Skyndiminnissíðan er skipt í *Myndbönd í skyndiminni* / *Hljóð í skyndiminni* og man eftir því hvora eininguna þú varst á síðast.
- Þegar smellt er á hljóðfærslu í skyndiminni opnast hljóðspilarinn strax; færslum má eyða einum og einum eða í stórum stíl.

### Niðurhal í staðværa möppu

- **Eigin valmyndarfærsla.** *Niðurhal í staðværa möppu* er sér færsla í valmynd myndbandasíðunnar, rétt undir *Vista hljóð í skyndiminni* — að setja í skyndiminni inni í forritinu og að vista í möppu eru tvær ólíkar aðgerðir.
- **Sækja myndband eða sækja hljóð.** Færslan spyr fyrst hvort þú viljir, og svo um gæðaflokk (gæðaveljari myndbands / hljóðs).
- **Þín mappa, þínar reglur.** Veldu hvaða möppu sem er í gegnum skráastjóra kerfisins (Stillingar → *Niðurhal í staðværa möppu*), og breyttu henni eða hreinsaðu úr henni hvenær sem þú vilt. Ef þú hefur ekki enn valdið opnast möppuveljarinn á staðnum.
- **Skrár sem spila beint.** Myndband er sótt sem einn sameinaðan straum (`fnval=1`), svo það sem lendir á diski er venjulegt MP4 sem þú getur gefið hvaða spilara sem er — engar hliðarstraumar sem þarf að sauma saman.
- **Hljóð heldur upprunalegu sniði sínu** — engin umkóðun, nákvæmlega eins og í skyndiminni forritsins.
- Skrár eru nefndar eftir titli myndbandsins og yfirskrifa aldrei fyrirliggjandi niðurhal.

## Þýðingavélarnar tvær

| | Innbyggt (sjálfgefið) | Eigið API |
|---|---|---|
| Líkan | **Index-Translate-35B-A3B** frá bilibili | hvaðeina sem er OpenAI-samhæft |
| Endastöð | `index-translate.bilibili.com/v1` | þín grunnslóð |
| API-lykill | **ekki nauðsynlegur** | þinn |
| Kostnaður | ókeypis | hvað þjónustuaðilinn þinn rukkar |
| Beiðnir | einn strengur á beiðni | í bylgjum (≤ 16 á beiðni) |
| Auka tungmál | — | hvert tungmál sem líkan þitt kannt |

**Af hverju ein beiðni í einu fyrir innbyggðu vélina.** Index-Translate er *sérfræðingur* í þýðingum, og samskiptareglan sem höfundar þess lýsa er sniðmát fyrir staka færslu („þýddu eftirfarandi texta yfir á X, sendu aðeins þýðinguna“). PiliBabel sendir því einn streng á beiðni á þessari vél í stað tölusetta-lista/JSON-fylkis magnsniðmátsins sem hann notar fyrir eigin-API-uppsetningar. Endastöðin er ókeypis, svo ekkert er til að vinna á að veðja á framleiðslu í magni — þetta er meðvituð víxlsvöð á nokkrum fleiri beiðnum gegn mun færri möguleikum á bilun.

**Uppfærsla frá 0.3.x.** Eigin API-stillingar þínar — grunnslóð, lykill og líkan — eru **skildar nákvæmlega eins og þú stilltir þeim**. Vál vélar fellur einfaldlega á innbyggða líkanið, svo í fyrstu ræsingu eftir uppfærslu verður þú á ókeypis líkani bilibili; opnaðu *Stillingar → AI → Gervigreindareiginleikar → þýðingavél* og skiptu aftur í *Eigið API* til að fara augabragðar aftur í fyrra uppsetninguna.

## Hvernig gervigreindarþýðing viðmótsins virkar (tæknilegt)

Geymslan hefur **ekkert i18n / ARB auðlindalag** — viðmótsstrengir eru harðkóðuð kínverska. Í stað þess að endurskrifa hverja græju bætir PiliBabel þunnu þýðingarlagi ofan á:

1. **Víðvært uppflettiumbrot.** `lib/services/ui_translate/` birtir efsta-stigs `uiTx(String src)`. Græjutexti sem áður var `Text('中文')` verður `Text(uiTx('中文'))`. Forskrifaður **kóðabreytingarmaður** framkvæmdi þetta um allt verkefnið (`tool/ui_translate_*.py`) — um **223 skrár / ~1.650+ strengi** — og sleppti sjálfvirkt nú ógilda `const`-lykilorði þar sem þörf var á (þ.m.t. algerar gerðir eins og `const X<T>(...)` og punktað nöfn eins og `const Positioned.fill(...)`, og breytti `static const` lista/kort-yfirlýsingum í `static final`).
2. **`GetxService`-kjarni** (`ui_translate_service.dart`):
   - varanlegt **uppruni → þýðing** skyndiminni (með GetStorage að baki), svo hver strengur er þýddur einu sinni og endurnýttur að eilífu;
   - `tx()` les fyrst `RxInt revision`, ákveður svo: ef slökkt → skila upprunanum; ef markið er **einfölduð kínverska (`zh-CN`)**, skila upprunanum án API-beiðni (efni Bilibili í uppruna er yfirgnæfandi einfölduð kínverska). Hvert annað mark — þ.m.t. hefðbundin kínverska, kantónska, Wu/sjanghverska og Hokkien/Min Nan — fer í gegnum stilltu vélina; að tilheyra kínversku fjölskyldunni ein skipar ekki yfir þýðingu. Svo er þjónað úr skyndiminni eða **sett í biðröð**;
   - strengir í biðröð eru skolaðir út af **vinnuflokki** með **stigvaxandi beitingu á hverjum hluta** (hver hluti sem kemur bakkar `revision` svo textinn uppfærist smám saman), og niðurstöður eru **varanlega geymdar** (hemjaðar). Magnstærð og samhliða fylgja vélinni: **1 á beiðni** á innbyggða líkaninu, **≤ 16 með ≤ 10 í flugi** á eigin API.
3. **Upplausn vélar.** `TranslateProvider` (`builtin` / `custom`) ákvarðar hvaða URL, lykil og líkan flutningurinn notar; að öðru leyti deila báðar vélar einni kóðaleið og einum tungmálalista, svo að skipta um vél er ein stilling og aldrei annar eiginleikahópur.
4. **Flutningurinn** endurnýtar sömu sannprófuðu **streymi**-rás og gervigreindayfirlit myndbanda — `AiChatService.streamChat` → `{base}/chat/completions` með `stream: true` (samhæft við gáttir sem aðeins styðja streymi) — framlengdur svo þýðing geti notað **sína eigin** `apiUrl` / `apiKey` / `model` og `enable_thinking`-flögg. Breytingin er **afturábakssamhæf**, svo myndbandayfirlit heldur áfram að virka óbreytt.
5. **Setningar með innskotum** nota `uiTxP(template, args)`: heil setning með `{0}`/`{1}`-vísum er þýdd sem einn stöðugur lykil (kvaðningin bidur líkanið að varðveita vísunum), og svo eru gildin sett inn aftur — svo strengir á sniðinu `"共 {0} 条"` þýðast án þess að skemma breytilegu hlutana.
6. **Tungmálatafla** (`app_language.dart`): hvert `AppLanguage` ber sýnilegt sjálfsnafn, `toModel`-kvaðningastreng sem kóðar ritmáls-/svæðisvenjur, og flögg um hvort opinber skrá bilibili þekkir það. Ritmálsreglur (einfalt á móti hefðbundnu, og tilskipanirnar um mállýskusamræmi) ná til líkansins aðeins í gegnum kvaðninguna, og ákveðin samræmingarumferð á biðlaranum lagar lausa stafi að því búnu.
7. **Athugasemdir** fara í gegnum `uiTxComment(text, id)`, sem varðveitir `@ / [emoji] / #efni# / tengill` sem heil tákn; textríkir hlutar sem bera tengla eru þýddir á meðan tengþekkirinn er varðveittur, og auðkennissett fyrir hverja athugasemd keyrir Upprunalegt ⇄ Þýðing-víxlinn.
8. **Danmaku** (`danmaku/view.dart`): þegar rofi hans er á, gengur staðsetningarhlustari yfir `[playhead, playhead + 15s]` einni sekúndu í einu og hitar upp `uiTx()` á efni hvers danmaku, svo atriði eru forþýdd áður en þau ná til skjásins; að kveikja á honum hreinsar og endurteiknar strigann.
9. **Geymslulyklar**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Stillingarviðmót**: ein fyrsta-stigs síða, „Gervigreindareiginleikar“ (`lib/pages/setting/ui_translate/`), með óháðum blokkum fyrir gervigreindayfirlit myndbanda og gervigreindarþýðingu.

**Altækt CDN (`VideoUtils.getCdnUrl`).** Straumslóðir eru undirritaðar, og að endurskrifa hýsilnafn slóðar fær hana hentri með 403 — svo afspilun endurskrifar aldrei hýsli. PiliBabel skilar staðsetningar-leiðuðu slóðinni sem bilibili gefur IP-tölu biðlarans, og þegar frambjóðendalistinn inniheldur þegar erlenda brún (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`) er hún fyrir valinu. Niðurhal, þar sem skipting hýsils er örugg, kjósa auk þess altæku Akamai-brúnina og snúa yfir á næsta undirritaða frambjóðanda þegar lína stöðvast eða hafnar endurtöku. Hráar `/v/resource` P2P-tenglar falla samt aftur í fyrirliggjandi endurvarp til að forðast 404.

**Hönnunarvalkostir / þekkt takmörk.** Þar sem strengjum er pakkað inn á staðnum í stað þess að taka þá út í auðlindir, eru nokkrar strengjabreytur utan um `Text` og nokkrir textríkir hlutar enn að fyllast stig af stigi. Strengir sem tvítaka sem **röklyklar** (samanbornir með `==`, notuð sem flipanöfn eins og `简介`, eða tölusetningarmerki notuð í rofum) er **ekki** pakkað almennt inn, viljandi, til að brjóta ekki hegðun. Danmaku-þýðing er besta-ávinningur á flakandi striga — undir afar þéttu danmaku gætirðu stuttlega séð upprunalega textann áður en þýðingin kemur. Þýðing þarf net; án þess taka mark utan kínversku einfaldlega ekki gildi. Innbyggða endastöðin er ókeypis almenningsþjónusta rekin af bilibili — ef hún fer einhvern tíma í takmörkun eða er ekki tiltæk, segir forritið þér það og þú getur skipt yfir í eigið API.

## Byggja og sannreyna

Forritið er byggt með bættu Flutter SDK ásamt bættum `material_ui` / `cupertino_ui` pökkum í gegnum `lib/scripts/patch.ps1` og `lib/scripts/build.ps1` (nákvæmlega eins og PiliNara / PiliPlus). GitHub Actions framleiðir **aflúsunar-APK** við hvern ýtti (push) (`.github/workflows/ui-translate-debug.yml`), og **birting merkis `v*` byggir sjálfvirkt og gefur út Android, Windows og Linux**-efni (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Kerfi
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

PiliBabel gefur út **Android (APK), Windows og Linux**-byggingar úr Releases; iOS/Pad er ekki pakkað í þessum fork ennþá.

<br/>

## Niðurhal

Náðu í byggingu úr **Releases**, eða klónaðu geymsluna og byggðu hana staðbundið.

### Arch Linux

Þakkir til [@nlsdt](https://github.com/nlsdt) fyrir pökkunina (uppskrift PiliNara gildir einnig fyrir PiliBabel).

```bash
sudo pacman -S pilinara      # í gegnum Arch Linux CN-safngeymsluna
paru -S pilinara-bin         # eða í gegnum AUR: pilinara-bin (forbyggð) / pilinara (frumkóði)
```

<br/>

## Breytingaskrá: 2.6.x → 3.3.4

- **2.6.x** — hljóðskyndiminni (aðskildir einingar fyrir myndband og hljóð, man síðustu val, inngangar á myndbandssíðu, hljóðsíðu og í hljóðspilara; upprunalegt snið varðveitt; gæði valanleg) og niðurhal í tækið (sér valmyndaratriði: fyrst myndband/hljóð, svo gæði; ef engin mappa er stillt opnast skráarval kerfisins).

- **3.0.x–3.1.0** — sjálflögrun netkerfis erlendis: heilsa hvers hýsils með skiptingu milli aðal- og varaleiðar, DNS-upplausn með skyndiminni, forhitun tenginga, kæling eftir áhættustýringu (412), svæðisgreining með handvirkri vali, CDN-hraðapróf deilt með API-laginu; frambuffur spilarans fylgir nú bitahraða myndbandsrásar.

- **3.2.0–3.3.3** — netgrunnur í stíl opinberu appinnar: fingrafar beiðni (buvid/fp/session_id/env), varaskipti gRPC-hýsla, endurtekningarsía, takmörk samhliða beiðna á hvern hýsil, forhleðsla fyrstu straums við kalt ræsingar, opinberir viðburðarfæribreytur straums, röð CDN-frambjóðenda með erlendum varaleiðum; forhleðsla annarrar síðu, takmörkuð biðröð fyrir forhleðslu forsíðumynda, forhleðsla spilunarslóða; síðan teikning dynamics (P3) um gRPC og lagfæringar: þýðingarvilla á lengd buffurs á hljóðsíðu og tegundarvilla í forhleðslu athugasemda sem gerði hverja tilraun að falla samstundis.

- **3.3.4** — dynamics-spjöld fyrir greiddar færslur, smáforrit, efnasöfn og áskriftir; löguð vandamál þar sem forsíðumyndir birtust alls ekki á fyrstu skjá heimasíðu; breytingar frá PiliNara teknar inn (stöðustika, niðurhal heldur áfram eftir að ferli lokast, uppfærsla media-kit, sniðganga svarts myndbands í Wayland, val á hljóðgæðum við skyndiminni); endurskoðun AI-þýðinga á öllum viðmótstexta sem bætt var við frá 3.0.5; þessi skrá.

## Erfða eiginleikayfirlit (frá PiliNara / PiliPlus)

Allt sem fyrir neðan er erfð frá PiliNara (og, í öðru lagi, frá PiliPlus); PiliBabel bætir gervigreindarþýðingarlagerinu ofan á.

**Viðmót og aðlögun að kerfum**
- [x] Forrit endurnefnt eftir kerfi svo margir biðlarar geti verið hlið við hlið (PiliBabel setst upp ásamt PiliNara)
- [x] Lagað Flutter-teiknun undir smáglugga Xiaomi HyperOS ([#161086](https://github.com/flutter/flutter/issues/161086), í gegnum [venera#467](https://github.com/venera-app/venera/pull/467)); fyrirsjáanleg bak-hreyfing á Android
- [x] Sérsniðin röð/fjöldi „Mitt“-spjalda; forsýning ferilspjalda og „horfa seinna“-hlutar
- [x] Sjálfvirk skipting hliðarstiku með stillanri kveikjubreidd; afritun myndar úr löngu-þýstri / hægri-smelli; stór MD3E-stílugleðing

**Leturgerðakerfi** — sameinuð innflutningslaug með tvíeyðingu eftir innihals-hash, danmaku-leturgerðum sameinuðum í sömu laug, `loadFontFromList` með ttc-stuðningi, og hreinum ASCII-hash-fjölskyldunöfnum.

**Afspilun, smágluggi og gæði** — smágluggi í forritinu (draga, stærða, SponsorBlock-slepp, sjálfvirk kerfis-PIP, sjálfbjargarstika í beinni), samhliða hljóðafspilun, hljóðstyrkur í forritinu upp í 200 %, sérsniðið CDN-lén myndbanda og val á svæðishnúti með töfprófun, aðskilin sjálfgefin gæði fyrir hálfa-/fulla skjá, læsing hraða við stroku upp, lyklaborðsstýring á spjaldtölvu, tímastimpilar SuperChat í beinni, hjartsláttur beinnar fyrir aðdáendunái.

**Skjátextar, gervigreind og án nettengingar** — tvítyngdir skjátextar með sjálfstæðri stílfæringu aukaskjátexta, gervigreindagreining skjátexta (sérsniðin OpenAI-samhæf endastöð, tímastimpilhopp, sniðmát, varanlegar samtöl, mýkt varasnið þegar skjátexta vantar), WEBVTT/SRT-útflutningur, tvíúsýn skyndiminnis án nettengingar með möppustýringu og varanlegum lýsigögnum, útflutningur niðurhala í opinberu Niðurhalsmöppuna (Android).

**Danmaku og útilokun** — endurbætt skölun sameinaðs danmaku (í stíl [Pakku.js](https://github.com/xmcp/pakku.js)), listabyggð sjónræn regex-útilokun með inn-/útflutningi, SponsorBlock-slepp við leit inn í hluta, háorku-framvindustika með Gaussískri kjarna.

**Síun ráðlegginga / færsla / athugasemda** — lykilorð í titli/UP/rás, lengd, spilarafjöldi, líkan-hlutfall, undanþága fyrir UP sem fylgt er, síun óheimillar/einungis-gjald-efnis, sameiginlegur hvítlisti, viðskipta-/óheimilar færslur, undanþágur athugasemda UP-höfundar sjálfs og festra athugasemda, App+Vefur sameinaður straumi.

**Færslur, leit og notendaupplýsingar** — sérsniðnir minnispunktar fyrir UP, minnispunktur-í-stað-gælunafns yfir 13 nafnastaði, sjálfstæð röðun hreiðraðra athugasemda, staðbundin lykilorðasíun leitar, b23.tv-styttslóðarhopp, einungis-gjald-merki, rofi fyrir að fela ráðleggingarástæður, sýning mynta-XP.

**Endurbætur beinna útsendinga** — spjald fyrir að klæðast aðdáendamerkjum, DLNA-útsending sem kjósa HLS, tímasýning SuperChat, neðri stjórnarstika smáglugga fyrir sjálfbjörgun.

**Kerfissamþætting og skjáborð** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), endurbyggð meðhöndlun hljóðfókusar.

<details>
<summary>Fullur upprunalegur eiginleika-/gátlisti (orðréttur, frá PiliNara — smelltu til að fletta út)</summary>

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

## Ábyrgðarlýsing

PiliBabel er persónulegt verkefni, unnið af áhuga, og er gefið út **einungis til náms og prófunar**; vinsamlegast eyddu því innan **24 klukkustunda** frá niðurhali.

- PiliBabel er **óopinber þriðja aðila**-biðlari og er **ekki tengdur, ekki styddur né kostaður af bilibili**.
- Öll API eru söfnuð frá opinberum opinberum endastöðvum; **engu brotinnu, ofréttinda- eða greiðsluveggjar-brjótandi efni er veitt**.
- **Gervigreindarþýðing keyrir á endastöð líkans hjá þriðja aðila.** Sjálfgefið er það eigin ókeypis almenningsþjónusta bilibili, Index-Translate; ef þú skiptir yfir í eigið API er það endastöðin sem þú stilltir. Gæði þýðinga og reglufylgni liggur á notandanum og valinni líkanaveitu; þetta verkefni hýsir **ekkert líkan og engan API-lykil**.
- Virðu höfundarrétt og notkunarskilmála bilibili. Notaðu á ábyrgan hátt.

Með virðingu fyrir upprunalegu og uppstreymishöfundunum fyrir framlag þeirra til opinna kóða:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — beint foreldriverkefni PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — opinbera þýðingarlíkanafjölskyldan sem innbyggða vélin kallar á

Ef eitthvað efni brýtur réttindi þín, vinsamlegast hafðu samband vegna fjarlægingar.

<br/>

## Notkunarleyfi

PiliBabel er gefið út undir **GNU General Public License v3.0 (GPL-3.0)** — sama leyfi og PiliNara, PiliPlus og PiliPala. Þar sem um afleitt verk er að ræða **verður PiliBabel einnig dreift undir GPL-3.0**: þú mátt nota, rannsaka, deila og breyta því frjálslega, að því gefnu að þú haldir sama leyfi, höfundarréttartilkynningum og þessum leyfistexta. Sjá [`LICENSE`](./LICENSE).

Hlutar frá þriðja aðila (Flutter-pakkar, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio) o.s.frv.) eru áfram undir eigin leyfum sínum.

Leturgerðin **LXGW WenKai**, sem fylgir með, er leyfð sérstaklega undir **SIL Open Font License 1.1**; leyfistexti hennar fylgir forritinu sem `assets/fonts/LXGWWenKai-OFL.txt`.

<br/>

## Þakkir

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — opinbera þýðingarlíkanafjölskylda bilibili, og ókeypis almenningsendastöðin á bak við innbyggðu vélina
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — opinbera kínverska leturgerðin sem pakkað er með forritinu, undir SIL Open Font License 1.1
- og fleira
- Innblásið af opinberu „gervigreindar-viðmótaþýðingu“ bilibili.
<br/>

---

> **Documentation language note / 文档语言说明.** This README and its translations are written and maintained with the help of AI translation tooling; the English version is the reference if any wording looks inconsistent. 本仓库的 README 及各语言译文在 AI 翻译工具的协助下撰写与维护；若各语言版本表述不一致，以英文版为准。
