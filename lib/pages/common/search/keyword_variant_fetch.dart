// 搜索词解析 + 简繁变体检索 —— 全 App 搜索框共用的两件套。
//
// **搜索词解析**（[SearchKeywordResolver]）：界面翻译开启后，标题会被译成
// 界面语言，用户自然会用界面语言搜；但 B 站的搜索接口只认中文原文，直接拿
// 外语词去搜必然搜不到。把查询词还原成简体中文再发请求；翻译不需要/失败时
// 一律退回原词——搜索绝不能因为翻译不可用而失效。结果按词缓存，翻页/重搜
// 不会重复解析。
//
// **简繁变体检索**（[KeywordVariantSearchMixin]）：B 站接口按字面匹配，
// 输入简体搜不到繁體标题、反之亦然。主词（用户原文经解析后的形态）先搜，
// 另一字形作为变体补搜并入；主词完全无结果时直接采用首个有结果的变体——
// 繁體用户的收藏/历史几乎都是简体标题，不能因为字形不合就给个空页。
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/zh_search_compat.dart';
import 'package:get/get.dart';

/// 搜索框输入词 → 简体中文检索词（带按词缓存）。
mixin SearchKeywordResolver {
  /// 当前搜索框里的原始输入。
  String get searchText;

  String? _resolvedFrom;
  String? _resolvedTo;

  /// 解析后的检索词（界面语言 → 简体中文；无需翻译时即原文）。
  Future<String> resolveSearchKeyword() async {
    final raw = searchText;
    if (raw.isEmpty) return raw;
    if (_resolvedFrom == raw && _resolvedTo != null) {
      return _resolvedTo!;
    }
    var resolved = raw;
    if (Get.isRegistered<UiTranslateService>()) {
      final translated = await UiTranslateService.to.translateQuery(raw);
      if (translated != null && translated.isNotEmpty) {
        resolved = translated;
      }
    }
    _resolvedFrom = raw;
    _resolvedTo = resolved;
    return resolved;
  }

  /// 重新输入新词时清掉按词缓存（可选；缓存键是原词，不清也不会串词）。
  void resetResolvedKeyword() {
    _resolvedFrom = null;
    _resolvedTo = null;
  }
}

/// 简繁变体检索：宿主是 [CommonListController]，单次检索由 [fetchData] 提供。
mixin KeywordVariantSearchMixin<R, T> on CommonListController<R, T> {
  /// 主检索词（用户原文解析后的形态）。
  Future<String> primaryKeyword();

  /// 单次检索：给定关键词与页码发一次请求。
  Future<LoadingState<R>> fetchData(String keyword, int page);

  /// 变体结果的条目去重键；返回 null 表示不去重。
  String? variantItemKey(T item) => null;

  /// 从响应里**无副作用**地取结果列表。默认走 [getDataList]；
  /// getDataList 里写了计数/isEnd 之类状态的子类必须覆盖成纯取值，
  /// 否则变体响应会污染主响应的状态。
  List<T>? variantList(R response) => getDataList(response);

  /// 主词先搜，另字形补搜合并；主词零结果时用第一个有结果的变体顶上。
  ///
  /// 变体只在**第一页**生效（与搜索结果页的原文补搜同一口径）：
  /// 翻页沿主词继续，合并语义只负责"第一屏就让人看到两形都能命中"。
  Future<LoadingState<R>> fetchWithKeywordVariants(
    Future<LoadingState<R>> Function(String keyword, int page) fetch,
  ) async {
    final primary = await primaryKeyword();
    final variants = zhSearchVariants(primary);
    if (page != 1 || variants.isEmpty) return fetch(primary, page);

    var response = await fetch(primary, page);
    // 主词有结果：逐个变体补搜，按去重键并入；某个变体失败/为空就跳过，
    // 不影响主词已有的结果。
    if (response is Success<R>) {
      final base = variantList(response.response);
      if (base == null || base.isEmpty) {
        // 主词零结果：直接用第一个有结果的变体当主响应。
        for (final variant in variants) {
          final LoadingState<R> extra = await fetch(variant, page);
          if (extra is Success<R>) {
            final list = variantList(extra.response);
            if (list != null && list.isNotEmpty) {
              response = extra;
              break;
            }
          }
        }
        return response;
      }
      final seen = <String>{};
      for (final item in base) {
        final key = variantItemKey(item);
        if (key != null && key.isNotEmpty) seen.add(key);
      }
      for (final variant in variants) {
        final LoadingState<R> extra;
        try {
          extra = await fetch(variant, page);
        } catch (_) {
          // 变体只是补搜：失败就少一路结果，绝不能让整页报错。
          continue;
        }
        if (extra is! Success<R>) continue;
        final extraList = variantList(extra.response);
        if (extraList == null || extraList.isEmpty) continue;
        for (final item in extraList) {
          final key = variantItemKey(item);
          if (key == null || key.isEmpty) continue;
          if (!seen.add(key)) continue;
          base.add(item);
        }
      }
      return response;
    }
    // 主词这一路本身就失败（网络/风控）：变体兜底试一次，全失败保持原错误。
    for (final variant in variants) {
      final LoadingState<R> extra;
      try {
        extra = await fetch(variant, page);
      } catch (_) {
        continue;
      }
      if (extra is Success<R> &&
          (variantList(extra.response)?.isNotEmpty ?? false)) {
        return extra;
      }
    }
    return response;
  }
}
