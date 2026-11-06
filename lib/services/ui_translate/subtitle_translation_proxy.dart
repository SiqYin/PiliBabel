import 'dart:async';
import 'dart:collection';

enum SubtitleTranslationProxyType { http, socks5 }

enum SubtitleTranslationPriority {
  playback(0),
  userRequested(10),
  background(20),
  playlistPrefetch(30);

  const SubtitleTranslationPriority(this.rank);

  final int rank;
}

class SubtitleTranslationPriorityHandle {
  SubtitleTranslationPriorityHandle(SubtitleTranslationPriority priority)
    : _priority = priority;

  SubtitleTranslationPriority _priority;

  SubtitleTranslationPriority get value => _priority;

  void promote(SubtitleTranslationPriority priority) {
    if (priority.rank < _priority.rank) _priority = priority;
  }
}

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

/// Schedules direct-device and configured proxy translation routes together.
///
/// A null slot represents a request made through the device's own network.
/// Each configured proxy adds six independent slots without replacing those
/// direct slots.
class SubtitleTranslationProxyPool {
  static const workersPerProxy = 6;
  static const _proxyCooldown = Duration(seconds: 60);
  static final LinkedHashMap<String, SubtitleTranslationProxyPool>
  _sharedPools = LinkedHashMap();

  SubtitleTranslationProxyPool(
    List<SubtitleTranslationProxy> proxies, {
    required int directWorkers,
    Duration routeAcquireTimeout = const Duration(seconds: 60),
  }) : this._(
         proxies,
         directWorkers: directWorkers,
         routeAcquireTimeout: routeAcquireTimeout,
       );

  factory SubtitleTranslationProxyPool.shared(
    List<SubtitleTranslationProxy> proxies, {
    required int directWorkers,
    Duration routeAcquireTimeout = const Duration(seconds: 60),
  }) {
    final key = _configurationKey(proxies, directWorkers, routeAcquireTimeout);
    final existing = _sharedPools.remove(key);
    if (existing != null) {
      _sharedPools[key] = existing;
      return existing;
    }
    final pool = SubtitleTranslationProxyPool._(
      proxies,
      directWorkers: directWorkers,
      routeAcquireTimeout: routeAcquireTimeout,
    );
    _sharedPools[key] = pool;
    return pool;
  }

  SubtitleTranslationProxyPool._(
    List<SubtitleTranslationProxy> proxies, {
    required int directWorkers,
    required this.routeAcquireTimeout,
  }) : assert(directWorkers >= 1),
       _capacity = directWorkers + proxies.length * workersPerProxy,
       _slots = [
         for (var i = 0; i < directWorkers; i++) null,
         // A new proxy starts with one probe slot. The remaining slots only
         // become available after its first successful translation request.
         for (final proxy in proxies) proxy,
       ],
       _proxies = proxies.toSet(),
       directWorkers = directWorkers;

  final int directWorkers;
  final Duration routeAcquireTimeout;
  final int _capacity;
  final List<SubtitleTranslationProxy?> _slots;
  final Set<SubtitleTranslationProxy> _proxies;
  final Set<SubtitleTranslationProxy> _activatedProxies = {};
  final List<_ProxyWaiter> _waiters = [];
  final Map<SubtitleTranslationProxy, DateTime> _unavailableUntil = {};
  int _nextWaiterSequence = 0;
  Timer? _cooldownTimer;

  bool get enabled => _proxies.any(_isRouteAvailable);
  int get workerCount => _capacity;
  int get waitingCount => _waiters.length;

  Future<T> run<T>(
    Future<T> Function(SubtitleTranslationProxy? proxy) action, {
    SubtitleTranslationPriority priority =
        SubtitleTranslationPriority.background,
    SubtitleTranslationPriorityHandle? priorityHandle,
  }) async {
    final route = await _acquire(priority, priorityHandle);
    var succeeded = false;
    try {
      final result = await action(route);
      succeeded = true;
      return result;
    } finally {
      if (succeeded && route != null) _activateProxy(route);
      _release(route);
    }
  }

  static bool shouldCooldownStatus(int? statusCode) =>
      statusCode == null ||
      statusCode == 401 ||
      statusCode == 403 ||
      statusCode == 407 ||
      statusCode == 429 ||
      statusCode >= 500;

  void markUnavailable(
    SubtitleTranslationProxy proxy, {
    Duration cooldown = _proxyCooldown,
  }) {
    _unavailableUntil[proxy] = DateTime.now().add(cooldown);
    _scheduleCooldownWake();
  }

  void _activateProxy(SubtitleTranslationProxy proxy) {
    if (!_activatedProxies.add(proxy)) return;
    for (var i = 1; i < workersPerProxy; i++) {
      _slots.add(proxy);
    }
    _drainWaiters();
  }

  Future<SubtitleTranslationProxy?> _acquire(
    SubtitleTranslationPriority priority,
    SubtitleTranslationPriorityHandle? priorityHandle,
  ) async {
    final route = _takeAvailableRoute();
    if (route.$1) return route.$2;
    final waiter = _ProxyWaiter(
      priority: priority,
      priorityHandle: priorityHandle,
      sequence: _nextWaiterSequence++,
    );
    _waiters.add(waiter);
    try {
      return await waiter.completer.future.timeout(routeAcquireTimeout);
    } on TimeoutException {
      // Future.timeout does not cancel the original future. Remove the waiter
      // so an abandoned request cannot later steal a released route.
      _waiters.remove(waiter);
      rethrow;
    }
  }

  void _release(SubtitleTranslationProxy? route) {
    _slots.add(route);
    _drainWaiters();
  }

  void _drainWaiters() {
    while (_waiters.isNotEmpty) {
      final route = _takeAvailableRoute();
      if (!route.$1) return;
      var bestIndex = 0;
      for (var i = 1; i < _waiters.length; i++) {
        final current = _waiters[i];
        final best = _waiters[bestIndex];
        if (current.priority.rank < best.priority.rank ||
            (current.priority == best.priority &&
                current.sequence < best.sequence)) {
          bestIndex = i;
        }
      }
      final waiter = _waiters.removeAt(bestIndex);
      if (!waiter.completer.isCompleted) waiter.completer.complete(route.$2);
    }
  }

  (bool, SubtitleTranslationProxy?) _takeAvailableRoute() {
    // Prefer working proxies while keeping all direct-device slots active.
    var index = _slots.indexWhere(
      (route) => route != null && _isRouteAvailable(route),
    );
    index = index >= 0 ? index : _slots.indexWhere((route) => route == null);
    return index < 0 ? (false, null) : (true, _slots.removeAt(index));
  }

  bool _isRouteAvailable(SubtitleTranslationProxy proxy) {
    final until = _unavailableUntil[proxy];
    if (until == null) return true;
    if (DateTime.now().isBefore(until)) return false;
    _unavailableUntil.remove(proxy);
    return true;
  }

  void _scheduleCooldownWake() {
    _cooldownTimer?.cancel();
    if (_unavailableUntil.isEmpty) return;
    final now = DateTime.now();
    final next = _unavailableUntil.values.reduce(
      (a, b) => a.isBefore(b) ? a : b,
    );
    final delay = next.difference(now);
    _cooldownTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
      _cooldownTimer = null;
      _unavailableUntil.removeWhere(
        (_, until) => !DateTime.now().isBefore(until),
      );
      _drainWaiters();
      _scheduleCooldownWake();
    });
  }

  static String _configurationKey(
    List<SubtitleTranslationProxy> proxies,
    int directWorkers,
    Duration routeAcquireTimeout,
  ) =>
      '$directWorkers|${routeAcquireTimeout.inMilliseconds}|${proxies.map((proxy) => [proxy.type.index, proxy.host, proxy.port, proxy.username ?? '', proxy.password ?? ''].join(':')).join('|')}';
}

class _ProxyWaiter {
  _ProxyWaiter({
    required SubtitleTranslationPriority priority,
    required this.priorityHandle,
    required this.sequence,
  }) : _fallbackPriority = priority;

  final SubtitleTranslationPriority _fallbackPriority;
  final SubtitleTranslationPriorityHandle? priorityHandle;
  final int sequence;
  final Completer<SubtitleTranslationProxy?> completer = Completer();

  SubtitleTranslationPriority get priority =>
      priorityHandle?.value ?? _fallbackPriority;
}
