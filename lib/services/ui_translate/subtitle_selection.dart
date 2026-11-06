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
      // 与后台源解析器、播放轨标签共用同一个「是否现成译文」判据，
      // 避免三处各自判断导致繁體中文目标被当成已有译文。
      if (track.isNativeTarget(language)) {
        final rank = (isAi ? 10 : 0) + score;
        if (rank > bestRank) {
          bestRank = rank;
          bestTarget = i;
        }
      }
      if (track.isChineseSourceTrack) {
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
