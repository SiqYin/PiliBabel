<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Kolmannen osapuolen bilibili-asiakasohjelma tekoälykäännöksillä.</b></p>
    <p>Babel — purkaa kieliesteet, jotta jokainen voisi nauttia bilibilistä omalla kielellään.</p>
    <p>Yhdistää bilibilin virallisen 151 kielen luettelon 6:een lisäkieleen, joita se ei kata - perinteinen kiina, wu sekä yksinkertaistettuna että perinteisenä, mantereen ja Taiwanin hokkien sekä zhuang.</p>
    <p>Käännös toimii suoraan asennuksesta bilibilin omalla ilmaisella mallilla — API-avainta ei tarvita.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.nan.md">台語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.mn.md">Монгол</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.pt.md">Português</a> · <a href="README.bn.md">বাংলা</a> · <a href="README.th.md">ไทย</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.it.md">Italiano</a> · <a href="README.fa.md">فارسی</a> · <a href="README.fil.md">Filipino</a> · <a href="README.ur.md">اردو</a> · <a href="README.mr.md">मराठी</a> · <a href="README.te.md">తెలుగు</a> · <a href="README.ta.md">தமிழ்</a> · <a href="README.pa.md">ਪੰਜਾਬੀ</a> · <a href="README.gu.md">ગુજરાતી</a> · <a href="README.ha.md">Hausa</a> · <a href="README.sw.md">Kiswahili</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.my.md">မြန်မာ</a> · <a href="README.pl.md">Polski</a> · <a href="README.is.md">Íslenska</a> · <a href="README.nb.md">Norsk</a> · <b>Suomi</b> · <a href="README.sv.md">Svenska</a> · <a href="README.da.md">Dansk</a> · <a href="README.be.md">Беларуская</a> · <a href="README.ug.md">ئۇيغۇرچە</a> · <a href="README.kk.md">Қазақша</a> · <a href="README.bo.md">བོད་ཡིག</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Koti" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Julkaisut" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Oma" />
</div>

<br/>

> **Vastuuvapauslauseke.** PiliBabel on **epävirallinen, avoimen lähdekoodin, kolmannen osapuolen** asiakasohjelma. Se **ei ole sidoksissa bilibiliin / bilibili Inc:iin, eikä bilibili ole hyväksynyt tai sponsoroinut sitä**. Jokainen API on koottu virallisista julkisista rajapinnoista; **maksullista sisältöä ei avata eikä murreta**. Lue koko [Vastuuvapauslauseke](#vastuuvapauslauseke) ja [Lisenssi](#lisenssi) -osiot.

## Mikä PiliBabel on?

PiliBabel on **itsenäinen kolmannen osapuolen forkki, joka on rakennettu [PiliNaran](https://github.com/Starfallan/PiliNara) päälle**, ja se perii kaiken, mitä PiliNara perii:

```
bilibili (virallinen julkinen API)
        ▲
   PiliPala / PiliPalaX        — alkuperäinen projekti
        ▲
   PiliPlus                    — aktiivinen forkki
        ▲
   PiliNara                    — PiliPlusen forkki (omia muutoksia)
        ▲
   PiliBabel  ← täällä olet   — PiliNaran forkki
```

PiliBabel säilyttää **jokaisen PiliNaran / PiliPlusen ominaisuuden** (katso [peritty ominaisuuslista](#peritty-ominaisuuslista-pilinaralta--piliplusilta) alempana) ja lisää **kaksi pääominaisuutta, joita ylävirran asiakasohjelmissa ei ole**:

> **Tekoälykäännös käyttöliittymässä ja sisällössä** — koko sovellus (käyttöliittymän tekstit, videon otsikot, UP-käyttäjien nimet, kommentit, julkaisut, syöte ja jopa suoratoiston danmaku (ruudulla vierivät kommentit)) näkyy sillä kielellä, **jonka sinä valitset**.

Ja versiosta 1.0 alkaen se toimii **suoraan asennuksesta**: käännösmalli on **sisäänrakennettu**. bilibili avasi oman käännösmalliperheensä, [Index-Translaten](https://github.com/bilibili/Index-Translate), lähdekoodin ja tarjoaa sitä ilmaisesta julkisesta rajapinnasta. PiliBabel toimitetaan osoittamana siihen, joten käännös toimii heti kun asennat sovelluksen — ei rekisteröitymistä, ei avainta, ei laskua. Jos haluat mieluummin käyttää omaa malliasi, oma-API-polku on yhä olemassa, yhden napautuksen päässä.

> **Kuulokeääni, joka oikeasti pysyy synkronissa** — Bluetooth- tai langollisilla kuulokkeilla ääni ei jää enää kuvasta jälkeen. Virallinen sovellus hoitaa tämän oikein; PiliNara ja PiliPlus eivät, sellaisenaan. PiliBabel pyytää nyt mpv:ltä ensin **AudioTrackia**, joka *mittaa* äänen toistoviiveen samalla tavalla kuin virallinen asiakasohjelma, **OpenSL ES**:n sijaan, joka vain *arvioi* sen.

## Keskeiset ominaisuudet

- **Kuulokeääni synkronissa.** Soitin käyttää nyt oletuksena mpv:n **AudioTrack**-taustajärjestelmää (järjestys `audiotrack,aaudio,opensles`) **OpenSL ES**:n sijaan. AudioTrack ilmoittaa *mitatun* toistoviiveen — se lukee toistettujen kehysten määrän ja laitteen esitysaikaleiman — mikä on täsmälleen se tapa, jolla virallinen bilibili-sovellus ja Androidin oma `MediaSync` pitävät kuvan ja äänen yhdessä. OpenSL ES vain *arvioi* sitä, joten Bluetooth-kuulokkeilla äänikello ajautui ja kuva näytettiin liian aikaisin. Testeissä viive on käytännössä kadonnut. Järjestystä voi muuttaa milloin tahansa kohdasta Asetukset → Video → Äänen toistolaite.

- **Tekoälykäännös kaikkialla.** Navigointivälilehdet, videokortit, tietosivut, kommentit, julkaisut sekä Oma / Suosikit / Historia / Viestit / Haku -näkymät — yleisläpikäynti kattaa **n. 1 650+ käyttöliittymätekstiä** sekä dynaamisen sisällön (otsikot, tekijöiden nimet, toimintamäärät).
- **Kaksi moottoria, yksi kytkin.** *Sisäänrakennettu* (oletus) käyttää bilibilin virallista **Index-Translate-35B-A3B**-ilmaisrajapintaa — mitään ei tarvitse määrittää. *Oma API* säilyttää aiemman toiminnan: osoita se mihin tahansa OpenAI-yhteensopivaan `/chat/completions`-rajapintaan omalla perusosoitteella / avaimella / mallilla. Tekoälyvideotiivistelmä ja tekoälykäännös käyttävät edelleen **täysin erillisiä** rajapintoja ja asetuksia, ja molemmat ovat yhden **»Tekoälyominaisuudet»**-sivun alla.
- **Yksi kieliluettelo, molemmat moottorit.** Kohdekieliluetteloa ei jaeta moottorittain — sama luettelo tarjotaan kumman tahansa moottorin kanssa. Se yhdistää bilibilin virallisen mallin **151 kieltä** **6:een lisäkieleen, joita se ei kata** — perinteinen kiina, wu sekä yksinkertaistettuna että perinteisenä, mantereen ja Taiwanin hokkien sekä zhuang. Alue- ja kirjoitusjärjestelmämuunnelmat pidetään **erillisinä luettelokohteina** yhdistämisen sijaan — marokkolainen / egyptiläinen / najdi / levanttiinarabia ovat kukin oma valintansa, samoin kyrillinen vastaan latinalainen serbia, usbekki ja urdu.
- **Rehellisyys kattavuudesta.** Virallisen luettelon kielet kattaa bilibilin malli. Sen ulkopuoliset muutamat — perinteinen kiina, yksinkertaistettu ja perinteinen wu, mantereen ja Taiwanin hokkien sekä zhuang — näkyvät silti luettelossa, sellaisinaan merkittyinä, jotta näet yhdellä silmäyksellä, että parempi tulos voi vaatia oman mallisi.
- **Käännä kerran, sitten se pysyy.** Jokainen lähdeteksti käännetään **täsmälleen kerran**; tulos tallennetaan paikallisesti eikä sitä **koskaan käännetä uudelleen**, kun avaat näytön uudestaan — sama periaate kuin virallisessa asiakasohjelmassa, vakaiden, ennustettavien käännösten vuoksi.
- **Alkuperäinen ⇄ Käännös -vaihto jokaisesta kommentista** (pieni kuvake, ei kiinankielinen sana). `@maininnat / [emoji] / #aiheet# / linkit` säilytetään tokeneina, ja **hyperlinkkejä sisältävät kommentit käännetään linkin pysyessä napsautettavana**.
- **Danmakun (弹幕) käännös** — oma kytkin soittimen oikeassa yläkulmassa olevassa ohjausrivissä, **poissa päältä oletuksena** ja vahvistuksen takana, jonka oma teksti on käännetty. Kun se on käytössä, toistokohtaa edeltävät danmakut käännetään etukäteen **n. 15 sekunnin erissä** (keskelle siirtyminen käsitellään oikein, ei alusta alkaen), joten käännös on yleensä valmiina kun se vierii ruutuun.
- **Ajattelutilan kytkin** (`enable_thinking`) laadun ja nopeuden valintaan, sekä **»testikäännös»**- ja **välimuistin tyhjennys** -painikkeet asetuksissa.
- **Nopea kielen vaihto**: eräpyynnöt rajatulla rinnakkaisuudella pysyvää välimuistia vasten; kielen vaihto pakottaa nykyisen näytön rakennettavaksi uudelleen kerran, joten et jää tuijottamaan kääntämätöntä tekstiä. Tekoälykäännöksen sammuttaminen palauttaa koko käyttöliittymän alkuperäiseen tekstiin eikä lähetä yhtään pyyntöä.
- **Aloitusopas ensimmäisellä käynnistyksellä.** Kun avaat sovelluksen ensimmäisen kerran, englanninkielinen valintaikkuna tarjoaa käännöksen käyttöönottoa. Hyväksyminen ottaa käännöksen käyttöön, valitsee sisäänrakennetun mallin, avaa tekoälyasetussivun ja kysyy heti, mitä kieltä haluat — joten uusi käyttäjä pääsee asennuksesta käännettyyn sovellukseen kahdella napautuksella.
- **Toisto, joka toimii koko maailmassa.** PiliBabel valitsee ulkomaisen reunapalvelimen (globaali **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`), jonka bilibilin maantieteellisesti reititetty `playurl` jo tarjoaa, kiinnittymisen sijaan mantereen solmuun (Aliyun/Shenzhen) — joten Kiinan mantereen ulkopuoliset käyttäjät eivät enää jää jumiin (»ääni jatkaa soittamista, video jäätyy»). Voit silti kiinnittää CDN:n manuaalisesti asetuksista.
- **»Teema ja väri» -sivu Material You -tyyliin.** Vaalea / tumma / seuraa järjestelmää valitaan **kolmesta reaaliaikaisesta esikatselukortista** — jokainen piirtää pienoismallin oikeasta käyttöliittymästä täsmälleen niillä väreillä, jotka tila käyttäisi (»seuraa järjestelmää» -kortti on jaettu vinosti, vaalea tumman päällä). Niiden alla: **dynaaminen väri** (järjestelmän taustakuvasta, kun laite tukee sitä), **korkeakontrastinen tumma** (aidon mustat pinnat, silmäystävällisempi yöllä) ja **aina tumma soitin**. Väripuoli säilyttää täyden FlexScheme-paletin — **19 siemenväriä** plus erillinen **»palettityyli»**, joka päättää, miten jokainen säiliöväri johdetaan siemenestä riippumatta siitä, minkä siemenen valitset.
- **LXGW WenKai tulee sovelluksen mukana.** Fontti **LXGW WenKai (霞鹜文楷)** on **pakattu mukaan ja asetettu oletukseksi** — lämmin, erittäin luettava kiinalainen fontti, joka sinulla on heti asennuksesta, sen sijaan että etsisit sitä valitsimesta. Se koskee koko käyttöliittymää *ja* danmakua. Voit silti vaihtaa takaisin järjestelmäfonttiin, valita minkä tahansa asennetun järjestelmäfontin tai tuoda oman `.ttf` / `.otf` / `.ttc` -tiedostosi; aiemmin erikseen valitsemasi fontti säilyy päivityksen yli. Paino ja koko pysyvät säädettävissä kuten ennenkin.

## Offline-äänivälimuisti ja lataus paikalliseen kansioon (vain PiliBabelissa)

Kaksi kykyä, joita ylävirran PiliNaralla / PiliPlusella ei ole — molemmat tähtäävät siihen, että omistaisit mediasi oikeasti offline-tilassa.

### Tallenna ääni välimuistiin (vain äänen offline-välimuisti)

- **Raita, ei video.** Kohta *Tallenna ääni välimuistiin* on heti kohdan *Tallenna video välimuistiin* alla videosivun valikossa, sekä oma äänivälimuistipainike kuuntelusivun yläpalkissa.
- **Valitse laatutaso.** Hi-Res häviötön, Dolby Atmos, 192K, 132K tai 64K — sama valmis luettelo, jota videolaadun valitsin käyttää.
- **Alkuperäinen kontti, ei uudelleenkoodausta.** Tiedosto kirjoitetaan täsmälleen niin kuin CDN sen toimittaa: `m4a`, `mp3`, `flac`, `wav`, `aac` tai `ogg`.
- **Oma moduulinsa.** Välimuistisivu on jaettu *Välimuistissa oleviin videoihin* / *Välimuistissa olevaan ääneen* ja se muistaa, kummassa moduulissa olit viimeksi.
- Välimuistissa olevan äänikohdan napauttaminen avaa äänisoittimen heti; kohteet voi poistaa yksitellen tai joukkona.

### Lataa paikalliseen kansioon

- **Oma valikkokohtansa.** *Lataa paikalliseen kansioon* on erillinen kohta videosivun valikossa, heti kohdan *Tallenna ääni välimuistiin* alla — välimuistiin tallentaminen sovelluksessa ja kansioon tallentaminen ovat kaksi eri toimintoa.
- **Lataa video tai lataa ääni.** Kohta kysyy ensin kumpaa, sitten laatutasoa (videolaadun / äänilaadun valitsin).
- **Kansiosi, sääntösi.** Valitse mikä tahansa kansio järjestelmän tiedostonhallinnan kautta (Asetukset → *Lataa paikalliseen kansioon*) ja vaihda tai tyhjennä se milloin tahansa. Jos et ole vielä valinnut, kansiovalitsin avautuu heti paikallaan.
- **Suoraan toistettavat tiedostot.** Video noudetaan yhtenä muxattuna virtana (`fnval=1`), joten levylle päättyvä tiedosto on tavallinen MP4, jonka voi antaa mille tahansa soittimelle — ei sivuvirtoja ommeltavaksi yhteen.
- **Ääni säilyttää alkuperäisen muotonsa** — ei uudelleenkoodausta, aivan kuten sovelluksen välimuistissa.
- Tiedostot nimetään videon otsikon mukaan eivätkä ne koskaan ylikirjoita olemassa olevaa latausta.

## Kaksi käännösmoottoria

| | Sisäänrakennettu (oletus) | Oma API |
|---|---|---|
| Malli | bilibilin **Index-Translate-35B-A3B** | mikä tahansa OpenAI-yhteensopiva |
| Rajapinta | `index-translate.bilibili.com/v1` | oma perusosoitteesi |
| API-avain | **ei tarvita** | sinun |
| Kustannus | ilmainen | mitä palveluntarjoajasi veloittaa |
| Pyynnöt | yksi teksti per pyyntö | erissä (≤ 16 per pyyntö) |
| Lisäkielet | — | kaikki kielet, joita mallisi osaa |

**Miksi yksi pyyntö kerrallaan sisäänrakennetulle moottorille.** Index-Translate on käännöksiin *erikoistunut*, ja sen tekijöiden dokumentoima kutsutapa on yhden kohteen malli (»käännä seuraava teksti kielelle X, tulosta vain käännös»). PiliBabel lähettää siksi tällä moottorilla yhden tekstin per pyyntö numeroidun luettelon/JSON-taulukon eräkehotteen sijaan, jota se käyttää oma-API-asetuksissa. Rajapinta on ilmainen, joten erätuloksen uhkapelistä ei ole hyötyä — tämä on tietoinen vaihto muutamaan ylimääräiseen pyyntöön vastineeksi paljon pienemmästä vikamahdollisuudesta.

**Päivitys versiosta 0.3.x.** Omat API-asetuksesi — perusosoite, avain ja malli — **jäävät täsmälleen siten kuin ne määritit**. Moottorin valinta saa vain oletukseksi sisäänrakennetun mallin, joten päivityksen jälkeisellä ensimmäisellä käynnistyksellä olet bilibilin ilmaisella mallilla; avaa *Asetukset → AI → Tekoälyominaisuudet → käännösmoottori* ja vaihda takaisin *Oma API* -valintaan palataksesi heti entisiin asetuksiisi.

## Miten tekoälykäyttöliittymäkäännös toimii (tekninen)

Repossa **ei ole i18n / ARB -resurssikerrosta** — käyttöliittymätekstit ovat kovakoodattua kiinaa. Sen sijaan että jokainen widget kirjoitettaisiin uudelleen, PiliBabel lisää päälle ohuen käännöskerroksen:

1. **Globaali hakuwrapperi.** `lib/services/ui_translate/` paljastaa ylätason `uiTx(String src)`-funktion. Widget-teksti, joka ennen oli `Text('中文')`, tulee muotoon `Text(uiTx('中文'))`. Skriptattu **codemod** lisäsi tämän koko projektiin (`tool/ui_translate_*.py`) — noin **223 tiedostoa / ~1 650+ tekstiä** — pudottaen automaattisesti nyt pätemättömän `const`-avainsanan tarvittaessa (mukaan lukien geneeriset tyypit kuten `const X<T>(...)` ja pisteelliset nimet kuten `const Positioned.fill(...)`, ja muuntaen `static const`-lista/map-esittelyt muotoon `static final`).
2. **`GetxService`-ydin** (`ui_translate_service.dart`):
   - pysyvä **lähde → käännös** -välimuisti (GetStoragen tukemana), joten jokainen teksti käännetään kerran ja käytetään uudelleen ikuisesti;
   - `tx()` lukee ensin `RxInt revision`-arvon ja päättää sitten: jos pois käytöstä → palauta alkuperäinen; jos kohde on **yksinkertaistettu kiina (`zh-CN`)**, palauta alkuperäinen ilman API-pyyntöä (Bilibilin lähdesisältö on lähes kokonaan yksinkertaistettua kiinaa). Jokainen muu kohde — mukaan lukien perinteinen kiina, kantonin kiina, wu/shanghainkiina ja hokkien/min nan — menee määritetyn moottorin läpi; pelkkä kuuluminen kiinalaisperheeseen ei ohita käännöstä. Tämän jälkeen palvellaan välimuistista tai **asetetaan jonoon**;
   - jonotetut tekstit huuhtelee **työläispooli** **paloittain vaiheittain soveltaen** (jokainen palautettu pala kasvattaa `revision`-arvoa, jolloin teksti päivittyy vähitellen), ja tulokset **tallennetaan pysyvästi** (drosselloituna). Eräkoko ja rinnakkaisuus seuraavat moottoria: **1 per pyyntö** sisäänrakennetulla mallilla, **≤ 16 ja ≤ 10 lentossa** omalla API:lla.
3. **Moottorin selvitys.** `TranslateProvider` (`builtin` / `custom`) päättää, mitä URL:ää, avainta ja mallia kuljetus käyttää; muuten molemmat moottorit jakavat yhden koodipolun ja yhden kieliluettelon, joten moottorin vaihtaminen on yksi asetus eikä koskaan eri ominaisuusjoukko.
4. **Kuljetus** käyttää uudelleen samaa varmennettua **striimauskanavaa** kuin tekoälyvideotiivistelmä — `AiChatService.streamChat` → `{base}/chat/completions` arvolla `stream: true` (yhteensopiva sellaisten yhdyskäytävien kanssa, jotka tukevat vain striimausta) — laajennettuna niin, että käännös voi käyttää **omia** `apiUrl` / `apiKey` / `model` -arvojaan ja `enable_thinking`-lippua. Muutos on **taaksepäin yhteensopiva**, joten videotiivistelmä jatkaa muuttumattomana.
5. **Interpoloidut lauseet** käyttävät `uiTxP(template, args)`-funktiota: kokonainen lause `{0}`/`{1}`-paikkamerkeillä käännetään yhtenä vakaana avaimena (kehote pyytää mallia säilyttämään paikkamerkit), minkä jälkeen arvot sijoitetaan takaisin — joten `"共 {0} 条"`-tyyppiset tekstit käännetään ilman dynaamisten osien rikkomista.
6. **Kielitaulukko** (`app_language.dart`): jokainen `AppLanguage` kantaa näytettävän autonyymin, `toModel`-kehotetekstin, joka koodaa kirjoitus- ja aluekäytännöt, ja lipun siitä, kattaako bilibilin virallinen luettelo sen. Kirjoitusjärjestelmäsäännöt (yksinkertaistettu vastaan perinteinen sekä murresääntökehotteet) saavuttavat mallin vain kehotteen kautta, ja deterministinen normalisointikierros asiakasohjelmassa korjaa irralliset merkit jälkeenpäin.
7. **Kommentit** menevät `uiTxComment(text, id)`-funktion läpi pitäen `@ / [emoji] / #aihe# / linkki` ehjinä tokeneina; linkkejä kantavat rikastekstiosat käännetään säilyttäen linkkien tunnistus, ja kommenttikohtainen id-joukko ohjaa Alkuperäinen ⇄ Käännös -vaihtoa.
8. **Danmaku** (`danmaku/view.dart`): kun sen kytkin on päällä, sijaintikuuntelija kävelee välin `[playhead, playhead + 15s]` sekunnin askelin ja esilataa `uiTx()`-funktion jokaisen danmakun sisällöllä, joten kohteet käännetään ennen ruutuun pääsyään; käyttöönotto tyhjentää kangaspinnan ja piirtää sen uudelleen.
9. **Tallennusavaimet**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Asetuskäyttöliittymä**: yksi ensimmäisen tason »Tekoälyominaisuudet»-sivu (`lib/pages/setting/ui_translate/`) erillisillä lohkoilla tekoälyvideotiivistelmälle ja tekoälykäännökselle.

**Maailmanlaajuinen CDN (`VideoUtils.getCdnUrl`).** Striimi-URL:t on allekirjoitettu, ja URL:n isäntänimen uudelleenkirjoitus johtaa 403-hylkäykseen — joten toisto ei koskaan kirjoita isäntiä uudelleen. PiliBabel palauttaa maantieteellisesti reititetyn URL:n, jonka bilibili antaa asiakkaan IP-osoitteelle, ja jos ehdokasluettelossa on jo ulkomainen reuna (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`), sitä suositaan. Lataukset, joissa isännän vaihto on turvallista, suosivat lisäksi globaalia Akamai-reunaa ja siirtyvät seuraavaan allekirjoitettuun ehdokkaaseen, kun linja juuttuu tai hylkää jatkon. `/v/resource`-muotoiset raaka P2P-linkit palaavat yhä olemassa olevaan välitykseen 404-virheiden välttämiseksi.

**Suunnittelukompromissit / tunnetut rajoitukset.** Koska tekstit kääritään paikoilleen resursseihin poimimisen sijaan, muutamat `Text`-ulkoiset tekstiparametrit ja osa rikastekstiosista täytetään yhä vaiheittain. Tekstejä, jotka toimivat samalla **logiikka-avaimina** (verrattuna `==`-operaattorilla, käytetty välilehtien niminä kuten `简介`, tai enum-nimiä kytkimissä), **ei** kääretä raa'asti tarkoituksella, jotta toiminta ei rikkoutuisi. Danmakukäännös on parhaan yrityksen toteutus vierivällä kangaspinnalla — erittäin tiheän danmakun alla saatat hetken nähdä alkuperäisen ennen käännöksen saapumista. Kääntäminen vaatii verkon; ilman sitä ei-kiinalaiset kohteet eivät yksinkertaisesti astu voimaan. Sisäänrakennettu rajapinta on bilibilin ylläpitämä ilmainen julkinen palvelu — jos sille asetetaan rajoitus tai se on poissa käytöstä, sovellus kertoo sen, ja voit vaihtaa omaan API:ysi.

## Kääntäminen ja varmentaminen

Sovellus käännetään paikatulla Flutter SDK:lla sekä paikatuilla `material_ui` / `cupertino_ui`-paketeilla `lib/scripts/patch.ps1`- ja `lib/scripts/build.ps1`-skripteillä (täsmälleen kuten PiliNara / PiliPlus). GitHub Actions tuottaa **debug-APK**:n jokaisesta pushista (`.github/workflows/ui-translate-debug.yml`), ja **tunnisteen `v*` julkaisu rakentaa ja julkaisee automaattisesti Android-, Windows- ja Linux**-artefaktit (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Alustat
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

PiliBabel toimittaa **Android (APK) -, Windows- ja Linux**-versiot Releases-sivulta; iOS/Pad-versioita ei ole vielä paketoitu tässä forkissa.

<br/>

## Lataus

Nouda versio **Releases**-sivulta tai kloonaa repo ja käännä se paikallisesti.

### Arch Linux

Kiitos [@nlsdt](https://github.com/nlsdt) pakkauksesta (PiliNaran resepti pätee myös PiliBabeliin).

```bash
sudo pacman -S pilinara      # Arch Linux CN -varaston kautta
paru -S pilinara-bin         # tai AUR:sta: pilinara-bin (esirakennettu) / pilinara (lähdekoodi)
```

<br/>

## Peritty ominaisuuslista (PiliNaralta / PiliPluselta)

Alla oleva kaikki on peritty PiliNaralta (ja välillisesti PiliPluselta); PiliBabel lisää päälle tekoälykäännöskerroksen.

**Käyttöliittymä ja alustasovellutus**
- [x] Sovellus nimetty alustakohtaisesti, jotta useita asiakasohjelmia voi olla rinnakkain (PiliBabel asentuu PiliNaran rinnalle)
- [x] Korjattu Flutterin renderöinti Xiaomi HyperOS:n pienikkunaikkunassa ([#161086](https://github.com/flutter/flutter/issues/161086), [venera#467](https://github.com/venera-app/venera/pull/467) kautta); ennakoiva paluu-animaatio Androidissa
- [x] Muokattava »Oma»-korttien järjestys ja määrä; historiaporttien esikatselu ja »katso myöhemmin» -osiot
- [x] Automaattinen sivupalkin vaihto säädettävällä liipaisinleveydellä; kuvan kopiointi pitkällä painalluksella / oikealla napsautuksella; suuri MD3E-tyylin päivitys

**Fonttijärjestelmä** — yhdistetty tuontialtisto sisältöhash-poistolla, danmaku-fontit yhdistetty samaan altistoon, `loadFontFromList` ttc-tuella ja puhtailla ASCII-hash-perhenimillä.

**Toisto, pienikkuna ja laatu** — sovelluksen sisäinen pienoikkuna (raahaus, koon muutos, SponsorBlock-ohitus, automaattinen järjestelmän PIP, selviytymispalkki lähetyksessä), rinnakkainen äänentoisto, sovelluksen äänenvoimakkuus jopa 200 %:iin, mukautettu video-CDN-verkkotunnus ja aluesolmun valinta viiveellä, erillinen puolikoko- ja kokoruutu-oletuslaatu, pyyhkäisyyn lukittu nopeus, näppäimistöohjaus tabletilla, SuperChat-aikaleimat lähetyksessä, live-sydämenlyönti faniläheisyyteen.

**Tekstitykset, tekoäly ja offline** — kaksikieliset tekstitykset itsenäisellä sivutekstityksen tyylillä, tekoälytekstitysanalyysi (mukautettu OpenAI-yhteensopiva rajapinta, aikaleimahyppy, mallipohjat, pysyvät keskustelut, pehmeä vararatkaisu tekstityksen puuttuessa), WEBVTT/SRT-vienti, offline-välimuistin kaksoisnäkymä kansiohallinnalla ja metadatan pysyvyydellä, latausten vienti julkiseen Lataukset-kansioon (Android).

**Danmaku ja estäminen** — parannettu yhdistetyn danmakun skaalaus ([Pakku.js](https://github.com/xmcp/pakku.js)-tyyliin), luettelopohjainen visuaalinen regex-esto tuonnilla/viennillä, SponsorBlock-hyppy segmenttiin siirryttäessä, korkeaenerginen edistymispalkki gaussisella ytimellä.

**Suositus-, julkaisu- ja kommenttisuodatus** — otsikon/UP:n/kanavan avainsanat, kesto, toistomäärä, tykkäysosuus, seurattujen UP:ien vapautus, luvattoman/vain-maksullisen suodatus, jaettu sallittujen luettelo, kaupalliset/luvattomat julkaisut, UP:n omien ja kiinnitettyjen kommenttien vapautukset, App+Web-yhdistetty syötetila.

**Julkaisut, haku ja käyttäjätiedot** — mukautetut muistiinpanot UP:ille, muistiinpano korvaa lempinimen 13 nimipaikassa, itsenäinen sisäkkäisten kommenttien lajittelu, paikallinen avainsanhakusuodatin, b23.tv-lyhytlinkkihyppy, vain-maksullinen-merkki, suosituksen perustelun piilotuskytkin, kolikko-XP-näyttö.

**Live-parannukset** — fanimitalin pukemispaneeli, HLS:ää suosiva DLNA-heijastus, SuperChat-aikanäyttö, pienikkunan alaosan ohjauspalkki selviytymiseen.

**Järjestelmäintegraatio ja työpöytä** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), uudelleenrakennettu äänikeskittymisen käsittely.

<details>
<summary>Täydellinen alkuperäinen ominaisuus-/tarkistusluettelo (sananmukaisesti, PiliNaralta — laajenna napsauttamalla)</summary>

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

## Vastuuvapauslauseke

PiliBabel on henkilökohtainen, kiinnostukseen perustuva projekti, tarjottu **vain oppimiseen ja testaamiseen**; poistathan sen **24 tunnin** kuluessa latauksesta.

- PiliBabel on **epävirallinen kolmannen osapuolen** asiakasohjelma eikä se **kuulu bilibiliin, eikä bilibili hyväksy tai sponsoroi sitä**.
- Kaikki API:t on koottu virallisista julkisista rajapinnoista; **ei tarjota murrettua, liian laajaoikeuksista tai maksumuuria kiertävää sisältöä**.
- **Tekoälykäännös toimii kolmannen osapuolen mallirajapinnassa.** Oletuksena se on bilibilin oma ilmainen julkinen Index-Translate-palvelu; jos vaihdat omaan API:ysi, se on määrittämäsi rajapinta. Käännösten laatu ja vaatimustenmukaisuus ovat käyttäjän ja valitun mallitarjoajan vastuulla; tämä projekti isännöi **ei mallia eikä API-avainta**.
- Kunnioita tekijänoikeuksia ja bilibilin käyttöehtoja. Käytä vastuullisesti.

Kunnioituksella alkuperäisiä ja ylävirran tekijöitä kohtaan heidän avoimen lähdekoodin omistautumisestaan:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — PiliBabelin suora emoprojekti
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — avoimen lähdekoodin käännösmalliperhe, jota sisäänrakennettu moottori kutsuu

Jos jokin sisältö loukkaa oikeuksiasi, otathan yhteyttä poistoa varten.

<br/>

## Lisenssi

PiliBabel on lisensoitu **GNU General Public License v3.0 (GPL-3.0)** -lisenssillä — samalla lisenssillä kuin PiliNara, PiliPlus ja PiliPala. Koska se on johdettu teos, **PiliBabel on levitettävä myös GPL-3.0:n alaisena**: saat käyttää, tutkia, jakaa ja muokata sitä vapaasti, kunhan säilytät saman lisenssin, tekijänoikeusilmoitukset ja tämän lisenssitekstin. Katso [`LICENSE`](./LICENSE).

Kolmannen osapuolen komponentit (Flutter-paketit, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio) jne.) pysyvät omilla lisenseillään.

Mukana tuleva **LXGW WenKai** -fontti on lisensoitu erikseen **SIL Open Font License 1.1** -lisenssillä; sen lisenssiteksti toimitetaan sovelluksen mukana tiedostona `assets/fonts/LXGWWenKai-OFL.txt`.

<br/>

## Kiitokset

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — bilibilin avoimen lähdekoodin käännösmalliperhe ja sisäänrakennetun moottorin takana oleva ilmainen julkinen rajapinta
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — sovelluksen mukana tuleva avoimen lähdekoodin kiinalainen fontti SIL Open Font License 1.1 -lisenssillä
- ja lisää
- Inspiroitunut bilibilin virallisesta »tekoälykäyttöliittymäkäännöksestä».
