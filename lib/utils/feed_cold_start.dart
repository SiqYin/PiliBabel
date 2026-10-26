import 'dart:async';

import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/home/rcmd/result.dart';
import 'package:PiliPlus/utils/accounts.dart';

/// B4 首页冷启动首屏 + feed 事件参数（对标官方 /x/v2/feed/coldstart、
/// login_event / open_event / banner_hash 这套参数）。
///
/// 官方在 App 冷启动时就把首屏 feed 先取回来，用户点开首页直接渲染。这里做等价
/// 处理：启动阶段（账号就绪后）预取一次，首页第一屏命中就直接用，省一次完整往返。
///
/// 纪律：只缓存 90 秒（首屏内容要新鲜，过期就正常请求）；未登录不预取（匿名 feed
/// 与登录态内容不同）；解析不出条目、请求失败一律静默放弃——绝不影响首页正常加载。
class FeedColdStart {
  FeedColdStart._();

  static const Duration _ttl = Duration(seconds: 90);
  static List<RcmdVideoItemAppModel>? _items;
  static DateTime? _at;

  static int issued = 0;
  static int hit = 0;
  static int miss = 0;

  static String get stats => '冷启动预取 $issued 次 / 命中 $hit 次 / 未命中 $miss 次';

  /// B4.1 官方 feed 的 open_event：本次进程内第一次取 feed 才置 1，之后都置 0。
  static bool _openEventPending = true;

  static int consumeOpenEvent() {
    if (_openEventPending) {
      _openEventPending = false;
      return 1;
    }
    return 0;
  }

  /// 启动阶段调用，不 await、不抛错。
  static void warm() {
    unawaited(_warm());
  }

  static Future<void> _warm() async {
    try {
      if (!Accounts.main.isLogin) {
        return;
      }
      issued++;
      final res = await VideoHttp.rcmdVideoListApp(freshIdx: 0, coldStart: true);
      if (res case Success(:final response)) {
        if (response.isNotEmpty) {
          _items = response;
          _at = DateTime.now();
        }
      }
    } catch (_) {
      // 冷启动预取失败不影响首页
    }
  }

  /// 首页第一屏请求前调用：命中返回预取结果，没命中返回 null（照常请求）。
  static List<RcmdVideoItemAppModel>? take() {
    final items = _items;
    final at = _at;
    if (items == null || at == null) {
      miss++;
      return null;
    }
    if (DateTime.now().difference(at) > _ttl) {
      miss++;
      return null;
    }
    hit++;
    return items;
  }
}
