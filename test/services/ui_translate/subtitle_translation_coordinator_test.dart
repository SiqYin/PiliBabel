import 'dart:async';
import 'dart:io';

import 'package:PiliPlus/services/ui_translate/subtitle_translation_coordinator.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';
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
      SubtitleTranslationJob factory(SubtitleTranslationUpdate onUpdate) =>
          SubtitleTranslationJob(
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
}
