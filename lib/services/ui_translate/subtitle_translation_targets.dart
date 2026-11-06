import 'package:PiliPlus/models_new/video/video_detail/data.dart';

class SubtitleTranslationTarget {
  const SubtitleTranslationTarget({
    required this.videoKey,
    required this.bvid,
    required this.aid,
    required this.cid,
    this.epId,
    this.seasonId,
  });

  final String videoKey;
  final String? bvid;
  final int? aid;
  final int? cid;

  /// 番剧（pgc）单集没有 bvid/aid 时，靠这两个参数请求字幕列表。
  final int? epId;
  final int? seasonId;
}

/// Flattens a normal multi-P video or an entire UGC season into independent
/// subtitle jobs. The selected part is moved to the front so its subtitles
/// become available first while the rest of the list continues in background.
List<SubtitleTranslationTarget> subtitleTranslationTargetsFromDetail({
  required VideoDetailData detail,
  required String fallbackVideoKey,
  required String fallbackBvid,
  int? fallbackAid,
  int? selectedCid,
}) {
  final targets = <SubtitleTranslationTarget>[];
  final seenCids = <int>{};
  final detailBvid = _nonEmpty(detail.bvid) ?? _nonEmpty(fallbackBvid);
  final detailAid = detail.aid ?? fallbackAid;

  void add({String? bvid, int? aid, int? cid}) {
    if (cid == null || !seenCids.add(cid)) return;
    final resolvedBvid = _nonEmpty(bvid);
    final resolvedAid = aid;
    if (resolvedBvid == null && resolvedAid == null) return;
    final identity = '${resolvedBvid ?? 'av$resolvedAid'}/$cid';
    targets.add(
      SubtitleTranslationTarget(
        videoKey: identity,
        bvid: resolvedBvid,
        aid: resolvedAid,
        cid: cid,
      ),
    );
  }

  final sections = detail.ugcSeason?.sections;
  if (sections != null && sections.isNotEmpty) {
    for (final section in sections) {
      for (final episode in section.episodes ?? const []) {
        final episodeAid = episode.aid ?? episode.arc?.aid;
        final episodeBvid = _nonEmpty(episode.bvid);
        // Some season payloads omit bvid but retain aid under arc. In that
        // case use aid directly instead of incorrectly reusing the clicked BV.
        final resolvedBvid =
            episodeBvid ?? (episodeAid == null ? detailBvid : null);
        final resolvedAid =
            episodeAid ?? (resolvedBvid == detailBvid ? detailAid : null);
        final pages = episode.pages;
        if (pages != null && pages.isNotEmpty) {
          for (final page in pages) {
            add(bvid: resolvedBvid, aid: resolvedAid, cid: page.cid);
          }
        } else {
          add(
            bvid: resolvedBvid,
            aid: resolvedAid,
            cid: episode.page?.cid ?? episode.cid,
          );
        }
      }
    }
  }

  // A video can expose an empty/incomplete UGC season object. Fall back to
  // its ordinary pages so pressing the card action still covers every part.
  if (targets.isEmpty) {
    for (final page in detail.pages ?? const []) {
      add(bvid: detailBvid, aid: detailAid, cid: page.cid);
    }
  }

  if (selectedCid != null && !seenCids.contains(selectedCid)) {
    add(bvid: detailBvid, aid: detailAid, cid: selectedCid);
  }

  final selectedIndex = targets.indexWhere((item) => item.cid == selectedCid);
  if (selectedIndex > 0) {
    targets.insert(0, targets.removeAt(selectedIndex));
  }

  if (targets.isEmpty) {
    return [
      SubtitleTranslationTarget(
        videoKey: fallbackVideoKey,
        bvid: _nonEmpty(fallbackBvid),
        aid: fallbackAid,
        cid: selectedCid,
      ),
    ];
  }
  return targets;
}

String? _nonEmpty(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
