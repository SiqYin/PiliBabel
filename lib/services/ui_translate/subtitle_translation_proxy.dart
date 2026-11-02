import 'dart:async';

enum SubtitleTranslationProxyType { http, socks5 }

class SubtitleTranslationProxy {
  const SubtitleTranslationProxy({
    required this.type,
    required this.host,
    required this.port,
    this.username,
    this.password,
  });

  final SubtitleTranslationProxyType type;
  final String host;
  final int port;
  final String? username;
  final String? password;

  String get label =>
      '${type == SubtitleTranslationProxyType.http ? 'HTTP' : 'SOCKS5'} $host:$port';

  static List<SubtitleTranslationProxy> parseMany(
    String raw, {
    SubtitleTranslationProxyType defaultType =
        SubtitleTranslationProxyType.http,
  }) {
    final routes = <SubtitleTranslationProxy>[];
    for (final line in raw.split(RegExp(r'[\r\n,]+'))) {
      final value = line.trim();
      if (value.isEmpty) continue;
      routes.add(parse(value, defaultType: defaultType));
    }
    return routes;
  }

  static SubtitleTranslationProxy parse(
    String value, {
    SubtitleTranslationProxyType defaultType =
        SubtitleTranslationProxyType.http,
  }) {
    var normalized = value.trim();
    var type = defaultType;
    if (normalized.startsWith('http://')) {
      type = SubtitleTranslationProxyType.http;
      normalized = normalized.substring('http://'.length);
    } else if (normalized.startsWith('socks5://')) {
      type = SubtitleTranslationProxyType.socks5;
      normalized = normalized.substring('socks5://'.length);
    }
    final parts = normalized.split(':');
    if (parts.length < 2 ||
        parts.length > 4 ||
        parts.any((part) => part.isEmpty)) {
      throw const FormatException('Proxy must be ip:port:user:pass');
    }
    final port = int.tryParse(parts[1]);
    if (port == null || port < 1 || port > 65535) {
      throw const FormatException('Proxy port must be between 1 and 65535');
    }
    if (parts.length == 3) {
      throw const FormatException(
        'Proxy authentication requires both user and password',
      );
    }
    return SubtitleTranslationProxy(
      type: type,
      host: parts.first,
      port: port,
      username: parts.length == 4 ? parts[2] : null,
      password: parts.length == 4 ? parts[3] : null,
    );
  }
}

/// Limits each configured proxy to six in-flight subtitle requests.
class SubtitleTranslationProxyPool {
  static const workersPerProxy = 6;

  SubtitleTranslationProxyPool(List<SubtitleTranslationProxy> proxies)
    : _slots = [
        for (final proxy in proxies)
          for (var i = 0; i < workersPerProxy; i++) proxy,
      ],
      _proxies = proxies.toSet();

  final List<SubtitleTranslationProxy> _slots;
  final Set<SubtitleTranslationProxy> _proxies;
  final List<Completer<SubtitleTranslationProxy>> _waiters = [];
  final Set<SubtitleTranslationProxy> _unavailable = {};

  bool get enabled => _proxies.any((proxy) => !_unavailable.contains(proxy));
  int get workerCount => _slots.length;

  Future<T> run<T>(
    Future<T> Function(SubtitleTranslationProxy proxy) action,
  ) async {
    final proxy = await _acquire();
    try {
      return await action(proxy);
    } finally {
      _release(proxy);
    }
  }

  void markUnavailable(SubtitleTranslationProxy proxy) {
    _unavailable.add(proxy);
    if (_proxies.every(_unavailable.contains)) {
      for (final waiter in _waiters) {
        if (!waiter.isCompleted) {
          waiter.completeError(
            StateError('All subtitle translation proxies are unavailable'),
          );
        }
      }
      _waiters.clear();
    }
  }

  Future<SubtitleTranslationProxy> _acquire() {
    if (_proxies.every(_unavailable.contains)) {
      return Future.error(
        StateError('All subtitle translation proxies are unavailable'),
      );
    }
    final index = _slots.indexWhere((proxy) => !_unavailable.contains(proxy));
    if (index >= 0) return Future.value(_slots.removeAt(index));
    if (_slots.isNotEmpty) {
      throw StateError('All subtitle translation proxies are unavailable');
    }
    final waiter = Completer<SubtitleTranslationProxy>();
    _waiters.add(waiter);
    return waiter.future;
  }

  void _release(SubtitleTranslationProxy proxy) {
    if (_unavailable.contains(proxy)) return;
    while (_waiters.isNotEmpty) {
      final waiter = _waiters.removeAt(0);
      if (!waiter.isCompleted) {
        waiter.complete(proxy);
        return;
      }
    }
    _slots.add(proxy);
  }
}
