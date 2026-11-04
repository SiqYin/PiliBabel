import 'dart:convert';

import 'package:PiliPlus/models_new/video/video_play_info/subtitle.dart';
import 'package:crypto/crypto.dart';

enum SubtitlePlaybackTrackKind { bilibili, translated }

enum SubtitlePlaybackTrackPhase { ready, translating, retrying, failed }

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
    final targetTag = _primaryLanguage(targetLanguage);
    final isTarget = subtitle.langTag == targetTag;
    final label = switch ((subtitle.langTag, isTarget, subtitle.isAi)) {
      ('vi', true, true) => 'Tiếng Việt (Bilibili AI)',
      ('vi', true, false) => 'Tiếng Việt (Bilibili)',
      ('zh', _, true) => 'Tiếng Trung (AI gốc)',
      ('zh', _, false) => 'Tiếng Trung (gốc)',
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

  static String _primaryLanguage(String value) {
    final normalized = value.toLowerCase().replaceFirst('ai-', '');
    return normalized.split(RegExp('[-_]')).first;
  }

  static String _stableUrl(String? value) {
    if (value == null || value.isEmpty) return '';
    final uri = Uri.tryParse(value);
    if (uri == null) return value.split('?').first;
    return uri.replace(query: '', fragment: '').toString();
  }
}
