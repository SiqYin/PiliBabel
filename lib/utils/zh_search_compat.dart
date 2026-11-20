// 简繁搜索兼容：字形归一 + 检索变体。
//
// 目标只有一个：**不管用户用简体还是繁體打字，搜索都能命中**。
// 这里不做"正确的"简繁转换（那需要词级上下文），只做字形层面的归一：
// 查询词与被查文本各自把每个字归到同一代表字形，再比对——
// 「歷史」和「历史」归一后都是「历史」，contains 自然成立。
//
// 映射表来自 OpenCC 字级字典（Apache-2.0），按等价类生成，
// 详见 `zh_script_table.dart` 头注与 glossary/make_zh_char_map.py。
library;

import 'package:PiliPlus/utils/zh_script_table.dart';

/// 把文本逐字归到**简体代表字形**。表里没有的字原样保留，
/// 所以拉丁字母、假名、谚文、标点都不受影响。
String zhToHans(String text) => _normalize(text, kZhToHans);

/// 把文本逐字归到**繁體代表字形**。
String zhToHant(String text) => _normalize(text, kZhToHant);

String _normalize(String text, Map<String, String> table) {
  if (text.isEmpty) return text;
  // 先做一次快速扫描：没有命中表里的字就直接返回原文，避免为纯英文/
  // 数字查询白付一次字符串拼接。
  var hit = false;
  for (final rune in text.runes) {
    if (table.containsKey(String.fromCharCode(rune))) {
      hit = true;
      break;
    }
  }
  if (!hit) return text;
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(table[ch] ?? ch);
  }
  return buffer.toString();
}

/// 简繁兼容的"包含"判断：两侧都归到简体形并转小写再比对。
///
/// 用于本地过滤型搜索框（下载列表/设置页/音乐列表等）——
/// 被查文本是存的原始标题，查询是用户现打的字，两边脚本、大小写都可能不一致。
bool zhCompatContains(String haystack, String needle) {
  if (needle.isEmpty) return true;
  if (haystack.isEmpty) return false;
  return zhToHans(haystack)
          .toLowerCase()
          .contains(zhToHans(needle).toLowerCase());
}

/// 检索变体：把 [query] 展开成「另一字形 + 多候选字替身」的列表（去重、
/// 保持优先序、上限 3 条——变体每条都是一次补搜请求）。
///
/// 服务器端搜索用：B 站接口按字面匹配，输入简体搜不到繁體标题、反之亦然，
/// 所以其它字形各搜一次再合并。若查询没有可转换的字形差异，
/// 返回空列表（调用方不需要补搜）。
///
/// 多候选字（發/髮、幹/乾、臺/檯/颱）的替身按单字替换展开在**整词繁體形**
/// 与原词上，不做笛卡尔积：代表形先行（OpenCC 首选），替身殿后。
List<String> zhSearchVariants(String query) {
  final variants = <String>{};
  final hansForm = zhToHans(query);
  final hantForm = zhToHant(query);
  if (hansForm != query) variants.add(hansForm);
  if (hantForm != query) variants.add(hantForm);
  // 替身：繁體侧多候选字按单字替换（在整词繁體形与原词上各试一次）。
  for (final base in <String>[hantForm, query]) {
    if (base.isEmpty) continue;
    final chars = [
      for (final rune in base.runes) String.fromCharCode(rune),
    ];
    for (var i = 0; i < chars.length; i++) {
      final alts = kZhAltHant[chars[i]] ?? const <String>[];
      for (final alt in alts) {
        final replaced = [
          for (var j = 0; j < chars.length; j++) j == i ? alt : chars[j],
        ].join();
        if (replaced != base && replaced != query) variants.add(replaced);
      }
    }
  }
  return variants.take(3).toList();
}
