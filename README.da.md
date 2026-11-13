<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>En tredjepartsklient til bilibili med AI-drevet oversættelse.</b></p>
    <p>Babel — river sprogbarrieren ned, så alle kan nyde bilibili på deres eget sprog.</p>
    <p>Forener bilibilis officielle liste på 151 sprog med 6 flere, den ikke dækker - traditionel kinesisk, forenklet og traditionel wu, hokkien fra Taiwan samt zhuang. Den sjette er Tâi-gí — taiwansk hokkien skrevet helt i POJ, uden et eneste kinesisk tegn.</p>
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
- **Én sprogliste, begge motorer.** Målsprogslisten opdeles ikke pr. motor — den samme liste tilbydes, uanset hvilken motor du vælger. Den forener de **151 sprog** i bilibilis officielle model med **6 flere, den ikke dækker** — traditionel kinesisk, forenklet og traditionel wu, taiwansk hokkien samt zhuang. Regionale og skriftvarianter bevares som **separate poster** i stedet for at blive slået sammen — marokkansk / egyptisk / najdi / levantinsk arabisk er hvert sit valg, og det samme gælder kyrillisk-mod-latinsk serbisk, usbekisk og urdu. Den sjette er Tâi-gí — taiwansk hokkien skrevet helt i POJ, uden et eneste kinesisk tegn.
- **Ærlig om dækning.** Sprog inden for den officielle liste dækkes af bilibilis model. De få udenfor — traditionel kinesisk, forenklet og traditionel wu, taiwansk hokkien samt zhuang — vises stadig på listen, markeret som sådan, så du med ét blik ved, at et bedre resultat kan kræve din egen model. Den sjette er Tâi-gí — taiwansk hokkien skrevet helt i POJ, uden et eneste kinesisk tegn.
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

## Ændringslog: 2.6.x → 3.9.3

- **2.6.x** — lydcache (adskilte moduler til video og lyd, husker sidste valg, indgange på videosiden, på lydsiden og i afspilleren; originalformatet bevares; kvalitet kan vælges) og download til enheden (eget menupunkt: først video/lyd, derefter kvalitet; uden en valgt mappe åbnes systemets filvælger).

- **3.0.x–3.1.0** — selvhelbredende netværk i udlandet: helbred pr. vært med skift mellem primær og reserve, DNS-opslag med cache, forvarmning af forbindelser, afkøling efter risikokontrol (412), regionsgenkendelse med manuelt valg, CDN-hastighedstest delt med API-laget; afspillerens fremadgående buffer følger nu videosporens bitrate.

- **3.2.0–3.3.3** — netværksfundament i den officielle apps stil: anmodningsfingeraftryk (buvid/fp/session_id/env), failover for gRPC-værter, retry-interceptor, grænse for samtidige anmodninger pr. vært, forudindlæsning af første feed ved kold start, officielle feed-hændelsesparametre, CDN-kandidaternes rækkefølge med udenlandske reserver; forudindlæsning af anden side, afgrænset kø til forudindlæsning af forsider, forudindlæsning af afspilnings-URL'er; derefter gengivelse af dynamik (P3) via gRPC samt rettelser: kompileringsfejl i buffertiden på lydsiden og typefejl i forudindlæsningen af kommentarer, som fik hvert nyt forsøg til at fejle øjeblikkeligt.

- **3.3.4** — dynamikkort til betalte opslag, mini-apps, emnesamlinger og abonnementer; fejlen hvor hjemmeskærmens første side mistede alle forsider er rettet; opdateringer fra PiliNara er hentet ind (statuslinje, genoptagelse af download efter procesafslutning, opdatering af media-kit, omgåelse af sort video i Wayland, valg af lydkvalitet ved cache); AI-oversættelsesrevision af al grænsefladetekst tilføjet siden 3.0.5; denne log.

- **3.3.x — den lange hale.** Dynamik (P3) via gRPC og dynamikkort til opladning, miniapps, emnesamlinger og abonnementer; forsiden mister ikke længere sine omslag på første skærm; en synkronisering med PiliNara (sort statuslinje, download genoptages efter dræbt proces, media-kit-opdatering, workaround for sort video på Wayland); derefter en afsluttende runde, der omlagde billedpipelinen til direkte forbindelse (løste både »omslag kræver træk-for-at-opdatere« og et bredt dataudfald), satte dataanmodninger til direkte forbindelse som standard, sendte lyd og video gennem en segmenteret proxy med flere forbindelser, begrænsede seek-ventetid til 600 ms og gendannede »vis fuld titel« pr. skærm.

- **3.4.0 — revisionen.** Analyzeren bragt til **0 fejl / 0 advarsler**, alle 44 sproglige READMEs fik en note om AI-oversættelse, og den resterende opgaveliste plus de kendte adfærdsforskelle i forhold til den officielle app blev skrevet ned i `docs/`.

- **3.5.0–3.9.3 — terminologi, oversættelse, undertekster, polering og afspillerrettelser.** Ordlisten voksede til **15 tabeller på fem sprog** (12 spil plus hololive, NIJISANJI og THE iDOLM@STER, 11.600+ termer) og lærte at opløse korte navne, hver del af et flerleddet navn og termer inde i en sætning, med en kontakt pr. tabel. Desuden: det officielle AI-taleoverføringsspor følger grænsefladesproget, søgesidens trending-ord oversættes og får to linjer, opdateringsdialogen læses som ren tekst i stedet for rå Markdown og oversættes først, så den aldrig åbner på kinesisk, automatisk opdateringstjek af ordlistetabellerne, og hakket ved tændt AI-oversættelse er væk. Et nedbrud fra 3.6.3, hvor tændt AI-oversættelse kunne efterlade siderne tomme og derefter lukke appen, er rettet i 3.6.4. I 3.6.5 stopper en indlejret term ikke længere resten af afsnittet fra at blive oversat, ordlisteskærmen følger appens tema, tabellerne er slået til som standard, og den version appen angiver om sig selv, matcher nu dens udgivelsestag. 3.6.6 retter, at dele af et efternavn blev udvidet til det fulde navn, lader ordlisteskærmen følge temaet igen (kontakterne virker) og lader officielle ordlistenavne overtrumfe forældede cachede oversættelser; 3.6.7 retter tælleren, der sad fast på 14/15 med alle kontakter slået til, og de viste tal i tre tabeller, som var forkerte (Reverse: 1999 havde slet intet indlejret). 3.6.8 tilføjer AI-undertekstoversættelse: kinesiske undertekster oversættes i kontekstbevidste blokke, med buffering i realtid, styring pr. spor, en offline vietnamesisk ordbog og valgfri proxy-routing (bidrag fra [saukhoai](https://github.com/saukhoai) via [PR #2](https://github.com/SiqYin/PiliBabel/pull/2)). 3.6.9 justerer undertekstknappens størrelse, tilføjer automatisk opsætning ved første start med registrering af systemsproget, oversætter segmentoplysningerne i afspillerlinjen, lader lydsporvalget følge sprogskiftet og retter uoversatte handlingsbeskeder. 3.7.0 tilføjer et HiRes-lydmærke i afspillerlinjen, retter fejl ved søgning og genindgang i lydafspilleren, registrerer automatisk tab af lydsporet og gendanner det uden tab, og retter flimren i videoens statuslinje under søgning. 3.7.1 gør undertekstknappen på omslaget til et rent ikon i samme størrelse som omslagsoversættelsesknappen og placerer det lige over den, forklarer de to knapper én gang ved første start, begynder at forhåndsoversætte undertekster, så snart en video åbnes, og rapporterer ikke længere «ingen undertekster / ikke logget ind» som en fejl. 3.7.2 retter den fejl, der gjorde undertekstoversættelsen umulig: i stedet for at afvise hver linje, der ligner originalen, kontrolleres hele blokken (kinesiske sprog er undtaget), batch-kald falder tilbage til linje-for-linje, ødelagte tidskoder kasseres, en fastlåst opgave giver op med den virkelige årsag, og både succes og fiasko giver en besked; «ikke logget ind» bliver nu også oversat. 3.7.3 gennemgår hele undertekstkæden: anime deler nu én identitetsnøgle mellem baggrundsjobbet og afspilleren, så en færdig oversættelse faktisk findes, og »slet oversættelse« virkelig sletter; et dobbelttryk kan ikke længere gøre en succes til en fejl; downloadede spor bærer den fulde målkode, så skift mellem forenklet, traditionel kinesisk, kantonesisk og wu ikke længere viser forkert skrift; usorterede tidskoder sorteres før oprensning, et tomt spor tæller ikke som en vellykket download, japansk og koreansk dømmes ikke længere som uoversat, status for flere dele samles i stedet for at overskrives, og alle undertekstbeskeder er forvarmet. 3.7.4 retter knappen til caching af undertekster, der kunne dreje for evigt: batchjob afsluttes nu altid (en del uden undertekster blokerer ikke længere hele sættet), samme afsnit åbnet fra forskellige indgange oversættes ikke to gange eller misses, afslutnings- og fejlmeddelelser når altid frem, vietnamesiske sportnavne viser ikke længere kinesisk først, undertekst-downloads prøver også v2-adressen, og en beskadiget oversættelse kopieres aldrig til offlinevideoer. 3.7.5 får danmaku-oversættelse til virkelig at fungere: hele segmenter foroversættes i batch, så kommentarer allerede er oversat, når de vises; oversættelseskøen lader ikke nyligt opdaterede titler sulte bag forvarmede tekster; fremdriftsringen på omslagsknappen bliver til et flueben, så snart den fyldes, og er lettere at læse under indlæsning; gamle oversættelsesspor med kun sprogtag gendannes i stedet for at blive oversat igen; og release-notes-arkivet er komplet igen. 3.7.6 forenerer fremdriftsringene på de to omslagsknapper: begge bruger nu den samme 17-pixels ring med bestemt fremdrift, der fyldes med uret fra nul i stedet for at dreje rundt for evigt; desuden er fejlen rettet, hvor batchopgaver (samling/flere dele) kolliderede med den valgte dels statusnøgle – delen oversættes nu faktisk, og batchen kan afsluttes. 3.7.7 gør omslagsknapperne til en kolonne på tre — danmaku, undertekster og coveroversættelse: hver knap hviler lille, vokser ved indlæsning og vender tilbage til lille med et grønt flueben, når den er færdig, og kolonnen rykker blødt til side når en vokser; cover-ringen viser nu reel downloadfremskridt; danmaku-foroversættelse får sin egen knap, der henter alle segmenter på forhånd og oversætter i batches; og uploader-navne bruger altid den fulde ordbogsform, mens titler og kommentarer beholder kortformen — スターレイル får også sin egen kortform スタレ. 3.7.8 fortsætter: intro-popuppen ved første start forklarer nu alle tre omslagsknapper (danmaku, undertekster og oversættelse); at åbne en video starter danmaku-foroversættelse automatisk sammen med underteksterne; danmaku-foroversættelsen bruger samme samtidige worker-pool som undertekster og føles lige så hurtig; og cover-genkendelsesanmodninger serialiseres i klikrækkefølge med automatiske forsøg ved gateway-timeouts — at trykke på flere omslag i træk ødelægger ikke længere de første, og 504 heler sig selv. 3.7.9 tilføjer højre-til-venstre-spejling: når grænsefladesproget skrives højre-til-venstre (arabisk, hebraisk, uigurisk og andre arabiske/hebraiske skriftvarianter), spejles navigation, lister, justering og margener automatisk; billeder og videoindhold spejles aldrig — afspillerens tidslinje forbliver venstre-til-højre. Også oversættelses-knapkolonnen og mærker på covers skifter side efter læseretning. 3.7.10 tilføjer højre-til-venstre-spejling: når grænsefladesproget skrives højre-til-venstre (arabisk, hebraisk, uigurisk og andre arabiske/hebraiske skriftvarianter), spejles navigation, lister, justering og margener automatisk; billeder og videoindhold spejles aldrig — afspillerens tidslinje forbliver venstre-til-højre. Også oversættelses-knapkolonnen og mærker på covers skifter side efter læseretning. 3.7.11 lægger de tre omslagsknapper vandret i stedet for lodret — coveroversættelse forankret i hjørnet, derefter undertekster, derefter danmaku — med samme vækst/tilbagevendende animation og skub-tilpasning nu langs rækken; RTL-spejlingen følger læseretningen. 3.7.12 tilføjer annuller/fortryd til de tre omslagsknapper: at trykke på en knap mens den loader stopper opgaven, sletter alt den har cachet og nulstiller den; en færdig (grønt flueben) kan også trækkes tilbage og få sin cache ryddet — selv et vellykket job kan altid fortrydes. 3.7.12→3.8.0: danmaku skifter på stedet til deres oversættelse — var oversættelsen ikke klar ved visning, skifter teksten automatisk, når den ankommer, uden at genstarte afspilning. De tre omslagsknapper ligger nu vandret (cover, undertekster, danmaku), første-start-introen beskriver dem venstre-til-højre, og canvas_danmaku-rendereren er taget ind i repoet for udskiftning på stedet. 3.7.12→3.8.1 afrunder 3.7-æraen: undertekster hærdet ende-til-ende, danmaku foroversat med udskiftning på stedet, cover-genkendelse med annuller/fortryd, RTL-spejling med blød flip-overgang — og alle sprog er nu søgbare via eget navn eller engelsk navn (uigurisk med). 3.8.2 gør retningsskift sikker og søgning gnidningsfri: flip-overgangen ved spejlskift gør ikke længere skærmen sort — visningen roterer til kanten, skifter retning på stedet og folder sig ud igen; den gamle løsning, der monterede navigatoren dobbelt, er skiftet ud. Sprogvælgeren fjerner desuden usynlige kontroltegn fra indsæt tekst, tilpasser søgefeltets retning til det indtastede og opdaterer resultater i realtid — uden Enter. 3.8.3 henter mærkeikonet tilbage, hvor det var blevet tomt: avataren for "alle uploadere" i dynamikken og logoet i gem-panelet viser igen det rigtige farvede logo, i stedet for den ensfarvede skive, der blev tilbage da den gamle konturgrafik blev skiftet ud med den fyldte gradientgrafik. 3.8.4 indarbejder forstærkning bidraget af saukhoai: ventetid på en oversættelsesproxyrute får nu timeout efter 60 sekunder, og opgivne ventere kan ikke længere stjæle frigivne pladser; en ny kontakt (til som standard) afgør, om afspilning må holde pause, når realtid undertekst-buffering halter bagefter, og afspilningen genoptages altid, når et undertekstjob giver op; yderligere elleve faste UI-tekster fik offline-vietnamesiske oversættelser. 3.8.5 starter undertekstoversættelsen fra det tidspunkt, hvor afspilningen faktisk begynder: at genoptage en lang video kræver ikke længere, at alt forinden oversættes først, og start fra 0:00 er uændret. 3.8.6 får HiRes-mærket i afspillerlinjen til endelig at dukke rigtigt op: det læste hidtil et almindeligt felt inde i en reaktiv blok, hvilket GetX afviser blankt, så det var aldrig blevet renderet siden 3.7.0; nu sidder det til venstre for segmentoplysningerne, skjuler sig når videoen ikke har et HiRes-spor, lyser mens HiRes-lyd afspilles og kan trykkes for at skifte mellem HiRes og det bedste ikke-HiRes-spor. 3.8.7 — Den sjette er Tâi-gí — taiwansk hokkien skrevet helt i POJ, uden et eneste kinesisk tegn. 3.8.8 retter sprogfeltet — listen filtrerer nu, mens du skriver, uden at du skal trykke på Enter — og tilføjer to kontakter til automatisk oversættelse af undertekster og danmaku, når du åbner en video (begge er tændt som standard). 3.8.9 gør de to automatisk-oversæt-kontakter færdige (slår man dem fra, stopper alle automatiske undertekst- og danmaku-oversættelser virkelig), deler oversættelsescacherne op efter sprog og gør danmaku-oversættelsen hurtigere. (3.8.10, 3.8.11, 3.8.12) (3.8.10, 3.8.11, 3.8.12, 3.8.13) I 3.8.12 / 3.8.13 / 3.8.14 / 3.9.0 / 3.9.1 er PiliNara-funktioner porteret: `#tag`-søgning, skjulte sidepanelsetiketter, rullehjulsvolumen, av-nummer, jumpscare-segmenter, kontinuerlig tilbagespoling, videorotation, SuperChat-gennemsigtighed, AI-chat-afbrydelse, sektionspanel. **3.9.2 / 3.9.3** udvider den indbyggede ordliste fra 11.742 til 19.482 opslag (Genshin 5.788, Star Rail 2.823, ZZZ 1.815, Wuthering Waves 1.443), tilføjer spillenavne i alle 15 tabeller (异环 hedder nu NTE på japansk) og giver hver ny tabel en lang og en kort form.

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
<br/>

---

> **Note om dokumentationssprog.** Denne README og dens oversættelser skrives og vedligeholdes med hjælp fra AI-oversættelsesværktøjer; den engelske version er reference, hvis en formulering virker inkonsistent.
> **Erklæring:** At distribuere PiliBabel-installationspakker uden tilladelse er en krænkelse. Download kun fra den officielle kanal [GitHub Releases](https://github.com/SiqYin/PiliBabel/releases). Fuld erklæring: [STATEMENT.md](STATEMENT.md).
