import 'package:PiliPlus/services/ui_translate/subtitle_text_quality.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detects Han across unified, extension and compatibility planes', () {
    for (final rune in const [
      0x3007,
      0x4E00,
      0x3400,
      0x20000,
      0x2B820,
      0x2EBF0,
      0x2F800,
      0x30000,
      0x31350,
    ]) {
      expect(
        SubtitleTextQuality.containsHan(String.fromCharCode(rune)),
        isTrue,
        reason: 'U+${rune.toRadixString(16).toUpperCase()}',
      );
    }
    expect(SubtitleTextQuality.containsHan('Xin chao 123'), isFalse);
  });

  test('rejects a Vietnamese cue with one residual Han character', () {
    expect(
      () => SubtitleTranslationOutput.sanitizeAndValidate(
        const ['你好'],
        const ['Xin chao 〇'],
        targetLanguage: 'vi',
      ),
      throwsFormatException,
    );
  });
}
