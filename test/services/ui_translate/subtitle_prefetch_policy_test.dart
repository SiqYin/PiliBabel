import 'package:PiliPlus/services/ui_translate/subtitle_prefetch_policy.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Entry = ({String video, int? cid});

List<_Entry> _select(List<_Entry> entries, int count, {int currentCid = 1}) =>
    selectSubtitlePrefetchEntries(
      entries: entries,
      currentCid: currentCid,
      count: count,
      cidOf: (entry) => entry.cid,
      identityOf: (entry) => '${entry.video}/${entry.cid}',
    );

void main() {
  const List<_Entry> entries = [
    (video: 'BV1', cid: 1),
    (video: 'BV1', cid: 2),
    (video: 'BV1', cid: 3),
    (video: 'BV1', cid: 4),
    (video: 'BV1', cid: 5),
    (video: 'BV1', cid: 6),
    (video: 'BV1', cid: 7),
  ];

  test('supports disabled, default-one and maximum-five prefetch', () {
    expect(_select(entries, 0), isEmpty);
    expect(_select(entries, 1).map((entry) => entry.cid), [2]);
    expect(_select(entries, 5).map((entry) => entry.cid), [2, 3, 4, 5, 6]);
    expect(_select(entries, 99), hasLength(5));
  });

  test('stops at playlist end and skips duplicate or invalid entries', () {
    const List<_Entry> noisy = [
      (video: 'BV1', cid: 1),
      (video: 'BV1', cid: 2),
      (video: 'BV1', cid: 2),
      (video: 'BV1', cid: null),
      (video: 'BV2', cid: 2),
      (video: 'BV1', cid: 3),
    ];
    expect(
      _select(noisy, 5).map((entry) => '${entry.video}/${entry.cid}'),
      ['BV1/2', 'BV2/2', 'BV1/3'],
    );
    expect(_select(entries, 5, currentCid: 7), isEmpty);
    expect(_select(entries, 5, currentCid: 99), isEmpty);
  });
}
