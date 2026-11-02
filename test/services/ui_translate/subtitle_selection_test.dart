import 'package:PiliPlus/models_new/video/video_play_info/subtitle.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_selection.dart';
import 'package:flutter_test/flutter_test.dart';

Subtitle _track(String language, {bool ai = false}) =>
    Subtitle(lan: language, isAi: ai);

void main() {
  test('prefers target AI over target regular and Chinese', () {
    final tracks = [
      _track('zh-CN'),
      _track('vi'),
      _track('ai-vi', ai: true),
    ];
    final selected = SubtitleSelectionPolicy.choose(
      tracks,
      'vi-VN',
      canTranslate: true,
    );
    expect(selected.index, 3);
    expect(selected.translate, false);
  });

  test('prefers a regular target over generating a translation', () {
    final selected = SubtitleSelectionPolicy.choose(
      [_track('ai-zh', ai: true), _track('en-US')],
      'en',
      canTranslate: false,
    );
    expect(selected.index, 2);
    expect(selected.translate, false);
  });

  test('uses regular Chinese as source before AI Chinese', () {
    final tracks = [_track('ai-zh', ai: true), _track('zh-CN')];
    final selected = SubtitleSelectionPolicy.choose(
      tracks,
      'vi',
      canTranslate: true,
    );
    expect(selected.index, 2);
    expect(selected.translate, true);
    expect(
      SubtitleSelectionPolicy.choose(
        tracks,
        'vi',
        canTranslate: false,
      ).translate,
      false,
    );
  });

  test('accepts AI Chinese source and preserves Chinese fallback', () {
    final selected = SubtitleSelectionPolicy.choose(
      [_track('ai-zh', ai: true)],
      'vi',
      canTranslate: true,
    );
    expect(selected.index, 1);
    expect(selected.translate, true);
    expect(
      SubtitleSelectionPolicy.choose([], 'vi', canTranslate: true).index,
      0,
    );
  });

  test('does not mistake a different Chinese script for target language', () {
    final selected = SubtitleSelectionPolicy.choose(
      [_track('zh-CN'), _track('zh-Hant')],
      'zh-Hant',
      canTranslate: true,
    );
    expect(selected.index, 2);
    expect(selected.translate, false);
    final ambiguous = SubtitleSelectionPolicy.choose(
      [_track('ai-zh', ai: true), _track('zh-CN')],
      'zh-Hant',
      canTranslate: true,
    );
    expect(ambiguous.index, 2);
    expect(ambiguous.translate, true);
  });
}
