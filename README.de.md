<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Ein Bilibili-Client von Drittanbietern mit KI-Übersetzung.</b></p>
    <p>Babel — die Sprachbarriere einreißen, damit jede und jeder bilibili in der eigenen Sprache genießen kann.</p>
    <p>Enthält Übersetzungen für 4 Sprachen der ethnischen Minderheiten Chinas und 3 chinesische Dialekte.</p>
    <p>Die Übersetzung läuft direkt nach der Installation über bilibilis kostenloses Modell — kein API-Schlüssel nötig.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.fr.md">Français</a> · <b>Deutsch</b> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a></p>
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

PiliBabel behält **alle Funktionen von PiliNara / PiliPlus** (siehe das [Verzeichnis der übernommenen Funktionen](#verzeichnis-der-übernommenen-funktionen-aus-pilinara--piliplus) weiter unten) und fügt **eine Kernfähigkeit hinzu, die die vorgelagerten Clients nicht haben**:

> **KI-Übersetzung von Oberfläche und Inhalten** — die gesamte App (Beschriftungen, Videotitel, Namen der UP, Kommentare, Dynamik, Feed und sogar Live-Danmaku) erscheint in der Sprache, **die du** wählst.

Und seit 1.0 funktioniert das **direkt nach der Installation**: Das Übersetzungsmodell ist **eingebaut**. bilibili hat sein eigenes Übersetzungsmodell [Index-Translate](https://github.com/bilibili/Index-Translate) quelloffen veröffentlicht und betreibt es über einen kostenlosen öffentlichen Endpunkt. PiliBabel zeigt standardmäßig darauf — die Übersetzung läuft also, sobald du die App installierst: keine Anmeldung, kein Schlüssel, keine Rechnung. Wenn du lieber dein eigenes Modell nutzt, bleibt der Weg über die eigene API bestehen, einen Tipp entfernt.

## Hauptfunktionen

- **KI-Übersetzung, überall.** Navigationsleisten, Videokarten, Detailseiten, Kommentare, Dynamik sowie die Bereiche Ich / Favoriten / Verlauf / Nachrichten / Suche — ein globaler Durchlauf erfasst **rund 1.650 Oberflächentexte**, dazu dynamische Inhalte (Titel, Autorennamen, Zähler).
- **Zwei Engines, ein Schalter.** *Eingebaut* (Standard) nutzt den kostenlosen Endpunkt des offiziellen Modells **Index-Translate-35B-A3B** von bilibili — nichts einzurichten. *Eigene API* behält das bisherige Verhalten: Richte sie auf einen beliebigen OpenAI-kompatiblen `/chat/completions`-Endpunkt mit eigener Basis-URL / Schlüssel / Modell. Die KI-Videozusammenfassung und die KI-Übersetzung haben weiterhin **vollständig getrennte** Endpunkte und Einstellungen und liegen gemeinsam auf einer Seite **„KI-Funktionen“**.
- **Eine Sprachliste, beide Engines.** Die Liste der Zielsprachen ist nicht nach Engine getrennt — es ist dieselbe Liste, egal welche du wählst. Sie vereint die **150 Sprachen** des offiziellen bilibili-Modells mit den **4 Sprachen der ethnischen Minderheiten Chinas und 3 chinesischen Dialekten**, die PiliBabel ergänzt — Tibetisch, Uigurisch, Zhuang und Hmong auf der einen Seite; Kantonesisch, Wu (Shanghai) und Minnan auf der anderen — dazu Chinesisch in traditioneller Schrift. Regionale und schriftbezogene Varianten bleiben **eigene Einträge**, statt zusammengelegt zu werden: Marokkanisches / Ägyptisches / Nadschdi- / Levantinisches Arabisch sind jeweils eigene Optionen, ebenso Serbisch, Usbekisch und Urdu in kyrillischer bzw. lateinischer Schrift.
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
