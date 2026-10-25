import 'dart:math';

import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/common/rcmd_mode.dart';
import 'package:PiliPlus/models/model_rec_video_item.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/services/logger.dart';
import 'package:PiliPlus/utils/image_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';

class RcmdController extends CommonListController {
  /// 每页预取的封面数：首屏之后的条目提前拉进图片缓存，滚动时直接命中
  /// （海外图片请求 RTT 高，预取对流畅度收益明显）。
  static const _prefetchCovers = 10;

  late bool enableSaveLastData = Pref.enableSaveLastData;
  final RcmdMode rcmdMode = Pref.rcmdMode;
  bool get appRcmd => rcmdMode == RcmdMode.app;

  int? lastRefreshAt;
  late bool savedRcmdTip = Pref.savedRcmdTip;

  // 合并模式专用页码：Web端由基类 page 管理（自动 ++），App端在此自管
  int _appPage = 0;
  bool _isFirstPage = false;

  @override
  bool get isEnd => false;

  @override
  void onInit() {
    super.onInit();
    page = 0;
    _appPage = 0;
    queryData();
  }

  @override
  Future<LoadingState> customGetData() async {
    if (rcmdMode != RcmdMode.merged) {
      // 单源模式：App / Web 两源的元素类型不同，三元合并后按运行时类型判断。
      _isFirstPage = (page == 0);
      final res = await (appRcmd
          ? VideoHttp.rcmdVideoListApp(freshIdx: page)
          : VideoHttp.rcmdVideoList(freshIdx: page, ps: 20));
      if (res case Success(:final response)
          when response is List<BaseRcmdVideoItemModel>) {
        _prefetchTailCovers(response);
      }
      return res;
    }

    // 合并模式：并行请求
    _isFirstPage = (page == 0 && _appPage == 0);
    final results = await Future.wait([
      VideoHttp.rcmdVideoList(freshIdx: page, ps: 20),
      VideoHttp.rcmdVideoListApp(freshIdx: _appPage),
    ]);

    // 静默降级：一个成功就展示
    List<BaseRcmdVideoItemModel> webList = [];
    List<BaseRcmdVideoItemModel> appList = [];
    if (results[0] case Success(:final response)) {
      webList = response;
    } else {
      logger.w('Web端推荐获取失败: ${results[0]}');
    }
    if (results[1] case Success(:final response)) {
      appList = response;
    } else {
      logger.w('App端推荐获取失败: ${results[1]}');
    }

    // 交错排列 + 按 aid 去重
    final seen = <int>{};
    final merged = <BaseRcmdVideoItemModel>[];
    final minLen = min(appList.length, webList.length);
    for (int i = 0; i < minLen; i++) {
      if (appList[i].aid != null && seen.add(appList[i].aid!)) {
        merged.add(appList[i]);
      }
      if (webList[i].aid != null && seen.add(webList[i].aid!)) {
        merged.add(webList[i]);
      }
    }
    // 多出的部分追加到末尾
    for (int i = minLen; i < appList.length; i++) {
      if (appList[i].aid != null && seen.add(appList[i].aid!)) {
        merged.add(appList[i]);
      }
    }
    for (int i = minLen; i < webList.length; i++) {
      if (webList[i].aid != null && seen.add(webList[i].aid!)) {
        merged.add(webList[i]);
      }
    }

    _appPage++; // App端页码自增（Web端由基类 page++ 管理）

    _prefetchTailCovers(merged);
    return Success(merged);
  }

  /// 预取本批后半段的封面：首屏（两列网格约 4~6 张）立即可见不需要预取，
  /// 之后的条目提前进缓存。不抛异常、不阻塞数据返回。
  void _prefetchTailCovers(List<BaseRcmdVideoItemModel> list) {
    try {
      if (list.length > 6) {
        ImageUtils.prefetchImages(
          list.skip(6).take(_prefetchCovers).map((e) => e.cover),
        );
      }
    } catch (_) {}
  }

  @override
  bool handleError(String? errMsg) {
    return enableSaveLastData;
  }

  @override
  void handleListResponse(List dataList) {
    if (enableSaveLastData && _isFirstPage) {
      if (loadingState.value case Success(:final response)) {
        if (response != null && response.isNotEmpty) {
          if (savedRcmdTip) {
            lastRefreshAt = dataList.length;
          }
          if (response.length > 200) {
            dataList.addAll(response.take(50));
          } else {
            dataList.addAll(response);
          }
        }
      }
    }
  }

  @override
  Future<void> onRefresh() {
    page = 0;
    _appPage = 0; // 重置 App 端页码
    isEnd = false;
    return queryData();
  }
}
