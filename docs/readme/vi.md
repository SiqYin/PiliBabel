<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Ứng dụng khách Bilibili của bên thứ ba, có dịch bằng AI.</b></p>
    <p>Babel — phá bỏ bức tường ngôn ngữ, để ai cũng được thưởng thức bilibili bằng tiếng của mình.</p>
    <p>Bao gồm dịch 4 ngôn ngữ dân tộc thiểu số của Trung Quốc và 3 phương ngữ tiếng Trung.</p>
    <p>Dịch hoạt động ngay sau khi cài, trên mô hình miễn phí của bilibili — không cần khóa API.</p>
</div>

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Trang chủ" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Động thái" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Của tôi" />
</div>

<br/>

> **Tuyên bố miễn trách.** PiliBabel là ứng dụng **không chính thức, mã nguồn mở, của bên thứ ba**. Nó **không liên kết, không được xác nhận và không được tài trợ bởi** bilibili / bilibili Inc. Mọi API đều lấy từ các điểm truy cập công khai chính thức; **không mở khóa hay bẻ khóa bất kỳ nội dung trả phí nào**. Vui lòng đọc trọn hai mục [Tuyên bố miễn trách](#tuyên-bố-miễn-trách) và [Giấy phép](#giấy-phép).

## PiliBabel là gì?

PiliBabel là một **bản fork độc lập của bên thứ ba, dựng trên [PiliNara](https://github.com/Starfallan/PiliNara)**, và thừa hưởng mọi thứ mà PiliNara thừa hưởng:

```
bilibili (API công khai chính thức)
        ▲
   PiliPala / PiliPalaX        — dự án gốc
        ▲
   PiliPlus                    — bản fork đang phát triển
        ▲
   PiliNara                    — bản fork của PiliPlus (chỉnh sửa cá nhân)
        ▲
   PiliBabel  ← bạn đang ở đây   — bản fork của PiliNara
```

PiliBabel giữ **toàn bộ tính năng của PiliNara / PiliPlus** (xem [danh sách tính năng kế thừa](#danh-sách-tính-năng-kế-thừa-từ-pilinara--piliplus) ở cuối) và bổ sung **một năng lực chủ đạo mà các ứng dụng gốc không có**:

> **Dịch giao diện và nội dung bằng AI** — toàn bộ ứng dụng (nhãn giao diện, tiêu đề video, tên chủ kênh, bình luận, động thái, bảng tin, và cả danmaku trực tiếp) hiển thị bằng ngôn ngữ **mà bạn** chọn.

Và từ phiên bản 1.0, việc đó chạy **ngay sau khi cài**: mô hình dịch đã được **tích hợp sẵn**. bilibili đã mở mã nguồn mô hình dịch của chính mình, [Index-Translate](https://github.com/bilibili/Index-Translate), và phục vụ nó qua một điểm truy cập công khai miễn phí. PiliBabel mặc định trỏ vào đó, nên bản dịch chạy ngay khi bạn cài ứng dụng — không đăng ký, không khóa, không hóa đơn. Nếu muốn dùng mô hình của riêng mình, đường dẫn «API riêng» vẫn còn nguyên, chỉ cách một lần chạm.

## Tính năng chính

- **Dịch bằng AI, ở khắp mọi nơi.** Thanh điều hướng, thẻ video, trang chi tiết, bình luận, động thái, cùng các màn hình Của tôi / Yêu thích / Lịch sử / Tin nhắn / Tìm kiếm — một lượt quét toàn cục bao phủ **khoảng 1650 chuỗi giao diện**, cộng thêm nội dung động (tiêu đề, tên tác giả, các bộ đếm).
- **Hai bộ máy, một công tắc.** *Tích hợp* (mặc định) dùng điểm truy cập miễn phí của mô hình chính thức **Index-Translate-35B-A3B** của bilibili — không cần cấu hình gì. *API riêng* giữ nguyên hành vi trước đây: trỏ tới bất kỳ điểm truy cập `/chat/completions` tương thích OpenAI nào, với URL gốc / khóa / mô hình của bạn. Tính năng tóm tắt video bằng AI và dịch bằng AI vẫn có điểm truy cập và cài đặt **hoàn toàn độc lập**, cùng nằm trong một trang **«Tính năng AI»**.
- **Một danh sách ngôn ngữ, dùng chung cho cả hai bộ máy.** Danh sách ngôn ngữ đích không chia theo bộ máy: bạn chọn bộ máy nào cũng là cùng một danh sách. Nó hợp nhất **150 ngôn ngữ** của mô hình chính thức bilibili với **4 ngôn ngữ dân tộc thiểu số của Trung Quốc và 3 phương ngữ tiếng Trung** mà PiliBabel bổ sung — tiếng Tây Tạng, Duy Ngô Nhĩ, Choang và H'Mông ở một phía; tiếng Quảng Đông, Ngô (Thượng Hải) và Mân Nam ở phía kia — cùng tiếng Trung phồn thể. Các biến thể vùng miền và chữ viết vẫn là **mục riêng biệt** thay vì gộp lại: tiếng Ả Rập Maroc / Ai Cập / Najd / Levant mỗi thứ là một lựa chọn riêng, tương tự tiếng Serbia, Uzbek và Urdu ở dạng chữ Kirin hoặc Latinh.
- **Nói thẳng về phạm vi bao phủ.** Những ngôn ngữ nằm trong danh mục chính thức do mô hình bilibili đảm nhiệm. Vài ngôn ngữ nằm ngoài — tiếng Trung phồn thể, cùng các phương ngữ tiếng Trung và ngôn ngữ dân tộc thiểu số nêu trên mà bilibili không liệt kê — vẫn xuất hiện trong danh sách, có đánh dấu rõ, để bạn thấy ngay rằng muốn kết quả tốt hơn có thể cần mô hình của riêng bạn.
- **Dịch một lần rồi cố định.** Mỗi chuỗi gốc được dịch **đúng một lần**; kết quả lưu cục bộ và **không bao giờ dịch lại** khi bạn mở lại màn hình — cùng nguyên tắc với ứng dụng chính thức, cho bản dịch ổn định và dễ đoán.
- **Nút chuyển «Nguyên văn ⇄ Bản dịch» cho từng bình luận** (một biểu tượng nhỏ, không phải một từ). `@lượt nhắc / [biểu tượng cảm xúc] / #chủ đề# / liên kết` được giữ nguyên như các token, và **bình luận chứa siêu liên kết vẫn được dịch trong khi liên kết vẫn bấm được**.
- **Dịch danmaku** — một công tắc riêng trong hàng điều khiển góc trên bên phải trình phát, **mặc định tắt** và có bước xác nhận mà chính nội dung xác nhận cũng được dịch. Khi đã bật, danmaku phía trước vị trí phát được dịch trước theo **từng lô khoảng 15 giây** (nhảy vào giữa được xử lý đúng chỗ, không phải từ đầu), nên bản dịch thường sẵn sàng khi chúng lướt qua.
- **Công tắc chế độ suy luận** (`enable_thinking`) để cân giữa chất lượng và tốc độ, kèm hai nút **«thử dịch»** và **xóa bộ nhớ đệm** trong cài đặt.
- **Đổi ngôn ngữ nhanh**: yêu cầu theo lô với số luồng đồng thời giới hạn trên bộ nhớ đệm lâu dài; đổi ngôn ngữ sẽ dựng lại màn hình hiện tại một lần, để bạn không phải nhìn mãi vào phần chữ chưa dịch. Tắt dịch bằng AI sẽ trả toàn bộ giao diện về nguyên văn và **không gửi bất kỳ yêu cầu nào**.
- **Hướng dẫn ở lần mở đầu tiên.** Lần đầu mở ứng dụng, một hộp thoại tiếng Anh đề nghị bật dịch. Nếu đồng ý, nó bật dịch, chọn mô hình tích hợp, mở trang cài đặt AI và hỏi ngay bạn muốn ngôn ngữ nào — người dùng mới đi từ «vừa cài xong» tới «đã dịch xong» chỉ với hai lần chạm.
- **Phát được ở mọi nơi trên thế giới.** PiliBabel chọn điểm biên ở nước ngoài (global **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) mà `playurl` định tuyến theo vị trí của bilibili vốn đã cung cấp, thay vì ghim bạn vào một nút ở Trung Quốc đại lục (Alibaba Cloud / Thâm Quyến) — nên người dùng ngoài Trung Quốc đại lục không còn gặp cảnh «tiếng vẫn chạy, hình đứng im». Bạn vẫn có thể chỉ định CDN thủ công trong cài đặt.

## Hai bộ máy dịch

| | Tích hợp (mặc định) | API riêng |
|---|---|---|
| Mô hình | bilibili **Index-Translate-35B-A3B** | bất kỳ mô hình tương thích OpenAI |
| Điểm truy cập | `index-translate.bilibili.com/v1` | URL gốc của bạn |
| Khóa API | **không cần** | của bạn |
| Chi phí | miễn phí | tùy nhà cung cấp |
| Cách gửi | một chuỗi mỗi yêu cầu | theo lô (≤ 16 mỗi yêu cầu) |
| Ngôn ngữ thêm | — | mọi ngôn ngữ mô hình của bạn biết |

**Vì sao bộ máy tích hợp gửi từng chuỗi một.** Index-Translate là mô hình **chuyên** dịch, và cách gọi mà chính tác giả tài liệu hóa là một mẫu đơn phần («dịch đoạn văn sau sang X, chỉ xuất bản dịch»). Vì vậy trên bộ máy này PiliBabel gửi một chuỗi mỗi yêu cầu, thay vì lời nhắc theo lô kiểu «danh sách đánh số / mảng JSON» dùng cho API riêng. Điểm truy cập miễn phí, nên chẳng có gì để được khi đánh cược vào đầu ra theo lô — đây là một đánh đổi có chủ đích: thêm vài yêu cầu để đổi lấy ít hơn hẳn khả năng thất bại.

**Nâng cấp từ 0.3.x.** Phần API riêng bạn đã cấu hình — URL gốc, khóa và mô hình — được **giữ nguyên xi, không bị ghi đè**. Việc chọn bộ máy chỉ mặc định sang mô hình tích hợp, nên lần mở đầu tiên sau khi nâng cấp bạn sẽ dùng mô hình miễn phí của bilibili; mở *Cài đặt → AI → Tính năng AI → bộ máy dịch* và chuyển về *API riêng* là quay lại cấu hình cũ ngay.

## Cách hoạt động của dịch giao diện (kỹ thuật)

Kho mã **không có lớp tài nguyên i18n / ARB nào** — chuỗi giao diện được viết cứng bằng tiếng Trung. Thay vì viết lại từng widget, PiliBabel phủ lên một lớp dịch mỏng:

1. **Một lớp bọc tra cứu toàn cục.** `lib/services/ui_translate/` cung cấp hàm cấp cao nhất `uiTx(String src)`. Chỗ từng là `Text('中文')` nay thành `Text(uiTx('中文'))`. Một **codemod bằng script** đã áp dụng điều này khắp dự án (`tool/ui_translate_*.py`) — khoảng **223 tệp / 1650 chuỗi** — đồng thời tự động bỏ từ khóa `const` đã trở nên không hợp lệ ở những chỗ cần thiết (kể cả generics như `const X<T>(...)` và tên có dấu chấm như `const Positioned.fill(...)`), và chuyển các khai báo `static const` dạng danh sách / map thành `static final`.
2. **Lõi `GetxService`** (`ui_translate_service.dart`):
   - một bộ nhớ đệm lâu dài **nguyên văn → bản dịch** (dựa trên GetStorage), nên mỗi chuỗi chỉ dịch một lần và dùng lại mãi mãi;
   - `tx()` đọc `RxInt revision` trước, rồi quyết định: nếu đang tắt → trả nguyên văn; nếu đích là **tiếng Trung giản thể (`zh-CN`)** → trả nguyên văn mà không gọi API (nội dung bilibili áp đảo là giản thể). Mọi đích khác — kể cả phồn thể, tiếng Quảng Đông, tiếng Ngô và Mân Nam — đều đi qua bộ máy đã cấu hình; **chỉ thuộc nhóm ngôn ngữ Trung Quốc là chưa đủ để bỏ qua dịch**. Sau đó: phục vụ từ bộ nhớ đệm hoặc **xếp hàng**;
   - các chuỗi trong hàng được một **nhóm worker** xử lý, với **áp dụng tăng dần theo từng khối** (mỗi khối trả về lại tăng `revision`, nên chữ cập nhật dần), và kết quả được **lưu bền** (có tiết chế tần suất). Cỡ lô và số luồng đồng thời đi theo bộ máy: **1 mỗi yêu cầu** trên mô hình tích hợp, **≤ 16 với ≤ 10 đang bay** trên API riêng.
3. **Xác định bộ máy.** `TranslateProvider` (`builtin` / `custom`) quyết định URL, khóa và mô hình mà lớp truyền tải dùng; ngoài điều đó, hai bộ máy chia sẻ một đường mã và một danh sách ngôn ngữ — nên đổi bộ máy chỉ là một cài đặt, **không bao giờ là một bộ tính năng khác**.
4. **Lớp truyền tải** dùng lại đúng kênh **truyền phát** đã được kiểm chứng của tính năng tóm tắt video bằng AI — `AiChatService.streamChat` → `{base}/chat/completions` với `stream: true` (tương thích cả với gateway chỉ hỗ trợ truyền phát) — mở rộng để phần dịch dùng được `apiUrl` / `apiKey` / `model` **riêng** và cờ `enable_thinking`. Thay đổi này **tương thích ngược**, nên tóm tắt video vẫn chạy như cũ.
5. **Câu có phần giữ chỗ** đi qua `uiTxP(template, args)`: một câu trọn vẹn chứa `{0}`/`{1}` được dịch như một khóa ổn định (lời nhắc yêu cầu mô hình giữ nguyên phần giữ chỗ), rồi các giá trị được đắp lại — nên những câu kiểu `"共 {0} 条"` được dịch mà không làm hỏng phần động.
6. **Bảng ngôn ngữ** (`app_language.dart`): mỗi `AppLanguage` mang một tên tự gọi để hiển thị, một chuỗi lời nhắc `toModel` mã hóa quy ước chữ viết và vùng miền, cùng một dấu cho biết danh mục chính thức của bilibili có bao phủ nó hay không. Quy tắc chữ viết (giản thể / phồn thể) và yêu cầu nhất quán phương ngữ chỉ **đi tới mô hình qua lời nhắc**, sau đó một lượt chuẩn hóa chữ viết tất định ở phía ứng dụng sẽ sửa những ký tự lạc.
7. **Bình luận** đi qua `uiTxComment(text, id)`, giữ `@ / [biểu tượng] / #chủ đề# / liên kết` nguyên vẹn như token; các đoạn văn bản giàu định dạng có liên kết vẫn được dịch mà vẫn nhận diện được liên kết, và một tập id theo từng bình luận điều khiển nút chuyển «Nguyên văn ⇄ Bản dịch».
8. **Danmaku** (`danmaku/view.dart`): khi công tắc bật, một bộ lắng nghe vị trí chạy qua `[vị trí phát, vị trí phát + 15 giây]` từng giây một và làm nóng `uiTx()` trên nội dung mỗi danmaku, nên chúng được dịch trước khi lên màn hình; khi bật sẽ xóa và vẽ lại khung vẽ.
9. **Khóa lưu trữ**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Giao diện cài đặt**: một trang cấp một duy nhất «Tính năng AI» (`lib/pages/setting/ui_translate/`) với các khối độc lập cho tóm tắt video AI và dịch giao diện.

**CDN toàn cầu (`VideoUtils.getCdnUrl`).** URL luồng được ký, và việc đổi máy chủ của một URL sẽ bị từ chối với 403 — nên phần phát **không bao giờ đổi máy chủ**. PiliBabel trả về URL đã định tuyến theo vị trí mà bilibili giao cho IP của ứng dụng, và khi danh sách ứng viên vốn đã có một điểm biên nước ngoài (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`) thì ưu tiên điểm đó. Với tải xuống, nơi việc đổi máy chủ là an toàn, hệ thống còn ưu tiên điểm biên Akamai toàn cầu và xoay sang ứng viên đã ký kế tiếp khi một tuyến đứng hoặc từ chối nối tiếp. Các liên kết P2P thô `/v/resource` vẫn quay về trung chuyển sẵn có để tránh lỗi 404.

**Đánh đổi thiết kế / giới hạn đã biết.** Vì các chuỗi được bọc tại chỗ thay vì tách ra thành tài nguyên, một số tham số chuỗi không phải `Text` và vài đoạn văn bản giàu định dạng vẫn đang được bổ sung dần. Những chuỗi đồng thời làm **khóa logic** (so sánh bằng `==`, dùng làm tên tab như `简介`, hoặc nhãn liệt kê trong công tắc) **cố ý không** được bọc hàng loạt, để khỏi phá vỡ hành vi. Dịch danmaku là nỗ lực hết mức trên một khung vẽ cuộn — với danmaku cực dày, bạn có thể thấy nguyên văn trong chốc lát trước khi bản dịch tới. Dịch cần mạng; không có mạng thì các đích ngoài tiếng Trung đơn giản là không hiện. Điểm truy cập tích hợp là dịch vụ công khai miễn phí do bilibili vận hành — nếu bị giới hạn tốc độ hay tạm ngưng, ứng dụng sẽ báo rõ và bạn có thể chuyển sang API riêng.

## Biên dịch và kiểm chứng

Ứng dụng được biên dịch bằng Flutter SDK đã vá cùng các gói `material_ui` / `cupertino_ui` đã vá, qua `lib/scripts/patch.ps1` và `lib/scripts/build.ps1` (giống hệt PiliNara / PiliPlus). GitHub Actions tạo **APK gỡ lỗi** sau mỗi lần đẩy mã (`.github/workflows/ui-translate-debug.yml`), và **phát hành thẻ `v*` sẽ tự động biên dịch và phát hành các gói cho Android, Windows và Linux** (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Nền tảng
- [x] Android
- [ ] iOS
- [ ] Máy tính bảng
- [x] Windows
- [x] Linux

PiliBabel phát hành bản dựng cho **Android (APK), Windows và Linux** trong Releases; bản fork này chưa đóng gói iOS và máy tính bảng.

<br/>

## Tải về

Lấy một bản dựng từ **Releases**, hoặc nhân bản kho mã và tự biên dịch tại máy.

### Arch Linux

Cảm ơn [@nlsdt](https://github.com/nlsdt) đã đóng gói (công thức của PiliNara dùng được luôn cho PiliBabel).

```bash
sudo pacman -S pilinara      # từ kho Arch Linux CN
paru -S pilinara-bin         # hoặc qua AUR: pilinara-bin (dựng sẵn) / pilinara (mã nguồn)
```

<br/>

## Danh sách tính năng kế thừa (từ PiliNara / PiliPlus)

Toàn bộ phần dưới đây được kế thừa từ PiliNara (và xa hơn nữa là PiliPlus); PiliBabel phủ thêm lớp dịch bằng AI lên trên.

**Giao diện và thích ứng nền tảng**
- [x] Đổi tên ứng dụng theo từng nền tảng để nhiều ứng dụng cùng tồn tại (PiliBabel cài song song với PiliNara)
- [x] Sửa lỗi hiển thị Flutter trong cửa sổ nhỏ của Xiaomi HyperOS ([#161086](https://github.com/flutter/flutter/issues/161086), qua [venera#467](https://github.com/venera-app/venera/pull/467)); hiệu ứng quay lại dự đoán trên Android
- [x] Tùy chỉnh thứ tự và số lượng thẻ «Của tôi»; xem trước thẻ lịch sử và mục «xem sau»
- [x] Tự động chuyển thanh bên với ngưỡng kích hoạt điều chỉnh được; sao chép ảnh bằng nhấn giữ / nhấp chuột phải; đổi mới diện mạo MD3E

**Hệ thống phông chữ** — một nhóm nhập thống nhất có khử trùng lặp bằng băm nội dung, phông danmaku gộp chung vào cùng nhóm, `loadFontFromList` hỗ trợ ttc, và tên họ phông thuần ASCII.

**Phát, cửa sổ nhỏ và chất lượng** — cửa sổ nhỏ trong ứng dụng (kéo, đổi kích thước, bỏ qua SponsorBlock, PIP hệ thống tự động, thanh tự cứu cho luồng trực tiếp), phát âm thanh đồng thời, âm lượng trong ứng dụng tới 200 %, tên miền CDN video tùy chỉnh và chọn nút theo vùng kèm đo độ trễ, chất lượng mặc định riêng cho nửa màn hình và toàn màn hình, khóa tốc độ khi vuốt lên, điều khiển bằng bàn phím trên máy tính bảng, mốc thời gian SuperChat trực tiếp, nhịp tim cho độ thân thiết của fan khi xem trực tiếp.

**Phụ đề, AI và ngoại tuyến** — phụ đề song ngữ với kiểu dáng phụ đề phụ độc lập, phân tích phụ đề bằng AI (điểm truy cập tương thích OpenAI tùy chỉnh, nhảy tới mốc thời gian, mẫu, hội thoại lưu bền, dự phòng mềm khi không có phụ đề), xuất WEBVTT/SRT, chế độ xem kép cho bộ nhớ đệm ngoại tuyến với quản lý thư mục và lưu bền siêu dữ liệu, xuất bản tải về thư mục Download công khai (Android).

**Danmaku và chặn** — cải thiện tỉ lệ phóng đại danmaku gộp (kiểu [Pakku.js](https://github.com/xmcp/pakku.js)), chặn bằng biểu thức chính quy trực quan dạng danh sách có nhập và xuất, bỏ qua vào trong đoạn SponsorBlock, thanh tiến trình năng lượng cao bằng nhân Gauss.

**Lọc gợi ý / động thái / bình luận** — từ khóa tiêu đề / chủ kênh / khu vực, thời lượng, số lượt xem, tỉ lệ thích, miễn trừ kênh đã theo dõi, lọc nội dung chưa cấp phép / chỉ dành cho người ủng hộ, danh sách trắng chia sẻ, động thái thương mại / chưa cấp phép, miễn trừ bình luận của chính chủ kênh và bình luận ghim, chế độ bảng tin hợp nhất App + Web.

**Động thái, tìm kiếm và thông tin người dùng** — ghi chú riêng cho chủ kênh, ghi chú thay thế biệt danh ở 13 vị trí, sắp xếp độc lập cho trả lời lồng nhau, lọc tìm kiếm bằng từ khóa cục bộ, nhảy qua liên kết rút gọn b23.tv, huy hiệu «chỉ dành cho người ủng hộ», công tắc ẩn lý do gợi ý, hiển thị kinh nghiệm xu.

**Cải thiện xem trực tiếp** — bảng đeo huy hiệu fan, truyền DLNA ưu tiên HLS, hiển thị thời gian SuperChat, thanh điều khiển dưới của cửa sổ nhỏ để tự cứu.

**Tích hợp hệ thống và máy tính để bàn** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), xử lý tiêu điểm âm thanh viết lại.

<details>
<summary>Danh sách tính năng gốc đầy đủ (nguyên văn từ PiliNara — bấm để mở)</summary>

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

## Tuyên bố miễn trách

PiliBabel là dự án cá nhân làm vì hứng thú, cung cấp **chỉ để học tập và thử nghiệm**; vui lòng xóa nó trong vòng **24 giờ** sau khi tải về.

- PiliBabel là ứng dụng **bên thứ ba không chính thức** và **không liên kết, không được xác nhận, không được tài trợ bởi bilibili**.
- Mọi API đều lấy từ các điểm truy cập công khai chính thức; **không cung cấp nội dung bẻ khóa, vượt quyền hay vượt tường trả phí**.
- **Dịch bằng AI chạy trên điểm truy cập mô hình của bên thứ ba.** Mặc định đó là dịch vụ Index-Translate công khai miễn phí của chính bilibili; nếu bạn chuyển sang API riêng thì đó là điểm truy cập bạn đã cấu hình. Chất lượng và tính tuân thủ của bản dịch thuộc trách nhiệm của người dùng và nhà cung cấp mô hình đã chọn; dự án này **không lưu trữ mô hình nào và không cung cấp khóa API nào**.
- Hãy tôn trọng bản quyền và điều khoản sử dụng của bilibili. Dùng một cách có trách nhiệm.

Tri ân các tác giả gốc và các dự án tiền nhiệm vì sự cống hiến cho mã nguồn mở:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — dự án cha trực tiếp của PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — họ mô hình dịch mã nguồn mở mà bộ máy tích hợp gọi tới

Nếu có nội dung nào xâm phạm quyền của bạn, hãy liên hệ để chúng tôi gỡ bỏ.

<br/>

## Giấy phép

PiliBabel được cấp phép theo **GNU General Public License v3.0 (GPL-3.0)** — cùng giấy phép với PiliNara, PiliPlus và PiliPala. Vì là tác phẩm phái sinh, **PiliBabel cũng phải được phân phối theo GPL-3.0**: bạn được tự do dùng, nghiên cứu, chia sẻ và sửa đổi, miễn là giữ nguyên giấy phép, các thông báo bản quyền và toàn văn giấy phép này. Xem [`LICENSE`](./LICENSE).

Các thành phần bên thứ ba (các gói Flutter, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), v.v.) vẫn theo giấy phép riêng của chúng.

<br/>

## Lời cảm ơn

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — họ mô hình dịch mã nguồn mở của bilibili, và là điểm truy cập công khai miễn phí đứng sau bộ máy tích hợp
- và nhiều dự án khác
- Lấy cảm hứng từ «dịch giao diện bằng AI» chính thức của bilibili.
