import 'package:PiliPlus/models/common/live/live_search_type.dart';
import 'package:PiliPlus/pages/live_search/child/controller.dart';
import 'package:PiliPlus/pages/search/controller.dart' show DebounceStreamMixin;
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class LiveSearchController extends GetxController
    with GetSingleTickerProviderStateMixin, DebounceStreamMixin<String> {
  late final TabController tabController;
  final editingController = TextEditingController();
  final focusNode = FocusNode();

  final mid = Get.parameters['mid'];
  final uname = Get.parameters['uname'];

  final RxBool hasData = false.obs;
  final RxList<int> counts = <int>[-1, -1].obs;

  late final roomCtr = Get.put(
    LiveSearchChildController(this, LiveSearchType.room),
    tag: Utils.generateRandomString(8),
  );
  late final userCtr = Get.put(
    LiveSearchChildController(this, LiveSearchType.user),
    tag: Utils.generateRandomString(8),
  );

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: 2);
    // 实时搜索（3.9.6）：输入停顿后直接检索，不必回车。
    subInit();
    editingController.addListener(_onEditChanged);
  }

  void _onEditChanged() {
    ctr?.add(editingController.text);
  }

  void _doSearch() {
    hasData.value = true;
    roomCtr
      ..scrollController.jumpToTop()
      ..onReload();
    userCtr
      ..scrollController.jumpToTop()
      ..onReload();
  }

  @override
  void onValueChanged(String value) {
    // 空文本回初始态；纯数字多半是房间号——等显式回车再跳转，
    // 避免逐位输入时每敲一个数字就跳一次房间。
    if (value.isEmpty || IdUtils.digitOnlyRegExp.hasMatch(value)) {
      return;
    }
    _doSearch();
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
      if (IdUtils.digitOnlyRegExp.hasMatch(editingController.text)) {
        PageUtils.toLiveRoom(int.parse(editingController.text));
      } else {
        hasData.value = true;
        roomCtr
          ..scrollController.jumpToTop()
          ..onReload();
        userCtr
          ..scrollController.jumpToTop()
          ..onReload();
      }
    }
  }

  @override
  void onClose() {
    editingController.removeListener(_onEditChanged);
    subDispose();
    editingController.dispose();
    focusNode.dispose();
    tabController.dispose();
    super.onClose();
  }
}
