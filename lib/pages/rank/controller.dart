import 'dart:async';

import 'package:PiliPlus/models/common/rank_type.dart';
import 'package:PiliPlus/pages/common/common_controller.dart';
import 'package:PiliPlus/pages/main/controller.dart';
import 'package:PiliPlus/pages/rank/zone/controller.dart';
import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RankController extends GetxController
    with GetSingleTickerProviderStateMixin, ScrollOrRefreshMixin {
  RxInt tabIndex = 0.obs;
  late TabController tabController;

  ZoneController get controller {
    final item = RankType.values[tabController.index];
    return Get.find<ZoneController>(tag: '${item.rid}${item.seasonType}');
  }

  @override
  ScrollController get scrollController => controller.scrollController;

  final _mainCtr = Get.find<MainController>();

  final tabScrollController = ScrollController();

  void scrollToCurrentIndex(double tabHeight, int index) {
    final position = tabScrollController.position;
    final offset = clampDouble(
      (tabHeight * (2 * index + 1) - position.viewportDimension) / 2.0 +
          (_mainCtr.useBottomNav && (_mainCtr.showBottomBar?.value ?? true)
              ? 80.0
              : 0.0),
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    tabScrollController.animateTo(
      offset,
      duration: kTabScrollDuration,
      curve: Curves.ease,
    );
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: RankType.values.length, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    tabScrollController.dispose();
    super.onClose();
  }

  @override
  Future<void> onRefresh() => controller.onRefresh();
}
