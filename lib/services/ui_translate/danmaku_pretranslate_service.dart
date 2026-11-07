import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:PiliPlus/grpc/dm.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_background_service.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/danmaku_utils.dart';
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

enum DanmakuPretranslatePhase {
  idle,
  preparing,
  translating,
  complete,
  failed,
}

class DanmakuPretranslateState {
  const DanmakuPretranslateState({
    this.phase = DanmakuPretranslatePhase.idle,
    this.progress = 0,
    this.message,
    this.noSource = false,
  });

  final DanmakuPretranslatePhase phase;
  final double progress;
  final String? message;

  /// 该视频没有可预翻译的弹幕（未登录拉不到分段等）。与字幕按钮的 noSource
  /// 同一口径：不是失败，图标置灰、点击可重查。
  final bool noSource;

  bool get isRunning =>
      phase == DanmakuPretranslatePhase.preparing ||
      phase == DanmakuPretranslatePhase.translating;
}

/// 弹幕批量预翻译服务（卡片「翻译弹幕」按钮的后端）。
///
/// 与 [SubtitleTranslationBackgroundService] 同一套产品口径：点击 → 拉取该视频
/// 全部分段的弹幕 → 整段批量预翻译（译文进 [UiTranslateService] 的持久缓存）→
/// 完成后按钮显示绿色对勾；进播放页时弹幕分段命中缓存，出生即译文。
/// 完成标记持久化到本机索引，重启后按钮仍显示已完成。
abstract final class DanmakuPretranslateService {
  static final RxMap<String, DanmakuPretranslateState> _states =
      <String, DanmakuPretranslateState>{}.obs;
  static final Set<String> _completed = {};
  static Future<void>? _loadFuture;
  static Future<void> _writeTail = Future.value();

  /// 已请求取消的任务键（3.7.12）：分段拉取与翻译批次在检查点观察并排空。
  static final Set<String> _cancelRequested = <String>{};

  /// 每个任务收集到的源文本（取消/撤销时按它清缓存）。完成任务落盘持久化，
  /// 重启后撤销仍能精准清缓存。
  static final Map<String, List<String>> _taskContents =
      <String, List<String>>{};

  /// 拉全部分段的上限：6 分钟一段，40 段 = 4 小时。超长的视频按前 4 小时算，
  /// 避免异常时长（直播回放之类）把任务拖成无底洞。
  static const int _maxSegments = 40;

  static DanmakuPretranslateState stateFor({
    required String videoKey,
    int? cid,
    String? language,
  }) =>
      _states[_key(videoKey, language ?? Pref.uiTranslateLang, cid)] ??
      const DanmakuPretranslateState();

  static Future<void> ensureInitialized() => _loadFuture ??= _loadIndex();

  /// 与字幕按钮同一判断：AI 翻译关着、目标是简中、或弹幕翻译开关没开时，
  /// 这个按钮没有可做的事。
  static bool get needed {
    if (!Get.isRegistered<UiTranslateService>()) return false;
    final service = UiTranslateService.to;
    return service.enabled &&
        service.translateContent &&
        !service.isSourceLanguage &&
        service.danmakuTranslate.value;
  }

  static void start({
    required String videoKey,
    String? bvid,
    int? aid,
    int? cid,
    int? epId,
    dynamic seasonId,
    bool force = false,
  }) {
    unawaited(
      _start(
        videoKey: videoKey,
        bvid: bvid,
        aid: aid,
        cid: cid,
        epId: epId,
        seasonId: seasonId,
        force: force,
      ),
    );
  }

  static Future<void> _start({
    required String videoKey,
    String? bvid,
    int? aid,
    int? cid,
    int? epId,
    dynamic seasonId,
    bool force = false,
  }) async {
    await ensureInitialized();
    if (!needed) {
      _fail(
        _key(videoKey, Pref.uiTranslateLang, cid),
        uiTx('请先开启 AI 翻译与弹幕翻译'),
      );
      return;
    }
    final target = Pref.uiTranslateLang;
    var taskKey = _key(videoKey, target, cid);
    final current = _states[taskKey];
    if (current?.isRunning == true ||
        (!force && current?.phase == DanmakuPretranslatePhase.complete)) {
      return;
    }
    _set(
      taskKey,
      DanmakuPretranslateState(
        phase: DanmakuPretranslatePhase.preparing,
        message: uiTx('正在获取弹幕分段'),
      ),
    );

    try {
      final identity = await SubtitleTranslationBackgroundService
          .resolvePlayableIdentity(
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
      final resolvedKey = _key(videoKey, target, resolvedCid);
      if (resolvedKey != taskKey) {
        _states.remove(taskKey);
        taskKey = resolvedKey;
      }
      final runningKey = taskKey;
      final already = _states[runningKey];
      if (already?.isRunning == true ||
          (!force && already?.phase == DanmakuPretranslatePhase.complete)) {
        return;
      }

      // 分段总数 = 视频时长 / 6 分钟。时长来源与字幕批量同一套：
      // UGC 用 videoIntro（秒），番剧用 pgcInfo 对应剧集（毫秒/秒混用，归一化）。
      final durationMs = await _resolveDurationMs(
        bvid: identity.bvid,
        epId: identity.epId,
        seasonId: identity.seasonId,
        matchedCid: resolvedCid,
      );
      if (durationMs <= 0) {
        _set(
          runningKey,
          DanmakuPretranslateState(noSource: true, message: uiTx('没有可预翻译的弹幕')),
        );
        return;
      }
      final segmentCount =
          ((durationMs - 1) ~/ DmUtils.segLength + 1).clamp(1, _maxSegments);

      // 逐段拉弹幕，收集需要翻译的文本（mode 7 是高级弹幕 JSON 负载，与播放器
      // 内同一口径跳过；空文本跳过；同视频内去重）。
      final contents = <String>[];
      final seen = <String>{};
      var fetched = 0;
      for (var seg = 0; seg < segmentCount; seg++) {
        if (_cancelRequested.contains(runningKey)) {
          _cleanupCancelled(runningKey, contents);
          return;
        }
        _set(
          runningKey,
          DanmakuPretranslateState(
            phase: DanmakuPretranslatePhase.preparing,
            progress: fetched / segmentCount * 0.2,
            message: uiTxP('正在获取弹幕 {0}/{1}', [fetched, segmentCount]),
          ),
        );
        final res = await DmGrpc.dmSegMobile(
          cid: resolvedCid,
          segmentIndex: seg + 1,
        );
        fetched++;
        if (res case Success(:final response)) {
          for (final elem in response.elems) {
            final text = elem.content;
            if (elem.mode == 7 || text.isEmpty) continue;
            if (!seen.add(text)) continue;
            contents.add(text);
          }
        }
        // 单段失败不中断：能拿多少翻多少。
      }
      if (contents.isEmpty) {
        _set(
          runningKey,
          DanmakuPretranslateState(noSource: true, message: uiTx('没有可预翻译的弹幕')),
        );
        return;
      }

      _taskContents[runningKey] = contents;
      if (_cancelRequested.contains(runningKey)) {
        _cleanupCancelled(runningKey, contents);
        return;
      }
      _set(
        runningKey,
        DanmakuPretranslateState(
          phase: DanmakuPretranslatePhase.translating,
          message: uiTx('正在翻译弹幕'),
        ),
      );
      await UiTranslateService.to.pretranslateDanmaku(
        contents,
        isCancelled: () => _cancelRequested.contains(runningKey),
        onProgress: (translated, total) {
          // 分段抓取占前 20%，翻译占后 80%。
          _set(
            runningKey,
            DanmakuPretranslateState(
              phase: DanmakuPretranslatePhase.translating,
              progress: 0.2 + (translated / (total == 0 ? 1 : total)) * 0.8,
              message: uiTxP('正在翻译弹幕 {0}/{1} 句', [translated, total]),
            ),
          );
        },
      );

      if (_cancelRequested.contains(runningKey)) {
        _cleanupCancelled(runningKey, contents);
        return;
      }
      _completed.add(runningKey);
      _set(
        runningKey,
        DanmakuPretranslateState(
          phase: DanmakuPretranslatePhase.complete,
          progress: 1,
          message: uiTx('弹幕已预翻译完成'),
        ),
      );
      unawaited(_saveIndex());
      unawaited(_saveContents(runningKey, contents));
      SmartDialog.showToast(uiTx('弹幕已预翻译完成'));
    } catch (e) {
      _fail(taskKey, uiTx('弹幕预翻译失败，可点按钮重试'));
    }
  }

  /// 取消收尾：把该任务已写入缓存的所有源文本清掉，状态复位为未开始。
  static void _cleanupCancelled(String runningKey, List<String> contents) {
    UiTranslateService.to.removeCachedTranslations(contents);
    _taskContents.remove(runningKey);
    _cancelRequested.remove(runningKey);
    _states[runningKey] = const DanmakuPretranslateState();
  }

  /// 取消（运行中）或撤销（已完成）：清缓存、清持久标记、状态复位。
  static void cancelOrUndo({
    required String videoKey,
    int? cid,
    String? language,
  }) {
    final taskKey = _key(videoKey, language ?? Pref.uiTranslateLang, cid);
    final state = _states[taskKey];
    if (state?.isRunning == true) {
      _cancelRequested.add(taskKey);
      // 分段拉取/翻译循环会在检查点观察取消并自行清缓存；这里兜底把
      // 「准备中但还没收集到任何内容」的状态也复位。
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (_cancelRequested.contains(taskKey)) {
          _cleanupCancelled(
            taskKey,
            _taskContents[taskKey] ?? const <String>[],
          );
        }
      });
      return;
    }
    if (state?.phase == DanmakuPretranslatePhase.complete ||
        _completed.contains(taskKey)) {
      final contents = _taskContents[taskKey] ?? _loadContents(taskKey);
      if (contents.isNotEmpty) {
        UiTranslateService.to.removeCachedTranslations(contents);
      }
      _completed.remove(taskKey);
      _taskContents.remove(taskKey);
      _deleteContents(taskKey);
      _states[taskKey] = const DanmakuPretranslateState();
      unawaited(_saveIndex());
    }
  }

  static File _contentsFile(String taskKey) => File(
    path.join(appSupportDirPath, 'danmaku_pretranslate', '$taskKey.json'),
  );

  static Future<void> _saveContents(String taskKey, List<String> contents) async {
    _writeTail = _writeTail.then((_) async {
      try {
        final file = _contentsFile(taskKey);
        await file.parent.create(recursive: true);
        final temp = File('${file.path}.tmp');
        await temp.writeAsString(jsonEncode({'contents': contents}), flush: true);
        await temp.rename(file.path);
      } catch (_) {
        // 内容清单写失败只影响「撤销」的精准清理，不影响真实缓存。
      }
    });
    return _writeTail;
  }

  static List<String> _loadContents(String taskKey) {
    try {
      final file = _contentsFile(taskKey);
      if (!file.existsSync()) return const <String>[];
      final decoded =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final items = decoded['contents'];
      if (items is! List) return const <String>[];
      return items.whereType<String>().toList(growable: false);
    } catch (_) {
      return const <String>[];
    }
  }

  static void _deleteContents(String taskKey) {
    try {
      final file = _contentsFile(taskKey);
      if (file.existsSync()) file.deleteSync();
    } catch (_) {}
  }

  /// 视频时长（毫秒）。UGC 走 videoIntro（秒 → ×1000）；
  /// 番剧走 pgcInfo 对应剧集（pgc 下发毫秒、pugv 下发秒，按量级归一化）。
  static Future<int> _resolveDurationMs({
    required String? bvid,
    required int? epId,
    required dynamic seasonId,
    required int matchedCid,
  }) async {
    try {
      if (epId != null || seasonId != null) {
        final info = await SearchHttp.pgcInfo(seasonId: seasonId, epId: epId);
        if (info case Success(:final response)) {
          for (final episode in response.episodes ?? const []) {
            if (epId != null && episode.epId != epId && episode.id != epId) {
              continue;
            }
            if (epId == null && episode.cid != matchedCid) {
              continue;
            }
            final raw = episode.duration ?? 0;
            if (raw <= 0) continue;
            // ≤12 小时的数值按秒处理（pgc 毫秒值不可能小于 43,200,000）。
            return raw <= 43200 ? raw * 1000 : raw;
          }
        }
        // 番剧拿不到时长时不再走 UGC 分支，直接返回。
        return 0;
      }
      if (bvid != null && bvid.isNotEmpty) {
        final intro = await VideoHttp.videoIntro(bvid: bvid);
        if (intro case Success(:final response)) {
          final seconds = response.duration ?? 0;
          if (seconds > 0) return seconds * 1000;
        }
      }
    } catch (_) {
      // 拿不到时长时由调用方给出「没有可预翻译的弹幕」兜底。
    }
    return 0;
  }

  static void _fail(String key, String message) {
    _set(
      key,
      DanmakuPretranslateState(
        phase: DanmakuPretranslatePhase.failed,
        message: message,
      ),
    );
  }

  static void _set(String key, DanmakuPretranslateState state) {
    _states[key] = state;
  }

  static String _key(String videoKey, String language, [int? cid]) =>
      cid == null ? '$videoKey/$language' : '$videoKey/$cid/$language';

  static File get _indexFile => File(
    path.join(appSupportDirPath, 'danmaku_pretranslate', 'index.json'),
  );

  static Future<void> _loadIndex() async {
    try {
      final file = _indexFile;
      if (!await file.exists()) return;
      final decoded =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final items = decoded['completed'];
      if (items is! List) return;
      for (final item in items.whereType<String>()) {
        _completed.add(item);
        _states[item] = const DanmakuPretranslateState(
          phase: DanmakuPretranslatePhase.complete,
          progress: 1,
          message: uiTxStaticDone,
        );
      }
      // 撤销功能（3.7.12）：为已完成的任务恢复源文本清单（懒加载亦可，
      // 这里直接载入——清单通常几十 KB）。
      for (final item in _completed.toList()) {
        final contents = _loadContents(item);
        if (contents.isNotEmpty) _taskContents[item] = contents;
      }
    } catch (_) {
      // 索引损坏只影响「已完成」标记的回显，不影响真实翻译缓存。
    }
  }

  /// 索引回显用的固定文案（静态上下文里不能调 uiTx，值由 _loadIndex 之外的
  /// 常量承担；显示层对 complete 态一律渲染绿勾，不依赖这条文案）。
  static const String uiTxStaticDone = '弹幕已预翻译完成';

  static Future<void> _saveIndex() {
    _writeTail = _writeTail.then((_) async {
      try {
        final file = _indexFile;
        await file.parent.create(recursive: true);
        final temp = File('${file.path}.tmp');
        await temp.writeAsString(
          jsonEncode({'completed': _completed.toList()..sort()}),
          flush: true,
        );
        await temp.rename(file.path);
      } catch (_) {
        // 标记写失败不影响真实缓存；下次完成时会再写。
      }
    });
    return _writeTail;
  }
}
