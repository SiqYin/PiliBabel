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

  bool get isComplete => completedChunks == totalChunks && failedChunks == 0;

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

/// Normalizes model output before it reaches the VTT/cache layer.
///
/// Batch prompts number their source lines for alignment. Some providers echo
/// those labels in each JSON string, which would otherwise be shown as part of
/// the subtitle. The validation also keeps an English fallback from being
/// treated as a finished Vietnamese translation.
abstract final class SubtitleTranslationOutput {
  static final RegExp _ordinalPrefix = RegExp(
    r'^\s*(?:\[(\d{1,3})\]|(\d{1,3})\s*[\.、\):：-]\s*(?!\d))',
  );
  static final RegExp _han = RegExp(r'[\u3400-\u9FFF\uF900-\uFAFF]');
  static final RegExp _vietnameseMarks = RegExp(r'[À-ỹĐđ]');
  static final RegExp _latinWords = RegExp(r'[A-Za-z]+');
  static const Set<String> _vietnameseWords = {
    'anh',
    'em',
    'xin',
    'chao',
    'chào',
    'toi',
    'tôi',
    'ban',
    'bạn',
    'khong',
    'không',
    'duoc',
    'được',
    'cua',
    'của',
    'voi',
    'với',
    'cho',
    'dung',
    'dừng',
    'lai',
    'lại',
    'day',
    'đây',
    'di',
    'đi',
    've',
    'về',
    'muon',
    'muốn',
    'gap',
    'gặp',
    'mot',
    'một',
    'nay',
    'này',
    'kia',
    'sao',
    'roi',
    'rồi',
    'la',
    'là',
    'va',
    'và',
    'se',
    'sẽ',
    'da',
    'đã',
    'dang',
    'đang',
  };
  static const Set<String> _englishWords = {
    'a',
    'an',
    'and',
    'are',
    'be',
    'but',
    'for',
    'from',
    'good',
    'he',
    'hello',
    'her',
    'him',
    'how',
    'i',
    'in',
    'is',
    'it',
    'me',
    'morning',
    'my',
    'no',
    'of',
    'on',
    'or',
    'please',
    'right',
    'sorry',
    'she',
    'thank',
    'that',
    'the',
    'there',
    'they',
    'this',
    'to',
    'we',
    'what',
    'when',
    'where',
    'why',
    'with',
    'want',
    'wait',
    'stop',
    'help',
    'love',
    'know',
    'need',
    'come',
    'go',
    'yes',
    'you',
    'your',
  };

  static List<String> sanitizeAndValidate(
    List<String> source,
    List<String> output, {
    String? targetLanguage,
  }) {
    if (source.length != output.length) {
      throw const FormatException('Subtitle line count changed');
    }
    return [
      for (var i = 0; i < output.length; i++)
        _validateLine(
          source: source[i],
          output: output[i],
          ordinal: i + 1,
          targetLanguage: targetLanguage,
        ),
    ];
  }

  static String _validateLine({
    required String source,
    required String output,
    required int ordinal,
    required String? targetLanguage,
  }) {
    final normalized = _stripEchoedOrdinal(source, output, ordinal).trim();
    if (normalized.isEmpty) {
      throw const FormatException('Subtitle translation is empty');
    }
    final sourceHasHan = _han.hasMatch(source);
    if (sourceHasHan && normalized == source.trim()) {
      throw const FormatException('Subtitle translation copied source');
    }
    if (sourceHasHan &&
        targetLanguage?.toLowerCase() == 'vi' &&
        _looksEnglishInsteadOfVietnamese(normalized)) {
      throw const FormatException('Subtitle translation is not Vietnamese');
    }
    return normalized;
  }

  static String _stripEchoedOrdinal(String source, String output, int ordinal) {
    final outputMatch = _ordinalPrefix.firstMatch(output);
    if (outputMatch == null || _ordinal(outputMatch) != ordinal) {
      return output;
    }
    // A real ordinal in the source (for example, "1. 第一章") is dialogue
    // content and must survive translation unchanged.
    final sourceMatch = _ordinalPrefix.firstMatch(source);
    if (sourceMatch != null && _ordinal(sourceMatch) == ordinal) {
      return output;
    }
    return output.substring(outputMatch.end);
  }

  static int? _ordinal(RegExpMatch match) =>
      int.tryParse(match.group(1) ?? match.group(2) ?? '');

  static bool _looksEnglishInsteadOfVietnamese(String value) {
    if (_vietnameseMarks.hasMatch(value)) return false;
    final words = _latinWords
        .allMatches(value.toLowerCase())
        .map((match) => match.group(0)!)
        .toList();
    if (words.any(_vietnameseWords.contains)) return false;
    if (words.any(_englishWords.contains)) return true;
    // Vietnamese normally carries either a diacritic or a recognizable word.
    // Preserve a compact title-cased name such as "Truong Vo Ky", but retry an
    // unmarked multi-word sentence rather than caching English as Vietnamese.
    return words.length > 1 && !_looksLikeTitleCasedName(value, words.length);
  }

  static bool _looksLikeTitleCasedName(String value, int wordCount) {
    if (wordCount > 4 || !RegExp(r'^[A-Za-z .\-]+$').hasMatch(value)) {
      return false;
    }
    return RegExp(r'^[A-Z][a-z]*(?:[ .-]+[A-Z][a-z]*)+$').hasMatch(value);
  }
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
    this.targetLanguage,
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
  final String? targetLanguage;
  final List<String> _texts;
  final Set<int> _pending = {};
  final Set<int> _completedChunks = {};
  final Set<int> _failedChunkIndexes = {};
  int positionSeconds;
  bool _cancelled = false;
  int _processedCues = 0;
  int _translatedCues = 0;
  bool _cacheChecked = false;
  bool _cacheHit = false;
  Timer? _refresh;
  DateTime? _lastEmitAt;
  Future<void> _checkpointTail = Future.value();

  int get total => (cues.length + chunkSize - 1) ~/ chunkSize;

  static String cacheIdentity(String cacheKey, List<SubtitleCue> cues) {
    final source = cues
        .map((cue) => '${cue.start}/${cue.end}/${cue.text}')
        .join(
          '\n',
        );
    return sha256.convert(utf8.encode('$cacheKey\n$source')).toString();
  }

  void cancel() {
    _cancelled = true;
    _refresh?.cancel();
  }

  void setPosition(int seconds) => positionSeconds = seconds;

  /// Publish the original cues before the first translation result arrives.
  /// This keeps the player on a valid subtitle track and gives the UI an
  /// immediate, observable "starting" state for a long-running request.
  void emitCurrent() {
    if (_cancelled || cues.isEmpty) return;
    _emit();
  }

  Future<bool> loadCached() async {
    if (_cacheChecked) return _cacheHit;
    _cacheChecked = true;
    final file = _cacheFile;
    try {
      if (!await file.exists()) return false;
      final data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      // Make a writable copy: valid legacy entries can be normalized below
      // and then saved back without forcing a new translation request.
      final lines = List<String>.from((data['texts'] as List).cast<String>());
      if (lines.length != cues.length || _cancelled) return false;
      final completed = data['completedChunks'] is List
          ? (data['completedChunks'] as List)
                .whereType<num>()
                .map((value) => value.toInt())
                .where((index) => index >= 0 && index < total)
                .toSet()
          : <int>{};
      final isComplete =
          data['complete'] == true ||
          (completed.isEmpty &&
              List.generate(total, (index) => index).every(
                (index) => _normalizedCachedChunk(index, lines) != null,
              ));
      if (isComplete) {
        completed
          ..clear()
          ..addAll(List.generate(total, (index) => index));
      }
      if (completed.isEmpty) {
        return false;
      }
      var normalizedLegacyCache = false;
      for (final index in completed) {
        final normalized = _normalizedCachedChunk(index, lines);
        if (normalized == null) return false;
        final start = index * chunkSize;
        for (var offset = 0; offset < normalized.length; offset++) {
          if (lines[start + offset] != normalized[offset]) {
            normalizedLegacyCache = true;
          }
        }
        lines.setRange(start, start + normalized.length, normalized);
      }
      _texts.setAll(0, lines);
      _completedChunks
        ..clear()
        ..addAll(completed);
      _failedChunkIndexes
        ..clear()
        ..addAll(
          data['failedChunks'] is List
              ? (data['failedChunks'] as List)
                    .whereType<num>()
                    .map((value) => value.toInt())
                    .where(
                      (index) =>
                          index >= 0 &&
                          index < total &&
                          !_completedChunks.contains(index),
                    )
              : const <int>[],
        );
      _translatedCues = _cueCount(_completedChunks);
      _processedCues = _translatedCues + _cueCount(_failedChunkIndexes);
      _cacheHit = _completedChunks.length == total;
      _emit();
      if (normalizedLegacyCache) {
        // Older releases may have stored model-echoed batch labels such as
        // "1. Xin chao". Keep the completed translation and repair the
        // durable file in place, rather than discarding it and retranslating.
        _saveCheckpoint();
        await _checkpointTail;
      }
      return _cacheHit;
    } catch (_) {
      return false;
    }
  }

  Future<void> run() async {
    if (cues.isEmpty || _cancelled || await loadCached()) return;
    _pending.addAll(
      List.generate(
        total,
        (index) => index,
      ).where((index) => !_completedChunks.contains(index)),
    );
    await Future.wait(List.generate(concurrency, (_) => _worker()));
    _refresh?.cancel();
    if (_cancelled) return;
    await _checkpointTail;
    _emit();
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
        _completedChunks.add(next);
        _failedChunkIndexes.remove(next);
        _translatedCues = _cueCount(_completedChunks);
      } catch (_) {
        if (_cancelled) return;
        _failedChunkIndexes.add(next);
      }
      _processedCues = _translatedCues + _cueCount(_failedChunkIndexes);
      _saveCheckpoint();
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
        return SubtitleTranslationOutput.sanitizeAndValidate(
          source,
          result,
          targetLanguage: targetLanguage,
        );
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
        completedChunks: _completedChunks.length,
        totalChunks: total,
        processedCues: _processedCues,
        translatedCues: _translatedCues,
        totalCues: cues.length,
        failedChunks: _failedChunkIndexes.length,
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

  List<String>? _normalizedCachedChunk(int index, List<String> texts) {
    final start = index * chunkSize;
    final end = min(start + chunkSize, cues.length);
    final source = cues.sublist(start, end).map((cue) => cue.text).toList();
    final cached = texts.sublist(start, end);
    try {
      return SubtitleTranslationOutput.sanitizeAndValidate(
        source,
        cached,
        targetLanguage: targetLanguage,
      );
    } on FormatException {
      return null;
    }
  }

  int _cueCount(Iterable<int> indexes) => indexes.fold(
    0,
    (count, index) => count + min(chunkSize, cues.length - index * chunkSize),
  );

  void _saveCheckpoint() {
    if (_cancelled) return;
    _checkpointTail = _checkpointTail.then((_) async {
      if (_cancelled) return;
      try {
        final file = _cacheFile;
        await file.parent.create(recursive: true);
        if (_cancelled) return;
        final complete = _completedChunks.length == total;
        final payload = <String, Object>{
          'version': 2,
          'complete': complete,
          'texts': List<String>.from(_texts),
          'completedChunks': _completedChunks.toList()..sort(),
          'failedChunks': _failedChunkIndexes.toList()..sort(),
        };
        final temp = File(
          '${file.path}.${identityHashCode(this)}.'
          '${DateTime.now().microsecondsSinceEpoch}.tmp',
        );
        await temp.writeAsString(jsonEncode(payload));
        if (_cancelled) {
          if (await temp.exists()) await temp.delete();
          return;
        }
        await temp.rename(file.path);
      } catch (_) {
        // Playback and a later retry do not depend on checkpoint storage.
      }
    });
  }

  File get _cacheFile {
    final hash = cacheIdentity(cacheKey, cues);
    return File(
      path.join(
        cacheDirectory ?? path.join(appSupportDirPath, 'subtitle_translations'),
        '$hash.json',
      ),
    );
  }
}
