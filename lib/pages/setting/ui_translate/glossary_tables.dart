import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/services/ui_translate/game_glossary.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 术语集清单页。
///
/// 把内嵌的每一个术语表（原神 / 鸣潮 / 崩坏：星穹铁道 / hololive …）按类别列出，
/// 每条一个开关，**默认全部开启**，用户可以关掉不玩的作品，避免它的专有名词被
/// 套用到别的语境里。
///
/// 关掉的效果：该词表的所有词条不再参与运行时匹配（见
/// `UiTranslateService._glossaryTableEnabled`），已翻好的缓存不受影响。
///
/// ## 两个必须遵守的约定（都是踩过坑的）
///
/// 1. **只能 import `material_ui`，不能 import `flutter/material`。**
///    本项目所有页面统一用 `material_ui`，它提供的 `ListTile` / `SwitchListTile`
///    才会跟随 App 的主题与调色板（明暗两套 + 多种配色风格）。
///    3.6.4.1 这页误用了 `flutter/material` 的 `SwitchListTile.adaptive` + 裸
///    `Scaffold`，结果整页只剩两个分组标题、开关全部不显示也不可点，
///    标题还固定成 Material 默认紫色。
///
/// 2. **整页裹一层 `Obx`**：译文是异步回来的，页面上所有 `uiTx` 都得能跟着刷新
///    （与 `pages/setting/pages/font_setting.dart` 的写法一致）。
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

  late Set<String> _disabled = _sanitise(Pref.glossaryDisabledTables);

  /// 剔除集合里不属于任何词表的残留 id。
  ///
  /// 3.6.4 的「默认全部关闭」迁移曾把 `kGlossaryNames` 的所有 id 前缀写进禁用
  /// 集合，其中包含 `game`（游戏名条目 `game|zzz` 的前缀），而本页根本没有它的
  /// 开关 —— 于是用户把 15 个开关全打开后，集合里仍残留 `game`，
  /// 计数「15 - 残留」就永远停在 14/15；运行时 `game|*` 的 8 条游戏名简称也被
  /// 顺带永久禁用。加载与保存时都过一遍白名单，老数据自动被治好。
  static Set<String> _sanitise(Set<String> stored) {
    final clean = <String>{
      for (final id in stored)
        if (kGlossaryManifest.containsKey(id)) id,
    };
    if (clean.length != stored.length) {
      Pref.glossaryDisabledTables = clean;
    }
    return clean;
  }

  /// 每个词表的词条数只算一次。
  /// 每次 build 都遍历上万个 key 会明显掉帧。
  static final Map<String, int> _countCache = _buildCounts();

  static Map<String, int> _buildCounts() {
    final map = <String, int>{};
    for (final key in kGlossaryNames.keys) {
      final bar = key.indexOf('|');
      if (bar <= 0) continue;
      final id = key.substring(0, bar);
      map[id] = (map[id] ?? 0) + 1;
    }
    return map;
  }

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

  Widget _section(String title, List<String> ids) {
    final tiles = <Widget>[];
    for (final id in ids) {
      if (!kGlossaryManifest.containsKey(id)) continue;
      final name = _tableNames[id] ?? id;
      tiles.add(
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(uiTx(name)),
          // 「已内置」：kGlossaryNames 里真正参与匹配的子集条数
          // （采集全量在构建机上，词表按分类白名单只内嵌核心部分）。
          // 不写「共 N 条」，避免和采集总数（manifest rows）对不上。
          subtitle: Text(
            uiTxP('已内置 {0} 条术语', [(_countCache[id] ?? 0).toString()]),
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
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
          // 分组标题不写死颜色：跟随当前主题的文字色，
          // 这样明暗主题和各种调色板下都协调。
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
    return SimpleScaffold(
      appBar: AppBar(title: Text(uiTx('术语集'))),
      body: SafeArea(
        top: false,
        // 整页裹一层 Obx：译文异步回来后整页刷新。
        // 依赖由内部的 uiTx() 建立 —— 它每次调用都会读一次服务的 revision，
        // 所以这里不需要（也不能）自己再读：revision 是**实例**成员，
        // 没有同名的静态入口。
        child: Obx(() {
          // 与设置主页那一项用同一个权威计数，避免两处公式漂移。
          final enabled = UiTranslateService.enabledGlossaryTableCount();
          return ListView(
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
          );
        }),
      ),
    );
  }
}
