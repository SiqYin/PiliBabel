import 'package:PiliPlus/models_new/video/video_play_info/subtitle.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_source_resolver.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';
import 'package:flutter_test/flutter_test.dart';

Subtitle _track(String lan, {bool ai = false}) =>
    Subtitle(lan: lan, lanDoc: lan, isAi: ai);

List<SubtitleCue> _cues(int count, {bool broken = false}) => List.generate(
  count,
  (index) => SubtitleCue(
    broken ? '00:00:00.000' : '00:00:${index.toString().padLeft(2, '0')}.000',
    broken
        ? '00:00:01.000'
        : '00:00:${(index + 1).toString().padLeft(2, '0')}.000',
    '句$index',
  ),
);

void main() {
  test('prefers native target AI before native regular', () async {
    final regular = _track('vi');
    final ai = _track('ai-vi', ai: true);
    final result = await SubtitleSourceResolver.resolve(
      tracks: [regular, ai, _track('zh-CN')],
      targetLanguage: 'vi',
      loadCues: (_) async => _cues(1),
    );

    expect(result?.kind, SubtitleSourceKind.nativeTarget);
    expect(result?.track, same(ai));
  });

  test('chooses the safe Chinese source with more cues', () async {
    final ai = _track('ai-zh', ai: true);
    final regular = _track('zh-CN');
    final result = await SubtitleSourceResolver.resolve(
      tracks: [ai, regular],
      targetLanguage: 'vi',
      forceChineseSource: true,
      loadCues: (track) async => track == ai ? _cues(2) : _cues(4),
    );

    expect(result?.track, same(regular));
    expect(result?.cues, hasLength(4));
  });

  test('uses AI as tie breaker and rejects malformed timelines', () async {
    final broken = _track('zh-CN');
    final ai = _track('ai-zh', ai: true);
    final regular = _track('zh-Hans');
    final result = await SubtitleSourceResolver.resolve(
      tracks: [broken, regular, ai],
      targetLanguage: 'vi',
      forceChineseSource: true,
      loadCues: (track) async =>
          track == broken ? _cues(4, broken: true) : _cues(2),
    );

    expect(result?.track, same(ai));
  });

  test('falls back when a candidate fails to load', () async {
    final unavailable = _track('ai-zh', ai: true);
    final regular = _track('zh-CN');
    final result = await SubtitleSourceResolver.resolve(
      tracks: [unavailable, regular],
      targetLanguage: 'vi',
      forceChineseSource: true,
      loadCues: (track) async {
        if (track == unavailable) throw StateError('offline');
        return _cues(1);
      },
    );

    expect(result?.track, same(regular));
  });
}
