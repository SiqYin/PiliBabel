> **Erklärung:** Das Verbreiten von PiliBabel-Installationspaketen ohne Erlaubnis ist eine Rechtsverletzung. Bitte nur aus der offiziellen Quelle [GitHub Releases](https://github.com/SiqYin/PiliBabel/releases) herunterladen. Vollständige Erklärung: [STATEMENT.md](STATEMENT.md).

<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Ein Bilibili-Client von Drittanbietern mit KI-Übersetzung.</b></p>
    <p>Babel — die Sprachbarriere einreißen, damit jede und jeder bilibili in der eigenen Sprache genießen kann.</p>
    <p>Vereint die 151 offiziell von bilibili unterstützten Sprachen mit 6 weiteren, die es nicht abdeckt — traditionelles Chinesisch, vereinfachtes und traditionelles Wu, Taiwan-Hokkien sowie Zhuang, Tâi-gí — in einer Liste.</p>
    <p>Die Übersetzung läuft direkt nach der Installation über bilibilis kostenloses Modell — kein API-Schlüssel nötig.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.nan.md">台語</a> · <a href="README.fr.md">Français</a> · <b>Deutsch</b> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.mn.md">Монгол</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.pt.md">Português</a> · <a href="README.bn.md">বাংলা</a> · <a href="README.th.md">ไทย</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.it.md">Italiano</a> · <a href="README.fa.md">فارسی</a> · <a href="README.fil.md">Filipino</a> · <a href="README.ur.md">اردو</a> · <a href="README.mr.md">मराठी</a> · <a href="README.te.md">తెలుగు</a> · <a href="README.ta.md">தமிழ்</a> · <a href="README.pa.md">ਪੰਜਾਬੀ</a> · <a href="README.gu.md">ગુજરાતી</a> · <a href="README.ha.md">Hausa</a> · <a href="README.sw.md">Kiswahili</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.my.md">မြန်မာ</a> · <a href="README.pl.md">Polski</a> · <a href="README.is.md">Íslenska</a> · <a href="README.nb.md">Norsk</a> · <a href="README.fi.md">Suomi</a> · <a href="README.sv.md">Svenska</a> · <a href="README.da.md">Dansk</a> · <a href="README.be.md">Беларуская</a> · <a href="README.ug.md">ئۇيغۇرچە</a> · <a href="README.kk.md">Қазақша</a> · <a href="README.bo.md">བོད་ཡིག</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Startseite" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dynamik" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Ich" />
</div>

<br/>

> **Haftungsausschluss.** PiliBabel ist ein **inoffizieller, quelloffener Client von Drittanbietern**. Er ist **weder mit bilibili / bilibili Inc. verbunden noch von ihnen unterstützt oder gesponsert**. Sämtliche APIs stammen aus offiziellen öffentlichen Endpunkten; **es werden keine kostenpflichtigen Inhalte freigeschaltet oder geknackt**. Bitte lies die Abschnitte [Haftungsausschluss](#haftungsausschluss) und [Lizenz](#lizenz) vollständig.

## Was ist PiliBabel?

PiliBabel ist ein **unabhängiger Fork von Drittanbietern auf Basis von [PiliNara](https://github.com/Starfallan/PiliNara)** und erbt alles, was PiliNara erbt:

```
bilibili (offizielle öffentliche API)
        ▲
   PiliPala / PiliPalaX        — das ursprüngliche Projekt
        ▲
   PiliPlus                    — aktiv gepflegter Fork
        ▲
   PiliNara                    — Fork von PiliPlus (persönliche Anpassungen)
        ▲
   PiliBabel  ← du bist hier    — Fork von PiliNara
```

PiliBabel behält **alle Funktionen von PiliNara / PiliPlus** (siehe das [Verzeichnis der übernommenen Funktionen](#verzeichnis-der-übernommenen-funktionen-aus-pilinara--piliplus) weiter unten) und fügt **zwei Kernfähigkeiten hinzu, die die vorgelagerten Clients nicht haben**:

> **KI-Übersetzung von Oberfläche und Inhalten** — die gesamte App (Beschriftungen, Videotitel, Namen der UP, Kommentare, Dynamik, Feed und sogar Live-Danmaku) erscheint in der Sprache, **die du** wählst.

Und seit 1.0 funktioniert das **direkt nach der Installation**: Das Übersetzungsmodell ist **eingebaut**. bilibili hat sein eigenes Übersetzungsmodell [Index-Translate](https://github.com/bilibili/Index-Translate) quelloffen veröffentlicht und betreibt es über einen kostenlosen öffentlichen Endpunkt. PiliBabel zeigt standardmäßig darauf — die Übersetzung läuft also, sobald du die App installierst: keine Anmeldung, kein Schlüssel, keine Rechnung. Wenn du lieber dein eigenes Modell nutzt, bleibt der Weg über die eigene API bestehen, einen Tipp entfernt.

> **Kopfhörerton, der wirklich synchron bleibt** — mit Bluetooth- oder kabelgebundenen Kopfhörern läuft der Ton dem Bild nicht mehr hinterher. Die offizielle App bekommt das hin; PiliNara und PiliPlus nicht, jedenfalls nicht ab Werk. PiliBabel verlangt von mpv jetzt zuerst **AudioTrack**: Dieses Backend **misst** die Audio-Ausgabelatenz, genau wie der offizielle Client — während **OpenSL ES** (die bisherige Voreinstellung) sie nur **schätzt**.

## Hauptfunktionen

- **Kopfhörerton ohne Verzögerung.** Der Player nutzt standardmäßig das **AudioTrack**-Backend von mpv (Reihenfolge `audiotrack,aaudio,opensles`) statt **OpenSL ES**. AudioTrack meldet eine **gemessene** Latenz — es liest die bereits ausgegebenen Frames und den Präsentationszeitstempel des Geräts —, genau wie es die offizielle bilibili-App und Androids eigenes `MediaSync` tun, um Bild und Ton zusammenzuhalten. OpenSL ES **schätzt** nur: Bei Bluetooth-Kopfhörern driftete die Audiouhr, und das Bild wurde zu früh gezeigt. Im Test ist die Verzögerung praktisch verschwunden. Die Reihenfolge lässt sich jederzeit unter Einstellungen → Video → Audioausgabegerät ändern.

- **KI-Übersetzung, überall.** Navigationsleisten, Videokarten, Detailseiten, Kommentare, Dynamik sowie die Bereiche Ich / Favoriten / Verlauf / Nachrichten / Suche — ein globaler Durchlauf erfasst **rund 1.650 Oberflächentexte**, dazu dynamische Inhalte (Titel, Autorennamen, Zähler).
- **Zwei Engines, ein Schalter.** *Eingebaut* (Standard) nutzt den kostenlosen Endpunkt des offiziellen Modells **Index-Translate-35B-A3B** von bilibili — nichts einzurichten. *Eigene API* behält das bisherige Verhalten: Richte sie auf einen beliebigen OpenAI-kompatiblen `/chat/completions`-Endpunkt mit eigener Basis-URL / Schlüssel / Modell. Die KI-Videozusammenfassung und die KI-Übersetzung haben weiterhin **vollständig getrennte** Endpunkte und Einstellungen und liegen gemeinsam auf einer Seite **„KI-Funktionen“**.
- **Eine Sprachliste, beide Engines.** Die Liste der Zielsprachen ist nicht nach Engine getrennt — es ist dieselbe Liste, egal welche du wählst. Sie vereint die **151 Sprachen** des offiziellen bilibili-Modells mit **6 weiteren, die es nicht abdeckt** — traditionelles Chinesisch, vereinfachtes und traditionelles Wu, Taiwan-Hokkien sowie Zhuang, Tâi-gí. Regionale und schriftliche Varianten bleiben **eigene Einträge**, statt zusammengelegt zu werden — Marokkanisches / Ägyptisches / Nadschdi- / Levantinisches Arabisch sind je eine eigene Wahl, ebenso Serbisch, Usbekisch und Urdu in kyrillischer bzw. lateinischer Schrift.
- **Ehrlich bei der Abdeckung.** Sprachen innerhalb des offiziellen Verzeichnisses deckt bilibilis Modell ab. Die wenigen außerhalb — traditionelles Chinesisch sowie die oben genannten chinesischen Dialekte und Minderheitensprachen, die bilibili nicht führt — erscheinen trotzdem in der Liste, entsprechend gekennzeichnet, damit du auf einen Blick siehst, dass ein besseres Ergebnis dein eigenes Modell erfordern kann.
- **Einmal übersetzt, dann festgeschrieben.** Jede Ausgangszeichenkette wird **genau einmal** übersetzt; das Ergebnis wird lokal gespeichert und **nie erneut übersetzt**, wenn du einen Bildschirm erneut öffnest — dasselbe Prinzip wie beim offiziellen Client, für stabile, vorhersehbare Übersetzungen.
- **Umschalter Original ⇄ Übersetzung pro Kommentar** (ein kleines Symbol, kein Wort). `@Erwähnungen / [Emojis] / #Themen# / Links` bleiben als Tokens erhalten, und **Kommentare mit Hyperlinks werden übersetzt, wobei der Link anklickbar bleibt**.
- **Danmaku-Übersetzung** — ein eigener Schalter in der oberen rechten Bedienleiste des Players, **standardmäßig aus** und hinter einer Bestätigung, deren Text selbst übersetzt wird. Einmal aktiviert, werden Danmaku vor der Abspielposition in **Paketen von etwa 15 Sekunden** vorübersetzt (ein Sprung in die Mitte wird korrekt behandelt, nicht von vorn), sodass die Übersetzung meist bereitsteht, wenn sie vorbeiziehen.
- **Schalter für den Denkmodus** (`enable_thinking`) für die Abwägung Qualität gegen Geschwindigkeit, plus die Schaltflächen **„Übersetzung testen“** und **Cache leeren** in den Einstellungen.
- **Schneller Sprachwechsel**: Anfragen in Stapeln mit begrenzter Nebenläufigkeit auf einem dauerhaften Cache; ein Sprachwechsel baut den aktuellen Bildschirm einmal neu auf, damit du nicht auf unübersetzten Text starrst. Wer die KI-Übersetzung abschaltet, bekommt die gesamte Oberfläche im Original zurück, und es werden **überhaupt keine Anfragen** gesendet.
- **Einführung beim ersten Start.** Beim ersten Öffnen der App schlägt ein englischer Dialog vor, die Übersetzung einzuschalten. Wer zustimmt, bekommt: Übersetzung aktiviert, eingebautes Modell ausgewählt, die KI-Einstellungen geöffnet und sofort die Frage nach der gewünschten Sprache — neue Nutzer kommen mit zwei Tipps von „gerade installiert“ zu „bereits übersetzt“.
- **Wiedergabe, die weltweit funktioniert.** PiliBabel wählt den ausländischen Endpunkt (globales **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`), den bilibilis geo-geroutetes `playurl` ohnehin anbietet, statt dich auf einen Festlandsknoten (Alibaba Cloud / Shenzhen) festzunageln — Nutzer außerhalb des chinesischen Festlands haben damit keine Hänger mehr nach dem Muster „Ton läuft, Bild steht“. Du kannst den CDN in den Einstellungen weiterhin manuell festlegen.
- **Eine Seite „Design & Farben" im Material-You-Stil.** Hell / dunkel / Systemeinstellung werden über **drei Live-Vorschaukarten** gewählt — jede zeigt eine Miniatur der echten Oberfläche in genau den Farben, die der jeweilige Modus anwenden würde (die Karte „Systemeinstellung" ist diagonal geteilt, hell oben links, dunkel unten rechts). Darunter: **dynamische Farben** (vom System-Hintergrundbild übernommen, sofern das Gerät es unterstützt), **dunkel mit hohem Kontrast** (echt schwarze Flächen, nachts angenehmer) und **Player immer dunkel**. Die Farbhälfte behält die vollständige FlexScheme-Palette — **19 Basisfarben** sowie ein eigenständiger **„Palettenstil"**, der bestimmt, wie alle Containerfarben aus der Basisfarbe abgeleitet werden, unabhängig davon, welche Basisfarbe Sie wählen.
- **LXGW WenKai ist mitgeliefert.** Die Schrift **霞鹜文楷 (LXGW WenKai)** ist **enthalten und als Standard gesetzt** — eine warme, sehr gut lesbare chinesische Schrift, die Sie direkt nach der Installation haben, statt sie in einer Auswahlliste zu suchen. Sie gilt für die gesamte Oberfläche *und* für die Danmaku. Sie können weiterhin zur Systemschrift wechseln, jede installierte Schrift wählen oder eine eigene `.ttf` / `.otf` / `.ttc` importieren; eine zuvor bewusst gewählte Schrift bleibt beim Update erhalten. Schriftschnitt und Größe sind wie bisher einstellbar.

## Offline-Audio-Cache und Download in einen eigenen Ordner (nur PiliBabel)

Zwei Funktionen, die PiliNara / PiliPlus nicht haben – und der Hauptgrund für diesen Fork.

### Audio-Cache (nur die Tonspur)

- Im Menü oben rechts auf der Videoseite steht *Audio-Cache* direkt unter *Video-Cache*; in der oberen Leiste der Hörseite gibt es links neben Sortieren / Sleep-Timer / Mehr ebenfalls einen *Audio-Cache*-Button.
- Qualitätsstufe wählbar: Hi-Res lossless, Dolby Atmos, 192K, 132K oder 64K – dieselbe Voreinstellungsliste wie bei der Videoqualität.
- Die Datei wird im Originalcontainer geschrieben (`m4a` / `mp3` / `flac` / `wav` / `aac` / `ogg`) – ohne Transkodierung.
- Die Cache-Seite ist in *Video-Cache* / *Audio-Cache* geteilt und merkt sich das zuletzt geöffnete Modul.
- Ein Tipp auf einen gecachten Titel öffnet direkt den Audioplayer; Löschen einzeln oder in Stapeln.

### Download in einen lokalen Ordner

- *In einen lokalen Ordner laden* ist ein eigener Menüpunkt auf der Videoseite, direkt unter *Audio-Cache* – In-App-Cache und Speichern in den eigenen Ordner sind zwei getrennte Aktionen.
- Zuerst wird *Video herunterladen* oder *Audio herunterladen* gefragt, danach die Qualitätsstufe (Video- / Audioqualität).
- Den Zielordner wählt man über den System-Dateimanager (Einstellungen → *Download-Ordner*); jederzeit änder- oder löschbar. Ist noch keiner gesetzt, öffnet sich die Ordnerauswahl direkt.
- Videos werden als einzelner gemuxter Stream geholt (`fnval=1`) – auf der Platte landet also eine normale MP4, die jeder Player öffnen kann.
- Audio behält sein Originalformat, genau wie der In-App-Cache.
- Dateien werden nach dem Videotitel benannt und überschreiben nie einen vorhandenen Download.

## Die beiden Übersetzungs-Engines

| | Eingebaut (Standard) | Eigene API |
|---|---|---|
| Modell | bilibili **Index-Translate-35B-A3B** | alles OpenAI-Kompatible |
| Endpunkt | `index-translate.bilibili.com/v1` | deine Basis-URL |
| API-Schlüssel | **nicht nötig** | deiner |
| Kosten | kostenlos | je nach Anbieter |
| Anfragen | eine Zeichenkette pro Anfrage | in Stapeln (≤ 16 pro Anfrage) |
| Zusätzliche Sprachen | — | jede Sprache, die dein Modell kennt |

**Warum pro Anfrage nur eine Zeichenkette, wenn die Engine eingebaut ist.** Index-Translate ist ein **spezialisiertes** Übersetzungsmodell, und die von seinen Autoren dokumentierte Aufrufkonvention ist eine Vorlage für einen einzelnen Eintrag („Übersetze den folgenden Text ins X, gib nur die Übersetzung aus“). PiliBabel sendet auf dieser Engine deshalb eine Zeichenkette pro Anfrage statt des Stapel-Prompts mit nummerierter Liste und JSON-Array, der für eigene APIs verwendet wird. Der Endpunkt ist kostenlos — es gibt nichts zu gewinnen, wenn man auf Stapelausgaben setzt. Das ist ein bewusster Tausch: ein paar Anfragen mehr gegen deutlich weniger Möglichkeiten zu scheitern.

**Upgrade von 0.3.x.** Deine eigenen API-Einstellungen — Basis-URL, Schlüssel und Modell — werden **genau so belassen, wie du sie eingerichtet hast**. Die Engine-Auswahl fällt lediglich auf das eingebaute Modell: Beim ersten Start nach dem Upgrade läuft also bilibilis kostenloses Modell. Öffne *Einstellungen → KI → KI-Funktionen → Übersetzungs-Engine* und stelle auf *Eigene API* zurück, um sofort wieder bei deiner Konfiguration zu sein.

## Wie die Oberflächenübersetzung funktioniert (technisch)

Das Repository hat **keine i18n- / ARB-Ressourcenschicht** — Oberflächentexte stehen fest im Code, auf Chinesisch. Statt jedes Widget neu zu schreiben, legt PiliBabel eine dünne Übersetzungsschicht darüber:

1. **Ein globaler Nachschlage-Wrapper.** `lib/services/ui_translate/` stellt die Funktion `uiTx(String src)` auf oberster Ebene bereit. Aus `Text('中文')` wird `Text(uiTx('中文'))`. Ein **geskriptetes Codemod** hat das im ganzen Projekt angewandt (`tool/ui_translate_*.py`) — rund **223 Dateien / 1.650 Zeichenketten** — und dabei das nun ungültige Schlüsselwort `const` automatisch entfernt, wo nötig (auch bei Generika wie `const X<T>(...)` und punktierten Namen wie `const Positioned.fill(...)`), und `static const`-Deklarationen von Listen und Maps in `static final` umgewandelt.
2. **Ein `GetxService`-Kern** (`ui_translate_service.dart`):
   - ein dauerhafter Cache **Ausgangstext → Übersetzung** (über GetStorage), sodass jede Zeichenkette einmal übersetzt und für immer wiederverwendet wird;
   - `tx()` liest zuerst ein `RxInt revision` und entscheidet dann: deaktiviert → Original zurückgeben; ist das Ziel **vereinfachtes Chinesisch (`zh-CN`)** → Original ohne API-Anfrage zurückgeben (bilibilis Inhalte sind überwiegend vereinfachtes Chinesisch). Jedes andere Ziel — auch traditionelles Chinesisch, Kantonesisch, Wu und Minnan — läuft über die konfigurierte Engine; die Zugehörigkeit zur chinesischen Sprachfamilie allein überspringt die Übersetzung nicht. Danach: aus dem Cache bedienen oder **einreihen**;
   - eingereihte Zeichenketten werden von einem **Worker-Pool** abgearbeitet, mit **inkrementeller Anwendung pro Block** (jeder zurückkommende Block erhöht `revision`, der Text aktualisiert sich also schrittweise), und die Ergebnisse werden **dauerhaft gespeichert** (gedrosselt). Stapelgröße und Nebenläufigkeit folgen der Engine: **1 pro Anfrage** beim eingebauten Modell, **≤ 16 mit ≤ 10 gleichzeitig** bei deiner eigenen API.
3. **Engine-Auflösung.** `TranslateProvider` (`builtin` / `custom`) bestimmt, welche URL, welcher Schlüssel und welches Modell in der Transportschicht verwendet werden; abgesehen davon teilen beide Engines einen Codepfad und eine Sprachliste — ein Engine-Wechsel ist also eine einzelne Einstellung und **nie ein anderer Funktionsumfang**.
4. **Die Transportschicht** nutzt denselben bewährten **Streaming**-Kanal wie die KI-Videozusammenfassung — `AiChatService.streamChat` → `{base}/chat/completions` mit `stream: true` (kompatibel mit Gateways, die nur Streaming unterstützen) — erweitert, damit die Übersetzung **eigene** `apiUrl` / `apiKey` / `model` und ein `enable_thinking`-Flag verwenden kann. Die Änderung ist **abwärtskompatibel**, die Videozusammenfassung funktioniert unverändert weiter.
5. **Sätze mit Platzhaltern** laufen über `uiTxP(template, args)`: Ein ganzer Satz mit `{0}`/`{1}` wird als eine stabile Schlüsselgröße übersetzt (der Prompt bittet das Modell, die Platzhalter zu erhalten), anschließend werden die Werte wieder eingesetzt — Zeichenketten wie `"共 {0} 条"` werden also übersetzt, ohne die dynamischen Teile zu verunstalten.
6. **Sprachtabelle** (`app_language.dart`): Jede `AppLanguage` trägt einen Anzeigenamen (Autonym), eine `toModel`-Prompt-Zeichenkette, die Schrift- und Regionskonventionen kodiert, und eine Angabe, ob bilibilis offizielles Verzeichnis sie abdeckt. Schriftregeln (vereinfacht / traditionell) und Vorgaben zur dialektalen Konsistenz erreichen das Modell **nur über den Prompt**; danach korrigiert ein deterministischer Normalisierungslauf auf Clientseite verirrte Zeichen.
7. **Kommentare** laufen über `uiTxComment(text, id)` und behalten `@ / [Emojis] / #Thema# / Link` als unversehrte Tokens; Rich-Text-Abschnitte mit Links werden übersetzt, während die Link-Erkennung erhalten bleibt, und eine Menge von IDs pro Kommentar steuert den Umschalter Original ⇄ Übersetzung.
8. **Danmaku** (`danmaku/view.dart`): Ist der Schalter an, läuft ein Positions-Listener `[Abspielposition, Abspielposition + 15 s]` Sekunde für Sekunde ab und wärmt `uiTx()` für jeden Danmaku-Inhalt vor, sodass die Einträge übersetzt sind, bevor sie auf den Bildschirm kommen; beim Aktivieren wird die Leinwand geleert und neu gezeichnet.
9. **Speicherschlüssel**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Einstellungsoberfläche**: eine einzelne Seite erster Ebene „KI-Funktionen“ (`lib/pages/setting/ui_translate/`) mit unabhängigen Blöcken für KI-Videozusammenfassung und Oberflächenübersetzung.

**Weltweites CDN (`VideoUtils.getCdnUrl`).** Stream-URLs sind signiert, und wer den Host einer URL umschreibt, bekommt ein 403 — die Wiedergabe schreibt den Host also nie um. PiliBabel gibt die geo-geroutete URL zurück, die bilibili der IP des Clients aushändigt, und wenn die Kandidatenliste bereits einen ausländischen Endpunkt enthält (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`), wird dieser bevorzugt. Downloads, bei denen ein Host-Tausch unbedenklich ist, bevorzugen zusätzlich den globalen Akamai-Endpunkt und wechseln zum nächsten signierten Kandidaten, wenn eine Leitung stockt oder eine Fortsetzung ablehnt. Rohe `/v/resource`-P2P-Links fallen weiterhin auf den bestehenden Relay zurück, um 404 zu vermeiden.

**Design-Kompromisse / bekannte Grenzen.** Weil Zeichenketten an Ort und Stelle umhüllt statt in Ressourcen ausgelagert werden, werden einige Nicht-`Text`-Zeichenkettenparameter und manche Rich-Text-Abschnitte noch schrittweise ergänzt. Zeichenketten, die zugleich **logische Schlüssel** sind (mit `==` verglichen, als Tab-Namen wie `简介` verwendet oder als Enum-Beschriftungen in Schaltern), werden **bewusst nicht** pauschal umhüllt, um das Verhalten nicht zu brechen. Die Danmaku-Übersetzung ist Best-Effort auf einer scrollenden Leinwand — bei extrem dichtem Danmaku siehst du den Originaltext kurz, bevor die Übersetzung eintrifft. Die Übersetzung braucht Netz; ohne Netz greifen nicht-chinesische Ziele schlicht nicht. Der eingebaute Endpunkt ist ein kostenloser öffentlicher Dienst von bilibili — sollte er gedrosselt oder nicht verfügbar sein, sagt dir die App das und du kannst auf deine eigene API wechseln.

## Bauen und prüfen

Die App wird mit einem gepatchten Flutter-SDK sowie gepatchten Paketen `material_ui` / `cupertino_ui` über `lib/scripts/patch.ps1` und `lib/scripts/build.ps1` gebaut (genau wie PiliNara / PiliPlus). GitHub Actions erzeugt bei jedem Push eine **Debug-APK** (`.github/workflows/ui-translate-debug.yml`), und **das Veröffentlichen eines Tags `v*` baut und veröffentlicht automatisch Android-, Windows- und Linux-Artefakte** (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Plattformen
- [x] Android
- [ ] iOS
- [ ] Tablet
- [x] Windows
- [x] Linux

PiliBabel liefert in den Releases Builds für **Android (APK), Windows und Linux**; iOS und Tablet sind in diesem Fork noch nicht gepackt.

<br/>

## Download

Hol dir einen Build aus den **Releases**, oder klone das Repository und baue es lokal.

### Arch Linux

Dank an [@nlsdt](https://github.com/nlsdt) fürs Paketieren (das PiliNara-Rezept gilt auch für PiliBabel).

```bash
sudo pacman -S pilinara      # über das Arch-Linux-CN-Repository
paru -S pilinara-bin         # oder über AUR: pilinara-bin (vorgebaut) / pilinara (Quelle)
```

<br/>

## Änderungsverlauf: 2.6.x → 3.9.3

- **2.6.x** — Audio-Cache (getrennte Module für Video und Audio, letzte Auswahl wird gemerkt, Einstiege auf der Videoseite, der Nur-Audio-Seite und im Audioplayer; Originalformat bleibt erhalten; wählbare Qualität) und Download auf das Gerät (eigener Menüpunkt: erst Video/Audio, dann Qualität; ohne eingestellten Ordner öffnet sich die Systemdateiauswahl).

- **3.0.x** — Selbstheilung im Auslandsnetz: Zustand je Host mit Umschaltung zwischen Haupt- und Ausweichroute, DNS-Auflösung mit Cache, Vorwärmen der Verbindungen, Abkühlung nach Risikokontrolle (412), Regionserkennung mit manueller Auswahl, CDN-Geschwindigkeitstest gemeinsam mit der API-Ebene.

- **3.1.0** — adaptiver Vorwärtspuffer nach Bitrate der Videospur sowie Korrekturen an Player und Audio.

- **3.2.0** — Netzwerkgrundlage im Stil der offiziellen App: Anfrage-Fingerabdruck (buvid/fp/session_id/env), gRPC-Host-Failover, Retry-Interceptor, Nebenläufigkeitsgrenze je Host, Vorladen des ersten Feeds beim Kaltstart, offizielle Feed-Ereignisparameter, CDN-Reihenfolge mit Ausweichrouten; Vorladen der zweiten Feed-Seite, begrenzte Warteschlange für Titelbilder, Vorladen der Wiedergabe-URLs; Audio und Kommentare laufen auf derselben Grundlage.

- **3.3.0–3.3.3** — Dynamik-Darstellung (P3) über gRPC, danach Korrekturen: Kompilierfehler bei der Pufferlänge auf der Audioseite und ein Typfehler beim Vorladen der Kommentare, durch den jeder Wiederholungsversuch sofort scheiterte.

- **3.3.4** — Dynamik-Karten für Bezahlkarten, Mini-Apps, Themensammlungen und Abos; der Startbildschirm ohne Titelbilder ist behoben; Abgleich mit PiliNara (Statusleiste, Fortsetzen des Downloads nach Prozessende, media-kit-Aktualisierung, Umgehung des schwarzen Bildes unter Wayland, wählbare Tonqualität beim Cachen); Prüfung der AI-Übersetzung für alle seit 3.0.5 hinzugefügten Oberflächentexte; dieser Änderungsverlauf.

- **3.3.x — der lange Schwanz.** Dynamik (P3) über gRPC gerendert, dazu Dynamik-Karten für Aufladungen, Mini-Apps, Themensammlungen und Abos; die Startseite verliert ihre Titelbilder nicht mehr; ein Abgleich mit PiliNara (schwarze Statusleiste, Download-Wiederaufnahme nach Prozessabbruch, media-kit-Update, Workaround für schwarzes Video unter Wayland); dann ein Abschlussdurchgang, der die Bildpipeline auf Direktverbindungen umstellte (behebt sowohl „Titelbilder brauchen ein Herunterziehen“ als auch einen flächendeckenden Datenausfall), Datenanfragen standardmäßig direkt laufen lässt, Audio und Video über einen segmentierten Proxy mit mehreren Verbindungen führt, die Wartezeit beim Spulen auf 600 ms begrenzt und das Verhalten von „vollständigen Titel anzeigen“ je Bildschirm wiederherstellt.

- **3.4.0 — die Prüfung.** Der Analyzer steht bei **0 Fehlern / 0 Warnungen**, alle 44 Sprach-READMEs haben einen Hinweis zur KI-Übersetzung erhalten, und die restliche Aufgabenliste sowie die bekannten Verhaltensunterschiede zur offiziellen App stehen jetzt in `docs/`.

- **3.5.0–3.9.3 — Terminologie, Übersetzung, Untertitel, Feinschliff und Player-Korrekturen.** Das Glossar wuchs auf **15 Tabellen in fünf Sprachen** (12 Spiele plus hololive, NIJISANJI und THE iDOLM@STER, über 11.600 Begriffe) und lernt, kurze Namen, jeden Teil eines mehrteiligen Namens und Begriffe mitten im Satz aufzulösen — mit einem Schalter pro Tabelle. Außerdem: die offizielle KI-Spur für die Originalton-Übersetzung folgt der Oberflächensprache, Trends der Suchseite werden übersetzt und zweizeilig dargestellt, der Update-Dialog liest sich als reiner Text statt als rohes Markdown und wird zuerst übersetzt, damit er nie chinesisch öffnet, automatische Prüfung auf Glossar-Updates, und das Stocken bei eingeschalteter KI-Übersetzung ist weg. Der in 3.6.3 eingeführte Absturz (bei aktiver KI-Übersetzung blieben Seiten leer, danach schloss sich die App) ist in 3.6.4 behoben. In 3.6.5 verhindert ein eingebetteter Begriff nicht mehr die Übersetzung des restlichen Absatzes, der Glossar-Bildschirm folgt dem App-Theme, die Tabellen sind standardmäßig aktiv, und die selbst gemeldete Version stimmt mit dem Release-Tag überein. 3.6.6 behebt, dass Namens-Teile zum vollen Namen expandierten, lässt den Glossar-Bildschirm wieder dem Theme folgen (Schalter funktionieren) und erlaubt offiziellen Namen, veraltete Cache-Übersetzungen zu überschreiben; 3.6.7 behebt den Zähler, der trotz aller Schalter auf 14/15 stehen blieb, und die angezeigten Zahlen dreier Tabellen (Reverse: 1999 war gar nicht eingebettet). 3.6.8 bringt die KI-Untertitelübersetzung: chinesische Untertitel werden kontextbewusst in Blöcken übersetzt, mit Echtzeit-Pufferung, Verwaltung pro Spur, einem Offline-Wörterbuch für Vietnamesisch und optionalem Proxy-Routing (beigesteuert von [saukhoai](https://github.com/saukhoai) über [PR #2](https://github.com/SiqYin/PiliBabel/pull/2)). 3.6.9 passt die Größe der Untertitel-Schaltfläche an, ergänzt die automatische Einrichtung beim ersten Start mit Erkennung der Systemsprache, übersetzt die Segmentangaben in der Player-Leiste, lässt die Tonspur-Auswahl der Sprachumschaltung folgen und repariert unübersetzte Rückmeldungen. 3.7.0 ergänzt ein HiRes-Audio-Abzeichen in der Player-Leiste, behebt Fehler beim Spulen und Wiedereinstieg im Audioplayer, erkennt einen verlorenen Tonkanal automatisch und stellt ihn verlustfrei wieder her, und behebt das Flackern des Fortschrittsbalkens beim Spulen. 3.7.1 macht die Untertitel-Schaltfläche auf dem Titelbild zu einem reinen Symbol in derselben Größe wie die Titelbild-Übersetzung und setzt sie direkt darüber, erklärt beide Schaltflächen einmal beim ersten Start, startet die Untertitel-Vorübersetzung, sobald ein Video geöffnet wird, und meldet «keine Untertitel / nicht angemeldet» nicht mehr als Fehler. 3.7.2 behebt den Fehler, wegen dem die Untertitelübersetzung nie gelang: Statt jede Zeile abzuweisen, die dem Original gleicht, wird jetzt der ganze Block geprüft (chinesische Zielsprachen ausgenommen), ein fehlgeschlagener Sammelaufruf fällt auf die Zeilenübersetzung zurück, beschädigte Zeitmarken werden verworfen, eine festgefahrene Aufgabe bricht mit der echten Ursache ab, und Erfolg wie Misserfolg werden gemeldet; «nicht angemeldet» wird ebenfalls übersetzt. 3.7.3 prüft die gesamte Untertitelkette Punkt für Punkt: Anime teilt sich jetzt einen Identitätsschlüssel zwischen Hintergrundaufgabe und Player, sodass eine fertige Übersetzung wirklich gefunden und „Übersetzung löschen“ tatsächlich löscht; ein Doppeltipp kann einen Erfolg nicht mehr in einen Fehler verwandeln; heruntergeladene Spuren tragen den vollständigen Zielsprachcode, sodass beim Wechsel zwischen Kurzzeichen, Langzeichen, Kantonesisch und Wu nicht mehr die falsche Schrift erscheint; ungeordnete Tracks werden zuerst sortiert, eine leere Spur gilt nicht mehr als erfolgreicher Download, Japanisch und Koreanisch werden nicht mehr als unübersetzt verworfen, der Status mehrerer Teile wird zusammengefasst statt überschrieben, und alle Rückmeldungen zum Untertitel sind vorgewärmt. 3.7.4 behebt die Schaltfläche zum Zwischenspeichern von Untertiteln, die ewig drehen konnte: Stapelverarbeitung endet jetzt immer (ein Teil ohne Untertitel hält nicht mehr das ganze Set auf), dieselbe Folge wird beim Öffnen über verschiedene Eingänge nicht mehr doppelt übersetzt oder verfehlt, Abschluss- und Fehlertoasts kommen zuverlässig, vietnamesische Spurnamen zeigen nicht mehr zuerst Chinesisch, Untertitel-Downloads probieren auch die v2-Adresse, und eine beschädigte Übersetzung wird nie in Offline-Videos kopiert. 3.7.5 macht die Danmaku-Übersetzung wirklich wirksam: ganze Segmente werden im Voraus chargenübersetzt, damit Bullet-Kommentare bereits übersetzt erscheinen; die Übersetzungswarteschlange lässt frisch geladene Titel nicht mehr hinter vorgewärmten Texten verhungern; der Fortschrittsring des Cover-Knopfs verwandelt sich beim Füllen sofort in einen Haken und ist beim Laden besser lesbar; alte Übersetzungsspur mit bloßem Sprachtag werden wiederhergestellt statt neu übersetzt; und das release-notes-Archiv ist wieder vollständig. 3.7.6 vereinheitlicht die Fortschrittsringe der beiden Cover-Knöpfe: Beide nutzen jetzt denselben 17-Pixel-Ring mit bestimmtem Fortschritt, der sich im Uhrzeigersinn von null füllt, statt endlos zu rotieren; außerdem wurde der Fehler behoben, bei dem Stapel- und Mehrteil-Aufgaben mit dem Zustandsschlüssel des ausgewählten Teils kollidierten – der Teil startet nun wirklich und der Stapel kann fertig werden. 3.7.7 macht aus den Cover-Knöpfen eine Drei-Knopf-Spalte – Danmaku, Untertitel und Cover-Übersetzung: jeder Knopf ruht klein, wächst beim Laden und kehrft nach Abschluss mit grünem Häkchen zur Kleinform zurück, und die Spalte weicht weich aus, sobald einer wächst; der Cover-Ring zeigt nun den echten Download-Fortschritt; die Danmaku-Vorübersetzung bekommt einen eigenen Knopf, der alle Segmente vorab holt und stapelweise übersetzt; und UP-Namen verwenden jetzt immer die Langform des Glossars, während Titel und Kommentare bei der Kurzform bleiben – für スターレイル wurde zusätzlich die eigenständige Kurzform スタレ ergänzt. 3.7.8 macht weiter: Das Erststart-Popup erklärt jetzt alle drei Cover-Knöpfe (Danmaku, Untertitel, Cover-Übersetzung); beim Öffnen eines Videos startet die Danmaku-Vorübersetzung automatisch neben den Untertiteln; die Danmaku-Vorübersetzung nutzt denselben gleichzeitigen Worker-Pool wie die Untertitel und ist damit genauso schnell; und Cover-Erkennungsanfragen werden in Klick-Reihenfolge serialisiert, mit automatischen Wiederholungen bei Gateway-Timeouts – mehrere Cover hintereinander drücken zerstört nicht mehr die ersten, und 504er heilen sich selbst. 3.7.9 fügt Rechts-nach-links-Spiegelung hinzu: Ist die Oberflächensprache rechtsläufig (Arabisch, Hebräisch, Uigurisch und weitere arabische/hebräische Schriftvarianten), spiegeln sich Navigation, Listen, Ausrichtung und Abstände automatisch; Bilder und Videoinhalte werden nie gespiegelt — die Player-Zeitleiste bleibt links-nach-rechts. Auch die Übersetzen-Knopfspalte und Abzeichen auf Covern wechseln die Seite passend zur Leserichtung. 3.7.10 fügt Rechts-nach-links-Spiegelung hinzu: Ist die Oberflächensprache rechtsläufig (Arabisch, Hebräisch, Uigurisch und weitere arabische/hebräische Schriftvarianten), spiegeln sich Navigation, Listen, Ausrichtung und Abstände automatisch; Bilder und Videoinhalte werden nie gespiegelt — die Player-Zeitleiste bleibt links-nach-rechts. Auch die Übersetzen-Knopfspalte und Abzeichen auf Covern wechseln die Seite passend zur Leserichtung. 3.7.11 ordnet die drei Cover-Knöpfe horizontal statt vertikal an – Cover-Übersetzung an der Ecke verankert, dann Untertitel, dann Danmaku – mit derselben Wachstums-/Zurück-Animation und Ausweich-Anpassung nun entlang der Reihe; die RTL-Spiegelung folgt der Leserichtung. 3.7.12 fügt den drei Cover-Knöpfen Abbrechen/Rückgängig hinzu: Ein erneutes Tippen während des Ladens stoppt den Auftrag, löscht alles Geschriebene und setzt den Knopf zurück; ein fertiger (grünes Häkchen) lässt sich ebenso widerrufen und aus dem Cache entfernen — auch ein erfolgreicher Auftrag kann zurückgenommen werden. 3.7.12→3.8.0: Danmaku wechseln jetzt direkt vor Ort zur Übersetzung — war die Übersetzung beim Erscheinen noch nicht fertig, springt der Text automatisch auf die Übersetzung, sobald sie im Hintergrund ankommt, ohne die Wiedergabe neu zu starten. Außerdem werden die drei Cover-Knöpfe jetzt horizontal statt vertikal angeordnet (Cover, Untertitel, Danmaku), das Erststart-Popup beschreibt sie links/mitte/rechts, und der canvas_danmaku-Renderer wurde zur Unterstützung des In-Place-Wechsels ins Repo übernommen. 3.8.1 schließt die 3.7-Ära ab: Untertitel Ende-zu-Ende gehärtet, Danmaku vorab übersetzt mit In-Place-Wechsel, Cover-Erkennung mit Abbrechen/Rückgängig, RTL-Spiegelung mit flüssigem Flip-Übergang – und jede Sprache ist jetzt über Eigenname oder englischen Namen auffindbar (auch Uigurisch). 3.8.2 macht Richtungswechsel sicher und die Suche nahtlos: Die Flip-Animation beim Spiegel-Umschalten erzeugt keinen schwarzen Bildschirm mehr — die Ansicht klappt auf die Kante, wechselt dort die Richtung und klappt wieder auf; die frühere Variante, die den Navigator doppelt montierte, wurde ersetzt. Die Sprachauswahl entfernt außerdem unsichtbare Steuerzeichen aus eingefügtem Text, richtet die Suchzeile nach der Eingabe aus und aktualisiert die Ergebnisse in Echtzeit — ohne Enter. 3.8.3 holt das Markenicon dorthin zurück, wo es leer geworden war: Der Avatar „alle Uploader“ der Dynamiken und das Logo im Speichern-Panel zeigen wieder das echte farbige Logo statt der einfarbigen Scheibe, die beim Austausch der alten Umriss-Grafik gegen die flächige Verlaufsgrafik übrig blieb. 3.8.4 übernimmt von saukhoai beigetragene Härtung: Das Warten auf eine Übersetzungs-Proxy-Route bricht nach 60 Sekunden ab, und verlassene Wartende können freigegebene Slots nicht mehr stehlen. Ein neuer Schalter (standardmäßig an) entscheidet, ob die Wiedergabe bei realzeitlichem Untertitel-Pufferrückstand pausieren darf, und nach Aufgabe eines Untertitel-Jobs läuft die Wiedergabe immer weiter. Elf weitere feste UI-Texte erhielten Offline-Übersetzungen ins Vietnamesische. 3.8.5 lädt die Untertitelübersetzung ab dem Zeitpunkt, an dem die Wiedergabe tatsächlich beginnt: Beim Fortsetzen eines langen Videos muss nicht mehr erst alles davor übersetzt werden, und ab 0:00 bleibt alles wie bisher. 3.8.6 lässt das HiRes-Abzeichen in der Player-Leiste endlich tatsächlich erscheinen: Es las bisher ein gewöhnliches Feld innerhalb eines reaktiven Blocks, was GetX rundheraus ablehnt, sodass es seit 3.7.0 nie gerendert wurde. Jetzt sitzt es links der Segmentinformationen, blendet sich aus, wenn das Video keine HiRes-Tonspur hat, leuchtet während HiRes-Audio und lässt sich antippen, um zwischen HiRes und der besten Nicht-HiRes-Spur zu wechseln. 3.8.7 — Tâi-gí. 3.8.8 behebt das Sprachsuchfeld — die Liste filtert jetzt beim Tippen, ohne dass die Eingabetaste gedrückt werden muss — und fügt zwei Schalter hinzu, mit denen sich die automatische Untertitel- und Danmaku-Übersetzung beim Öffnen eines Videos steuern lässt (beide standardmäßig an). 3.8.9 vervollständigt die beiden Schalter für automatische Übersetzung (beim Ausschalten stoppen wirklich alle automatischen Untertitel- und Danmaku-Übersetzungen), trennt die Übersetzungscaches nach Sprache und beschleunigt die Danmaku-Übersetzung. (3.8.10, 3.8.11, 3.8.12) (3.8.10, 3.8.11, 3.8.12, 3.8.13) In 3.8.12 / 3.8.13 / 3.8.14 / 3.9.0 / 3.9.1 wurden PiliNara-Funktionen übernommen: `#tag`-Suche, ausblendbare Seitenleisten-Beschriftungen, Lautstärke per Mausrad, av-Nummer, Jumpscare-Segmente, fortlaufendes Zurückspulen, Videodrehung, SuperChat-Transparenz, Abbrechen des KI-Chats, Abschnittsleiste. **3.9.2 / 3.9.3** erweitert das eingebaute Glossar von 11.742 auf 19.482 Einträge (Genshin 5.788, Star Rail 2.823, ZZZ 1.815, Wuthering Waves 1.443), ergänzt Spielnamen für alle 15 Tabellen (异环 heißt auf Japanisch jetzt NTE) und gibt jeder neuen Tabelle eine Lang- und eine Kurzform.

## Verzeichnis der übernommenen Funktionen (aus PiliNara / PiliPlus)

Alles Folgende stammt aus PiliNara (und mittelbar aus PiliPlus); PiliBabel legt die KI-Übersetzungsschicht darüber.

**Oberfläche und Plattformanpassung**
- [x] App je Plattform umbenannt, damit mehrere Clients koexistieren können (PiliBabel installiert sich neben PiliNara)
- [x] Flutter-Rendering im Xiaomi-HyperOS-Minifenster behoben ([#161086](https://github.com/flutter/flutter/issues/161086), via [venera#467](https://github.com/venera-app/venera/pull/467)); prädiktive Zurück-Animation unter Android
- [x] Reihenfolge und Anzahl der „Ich“-Karten anpassbar; Vorschau der Verlaufskarten und Abschnitt „Später ansehen“
- [x] Automatischer Wechsel der Seitenleiste mit einstellbarer Auslösebreite; Bildkopie per langem Druck / Rechtsklick; große MD3E-Stilüberarbeitung

**Schriftsystem** — ein einheitlicher Importpool mit Deduplizierung über Inhalts-Hashes, Danmaku-Schriften im selben Pool, `loadFontFromList` mit ttc-Unterstützung und reine ASCII-Namen für Schriftfamilien.

**Wiedergabe, Minifenster und Qualität** — Minifenster in der App (ziehen, skalieren, SponsorBlock-Sprung, automatisches System-PIP, Selbstrettungsleiste für Livestreams), gleichzeitige Audiowiedergabe, Lautstärke in der App bis 200 %, eigener Video-CDN-Domain und regionale Knotenauswahl mit Latenzmessung, getrennte Standardqualität für Halb- und Vollbild, Sperren der Geschwindigkeit per Wisch nach oben, Tastatursteuerung auf Tablets, SuperChat-Zeitstempel im Livestream, Herzschlag für die Fan-Intimität im Livestream.

**Untertitel, KI und Offline** — zweisprachige Untertitel mit unabhängigem Stil des Zweituntertitels, KI-Untertitelanalyse (eigener OpenAI-kompatibler Endpunkt, Sprung zum Zeitstempel, Vorlagen, gespeicherte Unterhaltungen, sanfter Rückfall ohne Untertitel), WEBVTT-/SRT-Export, Doppelansicht des Offline-Caches mit Ordnerverwaltung und Metadaten-Persistenz, Export von Downloads in den öffentlichen Download-Ordner (Android).

**Danmaku und Blockierung** — verbesserte Skalierung zusammengeführter Danmaku (im Stil von [Pakku.js](https://github.com/xmcp/pakku.js)), listenbasierte visuelle Regex-Blockierung mit Import und Export, SponsorBlock-Sprung in den Abschnitt, Hochenergie-Fortschrittsbalken mit Gauß-Kern.

**Filterung von Empfehlungen / Dynamik / Kommentaren** — Schlüsselwörter für Titel / UP / Kanal, Dauer, Aufrufzahl, Like-Rate, Ausnahme für gefolgte UPs, Filter für nicht autorisierte / nur für Abonnenten zugängliche Videos, geteilte Whitelist, kommerzielle / nicht autorisierte Dynamik, Ausnahme für eigene und angeheftete Kommentare des UPs, zusammengeführter App-+-Web-Feed.

**Dynamik, Suche und Nutzerinfo** — eigene Notizen zu UPs, Notiz ersetzt den Nicknamen an 13 Stellen, unabhängige Sortierung verschachtelter Antworten, lokaler Stichwortsuchfilter, Sprung über b23.tv-Kurzlinks, Abzeichen „nur für Abonnenten“, Schalter zum Ausblenden des Empfehlungsgrunds, Anzeige der Münz-EP.

**Livestream-Verbesserungen** — Panel zum Anlegen des Fan-Medaillons, DLNA-Casting mit Vorrang für HLS, Anzeige der SuperChat-Zeit, untere Bedienleiste des Minifensters zur Selbstrettung.

**Systemintegration und Desktop** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), neu geschriebene Handhabung des Audiofokus.

<details>
<summary>Vollständige ursprüngliche Funktionsliste (wortgetreu aus PiliNara — zum Aufklappen klicken)</summary>

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

## Haftungsausschluss

PiliBabel ist ein persönliches, aus Interesse betriebenes Projekt und wird **nur zum Lernen und Testen** bereitgestellt; bitte lösche es innerhalb von **24 Stunden** nach dem Download.

- PiliBabel ist ein **inoffizieller Client von Drittanbietern** und **weder mit bilibili verbunden noch von bilibili unterstützt oder gesponsert**.
- Alle APIs stammen aus offiziellen öffentlichen Endpunkten; **es werden keine geknackten, überprivilegierten oder Paywalls umgehenden Inhalte** bereitgestellt.
- **Die KI-Übersetzung läuft auf einem Modell-Endpunkt von Drittanbietern.** Standardmäßig ist das bilibilis eigener kostenloser öffentlicher Index-Translate-Dienst; wechselst du zu deiner eigenen API, ist es der von dir eingerichtete Endpunkt. Qualität und Konformität der Übersetzung liegen beim Nutzer und beim gewählten Modellanbieter; dieses Projekt **hostet kein Modell und stellt keinen API-Schlüssel bereit**.
- Respektiere das Urheberrecht und bilibilis Nutzungsbedingungen. Nutze es verantwortungsvoll.

Mit Respekt für die ursprünglichen und vorgelagerten Autorinnen und Autoren und ihr Engagement für Open Source:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — das direkte Elternprojekt von PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — die quelloffene Übersetzungsmodell-Familie, die die eingebaute Engine aufruft

Sollte ein Inhalt deine Rechte verletzen, kontaktiere uns bitte zur Entfernung.

<br/>

## Lizenz

PiliBabel steht unter der **GNU General Public License v3.0 (GPL-3.0)** — dieselbe Lizenz wie PiliNara, PiliPlus und PiliPala. Als abgeleitetes Werk **muss PiliBabel ebenfalls unter GPL-3.0 verbreitet werden**: Du darfst es frei nutzen, studieren, teilen und verändern, sofern du dieselbe Lizenz, die Urheberrechtshinweise und diesen Lizenztext beibehältst. Siehe [`LICENSE`](./LICENSE).

Komponenten von Drittanbietern (Flutter-Pakete, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio) usw.) bleiben unter ihren eigenen Lizenzen.

Die mitgelieferte Schrift **霞鹜文楷** steht separat unter der **SIL Open Font License 1.1**; ihr Lizenztext wird der App als `assets/fonts/LXGWWenKai-OFL.txt` beiliegen.

<br/>

## Danksagung

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — bilibilis quelloffene Übersetzungsmodell-Familie und der kostenlose öffentliche Endpunkt hinter der eingebauten Engine
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — die quelloffene chinesische Schrift, die der App beiliegt, unter der SIL Open Font License 1.1
- und weitere
- Inspiriert von bilibilis offizieller „KI-Oberflächenübersetzung“.
<br/>

---

> **Hinweis zur Dokumentsprache.** Diese README und ihre Übersetzungen werden mit Hilfe von KI-Übersetzungswerkzeugen erstellt und gepflegt; bei abweichenden Formulierungen ist die englische Fassung maßgeblich.
