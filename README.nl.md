<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Een Bilibili-client van derden met AI-aangedreven vertaling.</b></p>
    <p>Babel — de taalbarrière afbreken, zodat iedereen van bilibili kan genieten in de eigen taal.</p>
    <p>Voegt de 151 talen van bilibili's officiële inventaris samen met 6 extra talen die die niet dekt - Traditioneel Chinees, Vereenvoudigd en Traditioneel Wu, Hokkien van het vasteland en Taiwan, en Zhuang.</p>
    <p>Vertaling werkt direct na installatie op bilibili's eigen gratis model — geen API-sleutel nodig.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.nan.md">台語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.mn.md">Монгол</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.pt.md">Português</a> · <a href="README.bn.md">বাংলা</a> · <a href="README.th.md">ไทย</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.it.md">Italiano</a> · <a href="README.fa.md">فارسی</a> · <a href="README.fil.md">Filipino</a> · <a href="README.ur.md">اردو</a> · <a href="README.mr.md">मराठी</a> · <a href="README.te.md">తెలుగు</a> · <a href="README.ta.md">தமிழ்</a> · <a href="README.pa.md">ਪੰਜਾਬੀ</a> · <a href="README.gu.md">ગુજરાતી</a> · <a href="README.ha.md">Hausa</a> · <a href="README.sw.md">Kiswahili</a> · <b>Nederlands</b> · <a href="README.my.md">မြန်မာ</a> · <a href="README.pl.md">Polski</a> · <a href="README.is.md">Íslenska</a> · <a href="README.nb.md">Norsk</a> · <a href="README.fi.md">Suomi</a> · <a href="README.sv.md">Svenska</a> · <a href="README.da.md">Dansk</a> · <a href="README.be.md">Беларуская</a> · <a href="README.ug.md">ئۇيغۇرچە</a> · <a href="README.kk.md">Қазақша</a> · <a href="README.bo.md">བོད་ཡིག</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Startpagina" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dynamieken" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Mijn" />
</div>

<br/>

> **Disclaimer.** PiliBabel is een **onofficiële, open-source client van derden**. Het is **niet verbonden met, goedgekeurd door of gesponsord door** bilibili / bilibili Inc. Elke API is verzameld uit de officiële openbare endpoints; **er wordt geen betaalde inhoud ontgrendeld of gekraakt**. Lees a.u.b. de volledige secties [Disclaimer](#disclaimer) en [Licentie](#licentie).

## Wat is PiliBabel?

PiliBabel is een **onafhankelijke fork van derden, gebouwd bovenop [PiliNara](https://github.com/Starfallan/PiliNara)**, en het erft alles over wat PiliNara erft:

```
bilibili (officiële openbare API)
        ▲
   PiliPala / PiliPalaX        — het oorspronkelijke project
        ▲
   PiliPlus                    — actieve fork
        ▲
   PiliNara                    — fork van PiliPlus (persoonlijke aanpassingen)
        ▲
   PiliBabel  ← je bent hier   — fork van PiliNara
```

PiliBabel behoudt **elke functie van PiliNara / PiliPlus** (zie het [log van overgeërfde functies](#log-van-overgeërfde-functies-van-pilinara--piliplus) vlak onderaan) en voegt **twee kopfuncties toe die de upstream-clients niet hebben**:

> **AI-vertaling van interface én inhoud** — de hele app (UI-labels, videotitels, UP-namen, reacties, dynamieken, feed en zelfs live danmaku, de zwevende reacties die over de video heen scrollen) wordt weergegeven in de taal die **jij** kiest.

En sinds 1.0 doet hij dat **zonder enige configuratie**: het vertaalmodel is **ingebouwd**. bilibili heeft zijn eigen vertaalmodelfamilie open-source gemaakt, [Index-Translate](https://github.com/bilibili/Index-Translate), en dient die aan vanaf een gratis openbaar endpoint. PiliBabel wordt geleverd met de aanwijzer daar al op gezet, dus vertaling werkt zodra je de app installeert — geen registratie, geen sleutel, geen rekening. Wil je liever je eigen model gebruiken, dan staat het pad via eigen API er nog steeds, één tik verwijderd.

> **Koptelefoonaudio die echt synchroon blijft** — met Bluetooth- of bedrade koptelefoons blijft het geluid niet langer achter bij het beeld. De officiële app krijgt dit voor elkaar; PiliNara en PiliPlus niet, zo uit de doos. PiliBabel vraagt mpv nu eerst om **AudioTrack**, dat de latency van de audio-uitgang *meet* op dezelfde manier als de officiële client, in plaats van **OpenSL ES**, die die alleen *schat*.

## Belangrijkste functies

- **Koptelefoonaudio in sync.** De speler gebruikt nu standaard mpv's **AudioTrack**-backend (volgorde `audiotrack,aaudio,opensles`) in plaats van **OpenSL ES**. AudioTrack rapporteert een *gemeten* uitgangslatentie — hij leest het aantal afgespeelde frames en de presentatietijdstempel van het apparaat — precies zoals de officiële bilibili-app en Androids eigen `MediaSync` beeld en geluid bij elkaar houden. OpenSL ES *schat* die alleen, waardoor de audioklok bij Bluetooth-koptelefoons driftte en het beeld te vroeg werd getoond. In tests is de vertraging vrijweg weg. Pas de volgorde altijd aan via Instellingen → Video → Audio-uitvoerapparaat.

- **AI-vertaling, overal.** Navigatietabbladen, videokaarten, detailpagina's, reacties, dynamieken en de Mijn / Favorieten / Geschiedenis / Berichten / Zoeken-schermen — één globale sweep dekt **~1.650+ UI-strings**, plus dynamische inhoud (titels, auteursnamen, actietellers).
- **Twee engines, één schakelaar.** *Ingebouwd* (standaard) gebruikt bilibili's officiële gratis **Index-Translate-35B-A3B**-endpoint — niets te configureren. *Eigen API* houdt het vorige gedrag: wijs het naar elk OpenAI-compatibel `/chat/completions`-endpoint met je eigen basis-URL / sleutel / model. De AI-videosamenvatting en de AI-vertaling hebben nog steeds **volledig onafhankelijke** endpoints en instellingen, allebei onder één **"AI-functies"**-pagina.
- **Eén taallijst voor beide engines.** De lijst doeltalen is niet per engine opgesplitst — dezelfde lijst wordt aangeboden welke engine je ook kiest. Ze verenigt de **151 talen** van bilibili's officiële model met **6 extra die dat niet dekt** — Traditioneel Chinees, Vereenvoudigd en Traditioneel Wu, Hokkien van het vasteland en Taiwan, en Zhuang. Regionale en schriftvarianten blijven **aparte vermeldingen** in plaats van samengevoegd — Marokkaans / Egyptisch / Najdi / Levantijns Arabisch zijn elk een eigen keuze, net als Cyrillisch-versus-Latijn Servisch, Oezbeeks en Urdu.
- **Eerlijk over de dekking.** Talen binnen de officiële inventaris worden gedekt door bilibili's model. De handvol erbuiten — Traditioneel Chinees, Vereenvoudigd en Traditioneel Wu, Hokkien van het vasteland en Taiwan en Zhuang — staan gewoon in de lijst, als zodanig gemarkeerd, zodat je in één oogopslag weet dat een beter resultaat mogelijk je eigen model vergt.
- **Eén keer vertalen, dan vast.** Elke bronstring wordt **exact één keer** vertaald; het resultaat wordt lokaal bewaard en **nooit opnieuw vertaald** wanneer je een scherm heropent — hetzelfde principe als de officiële client, voor stabiele, voorspelbare vertalingen.
- **Per reactie een Origineel ⇄ Vertaling-schakelaar** (een klein pictogram, geen Chinees woord). `@vermeldingen / [emoji] / #onderwerpen# / links` blijven als tokens behouden, en **reacties met hyperlinks worden nog steeds vertaald terwijl de link klikbaar blijft**.
- **Danmaku-vertaling (弹幕)** — een onafhankelijke schakelaar in de controlerij rechtsboven in de speler, **standaard uit** en achter een bevestiging waarvan de tekst zelf ook vertaald is. Eenmaal ingeschakeld worden danmaku vóór de afspeelpositie vooraf vertaald in **batches van ~15 seconden** (vooruitspoelen naar het midden wordt correct afgehandeld, niet vanaf het begin), zodat de vertaling meestal klaar is tegen de tijd dat ze komen binnenscrollen.
- **Denkmodus-schakelaar** (`enable_thinking`) voor kwaliteit versus snelheid, plus knoppen **"vertaling testen"** en **cache wissen** in de instellingen.
- **Snel van taal wisselen**: gebatchte verzoeken met beperkte gelijktijdigheid op een persistente cache; het wisselen van taal forceert één keer een herbouw van het huidige scherm, zodat je niet naar onvertaalde tekst blijft staren. AI-vertaling uitzetten zet de hele UI terug naar de originele tekst en stuurt helemaal geen verzoeken.
- **Onboarding bij eerste start.** De eerste keer dat je de app opent, biedt een Engels dialoogvenster aan de vertaling in te schakelen. Accepteren schakelt vertaling in, kiest het ingebouwde model, opent de AI-instellingenpagina en vraagt meteen welke taal je wilt — zodat een nieuwe gebruiker van installatie naar vertaalde app gaat in twee tikken.
- **Afspelen dat wereldwijd werkt.** PiliBabel kiest de overzeese edge (globale **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) die bilibili's geo-gerouteerde `playurl` al aanbiedt, in plaats van je vast te pinnen op een node op het vasteland (Aliyun/Shenzhen) — zodat gebruikers buiten het Chinese vasteland niet meer vastlopen ("audio blijft spelen, video bevriest"). Je kunt nog steeds handmatig een CDN vastzetten in de instellingen.
- **Een "Thema en kleur"-pagina, in Material You-stijl.** Licht / donker / volg-systeem kies je uit **drie live voorbeeldkaarten** — elk rendert een miniatuur van de echte interface in precies de kleuren die die modus zou toepassen (de kaart "volg systeem" is diagonaal gesplitst, licht over donker). Daaronder: **dynamische kleur** (ontleend aan de systeemachtergrond waar het apparaat dat ondersteunt), **hoogcontrast-donker** (echt-zwarte oppervlakken, zachter voor de ogen 's nachts) en **altijd-donker-speler**. Het kleurgedeelte behoudt het volledige FlexScheme-palet — **19 zaadkleuren** plus een aparte **"paletstijl"** die bepaalt hoe elke containerkleur uit het zaad wordt afgeleid, onafhankelijk van welk zaad je kiest.
- **LXGW WenKai wordt meegeleverd.** Het lettertype **LXGW WenKai (霞鹜文楷)** is **ingebouwd en standaard ingesteld** — een warm, zeer leesbaar Chinees lettertype dat je hebt zodra je installeert, in plaats van er in een kiezer naar te zoeken. Het geldt voor de hele interface *en* voor danmaku. Je kunt nog steeds terug naar het systeemlettertype, elk geïnstalleerd systeemlettertype kiezen of je eigen `.ttf` / `.otf` / `.ttc` importeren; een lettertype dat je eerder expliciet had gekozen blijft behouden bij de upgrade. Gewicht en grootte blijven zoals voorheen aanpasbaar.

## Offline audiocache en downloaden naar lokale map (uniek voor PiliBabel)

Twee mogelijkheden die PiliNara / PiliPlus stroomopwaarts niet hebben — beide gericht op je media echt offline bezitten.

### Audio cachen (offline cache, alleen audio)

- **Het nummer, niet de video.** Een vermelding *Audio cachen* staat vlak onder *Video cachen* in het menu van de videopagina, plus een eigen knop voor audiocache in de bovenbalk van de video-luisterpagina.
- **Kies de kwaliteitsklasse.** Hi-Res verliesvrij, Dolby Atmos, 192K, 132K of 64K — dezelfde voorinstellijst als de videokwaliteitskiezer gebruikt.
- **Originele container, geen transcodering.** Het bestand wordt precies zoals de CDN het levert weggeschreven: `m4a`, `mp3`, `flac`, `wav`, `aac` of `ogg`.
- **Eigen module.** De cachepagina is gesplitst in *Gecachete video's* / *Gecachete audio* en onthoudt in welke module je de vorige keer was.
- Op een gecachet audio-item tikken opent meteen de audiospeler; items verwijder je één voor één of in bulk.

### Downloaden naar lokale map

- **Eigen menuvermelding.** *Downloaden naar lokale map* is een afzonderlijke vermelding in het menu van de videopagina, vlak onder *Audio cachen* — cachen binnen de app en naar een map opslaan zijn twee verschillende handelingen.
- **Video of audio downloaden.** De vermelding vraagt eerst welke van de twee, daarna naar de kwaliteitsklasse (video-/audiokwaliteitskiezer).
- **Jouw map, jouw regels.** Kies een willekeurige map via de bestandsbeheerder van het systeem (Instellingen → *Downloaden naar lokale map*) en wijzig of wis die wanneer je maar wilt. Heb je nog geen gekozen, dan opent de mapkiezer ter plekke.
- **Direct afspeelbare bestanden.** De video wordt als één gemuxte stream opgehaald (`fnval=1`), zodat wat op de schijf belandt een gewone MP4 is die je aan elke speler kunt geven — geen losse streams om aan elkaar te naaien.
- **Audio behoudt zijn originele formaat** — geen transcodering, exact zoals de cache in de app.
- Bestanden worden naar de videotitel vernoemd en overschrijven nooit een bestaande download.

## De twee vertaalengines

| | Ingebouwd (standaard) | Eigen API |
|---|---|---|
| Model | bilibili **Index-Translate-35B-A3B** | alles wat OpenAI-compatibel is |
| Endpoint | `index-translate.bilibili.com/v1` | je basis-URL |
| API-sleutel | **niet nodig** | die van jou |
| Kosten | gratis | wat je provider rekent |
| Verzoeken | één string per verzoek | gebatcht (≤ 16 per verzoek) |
| Extra talen | — | elke taal die je model kent |

**Waarom per verzoek voor de ingebouwde engine.** Index-Translate is een vertaal*specialist*, en de aanroepconventie die de auteurs documenteren is een item-per-item-sjabloon ("vertaal de volgende tekst naar X, geef alleen de vertaling uit"). PiliBabel stuurt daarom op deze engine één string per verzoek in plaats van de numerieke-lijst/JSON-array-batchprompt die het voor eigen-API-instellingen gebruikt. Het endpoint is gratis, dus er valt niets te winnen met gokken op batch-uitvoer — dit is een bewuste inruil van wat meer verzoeken tegen veel minder manieren om te falen.

**Upgraden vanaf 0.3.x.** Je eigen API-instellingen — basis-URL, sleutel en model — worden **precies gelaten zoals je ze hebt geconfigureerd**. De enginekeuze valt gewoon terug op het ingebouwde model, dus bij de eerste start na de upgrade zit je op bilibili's gratis model; open *Instellingen → AI → AI-functies → vertaalengine* en schakel terug naar *Eigen API* om direct terug te keren naar je vorige setup.

## Hoe de AI-interfacevertaling werkt (technisch)

De repository heeft **geen i18n-/ARB-resourcelaag** — UI-strings zijn hardgecodeerd Chinees. In plaats van elke widget te herschrijven, legt PiliBabel er een dunne vertaallaag bovenop:

1. **Een globale opzoek-wrapper.** `lib/services/ui_translate/` onthult een `uiTx(String src)` op topniveau. Widgettekst die vroeger `Text('中文')` was, wordt `Text(uiTx('中文'))`. Een gescripte **codemod** paste dit toe in het hele project (`tool/ui_translate_*.py`) — zo'n **223 bestanden / ~1.650+ strings** — waarbij automatisch het nu ongeldige sleutelwoord `const` werd weggehaald waar nodig (inclusief generics zoals `const X<T>(...)` en puntnamen zoals `const Positioned.fill(...)`, en `static const`-lijst/map-declaraties werden omgezet naar `static final`).
2. **Een `GetxService`-kern** (`ui_translate_service.dart`):
   - een persistente **bron → vertaling**-cache (op GetStorage), zodat elke string één keer wordt vertaald en voor altijd hergebruikt;
   - `tx()` leest eerst een `RxInt revision` en beslist dan: indien uitgeschakeld → geef het origineel terug; als het doel **Vereenvoudigd Chinees (`zh-CN`)** is, geef het origineel terug zonder API-verzoek (bilibili's broninhoud is overweldigend Vereenvoudigd Chinees). Elke andere doeltaal — inclusief Traditioneel Chinees, Kantonees, Wu/Shanghainees en Hokkien/Min Nan — gaat door de geconfigureerde engine; alleen tot de Chinese familie behoren slaat de vertaling niet over. Daarna serveren uit de cache of **in de wachtrij zetten**;
   - de strings in de wachtrij worden gespoeld door een **workerpool** met **incrementele toepassing per chunk** (elke teruggekeerde chunk verhoogt `revision`, zodat de tekst geleidelijk bijwerkt), en resultaten worden **bewaard** (met throttling). Batchgrootte en gelijktijdigheid volgen de engine: **1 per verzoek** op het ingebouwde model, **≤ 16 met ≤ 10 in de lucht** op je eigen API.
3. **Engine-resolutie.** `TranslateProvider` (`builtin` / `custom`) bepaalt welke URL, sleutel en model het transport gebruikt; verder delen beide engines één codepad en één taallijst, zodat engine wisselen één instelling is en nooit een andere functieset.
4. **Het transport** hergebruikt hetzelfde geverifieerde **streaming**-kanaal als de AI-videosamenvatting — `AiChatService.streamChat` → `{base}/chat/completions` met `stream: true` (compatibel met gateways die alleen streaming ondersteunen) — uitgebreid zodat vertaling zijn **eigen** `apiUrl` / `apiKey` / `model` en een `enable_thinking`-flag kan gebruiken. De wijziging is **achterwaarts compatibel**, dus videosamenvatting blijft ongewijzigd werken.
5. **Geïnterpoleerde zinnen** gebruiken `uiTxP(template, args)`: een hele zin met `{0}`/`{1}`-plaatshouders wordt als één stabiele sleutel vertaald (de prompt vraagt het model de plaatshouders te behouden), daarna worden de waarden teruggeplaatst — zodat strings in de trant van `"共 {0} 条"` vertaald worden zonder de dynamische delen te verminken.
6. **Talentabel** (`app_language.dart`): elke `AppLanguage` draagt een weergave-autoniem, een `toModel`-promptstring die schrift-/regioconventies codeert, en een vlag of bilibili's officiële inventaris die taal dekt. Schrifregels (Vereenvoudigd versus Traditioneel, en de dialectconsistentie-instructies) bereiken het model alleen via de prompt, en een deterministische normalisatiepass op de client herstelt daarna verdwaalde glyphs.
7. **Reacties** gaan door `uiTxComment(text, id)`, waarbij `@ / [emoji] / #onderwerp# / link` als intacte tokens blijven; rich-text-spans met links worden vertaald terwijl de linkherkenner behouden blijft, en een per-reactie id-set stuurt de Origineel ⇄ Vertaling-schakelaar aan.
8. **Danmaku** (`danmaku/view.dart`): als de schakelaar aan staat, loopt een positieluisteraar `[playhead, playhead + 15s]` telkens één seconde af en warmt `uiTx()` voor op de inhoud van elke danmaku, zodat items vooraf vertaald zijn voordat ze het scherm bereiken; aanzetten wist en herschildert het canvas.
9. **Opslagsleutels**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Instellingen-UI**: één pagina op het eerste niveau "AI-functies" (`lib/pages/setting/ui_translate/`) met onafhankelijke blokken voor AI-videosamenvatting en AI-vertaling.

**Wereldwijde CDN (`VideoUtils.getCdnUrl`).** Stream-URL's zijn ondertekend, en de host van een URL herschrijven wordt met 403 afgewezen — dus playback herschrijft nooit hosts. PiliBabel geeft de geo-gerouteerde URL terug die bilibili aan het IP van de client geeft, en wanneer de kandidatenlijst al een overzeese edge bevat (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`) wordt die verkozen. Downloads, waar een host-swap veilig is, verkiezen bovendien de globale Akamai-edge en roteren naar de volgende ondertekende kandidaat wanneer een lijn blijft hangen of een hervatting weigert. Kale `/v/resource` P2P-links vallen nog steeds terug op de bestaande relay om 404's te vermijden.

**Ontwerpafwegingen / bekende beperkingen.** Omdat strings op hun plek worden gewrapped in plaats van naar resources te worden geëxtraheerd, worden sommige niet-`Text`-stringparameters en sommige rich-text-spans nog stapsgewijs ingevuld. Strings die dubbel dienen als **logicasleutels** (vergeleken met `==`, gebruikt als tabbladnamen zoals `简介`, of enum-labels gebruikt in switches) worden bewust **niet** allesomvattend gewrapped, om het gedrag niet te breken. Danmaku-vertaling is best-effort op een scrollend canvas — bij extreem dichte danmaku zie je kort het origineel voordat de vertaling er is. Vertaling heeft netwerk nodig; zonder dat treden niet-Chinese doelen gewoon niet in werking. Het ingebouwde endpoint is een gratis openbare dienst van bilibili — als die ooit wordt beperkt of onbereikbaar is, zegt de app dat en kun je op je eigen API overschakelen.

## Bouwen en verifiëren

De app wordt gebouwd met een gepatchte Flutter-SDK plus gepatchte `material_ui`- / `cupertino_ui`-pakketten via `lib/scripts/patch.ps1` en `lib/scripts/build.ps1` (exact zoals PiliNara / PiliPlus). GitHub Actions produceert bij elke push een **debug-APK** (`.github/workflows/ui-translate-debug.yml`), en **een tag `v*` publiceren bouwt en releaset automatisch Android-, Windows- en Linux-artefacten** (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Platformen
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

PiliBabel levert **Android (APK)-, Windows- en Linux**-builds via Releases; iOS/Pad wordt in deze fork nog niet verpakt.

<br/>

## Downloaden

Pak een build uit **Releases**, of kloon de repo en bouw lokaal.

### Arch Linux

Dank aan [@nlsdt](https://github.com/nlsdt) voor het pakket (het PiliNara-recept is ook op PiliBabel van toepassing).

```bash
sudo pacman -S pilinara      # via de Arch Linux CN-repository
paru -S pilinara-bin         # of via AUR: pilinara-bin (voorgebouwd) / pilinara (bron)
```

<br/>

## Wijzigingslog: 2.6.x → 3.3.4

- **2.6.x** — audiocache (aparte modules voor video en audio, onthoudt de laatste keuze, ingangen op de videopagina, de alleen-audio-pagina en in de audiospeler; oorspronkelijk formaat blijft behouden; kwaliteit kiesbaar) en downloaden naar het apparaat (eigen menu-item: eerst video/audio, dan kwaliteit; zonder ingestelde map opent de systeem-bestandskiezer).

- **3.0.x–3.1.0** — zelfherstellend netwerk in het buitenland: gezondheid per host met omschakeling tussen primair en reserve, DNS-resolutie met cache, voorverwarmen van verbindingen, afkoeling na risicocontrole (412), regiodetectie met handmatige keuze, CDN-snelheidstest gedeeld met de API-laag; de voorwaartse buffer van de speler volgt nu de bitrate van de videospoor.

- **3.2.0–3.3.3** — netwerkbasis in de stijl van de officiële app: vingerafdruk van verzoeken (buvid/fp/session_id/env), failover van gRPC-hosts, retry-interceptor, limiet op gelijktijdige verzoeken per host, voorladen van de eerste feed bij een koude start, officiële feed-gebeurtenisparameters, volgorde van CDN-kandidaten met buitenlandse reserves; voorladen van de tweede pagina, begrensde wachtrij voor het voorladen van omslagen, voorladen van afspeel-URL's; daarna weergave van dynamics (P3) via gRPC en correcties: compileerfout in de buffertijd op de audiopagina en typefout bij het voorladen van reacties waardoor elke nieuwe poging direct mislukte.

- **3.3.4** — dynamics-kaarten voor betaalde berichten, mini-apps, themaverzamelingen en abonnementen; het probleem waarbij het eerste scherm van de startpagina helemaal geen omslagen toonde is opgelost; wijzigingen van PiliNara overgenomen (statusbalk, download hervatten na het sluiten van het proces, update van media-kit, zwarte video in Wayland omzeild, keuze van audiokwaliteit bij cachen); controle van AI-vertaling voor alle interfacetekst die sinds 3.0.5 is toegevoegd; deze log.

## Log van overgeërfde functies (van PiliNara / PiliPlus)

Alles hieronder komt over van PiliNara (en, overgedragen, PiliPlus); PiliBabel voegt er de AI-vertaallaag bovenop toe.

**UI- en platformaanpassing**
- [x] App per platform hernoemd zodat meerdere clients naast elkaar kunnen bestaan (PiliBabel installeert naast PiliNara)
- [x] Flutter-rendering onder het Xiaomi HyperOS-mini-venster gefixt ([#161086](https://github.com/flutter/flutter/issues/161086), via [venera#467](https://github.com/venera-app/venera/pull/467)); predictieve terug-animatie op Android
- [x] Aanpasbare volgorde/aantal van "Mijn"-kaarten; voorbeeld op geschiedenis-kaarten en secties "later bekijken"
- [x] Automatische sidebar-omschakeling met configureerbare triggerbreedte; afbeelding kopiëren via lang drukken / rechtermuisklik; grote MD3E-stijlvernieuwing

**Lettertypesysteem** — één verenigde importpool met deduplicatie op inhouds-hash, danmaku-lettertypes samengevoegd in dezelfde pool, `loadFontFromList` met ttc-ondersteuning en familienamen als puur-ASCII-hash.

**Afspelen, mini-venster en kwaliteit** — mini-venster in de app (slepen, vergroten/verkleinen, SponsorBlock-skips, automatische systeem-PIP, zelfreddingsbalk bij lives), audio naast elkaar afspelen, in-app-volume tot 200%, eigen video-CDN-domein en regionale nodekeuze met latentietest, aparte standaardkwaliteit voor half/volscherm, snelheidsvergrendeling bij omhoogswiepen, besturing via toetsenbord op tablets, SuperChat-tijdstempels bij lives, live-heartbeat voor fan-intimiteit.

**Ondertitels, AI en offline** — tweetalige ondertitels met onafhankelijke stijl van de secundaire ondertitel, AI-ondertitelanalyse (eigen OpenAI-compatibel endpoint, tijdstempelsprong, sjablonen, bewaarde gesprekken, zachte fallback zonder ondertitels), WEBVTT/SRT-export, dubbele weergave van de offline cache met mapbeheer en metadata-persistentie, downloads exporteren naar de openbare Download-map (Android).

**Danmaku en blokkering** — verbeterde schaalwijziging van samengevoegde danmaku ([Pakku.js](https://github.com/xmcp/pakku.js)-achtig), lijstgebaseerde visuele regex-blokkering met import/export, SponsorBlock-skip bij seek-in-segment, gaussische hoogenergie-voortgangsbalk.

**Filteren van aanbevelingen / dynamieken / reacties** — trefwoorden voor titel/UP/kanaal, duur, afspeelantal, like-ratio, vrijstelling voor gevolgde UP's, filteren van niet-geautoriseerd/allen-betalend, gedeelde whitelist, commerciële/niet-geautoriseerde dynamieken, vrijstellingen voor UP-eigen reactie en vastgepinde reactie, App+Web-samengevoegde feedmodus.

**Dynamieken, zoeken en gebruikersinfo** — eigen notities voor UP's, notitie-vervangt-bijnaam over 13 naamslots, onafhankelijke sortering van geneste reacties, lokaal trefwoordfilter bij zoeken, sprong via b23.tv-kortlink, badge alleen-betalend, schakelaar voor het verbergen van de aanbevelingsreden, weergave van munten-XP.

**Live-verbeteringen** — paneel voor het dragen van fanmedailles, DLNA-cast met voorkeur voor HLS, SuperChat-tijdweergave, onderste controlerij van het mini-venster voor zelfredding.

**Systeemintegratie en desktop** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), herbouwde audio-focus-afhandeling.

<details>
<summary>Volledige originele functie-/checklist (letterlijk, van PiliNara — klik om uit te klappen)</summary>

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

## Disclaimer

PiliBabel is een persoonlijk, interessegedreven project, uitsluitend **voor leren en testen** bedoeld; verwijder het binnen **24 uur** na download.

- PiliBabel is een **onofficiële client van derden** en is **niet verbonden met, goedgekeurd door of gesponsord door bilibili**.
- Alle API's zijn verzameld uit officiële openbare endpoints; **geen gekraakte, overgeprivilegieerde of betaalmuur-omzeilende inhoud** wordt geleverd.
- **AI-vertaling draait op een model-endpoint van derden.** Standaard is dat bilibili's eigen gratis openbare Index-Translate-dienst; als je overschakelt naar je eigen API, is het de endpoint die jij hebt geconfigureerd. Vertaalkwaliteit en naleving zijn de verantwoordelijkheid van de gebruiker en de gekozen modelprovider; dit project herbergt **geen model en geen API-sleutel**.
- Respecteer auteursrecht en bilibili's gebruiksvoorwaarden. Gebruik verantwoord.

Met respect voor de oorspronkelijke en stroomopwaartse auteurs voor hun open-source-toewijding:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — het directe ouderproject van PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — de open-source vertaalmodelfamilie die de ingebouwde engine aanroept

Als inhoud jouw rechten schendt, neem dan contact met ons op voor verwijdering.

<br/>

## Licentie

PiliBabel valt onder de **GNU General Public License v3.0 (GPL-3.0)** — dezelfde licentie als PiliNara, PiliPlus en PiliPala. Omdat het een afgeleid werk is, **moet PiliBabel eveneens onder GPL-3.0 worden verspreid**: je mag het vrij gebruiken, bestuderen, delen en aanpassen, mits je dezelfde licentie, de copyrightvermeldingen en deze licentietekst behoudt. Zie [`LICENSE`](./LICENSE).

Componenten van derden (Flutter-pakketten, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), enz.) blijven onder hun eigen licenties.

Het meegeleverde lettertype **LXGW WenKai** is apart gelicentieerd onder de **SIL Open Font License 1.1**; de licentietekst zit in de app als `assets/fonts/LXGWWenKai-OFL.txt`.

<br/>

## Met dank aan

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — bilibili's open-source vertaalmodelfamilie, en het gratis openbare endpoint achter de ingebouwde engine
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — het open-source Chinese lettertype dat met de app wordt meegeleverd, onder de SIL Open Font License 1.1
- en meer
- Geïnspireerd door bilibili's officiële "AI-interfacevertaling".
<br/>

---

> **Documentation language note / 文档语言说明.** This README and its translations are written and maintained with the help of AI translation tooling; the English version is the reference if any wording looks inconsistent. 本仓库的 README 及各语言译文在 AI 翻译工具的协助下撰写与维护；若各语言版本表述不一致，以英文版为准。
