import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:intl/intl.dart' show DateFormat;

abstract final class DateFormatUtils {
  static final shortFormat = DateFormat('MM-dd');
  static final longFormat = DateFormat('yyyy-MM-dd');
  static final _shortFormatD = DateFormat('MM-dd HH:mm');
  static final longFormatD = DateFormat('yyyy-MM-dd HH:mm');
  static final longFormatDs = DateFormat('yyyy-MM-dd HH:mm:ss');

  static String dateFormat(
    int? time, {
    DateFormat? short,
    DateFormat? long,
  }) {
    if (time == null || time == 0) {
      return '';
    }

    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(time * 1000);
    final diff = now.difference(date);

    final diffInMins = diff.inMinutes;
    if (diffInMins < 1) return uiTx('刚刚');
    if (diffInMins < 60) return uiTxP('{0}分钟前', [diffInMins]);

    final diffInHours = diff.inHours;
    if (diffInHours < 24) return uiTxP('{0}小时前', [diffInHours]);

    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    final dayDiff = today.difference(dateDay).inDays;
    if (dayDiff == 1) {
      return uiTxP('昨天 {0}:{1}', [
        _twoDigits(date.hour),
        _twoDigits(date.minute),
      ]);
    }
    if (dayDiff < 4) {
      return uiTxP('{0}天前', [dayDiff]);
    }
    final DateFormat sdf = now.year == date.year
        ? short ?? shortFormat
        : long ?? longFormat;
    return sdf.format(date);
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  static String chatFormat(int? time, {bool isHistory = false}) {
    if (time == null || time == 0) {
      return '';
    }

    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(time * 1000);

    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    if (today == dateDay) {
      final hm = '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
      return isHistory ? uiTxP('今天 {0}', [hm]) : hm;
    }
    final isYesterday = today.subtract(const Duration(days: 1)) == dateDay;
    if (isYesterday) {
      return uiTxP('昨天 {0}', [
        '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}',
      ]);
    }
    if (isHistory) {
      final DateFormat sdf = now.year == date.year
          ? _shortFormatD
          : longFormatD;
      return sdf.format(date);
    }
    return longFormatD.format(date);
  }

  static String format(int? time, {DateFormat? format}) {
    if (time == null || time == 0) {
      return '';
    }
    final date = DateTime.fromMillisecondsSinceEpoch(time * 1000);
    return (format ?? longFormatD).format(date);
  }
}
