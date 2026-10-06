import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/common/widgets/scroll_physics.dart' show tabBarView;
import 'package:PiliPlus/common/widgets/view_safe_area.dart';
import 'package:PiliPlus/models/common/search/search_type.dart';
import 'package:PiliPlus/pages/search/controller.dart';
import 'package:PiliPlus/pages/search_panel/article/view.dart';
import 'package:PiliPlus/pages/search_panel/live/view.dart';
import 'package:PiliPlus/pages/search_panel/pgc/view.dart';
import 'package:PiliPlus/pages/search_panel/user/view.dart';
import 'package:PiliPlus/pages/search_panel/video/view.dart';
import 'package:PiliPlus/pages/search_result/controller.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({super.key});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with SingleTickerProviderStateMixin {
  late SearchResultController _searchResultController;
  late TabController _tabController;
  final String _tag = DateTime.now().millisecondsSinceEpoch.toString();
  final bool _isFromSearch = Get.arguments?['fromSearch'] ?? false;
  SSearchController? sSearchController;

  @override
  void initState() {
    super.initState();
    _searchResultController = Get.put(
      SearchResultController(),
      tag: _tag,
    );

    _tabController = TabController(
      vsync: this,
      initialIndex: Get.arguments?['initIndex'] ?? 0,
      length: SearchType.values.length,
    );

    if (_isFromSearch) {
      try {
        sSearchController = Get.find<SSearchController>(
          tag: Get.parameters['tag'],
        );
        _tabController.addListener(listener);
      } catch (_) {}
    }
  }

  void listener() {
    sSearchController?.initIndex = _tabController.index;
  }

  /// 搜索词正在被翻成简体中文时显示的一条等待提示。
  ///
  /// 界面翻译开启后，用户输入的是界面语言，而 B 站的搜索接口只认中文，
  /// 所以检索前要先把词翻回简体中文——这一步要等模型返回，通常一两秒。
  /// 提示文案本身也走 [uiTx]，会跟着界面语言一起翻译。
  Widget _buildTranslateHint(ThemeData theme) {
    return Obx(() {
      if (!UiTranslateService.to.isTranslatingQuery) {
        return const SizedBox.shrink();
      }
      return Container(
        width: double.infinity,
        color: theme.colorScheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                uiTx('正在把搜索词翻译成简体中文，请稍候…'),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(listener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SimpleScaffold(
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        title: GestureDetector(
          onTap: () {
            if (_isFromSearch) {
              Get.back();
            } else {
              Get.offNamed(
                '/search',
                parameters: {'text': _searchResultController.keyword},
              );
            }
          },
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _searchResultController.keyword,
              style: theme.textTheme.titleMedium,
              maxLines: 1,
            ),
          ),
        ),
      ),
      body: ViewSafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
              controller: _tabController,
              tabs: SearchType.values
                  .map(
                    (item) => Obx(
                      () {
                        int count = _searchResultController.count[item.index];
                        return Tab(
                          text:
                              '${uiTx(item.label)}${count != -1 ? ' ${count > 99 ? '99+' : count}' : ''}',
                        );
                      },
                    ),
                  )
                  .toList(),
              isScrollable: true,
              indicatorWeight: 0,
              indicatorPadding: const EdgeInsets.symmetric(
                horizontal: 3,
                vertical: 8,
              ),
              indicator: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: theme.colorScheme.onSecondaryContainer,
              labelStyle:
                  TabBarTheme.of(
                    context,
                  ).labelStyle?.copyWith(fontSize: 13) ??
                  const TextStyle(fontSize: 13),
              dividerColor: Colors.transparent,
              dividerHeight: 0,
              unselectedLabelColor: theme.colorScheme.outline,
              tabAlignment: TabAlignment.start,
              onTap: (index) {
                if (!_tabController.indexIsChanging) {
                  if (_searchResultController.toTopIndex.value == index) {
                    _searchResultController.toTopIndex.refresh();
                  } else {
                    _searchResultController.toTopIndex.value = index;
                  }
                }
              },
            ),
            if (Get.isRegistered<UiTranslateService>())
              _buildTranslateHint(theme),
            Expanded(
              child: tabBarView(
                controller: _tabController,
                children: SearchType.values
                    .map(
                      (item) => switch (item) {
                        // SearchType.all => SearchAllPanel(
                        //   tag: _tag,
                        //   searchType: item,
                        //   keyword: _searchResultController.keyword,
                        // ),
                        SearchType.video => SearchVideoPanel(
                          tag: _tag,
                          searchType: item,
                          keyword: _searchResultController.keyword,
                        ),
                        SearchType.media_bangumi ||
                        SearchType.media_ft => SearchPgcPanel(
                          tag: _tag,
                          searchType: item,
                          keyword: _searchResultController.keyword,
                        ),
                        SearchType.live_room => SearchLivePanel(
                          tag: _tag,
                          searchType: item,
                          keyword: _searchResultController.keyword,
                        ),
                        SearchType.bili_user => SearchUserPanel(
                          tag: _tag,
                          searchType: item,
                          keyword: _searchResultController.keyword,
                        ),
                        SearchType.article => SearchArticlePanel(
                          tag: _tag,
                          searchType: item,
                          keyword: _searchResultController.keyword,
                        ),
                      },
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
