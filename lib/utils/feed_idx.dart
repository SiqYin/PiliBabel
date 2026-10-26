/// B4.1 首页 feed 的 idx 语义对齐官方 App。
///
/// 官方 App 的推荐流在「加载更多」时，idx 传的是上一条返回里的 idx，
/// 而不是页码。这里记住服务端最后给出的 idx，下次请求优先用它；
/// 服务端没有返回 idx（或返回不可用值）时回退到原来的页码语义，
/// 也就是行为与改动前完全一致，不会因为拿不到 idx 而把首页流打乱。
abstract final class FeedIdx {
  static int? _last;

  static int? get last => _last;

  /// 记下服务端最后一条的 idx；解析不出来就保持原值。
  static void record(Object? value) {
    final parsed = _parse(value);
    if (parsed != null && parsed > 0) {
      _last = parsed;
    }
  }

  /// 请求用的 idx：有服务端 idx 就用它，否则用调用方给的页码。
  static int pick(int freshIdx) => _last ?? freshIdx;

  /// 下拉刷新时清掉：刷新后应该从页码 0 重新开始。
  static void clear() => _last = null;

  static int? _parse(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
