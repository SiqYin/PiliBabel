import 'dart:async';
import 'dart:math';

import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/common/rcmd_mode.dart';
import 'package:PiliPlus/models/model_rec_video_item.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/services/logger.dart';
import 'package:PiliPlus/utils/connectivity_utils.dart';
import 'package:PiliPlus/utils/feed_cold_start.dart';
import 'package:PiliPlus/utils/image_utils.dart';
import 'package:PiliPlus/utils/play_url_prefetch.dart';
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

  /// B3：首屏预取播放地址的条数（前 N 条最可能被点开）
  static const int _prefetchPlayUrl = 2;

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
      // 单源模式：App / Web 两源经三元合并后静态类型即 List<BaseRcmdVideoItemModel>。
      _isFirstPage = (page == 0);
      // B4.2 首页第一屏优先吃冷启动预取结果（90 秒内有效），命中省一次往返
      final cold = page == 0 ? FeedColdStart.take() : null;
      final LoadingState<List<BaseRcmdVideoItemModel>> res;
      if (cold != null) {
        res = Success(cold);
      } else {
        res = await (appRcmd
            ? VideoHttp.rcmdVideoListApp(freshIdx: page)
            : VideoHttp.rcmdVideoList(freshIdx: page, ps: 20));
      }
      if (res case Success(:final response)) {
        _prefetchTailCovers(response);
      }
      return res;
    }

    // 合并模式：并行请求
    _isFirstPage = (page == 0 && _appPage == 0);
    // B4.2 合并模式下 App 那一路同样优先吃冷启动预取结果
    final cold = _appPage == 0 ? FeedColdStart.take() : null;
    final results = await Future.wait([
      VideoHttp.rcmdVideoList(freshIdx: page, ps: 20),
      cold != null
          ? Future.value(Success(cold))
          : VideoHttp.rcmdVideoListApp(freshIdx: _appPage),
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

  /// B3 卡片资源预加载（对标官方 feedsState changed start updatePreload）：首屏数据
  /// 一到就把最可能被点开的前两条播放地址先取回来，用户点开直接命中预取结果。
  /// 只在 WiFi 下做——蜂窝不发额外请求，省流量优先；失败静默，绝不影响列表。
  void _prefetchTopPlayUrl(List dataList) {
    try {
      final items = dataList
          .whereType<BaseRcmdVideoItemModel>()
          .take(_prefetchPlayUrl)
          .toList(growable: false);
      if (items.isEmpty) {
        return;
      }
      unawaited(
        ConnectivityUtils.isWiFi.then((isWiFi) {
          if (!isWiFi) {
            return;
          }
          for (final item in items) {
            final bvid = item.bvid;
            final cid = item.cid;
            if (bvid == null || cid == null || cid <= 0) {
              continue;
            }
            PlayUrlPrefetch.prefetch(bvid: bvid, cid: cid);
          }
        }),
      );
    } catch (_) {
      // 预取失败不影响列表
    }
  }

  @override
  bool handleError(String? errMsg) {
    return enableSaveLastData;
  }

  @override
  void handleListResponse(List dataList) {
    // B3：首屏到手即预取前两条播放地址（PlayUrlPrefetch 按 key 去重，
    // 下拉刷新不会重复取）
    if (_isFirstPage) {
      _prefetchTopPlayUrl(dataList);
    }
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
