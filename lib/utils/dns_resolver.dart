import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

/// 自解析层，对标官方客户端的 HTTPDNS。
///
/// 官方走的是自研网络引擎 Ignet + 自家 HTTPDNS 服务（com.bilibili.ignetdns.IgHttpDns /
/// tv.danmaku.bili.httpdns.api.HttpDns，配置键 httpdns.bili_single_isp_services），
/// 端点不在 dex 也不在 native 库里，无法照搬，所以这里用「进程内解析缓存 + 系统解析 +
/// DoH 回退」做到行为等价：解析结果有缓存、有失败降级、不再挡在请求的关键路径上。
///
/// 红线：只替换解析结果，绝不改写 URL 域名——B 站直链签名与主机绑定，
/// 改域名会让签名失效。
class DnsResolver {
  DnsResolver._();

  static final DnsResolver instance = DnsResolver._();

  /// 解析成功缓存时长。CDN 调度变化快，取 5 分钟。
  static const Duration _ttlSuccess = Duration(minutes: 5);

  /// 解析失败缓存时长，避免失败时反复打满解析器。
  static const Duration _ttlFailure = Duration(seconds: 20);

  static const Duration _systemTimeout = Duration(seconds: 3);
  static const Duration _dohTimeout = Duration(seconds: 5);

  /// DoH 服务，按顺序回退。都用 JSON 接口，不引额外依赖。
  static const List<String> _dohProviders = <String>[
    'https://1.1.1.1/dns-query',
    'https://8.8.8.8/resolve',
    'https://223.5.5.5/resolve',
  ];

  /// DoH 服务自身的主机：这些永远走系统解析，否则自锁。
  static const Set<String> _dohHosts = <String>{
    '1.1.1.1',
    '8.8.8.8',
    '223.5.5.5',
  };

  static final Map<String, _DnsEntry> _cache = <String, _DnsEntry>{};
  static final Map<String, Future<List<InternetAddress>?>> _inflight =
      <String, Future<List<InternetAddress>?>>{};

  static int hitCount = 0;
  static int staleHitCount = 0;
  static int missCount = 0;
  static int dohCount = 0;
  static int failCount = 0;

  static bool isDohHost(String host) => _dohHosts.contains(_normalize(host));

  static String _normalize(String host) {
    var h = host.trim().toLowerCase();
    if (h.endsWith('.')) h = h.substring(0, h.length - 1);
    return h;
  }

  static bool _isIpLiteral(String host) => InternetAddress.tryParse(host) != null;

  /// 取缓存里现成的解析结果（含已过期但还留着的旧值），拿不到返回 null。
  static List<InternetAddress>? peek(String host) {
    final entry = _cache[_normalize(host)];
    if (entry == null || entry.addresses.isEmpty) return null;
    return entry.addresses;
  }

  /// 解析主机；返回 null 表示彻底失败，调用方应回退系统解析。
  static Future<List<InternetAddress>?> lookup(
    String host, {
    bool useCache = true,
  }) async {
    final key = _normalize(host);
    if (key.isEmpty) return null;
    if (_isIpLiteral(key)) {
      final ip = InternetAddress.tryParse(key);
      return ip == null ? null : <InternetAddress>[ip];
    }
    final entry = _cache[key];
    if (entry != null) {
      final fresh = entry.expireAt.isAfter(DateTime.now());
      if (fresh) {
        if (entry.addresses.isEmpty) {
          // 失败结果在有效期内直接返回 null，不再打解析器
          failCount++;
          return null;
        }
        hitCount++;
        return entry.addresses;
      }
      if (entry.addresses.isNotEmpty) {
        // 过期先用旧值，后台刷新：解析不再挡在请求关键路径上
        staleHitCount++;
        unawaited(_resolve(key));
        return entry.addresses;
      }
    }
    if (!useCache && entry != null) {
      missCount++;
      return _resolve(key);
    }
    missCount++;
    return _resolve(key);
  }

  /// 预热：把主机提前解析进缓存，首次请求就不用等解析。
  static void warm(Iterable<String> hosts) {
    for (final host in hosts) {
      final key = _normalize(host);
      if (key.isEmpty || _isIpLiteral(key)) continue;
      final entry = _cache[key];
      if (entry != null && entry.expireAt.isAfter(DateTime.now())) continue;
      unawaited(_resolve(key));
    }
  }

  /// 换网后作废全部结果：旧网络下的解析结果不一定还适用。
  static void invalidate() {
    _cache.clear();
    _inflight.clear();
  }

  static String stats() =>
      'hit=$hitCount stale=$staleHitCount miss=$missCount doh=$dohCount fail=$failCount cache=${_cache.length}';

  static void logStats() {
    if (kDebugMode) debugPrint('DnsResolver $stats()');
  }

  static Future<List<InternetAddress>?> _resolve(String host) {
    final existing = _inflight[host];
    if (existing != null) return existing;
    final future = _doResolve(host).whenComplete(() => _inflight.remove(host));
    _inflight[host] = future;
    return future;
  }

  static Future<List<InternetAddress>?> _doResolve(String host) async {
    var addresses = await _systemLookup(host);
    if (addresses == null || addresses.isEmpty) {
      addresses = await _dohLookup(host);
    }
    final ok = addresses != null && addresses.isNotEmpty;
    if (!ok) {
      failCount++;
      if (kDebugMode) debugPrint('DnsResolver failed: $host');
    }
    _cache[host] = _DnsEntry(
      ok ? addresses! : const <InternetAddress>[],
      DateTime.now().add(ok ? _ttlSuccess : _ttlFailure),
    );
    return ok ? addresses : null;
  }

  static Future<List<InternetAddress>?> _systemLookup(String host) async {
    try {
      // 优先 IPv4：部分网络下 AAAA 通而实际不可达，走 IPv6 反而更慢
      final result = await InternetAddress.lookup(
        host,
        type: InternetAddressType.IPv4,
      ).timeout(_systemTimeout);
      if (result.isNotEmpty) return result;
    } catch (_) {}
    try {
      final result = await InternetAddress.lookup(host).timeout(_systemTimeout);
      final v6 = result
          .where((e) => e.type == InternetAddressType.IPv6)
          .toList(growable: false);
      if (v6.isNotEmpty) return v6;
    } catch (_) {}
    return null;
  }

  static Future<List<InternetAddress>?> _dohLookup(String host) async {
    for (final provider in _dohProviders) {
      final base = Uri.parse(provider);
      final uri = base.replace(
        queryParameters: <String, String>{'name': host, 'type': 'A'},
      );
      final client = HttpClient()
        ..connectionTimeout = _dohTimeout
        // 走直连：本机代理里的解析也走这里，绕开会自锁
        ..findProxy = ((_) => 'DIRECT');
      try {
        final req = await client.getUrl(uri).timeout(_dohTimeout);
        req.headers.set(HttpHeaders.acceptHeader, 'application/dns-json');
        final res = await req.close().timeout(_dohTimeout);
        if (res.statusCode != HttpStatus.ok) continue;
        final body = await res
            .transform(utf8.decoder)
            .join()
            .timeout(_dohTimeout);
        final list = _parseDoh(body);
        if (list.isNotEmpty) {
          dohCount++;
          return list;
        }
      } catch (_) {
      } finally {
        client.close(force: true);
      }
    }
    return null;
  }

  /// 解析 DoH 的 JSON 响应（Cloudflare / Google / AliDNS 同构）。
  static List<InternetAddress> _parseDoh(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is! Map) return const <InternetAddress>[];
      final answer = decoded['Answer'];
      if (answer is! List) return const <InternetAddress>[];
      final out = <InternetAddress>[];
      for (final item in answer) {
        if (item is! Map) continue;
        // type 1 = A，只取 IPv4
        if (item['type'] != 1) continue;
        final data = item['data'];
        if (data is! String) continue;
        final ip = InternetAddress.tryParse(data);
        if (ip != null) out.add(ip);
      }
      return out;
    } catch (_) {
      return const <InternetAddress>[];
    }
  }
}

class _DnsEntry {
  _DnsEntry(this.addresses, this.expireAt);

  final List<InternetAddress> addresses;
  final DateTime expireAt;
}
