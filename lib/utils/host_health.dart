import 'dart:async';
import 'dart:collection';

import 'package:PiliPlus/http/constants.dart';

/// 主机健康度：内存滚动窗口记录每个主机的成败，用来决定主备顺序与冷却。
///
/// 对齐思路：官方把多主机可用性与失败切换放在自研网络引擎里，业务侧只看到
/// 「接口总是能用」。这里把同样的职责放在客户端——主机清单固定，顺序按实测
/// 健康度动态调整，冷却期内优先走备选主机。
class HostHealth {
  HostHealth._();

  static final HostHealth instance = HostHealth._();

  /// 每个主机保留最近多少次结果
  static const int window = 20;

  /// 样本不足这个数时按「未知」处理（中性分），避免一两次抖动就把主备顺序翻过来
  static const int minSamples = 3;

  /// 未知主机的分数，正好落在「全失败」与「全成功」之间
  static const double unknownScore = 0.5;

  /// 风控（412）后的冷却时长：冷却期内不把该主机当首选
  static const Duration riskCooldown = Duration(minutes: 2);

  final Map<String, Queue<bool>> _samples = <String, Queue<bool>>{};
  final Map<String, DateTime> _riskUntil = <String, DateTime>{};

  void recordSuccess(String host) => _record(host, true);

  void recordFailure(String host) => _record(host, false);

  void _record(String host, bool ok) {
    if (host.isEmpty) return;
    final q = _samples.putIfAbsent(host, Queue<bool>.new);
    q.addLast(ok);
    while (q.length > window) {
      q.removeFirst();
    }
    if (ok) _riskUntil.remove(host);
  }

  /// 撞上风控：官方 APP 的做法是重新激活设备指纹再重试，这里额外给主机加冷却，
  /// 冷却期内优先走备选主机，避免反复撞同一台。
  void recordRiskControl(String host) {
    if (host.isEmpty) return;
    _riskUntil[host] = DateTime.now().add(riskCooldown);
    recordFailure(host);
  }

  bool isCoolingDown(String host) {
    final until = _riskUntil[host];
    if (until == null) return false;
    if (until.isAfter(DateTime.now())) return true;
    _riskUntil.remove(host);
    return false;
  }

  int samples(String host) => _samples[host]?.length ?? 0;

  double? successRate(String host) {
    final q = _samples[host];
    if (q == null || q.isEmpty) return null;
    var ok = 0;
    for (final v in q) {
      if (v) ok++;
    }
    return ok / q.length;
  }

  double _score(String host) {
    if (isCoolingDown(host)) return -1;
    final rate = successRate(host);
    if (rate == null || samples(host) < minSamples) return unknownScore;
    return rate;
  }

  /// 按健康度给候选主机排序：冷却中的排最后，其余按成功率降序；
  /// 分数相同则保持传入顺序（也就是配置顺序）。
  List<String> ordered(List<String> hosts) {
    if (hosts.length < 2) return List<String>.of(hosts);
    final indexed = <(int, String)>[
      for (var i = 0; i < hosts.length; i++) (i, hosts[i]),
    ];
    indexed.sort((a, b) {
      final byScore = _score(b.$2).compareTo(_score(a.$2));
      return byScore != 0 ? byScore : a.$1.compareTo(b.$1);
    });
    return <String>[for (final e in indexed) e.$2];
  }

  String primaryOf(List<String> hosts) => ordered(hosts).first;

  /// 换主机用：取排序后第一个不同于当前的主机；没有别的候选就返回 null。
  String? nextOf(List<String> hosts, String current) {
    for (final host in ordered(hosts)) {
      if (host != current) return host;
    }
    return null;
  }

  /// 换网时清空统计：旧网络下的成绩对新网络没有参考价值。
  void reset() {
    _samples.clear();
    _riskUntil.clear();
  }

  String stats() {
    final sb = StringBuffer('HostHealth');
    for (final host in _samples.keys) {
      final rate = successRate(host);
      sb.write(
        ' $host=${rate == null ? '-' : (rate * 100).toStringAsFixed(0)}%'
        '(${samples(host)})${isCoolingDown(host) ? '冷却' : ''}',
      );
    }
    return sb.toString();
  }
}

/// 单主机并发闸门：同一主机的并发请求超过上限就排队，避免一批请求同时挤在
/// 一条链路上把带宽抢光、反而拖慢首帧。
///
/// 只对普通请求生效；流式响应（下载、媒体）会长时间占用连接，不参与排队。
class HostLimiter {
  HostLimiter._();

  static final HostLimiter instance = HostLimiter._();

  /// 排队等不到空位时的兜底放行时间：宁可超出上限也不能把请求卡死在这里。
  static const Duration waitTimeout = Duration(seconds: 20);

  final Map<String, int> _running = <String, int>{};
  final Map<String, Queue<Completer<void>>> _waiting =
      <String, Queue<Completer<void>>>{};

  int running(String host) => _running[host] ?? 0;

  /// 返回 true 表示占到了名额，完成后必须 release；false 表示直接放行、无需归还。
  Future<bool> acquire(String host, int limit) async {
    if (host.isEmpty || limit <= 0) return false;
    final current = _running[host] ?? 0;
    if (current < limit) {
      _running[host] = current + 1;
      return true;
    }
    final completer = Completer<void>();
    final q = _waiting.putIfAbsent(host, Queue<Completer<void>>.new);
    q.addLast(completer);
    try {
      await completer.future.timeout(waitTimeout);
      // 被 release 让位：槽位已经算在我头上
      return true;
    } on TimeoutException {
      if (q.remove(completer)) {
        // 还在队列里：兜底放行，且不再额外占名额（否则名额会越滚越多）
        return false;
      }
      // 刚被让位：槽位归我
      return true;
    }
  }

  void release(String host) {
    if (host.isEmpty) return;
    final q = _waiting[host];
    if (q != null && q.isNotEmpty) {
      // 直接把槽位让给排队最久的那个，运行数不变
      q.removeFirst().complete();
      return;
    }
    final current = _running[host] ?? 0;
    if (current <= 1) {
      _running.remove(host);
      _waiting.remove(host);
    } else {
      _running[host] = current - 1;
    }
  }

  void reset() {
    for (final q in _waiting.values) {
      for (final c in q) {
        if (!c.isCompleted) c.complete();
      }
    }
    _waiting.clear();
    _running.clear();
  }

  String stats() {
    final sb = StringBuffer('HostLimiter');
    for (final e in _running.entries) {
      sb.write(' ${e.key}=${e.value}');
    }
    return sb.toString();
  }
}

/// 把主机清单与健康度凑一起的小工具：gRPC 主备顺序统一从这里取。
abstract final class HostPicker {
  /// gRPC 请求的首选主机：按实测健康度在 grpc.biliapi.net 与 app.bilibili.com
  /// 之间挑，默认（都没数据）就是官方那套顺序。
  static String grpcPrimary() =>
      HostHealth.instance.primaryOf(HttpString.grpcHosts);

  /// 该主机出问题时的下一个候选（gRPC 主机组内）。
  static String? grpcNext(String current) =>
      HostHealth.instance.nextOf(HttpString.grpcHosts, current);
}
