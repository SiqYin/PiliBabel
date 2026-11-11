import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models_new/video/video_play_info/subtitle.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_proxy.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_text_quality.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:get/get.dart';

/// 视频自带字幕的翻译。
///
/// 规则（与界面翻译一致）：
/// * 界面语言是简体中文时什么都不做 —— 原文本来就是简体中文，翻它没有意义；
/// * 界面语言是其它任何语言（含繁體中文、粵語、简体/繁體吴语、臺灣閩南語等
///   中文家族，以及纯白话字的 Tâi-gí）时，**正在显示的中文字幕一律翻成界面语言**；
/// * 只处理中文轨（含 B 站 `ai-zh` 自动生成轨），其它语种的轨原样显示。
///
/// 译文按 `bvid/cid/lan/目标语言` 缓存在内存里：同一视频来回切轨不会重复翻译。
abstract final class SubtitleTranslateService {
  /// Keep enough full VTT tracks in memory for normal playlist browsing.
  ///
  /// Completed translations are also checkpointed under the app-support
  /// directory by [SubtitleTranslationJob], so they survive app restarts and
  /// are not governed by the temporary image-cache limit. This in-memory
  /// layer avoids repeatedly reading those files while the user switches
  /// between recently watched videos or subtitle tracks.
  static const int _maxCache = 64;
  static final Map<String, String> _cache = {};

  /// 是否需要翻译字幕：界面翻译开着，且界面语言不是简体中文。
  static bool get needed {
    if (!Get.isRegistered<UiTranslateService>()) return false;
    final service = UiTranslateService.to;
    return service.enabled && service.translateContent;
  }

  /// 这条轨能不能作为中文源交给 AI 翻译（中文家族轨都算，但排除
  /// 我们自己落盘的 `-app-ai` 译文轨）。判定统一放在 `Subtitle` 上。
  static bool isChineseTrack(Subtitle sub) => sub.isChineseSourceTrack;

  /// 含中日韩汉字就认为需要翻译，纯数字/符号/拉丁文的行原样保留。
  static bool _isCjk(String s) => SubtitleTextQuality.containsHan(s);

  /// A single request per chunk in the common case. If the provider changes
  /// line boundaries, recover individual cues without ever shifting timing.
  static Future<List<String>> translateChunk(
    List<String> lines, {
    List<String> contextLines = const [],
    SubtitleTranslationProxy? proxy,
  }) async {
    if (!needed) throw StateError('Subtitle translation is disabled');
    if (lines.isEmpty) return [];
    final service = UiTranslateService.to;
    final target = service.currentLanguage.code;
    final translated = List<String>.of(lines);
    final indices = <int>[];
    for (var i = 0; i < lines.length; i++) {
      if (_isCjk(lines[i])) indices.add(i);
    }
    if (indices.isEmpty) return translated;
    final output = await service.translateSubtitleLines(
      [
        for (final i in indices) lines[i],
      ],
      contextLines: contextLines,
      subtitleProxy: proxy,
    );
    if (!needed ||
        service.currentLanguage.code != target ||
        output.length != indices.length) {
      throw const FormatException('Subtitle translation changed or failed');
    }
    for (var i = 0; i < indices.length; i++) {
      final value = output[i].trim();
      // 只拒绝「空译文」。**不再逐行拒绝「与原文相同」**：
      // 簡→繁、中→日汉字词、人名/数字行本来就会一字不差，
      // 逐行判死等于让整块（进而整条轨）永远失败。
      // 「模型整块没翻」由 SubtitleTranslationJob._rejectCopiedSource 按块判定。
      if (value.isEmpty) {
        throw const FormatException('Subtitle translation unavailable');
      }
      translated[indices[i]] = value;
    }
    return translated;
  }

  /// 翻译一条中文字幕轨，返回可直接挂载的 VTT 文本；不需要或失败返回 null。
  ///
  /// 这是合并 PR #2 时留下的旧同步路径（当前主链路走后台翻译服务），
  /// 但它的失败语义必须正确：
  /// 旧实现用 `translateTexts`（失败静默返回原文）逐行兜底，一旦模型出错就会
  /// 把中文原文包装成「译文轨」挂上去，而且再也不会重试。现在改用
  /// [UiTranslateService.translateSubtitleLines]，任何失败都返回 null。
  static Future<String?> translatedVtt({
    required String bvid,
    required int cid,
    required Subtitle sub,
  }) async {
    if (!needed || !isChineseTrack(sub)) return null;

    final target = UiTranslateService.to.currentLanguage.code;
    final key = '$bvid/$cid/${sub.lan}/$target';
    final hit = _cache[key];
    if (hit != null) return hit;

    final List body;
    try {
      final raw = await VideoHttp.fetchSubtitleBodyFor(sub);
      if (raw == null || raw.isEmpty) return null;
      body = raw;
    } catch (_) {
      return null;
    }
    final cues = SubtitleCues.fromBody(body);
    if (cues.isEmpty) return null;

    final texts = <String>[for (final cue in cues) cue.text];
    final indices = <int>[
      for (var i = 0; i < texts.length; i++)
        if (_isCjk(texts[i])) i,
    ];
    if (indices.isEmpty) return null;

    final translated = <String>[];
    const batch = 20;
    try {
      for (var start = 0; start < indices.length; start += batch) {
        final end = start + batch < indices.length
            ? start + batch
            : indices.length;
        final slice = indices.sublist(start, end);
        final out = await UiTranslateService.to.translateSubtitleLines(
          [for (final i in slice) texts[i]],
        );
        if (out.length != slice.length) return null;
        translated.addAll(out);
      }
    } catch (_) {
      return null;
    }
    for (var i = 0; i < indices.length; i++) {
      texts[indices[i]] = translated[i];
    }

    final vtt = SubtitleCues.toVtt(cues, texts);
    _cache[key] = vtt;
    while (_cache.length > _maxCache) {
      _cache.remove(_cache.keys.first);
    }
    return vtt;
  }
}
