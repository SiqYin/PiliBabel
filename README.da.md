<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>En tredjepartsklient til bilibili med AI-drevet oversættelse.</b></p>
    <p>Babel — river sprogbarrieren ned, så alle kan nyde bilibili på deres eget sprog.</p>
    <p>Forener bilibilis officielle liste på 151 sprog med 6 flere, den ikke dækker - traditionel kinesisk, forenklet og traditionel wu, hokkien fra fastlandet og Taiwan samt zhuang.</p>
    <p>Oversættelsen fungerer straks ud af boksen på bilibilis egen gratis model — ingen API-nøgle kræves.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.nan.md">台語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.mn.md">Монгол</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.pt.md">Português</a> · <a href="README.bn.md">বাংলা</a> · <a href="README.th.md">ไทย</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.it.md">Italiano</a> · <a href="README.fa.md">فارسی</a> · <a href="README.fil.md">Filipino</a> · <a href="README.ur.md">اردو</a> · <a href="README.mr.md">मराठी</a> · <a href="README.te.md">తెలుగు</a> · <a href="README.ta.md">தமிழ்</a> · <a href="README.pa.md">ਪੰਜਾਬੀ</a> · <a href="README.gu.md">ગુજરાતી</a> · <a href="README.ha.md">Hausa</a> · <a href="README.sw.md">Kiswahili</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.my.md">မြန်မာ</a> · <a href="README.pl.md">Polski</a> · <a href="README.is.md">Íslenska</a> · <a href="README.nb.md">Norsk</a> · <a href="README.fi.md">Suomi</a> · <a href="README.sv.md">Svenska</a> · <b>Dansk</b> · <a href="README.be.md">Беларуская</a> · <a href="README.ug.md">ئۇيغۇرچە</a> · <a href="README.kk.md">Қазақша</a> · <a href="README.bo.md">བོད་ཡིག</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Hjem" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dynamik" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Mig" />
</div>

<br/>

> **Ansvarsfraskrivelse.** PiliBabel er en **uofficiel, open source-, tredjeparts**klient. Den er **ikke tilknyttet, ikke godkendt af og ikke sponsoreret af** bilibili / bilibili Inc. Hver enkelt API er samlet fra de officielle offentlige endpoints; **intet betalt indhold låses op eller knækkes**. Læs venligst de fuldstændige afsnit [Ansvarsfraskrivelse](#ansvarsfraskrivelse) og [Licens](#licens).

## Hvad er PiliBabel?

PiliBabel er en **uafhængig tredjeparts-fork bygget oven på [PiliNara](https://github.com/Starfallan/PiliNara)**, og den arver alt, hvad PiliNara arver:

```
bilibili (officielt offentligt API)
        ▲
   PiliPala / PiliPalaX        — det oprindelige projekt
        ▲
   PiliPlus                    — aktiv fork
        ▲
   PiliNara                    — fork af PiliPlus (personlige tilretninger)
        ▲
   PiliBabel  ← du er her   — fork af PiliNara
```

PiliBabel bevarer **enhver funktion fra PiliNara / PiliPlus** (se [arvet funktionslog](#arvet-funktionslog-fra-pilinara--piliplus) længere nede) og tilføjer **to hovedfunktioner, som upstream-klienterne ikke har**:

> **AI-oversættelse af brugergrænseflade og indhold** — hele appen (brugergrænsefladetekster, videotitler, UP-navne, kommentarer, dynamik, feed og endda danmaku (rullende skærmkommentarer) i live) vises på det sprog, **du** vælger.

Og siden 1.0 gør den det **direkte ud af boksen**: oversættelsesmodellen er **indbygget**. bilibili har open-sourcet sin egen familie af oversættelsesmodeller, [Index-Translate](https://github.com/bilibili/Index-Translate), og betjener den fra et gratis offentligt endpoint. PiliBabel leveres peget på den, så oversættelsen virker i det øjeblik, du installerer appen — ingen tilmelding, ingen nøgle, ingen regning. Hvis du hellere vil bruge din egen model, er egen-API-vejen der stadig, ét tryk væk.

> **Lyd i hovedtelefoner, der faktisk holder sig synkroniseret** — med Bluetooth- eller kablede hovedtelefoner halter lyden ikke længere efter billedet. Den officielle app får det her til at lykkes; PiliNara og PiliPlus gør det ikke, ud af boksen. PiliBabel beder nu mpv om **AudioTrack** først, som *måler* lydudgangsforsinkelsen på samme måde som den officielle klient, i stedet for **OpenSL ES**, som kun *estimerer* den.

## Nøglefunktioner

- **Synkroniseret lyd i hovedtelefoner.** Afspilleren bruger nu mpvs **AudioTrack**-backend som standard (rækkefølge `audiotrack,aaudio,opensles`) i stedet for **OpenSL ES**. AudioTrack rapporterer en *målt* udgangsforsinkelse — den læser antallet af afspillede frames og enhedens præsentationstidsstempel — hvilket er præcis, hvordan den officielle bilibili-app og Androids egen `MediaSync` holder billede og lyd sammen. OpenSL ES *estimerer* den kun, så på Bluetooth-hovedtelefoner drev lydklokken, og billedet blev vist for tidligt. I test er forsinkelsen i praksis væk. Omrokér rækkefølgen når som helst under Indstillinger → Video → Lydudgangsenhed.

- **AI-oversættelse overalt.** Navigationsfaner, videokort, detailsider, kommentarer, dynamik samt Min / Favoritter / Historik / Beskeder / Søg-fladerne — en gennemgribende gennemgang dækker **~1.650+ brugergrænsefladestrenger** plus dynamisk indhold (titler, forfatternavne, handlingsantal).
- **To motorer, én kontakt.** *Indbygget* (standard) bruger bilibilis officielle gratis **Index-Translate-35B-A3B**-endpoint — intet, der skal konfigureres. *Egen API* bevarer den tidligere adfærd: peg den på et hvilket som helst OpenAI-kompatibelt `/chat/completions`-endpoint med din egen basis-URL / nøgle / model. AI-videosammendraget og AI-oversættelsen har stadig **helt uafhængige** endpoints og indstillinger, begge samlet på én **»AI-funktioner»**-side.
- **Én sprogliste, begge motorer.** Målsprogslisten opdeles ikke pr. motor — den samme liste tilbydes, uanset hvilken motor du vælger. Den forener de **151 sprog** i bilibilis officielle model med **6 flere, den ikke dækker** — traditionel kinesisk, forenklet og traditionel wu, fastlands- og taiwansk hokkien samt zhuang. Regionale og skriftvarianter bevares som **separate poster** i stedet for at blive slået sammen — marokkansk / egyptisk / najdi / levantinsk arabisk er hvert sit valg, og det samme gælder kyrillisk-mod-latinsk serbisk, usbekisk og urdu.
- **Ærlig om dækning.** Sprog inden for den officielle liste dækkes af bilibilis model. De få udenfor — traditionel kinesisk, forenklet og traditionel wu, fastlands- og taiwansk hokkien samt zhuang — vises stadig på listen, markeret som sådan, så du med ét blik ved, at et bedre resultat kan kræve din egen model.
- **Oversæt én gang, så er det fast.** Hver kildestreng oversættes **nøjagtigt én gang**; resultatet gemmes lokalt og **oversættes aldrig igen**, når du genåbner en skærm — samme princip som den officielle klient, for stabile, forudsigelige oversættelser.
- **Original ⇄ Oversættelse-kontakt pr. kommentar** (et lille ikon, ikke et kinesisk ord). `@omtaler / [emoji] / #emner# / links` bevares som tokens, og **kommentarer med hyperlinks oversættes stadig, mens linket forbliver klikbart**.
- **Oversættelse af danmaku (弹幕)** — en selvstændig kontakt i afspillerens øverste højre kontrolrække, **slukket som standard** og skjult bag en bekræftelse, hvis egen tekst er oversat. Når den er aktiveret, foroversættes danmaku foran afspilningshovedet i **~15-sekunders batches** (at springe til midten håndteres korrekt, ikke fra starten), så oversættelsen som regel er klar, når den ruller ind på skærmen.
- **Kontakt for tænketilstand** (`enable_thinking`) til kvalitet-mod-hastighed, samt knapper til **»testoversættelse»** og **ryd cache** i indstillingerne.
- **Hurtigt sprogskifte**: batch-forespørgsler med begrænset samtidighed mod et vedvarende cachelager; sprogskift gennemtvinger én genopbygning af den aktuelle skærm, så du ikke sidder og stirrer på uoversat tekst. Slukkes AI-oversættelsen, gendannes hele brugergrænsefladen til originalteksten, og der sendes slet ingen forespørgsler.
- **Introduktion ved første start.** Første gang du åbner appen, tilbyder en engelsk dialog at slå oversættelse til. Accept aktiverer oversættelsen, vælger den indbyggede model, åbner AI-indstillingssiden og spørger straks, hvilket sprog du vil have — så en ny bruger går fra installation til oversat app med to tryk.
- **Afspilning, der fungerer i hele verden.** PiliBabel vælger oversea-kanten (global **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`), som bilibilis georuttede `playurl` allerede tilbyder, i stedet for at låse dig til en fastlandsknude (Aliyun/Shenzhen) — så brugere uden for det kinesiske fastland går ikke længere i stå (»lyden fortsætter, videoen fryser«). Du kan stadig låse et CDN manuelt i indstillingerne.
- **En »Tema og farve«-side i Material You-stil.** Lys / mørk / følg systemet vælges fra **tre levende forhåndsvisningskort** — hvert af dem viser en miniature af den rigtige brugergrænseflade i netop de farver, tilstanden ville anvende (»følg systemet«-kortet er delt diagonalt, lyst over mørkt). Under dem: **dynamisk farve** (hentet fra systemets baggrund, hvor enheden understøtter det), **mørk med høj kontrast** (ægte sorte flader, skånsommere for øjnene om natten) og **altid mørk afspiller**. Farvedelen bevarer hele FlexScheme-paletten — **19 frøfarver** plus en separat **»paletstil«**, der afgør, hvordan hver beholderfarve afledes af frøfarven, uafhængigt af hvilken frøfarve du vælger.
- **LXGW WenKai følger med appen.** Skrifttypen **LXGW WenKai (霞鹜文楷)** er **bundlet med og sat som standard** — en varm, meget læsbar kinesisk skrifttype, du har fra det øjeblik, du installerer, i stedet for at lede efter en i en vælger. Den gælder hele brugergrænsefladen *og* danmaku. Du kan stadig skifte tilbage til systemskrifttypen, vælge enhver installeret systemskrifttype eller importere din egen `.ttf` / `.otf` / `.ttc`; en skrifttype, du tidligere eksplicit havde valgt, bevares gennem opgraderingen. Vægt og størrelse er stadig justerbare som før.

## Offline lydcachelagring og download til lokal mappe (unik for PiliBabel)

To muligheder, som upstream PiliNara / PiliPlus ikke har — begge rettet mod faktisk at eje dine medier offline.

### Cache lyd (offlinecache kun til lyd)

- **Sporet, ikke videoen.** Et punkt *Cache lyd* ligger lige under *Cache video* i videosidens menu, plus en dedikeret cache-lyd-knap i den øverste linje på lyttesiden.
- **Vælg kvalitetsniveau.** Hi-Res tabsfrit, Dolby Atmos, 192K, 132K eller 64K — den samme forudindstillede liste, som videokvalitetsvælgeren bruger.
- **Original beholder, ingen omkodning.** Filen skrives nøjagtigt, som CDN'en leverer den: `m4a`, `mp3`, `flac`, `wav`, `aac` eller `ogg`.
- **Eget modul.** Cachesiden er opdelt i *Cachede videoer* / *Cachet lyd* og husker, hvilket modul du var på sidst.
- Tryk på et cachet lydpunkt åbner straks lydafspilleren; punkter slettes enkeltvis eller i bulk.

### Download til lokal mappe

- **Eget menupunkt.** *Download til lokal mappe* er et separat punkt i videosidens menu, lige under *Cache lyd* — cachelagring inde i appen og gemning til en mappe er to forskellige handlinger.
- **Download video eller download lyd.** Punktet spørger først, hvilken af delene, og derefter til kvalitetsniveauet (vælger til videokvalitet / lydkvalitet).
- **Din mappe, dine regler.** Vælg en hvilken som helst mappe via systemets filhåndtering (Indstillinger → *Download til lokal mappe*), og ændr eller ryd den, når du vil. Hvis du ikke har valgt en endnu, åbnes mappevælgeren med det samme.
- **Direkte afspillelige filer.** Video hentes som én enkelt muxet strøm (`fnval=1`), så det, der lander på disken, er en almindelig MP4, du kan give til enhver afspiller — ingen sidestrømme at sy sammen.
- **Lyd bevarer sit originale format** — ingen omkodning, præcis som cachen i appen.
- Filer navngives efter videotitlen og overskriver aldrig en eksisterende download.

## De to oversættelsesmotorer

| | Indbygget (standard) | Egen API |
|---|---|---|
| Model | **Index-Translate-35B-A3B** fra bilibili | hvad som helst, der er OpenAI-kompatibelt |
| Endpoint | `index-translate.bilibili.com/v1` | din basis-URL |
| API-nøgle | **behøves ikke** | din |
| Omkostning | gratis | hvad din udbyder opkræver |
| Forespørgsler | én streng pr. forespørgsel | i batches (≤ 16 pr. forespørgsel) |
| Ekstra sprog | — | alle sprog, din model kan |

**Hvorfor én forespørgsel ad gangen for den indbyggede motor.** Index-Translate er en *specialist* i oversættelse, og kaldekonventionen, forfatterne dokumenterer, er en skabelon med et enkelt element (»oversæt følgende tekst til X, output kun oversættelsen«). PiliBabel sender derfor én streng pr. forespørgsel på denne motor i stedet for nummereret-liste/JSON-array-batchprompten, den bruger til egen-API-opsætninger. Endpointet er gratis, så der er intet at vinde ved at spille hasard med batch-output — dette er en bevidst afvejning af nogle få flere forespørgsler mod langt færre måder at fejle på.

**Opgradering fra 0.3.x.** Dine egne API-indstillinger — basis-URL, nøgle og model — **efterlades præcis, som du konfigurerede dem**. Motorvalget får ganske enkelt standarden indbygget model, så ved første start efter opgraderingen kører du på bilibilis gratis model; åbn *Indstillinger → AI → AI-funktioner → oversættelsesmotor* og skift tilbage til *Egen API* for straks at vende tilbage til din tidligere opsætning.

## Sådan fungerer AI-brugergrænsefladeoversættelsen (teknisk)

Repositoriet har **intet i18n / ARB-ressourcelag** — brugergrænsefladestrenger er hårdkodet kinesisk. I stedet for at omskrive enhver widget tilføjer PiliBabel et tyndt oversættelseslag oven på:

1. **En global opslags-wrapper.** `lib/services/ui_translate/` eksponerer en `uiTx(String src)` på topniveau. Widget-tekst, der plejede at være `Text('中文')`, bliver `Text(uiTx('中文'))`. En scriptet **codemod** anvendte dette hele projektet igennem (`tool/ui_translate_*.py`) — ca. **223 filer / ~1.650+ strenger** — og fjernede automatisk det nu ugyldige `const`-nøgleord, hvor det krævedes (herunder generika som `const X<T>(...)` og prikkede navne som `const Positioned.fill(...)`, samt konverterede `static const`-liste-/map-deklarationer til `static final`).
2. **En `GetxService`-kerne** (`ui_translate_service.dart`):
   - et vedvarende **kilde → oversættelse**-cachelager (med GetStorage bag), så hver streng oversættes én gang og genbruges for altid;
   - `tx()` læser først en `RxInt revision` og beslutter derefter: hvis slukket → returnér originalen; hvis målet er **forenklet kinesisk (`zh-CN`)**, returnér originalen uden API-forespørgsel (Bilibilis kildeindhold er overvejende forenklet kinesisk). Hvert andet mål — herunder traditionel kinesisk, kantonesisk, wu/shanghainesisk og hokkien/min nan — går gennem den konfigurerede motor; medlemskab af den kinesiske sprogfamilie alene springer ikke oversættelsen over. Server derefter fra cachen eller **sæt i kø**;
   - strenger i kø tømmes af en **arbejdspulje** med **trinvis anvendelse pr. chunk** (hver returneret chunk øger `revision`, så teksten opdateres gradvist), og resultaterne **gemmes vedvarende** (throttlet). Batchstørrelse og samtidighed følger motoren: **1 pr. forespørgsel** på den indbyggede model, **≤ 16 med ≤ 10 i luften** på din egen API.
3. **Motoropløsning.** `TranslateProvider` (`builtin` / `custom`) afgør, hvilken URL, nøgle og model transporten bruger; i øvrigt deler begge motorer én kodevej og én sprogliste, så det at skifte motor er én enkelt indstilling og aldrig et andet funktionsæt.
4. **Transporten** genbruger den samme verificerede **streaming**kanal som AI-videosammendraget — `AiChatService.streamChat` → `{base}/chat/completions` med `stream: true` (kompatibel med gateways, der kun understøtter streaming) — udvidet, så oversættelsen kan bruge sine **egne** `apiUrl` / `apiKey` / `model` og et `enable_thinking`-flag. Ændringen er **bagudkompatibel**, så videosammendraget fortsætter uændret.
5. **Interpolerede sætninger** bruger `uiTxP(template, args)`: en hel sætning med `{0}`/`{1}`-pladsholdere oversættes som én stabil nøgle (prompten beder modellen om at bevare pladsholderne), hvorefter værdierne sættes tilbage — så strenger af typen `"共 {0} 条"` oversættes uden at ødelægge de dynamiske dele.
6. **Sprogtabel** (`app_language.dart`): hvert `AppLanguage` bærer et visningsautonym, en `toModel`-promptstreng, der koder skrift-/regionskonventioner, og et flag for, om bilibilis officielle liste dækker det. Skriftregler (forenklet mod traditionel samt instruktionerne om dialektsamstemmighed) når kun modellen gennem prompten, og et deterministisk normaliseringstrin på klienten retter løse tegn bagefter.
7. **Kommentarer** går gennem `uiTxComment(text, id)` og bevarer `@ / [emoji] / #emne# / link` som intakte tokens; rich text-spans, der bærer links, oversættes, mens linkgenkenderen bevares, og et id-sæt pr. kommentar styrer Original ⇄ Oversættelse-kontakten.
8. **Danmaku** (`danmaku/view.dart`): når kontakten er slået til, går en positionslytter gennem `[playhead, playhead + 15s]` ét sekund ad gangen og forvarmer `uiTx()` på hvert danmaku-elements indhold, så elementerne er foroversat, før de når skærmen; aktivering rydder og gentegner lærredet.
9. **Lagringsnøgler**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Indstillingsbrugergrænseflade**: én førsteniveaus-side »AI-funktioner« (`lib/pages/setting/ui_translate/`) med uafhængige blokke til AI-videosammendrag og AI-oversættelse.

**CDN i hele verden (`VideoUtils.getCdnUrl`).** Stream-URL'er er signerede, og at omskrive en URL's værtsnavn får den afvist med 403 — så afspilning omskriver aldrig værter. PiliBabel returnerer den georuttede URL, som bilibili giver klientens IP, og når kandidatlisten allerede indeholder en oversea-kant (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`), foretrækkes den. Downloads, hvor et værtsskifte er sikkert, foretrækker desuden den globale Akamai-kant og roterer til næste signerede kandidat, når en linje går i stå eller afviser en genoptagelse. Rå `/v/resource` P2P-links falder stadig tilbage til det eksisterende relay for at undgå 404.

**Designafvejninger / kendte begrænsninger.** Fordi strenger wrappes på stedet i stedet for at blive trukket ud i ressourcer, udfyldes nogle få strengparametre uden for `Text` og enkelte rich text-spans stadig trinvist. Strenger, der dobbeltfungerer som **logiknøgler** (sammenlignet med `==`, brugt som fanenavne som `简介`, eller enum-etiketter i switches), wrappes bevidst **ikke** generelt for at undgå at ødelægge adfærden. Danmaku-oversættelse er bedste indsats på et rullende lærred — under ekstremt tæt danmaku kan du kort se originalen, før oversættelsen kommer. Oversættelse kræver netværk; uden det træder ikke-kinesiske mål ganske enkelt ikke i kraft. Det indbyggede endpoint er en gratis offentlig tjeneste drevet af bilibili — hvis den nogensinde bliver rate-limited eller utilgængelig, fortæller appen dig det, og du kan skifte til din egen API.

## Byg og verificér

Appen bygges med et patchet Flutter SDK plus patchede `material_ui` / `cupertino_ui`-pakker via `lib/scripts/patch.ps1` og `lib/scripts/build.ps1` (præcis som PiliNara / PiliPlus). GitHub Actions producerer en **debug-APK** ved hvert push (`.github/workflows/ui-translate-debug.yml`), og **publicering af et tag `v*` bygger og udgiver automatisk Android-, Windows- og Linux**-artefakter (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Platforme
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

PiliBabel leverer **Android (APK) -, Windows- og Linux**-builds fra Releases; iOS/Pad er ikke pakket i denne fork endnu.

<br/>

## Download

Hent et build fra **Releases**, eller klon repoet og byg det lokalt.

### Arch Linux

Tak til [@nlsdt](https://github.com/nlsdt) for pakningen (PiliNara-opskriften overføres til PiliBabel).

```bash
sudo pacman -S pilinara      # via Arch Linux CN-repositoriet
paru -S pilinara-bin         # eller via AUR: pilinara-bin (præ-bygget) / pilinara (kildekode)
```

<br/>

## Arvet funktionslog (fra PiliNara / PiliPlus)

Alt nedenfor er arvet fra PiliNara (og, indirekte, PiliPlus); PiliBabel tilføjer AI-oversættelseslaget oven på.

**Brugergrænseflade og platformstilpasning**
- [x] App omdøbt pr. platform, så flere klienter kan sameksistere (PiliBabel installeres ved siden af PiliNara)
- [x] Rettet Flutter-rendering under Xiaomi HyperOS-minivindue ([#161086](https://github.com/flutter/flutter/issues/161086), via [venera#467](https://github.com/venera-app/venera/pull/467)); forudsigende tilbage-animation på Android
- [x] Tilpasselig rækkefølge/antal for »Min«-kort; forhåndsvisning af historiekort og »se senere«-afsnit
- [x] Automatisk sidepanelskift med konfigurerbar udløserbredde; kopiér billede fra langt tryk / højreklik; stor MD3E-stil-opdatering

**Skrifttypesystem** — en samlet importpool med indholdshash-deduplikering, danmaku-skrifttyper samlet i samme pool, `loadFontFromList` med ttc-understøttelse og rene ASCII-hash-familienavne.

**Afspilning, minivindue og kvalitet** — minivindue i appen (træk, ændr størrelse, SponsorBlock-spring, automatisk system-PIP, selvrædningslinje i live), samtidig lydafspilning, lydstyrke i appen op til 200 %, selvvalgt video-CDN-domæne og valg af regional knude med latensmåling, separate standardkvaliteter til halv/fuld skærm, hastighedslås ved swipe op, tastaturstyring på tablet, SuperChat-tidsstempler i live, live-hjerteslag for fan-intimitet.

**Undertekster, AI og offline** — tosprogede undertekster med selvstændig styling af sekundær undertekst, AI-undertekstanalyse (selvvalgt OpenAI-kompatibelt endpoint, tidsstempel-spring, skabeloner, vedvarende samtaler, blød reserveløsning når undertekster mangler), WEBVTT/SRT-eksport, dobbeltvisning af offlinecache med mappehåndtering og vedvarende metadata, eksport af downloads til den offentlige Download-mappe (Android).

**Danmaku og blokering** — forbedret skalering af sammenlagt danmaku (i [Pakku.js](https://github.com/xmcp/pakku.js)-stil), listebaseret visuel regex-blokering med import/eksport, SponsorBlock-spring ved søgning ind i et segment, højenergi-fremgangslinje med gaussisk kerne.

**Filtrering af anbefalinger / dynamik / kommentarer** — nøgleord for titel/UP/kanal, varighed, afspilningsantal, like-rate, undtagelse for fulgte UP, filtrering af uautoriseret/kun-betalt indhold, delt whitelist, kommerciel/uautoriseret dynamik, undtagelser for UP-egne og fastgjorte kommentarer, App+Web-sammenlagt feed-tilstand.

**Dynamik, søgning og brugerinfo** — egne noter til UP, note-erstatter-kaldenavn på 13 navnepladser, selvstændig sortering af indlejrede kommentarer, lokalt nøgleordssøgefilter, b23.tv-kortlink-hop, kun-betalt-merke, kontakt til at skjule anbefalingsgrundlag, visning af mønt-XP.

**Live-forbedringer** — panel til at bære fanmedaljer, DLNA-casting der foretrækker HLS, SuperChat-tidsvisning, nederste kontrolinje i minivinduet til selvrædning.

**Systemintegration og skrivebord** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), ombygget håndtering af lydfokus.

<details>
<summary>Fuld original funktions-/tjekliste (ordret, fra PiliNara — klik for at udvide)</summary>

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

## Ansvarsfraskrivelse

PiliBabel er et personligt, interesse-drevet projekt, tilbudt **kun til læring og test**; slet det venligst inden for **24 timer** efter download.

- PiliBabel er en **uofficiel tredjeparts**klient og er **ikke tilknyttet, ikke godkendt af og ikke sponsoreret af bilibili**.
- Alle API'er er samlet fra officielle offentlige endpoints; **der tilbydes intet knækket, over-privilegeret eller betalingsmur-omgående indhold**.
- **AI-oversættelsen kører på et model-endpoint hos en tredjepart.** Som standard er det bilibilis egen gratis offentlige Index-Translate-tjeneste; hvis du skifter til din egen API, er det endpointet, du konfigurerede. Oversættelseskvalitet og compliance er brugerens og den valgte modeludbyders ansvar; dette projekt hoster **ingen model og ingen API-nøgle**.
- Respektér ophavsret og bilibilis servicevilkår. Brug ansvarligt.

Med respekt for de oprindelige og upstream-forfattere for deres engagement i open source:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — det direkte overordnede projekt for PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — den åbne familie af oversættelsesmodeller, som den indbyggede motor kalder

Hvis noget indhold krænker dine rettigheder, så kontakt os vedrørende fjernelse.

<br/>

## Licens

PiliBabel er licenseret under **GNU General Public License v3.0 (GPL-3.0)** — samme licens som PiliNara, PiliPlus og PiliPala. Fordi det er et afledt værk, **skal PiliBabel også distribueres under GPL-3.0**: du er fri til at bruge, studere, dele og ændre det, forudsat at du bevarer samme licens, ophavsretsmeddelelserne og denne licenstekst. Se [`LICENSE`](./LICENSE).

Tredjepartskomponenter (Flutter-pakker, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio) osv.) forbliver under deres egne licenser.

Den medfølgende skrifttype **LXGW WenKai** er licenseret separat under **SIL Open Font License 1.1**; dens licenstekst leveres inde i appen som `assets/fonts/LXGWWenKai-OFL.txt`.

<br/>

## Tak

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — bilibilis åbne familie af oversættelsesmodeller og det gratis offentlige endpoint bag den indbyggede motor
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — den åbne kinesiske skrifttype, der er bundlet med appen, under SIL Open Font License 1.1
- og mere
- Inspireret af bilibilis officielle »AI-brugergrænsefladeoversættelse«.
