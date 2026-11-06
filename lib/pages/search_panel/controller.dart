import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'dart:async' show StreamSubscription;

import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/models/common/search/article_search_type.dart';
import 'package:PiliPlus/models/common/search/search_type.dart';
import 'package:PiliPlus/models/common/search/user_search_type.dart';
import 'package:PiliPlus/models/common/search/video_search_type.dart';
import 'package:PiliPlus/models/search/result.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/pages/search_result/controller.dart';
import 'package:PiliPlus/pages/setting/widgets/list_editor_dialog.dart';
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class SearchPanelController<R extends SearchNumData<T>, T>
    extends CommonListController<R, T> {
  SearchPanelController({
    required this.keyword,
    required this.searchType,
    required this.tag,
  });
  final String tag;
  final String keyword;
  final SearchType searchType;

  // sort
  // common
  String order = '';

  // video
  VideoDurationType? videoDurationType; // int duration
  VideoZoneType? videoZoneType; // int? tids;
  int? pubBegin;
  int? pubEnd;

  // user
  Rx<UserOrderType>? userOrderType;
  Rx<UserType>? userType;

  // article
  Rx<ArticleZoneType>? articleZoneType; // int? categoryId;

  SearchResultController? searchResultController;

  // client-side keyword filter
  final RxList<String> includeKeywords = <String>[].obs;
  final RxList<String> excludeKeywords = <String>[].obs;

  RegExp? _buildRegex(List<String> keywords) {
    if (keywords.isEmpty) return null;
    try {
      final pattern = keywords
          .map((k) => k.contains('|') && !k.startsWith('(') ? '($k)' : k)
          .join('|');
      return RegExp(pattern, caseSensitive: false);
    } catch (_) {
      return null;
    }
  }

  List<E> filterKeywords<E>(List<E> list, String? Function(E) getTitle) {
    final hasInc = includeKeywords.isNotEmpty;
    final hasExc = excludeKeywords.isNotEmpty;
    if (!hasInc && !hasExc) return list;
    final inc = hasInc ? _buildRegex(includeKeywords) : null;
    final exc = hasExc ? _buildRegex(excludeKeywords) : null;
    return list.where((item) {
      final title = getTitle(item);
      if (title == null) return true;
      if (inc != null && !inc.hasMatch(title)) return false;
      if (exc != null && exc.hasMatch(title)) return false;
      return true;
    }).toList();
  }

  Widget buildKeywordFilterSection(
    BuildContext context,
    ThemeData theme,
    void Function(VoidCallback fn) setState,
  ) {
    final hasInc = includeKeywords.isNotEmpty;
    final hasExc = excludeKeywords.isNotEmpty;
    final hasAny = hasInc || hasExc;
    final primary = theme.colorScheme.primary;
    final error = theme.colorScheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Text(uiTx('关键词过滤'), style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        if (hasAny) ...[
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (hasInc)
                ...includeKeywords.asMap().entries.map(
                  (e) => InputChip(
                    avatar: Text('+',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        )),
                    label: Text(e.value),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    deleteIconColor: theme.colorScheme.onSecondaryContainer,
                    onDeleted: () {
                      includeKeywords.removeAt(e.key);
                      setState(() {});
                    },
                  ),
                ),
              if (hasExc)
                ...excludeKeywords.asMap().entries.map(
                  (e) => InputChip(
                    avatar: Text('-',
                        style: TextStyle(
                          color: error,
                          fontWeight: FontWeight.bold,
                        )),
                    label: Text(e.value),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    backgroundColor: theme.colorScheme.errorContainer,
                    deleteIconColor: theme.colorScheme.onErrorContainer,
                    onDeleted: () {
                      excludeKeywords.removeAt(e.key);
                      setState(() {});
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _editKeywords(
                  context,
                  setState,
                  title: uiTx('包含关键词'),
                  keywords: includeKeywords,
                  theme: theme,
                  isInclude: true,
                ),
                icon: Icon(
                  hasInc ? Icons.edit : Icons.add,
                  size: 16,
                ),
                label: Text(hasInc ? uiTx('编辑包含词') : uiTx('添加包含词')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _editKeywords(
                  context,
                  setState,
                  title: uiTx('排除关键词'),
                  keywords: excludeKeywords,
                  theme: theme,
                  isInclude: false,
                ),
                icon: Icon(
                  hasExc ? Icons.edit : Icons.remove,
                  size: 16,
                ),
                label: Text(hasExc ? uiTx('编辑排除词') : uiTx('添加排除词')),
              ),
            ),
          ],
        ),
        if (hasAny)
          TextButton(
            onPressed: () {
              includeKeywords.clear();
              excludeKeywords.clear();
              setState(() {});
            },
            child: Text(uiTx('清除所有关键词')),
          ),
      ],
    );
  }

  Future<void> _editKeywords(
    BuildContext context,
    void Function(VoidCallback fn) setState, {
    required String title,
    required RxList<String> keywords,
    required ThemeData theme,
    required bool isInclude,
  }) async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => ListEditorDialog(
        title: title,
        initialItems: List.from(keywords),
        hintText: uiTx('输入关键词或正则表达式'),
        itemLabel: isInclude ? '包含词' : '排除词',
        validator: (value) {
          if (value.isEmpty) return '请输入关键词';
          try {
            RegExp(value);
            return null;
          } catch (_) {
            return '无效的正则表达式';
          }
        },
      ),
    );
    if (result != null) {
      keywords.value = result;
      setState(() {});
      SmartDialog.showToast(uiTx('已更新$title'));
    }
  }

  void onSortSearch({
    bool getBack = true,
    String? label,
  }) {
    if (getBack) Get.back();
    SmartDialog.dismiss();
    if (label != null) {
      SmartDialog.showToast(uiTx("「$label」的筛选结果"));
    }
    SmartDialog.showLoading(msg: 'loading');
    onReload().whenComplete(SmartDialog.dismiss);
  }

  StreamSubscription? _listener;

  void cancelListener() {
    _listener?.cancel();
  }

  @override
  void onInit() {
    super.onInit();
    try {
      searchResultController = Get.find<SearchResultController>(tag: tag);
      _listener = searchResultController!.toTopIndex.listen((index) {
        if (index == searchType.index) {
          scrollController.animToTop();
        }
      });
    } catch (_) {}
    queryData();
  }

  @override
  List<T>? getDataList(R response) {
    return response.list;
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<R> response) {
    if (isRefresh) {
      searchResultController?.count[searchType.index] =
          response.response.numResults ?? 0;
    }
    return false;
  }

  String? gaiaVtoken;

  /// 译成简体中文后的检索词；null 表示这一轮还没解析过。
  String? _resolvedKeyword;

  /// 把界面语言的检索词还原成简体中文再检索。
  ///
  /// 界面翻译开启后，标题会被译成界面语言，用户自然会用界面语言去搜；
  /// 但 B 站的搜索接口只认中文原文，直接拿外语词去搜必然搜不到。
  /// 翻译不需要/失败时一律退回原词——搜索绝不能因为翻译不可用而失效。
  ///
  /// 结果缓存在本 controller 上：翻页复用同一个词，不会每页重译一次；
  /// 多个分栏同时开搜同一个词时，[UiTranslateService.translateQuery] 内部
  /// 会做并发去重，实际只发一次请求。
  Future<String> _resolveKeyword() async {
    final cached = _resolvedKeyword;
    if (cached != null) return cached;
    var resolved = keyword;
    if (Get.isRegistered<UiTranslateService>()) {
      final translated = await UiTranslateService.to.translateQuery(keyword);
      if (translated != null && translated.isNotEmpty) {
        resolved = translated;
      }
    }
    _resolvedKeyword = resolved;
    return resolved;
  }

  /// 搜索词本身就是简体中文时，结果按 B 站原文显示，不做内容翻译。
  bool get searchInSourceLanguage =>
      Get.isRegistered<UiTranslateService>() &&
      UiTranslateService.isSourceLanguageChinese(keyword);

  /// 需要额外用原文搜一次的词（非中文搜索词译成中文时才有值）。
  String? _originalKeyword;

  /// 两路结果按各自名次交替合并，同一个对象只留一条。
  List<T>? _mergeSearchList(List<T>? primary, List<T>? secondary) {
    if (primary == null || primary.isEmpty) return secondary;
    if (secondary == null || secondary.isEmpty) return primary;
    final merged = <T>[];
    final seen = <String>{};
    final len = primary.length > secondary.length
        ? primary.length
        : secondary.length;
    for (var i = 0; i < len; i++) {
      if (i < primary.length && seen.add(_searchItemKey(primary[i]))) {
        merged.add(primary[i]);
      }
      if (i < secondary.length && seen.add(_searchItemKey(secondary[i]))) {
        merged.add(secondary[i]);
      }
    }
    return merged;
  }

  String _searchItemKey(T e) {
    if (e is SearchVideoItemModel) return 'v${e.aid ?? e.id}';
    if (e is SearchUserItemModel) return 'u${e.mid}';
    if (e is SearchLiveItemModel) return 'l${e.roomid ?? e.uid}';
    if (e is SearchPgcItemModel) return 'p${e.seasonId ?? e.mediaId}';
    if (e is SearchArticleItemModel) return 'a${e.id}';
    return '$e';
  }

  @override
  Future<LoadingState<R>> customGetData() async {
    final resolvedKeyword = await _resolveKeyword();
    // 译名和原文不一样说明确实翻译过：第一页额外用原文再搜一次，
    // 有些内容正文里直接引用了这段外文，只搜译名会漏掉。
    _originalKeyword = resolvedKeyword == keyword ? null : keyword;
    final response = await SearchHttp.searchByType<R>(
      searchType: searchType,
      keyword: resolvedKeyword,
      page: page,
      order: order,
      duration: videoDurationType?.index,
      tids: videoZoneType?.tids,
      orderSort: userOrderType?.value.orderSort,
      userType: userType?.value.index,
      categoryId: articleZoneType?.value.categoryId,
      pubBegin: pubBegin,
      pubEnd: pubEnd,
      gaiaVtoken: gaiaVtoken,
      onSuccess: (String gaiaVtoken) {
        this.gaiaVtoken = gaiaVtoken;
        queryData(page == 1);
      },
    );
    final origin = _originalKeyword;
    if (page != 1 || origin == null) return response;
    final extra = await SearchHttp.searchByType<R>(
      searchType: searchType,
      keyword: origin,
      page: page,
      order: order,
      duration: videoDurationType?.index,
      tids: videoZoneType?.tids,
      orderSort: userOrderType?.value.orderSort,
      userType: userType?.value.index,
      categoryId: articleZoneType?.value.categoryId,
      pubBegin: pubBegin,
      pubEnd: pubEnd,
      gaiaVtoken: gaiaVtoken,
      onSuccess: (_) {},
    );
    if (response is Success<R> && extra is Success<R>) {
      response.response.list = _mergeSearchList(
        response.response.list,
        extra.response.list,
      );
    }
    return response;
  }

  @override
  Future<void> onReload() {
    scrollController.jumpToTop();
    return super.onReload();
  }

  int _lastLoadMoreTime = 0;

  bool get hasKeywordFilter =>
      includeKeywords.isNotEmpty || excludeKeywords.isNotEmpty;

  @override
  Future<void> onLoadMore() async {
    if (hasKeywordFilter) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastLoadMoreTime < 1200) return;
      await super.onLoadMore();
      _lastLoadMoreTime = DateTime.now().millisecondsSinceEpoch;
    } else {
      return super.onLoadMore();
    }
  }
}
