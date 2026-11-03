import 'dart:async';
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
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
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

  static Future<void> start({
    required String videoKey,
    String? bvid,
    int? aid,
    int? cid,
  }) async {
    await ensureInitialized();
    final target = Pref.uiTranslateLang;
    final taskKey = _key(videoKey, target);
    final current = _states[taskKey];
    if (current?.isRunning == true ||
        current?.phase == SubtitleTranslationTaskPhase.complete) {
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
        if (selection.index == 0) break;
        final candidate = choices[selection.index - 1];
        if (!selection.translate) {
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
      final pool = SubtitleTranslationProxyPool(
        proxies,
        directWorkers: Pref.subtitleConcurrency,
      );
      final cacheKey =
          '${bvid ?? 'av$aid'}/$resolvedCid/${sourceTrack.lan}/$target';
      final subscription = SubtitleTranslationCoordinator.attach(
        key: SubtitleTranslationJob.cacheIdentity(cacheKey, sourceCues),
        allowNewTranslation: true,
        createJob: (onUpdate) => SubtitleTranslationJob(
          cues: sourceCues,
          chunkSize: Pref.subtitleChunkSize,
          concurrency: pool.workerCount,
          contextOverlap: Pref.subtitleContextOverlap,
          targetLanguage: target,
          cacheKey: cacheKey,
          onUpdate: onUpdate,
          translate: SubtitleTranslateService.translateChunk,
          translateWithContext: (lines, context) => pool.run((proxy) async {
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
          }),
        ),
        onUpdate: (_, progress) {
          if (progress.isComplete) {
            markComplete(videoKey: videoKey, language: target);
            return;
          }
          final percent = (progress.ratio * 100).round();
          _set(
            taskKey,
            SubtitleTranslationTaskState(
              phase: SubtitleTranslationTaskPhase.translating,
              progress: progress.ratio,
              message: progress.failedChunks > 0
                  ? 'Đang thử lại $percent%'
                  : 'Đang dịch $percent%',
            ),
          );
        },
      );
      unawaited(subscription.whenComplete.then((_) => subscription.detach()));
    } catch (_) {
      _fail(taskKey, 'Không thể bắt đầu dịch sub, chạm để thử lại');
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
