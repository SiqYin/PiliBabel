import 'dart:io';

import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory storageDirectory;

  setUpAll(() async {
    storageDirectory = await Directory.systemTemp.createTemp(
      'pilibabel-glossary-test-',
    );
    appSupportDirPath = storageDirectory.path;
    await GStorage.init();
    UiTranslateService.warmGlossaryForTest();
  });

  tearDownAll(() async {
    await GStorage.close();
    await storageDirectory.delete(recursive: true);
  });

  test(
    'embedded glossary term is routed to the model with an official hint',
    () {
      const source = '绝区零的新剧情很精彩';
      final service = UiTranslateService();

      expect(service.glossaryTranslationForTest(source, 'ja'), isNull);

      final hints = UiTranslateService.glossaryPromptHintsForTest([
        source,
      ], 'ja');
      expect(hints, contains('绝区零'));
      expect(hints, contains('ゼンゼロ'));
    },
  );

  test('standalone glossary term still uses the preferred official name', () {
    final service = UiTranslateService();

    expect(service.glossaryTranslationForTest('绝区零', 'ja'), 'ゼンゼロ');
  });
}
