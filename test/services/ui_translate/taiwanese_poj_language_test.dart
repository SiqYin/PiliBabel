import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/services/ui_translate/app_language.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';

/// 台湾闽南语（白话字）：系统内置名「台湾闽南语（白话字）」、界面自称 Tâi-gí、
/// 英文名 Taiwanese。目标只有一个硬要求——**全篇 POJ，一个汉字都不许出现**。
void main() {
  const code = 'nan-TW-latn';

  group('Tâi-gí（台湾闽南语·白话字）', () {
    test('清单里有这一条：显示自称 Tâi-gí，代码唯一，属台湾闽南语变体', () {
      final l = appLanguageByCode(code);
      expect(l.code, code);
      expect(l.name, 'Tâi-gí');
      expect(l.official, isFalse, reason: '官方清单不含白话字版');
      expect(l.variantOf, '臺灣閩南語');
      expect(appLanguages.where((e) => e.code == code).length, 1);
    });

    test('提示词写清白话字（POJ）与「一个汉字都不能出现」', () {
      final toModel = appLanguageByCode(code).toModel;
      expect(toModel.contains('POJ'), isTrue);
      expect(toModel.contains('Pe̍h-ōe-jī'), isTrue);
      expect(toModel.contains('一個漢字都不能出現'), isTrue);
      expect(toModel.contains('不得漢羅夾用'), isTrue);
      expect(toModel.contains('Taiwanese'), isTrue, reason: '英文名要带给模型');
    });

    test('不算中文家族：译文里出现汉字必须被判成没翻', () {
      expect(appLanguageByCode(code).chineseFamily, isFalse);
      // 精确代码命中清单条目 → 以 chineseFamily 为唯一事实来源
      expect(SubtitleTranslationOutput.targetUsesHan(code), isFalse);
      expect(SubtitleTranslationOutput.isChineseFamilyTarget(code), isFalse);
      // 汉字版台湾闽南语不受影响，仍然允许汉字
      expect(SubtitleTranslationOutput.targetUsesHan('nan-TW'), isTrue);
      expect(SubtitleTranslationOutput.isChineseFamilyTarget('nan-TW'), isTrue);
    });

    test('不做繁简字形归一化（目标根本不用汉字）', () {
      final l = appLanguageByCode(code);
      expect(l.script, isNull);
      expect(l.scriptRule, isEmpty);
      expect(normalizeScript('Tâi-gí', l.script), 'Tâi-gí');
    });

    test('语言搜索：自称、去调号拼法、英文名、书写系统名都能命中', () {
      // 与选择器里的 hit() 同口径：自称名 / 代码 / 别名，三者折叠后 contains。
      bool hit(String query, String langCode) {
        final q = foldLanguageSearch(query);
        final l = appLanguageByCode(langCode);
        if (foldLanguageSearch(l.name).contains(q)) return true;
        if (foldLanguageSearch(l.code).contains(q)) return true;
        for (final alias
            in kLanguageSearchAliases[langCode] ?? const <String>[]) {
          if (foldLanguageSearch(alias).contains(q)) return true;
        }
        return false;
      }

      for (final q in <String>[
        'Tâi-gí',
        'tâi-gí',
        'TAI-GI',
        'taigi',
        'tâi-uân-gí',
        'Taiwanese',
        'taiwanese',
        'POJ',
        'peh-oe-ji',
        'Pe̍h-ōe-jī',
        '閩南語',
        '台灣閩南語',
        '台湾闽南语',
        '台語',
      ]) {
        expect(hit(q, code), isTrue, reason: '搜「$q」应命中 Tâi-gí');
      }
      expect(hit('français', code), isFalse);
      expect(hit('japanese', code), isFalse);
    });
  });
}
