# -*- coding: utf-8 -*-
"""把 1.1.0 的「主题与色彩 / 内置字体」两条特性、霞鹜文楷致谢与许可说明
写进全部 12 份 README。插桩位置全部靠锚点定位，不写死行号。"""
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

THEME = {
'en': '- **A "Theme & Colour" page, Material You style.** Light / dark / follow-system are chosen from **three live preview cards** — each one renders a miniature of the real interface in the exact colours that mode would apply (the "follow system" card is split diagonally, light over dark). Below them: **dynamic colour** (taken from the system wallpaper where the device supports it), **high-contrast dark** (true-black surfaces, easier on the eyes at night) and **always-dark player**. The colour half keeps the full FlexScheme palette — **19 seed colours** plus a separate **"palette style"** that decides how every container colour is derived from the seed, independently of which seed you pick.',
'zh': '- **Material You 風格的「主題與色彩」。** 淺色 / 深色 / 跟隨系統改用三張**即時預覽卡**來挑 —— 每張卡都用該模式實際會套用的配色，先把迷你介面畫給你看（「跟隨系統」那張是左上淺色、右下深色的對角拼接）。下方是**動態取色**（支援的裝置會跟著系統桌布取色）、**高對比度深色**（純黑介面，夜間更護眼）與**播放頁固定深色**。色彩那一半保留完整的 FlexScheme 調色板 —— **19 種色相**之外還多一個獨立的**「調色板風格」**，決定同一色相下所有容器色怎麼衍生，與你挑哪個色相互不干擾。',
'yue': '- **Material You 風格嘅「主題同色彩」。** 淺色 / 深色 / 跟系統改用三張**即時預覽卡**嚟揀 —— 每張卡都用嗰個模式實際會套用嘅配色，預先將迷你介面畫畀你睇（「跟系統」嗰張係左上淺色、右下深色嘅對角拼接）。下面係**動態取色**（支援嘅裝置會跟系統桌布取色）、**高對比度深色**（純黑介面，夜間更護眼）同**播放頁固定深色**。色彩嗰半保留完整嘅 FlexScheme 調色板 —— 除咗**19 種色相**，仲多一個獨立嘅**「調色板風格」**，決定同一色相下所有容器色點樣衍生，同你揀邊隻色相無關。',
'ja': '- **Material You スタイルの「テーマとカラー」。** ライト / ダーク / システムに従うは、**3枚のライブプレビューカード**から選べます。各カードには、そのモードで実際に適用される配色で描いた画面の縮小図が表示されます（「システムに従う」は左上ライト・右下ダークの対角分割）。下には**ダイナミックカラー**（対応端末では壁紙の色彩から取得）、**高コントラストダーク**（純黒の画面、夜にやさしい）、**再生画面は常にダーク**が並びます。カラー側は FlexScheme のパレットをそのまま維持し、**19 種のシードカラー**に加えて独立した**「パレットスタイル」**を選べます —— どのシードを選ぶかとは独立に、同じ色相から各コンテナの色をどう導くかだけが変わります。',
'fr': '- **Une page « Thème et couleurs » de style Material You.** Clair / sombre / suivre le système se choisissent parmi **trois cartes d\'aperçu en direct** — chacune dessine une miniature de l\'interface réelle avec les couleurs que ce mode appliquerait (la carte « suivre le système » est coupée en diagonale, clair en haut à gauche, sombre en bas à droite). En dessous : **couleurs dynamiques** (issues du fond d\'écran système quand l\'appareil le permet), **sombre haute contrastée** (surfaces noires, plus reposantes la nuit) et **lecteur toujours sombre**. La moitié couleur conserve toute la palette FlexScheme — **19 teintes de base**, plus un **« style de palette »** distinct qui décide de la façon dont chaque couleur de conteneur est dérivée de la teinte de base, indépendamment de la teinte choisie.',
'de': '- **Eine Seite „Design & Farben" im Material-You-Stil.** Hell / dunkel / Systemeinstellung werden über **drei Live-Vorschaukarten** gewählt — jede zeigt eine Miniatur der echten Oberfläche in genau den Farben, die der jeweilige Modus anwenden würde (die Karte „Systemeinstellung" ist diagonal geteilt, hell oben links, dunkel unten rechts). Darunter: **dynamische Farben** (vom System-Hintergrundbild übernommen, sofern das Gerät es unterstützt), **dunkel mit hohem Kontrast** (echt schwarze Flächen, nachts angenehmer) und **Player immer dunkel**. Die Farbhälfte behält die vollständige FlexScheme-Palette — **19 Basisfarben** sowie ein eigenständiger **„Palettenstil"**, der bestimmt, wie alle Containerfarben aus der Basisfarbe abgeleitet werden, unabhängig davon, welche Basisfarbe Sie wählen.',
'es': '- **Una página «Tema y color» de estilo Material You.** Claro / oscuro / seguir al sistema se eligen en **tres tarjetas de vista previa en vivo** — cada una dibuja una miniatura de la interfaz real con los colores que ese modo aplicaría (la tarjeta «seguir al sistema» va partida en diagonal, claro arriba a la izquierda, oscuro abajo a la derecha). Debajo: **color dinámico** (tomado del fondo de pantalla del sistema cuando el dispositivo lo permite), **oscuro de alto contraste** (superficies negras, más agradable de noche) y **reproductor siempre oscuro**. La mitad de color mantiene la paleta FlexScheme completa: **19 colores base** más un **«estilo de paleta»** aparte que decide cómo se deriva cada color de contenedor a partir del color base, con independencia de qué color base elijas.',
'ko': '- **Material You 스타일의 「테마 및 색상」.** 라이트 / 다크 / 시스템 따르기는 **실시간 미리보기 카드** 세 장으로 고른다. 각 카드에는 그 모드에서 실제로 적용될 색으로 앱 화면을 축소해 보여준다(「시스템 따르기」는 좌상단 라이트 · 우하단 다크의 대각 분할). 그 아래에는 **동적 색상**(지원되는 기기에서는 시스템 배경화면에서 추출), **고대비 다크**(순수 검은 배경, 야간에 눈부심 감소), **재생 화면은 항상 다크**가 있다. 색상 쪽은 FlexScheme 팔레트를 그대로 유지하며, **19가지 시드 컬러**와 별개로 독립적인 **「팔레트 스타일」**을 고를 수 있다 — 어떤 시드 색을 고르는지와 무관하게, 같은 색상에서 모든 컨테이너 색을 어떻게 유도할지만 바꾼다.',
'ar': '- **صفحة «السمة والألوان» بأسلوب Material You.** يُختار الوضع الفاتح / الداكن / اتباع النظام من **ثلاث بطاقات معاينة حيّة** — ترسم كل بطاقة نموذجًا مصغّرًا من الواجهة الحقيقية بالألوان التي سيطبّقها ذلك الوضع فعلًا (بطاقة «اتباع النظام» مقسومة قطريًا: الفاتح أعلى اليسار والداكن أسفل اليمين). أسفلها: **ألوان ديناميكية** (مأخوذة من خلفية النظام حيث يدعم الجهاز ذلك)، **وضع داكن عالي التباين** (أسطح سوداء تمامًا، أرقّ بالعين ليلًا)، و**مشغّل داكن دائمًا**. يحتفظ القسم اللوني بلوحة FlexScheme كاملة — **19 لونًا أساسيًا** إضافةً إلى **«نمط لوحة ألوان»** مستقل يحدّد كيف يُشتق كل لون حاوية من اللون الأساسي، بمعزل عن اللون الأساسي الذي تختاره.',
'vi': '- **Trang "Chủ đề & Màu sắc" theo phong cách Material You.** Sáng / tối / theo hệ thống được chọn từ **ba thẻ xem trước trực tiếp** — mỗi thẻ vẽ bản thu nhỏ của giao diện thật với đúng bộ màu mà chế độ đó sẽ áp dụng (thẻ "theo hệ thống" được chia theo đường chéo, sáng ở góc trên trái, tối ở góc dưới phải). Bên dưới là **màu động** (lấy từ ảnh nền hệ thống nếu thiết bị hỗ trợ), **tối tương phản cao** (nền đen tuyệt đối, dịu mắt hơn ban đêm) và **trình phát luôn tối**. Phần màu sắc giữ nguyên bảng màu FlexScheme — **19 màu gốc** cùng một **"kiểu bảng màu"** riêng biết quyết định mọi màu vùng chứa được suy ra từ màu gốc ra sao, độc lập với việc bạn chọn màu gốc nào.',
'ms': '- **Halaman "Tema & Warna" gaya Material You.** Light / dark / ikut sistem dipilih daripada **tiga kad pratonton langsung** — setiap kad melukis miniatur antara muka sebenar dengan warna yang akan digunakan mod tersebut (kad "ikut sistem" dibelah secara diagonal, light di kiri atas, dark di kanan bawah). Di bawahnya: **warna dinamik** (diambil daripada wallpaper sistem bila peranti menyokongnya), **gelap kontras tinggi** (permukaan hitam sepenuhnya, lebih nyaman pada waktu malam) dan **pemain sentiasa gelap**. Bahagian warna mengekalkan palet FlexScheme penuh — **19 warna asas** berserta **"gaya palet"** berasingan yang menentukan bagaimana setiap warna bekas dihasilkan daripada warna asas, secara bebas daripada warna asas yang anda pilih.',
'id': '- **Halaman "Tema & Warna" bergaya Material You.** Terang / gelap / ikuti sistem dipilih dari **tiga kartu pratinjau langsung** — setiap kartu menggambar versi mini antarmuka asli dengan warna yang benar-benar akan dipakai mode tersebut (kartu "ikuti sistem" terbelah diagonal, terang di kiri atas, gelap di kanan bawah). Di bawahnya: **warna dinamis** (diambil dari wallpaper sistem bila perangkat mendukungnya), **gelap kontras tinggi** (permukaan hitam pekat, lebih nyaman di malam hari) dan **pemutar selalu gelap**. Bagian warna mempertahankan palet FlexScheme penuh — **19 warna dasar** ditambah **"gaya palet"** tersendiri yang menentukan bagaimana setiap warna wadah diturunkan dari warna dasar, secara independen dari warna dasar yang Anda pilih.',
}

FONT = {
'en': '- **LXGW WenKai ships with the app.** The **LXGW WenKai (霞鹜文楷)** typeface is **bundled and set as the default** — a warm, highly legible Chinese font you have the moment you install, instead of hunting for one in a picker. It applies to the whole interface *and* to danmaku. You can still switch back to the system font, pick any installed system font, or import your own `.ttf` / `.otf` / `.ttc`; a font you had explicitly chosen before is kept across the upgrade. Weight and size stay adjustable as before.',
'zh': '- **內建霞鹜文楷。** App 直接內嵌**霞鹜文楷（LXGW WenKai）**，而且是**預設字體** —— 裝完就有，不用自己去字體清單裡翻。介面與彈幕都適用。當然還是可以改回系統字體、挑選系統上任何已安裝字體，或匯入自己的 `.ttf` / `.otf` / `.ttc`；升級前你若明確選過別的字體，會原樣保留。字重與字級照樣可調。',
'yue': '- **內建霞鹜文楷。** App 直接內嵌**霞鹜文楷（LXGW WenKai）**，而且係**預設字體** —— 裝完就有，唔使自己喺字體清單度搵。介面同彈幕都適用。當然仲可以改返系統字體、揀系統上任一已安裝字體，或者匯入自己嘅 `.ttf` / `.otf` / `.ttc`；升級前你若明確揀過其他字體，會原樣保留。字重同字級照樣調得。',
'ja': '- **LXGW WenKai を同梱。** 温かく読みやすい中文字体 **霞鹜文楷（LXGW WenKai）** を**同梱し、初期値として設定**している。インストール直後から使えて、フォント一覧を探す必要はない。画面全体のほか**弾幕（danmaku）**にも適用される。システムフォントに戻すことも、端末にインストール済みのフォントを選ぶことも、`.ttf` / `.otf` / `.ttc` を自分で読み込むことも可能で、更新前に明示的に選んでいたフォントはそのまま維持される。字重と字も従来どおり調整できる。',
'fr': '- **LXGW WenKai est fourni avec l\'application.** La police **霞鹜文楷 (LXGW WenKai)** est **incluse et définie par défaut** — une police chinoise chaleureuse et très lisible, disponible dès l\'installation, au lieu d\'aller la chercher dans un sélecteur. Elle s\'applique à toute l\'interface *et* aux danmaku. Vous pouvez revenir à la police système, choisir n\'importe quelle police installée, ou importer votre propre `.ttf` / `.otf` / `.ttc` ; une police choisie explicitement avant la mise à jour est conservée. Le poids et la taille restent réglables comme avant.',
'de': '- **LXGW WenKai ist mitgeliefert.** Die Schrift **霞鹜文楷 (LXGW WenKai)** ist **enthalten und als Standard gesetzt** — eine warme, sehr gut lesbare chinesische Schrift, die Sie direkt nach der Installation haben, statt sie in einer Auswahlliste zu suchen. Sie gilt für die gesamte Oberfläche *und* für die Danmaku. Sie können weiterhin zur Systemschrift wechseln, jede installierte Schrift wählen oder eine eigene `.ttf` / `.otf` / `.ttc` importieren; eine zuvor bewusst gewählte Schrift bleibt beim Update erhalten. Schriftschnitt und Größe sind wie bisher einstellbar.',
'es': '- **LXGW WenKai viene incluido.** La tipografía **霞鹜文楷 (LXGW WenKai)** está **incluida y configurada como predeterminada** — una fuente china cálida y muy legible que tienes nada más instalar, en lugar de buscarla en un selector. Se aplica a toda la interfaz *y* a los danmaku. Puedes volver a la fuente del sistema, elegir cualquier fuente instalada o importar tu propio `.ttf` / `.otf` / `.ttc`; si antes habías elegido una fuente explícitamente, se conserva tras la actualización. El peso y el tamaño siguen siendo ajustables como antes.',
'ko': '- **LXGW WenKai 내장.** 따뜻하고 가독성이 높은 중국어 글꼴 **霞鹜文楷(LXGW WenKai)** 을 **앱에 내장해 기본값으로 설정**했다. 설치 직후부터 쓸 수 있고, 글꼴 목록에서 찾아 고를 필요가 없다. 앱 전체에 적용되며 **다마쿠**에도 함께 쓰인다. 시스템 글꼴로 되돌리거나, 기기에 설치된 아무 글꼴이나 고르거나, `.ttf` / `.otf` / `.ttc` 를 직접 가져오는 것도 가능하다. 업그레이드 전에 명시적으로 골랐던 글꼴은 그대로 유지된다. 굵기와 크기도 예전처럼 조절할 수 있다.',
'ar': '- **LXGW WenKai مُضمَّن مع التطبيق.** خط **霞鹜文楷 (LXGW WenKai)** **مضمَّن ومضبوطًا كخط افتراضي** — خط صيني دافئ وسهل القراءة جدًا، متوفر فور التثبيت بدل البحث عنه في قائمة الخطوط. يُطبَّق على الواجهة كاملة *وعلى* الدانماكو. وما زال بإمكانك العودة إلى خط النظام، أو اختيار أي خط مثبَّت على الجهاز، أو استيراد ملفك الخاص `.ttf` / `.otf` / `.ttc`؛ ويُحتفظ بالخط الذي اخترته صراحةً قبل الترقية. ولا يزال ضبط السماكة والحجم متاحًا كما كان.',
'vi': '- **LXGW WenKai đi kèm sẵn trong ứng dụng.** Phông chữ **霞鹜文楷 (LXGW WenKai)** được **đóng gói và đặt làm mặc định** — một phông Trung Quốc ấm áp và rất dễ đọc, có ngay sau khi cài đặt mà không phải tìm trong danh sách. Nó áp dụng cho toàn bộ giao diện *và* cho danmaku. Bạn vẫn có thể chuyển về phông hệ thống, chọn bất kỳ phông nào đã cài, hoặc nhập phông `.ttf` / `.otf` / `.ttc` của riêng mình; nếu trước đây bạn đã chủ động chọn một phông, lựa chọn đó được giữ nguyên khi nâng cấp. Độ đậm và cỡ chữ vẫn chỉnh được như trước.',
'ms': '- **LXGW WenKai disertakan bersama aplikasi.** Fon **霞鹜文楷 (LXGW WenKai)** telah **dibungkus dan ditetapkan sebagai lalai** — fon Cina yang hangat dan sangat mudah dibaca, ada sebaik sahaja dipasang tanpa perlu mencarinya dalam senarai. Ia digunakan pada keseluruhan antara muka *dan* pada danmaku. Anda masih boleh bertukar kepada fon sistem, memilih mana-mana fon yang telah dipasang, atau mengimport `.ttf` / `.otf` / `.ttc` sendiri; fon yang anda pilih secara jelas sebelum ini akan dikekalkan selepas naik taraf. Berat dan saiz fon masih boleh laras seperti biasa.',
'id': '- **LXGW WenKai sudah disertakan.** Fon **霞鹜文楷 (LXGW WenKai)** **dikemas dan dijadikan bawaan** — fon Tionghoa yang hangat dan sangat mudah dibaca, langsung tersedia begitu aplikasi dipasang, tanpa perlu mencarinya di dalam daftar. Fon ini berlaku untuk seluruh antarmuka *dan* untuk danmaku. Anda tetap bisa beralih ke fon sistem, memilih fon sistem mana pun yang terpasang, atau mengimpor `.ttf` / `.otf` / `.ttc` sendiri; fon yang sebelumnya Anda pilih secara eksplisit tetap dipertahankan saat pembaruan. Berat dan ukuran fon tetap bisa diatur seperti sebelumnya.',
}

ACK = {
'en': '- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — the open-source Chinese typeface bundled with the app, under the SIL Open Font License 1.1',
'zh': '- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai)（霞鹜文楷）—— App 內嵌的開源中文字體，採 SIL Open Font License 1.1 授權',
'yue': '- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai)（霞鹜文楷）—— App 內嵌嘅開源中文字體，採 SIL Open Font License 1.1 授權',
'ja': '- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai)（霞鹜文楷）—— 同梱しているオープンソースの中文字体。SIL Open Font License 1.1',
'fr': '- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — la police chinoise open source incluse dans l\'application, sous licence SIL Open Font License 1.1',
'de': '- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — die quelloffene chinesische Schrift, die der App beiliegt, unter der SIL Open Font License 1.1',
'es': '- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — la tipografía china de código abierto incluida en la aplicación, bajo la SIL Open Font License 1.1',
'ko': '- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai)(霞鹜文楷) — 앱에 내장된 오픈소스 중국어 글꼴. SIL Open Font License 1.1',
'ar': '- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — الخط الصيني مفتوح المصدر المضمَّن مع التطبيق، برخصة SIL Open Font License 1.1',
'vi': '- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — phông chữ Trung Quốc mã nguồn mở được đóng gói trong ứng dụng, theo giấy phép SIL Open Font License 1.1',
'ms': '- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — fon Tionghoa sumber terbuka yang disertakan bersama aplikasi, di bawah lesen SIL Open Font License 1.1',
'id': '- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — font Tionghoa sumber terbuka yang disertakan dalam aplikasi, berlisensi SIL Open Font License 1.1',
}

LICENSE = {
'en': 'The bundled **LXGW WenKai** typeface is licensed separately under the **SIL Open Font License 1.1**; its licence text ships inside the app as `assets/fonts/LXGWWenKai-OFL.txt`.',
'zh': '內嵌的 **霞鹜文楷**另行以 **SIL Open Font License 1.1** 授權，其授權文本隨 App 一併分發，位於 `assets/fonts/LXGWWenKai-OFL.txt`。',
'yue': '內嵌嘅**霞鹜文楷**另行以 **SIL Open Font License 1.1** 授權，其授權文本隨 App 一併分發，喺 `assets/fonts/LXGWWenKai-OFL.txt`。',
'ja': '同梱の **霞鹜文楷** は **SIL Open Font License 1.1** で別途ライセンス供与されています。ライセンス本文はアプリ内の `assets/fonts/LXGWWenKai-OFL.txt` に同梱されています。',
'fr': 'La police **霞鹜文楷** incluse est soumise séparément à la **SIL Open Font License 1.1** ; son texte de licence est distribué avec l\'application dans `assets/fonts/LXGWWenKai-OFL.txt`.',
'de': 'Die mitgelieferte Schrift **霞鹜文楷** steht separat unter der **SIL Open Font License 1.1**; ihr Lizenztext wird der App als `assets/fonts/LXGWWenKai-OFL.txt` beiliegen.',
'es': 'La tipografía **霞鹜文楷** incluida se licencia por separado bajo la **SIL Open Font License 1.1**; su texto de licencia se distribuye con la aplicación en `assets/fonts/LXGWWenKai-OFL.txt`.',
'ko': '내장된 **霞鹜文楷**은 별도로 **SIL Open Font License 1.1** 라이선스를 따르며, 라이선스 전문은 `assets/fonts/LXGWWenKai-OFL.txt` 로 함께 배포됩니다.',
'ar': 'خط **霞鹜文楷** المُضمَّن مرخَّص بشكل منفصل بموجب **رخصة SIL Open Font License 1.1**، ويُوزَّع نص رخصته مع التطبيق في `assets/fonts/LXGWWenKai-OFL.txt`.',
'vi': 'Phông chữ **霞鹜文楷** được đóng gói được cấp phép riêng theo **SIL Open Font License 1.1**; văn bản giấy phép đi kèm trong ứng dụng tại `assets/fonts/LXGWWenKai-OFL.txt`.',
'ms': 'Fon **霞鹜文楷** yang disertakan dilesenkan secara berasingan di bawah **SIL Open Font License 1.1**; teks lesennya disertakan bersama aplikasi sebagai `assets/fonts/LXGWWenKai-OFL.txt`.',
'id': 'Fon **霞鹜文楷** yang disertakan berlisensi secara terpisah di bawah **SIL Open Font License 1.1**; teks lisensinya disertakan bersama aplikasi sebagai `assets/fonts/LXGWWenKai-OFL.txt`.',
}

FILES = {
    'README.md': 'en',
    'README.zh.md': 'zh',
    'README.yue.md': 'yue',
    'README.ja.md': 'ja',
    'README.fr.md': 'fr',
    'README.de.md': 'de',
    'README.es.md': 'es',
    'README.ko.md': 'ko',
    'README.ar.md': 'ar',
    'README.vi.md': 'vi',
    'README.ms.md': 'ms',
    'README.id.md': 'id',
}


def read(path):
    with io.open(path, encoding='utf-8') as f:
        return f.read().split('\n')


def write(path, lines):
    with io.open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(lines))


def patch(path, lang):
    lines = read(path)
    # 幂等：已打过补丁就跳过，避免重跑把内容插两遍
    if any('LXGWWenKai-OFL.txt' in l for l in lines):
        return None
    changed = []

    # ① 特性两条：插在特性列表末尾（下一个 "## " 之前的空行处）
    headings = [i for i, l in enumerate(lines) if l.startswith('## ')]
    engines = headings[2]
    insert_at = engines - 1  # engines 标题前的空行
    while insert_at > 0 and lines[insert_at - 1].strip() == '':
        insert_at -= 1
    new = [THEME[lang], FONT[lang]]
    lines[insert_at:insert_at] = new
    changed.append(f'features +{len(new)} @ line {insert_at + 1}')

    # ② 致谢：只认最后一节（致谢）里的 Index-Translate 行。
    # 「继承功能清单」里也有一条同名链接，取第一条会插错地方。
    heads = [i for i, l in enumerate(lines) if l.startswith('## ')]
    ack_head = heads[-1]
    ack_at = None
    for i in range(ack_head, len(lines)):
        if lines[i].startswith('- ') and 'bilibili/Index-Translate)' in lines[i]:
            ack_at = i + 1
            break
    if ack_at is None:
        raise SystemExit(f'{path}: 致谢段里找不到 Index-Translate 行')
    lines[ack_at:ack_at] = [ACK[lang]]
    changed.append(f'ack @ line {ack_at + 1}')

    # ③ 许可说明：放在致谢标题前那个 <br/> **之前**（即协议段末尾）
    br = None
    for i in range(ack_head - 1, 0, -1):
        if lines[i].strip() == '<br/>':
            br = i
            break
    if br is None:
        raise SystemExit(f'{path}: 找不到致谢前的 <br/>')
    lines[br:br] = ['', LICENSE[lang]]
    changed.append(f'license @ line {br + 1}')

    write(path, lines)
    return changed


def main():
    for name, lang in FILES.items():
        path = os.path.join(ROOT, name)
        if not os.path.exists(path):
            print(f'SKIP  {name} (不存在)')
            continue
        result = patch(path, lang)
        if result is None:
            print(f'SKIP  {name} (已含 1.1.0 内容)')
            continue
        for c in result:
            print(f'OK    {name}: {c}')


if __name__ == '__main__':
    main()
