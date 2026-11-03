import 'dart:convert';

import 'package:PiliPlus/common/widgets/flutter/list_tile.dart';
import 'package:PiliPlus/services/ui_translate/game_glossary.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 术语集清单页。
///
/// 把内嵌的每一个术语表（原神 / 鸣潮 / 崩坏：星穹铁道 / hololive …）按类别列出，
/// 每条一个开关，默认全开，用户可以关掉不玩的作品，避免它的专有名词被套用到
/// 其它语境里。
///
/// 关掉的效果：该词表的所有词条不再参与运行时匹配（见
/// `UiTranslateService._glossaryTableEnabled`），已翻好的缓存不受影响。
class GlossaryTablesPage extends StatefulWidget {
  const GlossaryTablesPage({super.key});

  @override
  State<GlossaryTablesPage> createState() => _GlossaryTablesPageState();
}

class _GlossaryTablesPageState extends State<GlossaryTablesPage> {
  /// 各词表 id 对应的展示名。用中文名作 key 是合适的：
  /// 这是术语表自身的数据，不随界面语言变化。
  static const Map<String, String> _tableNames = {
    'genshin': '原神',
    'hsr': '崩坏：星穹铁道',
    'zzz': '绝区零',
    'wuwa': '鸣潮',
    'hi3': '崩坏3',
    'ba': '蔚蓝档案',
    'nikke': '胜利女神：妮姬',
    'ak': '明日方舟',
    'uma': '赛马娘',
    'bd': 'BanG Dream!',
    'r1999': '重返未来 1999',
    'yh': '异环',
    'holo': 'hololive',
    'niji': 'NIJISANJI',
    'imas': '偶像大师',
  };

  /// 词表分组：按「游戏」与「企划」两类展示。
  static const List<String> _gameIds = [
    'genshin', 'hsr', 'zzz', 'wuwa', 'hi3', 'ak', 'ba', 'nikke',
    'uma', 'bd', 'r1999', 'yh',
  ];
  static const List<String> _projectIds = ['holo', 'niji', 'imas'];

  late Set<String> _disabled = Pref.glossaryDisabledTables;

  void _toggle(String id, bool enabled) {
    setState(() {
      if (enabled) {
        _disabled.remove(id);
      } else {
        _disabled.add(id);
      }
    });
    Pref.glossaryDisabledTables = _disabled;
    // 索引是按启用状态构建的，改开关后必须作废重建。
    UiTranslateService.rebuildGlossaryIndex();
  }

  /// 每个词表的词条数量，从内嵌表里现算。
  int _countOf(String id) {
    var n = 0;
    for (final key in kGlossaryNames.keys) {
      if (key.startsWith('$id|')) n++;
    }
    return n;
  }

  Widget _section(String title, List<String> ids) {
    final tiles = <Widget>[];
    for (final id in ids) {
      if (!kGlossaryManifest.containsKey(id)) continue;
      final name = _tableNames[id] ?? id;
      tiles.add(
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(uiTx(name)),
          subtitle: Text(
            uiTxP('{0} 条术语', [_countOf(id).toString()]),
          ),
          value: !_disabled.contains(id),
          onChanged: (v) => _toggle(id, v),
        ),
      );
    }
    if (tiles.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
          child: Text(
            uiTx(title),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        ...tiles,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = kGlossaryManifest.length - _disabled.length;
    return Scaffold(
      appBar: AppBar(title: Text(uiTx('术语集'))),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              uiTxP(
                '已启用 {0} / {1} 个术语集。关闭后，该作品的专有名词不再被自动套用。',
                [enabled.toString(), kGlossaryManifest.length.toString()],
              ),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          _section('游戏', _gameIds),
          _section('企划', _projectIds),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
