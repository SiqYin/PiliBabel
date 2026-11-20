import 'package:PiliPlus/models/common/member/search_type.dart';
import 'package:PiliPlus/pages/member_search/child/controller.dart';
import 'package:PiliPlus/pages/search/controller.dart' show DebounceStreamMixin;
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class MemberSearchController extends GetxController
    with GetSingleTickerProviderStateMixin, DebounceStreamMixin<String> {
  late final FocusNode focusNode;
  late final TabController tabController;
  late final TextEditingController editingController;

  final mid = Get.parameters['mid']!;
  final uname = Get.parameters['uname'];

  final RxBool hasData = false.obs;
  final RxList<int> counts = <int>[-1, -1].obs;

  late final MemberSearchChildController arcCtr;
  late final MemberSearchChildController dynCtr;

  @override
  void onInit() {
    super.onInit();
    focusNode = FocusNode();
    editingController = TextEditingController();
    tabController = TabController(vsync: this, length: 2);
    arcCtr = Get.put(
      MemberSearchChildController(this, MemberSearchType.archive),
      tag: Utils.generateRandomString(8),
    );
    dynCtr = Get.put(
      MemberSearchChildController(this, MemberSearchType.dynamic),
      tag: Utils.generateRandomString(8),
    );
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
    hasData.value = true;
    arcCtr
      ..scrollController.jumpToTop()
      ..onReload();
    dynCtr
      ..scrollController.jumpToTop()
      ..onReload();
  }

  void onClear() {
    if (editingController.value.text.isNotEmpty) {
      editingController.clear();
      counts.value = <int>[-1, -1];
      hasData.value = false;
      focusNode.requestFocus();
    } else {
      Get.back();
    }
  }

  void submit() {
    if (editingController.text.isNotEmpty) {
      hasData.value = true;
      arcCtr
        ..scrollController.jumpToTop()
        ..onReload();
      dynCtr
        ..scrollController.jumpToTop()
        ..onReload();
    }
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
