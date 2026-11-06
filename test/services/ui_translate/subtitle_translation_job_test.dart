import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

List<SubtitleCue> _cues(int length) => [
  for (var i = 0; i < length; i++)
    SubtitleCue(
      '00:${(i ~/ 60).toString().padLeft(2, '0')}:${(i % 60).toString().padLeft(2, '0')}.000',
      '00:${((i + 1) ~/ 60).toString().padLeft(2, '0')}:${((i + 1) % 60).toString().padLeft(2, '0')}.000',
      '句$i',
    ),
];

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('pili_subtitles_');
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test(
    'completed Vietnamese VTT rejects residual Chinese and timing drift',
    () {
      const source = [
        SubtitleCue('00:00:01.000', '00:00:02.000', '你好'),
        SubtitleCue('00:00:03.000', '00:00:04.000', '再见'),
      ];
      expect(
        SubtitleTranslationOutput.isCompleteVietnameseVtt(
          source,
          SubtitleCues.toVtt(source, const ['Xin chào', 'Tạm biệt']),
        ),
        isTrue,
      );
      expect(
        SubtitleTranslationOutput.isCompleteVietnameseVtt(
          source,
          SubtitleCues.toVtt(source, const ['Xin chào', '再见']),
        ),
        isFalse,
      );
      expect(
        SubtitleTranslationOutput.isCompleteVietnameseVtt(
          source,
          'WEBVTT\n\n00:00:01.100 --> 00:00:02.000\nXin chào\n\n'
          '00:00:03.000 --> 00:00:04.000\nTạm biệt\n',
        ),
        isFalse,
      );
    },
  );

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

  test(
    'keeps every source timestamp when chunks finish out of order',
    () async {
      const cues = [
        SubtitleCue('00:00:00.125', '00:00:01.875', '甲'),
        SubtitleCue('00:01:02.250', '00:01:04.500', '乙'),
        SubtitleCue('01:02:03.004', '01:02:06.999', '丙'),
      ];
      String? translatedVtt;
      final emittedVtts = <String>[];
      final job = SubtitleTranslationJob(
        cues: cues,
        chunkSize: 1,
        concurrency: 3,
        targetLanguage: 'vi',
        cacheKey: 'timestamp-order',
        cacheDirectory: directory.path,
        translate: (lines) async {
          // Complete later cues first, as happens with parallel API requests.
          final delay = switch (lines.single) {
            '甲' => 30,
            '乙' => 15,
            _ => 0,
          };
          await Future<void>.delayed(Duration(milliseconds: delay));
          return [
            switch (lines.single) {
              '甲' => 'Bản dịch một',
              '乙' => 'Bản dịch hai',
              _ => 'Bản dịch ba',
            },
          ];
        },
        onUpdate: (vtt, _) {
          emittedVtts.add(vtt);
          translatedVtt = vtt;
        },
      );

      await job.run();

      final parsed = SubtitleCues.fromVtt(translatedVtt!);
      expect(parsed.map((cue) => cue.start), cues.map((cue) => cue.start));
      expect(parsed.map((cue) => cue.end), cues.map((cue) => cue.end));
      expect(parsed.map((cue) => cue.text), [
        'Bản dịch một',
        'Bản dịch hai',
        'Bản dịch ba',
      ]);
      expect(
        emittedVtts.every(
          (vtt) => SubtitleCues.hasTimelineSubset(cues, vtt),
        ),
        isTrue,
      );
      expect(
        emittedVtts.every(
          (vtt) => SubtitleCues.fromVtt(
            vtt,
          ).every((cue) => !RegExp(r'[甲乙丙]').hasMatch(cue.text)),
        ),
        isTrue,
      );
      expect(SubtitleCues.hasSameTimeline(cues, translatedVtt!), isTrue);
    },
  );

  test('accepts only an exact ordered subset of the source timeline', () {
    final source = _cues(3);
    final partial = SubtitleCues.toVttSubset(
      source,
      const ['Một', 'Hai', 'Ba'],
      const [0, 2],
    );

    expect(SubtitleCues.hasTimelineSubset(source, partial), isTrue);
    expect(
      SubtitleCues.hasTimelineSubset(
        source,
        'WEBVTT\n\n00:00:00.100 --> 00:00:01.000\nMột\n',
      ),
      isFalse,
    );
    expect(
      SubtitleCues.hasTimelineSubset(
        source,
        'WEBVTT\n\n00:00:00.000 --> 00:00:01.000\nMột\n\n'
        '00:00:00.000 --> 00:00:01.000\nLặp\n',
      ),
      isFalse,
    );
  });

  test('realtime pause policy respects setting and retry exhaustion', () {
    const progress = SubtitleTranslationProgress(
      phase: SubtitleTranslationPhase.translating,
      completedChunks: 1,
      totalChunks: 5,
      processedCues: 20,
      translatedCues: 20,
      verifiedCues: 0,
      totalCues: 100,
      failedChunks: 1,
      currentPositionCovered: false,
      coverageAheadSeconds: 0,
      remainingTimelineCovered: false,
      renderRevision: 1,
      renderedChunks: [0],
    );

    expect(
      SubtitleRealtimeBufferPolicy.shouldBlockPlayback(
        progress,
        waitForComplete: false,
        autoPauseForBuffer: true,
        translatedTrackSelected: true,
      ),
      isTrue,
    );
    expect(
      SubtitleRealtimeBufferPolicy.shouldBlockPlayback(
        progress,
        waitForComplete: false,
        autoPauseForBuffer: false,
        translatedTrackSelected: true,
      ),
      isFalse,
    );
    expect(
      SubtitleRealtimeBufferPolicy.shouldBlockPlayback(
        progress.copyWith(retryExhausted: true),
        waitForComplete: true,
        autoPauseForBuffer: true,
        translatedTrackSelected: true,
      ),
      isFalse,
    );
  });

  test('production-style jobs delegate retry to the coordinator', () async {
    final directory = await Directory.systemTemp.createTemp(
      'pili_job_coordinator_retry_',
    );
    addTearDown(() => directory.delete(recursive: true));
    var calls = 0;

    final job = SubtitleTranslationJob(
      cues: _cues(20),
      chunkSize: 20,
      concurrency: 1,
      cacheKey: 'coordinator-owned-retry',
      cacheDirectory: directory.path,
      maxRetries: 0,
      translate: (_) async {
        calls++;
        throw TimeoutException('provider unavailable');
      },
      onUpdate: (_, __) {},
    );

    await job.run();

    expect(calls, 1);
  });

  test(
    'later five-percent chunk never covers the current playback position',
    () async {
      final firstChunk = Completer<void>();
      final remainingChunks = Completer<void>();
      final laterChunkUpdate = Completer<SubtitleTranslationProgress>();
      final emittedVtts = <String>[];
      var laterChunkReturned = false;
      final job = SubtitleTranslationJob(
        cues: _cues(400),
        chunkSize: 20,
        concurrency: 2,
        targetLanguage: 'vi',
        cacheKey: 'five-percent-gap',
        cacheDirectory: directory.path,
        translate: (lines) async {
          final chunk = int.parse(lines.first.substring(1)) ~/ 20;
          if (chunk == 0) await firstChunk.future;
          if (chunk >= 2) await remainingChunks.future;
          if (chunk == 1) laterChunkReturned = true;
          return [
            for (final line in lines) 'Bản dịch câu ${line.substring(1)}',
          ];
        },
        onUpdate: (vtt, progress) {
          emittedVtts.add(vtt);
          if (laterChunkReturned && !laterChunkUpdate.isCompleted) {
            laterChunkUpdate.complete(progress);
          }
        },
      );

      final running = job.run();
      final progress = await laterChunkUpdate.future;
      expect(progress.ratio, 0);
      expect(progress.completedChunks, 0);
      expect(progress.currentPositionCovered, isFalse);
      expect(SubtitleRealtimeBufferPolicy.canStart(progress), isFalse);
      expect(SubtitleCues.fromVtt(emittedVtts.last), isEmpty);
      expect(
        emittedVtts.every(
          (vtt) => SubtitleCues.fromVtt(
            vtt,
          ).every((cue) => !RegExp(r'[\u3400-\u9FFF]').hasMatch(cue.text)),
        ),
        isTrue,
      );
      job.cancel();
      firstChunk.complete();
      remainingChunks.complete();
      await running;
    },
  );

  test('requires sixty seconds to start and pauses below fifteen', () async {
    final gates = List.generate(5, (_) => Completer<void>());
    final lowBufferUpdate = Completer<SubtitleTranslationProgress>();
    final updates = <int, Completer<SubtitleTranslationProgress>>{
      for (var completed = 1; completed <= 3; completed++)
        completed: Completer<SubtitleTranslationProgress>(),
    };
    final job = SubtitleTranslationJob(
      cues: _cues(100),
      chunkSize: 20,
      concurrency: 1,
      targetLanguage: 'vi',
      cacheKey: 'realtime-watermarks',
      cacheDirectory: directory.path,
      translate: (lines) async {
        final chunk = int.parse(lines.first.substring(1)) ~/ 20;
        await gates[chunk].future;
        return [
          for (final line in lines) 'Bản dịch câu ${line.substring(1)}',
        ];
      },
      onUpdate: (_, progress) {
        final waiter = updates[progress.completedChunks];
        if (waiter != null && !waiter.isCompleted) waiter.complete(progress);
        if (progress.completedChunks == 3 &&
            progress.coverageAheadSeconds < 15 &&
            !lowBufferUpdate.isCompleted) {
          lowBufferUpdate.complete(progress);
        }
      },
    );

    final running = job.run();
    gates[0].complete();
    final twentySeconds = await updates[1]!.future;
    expect(twentySeconds.coverageAheadSeconds, 20);
    expect(SubtitleRealtimeBufferPolicy.canStart(twentySeconds), isFalse);
    expect(SubtitleRealtimeBufferPolicy.shouldPause(twentySeconds), isFalse);

    gates[1].complete();
    final fortySeconds = await updates[2]!.future;
    expect(fortySeconds.coverageAheadSeconds, 40);
    expect(SubtitleRealtimeBufferPolicy.canStart(fortySeconds), isFalse);

    gates[2].complete();
    final sixtySeconds = await updates[3]!.future;
    expect(sixtySeconds.coverageAheadSeconds, 60);
    expect(SubtitleRealtimeBufferPolicy.canStart(sixtySeconds), isTrue);

    job.setPosition(46);
    final lowBuffer = await lowBufferUpdate.future;
    expect(lowBuffer.coverageAheadSeconds, 14);
    expect(SubtitleRealtimeBufferPolicy.shouldPause(lowBuffer), isTrue);

    job.cancel();
    for (final gate in gates.skip(3)) {
      gate.complete();
    }
    await running;
  });

  test('does not reuse a cache identity when only cue timing changes', () {
    const original = [SubtitleCue('00:00:01.000', '00:00:02.000', '你好')];
    const retimed = [SubtitleCue('00:00:01.001', '00:00:02.000', '你好')];

    expect(
      SubtitleTranslationJob.cacheIdentity('same-track', original),
      isNot(SubtitleTranslationJob.cacheIdentity('same-track', retimed)),
    );
  });

  test('rejects a VTT update when a timestamp changes', () {
    const source = [
      SubtitleCue('00:00:01.000', '00:00:02.000', '你好'),
      SubtitleCue('00:00:02.000', '00:00:03.000', '再见'),
    ];
    final retimed = SubtitleCues.toVtt(
      const [
        SubtitleCue('00:00:01.000', '00:00:02.000', '你好'),
        SubtitleCue('00:00:02.500', '00:00:03.000', '再见'),
      ],
      ['Xin chào', 'Tạm biệt'],
    );

    expect(SubtitleCues.hasSameTimeline(source, retimed), isFalse);
  });

  test('rejects a source timeline that would stack four subtitles', () {
    const cues = [
      SubtitleCue('00:04:00.000', '00:04:04.000', '一'),
      SubtitleCue('00:04:00.100', '00:04:04.000', '二'),
      SubtitleCue('00:04:00.200', '00:04:04.000', '三'),
      SubtitleCue('00:04:00.300', '00:04:04.000', '四'),
    ];

    expect(SubtitleCues.hasSafePlaybackTimeline(cues), isFalse);
  });

  test('uses a separate checkpoint for an explicit retranslation', () {
    const cues = [SubtitleCue('00:00:01.000', '00:00:02.000', '你好')];
    final cached = SubtitleTranslationJob.cacheFileFor(
      'video/1/zh/vi',
      cues,
      cacheDirectory: directory.path,
    );
    final replacement = SubtitleTranslationJob.cacheFileFor(
      'video/1/zh/vi/retranslate/123',
      cues,
      cacheDirectory: directory.path,
    );

    expect(replacement.path, isNot(cached.path));
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
      expect(started.last, 3);
      waiting[3]!.complete();
      await Future<void>.delayed(Duration.zero);
      expect(started.last, 4);
      for (final id in [0, 2, 4]) {
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
    'prioritizes context, playing chunk and upcoming chunks before history',
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
      expect(started, [1, 2, 3]);
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

  test('strips only model-echoed batch ordinals before emitting VTT', () async {
    String? vtt;
    final job = SubtitleTranslationJob(
      cues: const [
        SubtitleCue('00:00:00.000', '00:00:01.000', '你好'),
        SubtitleCue('00:00:01.000', '00:00:02.000', '再见'),
      ],
      chunkSize: 20,
      concurrency: 1,
      targetLanguage: 'vi',
      cacheKey: 'strip-ordinals',
      cacheDirectory: directory.path,
      translate: (_) async => ['1. Xin chào', '2、Tạm biệt'],
      onUpdate: (value, _) => vtt = value,
    );

    await job.run();

    expect(vtt, contains('00:00:00.000 --> 00:00:01.000\nXin chào'));
    expect(vtt, contains('00:00:01.000 --> 00:00:02.000\nTạm biệt'));
    expect(vtt, isNot(contains('1. Xin chào')));
    expect(vtt, isNot(contains('2、Tạm biệt')));
  });

  test(
    'keeps a failed checkpoint when Vietnamese target receives English',
    () async {
      var attempts = 0;
      String? vtt;
      SubtitleTranslationProgress? progress;
      final job = SubtitleTranslationJob(
        cues: const [SubtitleCue('00:00:00.000', '00:00:01.000', '你好')],
        chunkSize: 20,
        concurrency: 1,
        targetLanguage: 'vi',
        cacheKey: 'reject-english',
        cacheDirectory: directory.path,
        retryDelay: Duration.zero,
        translate: (_) async {
          attempts++;
          return ['Hello, how are you?'];
        },
        onUpdate: (value, valueProgress) {
          vtt = value;
          progress = valueProgress;
        },
      );

      await job.run();

      expect(attempts, 3);
      expect(progress!.failedChunks, 1);
      expect(SubtitleCues.fromVtt(vtt!), isEmpty);
      final files = (await directory.list().toList())
          .whereType<File>()
          .toList();
      expect(files, hasLength(1));
      final checkpoint = await files.single.readAsString();
      expect(checkpoint, contains('"failedChunks":[0]'));
    },
  );

  test('preserves a real source ordinal in translated dialogue', () {
    expect(
      SubtitleTranslationOutput.sanitizeAndValidate(
        const ['1. 第一章'],
        const ['1. Chương một'],
        targetLanguage: 'vi',
      ),
      ['1. Chương một'],
    );
  });

  test('rejects a translated cue that merges an overlap context line', () {
    expect(
      () => SubtitleTranslationOutput.sanitizeAndValidate(
        const ['你要去哪里？'],
        const ['Huynh định đi đâu?\nTa sẽ đi cùng huynh.'],
        targetLanguage: 'vi',
      ),
      throwsFormatException,
    );
  });

  test('rejects an overlap translation inserted on the same line', () {
    expect(
      () => SubtitleTranslationOutput.sanitizeAndValidate(
        const ['你要去哪里？'],
        const ['Ta sẽ đi cùng huynh. Huynh định đi đâu?'],
        targetLanguage: 'vi',
        translatedContext: const ['Ta sẽ đi cùng huynh.'],
      ),
      throwsFormatException,
    );
  });

  test('rejects a context sentence used instead of the current cue', () {
    expect(
      () => SubtitleTranslationOutput.sanitizeAndValidate(
        const ['你要去哪里？'],
        const ['Ta sẽ đi cùng huynh.'],
        targetLanguage: 'vi',
        sourceContext: const ['我会和你一起去。'],
        translatedContext: const ['Ta sẽ đi cùng huynh.'],
      ),
      throwsFormatException,
    );
  });

  test('rejects multiple short context elements replacing current cues', () {
    expect(
      () => SubtitleTranslationOutput.sanitizeAndValidate(
        const ['你先走。', '我留下。'],
        const ['Chờ ta.', 'Được rồi.'],
        targetLanguage: 'vi',
        sourceContext: const ['等等我。', '好吧。'],
        translatedContext: const ['Chờ ta.', 'Được rồi.'],
      ),
      throwsFormatException,
    );
  });

  test('allows a short naturally repeated translation across chunks', () {
    expect(
      SubtitleTranslationOutput.sanitizeAndValidate(
        const ['好。'],
        const ['Được.'],
        targetLanguage: 'vi',
        sourceContext: const ['可以。'],
        translatedContext: const ['Được.'],
      ),
      const ['Được.'],
    );
  });

  test(
    'repairs legacy numbered Vietnamese cache without retranslating',
    () async {
      const cacheKey = 'legacy-numbered-cache';
      const cues = [
        SubtitleCue('00:00:00.000', '00:00:01.000', '你好'),
        SubtitleCue('00:00:01.000', '00:00:02.000', '再见'),
      ];
      final identity = SubtitleTranslationJob.cacheIdentity(cacheKey, cues);
      final file = File(path.join(directory.path, '$identity.json'));
      await file.writeAsString(
        jsonEncode({
          'version': 2,
          'complete': true,
          'texts': ['1. Xin chào', '2、Tạm biệt'],
          'completedChunks': [0],
          'failedChunks': <int>[],
        }),
      );
      var requests = 0;
      String? vtt;
      final job = SubtitleTranslationJob(
        cues: cues,
        chunkSize: 20,
        concurrency: 1,
        targetLanguage: 'vi',
        cacheKey: cacheKey,
        cacheDirectory: directory.path,
        translate: (_) async {
          requests++;
          throw StateError('offline');
        },
        onUpdate: (value, _) => vtt = value,
      );

      expect(await job.loadCached(), true);
      await job.run();

      expect(requests, 0);
      expect(vtt, contains('\nXin chào\n'));
      expect(vtt, contains('\nTạm biệt\n'));
      final repaired = jsonDecode(await file.readAsString()) as Map;
      expect(repaired['texts'], ['Xin chào', 'Tạm biệt']);
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
    'times out a stuck chunk and retries without losing cue timing',
    () async {
      var attempts = 0;
      String? vtt;
      final never = Completer<List<String>>();
      final job = SubtitleTranslationJob(
        cues: const [
          SubtitleCue('00:04:01.125', '00:04:03.875', '你好'),
        ],
        chunkSize: 20,
        concurrency: 1,
        cacheKey: 'stuck-retry',
        cacheDirectory: directory.path,
        retryDelay: Duration.zero,
        attemptTimeout: const Duration(milliseconds: 20),
        translate: (lines) {
          attempts++;
          if (attempts == 1) return never.future;
          return Future.value(['Xin chào']);
        },
        onUpdate: (value, _) => vtt = value,
      );

      await job.run();

      expect(attempts, 2);
      final cue = SubtitleCues.fromVtt(vtt!).single;
      expect(cue.start, '00:04:01.125');
      expect(cue.end, '00:04:03.875');
      expect(cue.text, 'Xin chào');
    },
  );

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

  test(
    'repairs a context cue echoed by an out-of-order parallel chunk',
    () async {
      var secondChunkAttempts = 0;
      String? finalVtt;
      final job = SubtitleTranslationJob(
        cues: _cues(25),
        chunkSize: 20,
        concurrency: 2,
        cacheKey: 'parallel-context-echo',
        cacheDirectory: directory.path,
        targetLanguage: 'vi',
        retryDelay: Duration.zero,
        translate: (lines) async =>
            lines.map((line) => 'Bản dịch câu ${line.substring(1)}').toList(),
        translateWithContext: (lines, context) async {
          if (lines.first == '句0') {
            await Future<void>.delayed(const Duration(milliseconds: 20));
          }
          if (lines.first == '句20') {
            secondChunkAttempts++;
            if (secondChunkAttempts == 1) {
              return [
                'Bản dịch câu 19. Bản dịch câu 20',
                for (final line in lines.skip(1))
                  'Bản dịch câu ${line.substring(1)}',
              ];
            }
          }
          return lines
              .map((line) => 'Bản dịch câu ${line.substring(1)}')
              .toList();
        },
        onUpdate: (vtt, _) => finalVtt = vtt,
      );

      await job.run();

      expect(secondChunkAttempts, 2);
      final translated = SubtitleCues.fromVtt(finalVtt!);
      expect(translated[19].text, 'Bản dịch câu 19');
      expect(translated[20].text, 'Bản dịch câu 20');
      expect(
        translated.any((cue) => cue.text.contains('19. Bản dịch câu 20')),
        isFalse,
      );
    },
  );

  test(
    'repairs a context cue that replaces a cue after parallel completion',
    () async {
      var secondChunkAttempts = 0;
      String? finalVtt;
      final job = SubtitleTranslationJob(
        cues: _cues(25),
        chunkSize: 20,
        concurrency: 2,
        cacheKey: 'parallel-context-replacement',
        cacheDirectory: directory.path,
        targetLanguage: 'vi',
        retryDelay: Duration.zero,
        translate: (lines) async => [
          for (final line in lines) 'Bản dịch câu ${line.substring(1)}',
        ],
        translateWithContext: (lines, _) async {
          if (lines.first == '句0') {
            await Future<void>.delayed(const Duration(milliseconds: 20));
            return [
              for (final line in lines) 'Bản dịch câu ${line.substring(1)}',
            ];
          }
          if (lines.first == '句20' && secondChunkAttempts++ == 0) {
            return [
              'Bản dịch câu 19',
              for (final line in lines.skip(1))
                'Bản dịch câu ${line.substring(1)}',
            ];
          }
          return [
            for (final line in lines) 'Đã sửa câu ${line.substring(1)}',
          ];
        },
        onUpdate: (vtt, _) => finalVtt = vtt,
      );

      await job.run();

      expect(secondChunkAttempts, 2);
      final translated = SubtitleCues.fromVtt(finalVtt!);
      expect(translated[19].text, 'Bản dịch câu 19');
      expect(translated[20].text, 'Đã sửa câu 20');
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
    expect(lastVtt, isNot(contains('句20')));
    expect(SubtitleCues.fromVtt(lastVtt!), hasLength(20));
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
    'retries only a cached chunk polluted by translated overlap context',
    () async {
      final cues = _cues(25);
      final initial = SubtitleTranslationJob(
        cues: cues,
        chunkSize: 20,
        concurrency: 1,
        cacheKey: 'cached-context-echo',
        cacheDirectory: directory.path,
        targetLanguage: 'vi',
        translate: (lines) async =>
            lines.map((line) => 'Bản dịch câu ${line.substring(1)}').toList(),
        onUpdate: (_, __) {},
      );
      await initial.run();

      final checkpoint = SubtitleTranslationJob.cacheFileFor(
        'cached-context-echo',
        cues,
        cacheDirectory: directory.path,
      );
      final data =
          jsonDecode(await checkpoint.readAsString()) as Map<String, dynamic>;
      final texts = List<String>.from(data['texts'] as List);
      texts[20] = 'Bản dịch câu 19. Bản dịch câu 20';
      data['texts'] = texts;
      await checkpoint.writeAsString(jsonEncode(data));

      final retriedChunks = <int>[];
      String? finalVtt;
      final resumed = SubtitleTranslationJob(
        cues: cues,
        chunkSize: 20,
        concurrency: 1,
        cacheKey: 'cached-context-echo',
        cacheDirectory: directory.path,
        targetLanguage: 'vi',
        translate: (lines) async {
          retriedChunks.add(int.parse(lines.first.substring(1)) ~/ 20);
          return lines
              .map((line) => 'Đã sửa câu ${line.substring(1)}')
              .toList();
        },
        onUpdate: (vtt, _) => finalVtt = vtt,
      );

      await resumed.run();

      expect(retriedChunks, [1]);
      final translated = SubtitleCues.fromVtt(finalVtt!);
      expect(translated.first.text, 'Bản dịch câu 0');
      expect(translated[20].text, 'Đã sửa câu 20');
    },
  );

  test(
    'retries only a cached chunk replaced by translated overlap context',
    () async {
      final cues = _cues(25);
      final initial = SubtitleTranslationJob(
        cues: cues,
        chunkSize: 20,
        concurrency: 1,
        cacheKey: 'cached-context-replacement',
        cacheDirectory: directory.path,
        targetLanguage: 'vi',
        translate: (lines) async => [
          for (final line in lines) 'Bản dịch câu ${line.substring(1)}',
        ],
        onUpdate: (_, __) {},
      );
      await initial.run();

      final checkpoint = SubtitleTranslationJob.cacheFileFor(
        'cached-context-replacement',
        cues,
        cacheDirectory: directory.path,
      );
      final data =
          jsonDecode(await checkpoint.readAsString()) as Map<String, dynamic>;
      final texts = List<String>.from(data['texts'] as List);
      texts[20] = texts[19];
      data['texts'] = texts;
      await checkpoint.writeAsString(jsonEncode(data));

      final retriedChunks = <int>[];
      String? finalVtt;
      final resumed = SubtitleTranslationJob(
        cues: cues,
        chunkSize: 20,
        concurrency: 1,
        cacheKey: 'cached-context-replacement',
        cacheDirectory: directory.path,
        targetLanguage: 'vi',
        translate: (lines) async {
          retriedChunks.add(int.parse(lines.first.substring(1)) ~/ 20);
          return [
            for (final line in lines) 'Đã sửa câu ${line.substring(1)}',
          ];
        },
        onUpdate: (vtt, _) => finalVtt = vtt,
      );

      await resumed.run();

      expect(retriedChunks, [1]);
      final translated = SubtitleCues.fromVtt(finalVtt!);
      expect(translated[19].text, 'Bản dịch câu 19');
      expect(translated[20].text, 'Đã sửa câu 20');
    },
  );

  test(
    'reopened context chunk disappears instead of reverting to Chinese',
    () async {
      var secondChunkAttempts = 0;
      final emitted = <String>[];
      final job = SubtitleTranslationJob(
        cues: _cues(25),
        chunkSize: 20,
        concurrency: 2,
        cacheKey: 'context-reopen-hidden',
        cacheDirectory: directory.path,
        targetLanguage: 'vi',
        retryDelay: Duration.zero,
        translate: (lines) async => [
          for (final line in lines) 'Bản dịch câu ${line.substring(1)}',
        ],
        translateWithContext: (lines, _) async {
          if (lines.first == '句0') {
            await Future<void>.delayed(const Duration(milliseconds: 20));
            return [
              for (final line in lines) 'Bản dịch câu ${line.substring(1)}',
            ];
          }
          if (lines.first == '句20' && secondChunkAttempts++ == 0) {
            return [
              'Bản dịch câu 19. Bản dịch câu 20',
              for (final line in lines.skip(1))
                'Bản dịch câu ${line.substring(1)}',
            ];
          }
          return [
            for (final line in lines) 'Đã sửa câu ${line.substring(1)}',
          ];
        },
        onUpdate: (vtt, _) => emitted.add(vtt),
      );

      await job.run();

      expect(secondChunkAttempts, 2);
      expect(
        emitted.every(
          (vtt) => SubtitleCues.fromVtt(vtt).every(
            (cue) => cue.text != 'Bản dịch câu 19. Bản dịch câu 20',
          ),
        ),
        isTrue,
        reason:
            'An out-of-order chunk must stay hidden until its translated '
            'overlap context has been validated.',
      );
      expect(
        SubtitleCues.fromVtt(emitted.last).map((cue) => cue.text),
        contains('Đã sửa câu 20'),
      );
    },
  );

  test('position updates keep the rendered VTT revision stable', () async {
    final secondChunk = Completer<void>();
    final firstChunk = Completer<SubtitleTranslationProgress>();
    final moved = Completer<SubtitleTranslationProgress>();
    var firstRevision = -1;
    final job = SubtitleTranslationJob(
      cues: _cues(40),
      chunkSize: 20,
      concurrency: 1,
      cacheKey: 'position-render-revision',
      cacheDirectory: directory.path,
      translate: (lines) async {
        if (lines.first == '句20') await secondChunk.future;
        return lines.map((line) => 'translated $line').toList();
      },
      onUpdate: (_, progress) {
        if (progress.completedChunks == 1 && !firstChunk.isCompleted) {
          firstRevision = progress.renderRevision;
          firstChunk.complete(progress);
          return;
        }
        if (progress.completedChunks == 1 &&
            progress.coverageAheadSeconds == 19 &&
            !moved.isCompleted) {
          moved.complete(progress);
        }
      },
    );

    final running = job.run();
    await firstChunk.future;
    job.setPosition(1);
    final positionProgress = await moved.future;
    expect(positionProgress.renderRevision, firstRevision);
    secondChunk.complete();
    await running;
  });

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

  test(
    'reopens only the legacy completed chunk that still contains Han',
    () async {
      final cues = _cues(40);
      const cacheKey = 'legacy-residual-han';
      final cache = SubtitleTranslationJob.cacheFileFor(
        cacheKey,
        cues,
        cacheDirectory: directory.path,
      );
      final texts = [
        for (var index = 0; index < cues.length; index++) 'Bản dịch câu $index',
      ];
      texts[25] = 'Bản dịch còn sót 〇';
      await cache.writeAsString(
        jsonEncode({
          'version': 2,
          'complete': true,
          'texts': texts,
          'completedChunks': [0, 1],
          'failedChunks': <int>[],
        }),
      );

      final retriedChunks = <int>[];
      final phases = <SubtitleTranslationPhase>[];
      String? finalVtt;
      final job = SubtitleTranslationJob(
        cues: cues,
        chunkSize: 20,
        concurrency: 2,
        cacheKey: cacheKey,
        cacheDirectory: directory.path,
        targetLanguage: 'vi',
        translate: (lines) async {
          retriedChunks.add(int.parse(lines.first.substring(1)) ~/ 20);
          return [
            for (final line in lines) 'Đã sửa câu ${line.substring(1)}',
          ];
        },
        onUpdate: (vtt, progress) {
          finalVtt = vtt;
          phases.add(progress.phase);
        },
      );

      await job.run();

      expect(retriedChunks, [1]);
      expect(phases, contains(SubtitleTranslationPhase.verifying));
      expect(phases.last, SubtitleTranslationPhase.ready);
      final translated = SubtitleCues.fromVtt(finalVtt!);
      expect(translated.first.text, 'Bản dịch câu 0');
      expect(translated[20].text, 'Đã sửa câu 20');
      expect(translated.any((cue) => cue.text.contains('〇')), isFalse);
      expect(
        translated.map((cue) => (cue.start, cue.end)),
        cues.map((cue) => (cue.start, cue.end)),
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
