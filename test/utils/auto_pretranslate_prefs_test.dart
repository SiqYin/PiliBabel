import 'dart:io';

import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// 「点开视频自动翻译字幕 / 弹幕」两个开关（3.8.8）。
///
/// 默认都要是**开**：这两个开关是给用户「收回自动」用的，不是让新装用户
/// 先去设置里打开一遍才生效。
void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'piliplus-auto-pretranslate-test-',
    );
    Hive.init(tempDir.path);
    GStorage.setting = await Hive.openBox('setting');
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('默认都开着', () {
    expect(Pref.uiTranslateAutoSubtitle, isTrue);
    expect(Pref.uiTranslateAutoDanmaku, isTrue);
  });

  test('用户可以分别关掉，且能读回来', () {
    Pref.uiTranslateAutoSubtitle = false;
    expect(Pref.uiTranslateAutoSubtitle, isFalse);
    expect(Pref.uiTranslateAutoDanmaku, isTrue, reason: '两个开关互相独立');

    Pref.uiTranslateAutoDanmaku = false;
    expect(Pref.uiTranslateAutoDanmaku, isFalse);
  });
}
