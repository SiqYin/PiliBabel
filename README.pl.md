<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Klient Bilibili osób trzecich z tłumaczeniem napędzanym przez AI.</b></p>
    <p>Babel — zburzenie bariery językowej, aby każdy mógł korzystać z bilibili we własnym języku.</p>
    <p>Łączy oficjalny spis 151 języków bilibili z 6 kolejnymi, których nie obejmuje - chiński tradycyjny, wu uproszczony i tradycyjny, hokkien kontynentalny i tajwański oraz zhuang.</p>
    <p>Tłumaczenie działa od razu na darmowym modelu samej bilibili — bez potrzeby klucza API.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.nan.md">台語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.mn.md">Монгол</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.pt.md">Português</a> · <a href="README.bn.md">বাংলা</a> · <a href="README.th.md">ไทย</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.it.md">Italiano</a> · <a href="README.fa.md">فارسی</a> · <a href="README.fil.md">Filipino</a> · <a href="README.ur.md">اردو</a> · <a href="README.mr.md">मराठी</a> · <a href="README.te.md">తెలుగు</a> · <a href="README.ta.md">தமிழ்</a> · <a href="README.pa.md">ਪੰਜਾਬੀ</a> · <a href="README.gu.md">ગુજરાતી</a> · <a href="README.ha.md">Hausa</a> · <a href="README.sw.md">Kiswahili</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.my.md">မြန်မာ</a> · <b>Polski</b> · <a href="README.is.md">Íslenska</a> · <a href="README.nb.md">Norsk</a> · <a href="README.fi.md">Suomi</a> · <a href="README.sv.md">Svenska</a> · <a href="README.da.md">Dansk</a> · <a href="README.be.md">Беларуская</a> · <a href="README.ug.md">ئۇيغۇرچە</a> · <a href="README.kk.md">Қазақша</a> · <a href="README.bo.md">བོད་ཡིག</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Strona główna" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dynamika" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Moje" />
</div>

<br/>

> **Zastrzeżenia.** PiliBabel jest **nieoficjalnym, otwartoźródłowym klientem osób trzecich**. **Nie jest powiązany, popierany ani sponsorowany** przez bilibili / bilibili Inc. Wszystkie API pochodzą z oficjalnych publicznych punktów końcowych; **żadne treści płatne nie są odblokowywane ani łamane**. Prosimy przeczytać pełne sekcje [Zastrzeżenia](#zastrzeżenia) i [Licencja](#licencja).

## Czym jest PiliBabel?

PiliBabel to **niezależny fork osób trzecich zbudowany na bazie [PiliNara](https://github.com/Starfallan/PiliNara)** i dziedziczy wszystko, co dziedziczy PiliNara:

```
bilibili (oficjalne publiczne API)
        ▲
   PiliPala / PiliPalaX        — oryginalny projekt
        ▲
   PiliPlus                    — aktywny fork
        ▲
   PiliNara                    — fork PiliPlus (osobiste poprawki)
        ▲
   PiliBabel  ← jesteś tutaj   — fork PiliNara
```

PiliBabel zachowuje **wszystkie funkcje PiliNara / PiliPlus** (zobacz [dziennik odziedziczonych funkcji](#dziennik-odziedziczonych-funkcji-z-pilinara--piliplus) bliżej końca) i dodaje **dwie główne możliwości, których nie mają nadrzędne klienty**:

> **Tłumaczenie interfejsu i treści przez AI** — cała aplikacja (etykiety interfejsu, tytuły filmów, nazwy UP, komentarze, dynamiki, feed, a nawet danmaku na żywo, czyli przewijające się po ekranie komentarze) jest wyświetlana w języku, który **wybierzesz**.

A od wersji 1.0 robi to **od razu, bez konfiguracji**: model tłumaczeniowy jest **wbudowany**. bilibili udostępniła na licencji open source własną rodzinę modeli tłumaczeniowych, [Index-Translate](https://github.com/bilibili/Index-Translate), i serwuje ją z darmowego publicznego punktu końcowego. PiliBabel jest dostarczany z ustawionym wskaźnikiem właśnie na nią, więc tłumaczenie działa od momentu instalacji aplikacji — bez rejestracji, bez klucza, bez rachunków. Jeśli wolisz użyć własnego modelu, ścieżka własnego API wciąż jest dostępna, jedno dotknięcie dalej.

> **Dźwięk w słuchawkach, który naprawdę pozostaje zsynchronizowany** — ze słuchawkami Bluetooth lub przewodowymi dźwięk nie zostaje już w tle za obrazem. Oficjalna aplikacja robi to dobrze; PiliNara i PiliPlus — nie, tuż po instalacji. PiliBabel prosi teraz mpv najpierw o **AudioTrack**, który *mierzy* opóźnienie wyjścia audio tak samo jak oficjalny klient, zamiast **OpenSL ES**, które jedynie je *szacuje*.

## Najważniejsze funkcje

- **Audio w słuchawkach w synchronizacji.** Odtwarzacz domyślnie używa teraz backendu **AudioTrack** mpv (kolejność `audiotrack,aaudio,opensles`) zamiast **OpenSL ES**. AudioTrack zgłasza *zmierzone* opóźnienie wyjścia — odczytuje liczbę odtworzonych ramek i znacznik czasu prezentacji urządzenia — i dokładnie w ten sposób oficjalna aplikacja bilibili oraz systemowy `MediaSync` Androida utrzymują obraz i dźwięk w zgodzie. OpenSL ES tylko je *szacuje*, więc na słuchawkach Bluetooth zegar audio dryfował, a obraz był pokazywany zbyt wcześnie. W testach opóźnienie praktycznie zniknęło. Kolejność można zmienić w dowolnym momencie w Ustawienia → Wideo → Urządzenie wyjścia audio.

- **Tłumaczenie przez AI wszędzie.** Zakładki nawigacji, karty wideo, strony szczegółów, komentarze, dynamiki oraz ekrany Moje / Ulubione / Historia / Wiadomości / Wyszukiwanie — globalne przemiatanie obejmuje **~1650+ ciągów interfejsu**, do tego treści dynamiczne (tytuły, nazwy autorów, liczby akcji).
- **Dwa silniki, jeden przełącznik.** *Wbudowany* (domyślny) korzysta z oficjalnego, darmowego punktu **Index-Translate-35B-A3B** bilibili — nic nie trzeba konfigurować. *Własne API* zachowuje dotychczasowe zachowanie: wskaż dowolny zgodny z OpenAI punkt `/chat/completions` z własnym adresem URL / kluczem / modelem. Funkcja AI-streszczenia wideo i funkcja tłumaczenia AI mają nadal **całkowicie niezależne** punkty końcowe i ustawienia, obie pod jedną stroną **„Funkcje AI”**.
- **Jedna lista języków dla obu silników.** Lista języków docelowych nie jest dzielona według silnika — ta sama lista jest oferowana niezależnie od wybranego silnika. Łączy ona **151 języków** oficjalnego modelu bilibili z **6 kolejnymi, których nie obejmuje** — chiński tradycyjny, wu uproszczony i tradycyjny, hokkien kontynentalny i tajwański oraz zhuang. Warianty regionalne i pismowe są utrzymywane jako **osobne wpisy**, a nie łączone — arabski marokański / egipski / nadżdyjski / lewantyński to osobne wybory, podobnie jak serbski, uzbecki i urdu w wersji cyrylica kontra łacina.
- **Szczerość co do pokrycia.** Języki wewnątrz oficjalnego spisu są obsługiwane przez model bilibili. Te nieliczne poza nim — chiński tradycyjny, wu uproszczony i tradycyjny, hokkien kontynentalny i tajwański oraz zhuang — nadal widnieją na liście, oznaczone jako takie, więc od razu wiesz, że lepszy wynik może wymagać własnego modelu.
- **Tłumaczenie raz, i już zostaje.** Każdy ciąg źródłowy jest tłumaczony **dokładnie raz**; wynik jest zapisywany lokalnie i **nigdy nie jest tłumaczony ponownie** po ponownym otwarciu ekranu — ta sama zasada co w oficjalnym kliencie, dla stabilnych, przewidywalnych tłumaczeń.
- **Przełącznik Oryginał ⇄ Tłumaczenie dla każdego komentarza** (mała ikona, nie chińskie słowo). `@wzmianki / [emoji] / #tematy# / linki` są zachowywane jako tokeny, a **komentarze zawierające hiperłącza nadal są tłumaczone, przy czym link pozostaje klikalny**.
- **Tłumaczenie danmaku (弹幕)** — niezależny przełącznik w rzędzie sterowania w prawym górnym rogu odtwarzacza, **domyślnie wyłączony** i chroniony potwierdzeniem, którego własny tekst jest tłumaczony. Po włączeniu danmaku przed punktem odtwarzania są wstępnie tłumaczone w **paczkach po ~15 sekund** (przeskok do środka jest obsłużony poprawnie, nie od początku), więc tłumaczenie jest zwykle gotowe, nim komentarz wpłynie na ekran.
- **Przełącznik trybu rozumowania** (`enable_thinking`) dla jakości kontra szybkość, plus przyciski **„przetestuj tłumaczenie”** i **wyczyść pamięć podręczną** w ustawieniach.
- **Szybka zmiana języka**: żądania paczkami z ograniczoną współbieżnością na trwałej pamięci podręcznej; zmiana języka raz wymusza przebudowę bieżącego ekranu, więc nie zostajesz wpatrzony w nieprzetłumaczony tekst. Wyłączenie tłumaczenia AI przywraca całemu interfejsowi oryginalny tekst i nie wysyła żadnych żądań.
- **Poradnik przy pierwszym uruchomieniu.** Przy pierwszym otwarciu aplikacji angielskie okno dialogowe proponuje włączenie tłumaczenia. Zaakceptowanie włącza tłumaczenie, wybiera wbudowany model, otwiera stronę ustawień AI i natychmiast pyta, jakiego języka chcesz — więc nowy użytkownik przechodzi od instalacji do przetłumaczonej aplikacji w dwóch dotknięciach.
- **Odtwarzanie działające na całym świecie.** PiliBabel wybiera zagraniczny węzeł brzegowy (globalny **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`), który `playurl` bilibili z routingu geograficznego już oferuje, zamiast przypinać cię do węzła kontynentalnego (Aliyun/Shenzhen) — dzięki temu użytkownicy spoza kontynentalnych Chin nie zawieszają się już („dźwięk leci, obraz się zamraża”). Nadal możesz ręcznie przypiąć CDN w ustawieniach.
- **Strona „Motyw i kolor” w stylu Material You.** Jasny / ciemny / zgodny z systemem wybiera się spośród **trzech kart z podglądem na żywo** — każda renderuje miniaturę prawdziwego interfejsu w dokładnych kolorach, które dany tryw zastosowałby (karta „zgodny z systemem” jest podzielona po przekątnej, jasna nad ciemną). Pod nimi: **kolor dynamiczny** (pobierany z tapety systemowej tam, gdzie urządzenie to obsługuje), **ciemny wysokiego kontrastu** (powierzchnie w czystej czerni, łagodniejsze dla oczu nocą) i **odtwarzacz zawsze ciemny**. Część kolorystyczna zachowuje pełną paletę FlexScheme — **19 kolorów bazowych** plus osobny **„styl palety”**, który decyduje, jak każdy kolor kontenera jest wyprowadzany z koloru bazowego, niezależnie od tego, który bazowy wybierzesz.
- **LXGW WenKai w zestawie z aplikacją.** Krój **LXGW WenKai (霞鹜文楷)** jest **dołączony i ustawiony domyślnie** — ciepła, bardzo czytelna chińska czcionka dostępna od razu po instalacji, zamiast szukać jej w wyborze. Dotyczy całego interfejsu *i* danmaku. Nadal możesz wrócić do czcionki systemowej, wybrać dowolną zainstalowaną czcionkę systemową albo zaimportować własną `.ttf` / `.otf` / `.ttc`; krój wybrany wcześniej jawnie jest zachowywany przez aktualizację. Grubość i rozmiar pozostają regulowane jak dotąd.

## Buforowanie audio offline i pobieranie do folderu lokalnego (unikatowe w PiliBabel)

Dwie możliwości, których nie mają nadrzędne PiliNara / PiliPlus — obie wymierzone w faktyczne posiadanie swoich mediów offline.

### Buforuj audio (offline'owy bufor samego audio)

- **Utwór, nie wideo.** Pozycja *Buforuj audio* znajduje się tuż pod *Buforuj wideo* w menu strony wideo, plus dedykowany przycisk buforowania audio w górnym pasku strony odsłuchiwania wideo.
- **Wybierz poziom jakości.** Hi-Res bezstratne, Dolby Atmos, 192K, 132K lub 64K — ta sama lista ustawień wstępnych, której używa wybór jakości wideo.
- **Oryginalny kontener, bez transkodowania.** Plik zapisywany jest dokładnie tak, jak serwuje go CDN: `m4a`, `mp3`, `flac`, `wav`, `aac` lub `ogg`.
- **Własny moduł.** Strona bufora jest podzielona na *Zbuforowane wideo* / *Zbuforowane audio* i pamięta, na którym module byłeś ostatnio.
- Dotknięcie zbuforowanego nagrania audio od razu otwiera odtwarzacz audio; elementy usuwa się pojedynczo lub masowo.

### Pobierz do folderu lokalnego

- **Własna pozycja w menu.** *Pobierz do folderu lokalnego* to osobna pozycja w menu strony wideo, tuż pod *Buforuj audio* — buforowanie w aplikacji i zapisywanie do folderu to dwie różne czynności.
- **Pobierz wideo albo pobierz audio.** Pozycja najpierw pyta, które z dwóch, potem o poziom jakości (wybór jakości wideo / audio).
- **Twój folder, twoje zasady.** Wybierz dowolny folder przez systemowy menedżer plików (Ustawienia → *Pobierz do folderu lokalnego*) i zmieniaj lub czyszcz go, kiedy chcesz. Jeśli jeszcze żadnego nie wybrałeś, wybór folderu otwiera się od razu.
- **Pliki odtwarzalne bezpośrednio.** Wideo jest pobierane jako jeden strumień zmultipleksowany (`fnval=1`), więc na dysk trafia zwykły MP4, który możesz oddać dowolnemu odtwarzaczowi — bez osobnych strumieni do sklejenia.
- **Audio zachowuje oryginalny format** — bez transkodowania, dokładnie jak bufor w aplikacji.
- Pliki otrzymują nazwę od tytułu wideo i nigdy nie nadpisują istniejącego pobrania.

## Dwa silniki tłumaczenia

| | Wbudowany (domyślny) | Własne API |
|---|---|---|
| Model | **Index-Translate-35B-A3B** bilibili | wszystko zgodne z OpenAI |
| Punkt końcowy | `index-translate.bilibili.com/v1` | twój bazowy adres URL |
| Klucz API | **niepotrzebny** | twój |
| Koszt | darmowy | cokolwiek pobiera twój dostawca |
| Żądania | jeden ciąg na żądanie | paczkami (≤ 16 na żądanie) |
| Dodatkowe języki | — | każdy język, który zna twój model |

**Dlaczego jedno żądanie na ciąg w silniku wbudowanym.** Index-Translate to *specjalista* od tłumaczeń, a konwencja wywołań udokumentowana przez jego autorów to szablon jednoelementowy („przetłumacz następujący tekst na X, zwróć tylko tłumaczenie”). PiliBabel wysyła więc na tym silniku jeden ciąg na żądanie zamiast grupowego promptu z numerowaną listą/tablicą JSON, którego używa dla konfiguracji z własnym API. Punkt końcowy jest darmowy, więc nie ma nic do zyskania na ryzykowaniu z grupowym wyjściem — to świadoma wymiana kilku dodatkowych żądań na znacznie mniej sposobów na awarię.

**Aktualizacja z 0.3.x.** Twoje ustawienia własnego API — bazowy adres URL, klucz i model — są **zostawione dokładnie tak, jak je skonfigurowałeś**. Wybór silnika po prostu domyślnie wskazuje model wbudowany, więc przy pierwszym uruchomieniu po aktualizacji będziesz na darmowym modelu bilibili; otwórz *Ustawienia → AI → Funkcje AI → silnik tłumaczenia* i wróć do *Własne API*, by natychmiast przywrócić poprzednią konfigurację.

## Jak działa tłumaczenie interfejsu przez AI (technicznie)

Repozytorium **nie ma warstwy zasobów i18n / ARB** — ciągi interfejsu to zaszyty w kodzie chiński. Zamiast przepisywać każdy widget, PiliBabel dodaje na wierzchu cienką warstwę tłumaczeniową:

1. **Globalny wrapper wyszukiwania.** `lib/services/ui_translate/` wystawia `uiTx(String src)` najwyższego poziomu. Tekst widgetu, który był `Text('中文')`, staje się `Text(uiTx('中文'))`. Skryptowy **codemod** zastosował to w całym projekcie (`tool/ui_translate_*.py`) — około **223 plików / ~1650+ ciągów** — automatycznie usuwając teraz nieprawidłowe słowo kluczowe `const` tam, gdzie było trzeba (łącznie z generykami takimi jak `const X<T>(...)` i nazwami kropkowymi takimi jak `const Positioned.fill(...)`, oraz zamieniając deklaracje listy/mapy `static const` na `static final`).
2. **Rdzeń `GetxService`** (`ui_translate_service.dart`):
   - trwała pamięć podręczna **źródło → tłumaczenie** (na GetStorage), więc każdy ciąg jest tłumaczony raz i używany w nieskończoność;
   - `tx()` najpierw czyta `RxInt revision`, potem decyduje: jeśli wyłączone → zwróć oryginał; jeśli celem jest **chiński uproszczony (`zh-CN`)**, zwróć oryginał bez żądania API (treści źródłowe bilibili w przytłaczającej większości to chiński uproszczony). Każdy inny cel — łącznie z chińskim tradycyjnym, kantońskim, wu/szanghajskim i hokkien/min nan — przechodzi przez skonfigurowany silnik; sama przynależność do rodziny chińskiej nie pomija tłumaczenia. Następnie podaje z pamięci podręcznej albo **kolejkuje**;
   - ciągi z kolejki są spłukiwane przez **pulę workerów** z **przyrostowym stosowaniem na porcje** (każda zwrócona porcja podbija `revision`, więc tekst aktualizuje się stopniowo), a wyniki są **utrwalane** (z dławieniem). Rozmiar paczki i współbieżność zależą od silnika: **1 na żądanie** na modelu wbudowanym, **≤ 16 z ≤ 10 w locie** na własnym API.
3. **Rozstrzyganie silnika.** `TranslateProvider` (`builtin` / `custom`) decyduje, jakiego adresu URL, klucza i modelu używa transport; poza tym oba silniki dzielą jedną ścieżkę kodu i jedną listę języków, więc przełączenie silnika to pojedyncze ustawienie i nigdy inny zestaw funkcji.
4. **Transport** ponownie używa tego samego sprawdzonego kanału **streamingowego** co AI-streszczenie wideo — `AiChatService.streamChat` → `{base}/chat/completions` z `stream: true` (zgodny z bramkami obsługującymi wyłącznie streaming) — rozszerzonego tak, by tłumaczenie mogło używać **własnych** `apiUrl` / `apiKey` / `model` i flagi `enable_thinking`. Zmiana jest **wstecznie zgodna**, więc streszczenie wideo działa bez zmian.
5. **Zdania z interpolacją** używają `uiTxP(template, args)`: całe zdanie z zastępnikami `{0}`/`{1}` jest tłumaczone jako jeden stabilny klucz (prompt prosi model o zachowanie zastępników), po czym wartości są podstawiane z powrotem — dzięki czemu ciągi w stylu `"共 {0} 条"` tłumaczą się bez kaleczenia części dynamicznych.
6. **Tablica języków** (`app_language.dart`): każdy `AppLanguage` niesie autonim wyświetlany, ciąg promptu `toModel` kodujący konwencje pisma/regionu oraz flagę, czy oficjalny spis bilibili go obejmuje. Reguły pisma (uproszczony kontra tradycyjny oraz instrukcje spójności dialektu) trafiają do modelu wyłącznie przez prompt, a deterministyczna normalizacja po stronie klienta poprawia potem błędne glify.
7. **Komentarze** przechodzą przez `uiTxComment(text, id)`, zachowując `@ / [emoji] / #temat# / link` jako nienaruszone tokeny; spany rich text niosące linki są tłumaczone przy zachowaniu rozpoznawania linków, a zbiór id per komentarz steruje przełącznikiem Oryginał ⇄ Tłumaczenie.
8. **Danmaku** (`danmaku/view.dart`): gdy przełącznik jest włączony, nasłuchiwacz pozycji przemierza `[playhead, playhead + 15s]` sekunda po sekundzie i dogrzewa `uiTx()` na treści każdego danmaku, więc elementy są tłumaczone z wyprzedzeniem, zanim dotrą na ekran; włączenie go czyści i przemalowuje kanwę.
9. **Klucze pamięci**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Interfejs ustawień**: jedna strona pierwszego poziomu „Funkcje AI” (`lib/pages/setting/ui_translate/`) z niezależnymi blokami dla AI-streszczenia wideo i tłumaczenia AI.

**Ogólnoświatowy CDN (`VideoUtils.getCdnUrl`).** Adresy URL strumieni są podpisane, a przepisanie hosta adresu powoduje odrzucenie go z 403 — dlatego odtwarzanie nigdy nie przepisuje hostów. PiliBabel zwraca adres z routingu geograficznego, który bilibili przydziela IP klienta, a gdy lista kandydatów zawiera już węzeł brzegowy spoza Chin (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`), ten jest preferowany. Pobrania, gdzie podmiana hosta jest bezpieczna, dodatkowo preferują globalny węzeł Akamai i rotują na kolejnego podpisanego kandydata, gdy linia się zacina lub odrzuca wznowienie. Surowe linki P2P `/v/resource` nadal spadają na istniejący relay, by uniknąć 404.

**Kompromisy projektowe / znane ograniczenia.** Ponieważ ciągi są opatrywane w miejscu, a nie wyodrębniane do zasobów, kilka parametrów tekstowych poza `Text` i część spanów rich text jest nadal uzupełnianych przyrostowo. Ciągi pełniące jednocześnie rolę **kluczy logicznych** (porównywane `==`, używane jako nazwy zakładek jak `简介` albo etykiety enumów w switchach) celowo **nie** są opatrywane masowo, żeby nie psuć zachowania. Tłumaczenie danmaku działa na zasadzie best-effort na przewijającej się kanwie — przy ekstremalnie gęstych danmaku możesz chwilę widzieć oryginał, zanim przyjdzie tłumaczenie. Tłumaczenie wymaga sieci; bez niej cele niechińskie po prostu nie wchodzą w życie. Wbudowany punkt końcowy to darmowa usługa publiczna prowadzona przez bilibili — jeśli kiedykolwiek będzie limitowana lub niedostępna, aplikacja cię o tym poinformuje i możesz przejść na własne API.

## Budowanie i weryfikacja

Aplikacja jest budowana z patchowanym SDK Fluttera plus patchowanymi pakietami `material_ui` / `cupertino_ui` za pomocą `lib/scripts/patch.ps1` i `lib/scripts/build.ps1` (dokładnie jak PiliNara / PiliPlus). GitHub Actions produkuje **APK debug** przy każdym pushu (`.github/workflows/ui-translate-debug.yml`), a **opublikowanie tagu `v*` automatycznie buduje i publikuje artefakty Android, Windows i Linux** (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Platformy
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

PiliBabel dostarcza kompilacje **Android (APK), Windows i Linux** z Releases; iOS/Pad nie jest jeszcze pakowany w tym forku.

<br/>

## Pobieranie

Weź kompilację z **Releases**, albo sklonuj repozytorium i zbuduj lokalnie.

### Arch Linux

Podziękowania dla [@nlsdt](https://github.com/nlsdt) za pakowanie (receptura PiliNara przenosi się na PiliBabel).

```bash
sudo pacman -S pilinara      # przez repozytorium Arch Linux CN
paru -S pilinara-bin         # lub przez AUR: pilinara-bin (skompilowany) / pilinara (źródła)
```

<br/>

## Dziennik zmian: 2.6.x → 3.3.4

- **2.6.x** — pamięć podręczna dźwięku (osobne moduły dla wideo i dźwięku, zapamiętuje ostatni wybór, wejścia na stronie wideo, stronie tylko dźwięku i w odtwarzaczu; zachowany oryginalny format; wybór jakości) oraz pobieranie na urządzenie (osobna pozycja menu: najpierw wideo/dźwięk, potem jakość; bez ustawionego folderu otwiera się systemowy wybór plików).

- **3.0.x–3.1.0** — samonaprawa sieci za granicą: stan każdego hosta z przełączaniem główny/zapasowy, rozwiązywanie DNS z pamięcią podręczną, wstępne rozgrzewanie połączeń, ochładzanie po kontroli ryzyka (412), rozpoznawanie regionu z ręcznym wyborem, test szybkości CDN współdzielony z warstwą API; bufor wyprzedzający odtwarzacza dostosowuje się do przepływności ścieżki wideo.

- **3.2.0–3.3.3** — podstawa sieciowa w stylu oficjalnej aplikacji: odcisk żądania (buvid/fp/session_id/env), przełączanie hostów gRPC, interceptор ponowień, limit równoczesnych żądań na host, wstępne wczytanie pierwszego strumienia przy zimnym starcie, oficjalne parametry zdarzeń strumienia, kolejność kandydatów CDN z zagranicznym zapasem; wstępne wczytanie drugiej strony, ograniczona kolejka wstępnego wczytywania okładek, wstępne wczytywanie adresów odtwarzania; następnie renderowanie dynamiki (P3) przez gRPC oraz poprawki: błąd kompilacji długości bufora na stronie dźwięku i błąd konwersji typu przy wstępnym wczytywaniu komentarzy, przez który każda ponowna próba kończyła się natychmiastowym niepowodzeniem.

- **3.3.4** — karty dynamiki dla wpisów płatnych, mini-aplikacji, zestawów tematów i subskrypcji; naprawiono brak okładek na pierwszym ekranie strony głównej; włączono zmiany z PiliNara (pasek stanu, wznawianie pobierania po zamknięciu procesu, aktualizacja media-kit, obejście czarnego obrazu w Wayland, wybór jakości dźwięku przy zapisie do pamięci podręcznej); audyt tłumaczenia AI dla wszystkich tekstów interfejsu dodanych od 3.0.5; ten dziennik.

## Dziennik odziedziczonych funkcji (z PiliNara / PiliPlus)

Wszystko poniżej pochodzi z PiliNara (i, przenośnie, PiliPlus); PiliBabel dodaje na wierzchu warstwę tłumaczenia AI.

**Interfejs i adaptacja platformowa**
- [x] Aplikacja przemianowana per platforma, aby wiele klientów mogło współistnieć (PiliBabel instaluje się obok PiliNara)
- [x] Naprawione renderowanie Fluttera pod minioknem Xiaomi HyperOS ([#161086](https://github.com/flutter/flutter/issues/161086), przez [venera#467](https://github.com/venera-app/venera/pull/467)); animacja predykcyjnego cofania na Androidzie
- [x] Konfigurowalna kolejność/liczba kart „Moje”; podgląd na kartach historii i sekcje „do obejrzenia później”
- [x] Automatyczne przełączanie panelu bocznego z konfigurowalną szerokością wyzwalacza; kopiowanie obrazu z długiego naciśnięcia / prawego kliknięcia; duże odświeżenie stylu MD3E

**System czcionek** — ujednolicona pula importu z deduplikacją po haszu treści, czcionki danmaku scalone do tej samej puli, `loadFontFromList` ze wsparciem ttc i nazwy rodzin z czystego hasza ASCII.

**Odtwarzanie, miniokno i jakość** — miniokno w aplikacji (przeciąganie, zmiana rozmiaru, pomijanie SponsorBlock, automatyczny systemowy PIP, pasek samoratowania na żywo), równoległe odtwarzanie audio, głośność w aplikacji do 200%, własna domena CDN wideo i wybór węzła regionalnego z testem opóźnień, oddzielna domyślna jakość dla pół/pełnego ekranu, blokada prędkości przy przesunięciu w górę, sterowanie klawiaturą na tablecie, znaczniki czasu SuperChat na żywo, heartbeat transmisji dla zażyłości z fanami.

**Napisy, AI i offline** — dwujęzyczne napisy z niezależną stylizacją napisów drugoplanowych, analiza napisów przez AI (własny punkt zgodny z OpenAI, skok po znaczniku czasu, szablony, trwałe rozmowy, miękkie przejście przy braku napisów), eksport WEBVTT/SRT, podwójny widok bufora offline z zarządzaniem folderami i utrwalaniem metadanych, eksport pobrań do publicznego folderu Download (Android).

**Danmaku i blokowanie** — ulepszone skalowanie scalonych danmaku (w stylu [Pakku.js](https://github.com/xmcp/pakku.js)), listowe wizualne blokowanie regexami z importem/eksportem, pomijanie seek-do-segmentu SponsorBlock, pasek postępu wysokiej energii z jądrem gaussowskim.

**Filtrowanie poleceń / dynamik / komentarzy** — słowa kluczowe tytułu/UP/kanału, czas trwania, liczba odtworzeń, wskaźnik polubień, zwolnienie dla obserwowanych UP, filtrowanie nieautoryzowanych/tylko płatnych, współdzielona biała lista, dynamiki komercyjne/nieautoryzowane, zwolnienia dla komentarza własnego UP i komentarza przypiętego, tryb scalonego feedu App+Web.

**Dynamiki, wyszukiwanie i informacje o użytkowniku** — własne notatki o UP, notatka zastępuje pseudonim w 13 miejscach nazw, niezależne sortowanie komentarzy zagnieżdżonych, lokalny filtr słów kluczowych w wyszukiwarce, przeskok po krótkim linku b23.tv, plakietka tylko płatne, przełącznik ukrywania powodu polecenia, wyświetlanie XP monet.

**Ulepszenia transmisji na żywo** — panel zakładania medali fana, rzut DLNA preferujący HLS, wyświetlanie czasu SuperChat, dolny pasek sterowania miniokna do samoratowania.

**Integracja z systemem i desktop** — SMTC na Windows, MPRIS na Linuksie (`audio_service_mpris`), przebudowana obsługa audio-focus.

<details>
<summary>Pełna oryginalna lista funkcji/checklista (dosłownie, z PiliNara — kliknij, aby rozwinąć)</summary>

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

## Zastrzeżenia

PiliBabel to projekt osobisty, tworzony z zamiłowania, dostarczany **wyłącznie do nauki i testów**; prosimy usunąć go w ciągu **24 godzin** od pobrania.

- PiliBabel jest **nieoficjalnym klientem osób trzecich** i **nie jest powiązany, popierany ani sponsorowany przez bilibili**.
- Wszystkie API pochodzą z oficjalnych publicznych punktów końcowych; **nie dostarczamy treści łamanych, nadmiarowo uprzywilejowanych ani omijających paywalla**.
- **Tłumaczenie AI działa na punkcie końcowym modelu strony trzeciej.** Domyślnie jest to darmowa publiczna usługa Index-Translate samej bilibili; jeśli przejdziesz na własne API, jest to punkt, który skonfigurowałeś. Jakość i zgodność tłumaczenia są odpowiedzialnością użytkownika i wybranego dostawcy modelu; ten projekt nie hostuje **żadnego modelu i żadnego klucza API**.
- Szanuj prawa autorskie i warunki korzystania bilibili. Korzystaj odpowiedzialnie.

Z szacunkiem dla oryginalnych i nadrzędnych autorów za ich otwartoźródłowe oddanie:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — projekt bezpośrednio nadrzędny wobec PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — otwartoźródłowa rodzina modeli tłumaczeniowych, którą wywołuje silnik wbudowany

Jeśli jakakolwiek treść narusza twoje prawa, skontaktuj się z nami w celu usunięcia.

<br/>

## Licencja

PiliBabel jest licencjonowany na warunkach **GNU General Public License v3.0 (GPL-3.0)** — tej samej licencji co PiliNara, PiliPlus i PiliPala. Ponieważ jest to praca pochodna, **PiliBabel również musi być dystrybuowany na GPL-3.0**: możesz go swobodnie używać, studiować, udostępniać i modyfikować, pod warunkiem zachowania tej samej licencji, informacji o prawach autorskich i tego tekstu licencji. Zobacz [`LICENSE`](./LICENSE).

Komponenty stron trzecich (pakiety Flutter, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), itd.) pozostają pod własnymi licencjami.

Dołączony krój **LXGW WenKai** jest licencjonowany osobno na **SIL Open Font License 1.1**; tekst licencji wchodzi w skład aplikacji jako `assets/fonts/LXGWWenKai-OFL.txt`.

<br/>

## Podziękowania

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — otwartoźródłowa rodzina modeli tłumaczeniowych bilibili i darmowy publiczny punkt końcowy stojący za silnikiem wbudowanym
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — otwartoźródłowa chińska czcionka dołączona do aplikacji, na licencji SIL Open Font License 1.1
- i więcej
- Zainspirowane oficjalnym „tłumaczeniem interfejsu AI” bilibili.
<br/>

---

> **Documentation language note / 文档语言说明.** This README and its translations are written and maintained with the help of AI translation tooling; the English version is the reference if any wording looks inconsistent. 本仓库的 README 及各语言译文在 AI 翻译工具的协助下撰写与维护；若各语言版本表述不一致，以英文版为准。
