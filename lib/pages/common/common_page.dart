import 'package:PiliPlus/common/constants.dart' show StyleString;
import 'package:PiliPlus/pages/common/common_controller.dart';
import 'package:PiliPlus/pages/main/controller.dart';
import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class CommonPageState<
  T extends StatefulWidget,
  R extends CommonController
>
    extends State<T> {
  R get controller;
  final _mainController = Get.find<MainController>();
  RxDouble? _barOffset;

  @override
  void initState() {
    super.initState();
    _barOffset = _mainController.barOffset;
  }

  Widget onBuild(Widget child) {
    if (_barOffset != null) {
      return NotificationListener<ScrollUpdateNotification>(
        onNotification: onNotification,
        child: child,
      );
    }
    return child;
  }

  bool onNotification(ScrollUpdateNotification notification) {
    if (!_mainController.useBottomNav) return false;

    final metrics = notification.metrics;
    if (metrics.axis == .horizontal ||
        metrics.pixels < 0 ||
        notification.dragDetails == null) {
      return false;
    }

    final scrollDelta = notification.scrollDelta ?? 0.0;
    _barOffset!.value = clampDouble(
      _barOffset!.value + scrollDelta,
      0.0,
      StyleString.topBarHeight,
    );

    return false;
  }

  @override
  void dispose() {
    _barOffset = null;
    super.dispose();
  }
}
