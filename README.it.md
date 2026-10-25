<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Un client Bilibili di terze parti con traduzione basata su IA.</b></p>
    <p>Babel — abbattere la barriera linguistica, così che chiunque possa godersi bilibili nella propria lingua.</p>
    <p>Unisce l'inventario ufficiale di 151 lingue di bilibili con altre 6 che non copre - cinese tradizionale, wu semplificato e tradizionale, hokkien della Cina continentale e di Taiwan, e zhuang.</p>
    <p>La traduzione funziona subito, così com'è, sul modello gratuito di bilibili stesso — nessuna chiave API richiesta.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.nan.md">台語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.mn.md">Монгол</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.pt.md">Português</a> · <a href="README.bn.md">বাংলা</a> · <a href="README.th.md">ไทย</a> · <a href="README.tr.md">Türkçe</a> · <b>Italiano</b> · <a href="README.fa.md">فارسی</a> · <a href="README.fil.md">Filipino</a> · <a href="README.ur.md">اردو</a> · <a href="README.mr.md">मराठी</a> · <a href="README.te.md">తెలుగు</a> · <a href="README.ta.md">தமிழ்</a> · <a href="README.pa.md">ਪੰਜਾਬੀ</a> · <a href="README.gu.md">ગુજરાતી</a> · <a href="README.ha.md">Hausa</a> · <a href="README.sw.md">Kiswahili</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.my.md">မြန်မာ</a> · <a href="README.pl.md">Polski</a> · <a href="README.is.md">Íslenska</a> · <a href="README.nb.md">Norsk</a> · <a href="README.fi.md">Suomi</a> · <a href="README.sv.md">Svenska</a> · <a href="README.da.md">Dansk</a> · <a href="README.be.md">Беларуская</a> · <a href="README.ug.md">ئۇيغۇرچە</a> · <a href="README.kk.md">Қазақша</a> · <a href="README.bo.md">བོད་ཡིག</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Home" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dinamiche" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Il mio profilo" />
</div>

<br/>

> **Avvertenza.** PiliBabel è un client **non ufficiale, open-source, di terze parti**. **Non è affiliato, appoggiato né sponsorizzato** da bilibili / bilibili Inc. Tutte le API sono raccolte dagli endpoint pubblici ufficiali; **nessun contenuto a pagamento viene sbloccato o craccato**. Si prega di leggere per intero le sezioni [Avvertenza](#avvertenza) e [Licenza](#licenza).

## Che cos'è PiliBabel?

PiliBabel è un **fork di terze parti e indipendente, costruito sopra [PiliNara](https://github.com/Starfallan/PiliNara)**, e eredita tutto ciò che PiliNara eredita:

```
bilibili (API pubbliche ufficiali)
        ▲
   PiliPala / PiliPalaX        — il progetto originale
        ▲
   PiliPlus                    — fork attivo
        ▲
   PiliNara                    — fork di PiliPlus (ritocchi personali)
        ▲
   PiliBabel  ← sei qui        — fork di PiliNara
```

PiliBabel conserva **ogni funzionalità di PiliNara / PiliPlus** (vedi il [registro delle funzionalità ereditate](#registro-delle-funzionalità-ereditate-da-pilinara--piliplus) verso il fondo) e aggiunge **due capacità di punta che i client upstream non hanno**:

> **Traduzione IA di interfaccia e contenuti** — l'intera app (etichette dell'interfaccia, titoli dei video, nomi degli UP, commenti, dinamiche, feed e persino i danmaku in diretta, i commenti volanti che scorrono sul video) viene resa nella lingua che **tu** scegli.

E dalla versione 1.0 lo fa **immediatamente, senza configurazione**: il modello di traduzione è **integrato**. bilibili ha reso open-source la propria famiglia di modelli di traduzione, [Index-Translate](https://github.com/bilibili/Index-Translate), e la serve da un endpoint pubblico gratuito. PiliBabel viene distribuito già puntato a esso, quindi la traduzione funziona appena installi l'app — senza registrazione, senza chiave, senza bolletta. Se preferisci usare il tuo modello, la strada della API propria è ancora lì, a un tocco di distanza.

> **L'audio in cuffia che resta davvero sincronizzato** — con cuffie Bluetooth o con filo, il suono non resta più indietro rispetto all'immagine. L'app ufficiale ci riesce; PiliNara e PiliPlus no, così come vengono distribuiti. PiliBabel ora chiede a mpv prima **AudioTrack**, che *misura* la latenza dell'uscita audio nello stesso modo in cui lo fa il client ufficiale, invece di **OpenSL ES**, che la *stima* soltanto.

## Funzionalità principali

- **Audio in cuffia sincronizzato.** Il player ora usa di default il backend **AudioTrack** di mpv (ordine `audiotrack,aaudio,opensles`) invece di **OpenSL ES**. AudioTrack riporta una latenza di uscita *misurata* — legge il conteggio dei frame riprodotti e il timestamp di presentazione del dispositivo — che è esattamente come l'app ufficiale di bilibili e il `MediaSync` di Android stesso tengono insieme immagine e suono. OpenSL ES la *stima* soltanto, quindi con le cuffie Bluetooth l'orologio dell'audio derivava e l'immagine veniva mostrata in anticipo. Nei test, il ritardo è praticamente sparito. Riordinalo quando vuoi in Impostazioni → Video → Dispositivo di uscita audio.

- **Traduzione IA, ovunque.** Schede di navigazione, schede video, pagine di dettaglio, commenti, dinamiche e le superfici Profilo / Preferiti / Cronologia / Messaggi / Ricerca — una passata globale copre **~1.650+ stringhe di interfaccia**, più i contenuti dinamici (titoli, nomi degli autori, conteggi delle azioni).
- **Due motori, un interruttore.** *Integrato* (predefinito) usa l'endpoint gratuito ufficiale **Index-Translate-35B-A3B** di bilibili — niente da configurare. *API propria* mantiene il comportamento precedente: puntalo su qualsiasi endpoint compatibile OpenAI `/chat/completions` con il tuo URL base / chiave / modello. La funzione di riepilogo video IA e quella di traduzione IA hanno ancora endpoint e impostazioni **completamente indipendenti**, entrambe in un'unica pagina **"Funzioni IA"**.
- **Un'unica lista di lingue per entrambi i motori.** La lista delle lingue di destinazione non è divisa per motore — viene offerta la stessa lista qualunque motore tu scelga. Unisce le **151 lingue** del modello ufficiale di bilibili con **altre 6 che non copre** — cinese tradizionale, wu semplificato e tradizionale, hokkien della Cina continentale e di Taiwan, e zhuang. Le varianti regionali e di scrittura restano **voci separate** invece di essere fuse — l'arabo marocchino / egiziano / najdi / levantino sono scelte ciascuna a sé, così come serbo, uzbeko e urdu cirillico contro latino.
- **Onestà sulla copertura.** Le lingue dentro l'inventario ufficiale sono coperte dal modello di bilibili. Le poche fuori — cinese tradizionale, wu semplificato e tradizionale, hokkien della Cina continentale e di Taiwan e zhuang — restano comunque nella lista, contrassegnate come tali, così sai a colpo d'occhio che un risultato migliore potrebbe richiedere il tuo modello.
- **Tradotto una volta, e resta fisso.** Ogni stringa sorgente viene tradotta **esattamente una volta**; il risultato è persistito localmente e **mai ritradotto** quando riapri una schermata — lo stesso principio del client ufficiale, per traduzioni stabili e prevedibili.
- **Interruttore Originale ⇄ Traduzione per ogni commento** (una piccola icona, non una parola cinese). `@menzioni / [emoji] / #argomenti# / link` vengono preservati come token, e **i commenti contenenti hyperlink si traducono comunque mantenendo il link cliccabile**.
- **Traduzione dei danmaku (弹幕)** — un interruttore indipendente nella riga di controlli in alto a destra del player, **spento di default** e protetto da una conferma il cui testo è esso stesso tradotto. Una volta attivato, i danmaku davanti alla testina di riproduzione vengono pre-tradotti in **blocchi di ~15 secondi** (saltare a metà video è gestito correttamente, non dall'inizio), così la traduzione è di solito pronta quando il commento scorre sullo schermo.
- **Interruttore della modalità di ragionamento** (`enable_thinking`) per qualità contro velocità, più i pulsanti **"prova traduzione"** e **svuota cache** nelle impostazioni.
- **Cambio lingua rapido**: richieste a lotti con concorrenza limitata su una cache persistente; cambiare lingua ricostruisce forzatamente la schermata corrente una volta, così non resti a fissare testo non tradotto. Disattivare la traduzione IA riporta tutta l'interfaccia al testo originale e non emette alcuna richiesta.
- **Onboarding al primo avvio.** La prima volta che apri l'app, una finestra di dialogo in inglese propone di attivare la traduzione. Accettandola si attiva la traduzione, si seleziona il modello integrato, si apre la pagina delle impostazioni IA e viene subito chiesta la lingua che vuoi — così un nuovo utente passa dall'installazione all'app tradotta in due tocchi.
- **Riproduzione che funziona in tutto il mondo.** PiliBabel seleziona il bordo oltreoceano (globale **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) che il `playurl` instradato geograficamente di bilibili già offre, invece di bloccarti su un nodo della Cina continentale (Aliyun/Shenzhen) — così gli utenti fuori dalla Cina continentale non si bloccano più ("l'audio continua, il video si congela"). Puoi comunque fissare manualmente un CDN nelle Impostazioni.
- **Una pagina "Tema e colore", in stile Material You.** Chiaro / scuro / segui-il-sistema si scelgono tra **tre schede di anteprima dal vivo** — ognuna rende una miniatura della vera interfaccia nei colori esatti che quella modalità applicherebbe (la scheda "segui il sistema" è divisa in diagonale, chiaro sopra scuro). Sotto di esse: **colore dinamico** (preso dallo sfondo di sistema dove il dispositivo lo supporta), **scuro ad alto contrasto** (superfici nero puro, più riposante per gli occhi di notte) e **player sempre scuro**. La metà colore mantiene l'intera tavolozza FlexScheme — **19 colori seme** più uno **"stile di tavolozza"** separato che decide come ogni colore dei contenitori deriva dal seme, indipendentemente dal seme che scegli.
- **LXGW WenKai inclusa nell'app.** Il carattere **LXGW WenKai (霞鹜文楷)** è **incluso e impostato come predefinito** — un carattere cinese caldo e molto leggibile che hai appena installi l'app, invece di cercarlo in un selettore. Si applica a tutta l'interfaccia *e* ai danmaku. Puoi comunque tornare al carattere di sistema, scegliere qualsiasi carattere di sistema installato o importare il tuo `.ttf` / `.otf` / `.ttc`; un carattere che avevi esplicitamente scelto prima viene conservato attraverso l'aggiornamento. Peso e dimensione restano regolabili come prima.

## Cache audio offline e download in cartella locale (esclusivo di PiliBabel)

Due capacità che PiliNara / PiliPlus a monte non hanno — entrambe pensate per possedere davvero i tuoi media offline.

### Cache audio (cache offline solo audio)

- **La traccia, non il video.** Una voce *Cache audio* sta subito sotto *Cache video* nel menu della pagina del video, più un pulsante dedicato per la cache audio nella barra in alto della pagina video in ascolto.
- **Scegli il livello di qualità.** Hi-Res senza perdita, Dolby Atmos, 192K, 132K o 64K — la stessa lista predefinita usata dal selettore qualità video.
- **Contenitore originale, nessuna transcodifica.** Il file viene scritto esattamente come il CDN lo serve: `m4a`, `mp3`, `flac`, `wav`, `aac` o `ogg`.
- **Un modulo suo.** La pagina cache è divisa in *Video in cache* / *Audio in cache* e ricorda in quale modulo eri l'ultima volta.
- Toccare un elemento audio in cache apre subito il player audio; gli elementi si eliminano uno a uno o in blocco.

### Download in cartella locale

- **Una voce di menu sua.** *Download in cartella locale* è una voce separata nel menu della pagina del video, proprio sotto *Cache audio* — fare cache dentro l'app e salvare in una cartella sono due azioni diverse.
- **Scaricare video o scaricare audio.** La voce chiede prima quale dei due, poi chiede il livello di qualità (selettore qualità video / audio).
- **La tua cartella, le tue regole.** Scegli qualsiasi cartella tramite il gestore file di sistema (Impostazioni → *Download in cartella locale*) e cambiala o svuotala quando vuoi. Se non ne hai ancora scelta una, il selettore cartelle si apre al momento.
- **File riproducibili direttamente.** Il video viene scaricato come unico flusso muxato (`fnval=1`), quindi ciò che arriva su disco è un normale MP4 da dare a qualsiasi player — nessun flusso secondario da ricucire.
- **L'audio mantiene il suo formato originale** — nessuna transcodifica, esattamente come la cache in-app.
- I file prendono il nome dal titolo del video e non sovrascrivono mai un download esistente.

## I due motori di traduzione

| | Integrato (predefinito) | API propria |
|---|---|---|
| Modello | **Index-Translate-35B-A3B** di bilibili | qualsiasi cosa compatibile OpenAI |
| Endpoint | `index-translate.bilibili.com/v1` | il tuo URL base |
| Chiave API | **non necessaria** | la tua |
| Costo | gratuito | ciò che il tuo provider addebita |
| Richieste | una stringa per richiesta | a lotti (≤ 16 per richiesta) |
| Lingue extra | — | qualsiasi lingua che il tuo modello conosca |

**Perché una richiesta per stringa sul motore integrato.** Index-Translate è uno *specialista* della traduzione, e la convenzione di chiamata documentata dai suoi autori è un modello a elemento singolo ("traduci il testo seguente in X, restituisci solo la traduzione"). PiliBabel quindi invia una stringa per richiesta su questo motore invece del prompt a lotti con lista numerata/array JSON che usa per le configurazioni con API propria. L'endpoint è gratuito, quindi non c'è nulla da guadagnare scommettendo su output in blocco — è uno scambio deliberato di qualche richiesta in più per molti meno modi di fallire.

**Aggiornamento dalla 0.3.x.** Le tue impostazioni della API propria — URL base, chiave e modello — sono **lasciate esattamente come le hai configurate**. La selezione del motore torna semplicemente predefinita sul modello integrato, quindi al primo avvio dopo l'aggiornamento sarai sul modello gratuito di bilibili; apri *Impostazioni → IA → Funzioni IA → motore di traduzione* e torna ad *API propria* per rientrare immediatamente nella configurazione precedente.

## Come funziona la traduzione IA dell'interfaccia (tecnico)

Il repository **non ha un livello di risorse i18n / ARB** — le stringhe dell'interfaccia sono cinese hardcoded. Invece di riscrivere ogni widget, PiliBabel aggiunge sopra un sottile livello di traduzione:

1. **Un wrapper globale di ricerca.** `lib/services/ui_translate/` espone un `uiTx(String src)` di livello superiore. Il testo dei widget che era `Text('中文')` diventa `Text(uiTx('中文'))`. Un **codemod** scriptato l'ha applicato a tutto il progetto (`tool/ui_translate_*.py`) — circa **223 file / ~1.650+ stringhe** — rimuovendo automaticamente la parola chiave `const` ormai non valida dove necessario (inclusi i generici come `const X<T>(...)` e i nomi puntati come `const Positioned.fill(...)`, e convertendo le dichiarazioni lista/mappa `static const` in `static final`).
2. **Un nucleo `GetxService`** (`ui_translate_service.dart`):
   - una cache persistente **sorgente → traduzione** (basata su GetStorage), così ogni stringa è tradotta una volta e riutilizzata per sempre;
   - `tx()` legge prima un `RxInt revision`, poi decide: se disattivato → restituisce l'originale; se la destinazione è il **cinese semplificato (`zh-CN`)**, restituisce l'originale senza richiesta API (i contenuti sorgente di bilibili sono nella stragrande maggioranza cinese semplificato). Ogni altra destinazione — incluso cinese tradizionale, cantonese, wu/shanghaiese e hokkien/min nan — passa dal motore configurato; la sola appartenenza alla famiglia cinese non salta la traduzione. Poi serve dalla cache o **accoda**;
   - le stringhe accodate vengono scaricate da un **pool di worker** con **applicazione incrementale per blocco** (ogni blocco restituito fa salire `revision`, così il testo si aggiorna progressivamente), e i risultati sono **persistiti** (con throttling). Dimensione lotto e concorrenza seguono il motore: **1 per richiesta** sul modello integrato, **≤ 16 con ≤ 10 in volo** sulla tua API.
3. **Risoluzione del motore.** `TranslateProvider` (`builtin` / `custom`) decide quale URL, chiave e modello usa il trasporto; per il resto i due motori condividono un solo percorso di codice e una sola lista lingue, quindi cambiare motore è una singola impostazione e mai un insieme di funzioni diverso.
4. **Il trasporto** riusa lo stesso canale **streaming** già verificato del riepilogo video IA — `AiChatService.streamChat` → `{base}/chat/completions` con `stream: true` (compatibile con gateway che supportano solo lo streaming) — esteso così che la traduzione possa usare `apiUrl` / `apiKey` / `model` **propri** e un flag `enable_thinking`. La modifica è **retrocompatibile**, quindi il riepilogo video continua a funzionare invariato.
5. **Le frasi interpolate** usano `uiTxP(template, args)`: un'intera frase con segnaposto `{0}`/`{1}` viene tradotta come un'unica chiave stabile (il prompt chiede al modello di conservare i segnaposto), poi i valori vengono ri-sostituiti — così le stringhe in stile `"共 {0} 条"` si traducono senza stravolgere le parti dinamiche.
6. **Tabella lingue** (`app_language.dart`): ogni `AppLanguage` porta un autonimo di visualizzazione, una stringa prompt `toModel` che codifica le convenzioni di scrittura/regione e un flag che dice se l'inventario ufficiale di bilibili la copre. Le regole di scrittura (semplificato contro tradizionale e le istruzioni di coerenza dialettale) raggiungono il modello solo tramite il prompt, e un passaggio di normalizzazione deterministica sul client corregge poi i glifi sfuggiti.
7. **I commenti** passano da `uiTxComment(text, id)`, mantenendo `@ / [emoji] / #argomento# / link` come token intatti; gli span di rich text che portano link vengono tradotti preservando il riconoscitore di link, e un insieme di id per commento pilota l'interruttore Originale ⇄ Traduzione.
8. **Danmaku** (`danmaku/view.dart`): quando l'interruttore è attivo, un listener di posizione percorre `[playhead, playhead + 15s]` un secondo alla volta e riscalda `uiTx()` sul contenuto di ogni danmaku, così gli elementi sono pre-tradotti prima di arrivare sullo schermo; attivarlo svuota e ridipinge la tela.
9. **Chiavi di archiviazione**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Interfaccia impostazioni**: una sola pagina di primo livello "Funzioni IA" (`lib/pages/setting/ui_translate/`) con blocchi indipendenti per riepilogo video IA e traduzione IA.

**CDN mondiale (`VideoUtils.getCdnUrl`).** Gli URL dello stream sono firmati, e riscrivere l'host di un URL lo fa rifiutare con 403 — quindi la riproduzione non riscrive mai gli host. PiliBabel restituisce l'URL instradato geograficamente che bilibili dà all'IP del client, e quando la lista dei candidati contiene già un bordo oltreoceano (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`) quello è preferito. I download, dove uno scambio di host è sicuro, preferiscono inoltre il bordo globale Akamai e passano al prossimo candidato firmato quando una linea si blocca o rifiuta un resume. I link P2P `/v/resource` grezzi ricadono ancora nel relay esistente per evitare 404.

**Compromessi di progetto / limiti noti.** Poiché le stringhe sono avvolte sul posto invece che estratte in risorse, alcuni parametri stringa fuori da `Text` e alcuni span di rich text vengono ancora riempiti incrementalmente. Le stringhe che fanno anche da **chiavi logiche** (confrontate con `==`, usate come nomi di scheda come `简介`, o etichette di enum usate negli switch) volutamente **non** vengono avvolte in blocco, per non rompere i comportamenti. La traduzione dei danmaku è best-effort su una tela che scorre — con danmaku estremamente densi puoi vedere brevemente l'originale prima che arrivi la traduzione. La traduzione richiede rete; senza, le destinazioni non cinesi semplicemente non hanno effetto. L'endpoint integrato è un servizio pubblico gratuito gestito da bilibili — se mai fosse limitato o indisponibile, l'app te lo dice e puoi passare alla tua API.

## Compilazione e verifica

L'app è costruita con un SDK Flutter patchato più i pacchetti patchati `material_ui` / `cupertino_ui` tramite `lib/scripts/patch.ps1` e `lib/scripts/build.ps1` (esattamente come PiliNara / PiliPlus). GitHub Actions produce un **APK di debug** a ogni push (`.github/workflows/ui-translate-debug.yml`), e **pubblicare un tag `v*` compila e pubblica automaticamente artefatti Android, Windows e Linux** (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Piattaforme
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

PiliBabel distribuisce build **Android (APK), Windows e Linux** dai Releases; iOS/Pad non sono ancora pacchettizzati in questo fork.

<br/>

## Download

Prendi una build dai **Releases**, oppure clona il repository e compila in locale.

### Arch Linux

Grazie a [@nlsdt](https://github.com/nlsdt) per il pacchetto (la ricetta PiliNara vale anche per PiliBabel).

```bash
sudo pacman -S pilinara      # tramite il repository Arch Linux CN
paru -S pilinara-bin         # o tramite AUR: pilinara-bin (precompilato) / pilinara (sorgenti)
```

<br/>

## Registro delle funzionalità ereditate (da PiliNara / PiliPlus)

Tutto ciò che segue arriva da PiliNara (e, per transitività, PiliPlus); PiliBabel aggiunge sopra il livello di traduzione IA.

**Interfaccia e adattamento alla piattaforma**
- [x] App rinominata per piattaforma così che più client possano coesistere (PiliBabel si installa accanto a PiliNara)
- [x] Corretto il rendering di Flutter sotto la mini-finestra Xiaomi HyperOS ([#161086](https://github.com/flutter/flutter/issues/161086), via [venera#467](https://github.com/venera-app/venera/pull/467)); animazione di back predittivo su Android
- [x] Ordine/numero delle schede "Profilo" personalizzabili; anteprima sulle schede cronologia e sezioni "guarda dopo"
- [x] Cambio automatico sidebar con larghezza di attivazione configurabile; copia immagine da long-press / clic destro; grande rinfrescata dello stile MD3E

**Sistema di caratteri** — un pool di importazione unificato con deduplicazione per hash del contenuto, caratteri danmaku fusi nello stesso pool, `loadFontFromList` con supporto ttc e nomi di famiglia hash in ASCII puro.

**Riproduzione, mini-finestra e qualità** — mini-finestra in-app (trascina, ridimensiona, skip SponsorBlock, PIP di sistema automatico, barra di auto-soccorso nelle live), riproduzione audio simultanea, volume in-app fino al 200%, dominio CDN video personalizzato e selezione nodo regionale con test di latenza, qualità predefinita separata mezzoschermo/schermo intero, blocco velocità con swipe verso l'alto, controllo da tastiera su tablet, timestamp SuperChat in diretta, heartbeat live per l'intimità coi fan.

**Sottotitoli, IA e offline** — sottotitoli bilingue con stile indipendente del sottotitolo secondario, analisi sottotitoli IA (endpoint personalizzato compatibile OpenAI, salto per timestamp, template, conversazioni persistite, fallback morbido senza sottotitoli), export WEBVTT/SRT, vista doppia della cache offline con gestione cartelle e persistenza dei metadati, esportazione download nella cartella Download pubblica (Android).

**Danmaku e blocco** — scalamento migliorato dei danmaku uniti (in stile [Pakku.js](https://github.com/xmcp/pakku.js)), blocco visuale basato su regex a liste con import/export, skip SponsorBlock del seek-dentro-segmento, barra di avanzamento alta energia a kernel gaussiano.

**Filtraggio raccomandati / dinamiche / commenti** — parole chiave titolo/UP/canale, durata, conteggio visualizzazioni, tasso like, esenzione UP seguiti, filtraggio non autorizzati/solo a pagamento, whitelist condivisa, dinamiche commerciali/non autorizzate, esenzioni commento-dell'UP e commento fissato, modalità feed unito App+Web.

**Dinamiche, ricerca e info utente** — note personalizzate per gli UP, nota-sostituisce-nickname su 13 slot nome, ordinamento indipendente dei commenti annidati, filtro locale per parola chiave nella ricerca, salto link brevi b23.tv, badge solo a pagamento, interruttore nascondi-motivo-raccomandazione, visualizzazione XP monete.

**Migliorie alle live** — pannello per indossare le medaglie fan, cast DLNA con preferenza HLS, visualizzazione tempo SuperChat, barra controlli in basso della mini-finestra per l'auto-soccorso.

**Integrazione sistema e desktop** — SMTC su Windows, MPRIS su Linux (`audio_service_mpris`), gestione audio-focus ricostruita.

<details>
<summary>Elenco completo originale di funzioni/checklist (verbatim, da PiliNara — clicca per espandere)</summary>

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

## Avvertenza

PiliBabel è un progetto personale, mosso da interesse, fornito **solo per studio e test**; si prega di eliminarlo entro **24 ore** dal download.

- PiliBabel è un client **di terze parti, non ufficiale** e **non è affiliato, appoggiato né sponsorizzato da bilibili**.
- Tutte le API sono raccolte da endpoint pubblici ufficiali; **nessun contenuto craccato, sovraprivilegiato o che scavalca paywall** viene fornito.
- **La traduzione IA gira su un endpoint modello di terze parti.** Di default si tratta del servizio pubblico gratuito Index-Translate di bilibili stesso; se passi alla tua API, è l'endpoint che hai configurato. Qualità e conformità della traduzione sono responsabilità dell'utente e del provider del modello scelto; questo progetto ospita **nessun modello e nessuna chiave API**.
- Rispetta il diritto d'autore e i Termini di servizio di bilibili. Usa con responsabilità.

Con rispetto verso gli autori originali e a monte per la loro dedizione open-source:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — il progetto padre diretto di PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — la famiglia di modelli di traduzione open-source che il motore integrato chiama

Se qualsiasi contenuto viola i tuoi diritti, contattaci per la rimozione.

<br/>

## Licenza

PiliBabel è concesso in licenza sotto la **GNU General Public License v3.0 (GPL-3.0)** — la stessa licenza di PiliNara, PiliPlus e PiliPala. Essendo un lavoro derivato, **anche PiliBabel deve essere distribuito sotto GPL-3.0**: sei libero di usarlo, studiarlo, condividerlo e modificarlo, a condizione di mantenere la stessa licenza, gli avvisi di copyright e questo testo di licenza. Vedi [`LICENSE`](./LICENSE).

I componenti di terze parti (pacchetti Flutter, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), ecc.) rimangono sotto le rispettive licenze.

Il carattere **LXGW WenKai** incluso è concesso separatamente sotto la **SIL Open Font License 1.1**; il testo della licenza è incluso nell'app come `assets/fonts/LXGWWenKai-OFL.txt`.

<br/>

## Ringraziamenti

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — la famiglia di modelli di traduzione open-source di bilibili, e l'endpoint pubblico gratuito dietro il motore integrato
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — il carattere cinese open-source incluso nell'app, sotto la SIL Open Font License 1.1
- e altro
- Ispirato alla "traduzione dell'interfaccia tramite IA" ufficiale di bilibili.
