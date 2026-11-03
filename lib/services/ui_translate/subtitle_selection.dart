import 'package:PiliPlus/models_new/video/video_play_info/subtitle.dart';

class SubtitleSelection {
  const SubtitleSelection({required this.index, required this.translate});

  final int index; // 1-based player index
  final bool translate;
}

abstract final class SubtitleSelectionPolicy {
  static SubtitleSelection choose(
    List<Subtitle> tracks,
    String language, {
    required bool canTranslate,
  }) {
    int bestTarget = -1;
    int bestRank = -1;
    int source = -1;
    int sourceRank = -1;
    for (var i = 0; i < tracks.length; i++) {
      final track = tracks[i];
      final score = Subtitle.langScore(track.lan, language);
      final isAi = track.isAi || track.lan.startsWith('ai-');
      // Bare "zh"/"ai-zh" is usually source Chinese, not a guaranteed
      // traditional-Chinese track for a zh-Hant target.
      final ambiguousChinese =
          track.langTag == 'zh' &&
          language.toLowerCase() != 'zh-cn' &&
          (track.lan == 'zh' || track.lan == 'ai-zh');
      if (score >= 2 && !ambiguousChinese) {
        final rank = (isAi ? 10 : 0) + score;
        if (rank > bestRank) {
          bestRank = rank;
          bestTarget = i;
        }
      }
      if (track.langTag == 'zh') {
        // Bilibili's AI track is normally the more complete speech-recognition
        // transcript. Use it as the translation source first; callers still
        // retry with the regular track when this track cannot be loaded.
        final rank = isAi ? 1 : 0;
        if (rank > sourceRank) {
          sourceRank = rank;
          source = i;
        }
      }
    }
    if (bestTarget >= 0) {
      return SubtitleSelection(index: bestTarget + 1, translate: false);
    }
    if (source >= 0) {
      return SubtitleSelection(
        index: source + 1,
        translate: canTranslate,
      );
    }
    return SubtitleSelection(index: tracks.isEmpty ? 0 : 1, translate: false);
  }
}
