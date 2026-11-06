typedef SubtitlePrefetchCid<T> = int? Function(T entry);
typedef SubtitlePrefetchIdentity<T> = String Function(T entry);

/// Selects unique entries after the current playlist item.
///
/// Keeping this policy independent from page-controller models makes the
/// 0-5 setting, end-of-list behavior and duplicate filtering deterministic.
List<T> selectSubtitlePrefetchEntries<T>({
  required List<T> entries,
  required int currentCid,
  required int count,
  required SubtitlePrefetchCid<T> cidOf,
  required SubtitlePrefetchIdentity<T> identityOf,
}) {
  final limit = count.clamp(0, 5).toInt();
  if (limit == 0 || entries.isEmpty) return <T>[];
  final current = entries.indexWhere((entry) => cidOf(entry) == currentCid);
  if (current < 0 || current + 1 >= entries.length) return <T>[];

  final selected = <T>[];
  final seen = <String>{};
  for (final entry in entries.skip(current + 1)) {
    if (selected.length >= limit) break;
    final cid = cidOf(entry);
    if (cid == null || cid == currentCid) continue;
    if (!seen.add(identityOf(entry))) continue;
    selected.add(entry);
  }
  return selected;
}
