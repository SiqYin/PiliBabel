<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>En tredjepartsklient för bilibili med AI-driven översättning.</b></p>
    <p>Babel — river ner språkbarriären, så att alla kan njuta av bilibili på sitt eget språk.</p>
    <p>Förenar bilibilis officiella lista på 151 språk med 6 till som den inte täcker - traditionell kinesiska, förenklad och traditionell wu, hokkien från fastlandet och Taiwan, samt zhuang.</p>
    <p>Översättningen fungerar direkt ur lådan på bilibilis egen gratis modell — ingen API-nyckel krävs.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.nan.md">台語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.mn.md">Монгол</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.pt.md">Português</a> · <a href="README.bn.md">বাংলা</a> · <a href="README.th.md">ไทย</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.it.md">Italiano</a> · <a href="README.fa.md">فارسی</a> · <a href="README.fil.md">Filipino</a> · <a href="README.ur.md">اردو</a> · <a href="README.mr.md">मराठी</a> · <a href="README.te.md">తెలుగు</a> · <a href="README.ta.md">தமிழ்</a> · <a href="README.pa.md">ਪੰਜਾਬੀ</a> · <a href="README.gu.md">ગુજરાતી</a> · <a href="README.ha.md">Hausa</a> · <a href="README.sw.md">Kiswahili</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.my.md">မြန်မာ</a> · <a href="README.pl.md">Polski</a> · <a href="README.is.md">Íslenska</a> · <a href="README.nb.md">Norsk</a> · <a href="README.fi.md">Suomi</a> · <b>Svenska</b> · <a href="README.da.md">Dansk</a> · <a href="README.be.md">Беларуская</a> · <a href="README.ug.md">ئۇيغۇرچە</a> · <a href="README.kk.md">Қазақша</a> · <a href="README.bo.md">བོད་ཡིག</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Hem" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dynamik" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Jag" />
</div>

<br/>

> **Ansvarsfriskrivning.** PiliBabel är en **oinofficiell, öppen källkods-, tredjeparts**klient. Den är **inte knuten till, inte godkänd av och inte sponsrad av** bilibili / bilibili Inc. Varje API är insamlat från de officiella publika ändpunkterna; **inget betalt innehåll låses upp eller knäcks**. Läs gärna de fullständiga avsnitten [Ansvarsfriskrivning](#ansvarsfriskrivning) och [Licens](#licens).

## Vad är PiliBabel?

PiliBabel är en **självständig tredjeparts-fork byggd ovanpå [PiliNara](https://github.com/Starfallan/PiliNara)**, och den ärver allt som PiliNara ärver:

```
bilibili (officiellt publikt API)
        ▲
   PiliPala / PiliPalaX        — originalprojektet
        ▲
   PiliPlus                    — aktiv fork
        ▲
   PiliNara                    — fork av PiliPlus (personliga justeringar)
        ▲
   PiliBabel  ← du är här   — fork av PiliNara
```

PiliBabel behåller **varje funktion från PiliNara / PiliPlus** (se [ärvd funktionslogg](#ärvd-funktionslogg-från-pilinara--piliplus) längre ner) och lägger till **två huvudfunktioner som uppströmsklienterna inte har**:

> **AI-översättning av gränssnitt och innehåll** — hela appen (gränssnittsetiketter, videotitlar, UP-namn, kommentarer, dynamik, flöde och till och med danmaku (rullande skärmkommentarer) i live) renderas på det språk **du** väljer.

Och sedan 1.0 gör den det **direkt ur lådan**: översättningsmodellen är **inbyggd**. bilibili har släppt öppen källkod för sin egen familj av översättningsmodeller, [Index-Translate](https://github.com/bilibili/Index-Translate), och serverar den från en gratis publik ändpunkt. PiliBabel levererar pekad mot den, så översättningen fungerar i samma stund du installerar appen — ingen registrering, ingen nyckel, ingen räkning. Om du hellre vill använda din egen modell finns egen-API-vägen fortfarande kvar, ett tryck bort.

> **Ljud i hörlurar som faktiskt håller sig synkroniserat** — med Bluetooth- eller trådbundna hörlurar släpar inte ljudet efter bilden längre. Den officiella appen får det här rätt; PiliNara och PiliPlus gör det inte, direkt ur lådan. PiliBabel ber nu mpv om **AudioTrack** först, vilket *mäter* ljudutgångsfördröjningen på samma sätt som den officiella klienten, i stället för **OpenSL ES**, som bara *uppskattar* den.

## Nyckelfunktioner

- **Synkroniserat ljud i hörlurar.** Spelaren använder nu mpvs **AudioTrack**-backend som standard (ordning `audiotrack,aaudio,opensles`) i stället för **OpenSL ES**. AudioTrack rapporterar en *mätt* utgångsfördröjning — den läser antalet uppspelade bildrutor och enhetens presentationstidsstämpel — vilket är exakt hur den officiella bilibili-appen och Androids egen `MediaSync` håller bild och ljud ihop. OpenSL ES *uppskattar* den bara, så på Bluetooth-hörlurar drev ljudklockan och bilden visades för tidigt. I testning är fördröjningen i princip borta. Ändra ordningen när som helst i Inställningar → Video → Ljudutgångsenhet.

- **AI-översättning, överallt.** Navigeringsflikar, videokort, detaljsidor, kommentarer, dynamik samt vyerna Min / Favoriter / Historik / Meddelanden / Sök — en genomgripande svepning täcker **~1 650+ gränssnittssträngar**, plus dynamiskt innehåll (titlar, författarnamn, åtgärdsantal).
- **Två motorer, en brytare.** *Inbyggd* (standard) använder bilibilis officiella gratis **Index-Translate-35B-A3B**-ändpunkt — inget att konfigurera. *Egen API* behåller det tidigare beteendet: peka den mot vilken OpenAI-kompatibel `/chat/completions`-ändpunkt som helst med din egen bas-URL / nyckel / modell. AI-videosammanfattningen och AI-översättningen har fortfarande **helt oberoende** ändpunkter och inställningar, båda samlade på en **”AI-funktioner”**-sida.
- **En språklista, båda motorerna.** Målspråkslistan delas inte upp per motor — samma lista erbjuds oavsett vilken motor du väljer. Den förenar de **151 språken** i bilibilis officiella modell med **6 till som den inte täcker** — traditionell kinesiska, förenklad och traditionell wu, fastlands- och taiwanesisk hokkien samt zhuang. Regionala och skriftvarianter behålls som **separata poster** i stället för att slås ihop — marockansk / egyptisk / najdi / levantinsk arabiska är var och ett ett eget val, och samma gäller kyrillisk-mot-latinsk serbiska, uzbekiska och urdu.
- **Ärlig om täckning.** Språk inom den officiella listan täcks av bilibilis modell. De få utanför — traditionell kinesiska, förenklad och traditionell wu, fastlands- och taiwanesisk hokkien samt zhuang — visas ändå i listan, markerade som sådana, så att du med en enda blick ser att ett bättre resultat kan kräva din egen modell.
- **Översätt en gång, sedan är det fast.** Varje källsträng översätts **exakt en gång**; resultatet sparas lokalt och **översätts aldrig igen** när du öppnar en skärm igen — samma princip som den officiella klienten, för stabila, förutsägbara översättningar.
- **Växling Original ⇄ Översättning per kommentar** (en liten ikon, inte ett kinesiskt ord). `@omnämningar / [emoji] / #ämnen# / länkar` bevaras som token, och **kommentarer med hyperlänkar översätts fortfarande medan länken förblir klickbar**.
- **Översättning av danmaku (弹幕)** — en egen brytare i spelarens övre högra kontrolrad, **av som standard** och skyddad bakom en bekräftelse vars egen text är översatt. När den är aktiverad föröversätts danmaku framför uppspelningshuvudet i **~15-sekunders omgångar** (att hoppa till mitten hanteras korrekt, inte från början), så översättningen är oftast klar när den rullar in på skärmen.
- **Brytare för tänkläge** (`enable_thinking`) för kvalitet mot hastighet, plus knappar för **”testöversättning”** och **rensning av cachen** i inställningarna.
- **Snabbt språkbyte**: gruppvisa förfrågningar med begränsad samtidighet mot ett beständigt cacheminne; att byta språk tvingar fram en ombyggnad av den aktuella skärmen en gång, så att du inte sitter och stirrar på oöversatt text. Att stänga av AI-översättningen återställer hela gränssnittet till originaltexten och skickar inga förfrågningar alls.
- **Introduktion vid första start.** Första gången du öppnar appen erbjuder en engelsk dialog att slå på översättning. Att acceptera aktiverar översättningen, väljer den inbyggda modellen, öppnar AI-inställningssidan och frågar omedelbart vilket språk du vill ha — så en ny användare går från installation till översatt app med två tryck.
- **Uppspelning som fungerar i hela världen.** PiliBabel väljer utlandskanten (globala **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) som bilibilis georutade `playurl` redan erbjuder, i stället för att låsa dig vid en fastlandsnod (Aliyun/Shenzhen) — så användare utanför fastlandet Kina fastnar inte längre (”ljudet fortsätter spela, videon fryser”). Du kan fortfarande låsa en CDN manuellt i inställningarna.
- **En sida för ”Tema och färg” i Material You-stil.** Ljust / mörkt / följ systemet väljs från **tre levande förhandsvisningskort** — vart och ett renderar en miniatyr av det riktiga gränssnittet i exakt de färger som läget skulle tillämpa (kortet ”följ systemet” är delat diagonalt, ljust över mörkt). Under dem: **dynamisk färg** (hämtad från systemets bakgrundsbild där enheten stöder det), **mörkt med hög kontrast** (äkta svarta ytor, skonsammare för ögonen på natten) och **alltid mörk spelare**. Färgdelen behåller hela FlexScheme-paletten — **19 fröfärger** plus en egen **”palettstil”** som avgör hur varje behållarfärg härleds från fröfärgen, oberoende av vilken fröfärg du väljer.
- **LXGW WenKai följer med appen.** Typsnittet **LXGW WenKai (霞鹜文楷)** är **medskickat och satt som standard** — ett varmt, mycket läsbart kinesiskt typsnitt du har i samma stund du installerar, i stället för att leta efter ett i en väljare. Det gäller hela gränssnittet *och* danmaku. Du kan fortfarande byta tillbaka till systemtypsnittet, välja vilket installerat systemtypsnitt som helst eller importera ditt eget `.ttf` / `.otf` / `.ttc`; ett typsnitt du tidigare uttryckligen valt behålls genom uppgraderingen. Tjocklek och storlek är fortfarande justerbara som tidigare.

## Offline-cachelagring av ljud och hämtning till lokal mapp (unikt för PiliBabel)

Två förmågor som uppströms PiliNara / PiliPlus inte har — båda riktade mot att faktiskt äga dina media offline.

### Cachelagra ljud (offlinecache endast för ljud)

- **Spåret, inte videon.** Ett val *Cachelagra ljud* ligger direkt under *Cachelagra video* i videonsidans meny, plus en dedikerad knapp för ljudcache i det övre fältet på lyssningssidan.
- **Välj kvalitetsnivå.** Hi-Res förlustfritt, Dolby Atmos, 192K, 132K eller 64K — samma förinställda lista som videokvalitetsväljaren använder.
- **Originalbehållare, ingen omkodning.** Filen skrivs exakt som CDN:n serverar den: `m4a`, `mp3`, `flac`, `wav`, `aac` eller `ogg`.
- **Egen modul.** Cachesidan är uppdelad i *Cachelagrade videor* / *Cachelagrat ljud* och minns vilken modul du var på senast.
- Att trycka på ett cachelagrat ljudobjekt öppnar ljudspelaren direkt; objekt kan tas bort ett i taget eller i bulk.

### Hämta till lokal mapp

- **Egen menypost.** *Hämta till lokal mapp* är en separat post i videonsidans meny, precis under *Cachelagra ljud* — cachelagring i appen och sparande till en mapp är två olika åtgärder.
- **Hämta video eller hämta ljud.** Posten frågar först vilken av dem, sedan efter kvalitetsnivån (väljare för videokvalitet / ljudkvalitet).
- **Din mapp, dina regler.** Välj vilken mapp som helst via systemets filhanterare (Inställningar → *Hämta till lokal mapp*), och ändra eller rensa den när du vill. Om du inte har valt någon än öppnas mappväljaren på fläcken.
- **Direkt spelbara filer.** Video hämtas som en enda muxad ström (`fnval=1`), så det som hamnar på disken är en vanlig MP4 som du kan ge till valfri spelare — inga sidovisningar att sy ihop.
- **Ljud behåller sitt originalformat** — ingen omkodning, precis som cachen i appen.
- Filer namnges efter videotiteln och skriver aldrig över en befintlig hämtning.

## De två översättningsmotorerna

| | Inbyggd (standard) | Egen API |
|---|---|---|
| Modell | **Index-Translate-35B-A3B** från bilibili | vad som helst som är OpenAI-kompatibelt |
| Ändpunkt | `index-translate.bilibili.com/v1` | din bas-URL |
| API-nyckel | **behövs inte** | din |
| Kostnad | gratis | vad din leverantör tar betalt |
| Förfrågningar | en sträng per förfrågan | gruppvis (≤ 16 per förfrågan) |
| Extra språk | — | alla språk din modell kan |

**Varför en förfrågan i taget för den inbyggda motorn.** Index-Translate är en *specialist* på översättning, och anropskonventionen dess upphovsmän dokumenterar är en mall för ett enda objekt (”översätt följande text till X, mata bara ut översättningen”). PiliBabel skickar därför en sträng per förfrågan på den här motorn i stället för numrerad-lista/JSON-array-prompten den använder för egen-API-uppsättningar. Ändpunkten är gratis, så det finns inget att vinna på att chansa på grupputmatning — det är en medveten avvägning av några fler förfrågningar mot betydligt färre sätt att misslyckas.

**Uppgradering från 0.3.x.** Dina egna API-inställningar — bas-URL, nyckel och modell — **lämnas exakt som du konfigurerade dem**. Motorvalet får helt enkelt standardinställningen inbyggd modell, så vid första start efter uppgraderingen kör du på bilibilis gratis modell; öppna *Inställningar → AI → AI-funktioner → översättningsmotor* och växla tillbaka till *Egen API* för att omedelbart återgå till din tidigare uppsättning.

## Hur AI-gränssnittsöversättningen fungerar (tekniskt)

Förrådet har **inget i18n / ARB-resurslager** — gränssnittssträngar är hårdkodad kinesiska. I stället för att skriva om varje widget lägger PiliBabel ett tunt översättningslager ovanpå:

1. **Ett globalt uppslagsomslag.** `lib/services/ui_translate/` exponerar en `uiTx(String src)` på toppnivå. Widgettext som brukade vara `Text('中文')` blir `Text(uiTx('中文'))`. En skriptad **codemod** tillämpade detta över hela projektet (`tool/ui_translate_*.py`) — cirka **223 filer / ~1 650+ strängar** — och tog automatiskt bort det nu ogiltiga nyckelordet `const` där det krävdes (inklusive generiska typer som `const X<T>(...)` och punktuppbyggda namn som `const Positioned.fill(...)`, samt konverterade `static const`-list-/kartdeklarationer till `static final`).
2. **En `GetxService`-kärna** (`ui_translate_service.dart`):
   - ett beständigt **källa → översättning**-cacheminne (med GetStorage i botten), så att varje sträng översätts en gång och återanvänds för alltid;
   - `tx()` läser först en `RxInt revision` och beslutar sedan: om avstängd → returnera originalet; om målet är **förenklad kinesiska (`zh-CN`)**, returnera originalet utan API-förfrågan (Bilibilis källinnehåll är till övervägande del förenklad kinesiska). Varje annat mål — inklusive traditionell kinesiska, kantonesiska, wu/shanghaienska och hokkien/min nan — går genom den konfigurerade motorn; medlemskap i den kinesiska språkfamiljen ensamt hoppar inte över översättningen. Servera sedan från cachen eller **kölägg**;
   - kölagda strängar spolas ut av en **arbetarpool** med **stegvis tillämpning per bit** (varje returnerad bit ökar `revision` så att texten uppdateras gradvis), och resultaten **lagras beständigt** (strypat). Gruppstorlek och samtidighet följer motorn: **1 per förfrågan** på den inbyggda modellen, **≤ 16 med ≤ 10 i luften** på din egen API.
3. **Motorupplösning.** `TranslateProvider` (`builtin` / `custom`) avgör vilken URL, nyckel och modell transporten använder; i övrigt delar båda motorerna en kodväg och en språklista, så att byta motor är en enda inställning och aldrig en annan funktionsuppsättning.
4. **Transporten** återanvänder samma verifierade **strömningskanal** som AI-videosammanfattningen — `AiChatService.streamChat` → `{base}/chat/completions` med `stream: true` (kompatibel med gateways som bara stöder strömning) — utökad så att översättningen kan använda sina **egna** `apiUrl` / `apiKey` / `model` och en `enable_thinking`-flagga. Ändringen är **bakåtkompatibel**, så videosammanfattningen fortsätter fungera oförändrad.
5. **Interpolerade meningar** använder `uiTxP(template, args)`: en hel mening med `{0}`/`{1}`-platshållare översätts som en enda stabil nyckel (prompten ber modellen behålla platshållarna), och därefter sätts värdena tillbaka — så att strängar av typen `"共 {0} 条"` översätts utan att förstöra de dynamiska delarna.
6. **Språktabell** (`app_language.dart`): varje `AppLanguage` bär ett visningsautonym, en `toModel`-promptsträng som kodar skrift-/regionkonventioner och en flagga för huruvida bilibilis officiella lista täcker den. Skriftregler (förenklad mot traditionell samt instruktionerna om dialektsamstämmighet) når modellen endast via prompten, och ett deterministiskt normaliseringssteg på klienten fixar lösa tecken efteråt.
7. **Kommentarer** går genom `uiTxComment(text, id)` och behåller `@ / [emoji] / #ämne# / länk` som intakta token; rikstextspänn som bär länkar översätts medan länkigenkänningen bevaras, och en id-mängd per kommentar styr växlingen Original ⇄ Översättning.
8. **Danmaku** (`danmaku/view.dart`): när dess brytare är på går en positionslyssnare igenom `[playhead, playhead + 15s]` en sekund i taget och förvärmer `uiTx()` på varje danmakus innehåll, så att objekten föröversätts innan de når skärmen; att aktivera den rensar och ritar om duken.
9. **Lagringsnycklar**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Inställningsgränssnitt**: en enda förstanivåsida ”AI-funktioner” (`lib/pages/setting/ui_translate/`) med oberoende block för AI-videosammanfattning och AI-översättning.

**CDN över hela världen (`VideoUtils.getCdnUrl`).** Ström-URL:er är signerade, och att skriva om en URL:s värdnamn får den avvisad med 403 — så uppspelning skriver aldrig om värdar. PiliBabel returnerar den georutade URL som bilibili ger klientens IP, och när kandidatlistan redan innehåller en utlandskant (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`) föredras den. Hämtningar, där ett byte av värd är säkert, föredrar dessutom den globala Akamai-kanten och roterar till nästa signerade kandidat när en linje stannar eller avvisar en återupptagning. Råa `/v/resource` P2P-länkar faller fortfarande tillbaka på det befintliga reläet för att undvika 404.

**Designavvägningar / kända begränsningar.** Eftersom strängar wrappas på plats i stället för att extraheras till resurser fylls några få strängparametrar utanför `Text` och vissa rikstextspänn fortfarande i stegvis. Strängar som dubbelar som **logiknycklar** (jämförda med `==`, använda som fliknamn som `简介`, eller enum-etiketter i brytare) wrappas medvetet **inte** generellt, för att inte bryta beteendet. Danmakuöversättning är en bästa-ansträngning-insats på en rullande duk — under extremt tät danmaku kan du kort se originalet innan översättningen kommer. Översättning kräver nätverk; utan det träder helt enkelt icke-kinesiska mål inte i kraft. Den inbyggda ändpunkten är en gratis offentlig tjänst driven av bilibili — om den någon gång hastighetsbegränsas eller är otillgänglig talar appen om det och du kan byta till din egen API.

## Bygga och verifiera

Appen byggs med ett patchat Flutter SDK plus patchade `material_ui` / `cupertino_ui`-paket via `lib/scripts/patch.ps1` och `lib/scripts/build.ps1` (exakt som PiliNara / PiliPlus). GitHub Actions producerar en **debug-APK** vid varje push (`.github/workflows/ui-translate-debug.yml`), och **att publicera en tagg `v*` bygger och släpper Android-, Windows- och Linux**-artefakter automatiskt (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Plattformar
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

PiliBabel levererar **Android (APK) -, Windows- och Linux**-byggen från Releases; iOS/Pad är inte paketerade i den här forken än.

<br/>

## Hämtning

Hämta ett bygge från **Releases**, eller klona förrådet och bygg det lokalt.

### Arch Linux

Tack till [@nlsdt](https://github.com/nlsdt) för paketeringen (PiliNara-receptet överförs till PiliBabel).

```bash
sudo pacman -S pilinara      # via Arch Linux CN-förrådet
paru -S pilinara-bin         # eller via AUR: pilinara-bin (förbyggt) / pilinara (källkod)
```

<br/>

## Ärvd funktionslogg (från PiliNara / PiliPlus)

Allt nedan ärvs från PiliNara (och, indirekt, PiliPlus); PiliBabel lägger AI-översättningslagret ovanpå.

**Gränssnitt och plattformsanpassning**
- [x] Appen omdöpt per plattform så att flera klienter kan samexistera (PiliBabel installeras bredvid PiliNara)
- [x] Fixad Flutter-rendering under Xiaomi HyperOS-minifönster ([#161086](https://github.com/flutter/flutter/issues/161086), via [venera#467](https://github.com/venera-app/venera/pull/467)); förutsägande tillbaka-animation på Android
- [x] Anpassningsbar ordning/antal för ”Min”-kort; förhandsvisning av historikkort och ”se senare”-avdelningar
- [x] Automatisk sidomenysväxling med konfigurerbar tröskelbredd; kopiera bild från långtryck / högerklick; stor MD3E-stil-uppdatering

**Typsnittssystem** — en enad importpool med deduplicering via innehållshash, danmaku-typsnitt sammanslagna i samma pool, `loadFontFromList` med stöd för ttc samt rena ASCII-hash-familjenamn.

**Uppspelning, minifönster och kvalitet** — minifönster i appen (dra, ändra storlek, SponsorBlock-hopp, automatisk system-PIP, självrädningsrad i live), uppspelning med samtidigt ljud, volym i appen upp till 200 %, anpassad video-CDN-domän och val av regional nod med latensmätning, separata standardkvaliteter för halv/helskärm, hastighetslås vid svep upp, tangentbordsstyrning på surfplatta, SuperChat-tidsstämplar i live, live-hjärtslag för fan-intimitet.

**Undertexter, AI och offline** — tvåspråkiga undertexter med oberoende stil för sekundär undertext, AI-analys av undertexter (anpassad OpenAI-kompatibel ändpunkt, tidsstämpelhopp, mallar, beständiga konversationer, mjuk reservlösning när undertexter saknas), WEBVTT/SRT-export, dubbelvy för offlinecache med mapphantering och beständig metadata, export av hämtningar till den offentliga mappen Hämtningar (Android).

**Danmaku och blockering** — förbättrad skalning av sammanslagen danmaku (i [Pakku.js](https://github.com/xmcp/pakku.js)-stil), listbaserad visuell regex-blockering med import/export, SponsorBlock-hopp vid sökning in i ett segment, högenergiframstegslist med gaussisk kärna.

**Filtrering av rekommendationer / dynamik / kommentarer** — nyckelord för titel/UP/kanal, längd, uppspelningsantal, gilla-frekvens, undantag för följda UP, filtrering av obehörigt/endast-betalt innehåll, delad vitlista, kommersiell/obehörig dynamik, undantag för UP-egna och fästa kommentarer, App+Webb-sammanslaget flödesläge.

**Dynamik, sökning och användarinfo** — egna anteckningar för UP, anteckning-ersätter-smeknamn över 13 namnplatser, oberoende sortering av nästlade kommentarer, lokalt nyckelordssökfilter, b23.tv-kortlänkshopp, endast-betalt-märke, brytare för att dölja rekommendationsorsak, visning av mynt-XP.

**Live-förbättringar** — panel för att bära fanmedaljer, DLNA-casting som föredrar HLS, SuperChat-tidsvisning, nedre kontrollist i minifönstret för självräddning.

**Systemintegration och skrivbord** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), ombyggd hantering av ljudfokus.

<details>
<summary>Fullständig ursprunglig funktions-/checklista (ordagrant, från PiliNara — klicka för att fälla ut)</summary>

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

## Ansvarsfriskrivning

PiliBabel är ett personligt, intressedrivet projekt, tillhandahållet **endast för lärande och testning**; var god radera det inom **24 timmar** från hämtningen.

- PiliBabel är en **oinofficiell tredjeparts**klient och är **inte knuten till, inte godkänd av och inte sponsrad av bilibili**.
- Alla API:er är insamlade från officiella publika ändpunkter; **inget knäckt, överprivilegierat eller betalväggs-kringgående innehåll** tillhandahålls.
- **AI-översättningen körs på en modelländpunkt från tredje part.** Som standard är det bilibilis egen gratis publika Index-Translate-tjänst; om du byter till din egen API är det ändpunkten du konfigurerade. Översättningskvalitet och regelefterlevnad är användarens och den valda modellleverantörens ansvar; det här projektet är värd för **ingen modell och ingen API-nyckel**.
- Respektera upphovsrätt och bilibilis användarvillkor. Använd ansvarsfullt.

Med respekt för de ursprungliga och uppströms sittande upphovsmännen för deras engagemang för öppen källkod:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — det direkta föräldraprojektet till PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — den öppna familjen av översättningsmodeller som den inbyggda motorn anropar

Om något innehåll kränker dina rättigheter, kontakta oss för borttagning.

<br/>

## Licens

PiliBabel är licensierat under **GNU General Public License v3.0 (GPL-3.0)** — samma licens som PiliNara, PiliPlus och PiliPala. Eftersom det är ett härlett verk **måste PiliBabel också distribueras under GPL-3.0**: du får fritt använda, studera, dela och ändra det, förutsatt att du behåller samma licens, upphovsrättsnoteringar och denna licenstext. Se [`LICENSE`](./LICENSE).

Tredjepartskomponenter (Flutter-paket, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio) etc.) förblir under sina egna licenser.

Det medföljande typsnittet **LXGW WenKai** är separat licensierat under **SIL Open Font License 1.1**; dess licenstext levereras i appen som `assets/fonts/LXGWWenKai-OFL.txt`.

<br/>

## Tack

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — bilibilis öppna familj av översättningsmodeller, och den gratis publika ändpunkten bakom den inbyggda motorn
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — det öppna kinesiska typsnitt som medföljer appen, under SIL Open Font License 1.1
- och mer
- Inspirerad av bilibilis officiella ”AI-gränssnittsöversättning”.
