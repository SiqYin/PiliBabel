import 'dart:async';

import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/common/video/video_type.dart';
import 'package:PiliPlus/models/video/play/url.dart';
import 'package:PiliPlus/services/logger.dart';
import 'package:PiliPlus/utils/connectivity_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';

/// B1 播放地址预取（对标官方 preloadedPlayViewReply / preloadedPlayViewUniteReply）。
///
/// 卡片被点开的那一刻，就按详情页首次取流会用的参数发一次请求；详情页取流时命中
/// 直接复用，省掉一次完整往返（实际是两次——App 直链与 Web 元数据并行那一对），
/// 首帧因此提前。
///
/// 三条纪律：
/// 1. 失败一律静默：预取只是抢时间，不把错误抛给用户，也不挡跳转与取流；
/// 2. 缓存短命（5 分钟）：直链本身有时效，宁可不用也不用过期地址；
/// 3. 同一 key 同一时刻只发一次（in-flight 合并）：预取与详情页取流不会重复请求。
///
/// 只有参数完全一致的请求才复用（画质、语言、音量均衡、试看、fnval 都进 key），
/// 参数不一致就老老实实重新取流，不做任何猜测性复用。
class PlayUrlPrefetch {
  PlayUrlPrefetch._();

  static const int _fnval = 4048;
  static const Duration _ttl = Duration(minutes: 5);
  static final Map<String, _Entry> _cache = <String, _Entry>{};

  /// 验收统计：实际发起的预取次数 / 命中次数 / 未命中次数。
  static int issued = 0;
  static int hit = 0;
  static int miss = 0;

  static String get stats => '预取 $issued 次 / 命中 $hit 次 / 未命中 $miss 次';

  static String _key({
    required String bvid,
    required int cid,
    required int qn,
    String? language,
    bool voiceBalance = false,
    bool tryLook = false,
  }) => '$bvid|$cid|$qn|$_fnval|${language ?? ''}|$voiceBalance|$tryLook';

  /// 详情页取流前调用：命中返回预取结果（可能仍在飞），没命中返回 null。
  ///
  /// 返回 null 就照原样发正式请求；命中但预取失败（最终返回 null）也照原样发正式
  /// 请求——两条路都不会改变原有取流行为，只是命中时省一次往返。
  static Future<PlayUrlModel?>? take({
    String? bvid,
    required int cid,
    required int qn,
    String? language,
    bool voiceBalance = false,
    bool tryLook = false,
  }) {
    if (bvid == null || cid <= 0) {
      return null;
    }
    final key = _key(
      bvid: bvid,
      cid: cid,
      qn: qn,
      language: language,
      voiceBalance: voiceBalance,
      tryLook: tryLook,
    );
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
    return entry.future;
  }

  /// 卡片点开时调用。不 await、不抛错、不阻塞跳转。
  static void prefetch({String? bvid, required int cid, int? qn}) {
    unawaited(_prefetch(bvid: bvid, cid: cid, qn: qn));
  }

  static Future<void> _prefetch({
    String? bvid,
    required int cid,
    int? qn,
  }) async {
    try {
      if (bvid == null || cid <= 0) {
        return;
      }
      final quality = qn ?? await _defaultQa();
      if (quality == null) {
        return;
      }
      final key = _key(bvid: bvid, cid: cid, qn: quality);
      if (_cache.containsKey(key)) {
        return;
      }
      issued++;
      _cache[key] = _Entry(
        _fetch(bvid: bvid, cid: cid, qn: quality),
        DateTime.now().add(_ttl),
      );
      // 顺手清过期项，缓存不会无界增长
      final now = DateTime.now();
      _cache.removeWhere((_, e) => e.expireAt.isBefore(now));
    } catch (_) {
      // 预取永远不往外抛
    }
  }

  static Future<PlayUrlModel?> _fetch({
    required String bvid,
    required int cid,
    required int qn,
  }) async {
    try {
      final res = await VideoHttp.videoUrl(
        bvid: bvid,
        cid: cid,
        qn: qn,
        tryLook: false,
        videoType: VideoType.ugc,
      );
      if (res case Success(:final response)) {
        return response;
      }
      return null;
    } catch (e) {
      logger.w('播放地址预取失败（静默降级）: $e');
      return null;
    }
  }

  /// 详情页首次取流用的画质：半屏画质优先，没设就用当前网络下的默认画质——
  /// 与 VideoDetailController 初始化 cacheVideoQa 的算法保持一致，否则预取参数
  /// 对不上，命不中。
  static Future<int?> _defaultQa() async {
    final half = Pref.defaultVideoQaHalfScreen;
    if (half != null) {
      return half;
    }
    final isWiFi = await ConnectivityUtils.isWiFi;
    return isWiFi ? Pref.defaultVideoQa : Pref.defaultVideoQaCellular;
  }
}

class _Entry {
  _Entry(this.future, this.expireAt);

  final Future<PlayUrlModel?> future;
  final DateTime expireAt;
}
