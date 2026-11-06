import 'package:PiliPlus/services/ui_translate/vietnamese_ui_translations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns an immediate Vietnamese translation for common UI labels', () {
    expect(vietnameseUiTranslation('首页'), 'Trang chủ');
    expect(vietnameseUiTranslation('AI 翻译'), 'AI Dịch');
    expect(vietnameseUiTranslation('字幕'), 'Phụ đề');
    expect(
      vietnameseUiTranslation('实时字幕不足时自动暂停'),
      'Tự dừng khi thiếu phụ đề realtime',
    );
    expect(
      vietnameseUiTranslation('正在重试出错的字幕分块'),
      'Đang thử lại phần phụ đề bị lỗi',
    );
  });

  test('does not claim dynamic content is a fixed UI label', () {
    expect(vietnameseUiTranslation('Một tiêu đề video bất kỳ'), isNull);
  });
}
