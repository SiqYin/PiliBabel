import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/pages/common/common_controller.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

abstract class CommonListController<R, T> extends CommonController<R, T> {
  int page = 1;
  bool isEnd = false;
  bool? hasFooter;

  @override
  Rx<LoadingState<List<T>?>> loadingState =
      LoadingState<List<T>?>.loading().obs;

  void handleListResponse(List<T> dataList) {}

  List<T>? getDataList(R response) {
    return response as List<T>?;
  }

  void checkIsEnd(int length) {}

  /// 「刷新失败保留上次数据」的通用实现，子类在 [handleError] 里直接 return 它。
  ///
  /// 刷新失败（网络抖动、风控拦截、海外线路抖动）时不清空已经加载出来的列表，
  /// 只弹一条提示——对齐首页推荐流的「保留上次内容」。
  ///
  /// 首次加载没有旧数据时不保留，仍然正常报错，避免页面卡在加载态。
  bool keepLastDataOnError(String? errMsg) {
    if (loadingState.value case Success(:final response)) {
      if (response == null || response.isEmpty) {
        return false;
      }
      if (errMsg != null && errMsg.isNotEmpty) {
        SmartDialog.showToast(errMsg);
      }
      return true;
    }
    return false;
  }

  @override
  Future<void> queryData([bool isRefresh = true]) async {
    if (isLoading || (!isRefresh && isEnd)) return;
    isLoading = true;
    final LoadingState<R> res = await customGetData();
    if (res case Success(:final response)) {
      if (!customHandleResponse(isRefresh, res)) {
        final dataList = getDataList(response);
        if (dataList == null || dataList.isEmpty) {
          isEnd = true;
          if (isRefresh) {
            loadingState.value = Success(dataList);
          } else if (hasFooter == true) {
            loadingState.refresh();
          }
          isLoading = false;
          return;
        }
        handleListResponse(dataList);
        if (isRefresh) {
          checkIsEnd(dataList.length);
          loadingState.value = Success(dataList);
        } else if (loadingState.value case Success(:final response)) {
          response!.addAll(dataList);
          checkIsEnd(response.length);
          loadingState.refresh();
        }
      }
      page++;
    } else {
      if (isRefresh && !handleError(res is Error ? res.errMsg : null)) {
        loadingState.value = res as Error;
      }
    }
    isLoading = false;
  }

  @override
  Future<void> onRefresh() {
    page = 1;
    isEnd = false;
    return super.onRefresh();
  }

  @override
  Future<void> onReload() {
    loadingState.value = LoadingState<List<T>?>.loading();
    return super.onReload();
  }
}
