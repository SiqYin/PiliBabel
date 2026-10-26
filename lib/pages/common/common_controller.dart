import 'dart:async';

import 'package:PiliPlus/common/widgets/flutter/refresh_indicator.dart'
    show RefreshIndicatorState;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/utils/net_status.dart';
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/widgets.dart' show GlobalKey, ScrollController;
import 'package:get/get.dart';

mixin ScrollOrRefreshMixin {
  ScrollController get scrollController;

  String get topOrRefreshThrottleKey =>
      'topOrRefresh_${identityHashCode(this)}';

  String get topAndRefreshThrottleKey =>
      'topAndRefresh_${identityHashCode(this)}';

  Future<void> animateToTop() => scrollController.animToTop();

  Future<void> onRefresh();

  void toTopAndRefresh() {
    EasyThrottle.throttle(
      topAndRefreshThrottleKey,
      const Duration(milliseconds: 500),
      () async {
        if (scrollController.hasClients &&
            scrollController.position.pixels != 0) {
          await animateToTop();
        }
        await showRefresh();
      },
    );
  }

  Future<void> showRefresh() => onRefresh();

  void toTopOrRefresh() {
    if (scrollController.hasClients) {
      if (scrollController.position.pixels == 0) {
        EasyThrottle.throttle(
          topOrRefreshThrottleKey,
          const Duration(milliseconds: 500),
          showRefresh,
        );
      } else {
        animateToTop();
      }
    }
  }
}

abstract class CommonController<R, T> extends GetxController
    with ScrollOrRefreshMixin {
  @override
  final ScrollController scrollController = ScrollController();

  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Future<void> showRefresh() =>
      refreshKey.currentState?.show() ?? onRefresh();

  bool isLoading = false;
  Rx<LoadingState> get loadingState;

  Future<LoadingState<R>> customGetData();

  Future<void> queryData([bool isRefresh = true]);

  bool customHandleResponse(bool isRefresh, Success<R> response) {
    return false;
  }

  bool handleError(String? errMsg) {
    return false;
  }

  @override
  Future<void> onRefresh() {
    return queryData();
  }

  Future<void> onLoadMore() {
    return queryData(false);
  }

  Future<void> onReload() {
    return onRefresh();
  }

  /// 网络恢复后自动补拉（A5.2）：页面落到错误态就挂上监听，拿到数据就解除。
  /// 用 loadingState 驱动，所有子类（列表页、搜索、评论等）自动获得这个行为；
  /// 用户正常浏览时不会被网络波动打扰。
  void Function()? _netRestoreRetry;

  void armNetRestoreRetry() {
    _netRestoreRetry ??= _onNetRestore;
    NetStatus.restored.removeListener(_netRestoreRetry!);
    NetStatus.restored.addListener(_netRestoreRetry!);
  }

  void disarmNetRestoreRetry() {
    final retry = _netRestoreRetry;
    if (retry != null) {
      NetStatus.restored.removeListener(retry);
    }
  }

  void _onNetRestore() {
    if (isClosed) return;
    if (loadingState.value is Error) {
      onReload();
    }
  }

  @override
  void onInit() {
    super.onInit();
    try {
      ever(loadingState, (LoadingState state) {
        if (state is Error) {
          armNetRestoreRetry();
        } else if (state is Success) {
          disarmNetRestoreRetry();
        }
      });
    } catch (_) {
      // loadingState 由子类延迟初始化时先跳过自动补拉，不影响页面本身
    }
  }

  @override
  void onClose() {
    disarmNetRestoreRetry();
    scrollController.dispose();
    super.onClose();
  }
}
