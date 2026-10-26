import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:PiliPlus/utils/storage_pref.dart';

/// E2 媒体层多连接代理（对标官方 ijk 播放栈的多连接分片下载）。
///
/// 播放内核默认用一条 TCP 连接顺序拉流，单连接在高延迟线路上很难吃满带宽，
/// 起播和拖动后重新缓冲都会偏慢。这里在 App 内部起一个只监听本机回环的 HTTP
/// 代理：内核照旧发一个普通 GET（带 Range），代理把它拆成 N 段并发向上游要，
/// 再按字节顺序回吐给内核。
///
/// 四条纪律：
/// 1. 默认关闭（Pref.mediaProxyConns 为 0），只有用户显式选了 1/2/4 才走代理；
/// 2. 只监听 127.0.0.1 且每次启动生成随机 token，其它进程既猜不到也进不来；
/// 3. 任何异常（上游报错、分片拿不到、URL 解析不了）都直接 302 回源，让内核自己
///    直连——绝不因为代理出问题导致视频放不出来；
/// 4. 拖动（新的 Range）时立即结束本次请求并强制关掉在飞的上游连接，旧连接不再占带宽。
class MediaProxy {
  MediaProxy._();

  static HttpServer? _server;
  static String? _token;
  static int _port = 0;
  static Future<void>? _starting;

  /// 小于这个长度不值得分片（一次往返就够了）
  static const int _minSplitBytes = 256 * 1024;

  static bool get available => _server != null && _token != null;

  /// 生效的连接数：0/1 视为不分片
  static int get connections {
    final n = Pref.mediaProxyConns;
    if (n <= 1) {
      return 1;
    }
    return n >= 4 ? 4 : 2;
  }

  /// 启动代理（幂等）。失败返回 false，调用方照原样直连即可。
  static Future<bool> ensureStarted() async {
    if (available) {
      return true;
    }
    final pending = _starting;
    if (pending != null) {
      await pending;
      return available;
    }
    final completer = Completer<void>();
    _starting = completer.future;
    try {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _server = server;
      _port = server.port;
      _token = _randomToken();
      server.listen(_handle, onError: (_) {});
    } catch (_) {
      _server = null;
      _token = null;
    } finally {
      completer.complete();
      _starting = null;
    }
    return available;
  }

  static void stop() {
    _server?.close(force: true);
    _server = null;
    _token = null;
    _port = 0;
  }

  static String _randomToken() {
    final r = Random.secure();
    final bytes = Uint8List(16);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = r.nextInt(256);
    }
    return base64Url.encode(bytes);
  }

  /// 把上游媒体地址包装成本机代理地址。关闭、只连一条或包装失败时原样返回。
  static String wrap(String url) {
    if (!available || connections <= 1) {
      return url;
    }
    try {
      final uri = Uri.parse(url);
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return url;
      }
      final b64 = base64Url.encode(utf8.encode(url));
      return 'http://127.0.0.1:$_port/media?t=$_token&u=$b64';
    } catch (_) {
      return url;
    }
  }

  static Future<void> _handle(HttpRequest request) async {
    final resp = request.response;
    // 每个请求独占一个 HttpClient：拖动时强制关掉它，在飞的上游连接一并断掉
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final q = request.uri.queryParameters;
      if (_token == null || q['t'] != _token) {
        resp.statusCode = HttpStatus.forbidden;
        await resp.close();
        return;
      }
      final raw = q['u'];
      if (raw == null || raw.isEmpty) {
        resp.statusCode = HttpStatus.badRequest;
        await resp.close();
        return;
      }
      final upstream = Uri.parse(utf8.decode(base64Url.decode(raw)));
      final (start, end) = _parseRange(
        request.headers.value(HttpHeaders.rangeHeader),
      );

      // 先探一次拿总长度（bytes=0-0 很便宜），顺便确认上游支不支持 Range
      final probe = await _open(client, upstream, 'bytes=0-0');
      final total = probe == null ? null : _totalOf(probe);
      final acceptRanges = probe != null &&
          (probe.headers.value(HttpHeaders.acceptRangesHeader)?.contains(
                'bytes',
              ) ??
              false);
      final contentType =
          probe?.headers.contentType?.toString() ?? 'application/octet-stream';
      await probe?.stream.drain<void>();

      final last = total == null
          ? null
          : (end == null ? total - 1 : min(end, total - 1));
      final length = last == null ? null : last - start + 1;

      if (total == null ||
          !acceptRanges ||
          connections <= 1 ||
          length == null ||
          length <= _minSplitBytes) {
        // 不分片：整体回源（保持内核原本的单连接行为）
        await _pipeSingle(resp, client, upstream, start, end, contentType);
        return;
      }

      final n = connections;
      final int lastByte = last!;
      final chunk = (length / n).ceil();
      final parts = <HttpClientResponse>[];
      for (var i = 0; i < n; i++) {
        final s = start + i * chunk;
        if (s > lastByte) {
          break;
        }
        final e = min(lastByte, s + chunk - 1);
        final r = await _open(client, upstream, 'bytes=$s-$e');
        if (r == null) {
          for (final p in parts) {
            unawaited(p.stream.drain<void>().catchError((_) {}));
          }
          await _redirect(resp, upstream);
          return;
        }
        parts.add(r);
      }

      resp.statusCode = HttpStatus.partialContent;
      resp.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
      resp.headers.set(HttpHeaders.contentTypeHeader, contentType);
      resp.headers.set(
        HttpHeaders.contentRangeHeader,
        'bytes $start-$lastByte/$total',
      );
      resp.headers.contentLength = length;
      for (final p in parts) {
        await resp.addStream(p.stream);
      }
    } catch (_) {
      // 客户端拖动/断开、上游中断：能关就关，什么都不用做
      try {
        await resp.close();
      } catch (_) {}
    } finally {
      client.close(force: true);
    }
  }

  static Future<void> _pipeSingle(
    HttpResponse resp,
    HttpClient client,
    Uri upstream,
    int start,
    int? end,
    String contentType,
  ) async {
    final range = (start > 0 || end != null)
        ? 'bytes=$start-${end == null ? '' : end}'
        : null;
    final res = await _open(client, upstream, range);
    if (res == null) {
      await _redirect(resp, upstream);
      return;
    }
    final status = res.statusCode;
    final cr = res.headers.value(HttpHeaders.contentRangeHeader);
    resp.statusCode = status == HttpStatus.partialContent
        ? HttpStatus.partialContent
        : HttpStatus.ok;
    resp.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
    resp.headers.set(
      HttpHeaders.contentTypeHeader,
      res.headers.contentType?.toString() ?? contentType,
    );
    if (cr != null) {
      resp.headers.set(HttpHeaders.contentRangeHeader, cr);
    }
    final len = res.contentLength;
    if (len >= 0) {
      resp.headers.contentLength = len;
    }
    await resp.addStream(res.stream);
  }

  static Future<void> _redirect(HttpResponse resp, Uri upstream) async {
    resp.statusCode = HttpStatus.found;
    resp.headers.set(HttpHeaders.locationHeader, upstream.toString());
    await resp.close();
  }

  static Future<HttpClientResponse?> _open(
    HttpClient client,
    Uri uri,
    String? range,
  ) async {
    try {
      final req = await client.getUrl(uri);
      if (range != null) {
        req.headers.set(HttpHeaders.rangeHeader, range);
      }
      final res = await req.close();
      if (res.statusCode >= 400) {
        await res.drain<void>();
        return null;
      }
      return res;
    } catch (_) {
      return null;
    }
  }

  static int? _totalOf(HttpClientResponse res) {
    final cr = res.headers.value(HttpHeaders.contentRangeHeader);
    if (cr != null) {
      final m = RegExp(r'/(\d+)\s*$').firstMatch(cr);
      final v = m == null ? null : int.tryParse(m.group(1)!);
      if (v != null && v > 0) {
        return v;
      }
    }
    final len = res.contentLength;
    if (len > 0 && res.statusCode == HttpStatus.ok) {
      return len;
    }
    return null;
  }

  static (int, int?) _parseRange(String? range) {
    if (range == null) {
      return (0, null);
    }
    final m = RegExp(r'bytes=(\d+)-(\d*)').firstMatch(range);
    if (m == null) {
      return (0, null);
    }
    final start = int.tryParse(m.group(1)!) ?? 0;
    final endStr = m.group(2);
    final end = (endStr == null || endStr.isEmpty) ? null : int.tryParse(endStr);
    return (start, end);
  }
}
