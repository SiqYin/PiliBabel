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
import 'package:PiliPlus/services/ui_translate/prewarm_strings.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_source_resolver.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_text_quality.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translate_service.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_artifact.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_coordinator.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_proxy.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_task_state.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_targets.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_video_key.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';

// 状态模型以前定义在本文件里，其它文件通过 import 本文件拿到类型。
// 移到纯 Dart 文件后仍 re-export，保持所有既有 import 不变。
export 'package:PiliPlus/services/ui_translate/subtitle_task_state.dart';
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

/// Starts subtitle translation from a card and keeps it alive after the card
/// (or its page) leaves the widget tree. Finished jobs share the same cache
/// identity as the player, so opening the video reuses the local result.
abstract final class SubtitleTranslationBackgroundService {
  static final RxMap<String, SubtitleTranslationTaskState> _states =
      <String, SubtitleTranslationTaskState>{}.obs;

  /// 封面按钮通常没有 cid（查询键 `bvid/语言`），后台任务解析出 cid 后改用
  /// `bvid/cid/语言`。一个视频可能有多个分P（多个 cid），所以这里是
  /// **一对多**：cardKey → 所有分P的任务键，查询时聚合，而不是让最后一个
  /// cid 的状态覆盖前面所有分P（单跳别名会误报「已完成」或「还在翻译」）。
  static final Map<String, Set<String>> _cardTaskKeys = {};
  static final Map<String, String> _taskCardKeys = {};
  static final Set<String> _completed = {};
  static final Set<String> _activeBatchTaskKeys = {};

  /// 「已受理但还没走到第一次 `_set`」的入口键。没有它，连点两次按钮会同时
  /// 通过状态检查，同一份任务被 attach 两遍，完成时第二次「替换缓存 → 重命名」
  /// 必然失败，把已经成功的任务改成 failed。
  static final Set<String> _startingKeys = {};
  static Future<void>? _loadFuture;
  static Future<void> _writeTail = Future.value();

  static SubtitleTranslationTaskState stateFor({
    required String videoKey,
    int? cid,
    String? language,
  }) {
    final lang = language ?? Pref.uiTranslateLang;
    final key = _key(videoKey, lang, cid);
    // 合集父任务的状态由 syncState 直接写在一个键上，不能被子任务聚合覆盖。
    if (_activeBatchTaskKeys.contains(key)) {
      return _states[key] ?? const SubtitleTranslationTaskState();
    }
    final direct = _states[key];
    final cardKey = _key(videoKey, lang);
    final tasks = _cardTaskKeys[cid == null ? key : cardKey];
    if (cid != null) {
      // 播放页带 cid 的精确查询：优先自己那条任务，其次卡片启动态，最后聚合。
      if (direct != null) return direct;
      final cardState = _states[cardKey];
      if (cardState != null) return cardState;
      if (tasks != null && tasks.isNotEmpty) return _aggregateCardState(tasks);
      return const SubtitleTranslationTaskState();
    }
    // 封面按钮（无 cid）：有多个分P就聚合，否则看启动态/自身状态。
    if (tasks != null && tasks.isNotEmpty) return _aggregateCardState(tasks);
    return direct ?? const SubtitleTranslationTaskState();
  }

  /// 把「无 cid 的卡片键」与「解析出 cid 后的任务键」登记为一对多关系。
  static void _registerCardTask(String cardKey, String taskKey) {
    if (cardKey == taskKey) return;
    (_cardTaskKeys[cardKey] ??= <String>{}).add(taskKey);
    _taskCardKeys[taskKey] = cardKey;
  }

  /// 从登记过的分P任务键取出状态，交给 [aggregateCardStates] 汇总。
  static SubtitleTranslationTaskState _aggregateCardState(
    Set<String> taskKeys,
  ) => aggregateCardStates(
    taskKeys
        .map((key) => _states[key])
        .whereType<SubtitleTranslationTaskState>(),
  );

  static bool _subtitleFeedbackPrewarmed = false;

  static Future<void> ensureInitialized() {
    // 封面按钮在首页推荐流里就会出现，不一定经过 warmVideo()/warmCommon()。
    // 字幕服务第一次被碰到的时机就是这里，单独把反馈文案排一次队，
    // 否则任务结束时才第一次 uiTx，toast 一闪而过只显示中文。
    if (!_subtitleFeedbackPrewarmed) {
      _subtitleFeedbackPrewarmed = true;
      PrewarmStrings.warmSubtitle();
    }
    // 索引加载失败（磁盘 IO 异常等）不能把服务永久锁死：`_loadFuture` 会一直
    // 是一个 errored Future，此后每个字幕任务的 ensureInitialized 都直接抛，
    // 表现为「点多少次都立刻失败」。失败时清掉缓存，让下一次可以重试。
    return _loadFuture ??= _loadIndex().catchError((Object _) {
      _loadFuture = null;
    });
  }

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
    final cardKey = _taskCardKeys[taskKey];
    if (cardKey != null) _completed.add(cardKey);
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
      if (file.existsSync()) {
        await file.delete();
        removed = true;
      }
    } on FileSystemException {
      // Clearing an optional cache must never affect the original subtitle.
    }
    _completed.remove(taskKey);
    final cardKey = _taskCardKeys[taskKey];
    if (cardKey != null) {
      // 还有别的分P已完成时，卡片级的完成标记不能一起删掉。
      final others = _cardTaskKeys[cardKey];
      final anyOtherComplete =
          others?.any(
            (key) => key != taskKey && _completed.contains(key),
          ) ??
          false;
      if (!anyOtherComplete) _completed.remove(cardKey);
    }
    _set(taskKey, const SubtitleTranslationTaskState());
    await _saveIndex();
    return removed;
  }

  static Future<void> start({
    required String videoKey,
    String? bvid,
    int? aid,
    int? cid,
    int? epId,
    int? seasonId,
    bool force = false,
    bool includeCollection = true,
  }) async {
    await ensureInitialized();
    final target = Pref.uiTranslateLang;
    final taskKey = _key(videoKey, target, cid);
    // 连点两次时两个 continuation 都可能在下一次 `_set` 之前看到 null，
    // 于是同一份任务被 attach 两遍；完成阶段会各跑一次「替换缓存 → 重命名
    // canonical」，第二次 rename 找不到源文件而抛错，把已经成功的任务改成
    // failed。这里用一个入口锁把重复启动挡在门外。
    if (!_startingKeys.add(taskKey)) return;
    try {
      await _startUnlocked(
        videoKey: videoKey,
        bvid: bvid,
        aid: aid,
        cid: cid,
        epId: epId,
        seasonId: seasonId,
        target: target,
        taskKey: taskKey,
        force: force,
        includeCollection: includeCollection,
      );
    } finally {
      _startingKeys.remove(taskKey);
    }
  }

  /// [start] 的实现体。入口锁由 [start] 持有，这里不再做重复启动判断。
  static Future<void> _startUnlocked({
    required String videoKey,
    String? bvid,
    int? aid,
    int? cid,
    int? epId,
    int? seasonId,
    required String target,
    required String taskKey,
    required bool force,
    required bool includeCollection,
  }) async {
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
    if (bvid == null && aid == null && epId == null && seasonId == null) {
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
        epId: epId,
        seasonId: seasonId,
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
      epId: epId,
      seasonId: seasonId,
      force: force,
      // 单集必须给结果反馈；只有合集批量（_startBatch）才关掉逐集 toast。
      notify: true,
    );
  }

  static Future<void> _startSingle({
    required String videoKey,
    String? bvid,
    int? aid,
    int? cid,
    int? epId,
    int? seasonId,
    bool force = false,
    bool notify = true,
  }) async {
    await ensureInitialized();
    final target = Pref.uiTranslateLang;
    var taskKey = _key(videoKey, target, cid);
    var shouldNotifyOutcome = notify;
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
    if (bvid == null && aid == null && epId == null && seasonId == null) {
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
      final identity = await _resolvePlayableIdentity(
        bvid: bvid,
        aid: aid,
        cid: cid,
        epId: epId,
        seasonId: seasonId,
      );
      if (identity == null) {
        _fail(taskKey, uiTx('无法获取视频分P'));
        return;
      }
      final resolvedCid = identity.cid;
      // 解析出真实 bvid 后必须把键升级到与播放页一致的形态。
      // 竖版番剧卡片只有 epId，启动时用 `ep<id>`；点开后播放页拿到 bvid，
      // 用的是 `BV...`。3.7.3 只统一了“同参数下”的键，没有统一“同视频不同入口”
      // 的键，导致同一集翻两遍、播放页查不到卡片刚写的产物。
      final cacheVideoKey = subtitleResolvedVideoKeyFor(
        callerVideoKey: videoKey,
        bvid: identity.bvid ?? bvid,
        aid: identity.aid ?? aid,
        epId: identity.epId ?? epId,
        seasonId: identity.seasonId ?? seasonId,
      );
      final resolvedTaskKey = _key(cacheVideoKey, target, resolvedCid);
      if (resolvedTaskKey != taskKey) {
        final callerCardKey = _key(videoKey, target);
        _registerCardTask(callerCardKey, resolvedTaskKey);
        if (cid != null && taskKey != callerCardKey) {
          _registerCardTask(taskKey, resolvedTaskKey);
        }
        _registerCardTask(_key(cacheVideoKey, target), resolvedTaskKey);
        final canonicalState = _states[resolvedTaskKey];
        if (canonicalState != null) _set(taskKey, canonicalState);
        final canonicalBusy =
            canonicalState?.isRunning == true ||
            (!force &&
                canonicalState?.phase ==
                    SubtitleTranslationTaskPhase.complete) ||
            canonicalState?.noSource == true ||
            canonicalState?.nativeTrackAvailable == true;
        if (canonicalBusy) {
          // 只是命中播放页已启动/已完成的同一条任务，不是本次启动的结果，
          // 不该再弹一次“预翻译完成/失败”。
          shouldNotifyOutcome = false;
          return;
        }
        taskKey = resolvedTaskKey;
        _set(
          taskKey,
          SubtitleTranslationTaskState(
            phase: SubtitleTranslationTaskPhase.preparing,
            message: uiTx('正在获取字幕'),
          ),
        );
      }
      final info = await VideoHttp.playInfo(
        aid: (identity.aid ?? aid)?.toString(),
        bvid: identity.bvid ?? bvid,
        cid: resolvedCid,
        seasonId: identity.seasonId,
        epId: identity.epId,
      );
      final tracks = switch (info) {
        Success(:final response) => response.subtitle?.subtitles,
        _ => null,
      };
      if (tracks == null) {
        // playInfo 失败（断网 / 风控 / 接口降级没下发 subtitle 字段）不是
        // 「这个视频没有字幕」：给可重试的 failed，别把按钮置灰到点不动。
        _fail(taskKey, uiTx('字幕下载失败，点击重试'));
        return;
      }
      if (tracks.isEmpty) {
        // 实测：未登录时 /x/player/v2 对**有 CC 的视频**也返回空列表，
        // 所以空列表要先分辨「没登录」和「真没字幕」——两者的处理完全不同。
        final loggedIn =
            Get.isRegistered<AccountService>() &&
            Get.find<AccountService>().isLogin.value;
        _noSource(
          taskKey,
          loggedIn ? uiTx('这个视频没有可用的中文字幕') : uiTx('字幕需要登录后才能获取，请先登录'),
        );
        return;
      }
      var loadAttempts = 0;
      var loadFailures = 0;
      final resolved = await SubtitleSourceResolver.resolve(
        tracks: List<Subtitle>.of(tracks),
        targetLanguage: target,
        forceChineseSource: force,
        loadCues: (candidate) async {
          loadAttempts++;
          Object? lastError;
          for (final url in candidate.subtitleUrlCandidates) {
            try {
              final body = await VideoHttp.fetchSubtitleBody(url);
              if (body != null && body.isNotEmpty) {
                return SubtitleCues.fromBody(body);
              }
            } catch (error) {
              lastError = error;
            }
          }
          if (lastError != null) {
            loadFailures++;
            throw lastError;
          }
          return const <SubtitleCue>[];
        },
      );
      if (resolved == null) {
        if (loadAttempts > 0 && loadFailures == loadAttempts) {
          // 每条候选轨都是「下载抛异常」（断网、风控、404）：这是可恢复的失败，
          // 必须给重试入口。以前一律归为 noSource，按钮置灰且点了没反应，
          // 看起来就像功能坏了。
          _fail(taskKey, uiTx('字幕下载失败，点击重试'));
        } else {
          // 能下载但确实没有可用的中文源（空 body / 时间轴不可用）。
          _noSource(taskKey, uiTx('这个视频没有可用的中文字幕'));
        }
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
      // cacheVideoKey 已在身份解析后统一：优先真实 bvid（播放页键），
      // 再降级 aid/epId/seasonId。旧缓存仍按原有优先级命中。
      final cacheKey = '$cacheVideoKey/$resolvedCid/${sourceTrack.lan}/$target';
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
                    videoKey: cacheVideoKey,
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
                    videoKey: cacheVideoKey,
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
        if (progress == null) {
          // 协调器正常情况下会先 emit 一次零进度；万一它没发（会话被复用、
          // job 构造就失败等），这里必须收尾，否则状态永远停在 preparing。
          if (_states[taskKey]?.isRunning ?? false) {
            _fail(taskKey, uiTx('字幕翻译没有开始，点击重试'));
          }
        } else if (!progress.isComplete &&
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
      if (shouldNotifyOutcome) _notifyOutcome(taskKey);
    }
  }

  /// 后台任务结束时的用户反馈（单集）。
  static void _notifyOutcome(String taskKey) {
    final state = _states[taskKey];
    // B 站本来就有目标语言字幕：没有发生任何翻译，不该报「已预翻译完成」。
    if (state?.nativeTrackAvailable == true) return;
    switch (state?.phase) {
      case SubtitleTranslationTaskPhase.complete:
        SmartDialog.showToast(uiTx('字幕已预翻译完成'));
      case SubtitleTranslationTaskPhase.failed:
        SmartDialog.showToast(uiTx('字幕预翻译失败，可点按钮重试'));
      default:
        break;
    }
  }

  /// 补齐 `/x/player/wbi/v2` 所需的三件套：cid / ep_id / season_id。
  ///
  /// 普通视频走 ab2c；番剧（pgc）卡片只有 epId 或只有 seasonId、没有 bvid/aid 时，
  /// 从番剧详情里按已知的 cid 或 epId 反查另外两个编号。以前番剧卡片/播放页的
  /// 自动预翻译要么停在「无法获取视频分P」，要么只有 season_id 就发请求，
  /// 被接口的 assert / 风控挡下来。
  static Future<
    ({
      int cid,
      String? bvid,
      int? aid,
      int? epId,
      dynamic seasonId,
    })?
  >
  _resolvePlayableIdentity({
    String? bvid,
    int? aid,
    int? cid,
    int? epId,
    dynamic seasonId,
  }) async {
    var resolvedCid = cid;
    var resolvedBvid = _nonEmptyBvid(bvid);
    var resolvedAid = aid;
    if (resolvedCid == null && (resolvedBvid != null || resolvedAid != null)) {
      try {
        resolvedCid = (await SearchHttp.ab2cWithDimension(
          aid: resolvedAid,
          bvid: resolvedBvid,
        ))?.cid;
      } catch (_) {
        // 继续尝试番剧详情兜底。
      }
    }

    var resolvedEpId = epId;
    var resolvedSeasonId = seasonId;
    // cid 已知但 epId 缺失时也要查：横版番剧卡片只带 seasonId，
    // playInfo 需要 ep_id 才能拿到该集的字幕列表。
    if ((resolvedCid == null || resolvedEpId == null) &&
        (epId != null || seasonId != null)) {
      try {
        final info = await SearchHttp.pgcInfo(
          seasonId: seasonId,
          epId: epId,
        );
        if (info case Success(:final response)) {
          resolvedSeasonId ??= response.seasonId;
          for (final episode in response.episodes ?? const []) {
            if (epId != null && episode.epId != epId && episode.id != epId) {
              continue;
            }
            if (epId == null &&
                resolvedCid != null &&
                episode.cid != resolvedCid) {
              continue;
            }
            final episodeCid = episode.cid;
            if (episodeCid == null || episodeCid <= 0) continue;
            resolvedCid ??= episodeCid;
            resolvedBvid ??= _nonEmptyBvid(episode.bvid);
            resolvedAid ??= episode.aid;
            resolvedEpId ??= episode.epId ?? episode.id;
            if (resolvedCid != null && resolvedEpId != null) break;
          }
        }
      } catch (_) {
        // 拿不到编号时由调用方给出明确的失败提示。
      }
    }

    if (resolvedCid == null || resolvedCid <= 0) return null;
    return (
      cid: resolvedCid,
      bvid: resolvedBvid,
      aid: resolvedAid,
      epId: resolvedEpId,
      seasonId: resolvedSeasonId,
    );
  }

  static String? _nonEmptyBvid(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  static Future<List<SubtitleTranslationTarget>> _resolveTranslationTargets({
    required String videoKey,
    required String bvid,
    int? aid,
    int? cid,
    int? epId,
    int? seasonId,
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
        epId: epId,
        seasonId: seasonId,
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
    Timer? monitor;

    void finishBatch() {
      monitor?.cancel();
      _activeBatchTaskKeys.remove(parentTaskKey);
    }

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
      // noSource（没有中文字幕）既不是 complete 也不是 failed，以前永远不被计入
      // 完成条件，合集里只要有 1 个分P没字幕，父任务就永远停在「正在检查视频列表」，
      // 定时器一直转、toast 永远不出现。这里把它当作「已处理、无需翻译」。
      final skipped = states.where((state) => state.noSource).length;
      final native = states.where((state) => state.nativeTrackAvailable).length;
      final progress =
          states.fold<double>(
            0,
            (sum, state) =>
                sum +
                (state.phase == SubtitleTranslationTaskPhase.complete ||
                        state.noSource
                    ? 1
                    : state.progress),
          ) /
          targets.length;
      if (running == 0 && completed + failed + skipped == targets.length) {
        finalized = true;
        // 必须在 syncState 内部收尾：批量 runNext 可能因「该分P已被播放页任务
        // 接管」提前返回，真正完成时间晚于 Future.wait；finally 里直接 cancel
        // 定时器会把父任务留在 translating，卡片永远转圈。
        finishBatch();
        if (failed > 0) {
          _fail(
            parentTaskKey,
            uiTxP('{0}/{1} 个分P失败，点击重试', [failed, targets.length]),
          );
          SmartDialog.showToast(
            uiTxP('{0}/{1} 个分P字幕预翻译失败', [
              failed,
              targets.length,
            ]),
          );
          return;
        }
        _markTaskComplete(parentTaskKey);
        final withoutWork = skipped + native;
        SmartDialog.showToast(
          withoutWork > 0
              ? uiTxP('全 {0} 个分P已处理（{1} 个无需翻译）', [
                  targets.length,
                  withoutWork,
                ])
              : uiTxP('全 {0} 个分P字幕已预翻译完成', [targets.length]),
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
          message: uiTxP('已翻译 {0}/{1} 个分P', [completed, targets.length]),
        ),
      );
    }

    syncState();
    monitor = Timer.periodic(
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
            epId: target.epId,
            seasonId: target.seasonId,
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
    } catch (error) {
      // 某个分P抛出未预期异常时，Future.wait 会提前结束。以前 finally 里
      // 只调 syncState()，此时子任务多半还是 idle → 父任务被写成 preparing，
      // 定时器又已经 cancel，于是永远转圈、没有任何失败提示。
      if (!finalized) {
        finalized = true;
        finishBatch();
        _fail(
          parentTaskKey,
          uiTxP('无法开始翻译字幕，点击重试（{0}）', ['${error.runtimeType}']),
        );
      }
    } finally {
      syncState();
      if (!finalized) {
        final stillRunning = targets.any(
          (target) => stateFor(
            videoKey: target.videoKey,
            cid: target.cid,
            language: language,
          ).isRunning,
        );
        if (!stillRunning) {
          // 队列确实没有推进且没有任何分P在跑：绝不让父任务停在 preparing。
          finalized = true;
          finishBatch();
          _fail(parentTaskKey, uiTx('字幕翻译没有开始，点击重试'));
          syncState();
        }
        // 还有分P在跑（例如被播放页的同一任务接管）：保留 monitor，
        // 等 syncState 看到全部终态后再收尾。
      }
      if (finalized) finishBatch();
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
    if (!source.existsSync()) {
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
      if (vttFile.existsSync()) await vttFile.delete();
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
        if (!vttFile.existsSync()) return false;
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
    // 不再把状态镜像覆盖到 cardKey：卡片查询时按所有分P实时聚合，
    // 否则最后一个分P的状态会把前面所有分P盖掉（单跳别名的老问题）。
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
        if (!cacheFile.existsSync() || !vttFile.existsSync()) continue;
        // 旧版合集批量产物把 cid 拼进 videoKey，这里归一到统一身份键，
        // 否则重启后状态键与封面按钮/播放页查询键对不上。
        final stateVideoKey = artifact.stateVideoKey;
        final taskKey = _key(
          stateVideoKey,
          artifact.targetLanguage,
          artifact.cid,
        );
        // 卡片查询用的是无 cid 的键，重启后也要能看到「已翻译」。
        final cardKey = _key(stateVideoKey, artifact.targetLanguage);
        _registerCardTask(cardKey, taskKey);
        if (artifact.verifierVersion != SubtitleTextQuality.verifierVersion) {
          _set(
            taskKey,
            SubtitleTranslationTaskState(
              phase: SubtitleTranslationTaskPhase.failed,
              message: uiTx('旧译文需要重新校验，打开视频后自动进行'),
            ),
          );
          continue;
        }
        if (!await _storedArtifactIsIntact(
          artifact: artifact,
          cacheFile: cacheFile,
          vttFile: vttFile,
        )) {
          _set(
            taskKey,
            SubtitleTranslationTaskState(
              phase: SubtitleTranslationTaskPhase.failed,
              message: uiTx('已保存的译文需要校验或修复，点击重试'),
            ),
          );
          continue;
        }
        _completed
          ..add(taskKey)
          ..add(cardKey);
        _set(
          taskKey,
          SubtitleTranslationTaskState(
            phase: SubtitleTranslationTaskPhase.complete,
            progress: 1,
            message: uiTx('已翻译并保存到设备'),
          ),
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
