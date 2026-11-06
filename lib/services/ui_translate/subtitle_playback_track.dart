import 'dart:convert';

import 'package:PiliPlus/models_new/video/video_play_info/subtitle.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:crypto/crypto.dart';

enum SubtitlePlaybackTrackKind { bilibili, translated }

enum SubtitlePlaybackTrackPhase {
  ready,
  translating,
  verifying,
  retrying,
  failed,
}

/// A stable player/menu identity that is independent from Bilibili's list
/// position. Translated tracks deliberately keep their own VTT instead of
/// replacing the source track's cache entry.
class SubtitlePlaybackTrack {
  const SubtitlePlaybackTrack({
    required this.id,
    required this.label,
    required this.language,
    required this.kind,
    required this.phase,
    this.sourceIndex,
    this.sourceLan,
    this.isAi = false,
    this.isComplete = false,
    this.progress = 0,
    this.translatedCues = 0,
    this.verifiedCues = 0,
    this.totalCues = 0,
    this.failedChunks = 0,
    this.vtt,
    this.cacheIdentity,
  });

  static const offId = 'subtitle:off';

  final String id;
  final String label;
  final String language;
  final SubtitlePlaybackTrackKind kind;
  final SubtitlePlaybackTrackPhase phase;
  final int? sourceIndex;
  final String? sourceLan;
  final bool isAi;
  final bool isComplete;
  final double progress;
  final int translatedCues;
  final int verifiedCues;
  final int totalCues;
  final int failedChunks;
  final String? vtt;
  final String? cacheIdentity;

  bool get isTranslated => kind == SubtitlePlaybackTrackKind.translated;

  SubtitlePlaybackTrack copyWith({
    String? label,
    SubtitlePlaybackTrackPhase? phase,
    bool? isComplete,
    double? progress,
    int? translatedCues,
    int? verifiedCues,
    int? totalCues,
    int? failedChunks,
    String? vtt,
    String? cacheIdentity,
  }) => SubtitlePlaybackTrack(
    id: id,
    label: label ?? this.label,
    language: language,
    kind: kind,
    phase: phase ?? this.phase,
    sourceIndex: sourceIndex,
    sourceLan: sourceLan,
    isAi: isAi,
    isComplete: isComplete ?? this.isComplete,
    progress: progress ?? this.progress,
    translatedCues: translatedCues ?? this.translatedCues,
    verifiedCues: verifiedCues ?? this.verifiedCues,
    totalCues: totalCues ?? this.totalCues,
    failedChunks: failedChunks ?? this.failedChunks,
    vtt: vtt ?? this.vtt,
    cacheIdentity: cacheIdentity ?? this.cacheIdentity,
  );

  static SubtitlePlaybackTrack bilibili({
    required Subtitle subtitle,
    required int sourceIndex,
    required int cid,
    required String targetLanguage,
  }) {
    // 裸 zh 源轨对繁體中文目标不是「现成译文」，标签不该写成
    // 「繁體中文（Bilibili 官方）」。与选轨/后台解析共用同一判据。
    final isTarget = subtitle.isNativeTarget(targetLanguage);
    // 标签跟随界面语言：中文源轨永远明确标注，目标语言轨标注来源，
    // 其余轨沿用 B 站自带的 lanDoc（如「英语」）。
    final targetName = UiTranslateService.to.currentLanguage.name;
    final label = switch ((subtitle.langTag, isTarget, subtitle.isAi)) {
      ('zh', _, true) => uiTx('中文（AI 识别）'),
      ('zh', _, false) => uiTx('中文（原文）'),
      (_, true, true) => uiTxP('{0}（Bilibili AI）', [targetName]),
      (_, true, false) => uiTxP('{0}（Bilibili 官方）', [targetName]),
      _ => subtitle.lanDoc ?? subtitle.lan,
    };
    final sourceIdentity = sha256
        .convert(
          utf8.encode(
            '${subtitle.lan}\n${subtitle.isAi}\n'
            '${_stableUrl(subtitle.subtitleUrl ?? subtitle.subtitleUrlV2)}',
          ),
        )
        .toString();
    return SubtitlePlaybackTrack(
      id: 'subtitle:bilibili:$cid:$sourceIdentity',
      label: label,
      language: subtitle.langTag,
      kind: SubtitlePlaybackTrackKind.bilibili,
      phase: SubtitlePlaybackTrackPhase.ready,
      sourceIndex: sourceIndex,
      sourceLan: subtitle.lan,
      isAi: subtitle.isAi,
      isComplete: true,
      progress: 1,
    );
  }

  static String _stableUrl(String? value) {
    if (value == null || value.isEmpty) return '';
    final uri = Uri.tryParse(value);
    if (uri == null) return value.split('?').first;
    return uri.replace(query: '', fragment: '').toString();
  }
}
