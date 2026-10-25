import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:PiliPlus/http/browser_ua.dart';
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
    await Future.wait(targets.map((url) => _probe(url, result)));
    if (result.isEmpty) {
      return;
    }
    // 合并而不是整体替换：这一轮没测到的老主机保留上一次的评分，避免因为一次
    // 探测抖动把已知可用的节点丢掉。
    _score.addAll(result);
    _testedAt = DateTime.now();
    _persist();
  }

  static Future<void> _probe(String url, Map<String, double> out) async {
    final host = _hostOf(url);
    if (host == null) {
      return;
    }
    final client = HttpClient()..connectionTimeout = _probeTimeout;
    try {
      final request = await client.getUrl(Uri.parse(url)).timeout(_probeTimeout);
      request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-$_probeBytes');
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
        if (received >= _probeBytes) {
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
