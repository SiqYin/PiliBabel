import 'dart:convert';

import 'package:PiliPlus/models_new/video/video_play_info/subtitle.dart';
import 'package:PiliPlus/services/ui_translate/app_language.dart';
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

  /// 固定 UI 标签的同步本地化：先查离线词典（人工钉扎/越南语，不依赖服务
  /// 注册、零请求秒回），未命中再走常规 `uiTx` 管道（跟随界面语言，未译
  /// 模板入队异步补译）。占位符 `{0}` 与模板一起查、查到后回填。
  static String _label(String template, String langCode, [String? arg]) {
    String fill(String value) =>
        arg == null ? value : value.replaceAll('{0}', arg);
    final offline = UiTranslateService.txOffline(template, langCode);
    if (offline != null) return fill(offline);
    return fill(uiTx(template));
  }

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
    // 语言自称（Tiếng Việt / English / 日本語）从 targetLanguage 推导，
    // 不依赖 UiTranslateService 注册：轨道名描述的是**轨道自身的语言**，
    // 且各调用点传入的 targetLanguage 就是 Pref.uiTranslateLang（界面语言）。
    final targetName = appLanguageByCode(targetLanguage).name;
    final label = switch ((subtitle.langTag, isTarget, subtitle.isAi)) {
      ('zh', _, true) => _label('中文（AI 识别）', targetLanguage),
      ('zh', _, false) => _label('中文（原文）', targetLanguage),
      (_, true, true) => _label('{0}（Bilibili AI）', targetLanguage, targetName),
      (_, true, false) => _label(
        '{0}（Bilibili 官方）',
        targetLanguage,
        targetName,
      ),
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
