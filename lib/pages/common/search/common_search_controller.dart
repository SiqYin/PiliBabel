import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

abstract class CommonSearchController<R, T> extends CommonListController<R, T> {
  final editController = TextEditingController();
  final focusNode = FocusNode();

  String? _resolvedFrom;
  String? _resolvedTo;

  /// 界面翻译开启后，列表里的标题会被译成界面语言，用户自然会用界面语言搜；
  /// 但 B 站的搜索接口只认中文原文，直接拿外语词去搜必然搜不到。
  /// 这里把查询词还原成原文再发请求；翻译不需要/失败时一律退回原词——
  /// 搜索绝不能因为翻译不可用而失效。结果按词缓存，翻页不会重复解析。
  Future<String> resolveKeyword() async {
    final raw = editController.text;
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
