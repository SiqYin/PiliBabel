import 'package:PiliPlus/models/common/enum_with_label.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';
import 'package:collection/collection.dart' show IterableExtension;

enum SubtitleFormat implements EnumWithLabel {
  json('JSON'),
  vtt('WEBVTT'),
  srt('SRT');

  @override
  final String label;
  const SubtitleFormat(this.label);
}

abstract final class SubtitleUtils {
  /// 只保留能正常显示的字幕条目。
  ///
  /// 播放页拿到的源字幕就是 `getSubtitles` 用本文件从 B 站 JSON 生成的 VTT；
  /// 以前零长度/倒序/空文本条目照样写进去，随后被整轨时间轴检查一票否决，
  /// 表现为「源字幕时间轴异常」且无法重试。这里在生成期就清掉。
  /// 与后台 `SubtitleCues.fromBody` 共用同一套时间轴清洗规则，避免
  /// 「播放页 json2Vtt 生成的轨」和「后台解析的轨」在重叠 cue 上结论不同。
  static List<SubtitleCue> _validCues(List list) =>
      SubtitleCues.sanitizeTimeline([
    for (final item in list)
      if (item is Map &&
          item['from'] is num &&
          item['to'] is num &&
          item['content'] is String &&
          (item['from'] as num) >= 0 &&
          (item['to'] as num) > (item['from'] as num) &&
          (item['content'] as String).trim().isNotEmpty)
        SubtitleCue(
          _vttTimecode(item['from'] as num),
          _vttTimecode(item['to'] as num),
          (item['content'] as String).trim(),
        ),
  ]);

  static String _vttTimecode(num seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    seconds %= 3600;
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    seconds %= 60;
    final sms = seconds.toStringAsFixed(3).padLeft(6, '0');
    return "$h:$m:$sms";
  }

  static String json2Vtt(List list) {
    final cues = _validCues(list);
    // 全部 cue 都不可用时必须返回空串：以前返回 "WEBVTT\n\n"，
    // `getSubtitlesFor` 的 `trim().isNotEmpty` 判成下载成功，播放页挂上一条
    // 空字幕轨，后台却又按「没有字幕」处理，两边对不上且永远翻不出来。
    if (cues.isEmpty) return '';
    return SubtitleCues.toVtt(cues, [for (final cue in cues) cue.text]);
  }

  static String _srtStamp(String vttStamp) => vttStamp.replaceAll('.', ',');

  static String json2Srt(List list) {
    final cues = _validCues(list);
    if (cues.isEmpty) return '';
    final sb = StringBuffer()
      ..writeAll(
        cues.mapIndexed(
          (i, cue) =>
              '${i + 1}\n${_srtStamp(cue.start)} --> ${_srtStamp(cue.end)}\n${cue.text}',
        ),
        '\n\n',
      );
    return sb.toString();
  }
}
