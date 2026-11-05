import 'dart:convert';
import 'dart:io';

import 'package:PiliPlus/services/ui_translate/subtitle_translation_artifact.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_text_quality.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

SubtitleTranslationArtifact _artifact(
  String root, {
  int cid = 1,
  String source = 'source-a',
}) {
  final key = SubtitleTranslationArtifact.makeKey(
    videoKey: 'BV1',
    cid: cid,
    targetLanguage: 'vi',
    sourceLan: 'ai-zh',
    sourceIdentity: source,
  );
  return SubtitleTranslationArtifact(
    key: key,
    videoKey: 'BV1',
    cid: cid,
    targetLanguage: 'vi',
    sourceLan: 'ai-zh',
    sourceIdentity: source,
    cueCount: 20,
    verifierVersion: SubtitleTextQuality.verifierVersion,
    cacheFilePath: path.join(root, '$key.json'),
    vttFilePath: path.join(root, '$key.vtt'),
    completedAt: DateTime.utc(2026, 1, 1),
  );
}

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('subtitle-artifact-');
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test('round trips a verified artifact', () async {
    final registry = SubtitleTranslationArtifactRegistry(
      directoryPath: directory.path,
    );
    final artifact = _artifact(directory.path);
    expect(
      await registry.registerVerified(artifact, verify: () => true),
      isTrue,
    );

    final reloaded = SubtitleTranslationArtifactRegistry(
      directoryPath: directory.path,
    );
    final found = await reloaded.find(
      videoKey: 'BV1',
      cid: 1,
      targetLanguage: 'vi',
      sourceLan: 'ai-zh',
      sourceIdentity: 'source-a',
    );
    expect(found?.key, artifact.key);
  });

  test('part and source identities never collide', () {
    expect(
      _artifact(directory.path, cid: 1).key,
      isNot(_artifact(directory.path, cid: 2).key),
    );
    expect(
      _artifact(directory.path, source: 'a').key,
      isNot(_artifact(directory.path, source: 'b').key),
    );
  });

  test('failed verification is not persisted', () async {
    final registry = SubtitleTranslationArtifactRegistry(
      directoryPath: directory.path,
    );
    expect(
      await registry.registerVerified(
        _artifact(directory.path),
        verify: () => false,
      ),
      isFalse,
    );
    expect(await registry.list(), isEmpty);
  });

  test('corrupt registry fails closed without deleting cache files', () async {
    final cache = File(path.join(directory.path, 'existing-cache.json'));
    await cache.writeAsString('cache');
    await File(path.join(directory.path, 'artifacts.json')).writeAsString('{');

    final registry = SubtitleTranslationArtifactRegistry(
      directoryPath: directory.path,
    );
    expect(await registry.list(), isEmpty);
    expect(await cache.exists(), isTrue);
  });

  test('atomic save replaces the previous index with valid JSON', () async {
    final registry = SubtitleTranslationArtifactRegistry(
      directoryPath: directory.path,
    );
    await registry.registerVerified(
      _artifact(directory.path, cid: 1),
      verify: () => true,
    );
    await registry.registerVerified(
      _artifact(directory.path, cid: 2),
      verify: () => true,
    );
    final decoded = jsonDecode(
      await File(path.join(directory.path, 'artifacts.json')).readAsString(),
    ) as Map<String, dynamic>;
    expect(decoded['version'], 1);
    expect(decoded['artifacts'], hasLength(2));
    expect(
      directory.listSync().whereType<File>().where(
        (file) => file.path.endsWith('.tmp'),
      ),
      isEmpty,
    );
  });
}
