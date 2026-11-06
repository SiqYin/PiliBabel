import 'package:PiliPlus/models_new/video/video_play_info/subtitle.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';

typedef SubtitleCueLoader = Future<List<SubtitleCue>> Function(Subtitle track);

enum SubtitleSourceKind { nativeTarget, chineseTranslation }

class ResolvedSubtitleSource {
  const ResolvedSubtitleSource({
    required this.kind,
    required this.track,
    this.cues = const [],
  });

  final SubtitleSourceKind kind;
  final Subtitle track;
  final List<SubtitleCue> cues;
}

/// Uses one source-selection policy for playback and detached background jobs.
abstract final class SubtitleSourceResolver {
  static Future<ResolvedSubtitleSource?> resolve({
    required List<Subtitle> tracks,
    required String targetLanguage,
    required SubtitleCueLoader loadCues,
    bool forceChineseSource = false,
  }) async {
    if (!forceChineseSource) {
      final native =
          tracks
              .where((track) => track.isNativeTarget(targetLanguage))
              .toList(growable: false)
            ..sort((a, b) {
              if (a.isAi == b.isAi) return 0;
              return a.isAi ? -1 : 1;
            });
      for (final track in native) {
        try {
          final cues = await loadCues(track);
          // B 站偶尔会列出一条下载即 404 / 空 body 的「目标语言」轨。
          // 以前不看内容就返回 nativeTarget，播放页挂不上字幕、后台又判定
          // 「无需翻译」，用户点多少次都不会有译文。这里验证后才能算现成译文。
          if (cues.isEmpty || !SubtitleCues.hasSafePlaybackTimeline(cues)) {
            continue;
          }
          return ResolvedSubtitleSource(
            kind: SubtitleSourceKind.nativeTarget,
            track: track,
            cues: cues,
          );
        } catch (_) {
          // 这条轨不可用就继续试下一条，全部不可用则退回中文源 + AI 翻译。
        }
      }
    }

    final candidates = <({Subtitle track, List<SubtitleCue> cues})>[];
    for (final track in tracks.where((track) => track.langTag == 'zh')) {
      try {
        final cues = await loadCues(track);
        if (cues.isEmpty || !SubtitleCues.hasSafePlaybackTimeline(cues)) {
          continue;
        }
        candidates.add((track: track, cues: cues));
      } catch (_) {
        // One unavailable source must not hide another usable transcript.
      }
    }
    candidates.sort((a, b) {
      final length = b.cues.length.compareTo(a.cues.length);
      if (length != 0) return length;
      final aAi = a.track.isAi || a.track.lan.startsWith('ai-');
      final bAi = b.track.isAi || b.track.lan.startsWith('ai-');
      if (aAi == bAi) return 0;
      return aAi ? -1 : 1;
    });
    if (candidates.isEmpty) return null;
    return ResolvedSubtitleSource(
      kind: SubtitleSourceKind.chineseTranslation,
      track: candidates.first.track,
      cues: candidates.first.cues,
    );
  }

  static String _primaryLanguage(String value) {
    final normalized = value.toLowerCase().replaceFirst('ai-', '');
    return normalized.split(RegExp('[-_]')).first;
  }

  /// 目标语言代码 → 主要语言子标签（'vi' / 'zh-Hant' → 'zh'），
  /// 供译文轨的语言标识与轨道匹配使用。
  static String primaryLanguageTag(String value) => _primaryLanguage(value);
}
