<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Yapay zekâ destekli çeviri sunan üçüncü taraf bir Bilibili istemcisi.</b></p>
    <p>Babel — dil engelini yıkmak için; herkes bilibili'nin tadını kendi dilinde çıkarabilsin diye.</p>
    <p>bilibili'nin resmî 151 dilli envanterini, kapsamadığı 6 dil daha ile birleştirir — Geleneksel Çince, Basitleştirilmiş ve Geleneksel Wu dili, anakara ve Tayvan Hokkiencesi ile Zhuang dili.</p>
    <p>Çeviri, bilibili'nin kendi ücretsiz modeliyle kutudan çıktığı gibi çalışır — API anahtarı gerekmez.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.nan.md">台語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.mn.md">Монгол</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.pt.md">Português</a> · <a href="README.bn.md">বাংলা</a> · <a href="README.th.md">ไทย</a> · <b>Türkçe</b> · <a href="README.it.md">Italiano</a> · <a href="README.fa.md">فارسی</a> · <a href="README.fil.md">Filipino</a> · <a href="README.ur.md">اردو</a> · <a href="README.mr.md">मराठी</a> · <a href="README.te.md">తెలుగు</a> · <a href="README.ta.md">தமிழ்</a> · <a href="README.pa.md">ਪੰਜਾਬੀ</a> · <a href="README.gu.md">ગુજરાતી</a> · <a href="README.ha.md">Hausa</a> · <a href="README.sw.md">Kiswahili</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.my.md">မြန်မာ</a> · <a href="README.pl.md">Polski</a> · <a href="README.is.md">Íslenska</a> · <a href="README.nb.md">Norsk</a> · <a href="README.fi.md">Suomi</a> · <a href="README.sv.md">Svenska</a> · <a href="README.da.md">Dansk</a> · <a href="README.be.md">Беларуская</a> · <a href="README.ug.md">ئۇيغۇرچە</a> · <a href="README.kk.md">Қазақша</a> · <a href="README.bo.md">བོད་ཡིག</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Ana Sayfa" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dinamikler" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Benim" />
</div>

<br/>

> **Sorumluluk Reddi.** PiliBabel **gayri resmî, açık kaynaklı, üçüncü taraf** bir istemcidir. bilibili / bilibili Inc. ile **hiçbir şekilde bağlantılı değildir, onaylanmamıştır veya sponsor edilmemiştir**. Kullanılan her API resmî herkese açık uç noktalardan toplanmıştır; **hiçbir ücretli içeriğin kilidi açılmaz veya kırılmaz**. Lütfen tam [Sorumluluk Reddi](#sorumluluk-reddi) ve [Lisans](#lisans) bölümlerini okuyun.

## PiliBabel nedir?

PiliBabel, **[PiliNara](https://github.com/Starfallan/PiliNara) üzerine inşa edilmiş bağımsız bir üçüncü taraf fork'tur** ve PiliNara'nın devraldığı her şeyi devralır:

```
bilibili (resmî herkese açık API)
        ▲
   PiliPala / PiliPalaX        — özgün proje
        ▲
   PiliPlus                    — aktif fork
        ▲
   PiliNara                    — PiliPlus'ın fork'u (kişisel ince ayarlar)
        ▲
   PiliBabel  ← buradasınız    — PiliNara'nın fork'u
```

PiliBabel, **PiliNara / PiliPlus'ın tüm özelliklerini korur** (en altta, yakınındaki [devralınan özellik günlüğüne](#devralınan-özellik-günlüğü-pilinara--piliplus) bakın) ve **yukarı akış istemcilerinde bulunmayan iki başlıca yetenek ekler**:

> **Yapay zekâ arayüz ve içerik çevirisi** — uygulamanın tamamı (arayüz etiketleri, video başlıkları, UP adları, yorumlar, dinamikler, akış ve hatta canlı danmaku) **sizin** seçtiğiniz dilde görüntülenir.

Ve 1.0 sürümünden itibaren bunu **kutudan çıktığı gibi** yapar: çeviri modeli **içine gömülüdür**. bilibili, kendi çeviri model ailesi [Index-Translate](https://github.com/bilibili/Index-Translate)'ı açık kaynak yaptı ve onu ücretsiz bir herkese açık uç noktadan sunuyor. PiliBabel buna işaret edecek şekilde gelir; dolayısıyla uygulamayı kurduğunuz anda çeviri çalışır — kayıt yok, anahtar yok, fatura yok. Kendi modelinizi kullanmayı tercih ederseniz, kendi API'niz yolu hâlâ oradadır, bir dokunuş uzağınızda.

> **Gerçekten eşzamanlı kalan kulaklık sesi** — Bluetooth veya kablolu kulaklıkla ses artık görüntünün gerisinde kalmaz. Resmî uygulama bunu doğru yapar; PiliNara ve PiliPlus, kutudan çıktıkları hâliyle yapamaz. PiliBabel artık mpv'den önce **AudioTrack**'i ister; bu, ses çıkışı gecikmesini resmî istemcinin yaptığı aynı şekilde *ölçer* — bunu yalnızca *tahmin eden* **OpenSL ES**'in yerine.

## Öne çıkan özellikler

- **Kulaklık sesinde eşzamanlılık.** Oynatıcı artık varsayılan olarak mpv'nin **AudioTrack** arka ucunu kullanır (`audiotrack,aaudio,opensles` sırası), **OpenSL ES** yerine. AudioTrack *ölçülmüş* bir çıkış gecikmesi bildirir — çalınıp biten kare sayısını ve aygıt sunum zaman damgasını okur — resmî bilibili uygulamasının ve Android'in kendi `MediaSync`'inin görüntü ile sesi birlikte tuttuğu yöntemin ta kendisidir. OpenSL ES bunu yalnızca *tahmin eder*; bu yüzden Bluetooth kulaklıklarda ses saati kayar ve görüntü erken gösterilirdi. Testlerde gecikme fiilen yok oldu. Sırayı istediğiniz zaman Ayarlar → Video → Ses çıkış aygıtı bölümünden değiştirebilirsiniz.

- **Yapay zekâ çevirisi, her yerde.** Gezinme sekmeleri, video kartları, ayrıntı sayfaları, yorumlar, dinamikler ve Benim / Favoriler / Geçmiş / Mesajlar / Arama yüzeyleri — küresel bir tarama **~1,650+ arayüz dizesini** artı dinamik içeriği (başlıklar, yazar adları, eylem sayıları) kapsar.
- **İki motor, tek anahtar.** *Yerleşik* (varsayılan), bilibili'nin resmî **Index-Translate-35B-A3B** ücretsiz uç noktasını kullanır — yapılandırılacak hiçbir şey yoktur. *Kendi API'niz* önceki davranışı korur: onu kendi temel URL'niz / anahtarınız / modelinizle herhangi bir OpenAI uyumlu `/chat/completions` uç noktasına yönlendirin. Yapay zekâ video özeti özelliği ile yapay zekâ çeviri özelliğinin hâlâ **tamamen bağımsız** uç noktaları ve ayarları vardır; ikisi de tek bir **"AI özellikleri"** sayfası altında yaşar.
- **Tek dil listesi, iki motor birlikte.** Hedef dil listesi mote göre bölünmez — hangi motoru seçerseniz seçin aynı liste sunulur. Liste, bilibili'nin resmî modelinin **151 dilini**, onun kapsamadığı **6 dil daha** ile birleştirir — Geleneksel Çince, Basitleştirilmiş ve Geleneksel Wu dili, anakara ve Tayvan Hokkiencesi ve Zhuang dili. Bölgesel ve yazı sistemi varyantları bir araya katlanmak yerine **ayrı girdiler** olarak tutulur — Fas / Mısır / Necid / Levanten Arapçası, tıpkı Kiril'e karşı Latin Sırpçası, Özbekçe ve Urduca gibi, her biri kendi başına bir seçenektir.
- **Kapsam konusunda dürüst.** Resmî envanterin içindeki diller bilibili'nin modeli tarafından karşılanır. Envanterin dışındaki az sayıda dil — Geleneksel Çince, Basitleştirilmiş ve Geleneksel Wu dili, anakara ve Tayvan Hokkiencesi ve Zhuang dili — listede yine görünür ve bu şekilde işaretlenir; böylece daha iyi bir sonuç için kendi modelinizin gerekebileceğini bir bakışta görürsünüz.
- **Bir kez çevirin, sonra sabittir.** Her kaynak dize **tam olarak bir kez** çevrilir; sonuç yerel olarak kalıcı hâle getirilir ve bir ekranı yeniden açtığınızda **asla yeniden çevrilmez** — kararlı, öngörülebilir çeviriler için resmî istemciyle aynı ilke.
- **Yorum başına Orijinal ⇄ Çeviri düğmesi** (Çince bir kelime değil, küçük bir simge). `@mentions / [emoji] / #topics# / links` belirteç olarak korunur ve **köprü bağlantısı içeren yorumlar bile çevrilirken bağlantı tıklanabilir kalır**.
- **Danmaku (弹幕) çevirisi** — oynatıcının sağ üst kontrol sırasında bağımsız bir düğme, **varsayılan olarak kapalıdır** ve kendi metni çevrilmiş bir onay ekranının arkasındadır. Etkinleştirildiğinde, oynatma konumunun ilerisindeki danmakular **~15 saniyelik gruplar** hâlinde önceden çevrilir (ortaya atlamak baştan değil doğru şekilde ele alınır), böylece çeviri genellikle ekrana kaydığı anda hazırdır.
- **Düşünme modu düğmesi** (`enable_thinking`) kaliteye karşı hız için, ayrıca ayarlar içinde **"çeviriyi sına"** ve **önbelleği temizle** düğmeleri.
- **Hızlı dil değiştirme**: kalıcı bir önbelleğe karşı sınırlı eşzamanlılıkla toplu istekler; dili değiştirmek geçerli ekranı bir kez zorla yeniden inşa eder, böylece çevrilmemiş metne bakakalmazsınız. Yapay zekâ çevirisini kapatmak tüm arayüzü özgün metne geri döndürür ve hiçbir istek göndermez.
- **İlk açılış karşılama rehberi.** Uygulamayı ilk açtığınızda İngilizce bir iletişim kutusu çeviriyi açmayı önerir. Kabul etmek çeviriyi etkinleştirir, yerleşik modeli seçer, yapay zekâ ayarları sayfasını açar ve hemen hangi dili istediğinizi sorar — böylece yeni bir kullanıcı, kurulumdan çevrilmiş uygulamaya iki dokunuşla gider.
- **Dünya çapında çalışan oynatma.** PiliBabel, sizi bir anakara (Aliyun/Shenzhen) düğümüne sabitlemek yerine, bilibili'nin coğrafi yönlendirmeli `playurl`'sinin zaten sunduğu yurt dışı kenar düğümünü (küresel **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) seçer — böylece anakara Çin dışındaki kullanıcılar artık takılmez ("ses çalmaya devam eder, video donar"). Ayarlar'dan yine de el ile bir CDN sabitleyebilirsiniz.
- **"Tema ve Renk" sayfası, Material You tarzı.** Açık / koyu / sistemle birlikte seçenekleri **üç canlı önizleme kartından** seçilir — her biri, o modun uygulayacağı tam renklerle gerçek arayüzün bir minyatürünü çizer ("sistemi izle" kartı çapraz olarak bölünmüştür, koyunun üzerinde açık). Altlarında: **dinamik renk** (aygıtın desteklediği yerlerde sistem duvar kâğıdından alınır), **yüksek kontrastlı koyu** (gerçek siyah yüzeyler, gece gözler için daha rahat) ve **her zaman koyu oynatıcı**. Renk yarısı tam FlexScheme paletini korur — **19 tohum rengi** artı, her kapsayıcı renginin tohumdan nasıl türetileceğine karar veren ve seçtiğiniz tohumdan bağımsız, ayrı bir **"palet stili"**.
- **LXGW WenKai uygulamayla birlikte gelir.** **LXGW WenKai (霞鹜文楷)** yazı tipi **paketin içine gömülüdür ve varsayılan olarak ayarlanmıştır** — uygulamayı kurduğunuz anda sahip olduğunuz, sıcak, yüksek okunabilirlikli bir Çince yazı tipi; bir seçicide tek tek aramak yerine. Tüm arayüze *ve* danmakuya uygulanır. Yine sistem yazı tipine dönebilir, kurulu herhangi bir sistem yazı tipini seçebilir veya kendi `.ttf` / `.otf` / `.ttc` dosyanızı içe aktarabilirsiniz; yükseltmeden önce açıkça seçtiğiniz bir yazı tipi yükseltme sonrasında da korunur. Kalınlık ve boyut eskisi gibi ayarlanabilir kalır.

## Çevrimdışı ses önbellekleme ve yerel klasöre indirme (PiliBabel'e özgü)

Yukarı akış PiliNara / PiliPlus'ta bulunmayan iki yetenek — ikisi de medyanızı çevrimdışı olarak gerçekten sahiplenmenize yöneliktir.

### Sesi önbelleğe al (yalnızca ses için çevrimdışı önbellek)

- **Parça, video değil.** Video sayfası menüsünde *Videoyu önbelleğe al* seçeneğinin hemen altında bir *Sesi önbelleğe al* girdisi bulunur; ayrıca sesle-dinleme sayfasının üst çubuğunda ayrı bir ses-önbelleği düğmesi vardır.
- **Kalite kademesini seçin.** Hi-Res kayıpsız, Dolby Atmos, 192K, 132K veya 64K — video kalite seçicisinin kullandığı aynı ön ayarlı liste.
- **Özgün kapsayıcı, kod dönüştürme yok.** Dosya, CDN'nin sunduğu biçimle tam olarak yazılır: `m4a`, `mp3`, `flac`, `wav`, `aac` veya `ogg`.
- **Kendi modülü.** Önbellek sayfası *Önbelleğe alınmış videolar* / *Önbelleğe alınmış sesler* olarak ikiye bölünür ve en son hangi modülde olduğunuzu hatırlar.
- Önbelleğe alınmış bir ses ögesine dokunmak ses oynatıcıyı anında açar; ögeler tek tek veya toplu olarak silinebilir.

### Yerel klasöre indir

- **Kendi menü girdisi.** *Yerel klasöre indirme*, video sayfası menüsünde *Sesi önbelleğe al*'ın hemen altında ayrı bir girdidir — uygulama içinde önbelleğe almak ile bir klasöre kaydetmek iki farklı eylemdir.
- **Video ya da ses indirin.** Girdi önce hangisini istediğinizi sorar, ardından kalite kademesini sorar (video kalitesi / ses kalitesi seçici).
- **Sizin klasörünüz, sizin kurallarınız.** Sistem dosya yöneticisiyle dilediğiniz klasörü seçin (Ayarlar → *Yerel klasöre indirme*) ve istediğiniz zaman değiştirin veya temizleyin. Henüz bir klasör seçmediyseniz, klasör seçici anında açılır.
- **Doğrudan çalınabilir dosyalar.** Video, tek bir Birleşik akış olarak alınır (`fnval=1`); böylece diske inen şey, herhangi bir oynatıcıya verebileceğiniz düz bir MP4'tür — birleştirilecek yan akış yoktur.
- **Ses özgün biçimini korur** — uygulama içi önbellekteki gibi tamamen kod dönüştürme yoktur.
- Dosyalar video başlığına göre adlandırılır ve var olan bir indirmenin üzerine asla yazmaz.

## İki çeviri motoru

| | Yerleşik (varsayılan) | Kendi API'niz |
|---|---|---|
| Model | bilibili **Index-Translate-35B-A3B** | OpenAI uyumlu her şey |
| Uç nokta | `index-translate.bilibili.com/v1` | kendi temel URL'niz |
| API anahtarı | **gerekli değildir** | sizinki |
| Maliyet | ücretsiz | sağlayıcınızın talep ettiği her ne ise |
| İstekler | istek başına bir dize | toplu (istek başına ≤ 16) |
| Ek diller | — | modelinizin bildiği her dil |

**Yerleşik motor için neden istek başına bir dize.** Index-Translate bir çeviri *uzmanıdır* ve yazarlarının belgelediği çağrı kuralı tek ögeli bir şablondur ("aşağıdaki metni X diline çevir, yalnızca çeviriyi çıkar"). PiliBabel bu nedenle bu motorda, kendi API'niz kurulumlarında kullandığı numaralı liste/JSON dizisi toplu istemi yerine istek başına bir dize gönderir. Uç nokta ücretsizdir; yani toplu çıktıya bahse girmekten kazanılacak bir şey yoktur — bu, çok daha az hata yolu karşılığında birkaç istek daha vermenin bilinçli bir takasıdır.

**0.3.x'ten yükseltme.** Kendi API ayarlarınız — temel URL, anahtar ve model — **tam olarak yapılandırdığınız gibi bırakılır**. Motor seçimi yalnızca varsayılan olarak yerleşik modeli seçer; dolayısıyla yükseltmeden sonraki ilk açılışta bilibili'nin ücretsiz modelinde olacaksınız. Önceki kurulumunuza anında dönmek için *Ayarlar → AI → AI özellikleri → çeviri motoru*'nu açın ve *Kendi API'niz*'e geri dönün.

## Yapay zekâ arayüz çevirisi nasıl çalışır (teknik)

Depoda **i18n / ARB kaynak katmanı yoktur** — arayüz dizeleri sabit kodlanmış Çincedir. Her parçacığı (widget) yeniden yazmak yerine PiliBabel üstüne ince bir çeviri katmanı ekler:

1. **Genel arama sarmalayıcısı.** `lib/services/ui_translate/`, üst düzey bir `uiTx(String src)` sunar. Eskiden `Text('中文')` olan parçacık metni `Text(uiTx('中文'))` olur. Betikleştirilmiş bir **codemod** bunu proje genelinde uyguladı (`tool/ui_translate_*.py`) — yaklaşık **223 dosya / ~1,650+ dize** — gerektiğinde artık geçersiz olan `const` anahtar sözcüğünü otomatik olarak düşürerek (`const X<T>(...)` gibi genel türler ile `const Positioned.fill(...)` gibi noktalı adlar dahil ve `static const` liste/eşleme bildirimlerini `static final` değerine dönüştürerek).
2. **Bir `GetxService` çekirdeği** (`ui_translate_service.dart`):
   - kalıcı bir **kaynak → çeviri** önbelleği (GetStorage ile desteklenir); böylece her dize bir kez çevrilir ve sonsuza dek yeniden kullanılır;
   - `tx()` önce bir `RxInt revision` okur, sonra karar verir: devre dışıysa → özgünü döndür; hedef **Basitleştirilmiş Çince (`zh-CN`)** ise, bir API isteği yapılmadan özgün döndürülür (Bilibili'nin kaynak içeriği ezici çoğunlukla Basitleştirilmiş Çincedir). Diğer her hedef — Geleneksel Çince, Kantonca, Wu/Şanghayca ve Hokkien/Min Nan dahil — yapılandırılan motordan geçer; yalnızca Çince ailesinin üyesi olması başlı başına çeviriyi atlamaz. Sonra önbellekten sun veya **kuyruğa al**;
   - kuyruğa alınan diziler, **öbek başına artımlı uygulama** yapan bir **işçi havuzu** tarafından boşaltılır (dönen her öbek `revision` değerini yükseltir, böylece metin kademeli olarak güncellenir) ve sonuçlar **kalıcılaştırılır** (kısılarak). Toplu iş boyutu ve eşzamanlılık motora uyar: yerleşik modelde **istek başına 1**, kendi API'nizde **aynı anda en fazla 10 ile istek başına ≤ 16**.
3. **Motor çözümlemesi.** `TranslateProvider` (`builtin` / `custom`), taşıma katmanının hangi URL'yi, anahtarı ve modeli kullanacağına karar verir; iki motor bunun dışında tek bir kod yolunu ve tek bir dil listesini paylaşır, dolayısıyla motor değiştirmek tek bir ayardır ve asla farklı bir özellik seti değildir.
4. **Taşıma katmanı**, yapay zekâ video özetiyle aynı doğrulanmış **akış** kanalını yeniden kullanır — `AiChatService.streamChat` → `{base}/chat/completions`, `stream: true` ile (yalnızca akışı destekleyen ağ geçitleriyle uyumludur) — çevirinin **kendi** `apiUrl` / `apiKey` / `model` değerlerini ve bir `enable_thinking` bayrağı kullanabilmesi için genişletilmiştir. Değişiklik **geriye dönük olarak uyumludur**; böylece video özeti değişmeden çalışmaya devam eder.
5. **Ara değerli cümleler** `uiTxP(template, args)` kullanır: `{0}`/`{1}` yer tutucuları içeren bütün bir cümle, tek bir kararlı anahtar olarak çevrilir (istemin istediği üzere model yer tutucuları korur), ardından değerler geri yerleştirilir — böylece `"共 {0} 条"` tarzı diziler, dinamik kısımları bozmadan çevrilir.
6. **Dil tablosu** (`app_language.dart`): her `AppLanguage`; bir görünen öz ad, yazı sistemi/bölge kurallarını kodlayan bir `toModel` istem dizesi ve bilibili'nin resmî envanterinin kapsayıp kapsamadığına dair bir bayrak taşır. Yazı sistemi kuralları (Basitleştirilmiş ve Geleneksel, ayrıca lehçe tutarlılığı yönergeleri) modele yalnızca istem üzerinden ulaşır ve istemcideki kararlı bir normalleştirme geçişi, sonradan yolundan çıkmış karakterleri düzeltir.
7. **Yorumlar** `uiTxComment(text, id)` üzerinden geçer; `@ / [emoji] / #topic# / link` bozulmamış belirteçler olarak tutulur; bağlantı taşıyan zengin metin aralıkları, bağlantı tanıyıcı korunarak çevrilir ve yorum başına bir kimlik kümesi Orijinal ⇄ Çeviri düğmesini yönlendirir.
8. **Danmaku** (`danmaku/view.dart`): düğmesi açıkken, bir konum dinleyicisi `[oynatma konumu, oynatma konumu + 15s]` aralığını saniye saniye dolaşır ve her danmakunun içeriğinde `uiTx()`'i ısıtır; böylece ögeler ekrana ulaşmadan önce çevrilir. Etkinleştirmek tuvali temizler ve yeniden çizer.
9. **Depolama anahtarları**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Ayarlar arayüzü**: yapay zekâ video özeti ve yapay zekâ çevirisi için bağımsız bloklar içeren, birinci düzey tek bir "AI özellikleri" sayfası (`lib/pages/setting/ui_translate/`).

**Dünya çapında CDN (`VideoUtils.getCdnUrl`).** Akış URL'leri imzalıdır ve bir URL'nin ana makine adını yeniden yazmak, URL'nin 403 ile reddedilmesine yol açar — dolayısıyla oynatma asla ana makine adını yeniden yazmaz. PiliBabel, bilibili'nin istemcinin IP'sine verdiği coğrafi yönlendirmeli URL'yi döndürür; aday listesi zaten bir yurt dışı kenar düğümü (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`) içeriyorsa o tercih edilir. Bir ana makine değişiminin güvenli olduğu indirmeler ayrıca küresel Akamai kenar düğümünü tercih eder ve bir hat takıldığında ya da sürdürme isteği reddedildiğinde bir sonraki imzalı adaya geçer. Ham `/v/resource` P2P bağlantıları, 404'lerden kaçınmak için hâlâ mevcut aktarma hizmetine geri düşer.

**Tasarım takasları / bilinen sınırlar.** Diziler kaynaklara ayrılmak yerine yerinde sarmalandığından, `Text` olmayan birkaç dize parametresi ve bazı zengin metin aralıkları hâlâ kademeli olarak doldurulmaktadır. **Mantık anahtarı** olarak kullanılan diziler (`==` ile karşılaştırılanlar, `简介` gibi sekme adları olarak kullanılanlar veya anahtar sözcüklerde kullanılan sabit liste etiketleri) davranışı bozmamak için bilinçli olarak **genel olarak sarılmaz**. Danmaku çevirisi, kayan bir tuvalde elden gelenin en iyisidir — son derece yoğun danmakularda, çeviri gelmeden önce özgünü kısaca görebilirsiniz. Çevirinin ağa ihtiyacı vardır; ağ yokken Çince olmayan hedefler basitçe etkili olmaz. Yerleşik uç nokta, bilibili'nin işlettiği ücretsiz bir herkese açık hizmettir — hiçbir zaman hız sınırına takılır ya da kullanılamaz hâle gelirse uygulama size bunu bildirir ve kendi API'nize geçebilirsiniz.

## Derleme ve doğrulama

Uygulama; `lib/scripts/patch.ps1` ve `lib/scripts/build.ps1` aracılığıyla yamalanmış bir Flutter SDK artı yamalanmış `material_ui` / `cupertino_ui` paketleriyle derlenir (tam olarak PiliNara / PiliPlus gibi). GitHub Actions her itişte bir **hata ayıklama APK**'sı üretir (`.github/workflows/ui-translate-debug.yml`) ve **bir `v*` etiketi yayımlamak, Android, Windows ve Linux yapıtlarını otomatik olarak derler ve yayınlar** (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Platformlar
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

PiliBabel, Releases'ten **Android (APK), Windows ve Linux** derlemelerini sunar; iOS/Pad henüz bu fork'ta paketlenmemiştir.

<br/>

## İndir

**Releases**'ten bir derleme alın ya da depoyu klonlayın ve yerel olarak derleyin.

### Arch Linux

Paketleme için [@nlsdt](https://github.com/nlsdt)'ye teşekkürler (PiliNara tarifi PiliBabel'e aynen geçer).

```bash
sudo pacman -S pilinara      # Arch Linux CN deposu aracılığıyla
paru -S pilinara-bin         # ya da AUR aracılığıyla: pilinara-bin (önceden derlenmiş) / pilinara (kaynak koddan)
```

<br/>

## Devralınan özellik günlüğü (PiliNara / PiliPlus)

Aşağıdaki her şey PiliNara'dan (ve dolaylı olarak PiliPlus'tan) devralınmıştır; PiliBabel üstüne yapay zekâ çeviri katmanını ekler.

**Arayüz ve platform uyarlama**
- [x] Uygulama, platform başına yeniden adlandırılır, böylece birden çok istemci yan yana var olabilir (PiliBabel, PiliNara ile birlikte kurulur)
- [x] Xiaomi HyperOS mini penceresi altında Flutter işleme düzeltildi ([#161086](https://github.com/flutter/flutter/issues/161086), [venera#467](https://github.com/venera-app/venera/pull/467) aracılığıyla); Android'de öngörülü geri animasyonu
- [x] Özelleştirilebilir "Benim" kart sırası/sayısı; geçmiş kartı önizlemesi ve "sonra izle" bölümleri
- [x] Yapılandırılabilir tetikleme genişliğiyle otomatik kenar çubuğu değiştirme; uzun basma / sağ tıklamadan görüntü kopyalama; geniş kapsamlı MD3E tarzı yenileme

**Yazı tipi sistemi** — içerik karmasıyla tekilleştirilen birleşik bir içe aktarma havuzu, aynı havuza birleştirilen danmaku yazı tipleri, ttc destekli `loadFontFromList` ve yalnızca-ASCII karmalı aile adları.

**Oynatma, mini pencere ve kalite** — uygulama içi mini pencere (sürükleme, boyutlandırma, SponsorBlock atlama, otomatik sistem resim-içi-penceresi, canlı kurtarma çubuğu), eşzamanlı ses oynatma, %200'e varan uygulama içi ses seviyesi, gecikme testiyle özel video CDN etki alanı ve bölgesel düğüm seçimi, ayrı yarı/tam ekran varsayılan kalitesi, yukarı kaydırma hız kilidi, tablet klavye denetimi, canlı SuperChat zaman damgaları, hayran-yakınlığı için canlı nabız.

**Altyazılar, yapay zekâ ve çevrimdışı** — bağımsız ikincil altyazı biçimlendirmesiyle iki dilli altyazılar, yapay zekâ altyazı analizi (özel OpenAI uyumlu uç nokta, zaman damgasına atlama, şablonlar, kalıcı konuşmalar, altyazı yokken yumuşak geri düşüş), WEBVTT/SRT dışa aktarma, klasör yönetimi ve üst veri kalıcılığıyla çevrimdışı önbellek çift görünümü, indirmeleri herkese açık İndirilenler klasörüne dışa aktarma (Android).

**Danmaku ve engelleme** — geliştirilmiş birleştirilmiş danmaku ölçekleme ([Pakku.js](https://github.com/xmcp/pakku.js) tarzı), içe/dışa aktarma destekli liste tabanlı görsel regex engelleme, SponsorBlock bölüme-atlamayı-atlama, Gauss çekirdekli yüksek enerji ilerleme çubuğu.

**Öneri / dinamik / yorum filtreleme** — başlık/UP/kanal anahtar sözcükleri, süre, oynatma sayısı, beğeni oranı, takip edilen UP muafiyeti, yetkisiz/yalnızca-ücretli filtreleme, paylaşılan beyaz liste, ticari/yetkisiz dinamikler, UP'un kendi yorumu ve sabitlenmiş yorum muafiyetleri, App+Web birleştirilmiş akış modu.

**Dinamikler, arama ve kullanıcı bilgisi** — UP'ler için özel notlar, 13 ad yuvasında notun-takma-adın-yerini-alması, bağımsız iç içe yorum sıralaması, yerel anahtar sözcük arama filtresi, b23.tv kısa bağlantı atlama, yalnızca-ücretli rozeti, öneri-nedenini-gizleme düğmesi, coin XP görünümü.

**Canlı yayın geliştirmeleri** — hayran madalyası takma paneli, HLS'yi tercih eden DLNA yayın, SuperChat zaman gösterimi, kurtarma için mini pencere alt denetim çubuğu.

**Sistem entegrasyonu ve masaüstü** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), yeniden inşa edilmiş ses-odak yönetimi.

<details>
<summary>Tam özgün özellik/denetim listesi (birebir, PiliNara'dan — genişletmek için tıklayın)</summary>

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

## Sorumluluk Reddi

PiliBabel kişisel, ilgiye dayalı bir projedir ve **yalnızca öğrenme ve test amacıyla** sağlanmıştır; lütfen indirdikten sonra **24 saat** içinde silin.

- PiliBabel **gayri resmî bir üçüncü taraf** istemcidir ve **bilibili ile bağlantılı değildir, onun tarafından onaylanmamıştır veya desteklenmemiştir**.
- Tüm API'ler resmî herkese açık uç noktalardan toplanmıştır; **kırılmış, aşırı yetkili veya ödeme duvarını atlayan hiçbir içerik** sağlanmaz.
- **Yapay zekâ çevirisi üçüncü taraf bir model uç noktasında çalışır.** Varsayılan olarak bu, bilibili'nin kendi ücretsiz herkese açık Index-Translate hizmetidir; kendi API'nize geçerseniz, bu yapılandırdığınız uç noktadır. Çeviri kalitesi ve uygunluk, kullanıcının ve seçilen model sağlayıcısının sorumluluğundadır; bu proje **model veya API anahtarı barındırmaz**.
- Telif hakkına ve bilibili'nin Hizmet Şartlarına saygı gösterin. Sorumlu bir şekilde kullanın.

Açık kaynak alanlarındaki adanmışlıkları için özgün ve yukarı akış yazarlarına saygıyla:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — PiliBabel'in doğrudan üst projesi
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — yerleşik motorun çağırdığı açık kaynak çeviri model ailesi

Herhangi bir içerik haklarınızı ihlal ediyorsa, lütfen kaldırılması için bizimle iletişime geçin.

<br/>

## Lisans

PiliBabel, **GNU Genel Kamu Lisansı v3.0 (GPL-3.0)** altında lisanslanmıştır — PiliNara, PiliPlus ve PiliPala ile aynı lisans. Türetilmiş bir çalışma olduğu için **PiliBabel de GPL-3.0 altında dağıtılmalıdır**: aynı lisansı, telif hakkı bildirimlerini ve bu lisans metnini korumanız şartıyla onu kullanmak, incelemek, paylaşmak ve değiştirmekte özgürsünüz. Bakınız: [`LICENSE`](./LICENSE).

Üçüncü taraf bileşenler (Flutter paketleri, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio) vb.) kendi lisansları altında kalır.

Uygulamayla birlikte gelen **LXGW WenKai** yazı tipi, ayrı olarak **SIL Open Font License 1.1** altında lisanslanmıştır; lisans metni uygulamanın içinde `assets/fonts/LXGWWenKai-OFL.txt` olarak yer alır.

<br/>

## Teşekkürler

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — bilibili'nin açık kaynak çeviri model ailesi ve yerleşik motorun arkasındaki ücretsiz herkese açık uç nokta
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — uygulamayla birlikte gelen açık kaynak Çince yazı tipi, SIL Open Font License 1.1 altında
- ve dahası
- bilibili'nin resmî "AI arayüz çevirisi" özelliğinden ilham alınmıştır.
