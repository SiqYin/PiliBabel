import 'package:PiliPlus/models/common/enum_with_label.dart';
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
  static List<Map> _validItems(List list) => [
    for (final item in list)
      if (item is Map &&
          item['from'] is num &&
          item['to'] is num &&
          item['content'] is String &&
          (item['from'] as num) >= 0 &&
          (item['to'] as num) > (item['from'] as num) &&
          (item['content'] as String).trim().isNotEmpty)
        item.cast<String, dynamic>(),
  ];

  static String _vttTimecode(num seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    seconds %= 3600;
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    seconds %= 60;
    final sms = seconds.toStringAsFixed(3).padLeft(6, '0');
    return "$h:$m:$sms";
  }

  static String json2Vtt(List list) {
    final items = _validItems(list);
    final sb = StringBuffer('WEBVTT\n\n')
      ..writeAll(
        items.map(
          (item) =>
              '${_vttTimecode(item['from'])} --> ${_vttTimecode(item['to'])}\n${item['content'].trim()}',
        ),
        '\n\n',
      );
    return sb.toString();
  }

  static String _srtTimecode(num seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    seconds %= 3600;
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    seconds %= 60;
    final s = seconds.toInt();
    final ms = ((seconds - s) * 1000).round().toString().padLeft(3, '0');
    return '$h:$m:${s.toString().padLeft(2, '0')},$ms';
  }

  static String json2Srt(List list) {
    final items = _validItems(list);
    final sb = StringBuffer()
      ..writeAll(
        items.mapIndexed(
          (i, e) =>
              '${i + 1}\n${_srtTimecode(e['from'])} --> ${_srtTimecode(e['to'])}\n${e['content'].trim()}',
        ),
        '\n\n',
      );
    return sb.toString();
  }
}
