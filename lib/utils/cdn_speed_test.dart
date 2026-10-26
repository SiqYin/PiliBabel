import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:PiliPlus/http/browser_ua.dart';
import 'package:PiliPlus/utils/cdn_region.dart';
import 'package:PiliPlus/utils/connectivity_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';

/// CDN 节点实测择优。
///
/// 背景：B 站下发的候选直链里，海外用户拿到的第一条常是大陆镜像，对境外访问被
/// 限速（实测约 100KB/s），于是视频流被饿死、而码率小得多的音频流还活着 —— 表现
/// 就是「画面卡住、声音和进度条照走」。此前只在候选里静态挑第一条海外地址，挑中
/// 的那条若同样被限速就没有兜底；官方 APP 是在播放器里实测测速后换节点。
///
/// 这里对候选地址做一次轻量探测（Range 只取前 [_probeBytes] 字节），按吞吐打分
/// 排序，结果留在内存里供 [bestOf] 同步查询，并**持久化**到本地缓存：冷启动后的
/// 第一波视频直接吃上一次会话的实测结果（同一网络下节点快慢基本不变），不再
/// 全靠静态猜。
///
/// 为什么是「同步查、异步测」：[VideoUtils.getCdnUrl] 是同步方法，取流路径不能等
/// 测速。所以策略是「本次用已知最优，同时把这一轮测出来给下次用」。用户开了
/// [Pref.cdnSpeedTest]（默认开）才启用。
abstract final class CdnSpeedTest {
  /// 每条地址探测的采样量。
  ///
  /// CDN 对海外的限速普遍在**突发额度（burst）之后**才生效：只拉 64KB 会整个
  /// 落在额度内，快慢节点测出来一样快，等于白测。512KB 足以穿过典型额度、
  /// 测出持续吞吐；被限速的节点（约 100KB/s）拉满 512KB 需要 5 秒以上，会直接
  /// 撞上探测超时被判「不可用」——这正是想要的结果。
  static const int _probeBytes = 512 * 1024;

  /// 蜂窝网络下的采样量。
  ///
  /// 一轮最多探 6 条地址，按 512KB 算就是 3MB —— 对流量用户是白烧的钱，蜂窝下
  /// 还更容易撞上运营商的突发额度。蜂窝下降采样到 128KB（一轮约 0.75MB）。
  /// 代价是测出来的持续吞吐更粗糙：被限速的节点不再会因为超时被判死，而是靠
  /// 评分排在快节点后面，择优结论仍然成立。
  static const int _probeBytesCellular = 128 * 1024;

  /// 单条地址的探测超时。海外慢节点本来就是要被淘汰的，超时即视为不可用。
  static const Duration _probeTimeout = Duration(seconds: 6);

  /// 一次探测最多并行几条，避免把刚起步的播放抢带宽。
  static const int _maxProbes = 6;

  /// 内存中实测结果的有效期：超过后后台重新探测（自愈网络变化）。
  static const Duration _retestTtl = Duration(minutes: 30);

  /// 持久化结果的有效期：过期后 [bestOf] 不再采用（静态挑选兜底）。
  static const Duration _persistTtl = Duration(days: 7);

  /// host -> 评分（字节/毫秒，越大越快）。只保留本轮探测到的主机。
  static final Map<String, double> _score = <String, double>{};

  static DateTime? _testedAt;

  /// 上一次「一轮探测全军覆没」的时间，用于给地区重识别节流。
  static DateTime? _lastEmptyAt;
  static Future<void>? _running;
  static bool _loaded = false;

  /// 启动后首次使用时把上次会话的实测结果装回来。
  static void _ensureLoaded() {
    if (_loaded) {
      return;
    }
    _loaded = true;
    try {
      final raw = GStorage.localCache.get(LocalCacheKey.cdnSpeedScores);
      if (raw is! String || raw.isEmpty) {
        return;
      }
      final data = jsonDecode(raw);
      if (data is! Map) {
        return;
      }
      final ts = data['ts'];
      if (ts is! int) {
        return;
      }
      final at = DateTime.fromMillisecondsSinceEpoch(ts);
      if (DateTime.now().difference(at) > _persistTtl) {
        return;
      }
      final scores = data['scores'];
      if (scores is Map) {
        scores.forEach((k, v) {
          if (v is num && v > 0) {
            _score[k.toString()] = v.toDouble();
          }
        });
        _testedAt = at;
      }
    } catch (_) {}
  }

  static void _persist() {
    try {
      GStorage.localCache.put(
        LocalCacheKey.cdnSpeedScores,
        jsonEncode({
          'ts': _testedAt?.millisecondsSinceEpoch,
          'scores': _score,
        }),
      );
    } catch (_) {}
  }

  /// 网络切换后调用：换网后节点快慢完全不同，旧评分只会误导挑选。
  ///
  /// 内存评分与持久化存档一起清掉，并把 [_loaded] 置真，避免下一次
  /// [_ensureLoaded] 又把旧网络的结果装回来。
  static void reset() {
    _score.clear();
    _testedAt = null;
    _running = null;
    _loaded = true;
    try {
      GStorage.localCache.delete(LocalCacheKey.cdnSpeedScores);
    } catch (_) {}
  }

  /// 是否已有可用的实测结果（含跨会话持久化的，7 天内有效）。
  static bool get hasResult {
    _ensureLoaded();
    return _score.isNotEmpty &&
        _testedAt != null &&
        DateTime.now().difference(_testedAt!) <= _persistTtl;
  }

  /// 在候选里挑出实测最快的一条；没有结果或都未测到时返回 null（调用方沿用
  /// 原有静态挑选）。
  static String? bestOf(Iterable<String> urls) {
    if (!hasResult) {
      return null;
    }
    String? best;
    var bestScore = 0.0;
    for (final url in urls) {
      final host = _hostOf(url);
      if (host == null) {
        continue;
      }
      final score = _score[host];
      if (score != null && score > bestScore) {
        bestScore = score;
        best = url;
      }
    }
    return best;
  }

  /// 对候选地址做一轮探测。同一时刻只跑一轮；**本轮会话内**已有未过期结果时
  /// 不重复测（持久化的旧结果不算数——后台重新探测自愈网络变化，测完刷新）。
  static Future<void> test(Iterable<String> urls, {bool force = false}) {
    _ensureLoaded();
    if (_running != null) {
      return _running!;
    }
    final fresh =
        _testedAt != null &&
        DateTime.now().difference(_testedAt!) <= _retestTtl;
    if (!force && fresh) {
      return Future<void>.value();
    }
    final targets = <String>[];
    final seen = <String>{};
    for (final url in urls) {
      final host = _hostOf(url);
      if (host == null || !seen.add(host)) {
        continue;
      }
      targets.add(url);
      if (targets.length >= _maxProbes) {
        break;
      }
    }
    if (targets.isEmpty) {
      return Future<void>.value();
    }
    return _running = _run(targets).whenComplete(() => _running = null);
  }

  static Future<void> _run(List<String> targets) async {
    final result = <String, double>{};
    final probeBytes = await _probeBytesNow();
    // 每探完一台就写进评分并刷新时间戳：起播侧只等一个有限预算，先回来的
    // 先算数（A4.3 首帧优先），而不是等整轮跑完才有分可用。
    await Future.wait(
      targets.map(
        (url) => _probe(url, result, probeBytes).whenComplete(() {
          if (result.isEmpty) return;
          _score.addAll(result);
          _testedAt = DateTime.now();
        }),
      ),
    );
    if (result.isEmpty) {
      // 一轮探测全军覆没：网络环境很可能已经变了（也可能只是直链签名过期）。
      // 把地区判定标记过期并重新识别一次；10 分钟内不重复触发，避免请求风暴。
      final now = DateTime.now();
      final last = _lastEmptyAt;
      if (last == null || now.difference(last) > const Duration(minutes: 10)) {
        _lastEmptyAt = now;
        CdnRegionResolver.invalidateAndRedetect();
      }
      return;
    }
    // 合并而不是整体替换：这一轮没测到的老主机保留上一次的评分，避免因为一次
    // 探测抖动把已知可用的节点丢掉。
    _score.addAll(result);
    _testedAt = DateTime.now();
    _persist();
  }

  /// 本轮探测的采样量：蜂窝网络下降低采样（见 [_probeBytesCellular]）。
  static Future<int> _probeBytesNow() async {
    if (await ConnectivityUtils.isCellular) {
      return _probeBytesCellular;
    }
    return _probeBytes;
  }

  static Future<void> _probe(
    String url,
    Map<String, double> out,
    int probeBytes,
  ) async {
    final host = _hostOf(url);
    if (host == null) {
      return;
    }
    final client = HttpClient()..connectionTimeout = _probeTimeout;
    try {
      final request = await client.getUrl(Uri.parse(url)).timeout(_probeTimeout);
      request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-$probeBytes');
      request.headers.set(HttpHeaders.userAgentHeader, BrowserUa.pc);
      // 直链签名与请求指纹绑定，这里只读不改，Referer 保持不设。
      final watch = Stopwatch()..start();
      final response = await request.close().timeout(_probeTimeout);
      if (response.statusCode != 200 && response.statusCode != 206) {
        return;
      }
      var received = 0;
      var firstByteMs = 0.0;
      await for (final chunk in response.timeout(_probeTimeout)) {
        if (firstByteMs == 0) {
          firstByteMs = watch.elapsedMicroseconds / 1000.0;
        }
        received += chunk.length;
        if (received >= probeBytes) {
          break;
        }
      }
      if (received <= 0) {
        return;
      }
      final totalMs = watch.elapsedMicroseconds / 1000.0;
      final throughput = received / (totalMs <= 0 ? 1.0 : totalMs);
      // 首字节时间作为惩罚项：高吞吐但握手很慢的节点，起播体验依然差。
      out[host] = throughput - firstByteMs * 0.05;
    } catch (_) {
      // 探测失败即视为该地址本轮不可用，不写入评分。
    } finally {
      client.close(force: true);
    }
  }

  static String? _hostOf(String url) {
    final host = Uri.tryParse(url)?.host;
    return (host == null || host.isEmpty) ? null : host;
  }
}
