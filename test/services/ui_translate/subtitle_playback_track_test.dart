import 'package:PiliPlus/models_new/video/video_play_info/subtitle.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_playback_track.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gives Bilibili source tracks stable Vietnamese labels', () {
    final vietnamese = SubtitlePlaybackTrack.bilibili(
      subtitle: Subtitle(lan: 'vi', lanDoc: 'Vietnamese', isAi: true),
      sourceIndex: 2,
      cid: 42,
      targetLanguage: 'vi',
    );
    final chinese = SubtitlePlaybackTrack.bilibili(
      subtitle: Subtitle(lan: 'ai-zh', lanDoc: '中文', isAi: true),
      sourceIndex: 0,
      cid: 42,
      targetLanguage: 'vi',
    );

    expect(vietnamese.label, 'Tiếng Việt (Bilibili AI)');
    expect(chinese.label, 'Tiếng Trung (AI gốc)');
    expect(vietnamese.id, isNot(chinese.id));
  });

  test('translated track keeps a distinct stable identity', () {
    const track = SubtitlePlaybackTrack(
      id: 'subtitle:translated:cache-id',
      label: 'Tiếng Việt (đang dịch 50%)',
      language: 'vi',
      kind: SubtitlePlaybackTrackKind.translated,
      phase: SubtitlePlaybackTrackPhase.translating,
      sourceIndex: 1,
      sourceLan: 'zh-CN',
      progress: 0.5,
      translatedCues: 10,
      totalCues: 20,
      vtt: 'WEBVTT',
      cacheIdentity: 'cache-id',
    );

    expect(track.isTranslated, isTrue);
    expect(track.id, isNot(SubtitlePlaybackTrack.offId));
    expect(track.copyWith(isComplete: true).id, track.id);
  });

  test('Bilibili track identity ignores expiring URL query parameters', () {
    final first = SubtitlePlaybackTrack.bilibili(
      subtitle: Subtitle(
        lan: 'ai-zh',
        subtitleUrl: 'https://example.com/subtitle.json?token=old',
        isAi: true,
      ),
      sourceIndex: 0,
      cid: 123,
      targetLanguage: 'vi',
    );
    final second = SubtitlePlaybackTrack.bilibili(
      subtitle: Subtitle(
        lan: 'ai-zh',
        subtitleUrl: 'https://example.com/subtitle.json?token=new',
        isAi: true,
      ),
      sourceIndex: 1,
      cid: 123,
      targetLanguage: 'vi',
    );

    expect(first.id, second.id);
  });
}
