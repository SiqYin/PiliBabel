import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/pages/common/search/keyword_variant_fetch.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

abstract class CommonSearchController<R, T> extends CommonListController<R, T>
    with SearchKeywordResolver, KeywordVariantSearchMixin<R, T> {
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
    editController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
