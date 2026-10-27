<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>En tredjepartsklient for bilibili med AI-drevet oversettelse.</b></p>
    <p>Babel — river ned språkbarrieren, så alle kan nyte bilibili på sitt eget språk.</p>
    <p>Forener bilibilis offisielle liste på 151 språk med 6 til som den ikke dekker - tradisjonell kinesisk, forenklet og tradisjonell wu, hokkien fra fastlandet og Taiwan, samt zhuang.</p>
    <p>Oversettelsen fungerer rett ut av boksen på bilibilis egen gratis modell — ingen API-nøkkel kreves.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.nan.md">台語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.mn.md">Монгол</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.pt.md">Português</a> · <a href="README.bn.md">বাংলা</a> · <a href="README.th.md">ไทย</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.it.md">Italiano</a> · <a href="README.fa.md">فارسی</a> · <a href="README.fil.md">Filipino</a> · <a href="README.ur.md">اردو</a> · <a href="README.mr.md">मराठी</a> · <a href="README.te.md">తెలుగు</a> · <a href="README.ta.md">தமிழ்</a> · <a href="README.pa.md">ਪੰਜਾਬੀ</a> · <a href="README.gu.md">ગુજરાતી</a> · <a href="README.ha.md">Hausa</a> · <a href="README.sw.md">Kiswahili</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.my.md">မြန်မာ</a> · <a href="README.pl.md">Polski</a> · <a href="README.is.md">Íslenska</a> · <b>Norsk</b> · <a href="README.fi.md">Suomi</a> · <a href="README.sv.md">Svenska</a> · <a href="README.da.md">Dansk</a> · <a href="README.be.md">Беларуская</a> · <a href="README.ug.md">ئۇيغۇرچە</a> · <a href="README.kk.md">Қазақша</a> · <a href="README.bo.md">བོད་ཡིག</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Hjem" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dynamikk" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Meg" />
</div>

<br/>

> **Ansvarsfraskrivelse.** PiliBabel er en **uoffisiell, åpen kildekode-, tredjeparts**klient. Den er **ikke tilknyttet, ikke godkjent av og ikke sponset av** bilibili / bilibili Inc. Hver enkelt API er samlet inn fra de offisielle offentlige endepunktene; **betalt innhold låses verken opp eller knekkes**. Vennligst les de fullstendige avsnittene [Ansvarsfraskrivelse](#ansvarsfraskrivelse) og [Lisens](#lisens).

## Hva er PiliBabel?

PiliBabel er en **uavhengig tredjeparts-fork bygget oppå [PiliNara](https://github.com/Starfallan/PiliNara)**, og den arver alt det PiliNara arver:

```
bilibili (offisielt offentlig API)
        ▲
   PiliPala / PiliPalaX        — det opprinnelige prosjektet
        ▲
   PiliPlus                    — aktiv fork
        ▲
   PiliNara                    — fork av PiliPlus (personlige justeringer)
        ▲
   PiliBabel  ← du er her   — fork av PiliNara
```

PiliBabel beholder **alle funksjonene til PiliNara / PiliPlus** (se [arvet funksjonslogg](#arvet-funksjonslogg-fra-pilinara--piliplus) nederst) og legger til **to hovedfunksjoner som oppstrømsklientene ikke har**:

> **AI-oversettelse av grensesnitt og innhold** — hele appen (grensesnittetiketter, videotitler, UP-navn, kommentarer, dynamikk, strøm og til og med danmaku (rullende skjermkommentarer) i direktesending) vises på språket **du** velger.

Og siden 1.0 gjør den det **rett ut av boksen**: oversettelsesmodellen er **innebygd**. bilibili åpnet kildekoden til sin egen familie av oversettelsesmodeller, [Index-Translate](https://github.com/bilibili/Index-Translate), og betjener den fra et gratis offentlig endepunkt. PiliBabel leveres pekt mot det, så oversettelsen fungerer i det øyeblikket du installerer appen — ingen registrering, ingen nøkkel, ingen regning. Hvis du heller vil bruke din egen modell, er egen-API-veien fortsatt der, ett trykk unna.

> **Lyd i hodetelefoner som faktisk holder seg synkronisert** — med Bluetooth- eller kablede hodetelefoner henger ikke lyden lenger etter bildet. Den offisielle appen får dette til; PiliNara og PiliPlus gjør det ikke, rett ut av boksen. PiliBabel ber nå mpv om **AudioTrack** først, som *måler* lydutgangsforsinkelsen på samme måte som den offisielle klienten, i stedet for **OpenSL ES**, som bare *anslår* den.

## Nøkkelfunksjoner

- **Synkronisert lyd i hodetelefoner.** Spilleren bruker nå mpvs **AudioTrack**-backend som standard (rekkefølge `audiotrack,aaudio,opensles`) i stedet for **OpenSL ES**. AudioTrack rapporterer en *målt* utgangsforsinkelse — den leser antall avspilte rammer og enhetens presentasjonstidsstempel — som er nøyaktig hvordan den offisielle bilibili-appen og Androids egen `MediaSync` holder bilde og lyd sammen. OpenSL ES *anslår* den bare, så på Bluetooth-hodetelefoner drev lydklokken, og bildet ble vist for tidlig. I testing er forsinkelsen i praksis borte. Endre rekkefølgen når som helst i Innstillinger → Video → Lydutgangsenhet.

- **AI-oversettelse overalt.** Navigasjonsfaner, videokort, detaljsider, kommentarer, dynamikk og Mine / Favoritter / Historikk / Meldinger / Søk-flatene — en gjennomgripende gjennomgang dekker **~1 650+ grensesnittstrenger**, i tillegg til dynamisk innhold (titler, forfatternavn, handlingsantall).
- **To motorer, én bryter.** *Innebygd* (standard) bruker bilibilis offisielle gratis **Index-Translate-35B-A3B**-endepunkt — ingenting å konfigurere. *Egen API* beholder den tidligere oppførselen: pek den mot et hvilket som helst OpenAI-kompatibelt `/chat/completions`-endepunkt med din egen basis-URL / nøkkel / modell. AI-videosammendraget og AI-oversettelsen har fortsatt **helt uavhengige** endepunkter og innstillinger, begge samlet på én **«AI-funksjoner»**-side.
- **Én språkliste, begge motorer.** Målspråklisten er ikke delt etter motor — den samme listen tilbys uansett hvilken motor du velger. Den forener de **151 språkene** i bilibilis offisielle modell med **6 til som den ikke dekker** — tradisjonell kinesisk, forenklet og tradisjonell wu, fastlands- og taiwansk hokkien, samt zhuang. Regionale og skriftvarianter beholdes som **egne oppføringer** i stedet for å slås sammen — marokkansk / egyptisk / najdi / levantinsk arabisk er hvert sitt valg, og det samme er kyrillisk-mot-latinsk serbisk, usbekisk og urdu.
- **Ærlig om dekningsgrad.** Språk innenfor den offisielle listen dekkes av bilibilis modell. De få utenfor — tradisjonell kinesisk, forenklet og tradisjonell wu, fastlands- og taiwansk hokkien og zhuang — vises likevel i listen, merket som sådan, så du ser med én gang at et bedre resultat kan kreve din egen modell.
- **Oversett én gang, så er det fast.** Hver kildestreng oversettes **nøyaktig én gang**; resultatet lagres lokalt og **oversettes aldri på nytt** når du åpner en skjerm igjen — samme prinsipp som den offisielle klienten, for stabile, forutsigbare oversettelser.
- **Original ⇄ Oversettelse-veksling per kommentar** (et lite ikon, ikke et kinesisk ord). `@omtaler / [emoji] / #emner# / lenker` bevares som token, og **kommentarer med hyperlenker oversettes fortsatt mens lenken forblir klikkbar**.
- **Oversettelse av danmaku (弹幕)** — en egen bryter i spillerens øverste høyre kontrollrad, **av som standard** og skjult bak en bekreftelse hvis egen tekst er oversatt. Når den er aktivert, forhåndsoversettes danmaku foran avspillingshodet i **~15-sekunders bunker** (å søke til midten håndteres riktig, ikke fra starten), så oversettelsen er vanligvis klar når den ruller inn på skjermen.
- **Bryter for tenkemodus** (`enable_thinking`) for kvalitet mot hastighet, i tillegg til knapper for **«testoversettelse»** og **tømming av hurtigbufferen** i innstillingene.
- **Raskt språkbytte**: forespørsler i bunker med begrenset samtidighet mot en vedvarende buffer; å bytte språk tvinger gjennoppbygging av den gjeldende skjermen én gang, så du sitter ikke og stirrer på uoversatt tekst. Å slå av AI-oversettelsen gjenoppretter hele grensesnittet til originalteksten og sender ingen forespørsler i det hele tatt.
- **Introduksjon ved første oppstart.** Første gang du åpner appen, tilbyr en engelsk dialog å slå på oversettelse. Å godta aktiverer oversettelsen, velger den innebygde modellen, åpner AI-innstillingssiden og spør umiddelbart hvilket språk du vil ha — så en ny bruker går fra installasjon til oversatt app i to trykk.
- **Avspilling som fungerer i hele verden.** PiliBabel velger den utenlandske edge-noden (global **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) som bilibilis georutete `playurl` allerede tilbyr, i stedet for å låse deg til en fastlandsknode (Aliyun/Shenzhen) — så brukere utenfor fastlands-Kina går ikke lenger i stå («lyden fortsetter å spille, videoen fryser»). Du kan fortsatt låse en CDN manuelt i innstillingene.
- **En «Tema og farge»-side i Material You-stil.** Lys / mørk / følg systemet velges fra **tre levende forhåndsvisningskort** — hvert av dem viser en miniatyr av det ekte grensesnittet i nøyaktig de fargene modusen ville brukt («følg systemet»-kortet er delt diagonalt, lyst over mørkt). Under dem: **dynamisk farge** (hentet fra systembakgrunnen der enheten støtter det), **mørk med høy kontrast** (ekte svarte flater, skånsommere for øynene om natten) og **alltid mørk spiller**. Fargedelen beholder hele FlexScheme-paletten — **19 frøfarger** i tillegg til en egen **«palettstil»** som avgjør hvordan hver beholderfarge avledes fra frøfargen, uavhengig av hvilken frøfarge du velger.
- **LXGW WenKai følger med appen.** Skrifttypen **LXGW WenKai (霞鹜文楷)** er **pakket med og satt som standard** — en varm, svært lesbar kinesisk skrifttype du har fra det øyeblikket du installerer, i stedet for å lete etter en i en velger. Den gjelder hele grensesnittet *og* danmaku. Du kan fortsatt bytte tilbake til systemskriften, velge hvilken som helst installert systemskrifttype eller importere din egen `.ttf` / `.otf` / `.ttc`; en skrifttype du tidligere hadde valgt eksplisitt, beholdes gjennom oppgraderingen. Vekt og størrelse er fortsatt justerbare som før.

## Frakoblet lydbufring og nedlasting til lokal mappe (unikt for PiliBabel)

To muligheter oppstrøms PiliNara / PiliPlus ikke har — begge rettet mot å faktisk eie mediene dine frakoblet.

### Bufre lyd (frakoblet buffer kun for lyd)

- **Sporet, ikke videoen.** En oppføring *Bufre lyd* ligger rett under *Bufre video* i videomensyen, i tillegg til en egen bufre-lyd-knapp i den øverste linjen på lyttesiden.
- **Velg kvalitetsnivå.** Hi-Res tapsfritt, Dolby Atmos, 192K, 132K eller 64K — den samme forhåndsinnstilte listen som videokvalitetsvelgeren bruker.
- **Original beholder, ingen omkoding.** Filen skrives nøyaktig slik CDN-en leverer den: `m4a`, `mp3`, `flac`, `wav`, `aac` eller `ogg`.
- **Egen modul.** Buffersiden er delt opp i *Bufrede videoer* / *Bufret lyd* og husker hvilken modul du var på sist.
- Å trykke på et bufret lydelement åpner lydspilleren umiddelbart; elementer slettes enkeltvis eller i bulk.

### Last ned til lokal mappe

- **Egen menyoppføring.** *Last ned til lokal mappe* er en egen oppføring i videomensyen, rett under *Bufre lyd* — bufring inne i appen og lagring til en mappe er to forskjellige handlinger.
- **Last ned video eller last ned lyd.** Oppføringen spør først hvilken av delene, og deretter etter kvalitetsnivået (velger for videokvalitet / lydkvalitet).
- **Din mappe, dine regler.** Velg hvilken som helst mappe gjennom systemets filbehandler (Innstillinger → *Last ned til lokal mappe*), og endre eller fjern den når du vil. Hvis du ikke har valgt en ennå, åpnes mappevelgeren på stedet.
- **Filer som kan spilles direkte.** Video hentes som én enkelt multiplekset strøm (`fnval=1`), så det som havner på disken er en vanlig MP4 du kan gi til hvilken som helst spiller — ingen sidestrømmer å sy sammen.
- **Lyd beholder det originale formatet** — ingen omkoding, akkurat som bufferen i appen.
- Filer navngis etter videotittelen og overskriver aldri en eksisterende nedlasting.

## De to oversettelsesmotorerne

| | Innebygd (standard) | Egen API |
|---|---|---|
| Modell | **Index-Translate-35B-A3B** fra bilibili | hva som helst som er OpenAI-kompatibelt |
| Endepunkt | `index-translate.bilibili.com/v1` | din basis-URL |
| API-nøkkel | **trengs ikke** | din |
| Kostnad | gratis | det din leverandør tar betalt for |
| Forespørsler | én streng per forespørsel | i bunker (≤ 16 per forespørsel) |
| Ekstra språk | — | alle språk modellen din kan |

**Hvorfor én forespørsel av gangen for den innebygde motoren.** Index-Translate er en *spesialist* i oversettelse, og kallkonvensjonen forfatterne dokumenterer, er en mal for ett enkelt element («oversett følgende tekst til X, skriv ut bare oversettelsen»). PiliBabel sender derfor én streng per forespørsel på denne motoren i stedet for nummerert-liste/JSON-array-bunkeprompten den bruker for egen-API-oppsett. Endepunktet er gratis, så det er ingenting å hente på å satse på bunkeutdata — dette er en bevisst avveining av noen flere forespørsler mot langt færre måter å feile på.

**Oppgradering fra 0.3.x.** Dine egne API-innstillinger — basis-URL, nøkkel og modell — **lates akkurat slik du konfigurerte dem**. Motorvalget får ganske enkelt standarden innebygd modell, så ved første oppstart etter oppgraderingen kjører du på bilibilis gratis modell; åpne *Innstillinger → AI → AI-funksjoner → oversettelsesmotor* og bytt tilbake til *Egen API* for å gå umiddelbart tilbake til det tidligere oppsettet.

## Slik fungerer AI-grensesnittoversettelsen (teknisk)

Repoet har **ingen i18n / ARB-ressurslag** — grensesnittstrenger er hardkodet kinesisk. I stedet for å skrive om hver eneste widget legger PiliBabel et tynt oversettelseslag på toppen:

1. **En global oppslagsinnpakning.** `lib/services/ui_translate/` eksponerer en `uiTx(String src)` på toppnivå. Widgettekst som tidligere var `Text('中文')` blir `Text(uiTx('中文'))`. En skriptet **codemod** brukte dette over hele prosjektet (`tool/ui_translate_*.py`) — omtrent **223 filer / ~1 650+ strenger** — og fjernet automatisk det nå ugyldige `const`-nøkkelordet der det trengtes (inkludert generiske typer som `const X<T>(...)` og prikkede navn som `const Positioned.fill(...)`, og konverterte `static const`-liste-/kartdeklarasjoner til `static final`).
2. **En `GetxService`-kjerne** (`ui_translate_service.dart`):
   - et vedvarende **kilde → oversettelse**-hurtigminne (med GetStorage bak), slik at hver streng oversettes én gang og gjenbrukes for alltid;
   - `tx()` leser en `RxInt revision` først og avgjør deretter: hvis av → returner originalen; hvis målet er **forenklet kinesisk (`zh-CN`)**, returner originalen uten API-forespørsel (Bilibilis kildeinnhold er overveldende forenklet kinesisk). Hvert annet mål — inkludert tradisjonell kinesisk, kantonesisk, wu/shanghainesisk og hokkien/min nan — går gjennom den konfigurerte motoren; medlemskap i den kinesiske språkfamilien alene hopper ikke over oversettelsen. Server deretter fra hurtigminnet eller **legg i kø**;
   - strenger i kø tømmes av en **arbeiderpool** med **trinnvis anvendelse per bit** (hver returnerte bit øker `revision`, slik at teksten oppdateres gradvis), og resultatene **lagres vedvarende** (strupet). Bunkestørrelse og samtidighet følger motoren: **1 per forespørsel** på den innebygde modellen, **≤ 16 med ≤ 10 i luften** på din egen API.
3. **Motoroppløsning.** `TranslateProvider` (`builtin` / `custom`) avgjør hvilken URL, nøkkel og modell transporten bruker; begge motorene deler ellers én kodebane og én språkliste, så å bytte motor er én enkelt innstilling og aldri et annet funksjonssett.
4. **Transporten** gjenbruker samme verifiserte **strømmingskanal** som AI-videosammendraget — `AiChatService.streamChat` → `{base}/chat/completions` med `stream: true` (kompatibel med gatewayer som bare støtter strømming) — utvidet slik at oversettelsen kan bruke sine **egne** `apiUrl` / `apiKey` / `model` og et `enable_thinking`-flagg. Endringen er **bakoverkompatibel**, så videosammendraget fortsetter å fungere uendret.
5. **Interpolerte setninger** bruker `uiTxP(template, args)`: en hel setning med `{0}`/`{1}`-plassholdere oversettes som én stabil nøkkel (prompten ber modellen beholde plassholderne), og deretter settes verdiene inn igjen — slik at strenger av typen `"共 {0} 条"` oversettes uten å ødelegge de dynamiske delene.
6. **Språktabell** (`app_language.dart`): hver `AppLanguage` bærer et visningsautonym, en `toModel`-promptstreng som koder skrift-/regionkonvensjoner, og et flagg for om bilibilis offisielle lager dekker den. Skriftregler (forenklet mot tradisjonell, og instruksjonene om dialektsamsvar) når modellen bare gjennom prompten, og et deterministisk normaliseringsslag på klienten retter løse tegn etterpå.
7. **Kommentarer** går gjennom `uiTxComment(text, id)` og beholder `@ / [emoji] / #emne# / lenke` som intakte token; riktekstspenn som bærer lenker, oversettes mens lenkegjenkjenneren bevares, og et id-sett per kommentar styrer Original ⇄ Oversettelse-vekslingen.
8. **Danmaku** (`danmaku/view.dart`): når bryteren er på, går en posisjonslytter gjennom `[playhead, playhead + 15s]` ett sekund av gangen og forvarmer `uiTx()` på hvert danmaku-element sitt innhold, slik at elementene er forhåndsoversatt før de når skjermen; å aktivere den tømmer lerretet og tegner det på nytt.
9. **Lagringsnøkler**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Innstillingsgrensesnitt**: én førstenivåside «AI-funksjoner» (`lib/pages/setting/ui_translate/`) med uavhengige blokker for AI-videosammendrag og AI-oversettelse.

**CDN over hele verden (`VideoUtils.getCdnUrl`).** Strøm-URL-er er signerte, og å omskrive verten til en URL får den avvist med 403 — så avspilling omskriver aldri verter. PiliBabel returnerer den georutete URL-en bilibili gir klientens IP, og når kandidatlisten allerede inneholder en utenlandsk edge-node (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`), foretrekkes den. Nedlastinger, der et vertsskifte er trygt, foretrekker i tillegg den globale Akamai-kanten og roterer til neste signerte kandidat når en linje stanser eller avviser en gjenopptakelse. Rå `/v/resource` P2P-lenker faller fortsatt tilbake på det eksisterende reléet for å unngå 404.

**Designavveininger / kjente begrensninger.** Fordi strenger pakkes inn på stedet i stedet for å hentes ut i ressurser, fylles noen få strengparametere utenom `Text` og enkelte riktekstspenn fortsatt inn trinnvis. Strenger som dobbeltfungerer som **logisknøkler** (sammenlignet med `==`, brukt som fanenavn som `简介`, eller enum-etiketter brukt i brytere) pakkes bevisst **ikke** inn generelt, for å unngå å ødelegge oppførselen. Danmakuoversettelse er best mulig innsats på et rullende lerret — under ekstremt tett danmaku kan du kort se originalen før oversettelsen kommer. Oversettelse trenger nettverk; uten det trer rett og slett ikke ikke-kinesiske mål i kraft. Det innebygde endepunktet er en gratis offentlig tjeneste drevet av bilibili — hvis den noen gang blir hastighetsbegrenset eller utilgjengelig, forteller appen deg det, og du kan bytte til din egen API.

## Bygge og verifisere

Appen bygges med et patchet Flutter SDK i tillegg til patchede `material_ui` / `cupertino_ui`-pakker via `lib/scripts/patch.ps1` og `lib/scripts/build.ps1` (akkurat som PiliNara / PiliPlus). GitHub Actions produserer en **feilsøkings-APK** ved hvert push (`.github/workflows/ui-translate-debug.yml`), og **å publisere en tagg `v*` bygger og utgir Android-, Windows- og Linux**-artefakter automatisk (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Plattformer
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

PiliBabel leverer **Android (APK) -, Windows- og Linux**-bygg fra Releases; iOS/Pad er ikke pakket i denne forgreningen ennå.

<br/>

## Nedlasting

Hent et bygg fra **Releases**, eller klon repoet og bygg det lokalt.

### Arch Linux

Takk til [@nlsdt](https://github.com/nlsdt) for pakkingen (PiliNara-oppskriften gjelder også for PiliBabel).

```bash
sudo pacman -S pilinara      # via Arch Linux CN-depotet
paru -S pilinara-bin         # eller via AUR: pilinara-bin (forhåndsbygd) / pilinara (kildekode)
```

<br/>

## Endringslogg: 2.6.x → 3.3.4

- **2.6.x** — lydcache (egne moduler for video og lyd, husker siste valg, innganger på videosiden, lydsiden og i spilleren; originalformatet beholdes; kvalitet kan velges) og nedlasting til enheten (eget menypunkt: først video/lyd, deretter kvalitet; uten valgt mappe åpnes systemets filvelger).

- **3.0.x–3.1.0** — selvhelbredende nettverk i utlandet: tilstand per vert med bytte mellom primær og reserve, DNS-oppslag med cache, forvarming av tilkoblinger, avkjøling etter risikokontroll (412), regionsgjenkjenning med manuelt valg, CDN-hastighetstest delt med API-laget; spillerens fremoverbuffer følger nå bitraten til videosporet.

- **3.2.0–3.3.3** — nettverksgrunnlag i den offisielle appens stil: forespørselsavtrykk (buvid/fp/session_id/env), failover for gRPC-verter, retry-interceptor, grense for samtidige forespørsler per vert, forhåndslasting av første feed ved kaldstart, offisielle feed-hendelsesparametere, rekkefølge for CDN-kandidater med utenlandske reserver; forhåndslasting av andre side, begrenset kø for forhåndslasting av omslag, forhåndslasting av avspillings-URL-er; deretter gjengivelse av dynamics (P3) via gRPC og rettelser: kompileringsfeil i buffertiden på lydsiden og typefeil i forhåndslastingen av kommentarer, som gjorde at hvert nytt forsøk feilet umiddelbart.

- **3.3.4** — dynamikkort for betalte innlegg, mini-apper, emnesamlinger og abonnementer; feilen der hjemskjermens første side mistet alle omslag er rettet; endringer fra PiliNara er hentet inn (statuslinje, gjenoppta nedlasting etter at prosessen lukkes, oppdatering av media-kit, omgå svart video i Wayland, valg av lydkvalitet ved cache); revisjon av AI-oversettelse for all grensesnitttekst lagt til siden 3.0.5; denne loggen.

## Arvet funksjonslogg (fra PiliNara / PiliPlus)

Alt nedenfor er arvet fra PiliNara (og, indirekte, PiliPlus); PiliBabel legger AI-oversettelseslaget på toppen.

**Grensesnitt og plattformtilpasning**
- [x] App omdøpt per plattform slik at flere klienter kan sameksistere (PiliBabel installeres ved siden av PiliNara)
- [x] Fikset Flutter-rendering under mini-vindu i Xiaomi HyperOS ([#161086](https://github.com/flutter/flutter/issues/161086), via [venera#467](https://github.com/venera-app/venera/pull/467)); forutsigende tilbakeanimasjon på Android
- [x] Valgfri rekkefølge/antall «Mine»-kort; forhåndsvisning av historiekort og «se senere»-bolker
- [x] Automatisk sidefeltbytte med konfigurerbar utløserbredde; kopier bilde fra langt trykk / høyreklikk; stor MD3E-stil-oppfriskning

**Skrifttypesystem** — én samlet importpool med deduplisering via innholdshash, danmaku-skrifttyper slått sammen i samme pool, `loadFontFromList` med ttc-støtte, og rene ASCII-hash-familienavn.

**Avspilling, minivindu og kvalitet** — minivindu i appen (dra, endre størrelse, SponsorBlock-hopp, automatisk system-PIP, selvredningslinje i direktesending), avspilling av samtidig lyd, volum i appen opptil 200 %, egendefinert video-CDN-domene og valg av regional node med latensmåling, separate standardkvaliteter for halv/fullskjerm, hastighetslås ved sveip opp, tastaturstyring på nettbrett, SuperChat-tidsstempler i direktesending, hjerteslag i direktesending for fan-intimitet.

**Undertekster, AI og frakoblet** — tospråklige undertekster med uavhengig styling av sekundær undertekst, AI-analyse av undertekster (egendefinert OpenAI-kompatibelt endepunkt, tidsstempelhopp, maler, vedvarende samtaler, myk reserveløsning når undertekster mangler), WEBVTT/SRT-eksport, dobbeltvisning av frakoblet buffer med mappehåndtering og vedvarende metadata, eksport av nedlastinger til den offentlige nedlastingsmappen (Android).

**Danmaku og blokkering** — forbedret skalering av sammenslått danmaku (i [Pakku.js](https://github.com/xmcp/pakku.js)-stil), liste­basert visuell regex-blokkering med import/eksport, SponsorBlock-hopp ved søk inn i et segment, høyenergi-fremdriftslinje med gaussisk kjerne.

**Filtrering av anbefalinger / dynamikk / kommentarer** — nøkkelord i tittel/UP/kanal, varighet, avspillingsantall, likerandel, unntak for fulgte UP, filtrering av uautorisert/kun-betalt innhold, delt hvitliste, kommersiell/uautorisert dynamikk, unntak for UP-egne og festede kommentarer, App+Nett-sammenslått strømmodus.

**Dynamikk, søk og brukerinfo** — egendefinerte notater for UP, notat-erstatter-kallenavn over 13 navneplasser, uavhengig sortering av nestede kommentarer, lokalt nøkkelordssøkfilter, b23.tv-kortlenkehopp, kun-betalt-merke, bryter for å skjule anbefalingsgrunnlag, visning av mynt-XP.

**Forbedringer i direktesending** — panel for å bære fanmedaljer, DLNA-casting som foretrekker HLS, SuperChat-tidsvisning, nederste kontrollinje i minivinduet for selvredning.

**Systemintegrasjon og skrivebord** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), gjenoppbygd håndtering av lydfokus.

<details>
<summary>Fullstendig original funksjons-/sjekkliste (ordrett, fra PiliNara — klikk for å utvide)</summary>

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

PiliBabel er et personlig prosjekt drevet av interesse, gitt ut **kun for læring og testing**; vennligst slett det innen **24 timer** etter nedlasting.

- PiliBabel er en **uoffisiell tredjeparts**klient og er **ikke tilknyttet, ikke godkjent av og ikke sponset av bilibili**.
- Alle API-er er samlet inn fra offisielle offentlige endepunkter; **det tilbys ikke noe knekket, overprivilegert eller betalingsmur-omgående innhold**.
- **AI-oversettelsen kjører på et modellendepunkt hos tredjepart.** Som standard er det bilibilis egen gratis offentlige Index-Translate-tjeneste; hvis du bytter til din egen API, er det endepunktet du konfigurerte. Oversettelseskvalitet og regelefterlevelse er brukerens og den valgte modelltilbyderens ansvar; dette prosjektet er vert for **ingen modell og ingen API-nøkkel**.
- Respekter opphavsrett og bilibilis brukervilkår. Bruk med ansvar.

Med respekt for de opprinnelige og oppstrøms forfatterne for deres innsats for åpen kildekode:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — det direkte overordnede prosjektet til PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — den åpne familien av oversettelsesmodeller som den innebygde motoren kaller på

Hvis noe innhold krenker rettighetene dine, vennligst kontakt oss for fjerning.

<br/>

## Lisens

PiliBabel er lisensiert under **GNU General Public License v3.0 (GPL-3.0)** — samme lisens som PiliNara, PiliPlus og PiliPala. Fordi det er et avledet verk, **må PiliBabel også distribueres under GPL-3.0**: du kan fritt bruke, studere, dele og endre det, forutsatt at du beholder samme lisens, opphavsrettsnotisene og denne lisensteksten. Se [`LICENSE`](./LICENSE).

Tredjepartskomponenter (Flutter-pakker, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio) osv.) forblir under sine egne lisenser.

Den medfølgende skrifttypen **LXGW WenKai** er lisensiert separat under **SIL Open Font License 1.1**; dens lisenstekst følger med i appen som `assets/fonts/LXGWWenKai-OFL.txt`.

<br/>

## Takk til

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — bilibilis åpne familie av oversettelsesmodeller, og det gratis offentlige endepunktet bak den innebygde motoren
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — den åpne kinesiske skrifttypen som er pakket med appen, under SIL Open Font License 1.1
- og mer
- Inspirert av bilibilis offisielle «AI-grensesnittoversettelse».
<br/>

---

> **Documentation language note / 文档语言说明.** This README and its translations are written and maintained with the help of AI translation tooling; the English version is the reference if any wording looks inconsistent. 本仓库的 README 及各语言译文在 AI 翻译工具的协助下撰写与维护；若各语言版本表述不一致，以英文版为准。
