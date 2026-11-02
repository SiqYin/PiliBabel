import 'dart:async';
import 'dart:io';

import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';
import 'package:flutter_test/flutter_test.dart';

List<SubtitleCue> _cues(int length) => [
  for (var i = 0; i < length; i++)
    SubtitleCue(
      '00:${(i ~/ 60).toString().padLeft(2, '0')}:${(i % 60).toString().padLeft(2, '0')}.000',
      '00:${((i + 1) ~/ 60).toString().padLeft(2, '0')}:${((i + 1) % 60).toString().padLeft(2, '0')}.000',
      '句$i',
    ),
];

void main() {
  test('round-trips downloaded VTT and Bilibili JSON cue timing', () {
    final cues = SubtitleCues.fromBody([
      {'from': 1.25, 'to': 2.5, 'content': '第一行'},
      {'from': 3, 'to': 4, 'content': '第二行'},
    ]);
    final vtt = SubtitleCues.toVtt(cues, cues.map((e) => e.text).toList());
    final parsed = SubtitleCues.fromVtt(vtt);
    expect(parsed.map((e) => e.start), ['00:00:01.250', '00:00:03.000']);
    expect(parsed.map((e) => e.text), ['第一行', '第二行']);
  });

  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('pili_subtitles_');
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test(
    'limits workers, reprioritizes after seeking and keeps cue order',
    () async {
      final started = <int>[];
      final waiting = <int, Completer<void>>{};
      final initialWorkers = Completer<void>();
      var active = 0;
      var peak = 0;
      String? finalVtt;
      final job = SubtitleTranslationJob(
        cues: _cues(100),
        chunkSize: 20,
        concurrency: 3,
        cacheKey: 'seek',
        cacheDirectory: directory.path,
        translate: (lines) async {
          final id = int.parse(lines.first.substring(1)) ~/ 20;
          started.add(id);
          if (started.length == 3) initialWorkers.complete();
          active++;
          if (active > peak) peak = active;
          final gate = waiting[id] = Completer<void>();
          await gate.future;
          active--;
          return lines.map((line) => 'translated $line').toList();
        },
        onUpdate: (vtt, _) => finalVtt = vtt,
      );
      final running = job.run();
      await initialWorkers.future;
      expect(started, [0, 1, 2]);
      job.setPosition(80);
      waiting[1]!.complete();
      await Future<void>.delayed(Duration.zero);
      expect(started.last, 4);
      waiting[4]!.complete();
      await Future<void>.delayed(Duration.zero);
      expect(started.last, 3);
      for (final id in [0, 2, 3]) {
        waiting[id]!.complete();
      }
      await running;
      expect(peak, 3);
      expect(
        finalVtt,
        contains('00:00:00.000 --> 00:00:01.000\ntranslated 句0'),
      );
      expect(
        finalVtt,
        contains('00:01:20.000 --> 00:01:21.000\ntranslated 句80'),
      );
      expect(await directory.list().length, 1);
    },
  );

  test(
    'prioritizes the playing chunk and upcoming chunks before history',
    () async {
      final started = <int>[];
      final waiting = <Completer<void>>[];
      final initialWorkers = Completer<void>();
      final job = SubtitleTranslationJob(
        cues: _cues(120),
        chunkSize: 20,
        concurrency: 3,
        cacheKey: 'realtime-priority',
        cacheDirectory: directory.path,
        positionSeconds: 50,
        translate: (lines) async {
          started.add(int.parse(lines.first.substring(1)) ~/ 20);
          final gate = Completer<void>();
          waiting.add(gate);
          if (started.length == 3) initialWorkers.complete();
          await gate.future;
          return lines.map((line) => 'translated $line').toList();
        },
        onUpdate: (_, __) {},
      );
      final running = job.run();
      await initialWorkers.future;
      expect(started, [2, 3, 4]);
      job.cancel();
      for (final gate in waiting) {
        gate.complete();
      }
      await running;
    },
  );

  test(
    'emits the first completed chunk immediately with cue progress',
    () async {
      final firstUpdate = Completer<SubtitleTranslationProgress>();
      final secondChunk = Completer<void>();
      final job = SubtitleTranslationJob(
        cues: _cues(40),
        chunkSize: 20,
        concurrency: 1,
        cacheKey: 'immediate-progress',
        cacheDirectory: directory.path,
        translate: (lines) async {
          if (lines.first == '句20') await secondChunk.future;
          return lines.map((line) => 'translated $line').toList();
        },
        onUpdate: (_, progress) {
          if (!firstUpdate.isCompleted) firstUpdate.complete(progress);
        },
      );
      final running = job.run();
      final progress = await firstUpdate.future;
      expect(progress.completedChunks, 1);
      expect(progress.processedCues, 20);
      expect(progress.translatedCues, 20);
      expect(progress.totalCues, 40);
      expect(progress.ratio, 0.5);
      secondChunk.complete();
      await running;
    },
  );

  test(
    'keeps a retryable checkpoint for an unchanged Chinese source copy',
    () async {
      final job = SubtitleTranslationJob(
        cues: _cues(20),
        chunkSize: 20,
        concurrency: 1,
        cacheKey: 'source-copy',
        cacheDirectory: directory.path,
        translate: (lines) async => lines,
        onUpdate: (_, progress) => expect(progress.failedChunks, 1),
      );
      await job.run();
      final files = (await directory.list().toList())
          .whereType<File>()
          .toList();
      expect(files, hasLength(1));
      expect(await files.single.readAsString(), contains('"failedChunks":[0]'));
    },
  );

  test('retries a transient chunk failure before reporting it', () async {
    var attempts = 0;
    SubtitleTranslationProgress? progress;
    final job = SubtitleTranslationJob(
      cues: _cues(20),
      chunkSize: 20,
      concurrency: 5,
      cacheKey: 'retry',
      cacheDirectory: directory.path,
      retryDelay: Duration.zero,
      translate: (lines) async {
        attempts++;
        if (attempts < 3) throw Exception('temporary network failure');
        return lines.map((line) => 'translated $line').toList();
      },
      onUpdate: (_, value) => progress = value,
    );

    await job.run();

    expect(attempts, 3);
    expect(progress!.failedChunks, 0);
    expect(progress!.translatedCues, 20);
  });

  test(
    'passes four source cues as context without shifting chunk output',
    () async {
      final calls = <({List<String> lines, List<String> context})>[];
      String? finalVtt;
      final job = SubtitleTranslationJob(
        cues: _cues(25),
        chunkSize: 20,
        concurrency: 1,
        cacheKey: 'context-overlap',
        cacheDirectory: directory.path,
        translate: (lines) async =>
            lines.map((line) => 'fallback $line').toList(),
        translateWithContext: (lines, context) async {
          calls.add((lines: [...lines], context: [...context]));
          return lines.map((line) => 'translated $line').toList();
        },
        onUpdate: (vtt, _) => finalVtt = vtt,
      );

      await job.run();

      expect(calls, hasLength(2));
      expect(calls.first.context, isEmpty);
      expect(calls.last.lines, ['句20', '句21', '句22', '句23', '句24']);
      expect(calls.last.context, ['句16', '句17', '句18', '句19']);
      expect(finalVtt, contains('translated 句20'));
    },
  );

  test('emits partial translation and checkpoints failed chunks', () async {
    String? lastVtt;
    bool? failed;
    int? translatedCues;
    final job = SubtitleTranslationJob(
      cues: _cues(40),
      chunkSize: 20,
      concurrency: 1,
      cacheKey: 'failed',
      cacheDirectory: directory.path,
      translate: (lines) async {
        if (lines.first == '句20') throw StateError('network');
        return lines.map((line) => 'translated $line').toList();
      },
      onUpdate: (vtt, progress) {
        lastVtt = vtt;
        failed = progress.failedChunks > 0;
        translatedCues = progress.translatedCues;
      },
    );
    await job.run();
    expect(failed, true);
    expect(translatedCues, 20);
    expect(lastVtt, contains('translated 句0'));
    expect(lastVtt, contains('句20'));
    final files = (await directory.list().toList()).whereType<File>().toList();
    expect(files, hasLength(1));
    final checkpoint = await files.single.readAsString();
    expect(checkpoint, contains('"completedChunks":[0]'));
    expect(checkpoint, contains('"failedChunks":[1]'));
  });

  test(
    'resumes only failed checkpoint chunks and preserves completed text',
    () async {
      final first = SubtitleTranslationJob(
        cues: _cues(40),
        chunkSize: 20,
        concurrency: 1,
        cacheKey: 'resume-failed-chunk',
        cacheDirectory: directory.path,
        translate: (lines) async {
          if (lines.first == '句20') throw StateError('temporary outage');
          return lines.map((line) => 'first $line').toList();
        },
        onUpdate: (_, __) {},
      );
      await first.run();

      final translatedChunks = <int>[];
      String? finalVtt;
      final resumed = SubtitleTranslationJob(
        cues: _cues(40),
        chunkSize: 20,
        concurrency: 1,
        cacheKey: 'resume-failed-chunk',
        cacheDirectory: directory.path,
        translate: (lines) async {
          translatedChunks.add(int.parse(lines.first.substring(1)) ~/ 20);
          return lines.map((line) => 'retry $line').toList();
        },
        onUpdate: (vtt, _) => finalVtt = vtt,
      );

      await resumed.run();

      expect(translatedChunks, [1]);
      expect(finalVtt, contains('first 句0'));
      expect(finalVtt, contains('retry 句20'));
    },
  );

  test(
    'reuses complete cache offline and invalidates changed source',
    () async {
      final cues = _cues(20);
      SubtitleTranslationJob build(
        List<SubtitleCue> input,
        Future<List<String>> Function(List<String>) translator,
      ) => SubtitleTranslationJob(
        cues: input,
        chunkSize: 20,
        concurrency: 3,
        cacheKey: 'same-video/part/lang',
        cacheDirectory: directory.path,
        translate: translator,
        onUpdate: (_, __) {},
      );
      await build(
        cues,
        (lines) async => lines.map((e) => 'vi $e').toList(),
      ).run();
      final offline = build(cues, (_) async => throw StateError('offline'));
      expect(await offline.loadCached(), true);
      await offline.run();
      final changed = [...cues];
      changed[0] = const SubtitleCue(
        '00:00:00.000',
        '00:00:01.000',
        'changed',
      );
      expect(
        await build(
          changed,
          (_) async => throw StateError('offline'),
        ).loadCached(),
        false,
      );
    },
  );

  test('cancelled work cannot emit or write a cache', () async {
    final gate = Completer<List<String>>();
    final started = Completer<void>();
    var updates = 0;
    final job = SubtitleTranslationJob(
      cues: _cues(20),
      chunkSize: 20,
      concurrency: 1,
      cacheKey: 'cancel',
      cacheDirectory: directory.path,
      translate: (_) {
        started.complete();
        return gate.future;
      },
      onUpdate: (_, __) => updates++,
    );
    final running = job.run();
    await started.future;
    job.cancel();
    gate.complete(List.filled(20, 'translated'));
    await running;
    expect(updates, 0);
    expect(await directory.list().isEmpty, true);
  });
}
