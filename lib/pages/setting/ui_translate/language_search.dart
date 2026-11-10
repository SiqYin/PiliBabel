import 'dart:ui' as ui;

import 'package:PiliPlus/services/ui_translate/app_language.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 官方清单覆盖的语言数 / 清单外的数量，用于选择器顶部的说明。
final int kOfficialLanguageCount = appLanguages.where((e) => e.official).length;
final int kUnofficialLanguageCount =
    appLanguages.where((e) => !e.official).length;

/// 列表顺序：1.0.0 之前内置的那 29 种（还没接 B 站官方翻译时的清单）按当年的
/// 先后排在最前，其余按原有顺序（英文名 A–Z）跟在后面。常用语言始终在列表上方，
/// 不用滚就能点到。
const List<String> _legacyLanguageOrder = <String>[
  'zh-CN',
  'zh-TW',
  'en',
  'ja',
  'ko',
  'yue-Hans',
  'yue-Hant',
  'wuu-Hans',
  'wuu-Hant',
  'nan-CN',
  // 白话字（POJ）版台湾闽南语：**紧挨着汉字版的两个闽南语**，
  // 让人一眼看出它是同一语族的另一种书写（3.8.8 用户要求）。
  'nan-TW-latn',
  'nan-TW',
  'ar',
  'fil',
  'fr',
  'de',
  'he',
  'hmn',
  'id',
  'it',
  'ms',
  'mn',
  'ru',
  'es',
  'th',
  'bo',
  'tr',
  'ug',
  'vi',
  'za',
];

/// 选择器里的行序（常用语言在前，其余在后）。
final List<AppLanguage> _pickerRows = () {
  final legacy = <AppLanguage>[];
  final rest = <AppLanguage>[];
  for (final l in appLanguages) {
    (_legacyLanguageOrder.contains(l.code) ? legacy : rest).add(l);
  }
  legacy.sort(
    (a, b) => _legacyLanguageOrder
        .indexOf(a.code)
        .compareTo(_legacyLanguageOrder.indexOf(b.code)),
  );
  return <AppLanguage>[...legacy, ...rest];
}();

/// 选择器里实际显示的行序（对外可见，方便测试与审计）。
List<AppLanguage> get pickerLanguageRows => _pickerRows;

/// 语言搜索过滤：自称名 / 代码 / 英文别名，三者都先折叠再 `contains`。
///
/// 折叠包含两件事：统一小写 + 剥离不可见字符（双向控制符/零宽字符），以及
/// 阿拉伯文字母变体归一——维吾尔/阿拉伯/波斯键盘的同形异码字母
/// （ي/ی/ى、ك/ک、ه/ة/ە）曾让「照着自称名打也搜不到」。
///
/// 纯函数：搜索框的过滤逻辑单独拎出来，方便直接测。
List<AppLanguage> filterAppLanguagesByQuery(
  List<AppLanguage> languages,
  String query,
) {
  final q = foldLanguageSearch(query);
  if (q.isEmpty) return List<AppLanguage>.of(languages);
  return languages.where((l) {
    if (foldLanguageSearch(l.name).contains(q)) return true;
    if (foldLanguageSearch(l.code).contains(q)) return true;
    for (final alias in kLanguageSearchAliases[l.code] ?? const <String>[]) {
      if (foldLanguageSearch(alias).contains(q)) return true;
    }
    return false;
  }).toList();
}

/// 读一次翻译服务的 [revision]，给 `Obx` 建立依赖。
///
/// 服务没注册时（组件测试里没有 `Get.put`）直接跳过：`Obx` 一次 observable
/// 都没读到会抛「improper use of a GetX」。生产环境服务总是注册，行为不变。
void touchUiTranslateRevision() {
  if (Get.isRegistered<UiTranslateService>()) {
    UiTranslateService.to.revision.value;
  }
}

/// 需要「译文回来就重建」的片段。
///
/// 服务已注册时包一层 `Obx`（并在 build 里读一次 revision 建立依赖）——
/// 译文是异步到的，没有 Obx 就只在构建那一刻取一次值，译文晚到就永远停在原文上。
///
/// 服务没注册时（组件测试）直接求值：此时 `uiTx()` 本来就返回原文，
/// 也不该注册一个空 Obx（GetX 4.7.2 下空 Obx 会在构建时抛
/// 「improper use of a GetX」）。
Widget rebuildOnTranslation(Widget Function() builder) {
  if (!Get.isRegistered<UiTranslateService>()) return builder();
  return Obx(() {
    touchUiTranslateRevision();
    return builder();
  });
}

/// 语言搜索框 + 结果列表。
///
/// **3.8.8 从弹窗里抽成独立组件**：以前搜索逻辑写在 `showDialog` 的
/// `StatefulBuilder` 里，监听器只更新了 `query` 变量、**从不触发重建**，
/// 结果就是「输入什么都没反应、按回车也没反应」——搜索框等于完全失效
/// （3.8.2 那次「实时搜索」改造把 `setState` 弄丢了）。
///
/// 现在状态由本组件自己持有：文本变化 → `setState` → 列表按新查询重建，
/// 输入即出结果，不需要按回车。
class LanguageSearchList extends StatefulWidget {
  const LanguageSearchList({
    super.key,
    required this.selectedCode,
    required this.onSelected,
    this.languages,
  });

  /// 当前选中的语言代码（这一行打勾）。
  final String selectedCode;

  /// 选中某项时回调（弹窗里用它 `Navigator.pop`）。
  final ValueChanged<String> onSelected;

  /// 要显示的语言列表；默认用选择器的固定行序。
  final List<AppLanguage>? languages;

  @override
  State<LanguageSearchList> createState() => _LanguageSearchListState();
}

class _LanguageSearchListState extends State<LanguageSearchList> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // 用 controller 的 listener 而不是 onChanged：部分输入法在组合（composing）
    // 阶段不触发 onChanged，表现为「英文要按回车才出结果」。
    _controller.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    final v = _controller.text;
    if (v == _query) return;
    // **必须重建**：结果列表是按 `_query` 过滤出来的，不重建就永远是全量，
    // 表现为「输入任何内容都没有效果」。这正是 3.8.2→3.8.7 期间搜索框全坏的根因。
    setState(() => _query = v);
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languages = widget.languages ?? _pickerRows;
    final rows = filterAppLanguagesByQuery(languages, _query);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        rebuildOnTranslation(() {
          return TextField(
            controller: _controller,
            // 双向自适应：输入 RTL 自称名时按首强方向字符切方向，
            // 所见即所输（逻辑串一直正确，这里只修观感）。
            textDirection: firstStrongIsRtl(_query)
                ? ui.TextDirection.rtl
                : ui.TextDirection.ltr,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.search, size: 20),
              hintText: uiTx('搜索语言：自称名 / 英文名均可'),
              border: const OutlineInputBorder(),
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 8),
          child: rebuildOnTranslation(() {
            return Text(
              uiTx('按自称名或英文名检索均可，实时出结果。'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            );
          }),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: rows.length + 1,
            itemBuilder: (context, index) {
              // 第 0 项是覆盖范围说明，跟着列表一起滚。
              if (index == 0) {
                // 必须包 Obx：译文是异步到的，没有 Obx 就只在构建那一刻取一次值。
                return rebuildOnTranslation(
                  () => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      // 带插值的整句必须走 uiTxP：Dart 的字符串插值会把「已填好数字的
                      // 整句」当成翻译 key，每条插值结果都是新 key，缓存永远命不中，
                      // 而且模型也不能保证回填后语序还对。uiTxP 把带 {0}/{1} 的模板
                      // 作为稳定 key 送翻，再回填参数。
                      //
                      // 另外**不要写 markdown 强调**：Flutter 的 Text 不解析 markdown，
                      // `**xxx**` 会原样显示成星号。
                      uiTxP(
                        '内置的 B 站官方模型覆盖 {0} 种语言。清单外的 {1} 种'
                        '（繁體中文、吴语、闽南语、壮语等）一样可以选，'
                        '但官方模型不保证效果 —— 想要这几种，建议在'
                        '「翻译引擎」里切换到自备 API。\n\n'
                        '若自行接入 API，还能翻译你自己的模型支持的任何其它语言，'
                        '不限于这份清单。',
                        [
                          kOfficialLanguageCount,
                          kUnofficialLanguageCount,
                        ],
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                );
              }
              final language = rows[index - 1];
              final selected = language.code == widget.selectedCode;
              // 整行包 Obx。**这一步不能省**：下面的 uiTx 是异步拿译文的，没有 Obx 的话
              // 这一行只在构建那一刻取一次值，译文晚到就永远停在原文上 —— 而「哪一行
              // 恰好被重建过」取决于滚动时机，于是会出现「同为官方清单外，這行翻了、
              // 那行没翻」的随机现象。
              return rebuildOnTranslation(() {
                // 官方条目的 subtitle 是 null，行内一次 uiTx 都不调，也就是这个 Obx
                // 里没有任何 observable。GetX 4.7.2 下这种行会在构建时抛错，而 release
                // 不弹红屏、只静默丢行 —— 官方那 151 种语言于是整批从列表里消失，
                // 只剩清单外那几种。所以这里也要显式读一次 revision。
                touchUiTranslateRevision();
                // Language names are autonyms; keep them literal instead of asking
                // the selected target language to translate the language selector.
                return ListTile(
                  dense: true,
                  selected: selected,
                  // 官方清单外的几种提醒一句：它们能选，但想要好效果得自备模型。
                  subtitle: language.official
                      ? null
                      : Text(
                          uiTx('官方清单外 · 建议自备 API'),
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(language.name),
                  trailing: selected ? const Icon(Icons.check) : null,
                  onTap: () => widget.onSelected(language.code),
                );
              });
            },
          ),
        ),
      ],
    );
  }
}
