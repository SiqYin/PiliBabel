import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show max, min;

import 'package:PiliPlus/utils/path_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

typedef SubtitleChunkTranslator = Future<List<String>> Function(
  List<String> lines,
);

typedef SubtitleChunkTranslatorWithContext = Future<List<String>> Function(
  List<String> lines,
  List<String> context,
);

class SubtitleTranslationProgress {
  const SubtitleTranslationProgress({
    required this.completedChunks,
    required this.totalChunks,
    required this.processedCues,
    required this.translatedCues,
    required this.totalCues,
    required this.failedChunks,
  });

  final int completedChunks;
  final int totalChunks;
  final int processedCues;
  final int translatedCues;
  final int totalCues;
  final int failedChunks;

  bool get isComplete => completedChunks == totalChunks;

  double get ratio => totalCues == 0 ? 0 : processedCues / totalCues;
}

typedef SubtitleTranslationUpdate = void Function(
  String vtt,
  SubtitleTranslationProgress progress,
);

class SubtitleCue {
  const SubtitleCue(this.start, this.end, this.text);
  final String start;
  final String end;
  final String text;
}

abstract final class SubtitleCues {
  static List<SubtitleCue> fromBody(List body) => [
    for (final item in body)
      if (item is Map &&
          item['from'] is num &&
          item['to'] is num &&
          item['content'] is String &&
          (item['content'] as String).trim().isNotEmpty)
        SubtitleCue(
          _time(item['from'] as num),
          _time(item['to'] as num),
          (item['content'] as String).trim(),
        ),
  ];

  static List<SubtitleCue> fromVtt(String vtt) {
    final cues = <SubtitleCue>[];
    final blocks = vtt.replaceAll('\r\n', '\n').split(RegExp(r'\n\s*\n'));
    for (final block in blocks) {
      final lines = block.split('\n');
      final idx = lines.indexWhere((line) => line.contains(' --> '));
      if (idx < 0 || idx + 1 >= lines.length) continue;
      final parts = lines[idx].split(' --> ');
      if (parts.length != 2) continue;
      final text = lines.skip(idx + 1).join('\n').trim();
      if (text.isNotEmpty) {
        cues.add(SubtitleCue(parts[0].trim(), parts[1].trim(), text));
      }
    }
    return cues;
  }

  static String toVtt(List<SubtitleCue> cues, List<String> texts) {
    final out = StringBuffer('WEBVTT\n\n');
    for (var i = 0; i < cues.length; i++) {
      out
        ..writeln('${cues[i].start} --> ${cues[i].end}')
        ..writeln(texts[i])
        ..writeln();
    }
    return out.toString();
  }

  static String _time(num seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final rest = (seconds % 60).toStringAsFixed(3).padLeft(6, '0');
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:$rest';
  }
}

class SubtitleTranslationJob {
  static const _maxRetries = 2;

  SubtitleTranslationJob({
    required this.cues,
    required this.chunkSize,
    required this.concurrency,
    required this.translate,
    required this.cacheKey,
    required this.onUpdate,
    this.translateWithContext,
    this.positionSeconds = 0,
    this.cacheDirectory,
    this.retryDelay = const Duration(milliseconds: 250),
    this.contextOverlap = 4,
  }) : _texts = cues.map((cue) => cue.text).toList();

  final List<SubtitleCue> cues;
  final int chunkSize;
  final int concurrency;
  final SubtitleChunkTranslator translate;
  final SubtitleChunkTranslatorWithContext? translateWithContext;
  final String cacheKey;
  final String? cacheDirectory;
  final SubtitleTranslationUpdate onUpdate;
  final Duration retryDelay;
  final int contextOverlap;
  final List<String> _texts;
  final Set<int> _pending = {};
  int positionSeconds;
  bool _cancelled = false;
  int _completed = 0;
  int _processedCues = 0;
  int _translatedCues = 0;
  int _failedChunks = 0;
  bool _cacheChecked = false;
  bool _cacheHit = false;
  Timer? _refresh;
  DateTime? _lastEmitAt;

  int get total => (cues.length + chunkSize - 1) ~/ chunkSize;

  void cancel() {
    _cancelled = true;
    _refresh?.cancel();
  }

  void setPosition(int seconds) => positionSeconds = seconds;

  Future<bool> loadCached() async {
    if (_cacheChecked) return _cacheHit;
    _cacheChecked = true;
    final file = _cacheFile;
    try {
      if (!await file.exists()) return false;
      final data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final lines = (data['texts'] as List).cast<String>();
      if (lines.length != cues.length ||
          lines.any((line) => line.trim().isEmpty) ||
          _unchangedChinese(cues.map((cue) => cue.text).toList(), lines) ||
          _cancelled)
        return false;
      _texts.setAll(0, lines);
      _completed = total;
      _processedCues = cues.length;
      _translatedCues = cues.length;
      _cacheHit = true;
      _emit();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> run() async {
    if (cues.isEmpty || _cancelled || await loadCached()) return;
    _pending.addAll(List.generate(total, (i) => i));
    await Future.wait(List.generate(concurrency, (_) => _worker()));
    _refresh?.cancel();
    if (_cancelled) return;
    _emit();
    if (_failedChunks == 0) {
      try {
        final file = _cacheFile;
        await file.parent.create(recursive: true);
        final temp = File('${file.path}.${identityHashCode(this)}.tmp');
        await temp.writeAsString(jsonEncode({'texts': _texts}));
        if (_cancelled) {
          await temp.delete();
          return;
        }
        await temp.rename(file.path);
      } catch (_) {
        // Playback does not depend on disk caching.
      }
    }
  }

  Future<void> _worker() async {
    while (!_cancelled && _pending.isNotEmpty) {
      final next = _nearestPending();
      _pending.remove(next);
      final start = next * chunkSize;
      final end = min(start + chunkSize, cues.length);
      final source = cues.sublist(start, end).map((e) => e.text).toList();
      final contextStart = max(0, start - contextOverlap);
      final context = cues
          .sublist(contextStart, start)
          .map((cue) => cue.text)
          .toList();
      try {
        final result = await _translateWithRetry(source, context);
        if (_cancelled) return;
        _texts.setRange(start, end, result);
        _translatedCues += end - start;
      } catch (_) {
        if (_cancelled) return;
        _failedChunks++;
      }
      _completed++;
      _processedCues += end - start;
      _scheduleEmit();
    }
  }

  Future<List<String>> _translateWithRetry(
    List<String> source,
    List<String> context,
  ) async {
    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final result =
            await (translateWithContext?.call(source, context) ??
                translate(source));
        if (result.length != source.length ||
            result.any((e) => e.trim().isEmpty) ||
            _unchangedChinese(source, result)) {
          throw const FormatException('Invalid subtitle translation');
        }
        return result;
      } catch (error, stackTrace) {
        // Local state changes cannot be fixed by retrying and must stop work.
        if (_cancelled || error is StateError || attempt == _maxRetries) {
          Error.throwWithStackTrace(error, stackTrace);
        }
        final delay = Duration(
          milliseconds: retryDelay.inMilliseconds * (attempt + 1),
        );
        if (delay > Duration.zero) await Future<void>.delayed(delay);
      }
    }
    throw StateError('Unreachable subtitle translation retry state');
  }

  static bool _unchangedChinese(List<String> source, List<String> result) {
    for (var i = 0; i < source.length; i++) {
      final isChinese = source[i].runes.any(
        (r) => (r >= 0x3400 && r <= 0x9FFF) || (r >= 0xF900 && r <= 0xFAFF),
      );
      if (!isChinese) continue;
      if (source[i].trim() == result[i].trim()) return true;
    }
    return false;
  }

  int _nearestPending() {
    var best = _pending.first;
    var bestBand = 3;
    var bestDistance = double.infinity;
    for (final index in _pending) {
      final startIndex = index * chunkSize;
      final endIndex = min(startIndex + chunkSize, cues.length) - 1;
      final start = _seconds(cues[startIndex].start);
      final end = _seconds(cues[endIndex].end);
      final (band, distance) = switch (positionSeconds) {
        // Cue end times are exclusive, so a boundary belongs to the next chunk.
        final position when position >= start && position < end => (0, 0.0),
        final position when position < start => (1, start - position),
        final position => (2, position - end),
      };
      if (band < bestBand ||
          (band == bestBand && distance < bestDistance) ||
          (band == bestBand && distance == bestDistance && index < best)) {
        best = index;
        bestBand = band;
        bestDistance = distance;
      }
    }
    return best;
  }

  void _scheduleEmit() {
    const interval = Duration(milliseconds: 400);
    final last = _lastEmitAt;
    final elapsed = last == null ? interval : DateTime.now().difference(last);
    if (elapsed >= interval) {
      _refresh?.cancel();
      _refresh = null;
      _emit();
      return;
    }
    _refresh ??= Timer(interval - elapsed, () {
      _refresh = null;
      if (!_cancelled) _emit();
    });
  }

  void _emit() {
    _lastEmitAt = DateTime.now();
    onUpdate(
      SubtitleCues.toVtt(cues, _texts),
      SubtitleTranslationProgress(
        completedChunks: _completed,
        totalChunks: total,
        processedCues: _processedCues,
        translatedCues: _translatedCues,
        totalCues: cues.length,
        failedChunks: _failedChunks,
      ),
    );
  }

  static double _seconds(String timestamp) {
    final parts = timestamp.split(':');
    if (parts.length != 3) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 3600 +
        (int.tryParse(parts[1]) ?? 0) * 60 +
        (double.tryParse(parts[2]) ?? 0);
  }

  File get _cacheFile {
    final source = cues.map((e) => '${e.start}/${e.end}/${e.text}').join('\n');
    final hash = sha256.convert(utf8.encode('$cacheKey\n$source'));
    return File(
      path.join(
        cacheDirectory ?? path.join(appSupportDirPath, 'subtitle_translations'),
        '$hash.json',
      ),
    );
  }
}
