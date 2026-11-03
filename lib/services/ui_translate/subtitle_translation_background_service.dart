import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models_new/video/video_play_info/subtitle.dart';
import 'package:PiliPlus/services/ai_chat/ai_chat_service.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_selection.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translate_service.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_coordinator.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_proxy.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_targets.dart';
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

enum SubtitleTranslationTaskPhase {
  idle,
  preparing,
  translating,
  complete,
  failed,
}

class SubtitleTranslationTaskState {
  const SubtitleTranslationTaskState({
    this.phase = SubtitleTranslationTaskPhase.idle,
    this.progress = 0,
    this.message,
  });

  final SubtitleTranslationTaskPhase phase;
  final double progress;
  final String? message;

  bool get isRunning =>
      phase == SubtitleTranslationTaskPhase.preparing ||
      phase == SubtitleTranslationTaskPhase.translating;
}

/// Starts subtitle translation from a card and keeps it alive after the card
/// (or its page) leaves the widget tree. Finished jobs share the same cache
/// identity as the player, so opening the video reuses the local result.
abstract final class SubtitleTranslationBackgroundService {
  static final RxMap<String, SubtitleTranslationTaskState> _states =
      <String, SubtitleTranslationTaskState>{}.obs;
  static final Set<String> _completed = {};
  static final Set<String> _activeBatchTaskKeys = {};
  static Future<void>? _loadFuture;
  static Future<void> _writeTail = Future.value();

  static SubtitleTranslationTaskState stateFor({
    required String videoKey,
    String? language,
  }) =>
      _states[_key(videoKey, language ?? Pref.uiTranslateLang)] ??
      const SubtitleTranslationTaskState();

  static Future<void> ensureInitialized() => _loadFuture ??= _loadIndex();

  static void markComplete({required String videoKey, String? language}) {
    final taskKey = _key(videoKey, language ?? Pref.uiTranslateLang);
    // The player can finish the selected child while its collection is still
    // translating. Keep aggregate progress visible until every child settles.
    if (_activeBatchTaskKeys.contains(taskKey)) return;
    _markTaskComplete(taskKey);
  }

  static void _markTaskComplete(String taskKey) {
    _completed.add(taskKey);
    _set(
      taskKey,
      const SubtitleTranslationTaskState(
        phase: SubtitleTranslationTaskPhase.complete,
        progress: 1,
        message: 'Đã dịch và lưu trên thiết bị',
      ),
    );
    unawaited(_saveIndex());
  }

  /// Removes one durable track cache and its card/player completion marker.
  /// Callers must not invoke this while the corresponding job is running.
  static Future<bool> removeCachedTranslation({
    required String videoKey,
    required String cacheKey,
    required List<SubtitleCue> cues,
    String? language,
  }) async {
    await ensureInitialized();
    final taskKey = _key(videoKey, language ?? Pref.uiTranslateLang);
    var removed = false;
    try {
      final file = SubtitleTranslationJob.cacheFileFor(cacheKey, cues);
      if (await file.exists()) {
        await file.delete();
        removed = true;
      }
    } on FileSystemException {
      // Clearing an optional cache must never affect the original subtitle.
    }
    _completed.remove(taskKey);
    _set(taskKey, const SubtitleTranslationTaskState());
    await _saveIndex();
    return removed;
  }

  static Future<void> start({
    required String videoKey,
    String? bvid,
    int? aid,
    int? cid,
    bool force = false,
    bool includeCollection = true,
  }) async {
    await ensureInitialized();
    final target = Pref.uiTranslateLang;
    final taskKey = _key(videoKey, target);
    final current = _states[taskKey];
    if (current?.isRunning == true ||
        (!force && current?.phase == SubtitleTranslationTaskPhase.complete)) {
      return;
    }
    if (!SubtitleTranslateService.needed) {
      _fail(
        taskKey,
        'Hãy bật AI Dịch và chọn ngôn ngữ đích trước khi dịch sub',
      );
      return;
    }
    if (bvid == null && aid == null) {
      _fail(taskKey, 'Video này không có mã để lấy phụ đề');
      return;
    }

    if (includeCollection && bvid != null) {
      _set(
        taskKey,
        const SubtitleTranslationTaskState(
          phase: SubtitleTranslationTaskPhase.preparing,
          message: 'Đang kiểm tra danh sách video',
        ),
      );
      final targets = await _resolveTranslationTargets(
        videoKey: videoKey,
        bvid: bvid,
        aid: aid,
        cid: cid,
      );
      if (targets.length > 1) {
        await _startBatch(
          parentVideoKey: videoKey,
          targets: targets,
          language: target,
          force: force,
        );
        return;
      }
    }

    await _startSingle(
      videoKey: videoKey,
      bvid: bvid,
      aid: aid,
      cid: cid,
      force: force,
    );
  }

  static Future<void> _startSingle({
    required String videoKey,
    String? bvid,
    int? aid,
    int? cid,
    bool force = false,
  }) async {
    await ensureInitialized();
    final target = Pref.uiTranslateLang;
    final taskKey = _key(videoKey, target);
    final current = _states[taskKey];
    if (current?.isRunning == true ||
        (!force && current?.phase == SubtitleTranslationTaskPhase.complete)) {
      return;
    }
    if (!SubtitleTranslateService.needed) {
      _fail(
        taskKey,
        'Hãy bật AI Dịch và chọn ngôn ngữ đích trước khi dịch sub',
      );
      return;
    }
    if (bvid == null && aid == null) {
      _fail(taskKey, 'Video này không có mã để lấy phụ đề');
      return;
    }

    _set(
      taskKey,
      const SubtitleTranslationTaskState(
        phase: SubtitleTranslationTaskPhase.preparing,
        message: 'Đang lấy phụ đề',
      ),
    );
    try {
      final resolvedCid =
          cid ??
          (await SearchHttp.ab2cWithDimension(aid: aid, bvid: bvid))?.cid;
      if (resolvedCid == null) {
        _fail(taskKey, 'Không lấy được phần video để dịch phụ đề');
        return;
      }
      final info = await VideoHttp.playInfo(
        aid: aid?.toString(),
        bvid: bvid,
        cid: resolvedCid,
      );
      final tracks = switch (info) {
        Success(:final response) => response.subtitle?.subtitles,
        _ => null,
      };
      if (tracks == null) {
        _fail(taskKey, 'Không lấy được danh sách phụ đề');
        return;
      }
      final choices = List<Subtitle>.of(tracks);
      Subtitle? track;
      List<SubtitleCue>? cues;
      while (choices.isNotEmpty) {
        final selection = SubtitleSelectionPolicy.choose(
          choices,
          target,
          canTranslate: true,
        );
        Subtitle? candidate;
        if (force) {
          // A forced retry must translate a Chinese source even when Bilibili
          // already offers a target-language track. Prefer the more complete
          // AI transcript, then fall back to the regular Chinese track.
          candidate = choices.firstWhereOrNull(
            (item) =>
                item.langTag == 'zh' &&
                (item.isAi || item.lan.startsWith('ai-')),
          );
          candidate ??= choices.firstWhereOrNull(
            (item) => item.langTag == 'zh',
          );
          if (candidate == null) break;
        } else {
          if (selection.index == 0) break;
          candidate = choices[selection.index - 1];
        }
        if (!force && !selection.translate) {
          markComplete(videoKey: videoKey, language: target);
          return;
        }
        final url = candidate.subtitleUrl;
        final body = url == null || url.isEmpty
            ? null
            : await VideoHttp.fetchSubtitleBody(url);
        final parsed = body == null
            ? const <SubtitleCue>[]
            : SubtitleCues.fromBody(body);
        if (parsed.isNotEmpty) {
          track = candidate;
          cues = parsed;
          break;
        }
        // Prefer the AI transcript, but an unavailable/empty AI track must
        // not prevent a usable original Chinese track from being translated.
        choices.remove(candidate);
      }
      if (track == null || cues == null) {
        _fail(taskKey, 'Không tải được phụ đề nguồn để dịch');
        return;
      }
      final sourceTrack = track;
      final sourceCues = cues;
      final proxies = _readProxies();
      final pool = SubtitleTranslationProxyPool.shared(
        proxies,
        directWorkers: Pref.subtitleConcurrency,
      );
      final cacheKey =
          '${bvid ?? 'av$aid'}/$resolvedCid/${sourceTrack.lan}/$target';
      // A retranslation gets an isolated checkpoint. The canonical cache stays
      // available to the player until all replacement chunks have succeeded.
      final activeCacheKey = force
          ? '$cacheKey/retranslate/${DateTime.now().microsecondsSinceEpoch}'
          : cacheKey;
      var replacementSaved = !force;
      Future<void>? replacementPromotion;
      final subscription = SubtitleTranslationCoordinator.attach(
        key: SubtitleTranslationJob.cacheIdentity(activeCacheKey, sourceCues),
        allowNewTranslation: true,
        priority: SubtitleTranslationPriority.userRequested,
        createJob: (onUpdate, priority) => SubtitleTranslationJob(
          cues: sourceCues,
          chunkSize: Pref.subtitleChunkSize,
          concurrency: pool.workerCount,
          contextOverlap: Pref.subtitleContextOverlap,
          targetLanguage: target,
          cacheKey: activeCacheKey,
          onUpdate: onUpdate,
          translate: SubtitleTranslateService.translateChunk,
          translateWithContext: (lines, context) => pool.run(
            (proxy) async {
              try {
                return await SubtitleTranslateService.translateChunk(
                  lines,
                  contextLines: context,
                  proxy: proxy,
                );
              } on AiApiException catch (error) {
                if (proxy != null && error.statusCode == null) {
                  pool.markUnavailable(proxy);
                }
                rethrow;
              }
            },
            priorityHandle: priority,
          ),
        ),
        onUpdate: (_, progress) {
          if (progress.isComplete) {
            if (!replacementSaved) {
              replacementSaved = true;
              _set(
                taskKey,
                const SubtitleTranslationTaskState(
                  phase: SubtitleTranslationTaskPhase.translating,
                  progress: 1,
                  message: 'Đang lưu bản dịch mới',
                ),
              );
              replacementPromotion =
                  _replaceCachedTranslation(
                        activeCacheKey: activeCacheKey,
                        canonicalCacheKey: cacheKey,
                        cues: sourceCues,
                      )
                      .then((_) {
                        markComplete(videoKey: videoKey, language: target);
                      })
                      .catchError((_) {
                        _fail(
                          taskKey,
                          'Không thể lưu bản dịch mới, chạm để thử lại',
                        );
                      });
              unawaited(replacementPromotion);
            } else {
              markComplete(videoKey: videoKey, language: target);
            }
            return;
          }
          final percent = (progress.ratio * 100).round();
          _set(
            taskKey,
            SubtitleTranslationTaskState(
              phase: SubtitleTranslationTaskPhase.translating,
              progress: progress.ratio,
              message: progress.processedCues == 0
                  ? 'Đang xếp hàng dịch ưu tiên'
                  : progress.failedChunks > 0
                  ? 'Đang thử lại $percent%'
                  : 'Đang dịch $percent%',
            ),
          );
        },
      );
      await subscription.whenComplete;
      await replacementPromotion;
      subscription.detach();
    } catch (_) {
      _fail(taskKey, 'Không thể bắt đầu dịch sub, chạm để thử lại');
    }
  }

  static Future<List<SubtitleTranslationTarget>> _resolveTranslationTargets({
    required String videoKey,
    required String bvid,
    int? aid,
    int? cid,
  }) async {
    try {
      final intro = await VideoHttp.videoIntro(bvid: bvid);
      if (intro case Success(:final response)) {
        return subtitleTranslationTargetsFromDetail(
          detail: response,
          fallbackVideoKey: videoKey,
          fallbackBvid: bvid,
          fallbackAid: aid,
          selectedCid: cid,
        );
      }
    } catch (_) {
      // A failed optional list lookup falls back to the selected video only.
    }
    return [
      SubtitleTranslationTarget(
        videoKey: videoKey,
        bvid: bvid,
        aid: aid,
        cid: cid,
      ),
    ];
  }

  static Future<void> _startBatch({
    required String parentVideoKey,
    required List<SubtitleTranslationTarget> targets,
    required String language,
    required bool force,
  }) async {
    final parentTaskKey = _key(parentVideoKey, language);
    _activeBatchTaskKeys.add(parentTaskKey);
    _completed.remove(parentTaskKey);
    if (force) {
      // Keep the old subtitle cache usable, but reset display markers so an
      // explicit collection retranslation cannot look complete immediately.
      for (final target in targets) {
        final childTaskKey = _key(target.videoKey, language);
        _completed.remove(childTaskKey);
        _set(childTaskKey, const SubtitleTranslationTaskState());
      }
    }
    unawaited(_saveIndex());
    var finalized = false;

    void syncState() {
      if (finalized) return;
      final states = [
        for (final target in targets)
          stateFor(videoKey: target.videoKey, language: language),
      ];
      final completed = states
          .where(
            (state) => state.phase == SubtitleTranslationTaskPhase.complete,
          )
          .length;
      final failed = states
          .where((state) => state.phase == SubtitleTranslationTaskPhase.failed)
          .length;
      final running = states.where((state) => state.isRunning).length;
      final progress =
          states.fold<double>(
            0,
            (sum, state) =>
                sum +
                (state.phase == SubtitleTranslationTaskPhase.complete
                    ? 1
                    : state.progress),
          ) /
          targets.length;
      if (completed == targets.length) {
        finalized = true;
        _markTaskComplete(parentTaskKey);
        return;
      }
      if (running == 0 && completed + failed == targets.length && failed > 0) {
        finalized = true;
        _fail(
          parentTaskKey,
          '$failed/${targets.length} video bị lỗi, chạm để thử lại',
        );
        return;
      }
      _set(
        parentTaskKey,
        SubtitleTranslationTaskState(
          phase: running == 0
              ? SubtitleTranslationTaskPhase.preparing
              : SubtitleTranslationTaskPhase.translating,
          progress: progress,
          message: 'Đang dịch $completed/${targets.length} video',
        ),
      );
    }

    syncState();
    final timer = Timer.periodic(
      const Duration(milliseconds: 350),
      (_) => syncState(),
    );
    try {
      final queue = Queue<SubtitleTranslationTarget>.of(targets);

      Future<void> runNext() async {
        while (queue.isNotEmpty) {
          final target = queue.removeFirst();
          await _startSingle(
            videoKey: target.videoKey,
            bvid: target.bvid,
            aid: target.aid,
            cid: target.cid,
            force: force,
          );
        }
      }

      // Keep several videos progressing without flooding Bilibili metadata and
      // subtitle endpoints for very large collections. Chunk/API concurrency
      // remains governed by the shared direct + proxy route pool.
      await Future.wait([
        for (var i = 0; i < targets.length.clamp(1, 3); i++) runNext(),
      ]);
      syncState();
    } finally {
      timer.cancel();
      syncState();
      _activeBatchTaskKeys.remove(parentTaskKey);
    }
  }

  static List<SubtitleTranslationProxy> _readProxies() {
    try {
      return SubtitleTranslationProxy.parseMany(
        Pref.subtitleTranslationProxies,
        defaultType: Pref.subtitleTranslationProxyType == 'socks5'
            ? SubtitleTranslationProxyType.socks5
            : SubtitleTranslationProxyType.http,
      );
    } on FormatException {
      // Invalid optional proxy configuration never blocks direct translation.
      return const [];
    }
  }

  /// Atomically promotes a completed replacement only after every chunk has
  /// been checkpointed. If the app is closed mid-translation, the old cache
  /// is therefore still usable on the next launch.
  static Future<void> _replaceCachedTranslation({
    required String activeCacheKey,
    required String canonicalCacheKey,
    required List<SubtitleCue> cues,
  }) async {
    final source = SubtitleTranslationJob.cacheFileFor(activeCacheKey, cues);
    final destination = SubtitleTranslationJob.cacheFileFor(
      canonicalCacheKey,
      cues,
    );
    if (!await source.exists()) {
      throw const FileSystemException('Replacement subtitle cache is missing');
    }
    await destination.parent.create(recursive: true);
    // Both files live in the same cache directory. On Android, macOS and
    // Linux, rename replaces the old completed file atomically; there is never
    // a partially written canonical cache for the player to consume.
    await source.rename(destination.path);
  }

  static void _set(String key, SubtitleTranslationTaskState state) {
    _states[key] = state;
  }

  static void _fail(String key, String message) {
    _set(
      key,
      SubtitleTranslationTaskState(
        phase: SubtitleTranslationTaskPhase.failed,
        message: message,
      ),
    );
  }

  static String _key(String videoKey, String language) => '$videoKey/$language';

  static File get _indexFile => File(
    path.join(appSupportDirPath, 'subtitle_translations', 'video_index.json'),
  );

  static Future<void> _loadIndex() async {
    try {
      final file = _indexFile;
      if (!file.existsSync()) return;
      final data = jsonDecode(await file.readAsString());
      if (data is! Map || data['completed'] is! List) return;
      for (final value in data['completed'] as List) {
        if (value is! String) continue;
        _completed.add(value);
        _states[value] = const SubtitleTranslationTaskState(
          phase: SubtitleTranslationTaskPhase.complete,
          progress: 1,
          message: 'Đã dịch và lưu trên thiết bị',
        );
      }
    } catch (_) {
      // A missing or old status index never invalidates translation caches.
    }
  }

  static Future<void> _saveIndex() {
    _writeTail = _writeTail.then((_) async {
      try {
        final file = _indexFile;
        await file.parent.create(recursive: true);
        final temp = File('${file.path}.tmp');
        await temp.writeAsString(
          jsonEncode({
            'version': 1,
            'completed': _completed.toList()..sort(),
          }),
        );
        await temp.rename(file.path);
      } catch (_) {
        // The translation cache remains valid even if its display index fails.
      }
    });
    return _writeTail;
  }
}
