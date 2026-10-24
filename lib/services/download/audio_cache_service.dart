import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show Directory, File;

import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/common/account_type.dart';
import 'package:PiliPlus/models/common/video/audio_quality.dart';
import 'package:PiliPlus/models/common/video/video_type.dart';
import 'package:PiliPlus/models_new/download/audio_cache_entry.dart';
import 'package:PiliPlus/services/download/download_manager.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/video_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

enum AudioCacheStatus { wait, downloading, completed, failed }

/// 一条音频缓存任务（下载中或刚结束）。
class AudioCacheTask {
  AudioCacheTask({
    required this.bvid,
    required this.cid,
    required this.title,
    required this.quality,
  });

  final String bvid;
  final int cid;
  final String title;
  final AudioQuality quality;

  final status = AudioCacheStatus.wait.obs;
  final received = 0.obs;
  final total = 0.obs;
  final error = RxnString();

  DownloadManager? manager;

  String get id => '${bvid}_$cid';

  double get progress {
    final t = total.value;
    return t <= 0 ? 0 : (received.value / t).clamp(0.0, 1.0);
  }

  void dispose() {
    manager = null;
  }
}

/// 音频缓存服务。
///
/// 与视频离线缓存互相独立：不套用 B 站官方下载目录结构，每个条目一个目录，
/// 里面直接放原格式音频文件（m4a / mp3 / flac / wav ...），另存一份 entry.json。
/// 索引写在缓存根目录的 index.json 里。
class AudioCacheService extends GetxService {
  static const String _indexFile = 'index.json';
  static const String _entryFile = 'entry.json';

  /// 缓存可选音质：从 Hi-Res 无损到 64K，从高到低。
  static const List<AudioQuality> cacheQualities = <AudioQuality>[
    AudioQuality.hiRes,
    AudioQuality.dolby_30250,
    AudioQuality.k192,
    AudioQuality.k132,
    AudioQuality.k64,
  ];

  final audioList = <AudioCacheEntry>[].obs;
  final taskList = <AudioCacheTask>[].obs;

  late final Future<void> waitForInitialization;

  @override
  void onInit() {
    super.onInit();
    waitForInitialization = _readIndex();
  }

  Future<Directory> _root() async {
    final dir = Directory(path.join(downloadPath, 'audio'));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _readIndex() async {
    try {
      final dir = await _root();
      final indexFile = File(path.join(dir.path, _indexFile));
      final list = <AudioCacheEntry>[];
      if (indexFile.existsSync()) {
        final raw = jsonDecode(await indexFile.readAsString());
        if (raw is List) {
          for (final item in raw) {
            if (item is! Map) {
              continue;
            }
            final entry = AudioCacheEntry.fromJson(
              Map<String, dynamic>.from(item),
            );
            final file = File(entry.filePath);
            // 文件被用户手动删掉的条目顺带清理，不留空壳
            if (!file.existsSync()) {
              continue;
            }
            entry.fileSize = file.lengthSync();
            list.add(entry);
          }
        }
      }
      list.sort((a, b) => b.timeCreateStamp.compareTo(a.timeCreateStamp));
      audioList.assignAll(list);
    } catch (e, s) {
      debugPrint('audio cache index: $e\n$s');
    }
  }

  Future<void> _writeIndex() async {
    try {
      final dir = await _root();
      final file = File(path.join(dir.path, _indexFile));
      await file.writeAsString(
        jsonEncode(audioList.map((e) => e.toJson()).toList()),
      );
    } catch (e, s) {
      debugPrint('audio cache index write: $e\n$s');
    }
  }

  bool isCached(int cid) => audioList.any((e) => e.cid == cid);

  AudioCacheEntry? entryOf(int cid) =>
      audioList.firstWhereOrNull((e) => e.cid == cid);

  AudioCacheTask? taskOf(int cid) =>
      taskList.firstWhereOrNull((e) => e.cid == cid);

  static String _descOf(int code) => AudioQuality.values
      .firstWhere((e) => e.code == code, orElse: () => AudioQuality.k192)
      .desc;

  /// 按流类型给扩展名：B 站 DASH 音频是 fMP4，落盘就是 m4a；
  /// 无损档给的是 FLAC，就按 flac 存。用户拿到的就是能直接播的原始格式。
  static String _extFromMime(String? mime) {
    switch (mime) {
      case 'audio/mp4':
      case 'audio/mp4a-latm':
        return 'm4a';
      case 'audio/mpeg':
        return 'mp3';
      case 'audio/flac':
      case 'audio/x-flac':
        return 'flac';
      case 'audio/wav':
      case 'audio/x-wav':
      case 'audio/wave':
        return 'wav';
      case 'audio/aac':
      case 'audio/aacp':
        return 'aac';
      case 'audio/ogg':
        return 'ogg';
      default:
        return 'm4a';
    }
  }

  static String _sanitize(String name) {
    final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|\r\n]'), '_').trim();
    if (cleaned.isEmpty) {
      return 'audio';
    }
    return cleaned.length > 80 ? cleaned.substring(0, 80) : cleaned;
  }

  /// 开始缓存一条音频。[quality] 是用户选的档位，取不到时自动退到可用档位。
  Future<bool> download({
    required int avid,
    required String bvid,
    required int cid,
    required String title,
    required String cover,
    String? ownerName,
    int? ownerId,
    int durationMs = 0,
    String? seasonId,
    int? epId,
    required AudioQuality quality,
  }) async {
    await waitForInitialization;
    if (isCached(cid)) {
      SmartDialog.showToast(uiTx('该音频已缓存'));
      return false;
    }
    final existed = taskOf(cid);
    if (existed != null && existed.status.value != AudioCacheStatus.failed) {
      SmartDialog.showToast(uiTx('该音频正在缓存'));
      return false;
    }
    if (existed != null) {
      taskList.remove(existed);
    }

    final task = AudioCacheTask(
      bvid: bvid,
      cid: cid,
      title: title,
      quality: quality,
    );
    taskList.insert(0, task);

    final isLogin = Accounts.get(AccountType.video).isLogin;
    final res = await VideoHttp.videoUrl(
      avid: avid,
      bvid: bvid,
      cid: cid,
      seasonId: seasonId,
      epid: epId,
      qn: 80,
      tryLook: !isLogin && Pref.p1080,
      videoType: epId == null
          ? VideoType.ugc
          : (isLogin ? VideoType.pgc : VideoType.ugc),
      allowAppSource: false,
    );
    if (res case Success(:final response)) {
      final audios = response.dash?.audio;
      if (audios == null || audios.isEmpty) {
        task.status.value = AudioCacheStatus.failed;
        task.error.value = 'no audio stream';
        SmartDialog.showToast(uiTx('该视频没有可用的音频流'));
        return false;
      }
      // 档位选择：优先精确命中，其次不高于目标档位的最高档，最后退到最低档
      final ids = audios.map((e) => e.id).toList()..sort();
      var target = quality.code;
      if (!ids.contains(target)) {
        final lower = ids.where((e) => e < target).toList();
        target = lower.isNotEmpty ? lower.last : ids.first;
      }
      final item = audios.firstWhere(
        (e) => e.id == target,
        orElse: () => audios.first,
      );
      final mainUrl = VideoUtils.getCdnUrl(
        item.playUrls,
        isAudio: true,
        preferAkamai: VideoUtils.downloadPreferAkamai,
      );
      final urls = <String>[
        mainUrl,
        ...item.playUrls.where((u) => u != mainUrl),
      ];
      // 境外网络从大陆镜像取流常被限速，插一条 Akamai 边缘作候选
      final akamai = VideoUtils.akamaiVariant(mainUrl);
      if (akamai != null && !urls.contains(akamai)) {
        urls.insert(1, akamai);
      }

      final ext = _extFromMime(item.mimeType);
      final dir = Directory(path.join((await _root()).path, '${bvid}_$cid'));
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      final filePath = path.join(dir.path, '${_sanitize(title)}.$ext');

      task.status.value = AudioCacheStatus.downloading;
      final manager = DownloadManager(
        urls: urls,
        path: filePath,
        onReceiveProgress: (received, total) {
          task.received.value = received;
          task.total.value = total;
        },
        onDone: ([Object? error]) async {
          if (error != null) {
            task.status.value = AudioCacheStatus.failed;
            task.error.value = error.toString();
            SmartDialog.showToast(uiTx('音频缓存失败'));
            return;
          }
          final file = File(filePath);
          final entry = AudioCacheEntry(
            avid: avid,
            bvid: bvid,
            cid: cid,
            title: title,
            cover: cover,
            ownerName: ownerName,
            ownerId: ownerId,
            durationMs: response.dash?.duration ?? durationMs,
            qualityCode: target,
            qualityDesc: _descOf(target),
            filePath: filePath,
            ext: ext,
            fileSize: file.existsSync() ? file.lengthSync() : 0,
            timeCreateStamp: DateTime.now().millisecondsSinceEpoch,
          );
          await File(
            path.join(dir.path, _entryFile),
          ).writeAsString(jsonEncode(entry.toJson()));
          audioList.insert(0, entry);
          await _writeIndex();
          task.status.value = AudioCacheStatus.completed;
          SmartDialog.showToast(uiTx('音频缓存完成'));
        },
      );
      task.manager = manager;
      return true;
    } else {
      task.status.value = AudioCacheStatus.failed;
      task.error.value = res.toString();
      SmartDialog.showToast(uiTx('取流失败，无法缓存音频'));
      return false;
    }
  }

  Future<void> cancelTask(AudioCacheTask task) async {
    final manager = task.manager;
    task.manager = null;
    taskList.remove(task);
    if (manager != null) {
      await manager.cancel(isDelete: true);
    }
  }

  void removeTask(AudioCacheTask task) => taskList.remove(task);

  /// 删除缓存。[deleteFile] 为 true 时连本地音频文件一起删。
  Future<void> delete(
    List<AudioCacheEntry> entries, {
    required bool deleteFile,
  }) async {
    for (final entry in entries) {
      audioList.removeWhere((e) => e.id == entry.id);
      if (!deleteFile) {
        continue;
      }
      try {
        final file = File(entry.filePath);
        final parent = file.parent;
        if (file.existsSync()) {
          await file.delete();
        }
        final entryFile = File(path.join(parent.path, _entryFile));
        if (entryFile.existsSync()) {
          await entryFile.delete();
        }
        if (parent.existsSync() && parent.listSync().isEmpty) {
          await parent.delete();
        }
      } catch (e, s) {
        debugPrint('audio cache delete: $e\n$s');
      }
    }
    await _writeIndex();
  }

  Future<void> refresh() async {
    await _readIndex();
  }
}
