import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/pages/setting/ui_translate/language_search.dart';
import 'package:PiliPlus/services/ui_translate/app_language.dart';

/// 语言选择器的搜索与列表（3.8.8）。
///
/// 回归点：**搜索框曾完全失效**——3.8.2 起监听器只更新了 query 变量、
/// 从不触发重建，于是「输入什么都不出结果、按回车也没反应」。
/// 这里既测纯过滤逻辑，也用组件测试锁住「输入即出结果、不用回车」。
void main() {
  group('语言过滤（纯逻辑）', () {
    test('空查询返回全部语言，数量与清单一致', () {
      expect(
        filterAppLanguagesByQuery(appLanguages, '').length,
        appLanguages.length,
      );
    });

    test('自称名、代码、英文别名都能命中', () {
      expect(
        filterAppLanguagesByQuery(appLanguages, 'français')
            .map((e) => e.code),
        contains('fr'),
      );
      expect(
        filterAppLanguagesByQuery(appLanguages, 'fr').map((e) => e.code),
        contains('fr'),
      );
      expect(
        filterAppLanguagesByQuery(appLanguages, '日本語').map((e) => e.code),
        contains('ja'),
      );
    });

    test('白话字台湾闽南语：自称、去调号拼法、英文名、POJ 都能搜到', () {
      for (final q in <String>[
        'Tâi-gí',
        'tâi-gí',
        'tai-gi',
        'taigi',
        'Taiwanese',
        'POJ',
        'peh-oe-ji',
        '閩南語',
        '台湾闽南语',
      ]) {
        expect(
          filterAppLanguagesByQuery(appLanguages, q).map((e) => e.code),
          contains('nan-TW-latn'),
          reason: '搜「$q」应命中 Tâi-gí',
        );
      }
    });

    test('新增语言固定清单：带调号自称名必须有 ASCII 别名（普通键盘能搜到）', () {
      for (final code in kAliasRequiredCodes) {
        final l = appLanguageByCode(code);
        final aliases = kLanguageSearchAliases[code] ?? const <String>[];
        expect(
          aliases.any((a) => a.codeUnits.every((c) => c < 128)),
          isTrue,
          reason: '$code（${l.name}）没有纯 ASCII 别名，普通键盘搜不到',
        );
        // 自称名本身也要能命中（大小写折叠后 contains）
        expect(
          filterAppLanguagesByQuery(appLanguages, l.name.toLowerCase())
              .map((e) => e.code),
          contains(code),
        );
      }
    });

    test('搜不到就是搜不到', () {
      expect(filterAppLanguagesByQuery(appLanguages, 'zzzz-not-a-lang'), isEmpty);
    });
  });

  group('语言选择器组件', () {
    Future<void> pumpPicker(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: LanguageSearchList(
                selectedCode: 'zh-CN',
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    test('Tâi-gí 紧挨在臺灣閩南語之前', () {
      final codes = pickerLanguageRows.map((e) => e.code).toList();
      final poj = codes.indexOf('nan-TW-latn');
      final tw = codes.indexOf('nan-TW');
      expect(poj, greaterThanOrEqualTo(0));
      expect(tw, greaterThan(poj), reason: '汉字版臺灣閩南語排在白话字版之后');
    });

    test('中文方言只剩 粵語 / Tâi-gí / 臺灣閩南語 三条', () {
      final names = appLanguages.map((e) => e.name).toList();
      expect(names, contains('粵語'));
      expect(names, isNot(contains('繁體粵語')));
      expect(names, isNot(contains('简体粤语')));
      expect(names, isNot(contains('大陆闽南语')));
      // 粤语只有一档，且默认仍是繁體字形。
      expect(
        appLanguages.where((e) => e.code.startsWith('yue')).length,
        1,
      );
      expect(
        appLanguages.firstWhere((e) => e.code == 'yue-Hant').script,
        'Hant',
      );
    });

    test('已下线的语言代码迁到现行条目', () {
      // 旧版本存过这两条的用户，不该被悄悄切回简体中文（等于关掉翻译）。
      expect(appLanguageByCode('yue-Hans').code, 'yue-Hant');
      expect(appLanguageByCode('nan-CN').code, 'nan-TW');
    });

    testWidgets('Tâi-gí 那行带「官方清单外 · 建议自备 API」的小红字', (tester) async {
      await pumpPicker(tester);
      await tester.enterText(find.byType(TextField), 'tâi-gí');
      await tester.pump();
      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.text('官方清单外 · 建议自备 API'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Tâi-gí 在列表里搜得到（输入自称即可命中）', (tester) async {
      await pumpPicker(tester);
      await tester.enterText(find.byType(TextField), 'tâi-gí');
      await tester.pump();
      expect(find.text('Tâi-gí'), findsOneWidget);
      expect(find.text('English'), findsNothing);
    });

    testWidgets('漢字版臺灣閩南語也在列表里', (tester) async {
      await pumpPicker(tester);
      await tester.enterText(find.byType(TextField), '臺灣閩南語');
      await tester.pump();
      // 注意：输入框里也有这段文字，断言要限定在**列表**里。
      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.text('臺灣閩南語'),
        ),
        findsOneWidget,
      );
      // 3.8.10 下线：清单里不再有「大陆闽南语」「简体粤语」。
      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.text('大陆闽南语'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.text('简体粤语'),
        ),
        findsNothing,
      );
    });
  });
}
