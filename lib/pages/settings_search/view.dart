import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/common/widgets/view_insets_safe_area.dart';
import 'package:PiliPlus/common/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/pages/search/controller.dart' show DebounceStreamState;
import 'package:PiliPlus/pages/setting/models/dynamics_settings.dart';
import 'package:PiliPlus/pages/setting/models/extra_settings.dart';
import 'package:PiliPlus/pages/setting/models/model.dart';
import 'package:PiliPlus/utils/zh_search_compat.dart';
import 'package:PiliPlus/pages/setting/models/play_settings.dart';
import 'package:PiliPlus/pages/setting/models/privacy_settings.dart';
import 'package:PiliPlus/pages/setting/models/recommend_settings.dart';
import 'package:PiliPlus/pages/setting/models/style_settings.dart';
import 'package:PiliPlus/pages/setting/models/video_settings.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:PiliPlus/utils/waterfall.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';
import 'package:waterfall_flow/waterfall_flow.dart'
    hide SliverWaterfallFlowDelegateWithMaxCrossAxisExtent;

class SettingsSearchPage extends StatefulWidget {
  const SettingsSearchPage({super.key});

  @override
  State<SettingsSearchPage> createState() => _SettingsSearchPageState();
}

class _SettingsSearchPageState
    extends DebounceStreamState<SettingsSearchPage, String> {
  final _textEditingController = TextEditingController();
  final RxList<SettingsModel> _list = <SettingsModel>[].obs;
  /// 必须是 getter：这些 `xxxSettings` 里的 `uiTx(...)` 是**求值时**取译文的，
  /// 用 `late final` 缓存下来的话，关闭 AI 翻译后搜索索引里仍是旧译文。
  List<SettingsModel> get _settings => [
    ...extraSettings,
    ...privacySettings,
    ...recommendSettings,
    ...dynamicsSettings,
    ...videoSettings,
    ...playSettings,
    ...styleSettings,
  ];

  @override
  void onValueChanged(String value) {
    if (value.isEmpty) {
      _list.clear();
    } else {
      // zhCompatContains 自带小写折叠 + 简繁字形归一：设置项标题存的是
      // 简体原文，繁體界面下照着界面上的字打也能搜到。
      bool hit(String? text) =>
          text != null &&
          text.isNotEmpty &&
          zhCompatContains(text, value);
      _list.value = _settings
          .where(
            (item) =>
                hit(item.effectiveTitle) ||
                hit(item.effectiveSubtitle) ||
                // 原文标题/副标题：界面翻译开着时显示的是译文，原文也要可搜。
                hit(item.title) ||
                hit(item.subtitle),
          )
          .toList();
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleScaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              if (_textEditingController.text.isNotEmpty) {
                _textEditingController.clear();
                _list.clear();
              } else {
                Get.back();
              }
            },
            icon: const Icon(Icons.clear),
          ),
          const SizedBox(width: 10),
        ],
        title: TextField(
          autofocus: true,
          controller: _textEditingController,
          textAlignVertical: TextAlignVertical.center,
          onChanged: ctr!.add,
          decoration: InputDecoration(
            isDense: true,
            hintText: uiTx('搜索'),
            visualDensity: .standard,
            border: InputBorder.none,
          ),
        ),
      ),
      body: ViewInsetsSafeArea(
        child: CustomScrollView(
          slivers: [
            ViewSliverSafeArea(
              sliver: Obx(
                () => _list.isEmpty
                    ? const HttpError()
                    : SliverWaterfallFlow(
                        gridDelegate:
                            SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: Grid.smallCardWidth * 2,
                            ),
                        delegate: SliverChildBuilderDelegate(
                          (_, index) => _list[index].widget,
                          childCount: _list.length,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
