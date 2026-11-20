import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/pages/common/search/keyword_variant_fetch.dart';
import 'package:PiliPlus/pages/search/controller.dart' show DebounceStreamMixin;
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

abstract class CommonSearchController<R, T> extends CommonListController<R, T>
    with
        SearchKeywordResolver,
        KeywordVariantSearchMixin<R, T>,
        DebounceStreamMixin<String> {
  final editController = TextEditingController();
  final focusNode = FocusNode();

  @override
  String get searchText => editController.text;

  @override
  Future<String> primaryKeyword() => resolveSearchKeyword();

  /// 单次检索：给定关键词与页码。子类只需要关心"拿词去查"这一件事；
  /// 解析（界面语言→简体中文）与简繁变体合并由基类统一处理。
  Future<LoadingState<R>> fetchData(String keyword, int page);

  @override
  Future<LoadingState<R>> customGetData() => fetchWithKeywordVariants(fetchData);

  @override
  void onInit() {
    super.onInit();
    // 实时搜索（3.9.6）：输入停顿 200ms 后直接检索，不必回车。
    // 主词解析与简繁变体沿用原链路；AI 翻译内部有按词缓存与并发去重，
    // 连续输入不会放大请求量。
    subInit();
    editController.addListener(_onEditChanged);
  }

  void _onEditChanged() {
    ctr?.add(editController.text);
  }

  @override
  void onValueChanged(String value) {
    if (value.trim().isEmpty) {
      // 清空：回到未搜索的初始态（与清空按钮一致）。
      page = 1;
      isEnd = false;
      loadingState.value = LoadingState<List<T>?>.loading();
      return;
    }
    onRefresh();
  }

  void onClear() {
    if (editController.text.isNotEmpty) {
      editController.clear();
    } else {
      Get.back();
    }
  }

  @override
  Future<void> onRefresh() {
    if (editController.value.text.isEmpty) {
      return Future.syncValue(null);
    }
    return super.onRefresh();
  }

  @override
  void onClose() {
    editController.removeListener(_onEditChanged);
    subDispose();
    editController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
