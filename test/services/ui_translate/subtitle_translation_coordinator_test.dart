import 'dart:async';
import 'dart:io';

import 'package:PiliPlus/services/ui_translate/subtitle_translation_coordinator.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_proxy.dart';
import 'package:flutter_test/flutter_test.dart';

List<SubtitleCue> _cues(int length) => [
  for (var i = 0; i < length; i++)
    SubtitleCue(
      '00:00:${i.toString().padLeft(2, '0')}.000',
      '00:00:${(i + 1).toString().padLeft(2, '0')}.000',
      '句$i',
    ),
];

void main() {
  test(
    'reports a zero-progress update before the first chunk completes',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'pili_coordinator_initial_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final translateGate = Completer<void>();
      final updates = <SubtitleTranslationProgress>[];

      final subscription = SubtitleTranslationCoordinator.attach(
        key: 'initial-progress',
        allowNewTranslation: true,
        createJob: (onUpdate, _) => SubtitleTranslationJob(
          cues: _cues(20),
          chunkSize: 20,
          concurrency: 1,
          cacheKey: 'initial-progress',
          cacheDirectory: directory.path,
          translate: (lines) async {
            await translateGate.future;
            return lines.map((line) => 'vi $line').toList();
          },
          onUpdate: onUpdate,
        ),
        onUpdate: (_, progress) => updates.add(progress),
      );

      expect(updates, hasLength(1));
      expect(updates.single.processedCues, 0);
      expect(updates.single.totalCues, 20);
      expect(updates.single.isComplete, isFalse);

      subscription.cancel();
      translateGate.complete();
      await subscription.whenComplete;
    },
  );

  test(
    'detaching a viewer leaves translation running for a later viewer',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'pili_coordinator_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final firstChunk = Completer<void>();
      final secondChunk = Completer<void>();
      var calls = 0;
      var completed = 0;
      SubtitleTranslationJob factory(
        SubtitleTranslationUpdate onUpdate,
        SubtitleTranslationPriorityHandle _,
      ) => SubtitleTranslationJob(
        cues: _cues(40),
        chunkSize: 20,
        concurrency: 1,
        cacheKey: 'background-session',
        cacheDirectory: directory.path,
        translate: (lines) async {
          calls++;
          if (lines.first == '句0') {
            firstChunk.complete();
          } else {
            await secondChunk.future;
          }
          return lines.map((line) => 'vi $line').toList();
        },
        onUpdate: onUpdate,
      );

      final original = SubtitleTranslationCoordinator.attach(
        key: 'background-session',
        createJob: factory,
        allowNewTranslation: true,
        onUpdate: (_, _) {},
        onCompleted: () => completed++,
      );
      await firstChunk.future;
      original.detach();
      secondChunk.complete();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      String? restoredVtt;
      final restored = SubtitleTranslationCoordinator.attach(
        key: 'background-session',
        createJob: factory,
        allowNewTranslation: true,
        onUpdate: (vtt, _) => restoredVtt = vtt,
      );
      await restored.whenComplete;

      expect(calls, 2);
      expect(completed, 1);
      expect(restoredVtt, contains('vi 句0'));
      expect(restoredVtt, contains('vi 句20'));
    },
  );

  test('manual retry wakes backoff without starting a duplicate job', () async {
    final directory = await Directory.systemTemp.createTemp(
      'pili_coordinator_retry_',
    );
    addTearDown(() => directory.delete(recursive: true));
    var calls = 0;
    var failedUpdates = 0;
    final failed = Completer<void>();

    final subscription = SubtitleTranslationCoordinator.attach(
      key: 'manual-retry',
      allowNewTranslation: true,
      retryDelay: (_, _) => const Duration(days: 1),
      createJob: (onUpdate, _) => SubtitleTranslationJob(
        cues: _cues(20),
        chunkSize: 20,
        concurrency: 1,
        cacheKey: 'manual-retry',
        cacheDirectory: directory.path,
        translate: (lines) async {
          calls++;
          if (calls == 1) throw StateError('temporary outage');
          return lines.map((line) => 'vi $line').toList();
        },
        onUpdate: onUpdate,
      ),
      onUpdate: (_, progress) {
        if (progress.failedChunks > 0) {
          failedUpdates++;
          if (!failed.isCompleted) failed.complete();
        }
      },
    );

    await failed.future;
    subscription.retryNow();
    await subscription.whenComplete.timeout(const Duration(seconds: 2));

    expect(calls, 2);
    expect(failedUpdates, greaterThanOrEqualTo(1));
  });

  test('successful progress resets automatic retry backoff', () async {
    final directory = await Directory.systemTemp.createTemp(
      'pili_coordinator_backoff_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final attempts = <int>[];
    final delayStarted = StreamController<int>.broadcast();
    addTearDown(delayStarted.close);
    final calls = <int, int>{};

    final subscription = SubtitleTranslationCoordinator.attach(
      key: 'progress-resets-backoff',
      allowNewTranslation: true,
      retryDelay: (_, attempt) {
        attempts.add(attempt);
        delayStarted.add(attempt);
        return const Duration(days: 1);
      },
      createJob: (onUpdate, _) => SubtitleTranslationJob(
        cues: _cues(40),
        chunkSize: 20,
        concurrency: 1,
        cacheKey: 'progress-resets-backoff',
        cacheDirectory: directory.path,
        translate: (lines) async {
          final chunk = lines.first == '句0' ? 0 : 1;
          final call = (calls[chunk] ?? 0) + 1;
          calls[chunk] = call;
          if (call == 1 || (chunk == 1 && call == 2)) {
            throw StateError('retry chunk $chunk');
          }
          return lines.map((line) => 'vi $line').toList();
        },
        onUpdate: onUpdate,
      ),
      onUpdate: (_, _) {},
    );

    await delayStarted.stream.first;
    subscription.retryNow();
    await delayStarted.stream.first;

    expect(attempts.take(2), [0, 0]);
    subscription.retryNow();
    await subscription.whenComplete.timeout(const Duration(seconds: 2));
  });

  test('gives up after three no-progress rounds instead of hanging', () async {
    final directory = await Directory.systemTemp.createTemp(
      'pili_coordinator_idle_',
    );
    addTearDown(() => directory.delete(recursive: true));
    var calls = 0;
    final failed = Completer<void>();
    SubtitleTranslationProgress? lastProgress;
    final subscription = SubtitleTranslationCoordinator.attach(
      key: 'idle-give-up',
      allowNewTranslation: true,
      retryDelay: (_, _) => Duration.zero,
      createJob: (onUpdate, _) => SubtitleTranslationJob(
        cues: _cues(20),
        chunkSize: 20,
        concurrency: 1,
        cacheKey: 'idle-give-up',
        cacheDirectory: directory.path,
        translate: (lines) {
          calls++;
          throw StateError('provider unavailable');
        },
        onUpdate: onUpdate,
      ),
      onUpdate: (_, progress) {
        lastProgress = progress;
        if (progress.failedChunks > 0 && !failed.isCompleted) {
          failed.complete();
        }
      },
    );

    await failed.future;
    await subscription.whenComplete.timeout(const Duration(seconds: 2));

    // StateError 属于本地不可重试错误：每轮 job.run 只请求一次，
    // 协调器连续 3 轮无进展后必须收尾。
    expect(calls, 3);
    expect(lastProgress!.isComplete, isFalse);
    expect(lastProgress!.failedChunks, 1);
    expect(subscription.lastError, isA<StateError>());
  });
}
