import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/services/account_service.dart';
import 'package:PiliPlus/models_new/video/video_play_info/subtitle.dart';
import 'package:PiliPlus/services/ai_chat/ai_chat_service.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_source_resolver.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_text_quality.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translate_service.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_artifact.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_coordinator.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_proxy.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_targets.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

enum SubtitleTranslationTaskPhase {
  idle,
  preparing,
  translating,
  verifying,
  complete,
  failed,
}

class SubtitleTranslationTaskState {
  const SubtitleTranslationTaskState({
    this.phase = SubtitleTranslationTaskPhase.idle,
    this.progress = 0,
    this.message,
    this.nativeTrackAvailable = false,
    this.noSource = false,
  });

  final SubtitleTranslationTaskPhase phase;
  final double progress;
  final String? message;

  /// 本站（Bilibili）已提供目标语言字幕，无需 AI 翻译。
  final bool nativeTrackAvailable;

  /// 这个视频根本没有可用的中文字幕轨。
  ///
  /// 必须和「失败」分开：B 站大多数视频没有 CC 字幕，按下按钮必然没东西可翻。
  /// 以前这种情况被当成失败（红图标 + 「点击重试」），看起来像功能坏了，而重试
  /// 永远不可能成功 —— 因为源本来就不存在。
  final bool noSource;

  bool get isRunning =>
      phase == SubtitleTranslationTaskPhase.preparing ||
      phase == SubtitleTranslationTaskPhase.translating ||
      phase == SubtitleTranslationTaskPhase.verifying;
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
    int? cid,
    String? language,
  }) =>
      _states[_key(videoKey, language ?? Pref.uiTranslateLang, cid)] ??
      const SubtitleTranslationTaskState();

  static Future<void> ensureInitialized() => _loadFuture ??= _loadIndex();

  static void markComplete({
    required String videoKey,
    required int cid,
    String? language,
  }) {
    final taskKey = _key(videoKey, language ?? Pref.uiTranslateLang, cid);
    // The player can finish the selected child while its collection is still
    // translating. Keep aggregate progress visible until every child settles.
    if (_activeBatchTaskKeys.contains(taskKey)) return;
    _markTaskComplete(taskKey);
  }

  static void _markTaskComplete(String taskKey) {
    _completed.add(taskKey);
    _set(
      taskKey,
      SubtitleTranslationTaskState(
        phase: SubtitleTranslationTaskPhase.complete,
        progress: 1,
        message: uiTx('已翻译并保存到设备'),
      ),
    );
    unawaited(_saveIndex());
  }

  /// Removes one durable track cache and its card/player completion marker.
  /// Callers must not invoke this while the corresponding job is running.
  static Future<bool> removeCachedTranslation({
    required String videoKey,
    required int cid,
    required String cacheKey,
    required List<SubtitleCue> cues,
    String? language,
  }) async {
    await ensureInitialized();
    final taskKey = _key(videoKey, language ?? Pref.uiTranslateLang, cid);
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
    final taskKey = _key(videoKey, target, cid);
    final current = _states[taskKey];
    if (current?.isRunning == true ||
        (!force && current?.phase == SubtitleTranslationTaskPhase.complete)) {
      return;
    }
    if (!SubtitleTranslateService.needed) {
      // 失败原因分两种，说清楚才不会让人以为「重试」有用：
      // 没开 AI 翻译 → 去设置里开；目标语言就是简体中文 → 没有可翻的东西。
      _fail(
        taskKey,
        Get.isRegistered<UiTranslateService>() && UiTranslateService.to.enabled
            ? uiTx('目标语言是简体中文，字幕无需翻译')
            : uiTx('请先开启 AI 翻译并选择目标语言'),
      );
      return;
    }
    if (bvid == null && aid == null) {
      _fail(taskKey, uiTx('该视频缺少可获取字幕的编号'));
      return;
    }

    if (includeCollection && bvid != null) {
      _set(
        taskKey,
        SubtitleTranslationTaskState(
          phase: SubtitleTranslationTaskPhase.preparing,
          message: uiTx('正在检查视频列表'),
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
          parentCid: cid,
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
      // 合集逐集翻译时不要每集弹一次 toast，收尾由 _startBatch 统一提示。
      notify: false,
    );
  }

  static Future<void> _startSingle({
    required String videoKey,
    String? bvid,
    int? aid,
    int? cid,
    bool force = false,
    bool notify = true,
  }) async {
    await ensureInitialized();
    final target = Pref.uiTranslateLang;
    var taskKey = _key(videoKey, target, cid);
    final current = _states[taskKey];
    if (current?.isRunning == true ||
        (!force && current?.phase == SubtitleTranslationTaskPhase.complete)) {
      return;
    }
    if (!SubtitleTranslateService.needed) {
      // 失败原因分两种，说清楚才不会让人以为「重试」有用：
      // 没开 AI 翻译 → 去设置里开；目标语言就是简体中文 → 没有可翻的东西。
      _fail(
        taskKey,
        Get.isRegistered<UiTranslateService>() && UiTranslateService.to.enabled
            ? uiTx('目标语言是简体中文，字幕无需翻译')
            : uiTx('请先开启 AI 翻译并选择目标语言'),
      );
      return;
    }
    if (bvid == null && aid == null) {
      _fail(taskKey, uiTx('该视频缺少可获取字幕的编号'));
      return;
    }

    _set(
      taskKey,
      SubtitleTranslationTaskState(
        phase: SubtitleTranslationTaskPhase.preparing,
        message: uiTx('正在获取字幕'),
      ),
    );
    try {
      final resolvedCid =
          cid ??
          (await SearchHttp.ab2cWithDimension(aid: aid, bvid: bvid))?.cid;
      if (resolvedCid == null) {
        _fail(taskKey, uiTx('无法获取视频分P'));
        return;
      }
      if (cid == null) {
        final resolvedTaskKey = _key(videoKey, target, resolvedCid);
        if (resolvedTaskKey != taskKey) {
          _states.remove(taskKey);
          taskKey = resolvedTaskKey;
          _set(
            taskKey,
            SubtitleTranslationTaskState(
              phase: SubtitleTranslationTaskPhase.preparing,
              message: uiTx('正在获取字幕'),
            ),
          );
        }
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
      if (tracks == null || tracks.isEmpty) {
        // 实测：未登录时 /x/player/v2 对**有 CC 的视频**也返回空列表，
        // 所以空列表要先分辨「没登录」和「真没字幕」——两者的处理完全不同。
        final loggedIn =
            Get.isRegistered<AccountService>() &&
            Get.find<AccountService>().isLogin.value;
        _noSource(
          taskKey,
          loggedIn
              ? uiTx('这个视频没有可用的中文字幕')
              : uiTx('字幕需要登录后才能获取，请先登录'),
        );
        return;
      }
      final resolved = await SubtitleSourceResolver.resolve(
        tracks: List<Subtitle>.of(tracks),
        targetLanguage: target,
        forceChineseSource: force,
        loadCues: (candidate) async {
          final url = candidate.subtitleUrl;
          final body = url == null || url.isEmpty
              ? null
              : await VideoHttp.fetchSubtitleBody(url);
          return body == null
              ? const <SubtitleCue>[]
              : SubtitleCues.fromBody(body);
        },
      );
      if (resolved == null) {
        // 有轨但都下不下来 / 时间轴不安全：对用户来说同样是「这个视频没有能用的
        // 中文字幕」，给重试没有意义。
        _noSource(taskKey, uiTx('这个视频没有可用的中文字幕'));
        return;
      }
      if (resolved.kind == SubtitleSourceKind.nativeTarget) {
        _set(
          taskKey,
          SubtitleTranslationTaskState(
            phase: SubtitleTranslationTaskPhase.complete,
            progress: 1,
            message: uiTx('Bilibili 已提供目标语言字幕'),
            nativeTrackAvailable: true,
          ),
        );
        return;
      }
      final sourceTrack = resolved.track;
      final sourceCues = resolved.cues;
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
      final sourceIdentity = SubtitleTranslationJob.cacheIdentity(
        cacheKey,
        sourceCues,
      );
      var completionScheduled = false;
      SubtitleTranslationProgress? lastProgress;
      Future<void>? completionPromotion;
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
          maxRetries: 0,
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
                if (proxy != null &&
                    SubtitleTranslationProxyPool.shouldCooldownStatus(
                      error.statusCode,
                    )) {
                  pool.markUnavailable(proxy);
                }
                rethrow;
              }
            },
            priorityHandle: priority,
          ),
        ),
        onUpdate: (vtt, progress) {
          lastProgress = progress;
          if (progress.retryExhausted) {
            _fail(
              taskKey,
              'Tự động thử lại đã dừng ở '
              '${(progress.ratio * 100).round()}%, chạm để thử lại',
            );
            return;
          }
          if (progress.isComplete && !completionScheduled) {
            completionScheduled = true;
            _set(
              taskKey,
              SubtitleTranslationTaskState(
                phase: SubtitleTranslationTaskPhase.verifying,
                progress: 1,
                message: uiTx('正在校验并保存译文字幕'),
              ),
            );
            completionPromotion =
                () async {
                  if (force) {
                    await _replaceCachedTranslation(
                      activeCacheKey: activeCacheKey,
                      canonicalCacheKey: cacheKey,
                      cues: sourceCues,
                    );
                  }
                  final registered = await registerCompletedArtifact(
                    videoKey: bvid ?? 'av$aid',
                    cid: resolvedCid,
                    targetLanguage: target,
                    sourceLan: sourceTrack.lan,
                    sourceIdentity: sourceIdentity,
                    cacheKey: cacheKey,
                    cues: sourceCues,
                    vtt: vtt,
                  );
                  if (!registered) {
                    throw const FormatException(
                      'completed subtitle failed full validation',
                    );
                  }
                  markComplete(
                    videoKey: videoKey,
                    cid: resolvedCid,
                    language: target,
                  );
                }().catchError((_) {
                  _fail(
                    taskKey,
                    uiTx('译文未通过校验或无法保存，点击重试'),
                  );
                });
            unawaited(completionPromotion);
            return;
          }
          final percent = (progress.ratio * 100).round();
          _set(
            taskKey,
            SubtitleTranslationTaskState(
              phase: progress.phase == SubtitleTranslationPhase.verifying
                  ? SubtitleTranslationTaskPhase.verifying
                  : SubtitleTranslationTaskPhase.translating,
              progress: progress.ratio,
              message: progress.phase == SubtitleTranslationPhase.verifying
                  ? uiTx('正在校验译文字幕')
                  : progress.processedCues == 0
                  ? uiTx('正在排队等待优先翻译')
                  : progress.failedChunks > 0
                  ? uiTxP('正在重试 {0} 个出错分块（{1}%）', [
                      progress.failedChunks,
                      percent,
                    ])
                  : uiTxP('正在翻译 {0}/{1} 句（{2}%）', [
                      progress.processedCues,
                      progress.totalCues,
                      percent,
                    ]),
            ),
          );
        },
      );
      try {
        await subscription.whenComplete;
        await completionPromotion;
        final progress = lastProgress;
        if (progress != null &&
            !progress.isComplete &&
            (_states[taskKey]?.isRunning ?? false)) {
          // 带上真实原因（AiApiException / FormatException / TimeoutException…）。
          // 重试若干轮仍无进展时协调器会主动收尾，这里就是那一刻。
          final cause = subscription.lastError;
          _fail(
            taskKey,
            cause == null
                ? uiTxP('还有 {0} 个分块出错，点击重试', [progress.failedChunks])
                : uiTxP('还有 {0} 个分块出错（{1}），点击重试', [
                    progress.failedChunks,
                    '${cause.runtimeType}',
                  ]),
          );
        }
      } finally {
        subscription.detach();
      }
    } catch (error) {
      // 别再把原因吞掉：以前这里只有一句「无法开始翻译」，出了必失败的问题
      // 只能靠猜。模板里带上异常类型，既能让用户看懂，也不会给每条错误
      // 造一条新的翻译词条。
      _fail(
        taskKey,
        uiTxP('无法开始翻译字幕，点击重试（{0}）', ['${error.runtimeType}']),
      );
    } finally {
      // 结果反馈：完成给一句话，失败也给一句话。
      // 之前只有封面按钮那个小图标从「转圈」变成对勾，用户根本注意不到。
      if (notify) _notifyOutcome(taskKey);
    }
  }

  /// 后台任务结束时的用户反馈（单集）。
  static void _notifyOutcome(String taskKey) {
    switch (_states[taskKey]?.phase) {
      case SubtitleTranslationTaskPhase.complete:
        SmartDialog.showToast(uiTx('字幕已预翻译完成'));
      case SubtitleTranslationTaskPhase.failed:
        SmartDialog.showToast(uiTx('字幕预翻译失败，可点按钮重试'));
      default:
        break;
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
    required int? parentCid,
    required List<SubtitleTranslationTarget> targets,
    required String language,
    required bool force,
  }) async {
    final parentTaskKey = _key(parentVideoKey, language, parentCid);
    _activeBatchTaskKeys.add(parentTaskKey);
    _completed.remove(parentTaskKey);
    if (force) {
      // Keep the old subtitle cache usable, but reset display markers so an
      // explicit collection retranslation cannot look complete immediately.
      for (final target in targets) {
        final childTaskKey = _key(target.videoKey, language, target.cid);
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
          stateFor(
            videoKey: target.videoKey,
            cid: target.cid,
            language: language,
          ),
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
        SmartDialog.showToast(uiTxP('全 {0} 个分P字幕已预翻译完成', [
          targets.length,
        ]));
        return;
      }
      if (running == 0 && completed + failed == targets.length && failed > 0) {
        finalized = true;
        _fail(
          parentTaskKey,
          uiTxP('{0}/{1} 个分P失败，点击重试', [failed, targets.length]),
        );
        SmartDialog.showToast(uiTxP('{0}/{1} 个分P字幕预翻译失败', [
          failed,
          targets.length,
        ]));
        return;
      }
      _set(
        parentTaskKey,
        SubtitleTranslationTaskState(
          phase: running == 0
              ? SubtitleTranslationTaskPhase.preparing
              : SubtitleTranslationTaskPhase.translating,
          progress: progress,
          message: uiTxP('已翻译 {0}/{1} 个分P', [completed, targets.length]),
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
            // 批量里逐集不弹 toast，统一在 syncState 里汇报一次总数。
            notify: false,
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

  static Future<bool> registerCompletedArtifact({
    required String videoKey,
    required int cid,
    required String targetLanguage,
    required String sourceLan,
    required String sourceIdentity,
    required String cacheKey,
    required List<SubtitleCue> cues,
    required String vtt,
  }) async {
    if (!SubtitleTranslationOutput.isCompleteTranslatedVtt(
      cues,
      vtt,
      targetLanguage: targetLanguage,
    )) {
      return false;
    }
    final directory = Directory(
      path.join(appSupportDirPath, 'subtitle_translations'),
    );
    await directory.create(recursive: true);
    final vttFile = File(path.join(directory.path, '$sourceIdentity.vtt'));
    final temp = File(
      '${vttFile.path}.${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    await temp.writeAsString(vtt, flush: true);
    try {
      await temp.rename(vttFile.path);
    } on FileSystemException {
      if (await vttFile.exists()) await vttFile.delete();
      await temp.rename(vttFile.path);
    }
    final artifact = SubtitleTranslationArtifact(
      key: SubtitleTranslationArtifact.makeKey(
        videoKey: videoKey,
        cid: cid,
        targetLanguage: targetLanguage,
        sourceLan: sourceLan,
        sourceIdentity: sourceIdentity,
      ),
      videoKey: videoKey,
      cid: cid,
      targetLanguage: targetLanguage,
      sourceLan: sourceLan,
      sourceIdentity: sourceIdentity,
      cueCount: cues.length,
      verifierVersion: SubtitleTextQuality.verifierVersion,
      cacheFilePath: SubtitleTranslationJob.cacheFileFor(cacheKey, cues).path,
      vttFilePath: vttFile.path,
      completedAt: DateTime.now(),
    );
    return SubtitleTranslationArtifactRegistry.shared.registerVerified(
      artifact,
      verify: () async {
        if (!await vttFile.exists()) return false;
        return SubtitleTranslationOutput.isCompleteTranslatedVtt(
          cues,
          await vttFile.readAsString(),
          targetLanguage: targetLanguage,
        );
      },
    );
  }

  static void _set(String key, SubtitleTranslationTaskState state) {
    _states[key] = state;
  }

  /// 源不存在（不是失败）：图标置灰、点按不再重试。
  static void _noSource(String key, String message) {
    _set(
      key,
      SubtitleTranslationTaskState(message: message, noSource: true),
    );
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

  static String _key(String videoKey, String language, [int? cid]) =>
      cid == null ? '$videoKey/$language' : '$videoKey/$cid/$language';

  static File get _indexFile => File(
    path.join(appSupportDirPath, 'subtitle_translations', 'video_index.json'),
  );

  static Future<void> _loadIndex() async {
    // `video_index.json` from older builds is only a display hint keyed by
    // video/language. Never restore completion from it because it cannot prove
    // the part, source fingerprint, cue count or timeline.
    try {
      final file = _indexFile;
      if (file.existsSync()) await file.readAsString();
    } catch (_) {
      // A missing or old status index never invalidates translation caches.
    }

    final artifacts = await SubtitleTranslationArtifactRegistry.shared.list();
    for (final artifact in artifacts) {
      try {
        final cacheFile = File(artifact.cacheFilePath);
        final vttFile = File(artifact.vttFilePath);
        if (!await cacheFile.exists() || !await vttFile.exists()) continue;
        final taskKey = _key(
          artifact.videoKey,
          artifact.targetLanguage,
          artifact.cid,
        );
        if (artifact.verifierVersion != SubtitleTextQuality.verifierVersion) {
          _states[taskKey] = SubtitleTranslationTaskState(
            phase: SubtitleTranslationTaskPhase.failed,
            message: uiTx('旧译文需要重新校验，打开视频后自动进行'),
          );
          continue;
        }
        if (!await _storedArtifactIsIntact(
          artifact: artifact,
          cacheFile: cacheFile,
          vttFile: vttFile,
        )) {
          _states[taskKey] = SubtitleTranslationTaskState(
            phase: SubtitleTranslationTaskPhase.failed,
            message: uiTx('已保存的译文需要校验或修复，点击重试'),
          );
          continue;
        }
        _completed.add(taskKey);
        _states[taskKey] = SubtitleTranslationTaskState(
          phase: SubtitleTranslationTaskPhase.complete,
          progress: 1,
          message: uiTx('已翻译并保存到设备'),
        );
      } catch (_) {
        // Invalid artifacts stay on disk for targeted repair, but are never
        // advertised as a completed translated subtitle.
      }
    }
  }

  static Future<bool> _storedArtifactIsIntact({
    required SubtitleTranslationArtifact artifact,
    required File cacheFile,
    required File vttFile,
  }) async {
    try {
      final checkpoint =
          jsonDecode(await cacheFile.readAsString()) as Map<String, dynamic>;
      if (checkpoint['complete'] != true ||
          (checkpoint['verifierVersion'] as num?)?.toInt() !=
              SubtitleTextQuality.verifierVersion) {
        return false;
      }
      final texts = List<String>.from(
        (checkpoint['texts'] as List).cast<String>(),
      );
      final cues = SubtitleCues.fromVtt(await vttFile.readAsString());
      if (texts.length != artifact.cueCount ||
          cues.length != artifact.cueCount ||
          !SubtitleCues.hasSafePlaybackTimeline(cues)) {
        return false;
      }
      for (var index = 0; index < cues.length; index++) {
        final text = cues[index].text;
        if (text != texts[index] ||
            (artifact.targetLanguage.toLowerCase().startsWith('vi') &&
                SubtitleTextQuality.containsHan(text))) {
          return false;
        }
      }
      return true;
    } catch (_) {
      return false;
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
            'version': 2,
            // These are migration/debug hints only. Startup completion state
            // is reconstructed exclusively from verified artifacts.
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
