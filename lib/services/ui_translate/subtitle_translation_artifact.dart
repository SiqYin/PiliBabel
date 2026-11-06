import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:PiliPlus/utils/path_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

class SubtitleTranslationArtifact {
  const SubtitleTranslationArtifact({
    required this.key,
    required this.videoKey,
    required this.cid,
    required this.targetLanguage,
    required this.sourceLan,
    required this.sourceIdentity,
    required this.cueCount,
    required this.verifierVersion,
    required this.cacheFilePath,
    required this.vttFilePath,
    required this.completedAt,
  });

  final String key;
  final String videoKey;
  final int cid;
  final String targetLanguage;
  final String sourceLan;
  final String sourceIdentity;
  final int cueCount;
  final int verifierVersion;
  final String cacheFilePath;
  final String vttFilePath;
  final DateTime completedAt;

  /// 3.7.2 及更早版本的合集批量子任务把 `'<videoKey>/<cid>'` 当 videoKey，
  /// 统一身份键之后这类旧记录仍要能归并到正确的任务键上，否则重启后
  /// 封面按钮/播放页看不到「已翻译」。
  String get stateVideoKey {
    final suffix = '/$cid';
    return videoKey.endsWith(suffix)
        ? videoKey.substring(0, videoKey.length - suffix.length)
        : videoKey;
  }

  static String makeKey({
    required String videoKey,
    required int cid,
    required String targetLanguage,
    required String sourceLan,
    required String sourceIdentity,
  }) => sha256
      .convert(
        utf8.encode(
          '$videoKey\n$cid\n$targetLanguage\n$sourceLan\n$sourceIdentity',
        ),
      )
      .toString();

  Map<String, dynamic> toJson() => {
    'key': key,
    'videoKey': videoKey,
    'cid': cid,
    'targetLanguage': targetLanguage,
    'sourceLan': sourceLan,
    'sourceIdentity': sourceIdentity,
    'cueCount': cueCount,
    'verifierVersion': verifierVersion,
    'cacheFilePath': cacheFilePath,
    'vttFilePath': vttFilePath,
    'completedAt': completedAt.toUtc().toIso8601String(),
  };

  factory SubtitleTranslationArtifact.fromJson(Map<String, dynamic> json) =>
      SubtitleTranslationArtifact(
        key: json['key'] as String,
        videoKey: json['videoKey'] as String,
        cid: (json['cid'] as num).toInt(),
        targetLanguage: json['targetLanguage'] as String,
        sourceLan: json['sourceLan'] as String,
        sourceIdentity: json['sourceIdentity'] as String,
        cueCount: (json['cueCount'] as num).toInt(),
        verifierVersion: (json['verifierVersion'] as num?)?.toInt() ?? 0,
        cacheFilePath: json['cacheFilePath'] as String,
        vttFilePath: json['vttFilePath'] as String,
        completedAt: DateTime.parse(json['completedAt'] as String),
      );
}

class SubtitleTranslationArtifactRegistry {
  SubtitleTranslationArtifactRegistry({String? directoryPath})
    : directoryPath =
          directoryPath ??
          path.join(appSupportDirPath, 'subtitle_translations');

  static final shared = SubtitleTranslationArtifactRegistry();
  static const _version = 1;

  final String directoryPath;
  final Map<String, SubtitleTranslationArtifact> _artifacts = {};
  Future<void> _writeTail = Future<void>.value();
  bool _initialized = false;

  File get _indexFile => File(path.join(directoryPath, 'artifacts.json'));

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final file = _indexFile;
      if (!await file.exists()) return;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic> || decoded['version'] != _version) {
        return;
      }
      final items = decoded['artifacts'];
      if (items is! List) return;
      for (final item in items.whereType<Map>()) {
        try {
          final artifact = SubtitleTranslationArtifact.fromJson(
            item.cast<String, dynamic>(),
          );
          _artifacts[artifact.key] = artifact;
        } catch (_) {
          // Keep the valid entries and fail closed for malformed records.
        }
      }
    } catch (_) {
      // A corrupt marker must never delete the durable translation caches.
    }
  }

  Future<List<SubtitleTranslationArtifact>> list() async {
    await initialize();
    return List.unmodifiable(_artifacts.values);
  }

  Future<SubtitleTranslationArtifact?> find({
    required String videoKey,
    required int cid,
    required String targetLanguage,
    required String sourceLan,
    required String sourceIdentity,
  }) async {
    await initialize();
    final key = SubtitleTranslationArtifact.makeKey(
      videoKey: videoKey,
      cid: cid,
      targetLanguage: targetLanguage,
      sourceLan: sourceLan,
      sourceIdentity: sourceIdentity,
    );
    final exact = _artifacts[key];
    if (exact != null) return exact;
    // 旧版合集批量子任务用 '<videoKey>/<cid>' 作 videoKey；回退一次，
    // 让用户已经翻好的译文不会因为这次身份键统一而全部作废。
    final legacyKey = SubtitleTranslationArtifact.makeKey(
      videoKey: '$videoKey/$cid',
      cid: cid,
      targetLanguage: targetLanguage,
      sourceLan: sourceLan,
      sourceIdentity: sourceIdentity,
    );
    return _artifacts[legacyKey];
  }

  Future<SubtitleTranslationArtifact?> findForPart({
    required String videoKey,
    required int cid,
    required String targetLanguage,
  }) async {
    await initialize();
    final matches =
        _artifacts.values
            .where(
              (artifact) =>
                  (artifact.videoKey == videoKey ||
                      artifact.videoKey == '$videoKey/$cid') &&
                  artifact.cid == cid &&
                  artifact.targetLanguage == targetLanguage,
            )
            .toList()
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return matches.isEmpty ? null : matches.first;
  }

  Future<bool> registerVerified(
    SubtitleTranslationArtifact artifact, {
    required FutureOr<bool> Function() verify,
  }) async {
    await initialize();
    if (!await verify()) return false;
    _artifacts[artifact.key] = artifact;
    try {
      await _save();
    } catch (_) {
      // 索引写失败时不能把这条产物留在内存里当成「已完成」：
      // 否则本次会话会显示已翻译，重启后索引里却没有，用户点重翻也无从下手。
      _artifacts.remove(artifact.key);
      rethrow;
    }
    return true;
  }

  Future<void> remove(String key) async {
    await initialize();
    if (_artifacts.remove(key) != null) await _save();
  }

  Future<void> removeMatching({
    required String videoKey,
    required int cid,
    required String targetLanguage,
    required String sourceLan,
    required String sourceIdentity,
  }) async {
    final artifact = await find(
      videoKey: videoKey,
      cid: cid,
      targetLanguage: targetLanguage,
      sourceLan: sourceLan,
      sourceIdentity: sourceIdentity,
    );
    if (artifact == null) return;
    try {
      final file = File(artifact.vttFilePath);
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // The registry entry must still be removed when an optional VTT vanished.
    }
    await remove(artifact.key);
  }

  Future<void> _save() {
    final completer = Completer<void>();
    _writeTail = _writeTail.then((_) async {
      try {
        final directory = Directory(directoryPath);
        await directory.create(recursive: true);
        final file = _indexFile;
        final temp = File(
          '${file.path}.${DateTime.now().microsecondsSinceEpoch}.tmp',
        );
        await temp.writeAsString(
          jsonEncode({
            'version': _version,
            'artifacts': _artifacts.values
                .map((artifact) => artifact.toJson())
                .toList(growable: false),
          }),
          flush: true,
        );
        try {
          await temp.rename(file.path);
        } on FileSystemException {
          if (await file.exists()) await file.delete();
          await temp.rename(file.path);
        }
        completer.complete();
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }
}
