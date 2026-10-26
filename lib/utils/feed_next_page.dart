import 'dart:async';

/// B3.1 二屏预取：首屏到手之后，在后台把第二屏的接口数据取回来，
/// 用户滚到第二屏时直接渲染，不用再等一次接口往返。
///
/// B3.2 去重：每次下拉刷新都会推进 [generation]，在飞的旧预取回来时代次已经变了，
/// 于是直接被丢弃——不会出现「刷新后的新数据被旧预取顶掉」。
///
/// 只在首屏（page 0）成功之后触发一次，且只缓存一屏，避免预取变成额外的流量负担。
abstract final class FeedNextPage {
  static const Duration _ttl = Duration(seconds: 90);

  static int _generation = 0;
  static int? _freshIdx;
  static Object? _data;
  static DateTime? _at;

  static int get generation => _generation;

  /// 下拉刷新时调用：推进代次，旧预取立即失效。
  static int bumpGeneration() {
    _generation++;
    clear();
    return _generation;
  }

  /// 写入预取结果。代次不符（说明这中间刷新过）时直接丢掉。
  static void put({
    required int freshIdx,
    required Object data,
    required int generation,
  }) {
    if (generation != _generation) return;
    _freshIdx = freshIdx;
    _data = data;
    _at = DateTime.now();
  }

  /// 取用预取结果：页码不符、已过期、或没有预取都返回 null（调用方回退正常请求）。
  /// 取到即消费掉，避免同一份数据被重复使用。
  static Object? take(int freshIdx) {
    final data = _data;
    final at = _at;
    if (data == null || at == null || _freshIdx != freshIdx) return null;
    if (at.add(_ttl).isBefore(DateTime.now())) {
      clear();
      return null;
    }
    clear();
    return data;
  }

  static void clear() {
    _freshIdx = null;
    _data = null;
    _at = null;
  }
}
