import 'package:PiliPlus/models/common/reply/reply_search_type.dart';
import 'package:PiliPlus/pages/video/reply_search_item/child/controller.dart';
import 'package:PiliPlus/pages/search/controller.dart' show DebounceStreamMixin;
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class ReplySearchController extends GetxController
    with GetSingleTickerProviderStateMixin, DebounceStreamMixin<String> {
  ReplySearchController(this.type, this.oid);
  final int type;
  final int oid;

  late final FocusNode focusNode;
  late final TabController tabController;
  late final TextEditingController editingController;

  late final videoCtr = Get.put(
    ReplySearchChildController(this, ReplySearchType.video),
    tag: Utils.generateRandomString(8),
  );
  late final articleCtr = Get.put(
    ReplySearchChildController(this, ReplySearchType.article),
    tag: Utils.generateRandomString(8),
  );

  void onClear() {
    if (editingController.value.text.isNotEmpty) {
      editingController.clear();
      focusNode.requestFocus();
    } else {
      Get.back();
    }
  }

  @override
  void onInit() {
    super.onInit();
    focusNode = FocusNode();
    tabController = TabController(vsync: this, length: 2);
    editingController = TextEditingController();
    submit();
    // 实时搜索（3.9.6）：输入停顿后直接检索，不必回车。
    subInit();
    editingController.addListener(_onEditChanged);
  }

  void _onEditChanged() {
    ctr?.add(editingController.text);
  }

  @override
  void onValueChanged(String value) {
    if (value.isEmpty) {
      return;
    }
    submit();
  }

  void submit() {
    videoCtr
      ..scrollController.jumpToTop()
      ..onReload();
    articleCtr
      ..scrollController.jumpToTop()
      ..onReload();
  }

  @override
  void onClose() {
    editingController.removeListener(_onEditChanged);
    subDispose();
    focusNode.dispose();
    tabController.dispose();
    editingController.dispose();
    super.onClose();
  }
}
