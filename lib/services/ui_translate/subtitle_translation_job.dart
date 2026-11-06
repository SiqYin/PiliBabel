import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show max, min;

import 'package:PiliPlus/services/ui_translate/subtitle_text_quality.dart';
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

enum SubtitleTranslationPhase { translating, verifying, ready }

class SubtitleTranslationProgress {
  const SubtitleTranslationProgress({
    required this.phase,
    required this.completedChunks,
    required this.totalChunks,
    required this.processedCues,
    required this.translatedCues,
    required this.verifiedCues,
    required this.totalCues,
    required this.failedChunks,
    required this.currentPositionCovered,
    required this.coverageAheadSeconds,
    required this.remainingTimelineCovered,
    required this.renderRevision,
    required this.renderedChunks,
    this.retryExhausted = false,
    this.retryAttempt = 0,
  });

  final SubtitleTranslationPhase phase;
  final int completedChunks;
  final int totalChunks;
  final int processedCues;
  final int translatedCues;
  final int verifiedCues;
  final int totalCues;
  final int failedChunks;
  final bool currentPositionCovered;
  final double coverageAheadSeconds;
  final bool remainingTimelineCovered;
  final int renderRevision;
  final List<int> renderedChunks;
  final bool retryExhausted;
  final int retryAttempt;

  bool get isComplete => phase == SubtitleTranslationPhase.ready;

  double get ratio => totalCues == 0 ? 0 : translatedCues / totalCues;

  SubtitleTranslationProgress copyWith({
    bool? retryExhausted,
    int? retryAttempt,
  }) => SubtitleTranslationProgress(
    phase: phase,
    completedChunks: completedChunks,
    totalChunks: totalChunks,
    processedCues: processedCues,
    translatedCues: translatedCues,
    verifiedCues: verifiedCues,
    totalCues: totalCues,
    failedChunks: failedChunks,
    currentPositionCovered: currentPositionCovered,
    coverageAheadSeconds: coverageAheadSeconds,
    remainingTimelineCovered: remainingTimelineCovered,
    renderRevision: renderRevision,
    renderedChunks: renderedChunks,
    retryExhausted: retryExhausted ?? this.retryExhausted,
    retryAttempt: retryAttempt ?? this.retryAttempt,
  );
}

abstract final class SubtitleRealtimeBufferPolicy {
  static const double resumeAheadSeconds = 60;
  static const double pauseAheadSeconds = 15;

  static bool canStart(SubtitleTranslationProgress progress) =>
      progress.currentPositionCovered &&
      (progress.coverageAheadSeconds >= resumeAheadSeconds ||
          progress.remainingTimelineCovered);

  static bool shouldPause(SubtitleTranslationProgress progress) =>
      !progress.currentPositionCovered ||
      (!progress.remainingTimelineCovered &&
          progress.coverageAheadSeconds < pauseAheadSeconds);

  static bool shouldBlockPlayback(
    SubtitleTranslationProgress progress, {
    required bool waitForComplete,
    required bool autoPauseForBuffer,
    required bool translatedTrackSelected,
  }) {
    if (progress.isComplete || progress.retryExhausted) return false;
    if (waitForComplete) return true;
    if (!autoPauseForBuffer) return false;
    return translatedTrackSelected
        ? shouldPause(progress)
        : !canStart(progress);
  }
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
  static final RegExp _vietnameseMarks = RegExp(r'[À-ỹĐđ]');
  static final RegExp _latinWords = RegExp(r'[A-Za-z]+');
  static final RegExp _contextWordSeparator = RegExp(
    r'[^0-9A-Za-zÀ-ỹĐđ]+',
  );
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
    List<String> sourceContext = const [],
    List<String> translatedContext = const [],
  }) {
    if (source.length != output.length) {
      throw const FormatException('Subtitle line count changed');
    }
    final normalized = [
      for (var i = 0; i < output.length; i++)
        _validateLine(
          source: source[i],
          output: output[i],
          ordinal: i + 1,
          targetLanguage: targetLanguage,
        ),
    ];
    _rejectCopiedSource(source, normalized, targetLanguage);
    _rejectMergedContext(
      source: source,
      output: normalized,
      sourceContext: sourceContext,
      translatedContext: translatedContext,
    );
    return normalized;
  }

  /// A completed Vietnamese artifact must preserve every source cue while
  /// passing the same per-line quality checks used during chunk translation.
  static bool isCompleteVietnameseVtt(
    List<SubtitleCue> source,
    String renderedVtt,
  ) => isCompleteTranslatedVtt(
    source,
    renderedVtt,
    targetLanguage: 'vi',
  );

  static bool isCompleteTranslatedVtt(
    List<SubtitleCue> source,
    String renderedVtt, {
    required String targetLanguage,
  }) {
    final rendered = SubtitleCues.fromVtt(renderedVtt);
    if (rendered.length != source.length ||
        !SubtitleCues.hasSameTimeline(source, renderedVtt)) {
      return false;
    }
    try {
      sanitizeAndValidate(
        source.map((cue) => cue.text).toList(growable: false),
        rendered.map((cue) => cue.text).toList(growable: false),
        targetLanguage: targetLanguage,
      );
      return true;
    } on FormatException {
      return false;
    }
  }

  /// 目标语言是否属于中文家族（简繁/粤语/吴语/闽南语）。
  ///
  /// 这些目标本来就该有大量行与原文一字不差（「好的」→「好的」），
  /// 任何「照抄」判定都必须豁免，否则整条轨必挂。
  static bool _isChineseFamilyTarget(String? targetLanguage) {
    final target = (targetLanguage ?? '').toLowerCase();
    return target.startsWith('zh') ||
        target.startsWith('yue') ||
        target.startsWith('wuw') ||
        target.startsWith('nan');
  }

  /// 整块级别的「模型根本没翻」判定。
  ///
  /// 判据：带汉字的行里 80% 以上与原文一字不差，且至少 2 行。
  /// 单行块不判（「了解」→「了解」这种合法情况无法区分）。
  static void _rejectCopiedSource(
    List<String> source,
    List<String> output,
    String? targetLanguage,
  ) {
    if (_isChineseFamilyTarget(targetLanguage)) return;
    var hanLines = 0;
    var copied = 0;
    for (var i = 0; i < source.length && i < output.length; i++) {
      if (!SubtitleTextQuality.containsHan(source[i])) continue;
      hanLines++;
      if (output[i] == source[i].trim()) copied++;
    }
    if (hanLines >= 2 && copied >= (hanLines * 0.8).ceil()) {
      throw const FormatException('Subtitle translation copied source');
    }
  }

  static void _rejectMergedContext({
    required List<String> source,
    required List<String> output,
    required List<String> sourceContext,
    required List<String> translatedContext,
  }) {
    if (translatedContext.isEmpty) return;
    final contexts =
        <({String? source, String translated, List<String> words})>[];
    final sourceOffset = sourceContext.length - translatedContext.length;
    for (var index = 0; index < translatedContext.length; index++) {
      final sourceIndex = sourceOffset + index;
      contexts.add((
        source: sourceIndex >= 0 && sourceIndex < sourceContext.length
            ? sourceContext[sourceIndex]
            : null,
        translated: translatedContext[index],
        words: _contextWords(translatedContext[index]),
      ));
    }
    for (var outputIndex = 0; outputIndex < output.length; outputIndex++) {
      final line = output[outputIndex];
      final words = _contextWords(line);
      for (final context in contexts) {
        final contextWords = context.words;
        if (contextWords.isEmpty) continue;
        final exact =
            words.length == contextWords.length &&
            _sameWords(words, 0, contextWords);
        // A model can preserve the JSON array length by replacing the current
        // cue with one translated context cue. Catch distinctive sentences,
        // but allow short natural repeats such as "Vâng" or "Được".
        if (exact &&
            context.source != null &&
            _isDistinctiveContext(contextWords) &&
            !_sameSourceCue(source[outputIndex], context.source!)) {
          throw const FormatException(
            'Subtitle translation replaced a cue with overlap context',
          );
        }
        if (contextWords.length < 2 || words.length <= contextWords.length) {
          continue;
        }
        final prefix = _sameWords(words, 0, contextWords);
        final suffix = _sameWords(
          words,
          words.length - contextWords.length,
          contextWords,
        );
        if (!prefix && !suffix) continue;
        final extraWords = words.length - contextWords.length;
        // A two-word context such as "xin chào" is only considered an echo
        // when the model also appended a meaningful sentence. Longer context
        // lines need less extra text to prove that two cues were merged.
        if ((contextWords.length == 2 && extraWords >= 3) ||
            (contextWords.length >= 3 && extraWords >= 2)) {
          throw const FormatException(
            'Subtitle translation repeated an overlap context cue',
          );
        }
      }
    }
    _rejectContextSequence(source, output, contexts);
  }

  static void _rejectContextSequence(
    List<String> source,
    List<String> output,
    List<({String? source, String translated, List<String> words})> contexts,
  ) {
    if (contexts.length < 2 || output.length < 2) return;
    for (var outputStart = 0; outputStart < output.length - 1; outputStart++) {
      for (
        var contextStart = 0;
        contextStart < contexts.length - 1;
        contextStart++
      ) {
        var matched = 0;
        var matchedWords = 0;
        var sourceMatches = true;
        while (outputStart + matched < output.length &&
            contextStart + matched < contexts.length &&
            _sameTranslatedCue(
              output[outputStart + matched],
              contexts[contextStart + matched].translated,
            )) {
          final context = contexts[contextStart + matched];
          matchedWords += context.words.length;
          sourceMatches =
              sourceMatches &&
              context.source != null &&
              _sameSourceCue(
                source[outputStart + matched],
                context.source!,
              );
          matched++;
        }
        // Two or more context elements replacing current cues are strong
        // evidence even when each element is too short to judge alone.
        if (matched >= 2 && matchedWords >= 4 && !sourceMatches) {
          throw const FormatException(
            'Subtitle translation repeated overlap context elements',
          );
        }
      }
    }
  }

  static bool _isDistinctiveContext(List<String> words) =>
      words.length >= 4 || (words.length >= 3 && words.join().length >= 12);

  static bool _sameTranslatedCue(String value, String expected) {
    final valueWords = _contextWords(value);
    final expectedWords = _contextWords(expected);
    return valueWords.length == expectedWords.length &&
        _sameWords(valueWords, 0, expectedWords);
  }

  static bool _sameSourceCue(String value, String expected) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ') ==
      expected.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static List<String> _contextWords(String value) => value
      .toLowerCase()
      .split(_contextWordSeparator)
      .where((word) => word.isNotEmpty)
      .toList(growable: false);

  static bool _sameWords(
    List<String> value,
    int offset,
    List<String> expected,
  ) {
    for (var i = 0; i < expected.length; i++) {
      if (value[offset + i] != expected[i]) return false;
    }
    return true;
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
    if (!source.contains('\n') && normalized.contains('\n')) {
      throw const FormatException('Subtitle translation merged extra lines');
    }
    if (normalized.contains('CONTEXT_ONLY_JSON') ||
        normalized.contains('TRANSLATE_ONLY_JSON')) {
      throw const FormatException('Subtitle translation echoed prompt data');
    }
    final sourceHasHan = SubtitleTextQuality.containsHan(source);
    // 逐行「和原文一样」不能判死：簡體→繁體、中文→日文（汉字词）、
    // 以及人名/数字行，本来就有大量行译文与原文完全相同。以前这里逐行抛异常，
    // 中文家族目标（繁中/粤语/吴语/闽南语）几乎每一块都会挂 → 整片永远翻不出来。
    // 「模型整体拒绝翻译」改在 _rejectCopiedSource 里按块判定。
    if (targetLanguage?.toLowerCase().startsWith('vi') == true &&
        SubtitleTextQuality.containsHan(normalized)) {
      throw const FormatException(
        'Vietnamese subtitle still contains untranslated Chinese text',
      );
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
          (item['content'] as String).trim().isNotEmpty &&
          // 丢掉零长度/倒序的坏 cue：hasSafePlaybackTimeline 是「整条轨」判定，
          // 一条坏 cue 会让整条字幕被判不可用（界面表现为「没有可用字幕」）。
          (item['to'] as num) > (item['from'] as num))
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

  static String toVttSubset(
    List<SubtitleCue> cues,
    List<String> texts,
    Iterable<int> cueIndexes,
  ) {
    final indexes = cueIndexes.toSet().toList()..sort();
    final out = StringBuffer('WEBVTT\n\n');
    for (final index in indexes) {
      if (index < 0 || index >= cues.length || index >= texts.length) {
        throw RangeError.index(index, cues, 'cueIndexes');
      }
      out
        ..writeln('${cues[index].start} --> ${cues[index].end}')
        ..writeln(texts[index])
        ..writeln();
    }
    return out.toString();
  }

  /// A translation may change only cue text. Rejecting a mismatched rendered
  /// VTT prevents a stale or malformed update from collapsing playback times.
  static bool hasSameTimeline(List<SubtitleCue> source, String renderedVtt) {
    final rendered = fromVtt(renderedVtt);
    if (source.length != rendered.length) return false;
    for (var i = 0; i < source.length; i++) {
      if (source[i].start != rendered[i].start ||
          source[i].end != rendered[i].end) {
        return false;
      }
    }
    return true;
  }

  /// Realtime output may omit untranslated chunks, but every rendered cue
  /// must remain an ordered, unique member of the source timeline.
  static bool hasTimelineSubset(
    List<SubtitleCue> source,
    String renderedVtt,
  ) {
    if (!renderedVtt.trimLeft().startsWith('WEBVTT')) return false;
    final rendered = fromVtt(renderedVtt);
    if (RegExp(r' --> ').allMatches(renderedVtt).length != rendered.length) {
      return false;
    }
    var sourceIndex = 0;
    for (final cue in rendered) {
      var matched = false;
      while (sourceIndex < source.length) {
        final candidate = source[sourceIndex++];
        if (candidate.start == cue.start && candidate.end == cue.end) {
          matched = true;
          break;
        }
      }
      if (!matched) return false;
    }
    return true;
  }

  /// Some AI-generated Bilibili tracks contain repeated or invalid ranges.
  /// mpv renders every overlapping cue at once, then has nothing left later.
  /// Do not retime source dialogue: callers can select a healthy source track.
  static bool hasSafePlaybackTimeline(List<SubtitleCue> cues) {
    if (cues.isEmpty) return false;
    final events = <({double time, int delta})>[];
    for (final cue in cues) {
      final start = _seconds(cue.start);
      final end = _seconds(cue.end);
      if (start == null || end == null || start < 0 || end <= start) {
        return false;
      }
      events
        ..add((time: start, delta: 1))
        ..add((time: end, delta: -1));
    }
    // End events must be processed first: WebVTT cue ends are exclusive.
    events.sort(
      (a, b) => a.time != b.time
          ? a.time.compareTo(b.time)
          : a.delta.compareTo(b.delta),
    );
    var active = 0;
    for (final event in events) {
      active += event.delta;
      // Three simultaneous cues remain usable for exceptional dialogue; four
      // or more produces the stacked subtitles seen with malformed AI tracks.
      if (active > 3 || active < 0) return false;
    }
    return active == 0;
  }

  static double? _seconds(String timestamp) {
    final parts = timestamp.replaceAll(',', '.').split(':');
    if (parts.length != 3) return null;
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    final seconds = double.tryParse(parts[2]);
    if (hours == null || minutes == null || seconds == null || minutes > 59) {
      return null;
    }
    return hours * 3600 + minutes * 60 + seconds;
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
    this.attemptTimeout = const Duration(seconds: 60),
    this.maxRetries = 2,
    this.contextOverlap = 4,
    this.targetLanguage,
  }) : assert(maxRetries >= 0),
       _texts = cues.map((cue) => cue.text).toList();

  final List<SubtitleCue> cues;
  final int chunkSize;
  final int concurrency;
  final SubtitleChunkTranslator translate;
  final SubtitleChunkTranslatorWithContext? translateWithContext;
  final String cacheKey;
  final String? cacheDirectory;
  final SubtitleTranslationUpdate onUpdate;
  final Duration retryDelay;
  final Duration attemptTimeout;
  final int maxRetries;
  final int contextOverlap;
  final String? targetLanguage;
  final List<String> _texts;
  final Set<int> _pending = {};
  final Set<int> _completedChunks = {};
  final Map<int, List<String>> _provisionalChunks = {};
  final Set<int> _failedChunkIndexes = {};
  int positionSeconds;
  bool _cancelled = false;
  int _processedCues = 0;
  int _translatedCues = 0;
  bool _cacheChecked = false;
  bool _cacheHit = false;
  SubtitleTranslationPhase _phase = SubtitleTranslationPhase.translating;
  int _verifiedCues = 0;
  Timer? _refresh;
  DateTime? _lastEmitAt;
  String? _lastRenderedVtt;
  int _renderRevision = 0;
  Future<void> _checkpointTail = Future.value();

  int get total => (cues.length + chunkSize - 1) ~/ chunkSize;

  /// 最近一次分块翻译失败的真实原因（接口错误、校验不通过等）。
  ///
  /// 只用于把失败原因显示给用户/写进日志：以前所有异常都在 `_worker` 里被吞掉，
  /// 上层只知道「N 个分块出错」，不知道是 401、超时还是校验拒绝。
  Object? get lastError => _lastError;
  Object? _lastError;

  static String cacheIdentity(String cacheKey, List<SubtitleCue> cues) {
    final source = cues
        .map((cue) => '${cue.start}/${cue.end}/${cue.text}')
        .join(
          '\n',
        );
    return sha256.convert(utf8.encode('$cacheKey\n$source')).toString();
  }

  /// Resolves the durable checkpoint for a source track.  Kept public so a
  /// deliberate retranslation can prepare a replacement without deleting the
  /// currently playable cache first.
  static File cacheFileFor(
    String cacheKey,
    List<SubtitleCue> cues, {
    String? cacheDirectory,
  }) => File(
    path.join(
      cacheDirectory ?? path.join(appSupportDirPath, 'subtitle_translations'),
      '${cacheIdentity(cacheKey, cues)}.json',
    ),
  );

  void cancel() {
    _cancelled = true;
    _refresh?.cancel();
  }

  void setPosition(int seconds) {
    if (_cancelled || seconds == positionSeconds) return;
    positionSeconds = seconds;
    // Position updates change buffer readiness and queue priority, but they do
    // not rebuild the VTT or advance renderRevision.
    _scheduleEmit();
  }

  /// Publish an empty Vietnamese track before the first valid chunk arrives.
  /// Source Chinese is never copied into realtime translated output.
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
      final provisional = data['provisionalChunks'] is List
          ? (data['provisionalChunks'] as List)
                .whereType<num>()
                .map((value) => value.toInt())
                .where((index) => index >= 0 && index < total)
                .toSet()
          : <int>{};
      final declaredComplete =
          data['complete'] == true ||
          (completed.isEmpty &&
              List.generate(total, (index) => index).every(
                (index) => _normalizedCachedChunk(index, lines) != null,
              ));
      if (declaredComplete) {
        completed
          ..clear()
          ..addAll(List.generate(total, (index) => index));
        provisional.clear();
      }
      if (completed.isEmpty && provisional.isEmpty) {
        return false;
      }
      var normalizedLegacyCache = false;
      final invalidCompleted = <int>{};
      final candidates = {...completed, ...provisional}.toList()..sort();
      _texts.setAll(0, cues.map((cue) => cue.text));
      _completedChunks.clear();
      _provisionalChunks.clear();
      for (final index in candidates) {
        final start = index * chunkSize;
        final end = min(start + chunkSize, cues.length);
        final candidate = lines.sublist(start, end);
        final contextStart = max(0, start - contextOverlap);
        final source = cues.sublist(start, end).map((cue) => cue.text).toList();
        final context = cues
            .sublist(contextStart, start)
            .map((cue) => cue.text)
            .toList();
        final translatedContext = _completeTranslatedContext(
          contextStart,
          start,
        );
        if (context.isNotEmpty && translatedContext == null) {
          _texts.setRange(start, end, candidate);
          _provisionalChunks[index] = List<String>.from(candidate);
          continue;
        }
        List<String>? normalized;
        try {
          normalized = SubtitleTranslationOutput.sanitizeAndValidate(
            source,
            candidate,
            targetLanguage: targetLanguage,
            sourceContext: context,
            translatedContext: translatedContext ?? const <String>[],
          );
        } on FormatException {
          normalized = null;
        }
        if (normalized == null) {
          invalidCompleted.add(index);
          lines.setRange(
            start,
            end,
            cues.sublist(start, end).map((cue) => cue.text),
          );
          continue;
        }
        for (var offset = 0; offset < normalized.length; offset++) {
          if (lines[start + offset] != normalized[offset]) {
            normalizedLegacyCache = true;
          }
        }
        lines.setRange(start, start + normalized.length, normalized);
        _texts.setRange(start, start + normalized.length, normalized);
        _completedChunks.add(index);
      }
      if (_completedChunks.isEmpty && _provisionalChunks.isEmpty) return false;
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
                          !_completedChunks.contains(index) &&
                          !_provisionalChunks.containsKey(index),
                    )
              : const <int>[],
        );
      _failedChunkIndexes.addAll(invalidCompleted);
      _translatedCues = _cueCount(_completedChunks);
      _processedCues = _translatedCues + _cueCount(_failedChunkIndexes);
      _phase = SubtitleTranslationPhase.translating;
      _verifiedCues = 0;
      _emit();
      if (_completedChunks.length == total && _failedChunkIndexes.isEmpty) {
        _cacheHit = await _verifyAndFinalize();
        return _cacheHit;
      }
      if (normalizedLegacyCache ||
          declaredComplete ||
          invalidCompleted.isNotEmpty ||
          _provisionalChunks.isNotEmpty) {
        // Older releases may have stored model-echoed batch labels such as
        // "1. Xin chao". Keep the completed translation and repair the
        // durable file in place, rather than discarding it and retranslating.
        _saveCheckpoint();
        await _checkpointTail;
      }
      return false;
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
      ).where(
        (index) =>
            !_completedChunks.contains(index) &&
            !_provisionalChunks.containsKey(index),
      ),
    );
    do {
      await Future.wait(List.generate(concurrency, (_) => _worker()));
      await _repairMergedContextChunks();
    } while (_pending.isNotEmpty && !_cancelled);
    _refresh?.cancel();
    if (_cancelled) return;
    await _checkpointTail;
    if (_completedChunks.length == total && _failedChunkIndexes.isEmpty) {
      await _verifyAndFinalize();
    } else {
      _phase = SubtitleTranslationPhase.translating;
      _verifiedCues = 0;
      _emit();
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
      final translatedContext = _completeTranslatedContext(
        contextStart,
        start,
      );
      try {
        final result = await _translateWithRetry(
          source,
          context,
          translatedContext ?? const <String>[],
        );
        if (_cancelled) return;
        if (context.isNotEmpty && translatedContext == null) {
          // Keep an out-of-order result hidden until every overlap cue has a
          // validated translation. Otherwise a context echo can briefly leak
          // into the realtime Vietnamese track before the later repair pass.
          _texts.setRange(start, end, result);
          _provisionalChunks[next] = List<String>.from(result);
          _failedChunkIndexes.remove(next);
        } else {
          _acceptChunk(next, result);
        }
        _promoteProvisionalChunks();
        _translatedCues = _cueCount(_completedChunks);
      } catch (error) {
        if (_cancelled) return;
        _lastError = error;
        _provisionalChunks.remove(next);
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
    List<String> translatedContext,
  ) async {
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final request =
            translateWithContext?.call(source, context) ?? translate(source);
        final result = attemptTimeout > Duration.zero
            ? await request.timeout(attemptTimeout)
            : await request;
        return SubtitleTranslationOutput.sanitizeAndValidate(
          source,
          result,
          targetLanguage: targetLanguage,
          sourceContext: context,
          translatedContext: translatedContext,
        );
      } catch (error, stackTrace) {
        // Local state changes cannot be fixed by retrying and must stop work.
        if (_cancelled || error is StateError || attempt == maxRetries) {
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

  List<String>? _completeTranslatedContext(int start, int end) {
    if (start >= end) return const <String>[];
    for (var index = start; index < end; index++) {
      if (!_completedChunks.contains(index ~/ chunkSize)) return null;
    }
    return _texts.sublist(start, end);
  }

  void _acceptChunk(int index, List<String> translated) {
    final start = index * chunkSize;
    final end = min(start + chunkSize, cues.length);
    _texts.setRange(start, end, translated);
    _provisionalChunks.remove(index);
    _completedChunks.add(index);
    _failedChunkIndexes.remove(index);
  }

  void _promoteProvisionalChunks() {
    var changed = true;
    while (changed && !_cancelled) {
      changed = false;
      final candidates = _provisionalChunks.keys.toList()..sort();
      for (final chunk in candidates) {
        final start = chunk * chunkSize;
        final end = min(start + chunkSize, cues.length);
        final contextStart = max(0, start - contextOverlap);
        final translatedContext = _completeTranslatedContext(
          contextStart,
          start,
        );
        if (translatedContext == null) continue;
        final source = cues.sublist(start, end).map((cue) => cue.text).toList();
        final context = cues
            .sublist(contextStart, start)
            .map((cue) => cue.text)
            .toList();
        final candidate = _provisionalChunks[chunk]!;
        try {
          final normalized = SubtitleTranslationOutput.sanitizeAndValidate(
            source,
            candidate,
            targetLanguage: targetLanguage,
            sourceContext: context,
            translatedContext: translatedContext,
          );
          _acceptChunk(chunk, normalized);
        } on FormatException {
          _provisionalChunks.remove(chunk);
          _texts.setRange(start, end, source);
          // Retry only this chunk now that the translated overlap context is
          // available. Existing workers will pick it up without duplicating
          // requests or hiding already validated chunks.
          _pending.add(chunk);
          _failedChunkIndexes.remove(chunk);
        }
        changed = true;
      }
    }
  }

  Future<void> _repairMergedContextChunks() async {
    if (_cancelled || contextOverlap <= 0) return;
    // Parallel workers can finish a later chunk before its preceding chunk,
    // so translated context may not exist during the first validation. Check
    // completed boundaries once all workers settle and retry only polluted
    // chunks, in order, while their clean preceding translations are known.
    for (var chunk = 1; chunk < total && !_cancelled; chunk++) {
      if (!_completedChunks.contains(chunk)) continue;
      final start = chunk * chunkSize;
      final end = min(start + chunkSize, cues.length);
      final contextStart = max(0, start - contextOverlap);
      final source = cues.sublist(start, end).map((cue) => cue.text).toList();
      final context = cues
          .sublist(contextStart, start)
          .map((cue) => cue.text)
          .toList();
      final translatedContext = _completeTranslatedContext(
        contextStart,
        start,
      );
      if (translatedContext == null) {
        _completedChunks.remove(chunk);
        _provisionalChunks[chunk] = _texts.sublist(start, end);
        _translatedCues = _cueCount(_completedChunks);
        _processedCues = _translatedCues + _cueCount(_failedChunkIndexes);
        _saveCheckpoint();
        _emit();
        continue;
      }
      try {
        SubtitleTranslationOutput.sanitizeAndValidate(
          source,
          _texts.sublist(start, end),
          targetLanguage: targetLanguage,
          sourceContext: context,
          translatedContext: translatedContext,
        );
        continue;
      } on FormatException {
        _completedChunks.remove(chunk);
        _texts.setRange(start, end, source);
        _translatedCues = _cueCount(_completedChunks);
        _processedCues = _translatedCues + _cueCount(_failedChunkIndexes);
        _saveCheckpoint();
        // Remove the invalid chunk from the live Vietnamese track before its
        // retry starts. It must never fall back to source Chinese or keep a
        // known context-polluted cue visible during repair.
        _refresh?.cancel();
        _refresh = null;
        _emit();
      }
      try {
        final repaired = await _translateWithRetry(
          source,
          context,
          translatedContext,
        );
        if (_cancelled) return;
        _acceptChunk(chunk, repaired);
        _promoteProvisionalChunks();
      } catch (_) {
        if (_cancelled) return;
        _failedChunkIndexes.add(chunk);
      }
      _translatedCues = _cueCount(_completedChunks);
      _processedCues = _translatedCues + _cueCount(_failedChunkIndexes);
      _saveCheckpoint();
      _scheduleEmit();
    }
  }

  int _nearestPending() {
    var best = _pending.first;
    var bestBand = 5;
    var bestDistance = double.infinity;
    final playbackCue = _cueIndexAtOrAfter(positionSeconds.toDouble());
    final playbackChunk = playbackCue == null ? null : playbackCue ~/ chunkSize;
    final contextStartChunk = playbackChunk == null
        ? null
        : max(0, playbackChunk * chunkSize - contextOverlap) ~/ chunkSize;
    for (final index in _pending) {
      final startIndex = index * chunkSize;
      final endIndex = min(startIndex + chunkSize, cues.length) - 1;
      final start = _seconds(cues[startIndex].start);
      final end = _seconds(cues[endIndex].end);
      final lookaheadEnd =
          positionSeconds + SubtitleRealtimeBufferPolicy.resumeAheadSeconds;
      final isContextDependency =
          playbackChunk != null &&
          contextStartChunk != null &&
          index >= contextStartChunk &&
          index < playbackChunk;
      final (band, distance) = switch (positionSeconds) {
        // Translate the overlap dependency first so the playing chunk can be
        // validated and exposed as soon as its parallel request returns.
        _ when isContextDependency => (0, index.toDouble()),
        _ when playbackChunk != null && index == playbackChunk => (1, 0.0),
        final position when start >= position && start < lookaheadEnd => (
          2,
          start - position,
        ),
        final position when position < start => (3, start - position),
        final position => (4, position - end),
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

  int? _cueIndexAtOrAfter(double position) {
    for (var index = 0; index < cues.length; index++) {
      final start = _seconds(cues[index].start);
      final end = _seconds(cues[index].end);
      if ((position >= start && position < end) || start >= position) {
        return index;
      }
    }
    return null;
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
    final renderedChunks = _completedChunks.toList()..sort();
    final cueIndexes = <int>[
      for (final chunk in renderedChunks)
        for (
          var index = chunk * chunkSize;
          index < min((chunk + 1) * chunkSize, cues.length);
          index++
        )
          index,
    ];
    final renderedVtt = SubtitleCues.toVttSubset(cues, _texts, cueIndexes);
    if (renderedVtt != _lastRenderedVtt) {
      _lastRenderedVtt = renderedVtt;
      _renderRevision++;
    }
    final coverage = _coverageAtPosition();
    onUpdate(
      renderedVtt,
      SubtitleTranslationProgress(
        phase: _phase,
        completedChunks: _completedChunks.length,
        totalChunks: total,
        processedCues: _processedCues,
        translatedCues: _translatedCues,
        verifiedCues: _verifiedCues,
        totalCues: cues.length,
        failedChunks: _failedChunkIndexes.length,
        currentPositionCovered: coverage.currentPositionCovered,
        coverageAheadSeconds: coverage.coverageAheadSeconds,
        remainingTimelineCovered: coverage.remainingTimelineCovered,
        renderRevision: _renderRevision,
        renderedChunks: List.unmodifiable(renderedChunks),
      ),
    );
  }

  ({
    bool currentPositionCovered,
    double coverageAheadSeconds,
    bool remainingTimelineCovered,
  })
  _coverageAtPosition() {
    if (cues.isEmpty) {
      return (
        currentPositionCovered: false,
        coverageAheadSeconds: 0,
        remainingTimelineCovered: false,
      );
    }
    final position = positionSeconds.toDouble();
    final cueIndex = _cueIndexAtOrAfter(position);
    // No subtitle cues remain after the playback position, so subtitle
    // buffering must not pause the end of the video.
    if (cueIndex == null) {
      return (
        currentPositionCovered: true,
        coverageAheadSeconds: 0,
        remainingTimelineCovered: true,
      );
    }
    final currentChunk = cueIndex ~/ chunkSize;
    if (!_completedChunks.contains(currentChunk)) {
      return (
        currentPositionCovered: false,
        coverageAheadSeconds: 0,
        remainingTimelineCovered: false,
      );
    }
    var lastChunk = currentChunk;
    while (lastChunk + 1 < total && _completedChunks.contains(lastChunk + 1)) {
      lastChunk++;
    }
    final endCueIndex = min((lastChunk + 1) * chunkSize, cues.length) - 1;
    final coverageEnd = _seconds(cues[endCueIndex].end);
    return (
      currentPositionCovered: true,
      coverageAheadSeconds: max(0, coverageEnd - position),
      remainingTimelineCovered: lastChunk == total - 1,
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
    final contextStart = max(0, start - contextOverlap);
    final sourceContext = cues
        .sublist(contextStart, start)
        .map((cue) => cue.text)
        .toList();
    final translatedContext = texts.sublist(contextStart, start);
    try {
      return SubtitleTranslationOutput.sanitizeAndValidate(
        source,
        cached,
        targetLanguage: targetLanguage,
        sourceContext: sourceContext,
        translatedContext: translatedContext,
      );
    } on FormatException {
      return null;
    }
  }

  int _cueCount(Iterable<int> indexes) => indexes.fold(
    0,
    (count, index) => count + min(chunkSize, cues.length - index * chunkSize),
  );

  Future<bool> _verifyAndFinalize() async {
    if (_cancelled ||
        _completedChunks.length != total ||
        _failedChunkIndexes.isNotEmpty) {
      return false;
    }
    _phase = SubtitleTranslationPhase.verifying;
    _verifiedCues = 0;
    _saveCheckpoint();
    await _checkpointTail;
    if (_cancelled) return false;
    _emit();

    var invalid = await _invalidCheckpointChunks(requireComplete: false);
    if (invalid.isNotEmpty) {
      _reopenInvalidChunks(invalid);
      return false;
    }

    _verifiedCues = cues.length;
    _saveCheckpoint(complete: true);
    await _checkpointTail;
    if (_cancelled) return false;
    invalid = await _invalidCheckpointChunks(requireComplete: true);
    if (invalid.isNotEmpty) {
      _reopenInvalidChunks(invalid);
      return false;
    }

    _phase = SubtitleTranslationPhase.ready;
    _cacheHit = true;
    _emit();
    return true;
  }

  Future<Set<int>> _invalidCheckpointChunks({
    required bool requireComplete,
  }) async {
    final all = List.generate(total, (index) => index).toSet();
    try {
      final data =
          jsonDecode(await _cacheFile.readAsString()) as Map<String, dynamic>;
      if ((data['verifierVersion'] as num?)?.toInt() !=
              SubtitleTextQuality.verifierVersion ||
          (requireComplete && data['complete'] != true)) {
        return all;
      }
      final lines = List<String>.from((data['texts'] as List).cast<String>());
      if (lines.length != cues.length) return all;
      final invalid = <int>{};
      for (var index = 0; index < total; index++) {
        if (_normalizedCachedChunk(index, lines) == null) invalid.add(index);
      }
      if (invalid.isEmpty &&
          !SubtitleTranslationOutput.isCompleteTranslatedVtt(
            cues,
            SubtitleCues.toVtt(cues, lines),
            targetLanguage: targetLanguage ?? '',
          )) {
        return all;
      }
      return invalid;
    } catch (_) {
      return all;
    }
  }

  void _reopenInvalidChunks(Set<int> invalid) {
    for (final index in invalid) {
      final start = index * chunkSize;
      final end = min(start + chunkSize, cues.length);
      _texts.setRange(
        start,
        end,
        cues.sublist(start, end).map((cue) => cue.text),
      );
    }
    _completedChunks.removeAll(invalid);
    for (final index in invalid) {
      _provisionalChunks.remove(index);
    }
    _failedChunkIndexes.addAll(invalid);
    _translatedCues = _cueCount(_completedChunks);
    _processedCues = _translatedCues + _cueCount(_failedChunkIndexes);
    _verifiedCues = 0;
    _phase = SubtitleTranslationPhase.translating;
    _cacheHit = false;
    _saveCheckpoint();
    _emit();
  }

  void _saveCheckpoint({bool complete = false}) {
    if (_cancelled) return;
    _checkpointTail = _checkpointTail.then((_) async {
      if (_cancelled) return;
      try {
        final file = _cacheFile;
        await file.parent.create(recursive: true);
        if (_cancelled) return;
        final payload = <String, Object>{
          'version': 4,
          'verifierVersion': SubtitleTextQuality.verifierVersion,
          'complete': complete,
          'texts': List<String>.from(_texts),
          'completedChunks': _completedChunks.toList()..sort(),
          'provisionalChunks': _provisionalChunks.keys.toList()..sort(),
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

  File get _cacheFile => cacheFileFor(
    cacheKey,
    cues,
    cacheDirectory: cacheDirectory,
  );
}
