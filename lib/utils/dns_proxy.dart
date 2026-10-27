import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:PiliPlus/utils/dns_resolver.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

/// 本机解析代理：HTTPDNS 在 Flutter 侧唯一能真正落地的形态。
///
/// 官方把解析与调度放在自研网络引擎 Ignet 与自家 HTTPDNS 里，客户端侧无从照搬；
/// 而 Flutter 这边没有可注入的 DNS 钩子——HTTP/1.1 的 dart:io HttpClient 能用
/// connectionFactory，但默认开启的 HTTP/2 走 dio_http2_adapter 的 ConnectionManager，
/// socket 由它自己建，钩不到。所以这里换一条等价路线：客户端用 findProxy 把请求
/// 交给 127.0.0.1，由代理按 DnsResolver 的结果建上游连接。
///
/// TLS 端到端不变：代理只做字节转发，SNI / Host / 直链签名都不受影响。
///
/// 与系统代理的关系：用户自己开了系统代理时本代理不启用（proxySpec 返回 null），
/// 交回原有的系统代理链路，避免二次转发把用户自己的代理叠掉。
class DnsProxy {
  DnsProxy._();

  static final DnsProxy instance = DnsProxy._();

  static const Duration _connectTimeout = Duration(seconds: 10);
  static const Duration _idleTimeout = Duration(seconds: 90);
  static const int _maxHeaderBytes = 32 * 1024;
  static const int _flushThreshold = 64 * 1024;

  ServerSocket? _server;

  bool get available => _server != null;

  int get port => _server?.port ?? 0;

  static int tunnelCount = 0;
  static int plainCount = 0;
  static int failCount = 0;

  /// findProxy 用的规范串；未启用（或用户开了系统代理）时返回 null。
  static String? get proxySpec {
    if (Pref.enableSystemProxy) return null;
    final p = instance;
    return p.available ? 'PROXY 127.0.0.1:${p.port}' : null;
  }

  static String stats() =>
      'tunnel=$tunnelCount plain=$plainCount fail=$failCount';

  static void logStats() {
    if (kDebugMode) debugPrint('DnsProxy ${stats()}');
  }

  Future<void> start() async {
    if (_server != null) return;
    try {
      final server = await ServerSocket.bind(
        InternetAddress.loopbackIPv4,
        0,
        shared: false,
      );
      _server = server;
      server.listen(
        _handle,
        onError: (Object e) {
          if (kDebugMode) debugPrint('DnsProxy listen error: $e');
        },
      );
      if (kDebugMode) debugPrint('DnsProxy listening 127.0.0.1:${server.port}');
    } catch (e) {
      if (kDebugMode) debugPrint('DnsProxy bind failed: $e');
    }
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    try {
      await server?.close();
    } catch (_) {}
  }

  Future<void> restart() async {
    await stop();
    await start();
  }

  void _handle(Socket client) {
    try {
      client.setOption(SocketOption.tcpNoDelay, true);
    } catch (_) {}

    final buffer = BytesBuilder(copy: false);
    var headerParsed = false;
    Socket? upstream;
    Timer? idle;

    /// 头部已经解析完、但上游 socket 还没就绪这段时间里收到的字节。
    ///
    /// 不能直接丢：CONNECT 分支里 `_dispatch` 会先回 200 再返回上游 socket，
    /// 客户端一看到 200 就立刻发 TLS ClientHello，而这些字节可能比
    /// `await _dispatch(...)` 的返回更早到达（`client.listen` 的回调是 async，
    /// 事件循环不会等它）。以前这里 `if (up == null) return;` 直接丢包，
    /// 表现就是经本机代理的 HTTPS 请求偶发握手失败——GitHub 更新检查正好走
    /// 这条链路（HTTP/2 通道由 ConnectionManager 统一指向本代理）。
    /// 现在先攒起来，等上游就绪后按序补发。
    final pending = <List<int>>[];

    void touch() {
      idle?.cancel();
      idle = Timer(_idleTimeout, () {
        client.destroy();
        upstream?.destroy();
      });
    }

    void closeAll() {
      idle?.cancel();
      try {
        client.destroy();
      } catch (_) {}
      try {
        upstream?.destroy();
      } catch (_) {}
    }

    touch();

    client.listen(
      (chunk) async {
        touch();
        if (headerParsed) {
          final up = upstream;
          if (up == null) {
            // 上游还没就绪：先攒着，稍后补发（见 pending 的注释）
            pending.add(chunk);
            return;
          }
          up.add(chunk);
          return;
        }
        buffer.add(chunk);
        final data = buffer.toBytes();
        final end = _headerEnd(data);
        if (end < 0) {
          if (data.length > _maxHeaderBytes) {
            failCount++;
            _reply(client, 'HTTP/1.1 431 Request Header Fields Too Large');
            closeAll();
          }
          return;
        }
        headerParsed = true;
        final head = latin1.decode(data.sublist(0, end));
        final rest = data.sublist(end + 4);
        try {
          upstream = await _dispatch(client, head);
        } catch (e) {
          failCount++;
          if (kDebugMode) debugPrint('DnsProxy dispatch failed: $e');
          _reply(client, 'HTTP/1.1 502 Bad Gateway');
          closeAll();
          return;
        }
        final up = upstream;
        if (up == null) {
          closeAll();
          return;
        }
        unawaited(
          _pump(
            up,
            client,
            closeAll,
            touch,
            onError: () {
              failCount++;
              closeAll();
            },
          ),
        );
        // 补发顺序必须严格按到达先后，否则 TLS 握手会错位：
        // 先发与头部同一批到达的 rest，再发上游就绪前攒下的 pending。
        if (rest.isNotEmpty) {
          up.add(rest);
        }
        for (final queued in pending) {
          up.add(queued);
        }
        pending.clear();
      },
      onError: (Object _) => closeAll(),
      onDone: closeAll,
      cancelOnError: true,
    );
  }

  /// 单方向搬运。await for 自带背压：上游不吐完就不读下一块，累积到阈值再 flush，
  /// 避免大响应把内存撑爆；socket 被销毁时流自然结束，循环随之退出。
  Future<void> _pump(
    Stream<List<int>> from,
    IOSink to,
    void Function() onClose,
    void Function() touch, {
    required void Function() onError,
  }) async {
    var pending = 0;
    try {
      await for (final chunk in from) {
        touch();
        to.add(chunk);
        pending += chunk.length;
        if (pending >= _flushThreshold) {
          await to.flush();
          pending = 0;
        }
      }
    } catch (_) {
      onError();
      return;
    }
    onClose();
  }

  /// 处理一条代理请求。CONNECT 走隧道；绝对 URI 形式改写请求行后转发。
  Future<Socket?> _dispatch(Socket client, String head) async {
    final lines = head.split('\r\n');
    if (lines.isEmpty) {
      _reply(client, 'HTTP/1.1 400 Bad Request');
      return null;
    }
    final first = lines.first.split(' ');
    if (first.length < 3) {
      _reply(client, 'HTTP/1.1 400 Bad Request');
      return null;
    }
    final method = first[0].toUpperCase();
    final target = first[1];

    if (method == 'CONNECT') {
      final hostPort = _splitHostPort(target, 443);
      if (hostPort == null) {
        _reply(client, 'HTTP/1.1 400 Bad Request');
        return null;
      }
      final up = await _connect(hostPort.$1, hostPort.$2);
      client.add(latin1.encode('HTTP/1.1 200 Connection Established\r\n\r\n'));
      await client.flush();
      tunnelCount++;
      return up;
    }

    final uri = Uri.tryParse(target);
    if (uri == null || uri.host.isEmpty) {
      _reply(client, 'HTTP/1.1 400 Bad Request');
      return null;
    }
    final port = uri.hasPort ? uri.port : 80;
    final up = await _connect(uri.host, port);
    final path = uri.path.isEmpty ? '/' : uri.path;
    final query = uri.hasQuery ? '?${uri.query}' : '';
    final rewritten = <String>[
      '$method $path$query ${first[2]}',
      ...lines.skip(1),
    ].join('\r\n');
    up.add(latin1.encode('$rewritten\r\n\r\n'));
    await up.flush();
    plainCount++;
    return up;
  }

  /// 建上游连接：先自解析，解析层全灭时把主机名交回系统解析。
  Future<Socket> _connect(String host, int port) async {
    final ip = InternetAddress.tryParse(host) ??
        (await DnsResolver.lookup(host))?.first;
    if (ip != null) {
      return Socket.connect(ip, port, timeout: _connectTimeout);
    }
    return Socket.connect(host, port, timeout: _connectTimeout);
  }

  void _reply(Socket client, String status) {
    try {
      client.add(latin1.encode('$status\r\nConnection: close\r\n\r\n'));
      unawaited(client.flush().catchError((Object _) {}));
    } catch (_) {
      client.destroy();
    }
  }

  static int _headerEnd(List<int> data) {
    for (var i = 0; i + 3 < data.length; i++) {
      if (data[i] == 13 &&
          data[i + 1] == 10 &&
          data[i + 2] == 13 &&
          data[i + 3] == 10) {
        return i;
      }
    }
    return -1;
  }

  static (String, int)? _splitHostPort(String target, int defaultPort) {
    if (target.startsWith('[')) {
      final idx = target.indexOf(']');
      if (idx < 0) return null;
      final host = target.substring(1, idx);
      final rest = target.substring(idx + 1);
      if (rest.startsWith(':')) {
        final port = int.tryParse(rest.substring(1));
        return port == null ? null : (host, port);
      }
      return (host, defaultPort);
    }
    final idx = target.lastIndexOf(':');
    if (idx < 0) return (target, defaultPort);
    final port = int.tryParse(target.substring(idx + 1));
    if (port == null) return (target, defaultPort);
    return (target.substring(0, idx), port);
  }
}
