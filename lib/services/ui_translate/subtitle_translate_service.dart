import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models_new/video/video_play_info/subtitle.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/subtitle_utils.dart';
import 'package:get/get.dart';

/// 视频自带字幕的翻译。
///
/// 规则（与界面翻译一致）：
/// * 界面语言是简体中文时什么都不做 —— 原文本来就是简体中文，翻它没有意义；
/// * 界面语言是其它任何语言（含繁體中文、简体粤语、简体吴语、大陆闽南语等
///   中文家族）时，**正在显示的中文字幕一律翻成界面语言**；
/// * 只处理中文轨（含 B 站 `ai-zh` 自动生成轨），其它语种的轨原样显示。
///
/// 译文按 `bvid/cid/lan/目标语言` 缓存在内存里：同一视频来回切轨不会重复翻译。
abstract final class SubtitleTranslateService {
  /// 一条字幕轨要发多次请求，缓存只留最近几条，避免长列表下内存膨胀。
  static const int _maxCache = 6;
  static final Map<String, String> _cache = {};

  /// 是否需要翻译字幕：界面翻译开着，且界面语言不是简体中文。
  static bool get needed {
    if (!Get.isRegistered<UiTranslateService>()) return false;
    final service = UiTranslateService.to;
    return service.enabled && service.translateContent;
  }

  /// 这条轨是不是中文轨。`langTag` 已归一化（`ai-zh` → `zh`、`zh-Hant` → `zh`）。
  static bool isChineseTrack(Subtitle sub) => sub.langTag == 'zh';

  /// 含中日韩汉字就认为需要翻译，纯数字/符号/拉丁文的行原样保留。
  static bool _isCjk(String s) {
    for (final r in s.runes) {
      if ((r >= 0x3400 && r <= 0x9FFF) || (r >= 0xF900 && r <= 0xFAFF)) {
        return true;
      }
    }
    return false;
  }

  /// 翻译一条中文字幕轨，返回可直接挂载的 VTT 文本；不需要或失败返回 null。
  static Future<String?> translatedVtt({
    required String bvid,
    required int cid,
    required Subtitle sub,
  }) async {
    final url = sub.subtitleUrl;
    if (url == null || url.isEmpty) return null;
    if (!needed || !isChineseTrack(sub)) return null;

    final target = UiTranslateService.to.currentLanguage.code;
    final key = '$bvid/$cid/${sub.lan}/$target';
    final hit = _cache[key];
    if (hit != null) return hit;

    final List body;
    try {
      final raw = await VideoHttp.fetchSubtitleBody(url);
      if (raw == null || raw.isEmpty) return null;
      body = raw;
    } catch (_) {
      return null;
    }

    final lines = <String>[];
    for (final item in body) {
      lines.add(((item is Map ? item['content'] : null) as String?)?.trim() ?? '');
    }

    // 只翻含汉字的行：纯数字/符号行没有翻译价值，少发一次请求。
    final index = <int>[];
    final pending = <String>[];
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].isNotEmpty && _isCjk(lines[i])) {
        index.add(i);
        pending.add(lines[i]);
      }
    }
    if (pending.isEmpty) return null;

    final translated = <String>[];
    const batch = 30;
    for (var i = 0; i < pending.length; i += batch) {
      final end = i + batch < pending.length ? i + batch : pending.length;
      translated.addAll(await _translateBatch(pending.sublist(i, end)));
    }
    if (translated.length != pending.length) return null;
    for (var i = 0; i < index.length; i++) {
      lines[index[i]] = translated[i];
    }

    final out = <Map<String, dynamic>>[];
    for (var i = 0; i < body.length; i++) {
      final item = body[i];
      if (item is Map) {
        out.add({
          'from': item['from'],
          'to': item['to'],
          'content': lines[i].isEmpty ? (item['content'] ?? '') : lines[i],
        });
      }
    }
    if (out.isEmpty) return null;

    final vtt = SubtitleUtils.json2Vtt(out);
    _cache[key] = vtt;
    while (_cache.length > _maxCache) {
      _cache.remove(_cache.keys.first);
    }
    return vtt;
  }

  /// 一批字幕行：先整批拼成一段发一次请求，再按行拆回。
  /// 行数对不上就退化成逐行翻译 —— 宁可慢，也不要把字幕错位。
  static Future<List<String>> _translateBatch(List<String> part) async {
    final service = UiTranslateService.to;
    if (part.length > 1) {
      try {
        final out = await service.translateTexts([part.join('\n')]);
        if (out.isNotEmpty) {
          final split = out.first.split('\n');
          if (split.length == part.length) {
            return split.map((e) => e.trim()).toList();
          }
        }
      } catch (_) {}
    }
    final one = <String>[];
    for (final line in part) {
      try {
        final out = await service.translateTexts([line]);
        one.add(out.isNotEmpty ? out.first : line);
      } catch (_) {
        one.add(line);
      }
    }
    return one;
  }
}
