import 'dart:async';
import 'dart:io';

import 'package:PiliPlus/http/browser_ua.dart';

/// CDN 节点实测择优。
///
/// 背景：B 站下发的候选直链里，海外用户拿到的第一条常是大陆镜像，对境外访问被
/// 限速（实测约 100KB/s），于是视频流被饿死、而码率小得多的音频流还活着 —— 表现
/// 就是「画面卡住、声音和进度条照走」。此前只在候选里静态挑第一条海外地址，挑中
/// 的那条若同样被限速就没有兜底；官方 APP 是在播放器里实测测速后换节点。
///
/// 这里对候选地址做一次轻量探测（Range 只取前 [_probeBytes] 字节），按吞吐打分
/// 排序，结果留在内存里供 [bestOf] 同步查询。
///
/// 为什么是「同步查、异步测」：[VideoUtils.getCdnUrl] 是同步方法，取流路径不能等
/// 测速。所以策略是「本次用已知最优，同时把这一轮测出来给下次用」——第一次播放
/// 仍走静态挑选，同一条视频的后续取流、换线、切清晰度就能吃到实测结果。用户开了
/// [Pref.cdnSpeedTest]（默认开）才启用。
abstract final class CdnSpeedTest {
  /// 每条地址探测的采样量。太小测不出吞吐差异，太大拖慢后台探测。
  static const int _probeBytes = 64 * 1024;

  /// 单条地址的探测超时。海外慢节点本来就是要被淘汰的，超时即视为不可用。
  static const Duration _probeTimeout = Duration(seconds: 4);

  /// 一次探测最多并行几条，避免把刚起步的播放抢带宽。
  static const int _maxProbes = 6;

  /// 结果有效期。网络会变，过期后重新测。
  static const Duration _resultTtl = Duration(minutes: 30);

  /// host -> 评分（字节/毫秒，越大越快）。只保留本轮探测到的主机。
  static final Map<String, double> _score = <String, double>{};

  static DateTime? _testedAt;
  static Future<void>? _running;

  /// 是否已有可用的实测结果。
  static bool get hasResult =>
      _score.isNotEmpty &&
      _testedAt != null &&
      DateTime.now().difference(_testedAt!) <= _resultTtl;

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

  /// 对候选地址做一轮探测。同一时刻只跑一轮；已有结果且未过期时不重复测。
  static Future<void> test(Iterable<String> urls, {bool force = false}) {
    if (_running != null) {
      return _running!;
    }
    if (!force && hasResult) {
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
