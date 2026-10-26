import 'dart:async';

import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show MainListReply, Mode;
import 'package:PiliPlus/grpc/reply.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/reply/reply_sort_type.dart';
import 'package:PiliPlus/utils/storage_pref.dart';

/// D1 评论首屏预取（对标官方 Chronos 的 GetPreloadResources / PreloadResources，
/// 限次重试对应 comment_preload_attempt_limit）。
///
/// 点开视频那一刻，就按评论列表首次请求会用的参数（oid + type + 排序）取一次首屏；
/// 评论控制器首屏命中就直接渲染，省掉一次完整往返，也不再出现加载骨架。
///
/// 四条纪律：
/// 1. 限次重试（默认 2 次）后失败静默——预取失败就退回正常加载，绝不报错、绝不卡住；
/// 2. 缓存带 TTL（3 分钟）和版本号，过期或版本变化一律不用；
/// 3. 键里带排序模式，热门/最新互不串用（D4.1 排序缓存隔离）；
/// 4. 只服务首屏（游标为空的首页），翻页一律走正常请求。
class ReplyPrefetch {
  ReplyPrefetch._();

  /// 对标官方 comment_preload_attempt_limit：预取最多试 2 次，不做无限重试
  static const int _maxAttempts = 2;

  /// D3.1 缓存过期策略：时间（3 分钟）+ 版本号
  static const Duration _ttl = Duration(minutes: 3);

  /// 缓存版本：评论解析结构或过滤规则变了就 +1，旧缓存立即作废
  static const int _cacheVersion = 1;

  static final Map<String, _Entry> _cache = <String, _Entry>{};

  static int issued = 0;
  static int hit = 0;
  static int miss = 0;

  static String get stats => '评论预取 $issued 次 / 命中 $hit 次 / 未命中 $miss 次';

  /// 用户当前的评论排序对应的 gRPC 模式（与 ReplyController.onInit 的算法一致）
  static Mode get defaultMode => Pref.replySortType == ReplySortType.time
      ? Mode.MAIN_LIST_TIME
      : Mode.MAIN_LIST_HOT;

  static String _key(int oid, int type, Mode mode) =>
      '$_cacheVersion|$oid|$type|${mode.value}';

  /// 点开视频/动态时调用。不 await、不抛错、不阻塞跳转。
  static void prefetch({required int oid, required int type, Mode? mode}) {
    unawaited(_prefetch(oid: oid, type: type, mode: mode));
  }

  static Future<void> _prefetch({
    required int oid,
    required int type,
    Mode? mode,
  }) async {
    try {
      if (oid <= 0) {
        return;
      }
      final m = mode ?? defaultMode;
      final key = _key(oid, type, m);
      if (_cache.containsKey(key)) {
        return;
      }
      issued++;
      _cache[key] = _Entry(
        _fetch(oid: oid, type: type, mode: m),
        DateTime.now().add(_ttl),
      );
      final now = DateTime.now();
      _cache.removeWhere((_, e) => e.expireAt.isBefore(now));
    } catch (_) {
      // 预取失败不影响任何东西
    }
  }

  static Future<MainListReply?> _fetch({
    required int oid,
    required int type,
    required Mode mode,
  }) async {
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final res = await ReplyGrpc.mainList(
          oid: oid,
          type: type,
          mode: mode,
          offset: null,
          cursorNext: null,
        );
        if (res case Success(:final response)) {
          return response;
        }
      } catch (_) {
        // 落到下面的退避重试
      }
      if (attempt < _maxAttempts) {
        await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
      }
    }
    return null;
  }

  /// 首屏请求前调用：命中返回预取结果（可能仍在飞），没命中返回 null。
  static Future<MainListReply?>? takeFirstPage({
    required int oid,
    required int type,
    required Mode mode,
  }) {
    if (oid <= 0) {
      return null;
    }
    final key = _key(oid, type, mode);
    final entry = _cache[key];
    if (entry == null) {
      miss++;
      return null;
    }
    if (entry.expireAt.isBefore(DateTime.now())) {
      _cache.remove(key);
      miss++;
      return null;
    }
    hit++;
    // 一次性消费：命中即取走。否则下拉刷新/失败重试会反复拿到同一份旧结果
    // （预取失败时就是反复秒失败，根本不会重新请求）。
    _cache.remove(key);
    return entry.future;
  }
}

class _Entry {
  _Entry(this.future, this.expireAt);

  final Future<MainListReply?> future;
  final DateTime expireAt;
}
