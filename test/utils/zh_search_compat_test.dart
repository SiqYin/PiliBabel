// 简繁搜索兼容：字形归一 / 检索变体 / 兼容 contains。
//
// 表由 glossary/make_zh_char_map.py 从 OpenCC 字级字典生成，
// 这里锁定的是**搜索语义**：简体输入能命中繁體标题、繁體输入能命中简体
// 标题，联想/变体的方向恒定。
import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/services/ui_translate/app_language.dart';
import 'package:PiliPlus/utils/zh_search_compat.dart';

void main() {
  test('zhToHans folds traditional-only shapes to their simplified rep', () {
    expect(zhToHans('歷史'), '历史');
    expect(zhToHans('發現'), '发现');
    expect(zhToHans('頭髮'), '头发');
    expect(zhToHans('麵包'), '面包');
    // 后/裡/幹：多候选歧义字按等价类归一
    expect(zhToHans('後面'), '后面');
    expect(zhToHans('裡面'), '里面');
    expect(zhToHans('幹活'), '干活');
  });

  test('zhToHans keeps non-Han text and simplified text untouched', () {
    expect(zhToHans('历史'), '历史');
    expect(zhToHans(' genshin impact 2026 '), ' genshin impact 2026 ');
    expect(zhToHans('コメント'), 'コメント');
    expect(zhToHans(''), '');
  });

  test('zhToHant is the mirror direction', () {
    // 繁體代表取 OpenCC 首选形：发 → 發（髮 是替身，见变体测试）。
    expect(zhToHant('历史'), '歷史');
    expect(zhToHant('发现'), '發現');
    expect(zhToHant('头发'), '頭發');
    // 已经是繁體的字形不再变
    expect(zhToHant('歷史'), '歷史');
  });

  test('both directions are idempotent', () {
    expect(zhToHans(zhToHans('歷史頭髮')), zhToHans('歷史頭髮'));
    expect(zhToHant(zhToHant('历史头发')), zhToHant('历史头发'));
  });

  test('zhSearchVariants returns only the differing other script(s)', () {
    // 简体输入 → 补繁體形（代表形第一，替身殿后）
    final hist = zhSearchVariants('历史');
    expect(hist.first, '歷史');
    expect(hist, contains('曆史'));
    expect(hist.length, lessThan(4));
    // 繁體输入 → 补简体形第一
    final histHant = zhSearchVariants('歷史');
    expect(histHant.first, '历史');
    expect(histHant.length, lessThan(4));
    // 无可转换字形 → 无变体（纯英文/数字）
    expect(zhSearchVariants('genshin'), <String>[]);
    // 混排：只有汉字部分参与变体
    final variants = zhSearchVariants('MMD歷史');
    expect(variants.first, 'MMD历史');
    expect(variants.length, lessThan(4));
  });

  test('multi-candidate chars get substitute variants, not just the rep', () {
    // 发 的繁體代表是 發，但 髮 也是合法字形：头发 要能补搜出 頭髮。
    final hairVariants = zhSearchVariants('头发');
    expect(hairVariants.first, '頭發');
    expect(hairVariants, contains('頭髮'));
    // 干 的繁體候选里有 乾：干隆 的替身能命中 乾隆。
    expect(zhSearchVariants('干隆'), contains('乾隆'));
    // 替身按单字替换展开，不做笛卡尔积：条数有上限。
    expect(zhSearchVariants('头发').length, lessThan(4));
  });

  test('zhCompatContains matches across scripts and case', () {
    expect(zhCompatContains('歷史記錄', '历史'), true);
    expect(zhCompatContains('历史记录', '歷史'), true);
    expect(zhCompatContains('Genshin Impact', 'GENSHIN'), true);
    expect(zhCompatContains('干物妹', '幹物妹'), true);
    expect(zhCompatContains('历史记录', '幹活'), false);
    // 空查询恒命中、空原文不命中
    expect(zhCompatContains('历史', ''), true);
    expect(zhCompatContains('', '历史'), false);
  });

  test('language name folding survives script mixing (via foldLanguageSearch)',
      () {
    // foldLanguageSearch 现在叠加了 zhToHans：简繁两种字形打语言名都能命中。
    // 简体「吴语」与繁體「吳語」折叠后必然相等。
    expect(zhToHans('吳語'), '吴语');
    expect(zhToHans('繁體中文'), '繁体中文');
  });

  test('looksLikeChineseScript accepts traditional, rejects Japanese', () {
    expect(looksLikeChineseScript('历史'), true);
    expect(looksLikeChineseScript('歷史'), true);
    expect(looksLikeChineseScript(''), false);
    // 假名 → 日文，不是中文脚本
    expect(looksLikeChineseScript('コメント'), false);
    // 日文独有字（新字体）→ 日文
    expect(looksLikeChineseScript('検索'), false);
  });
}
