import 'dart:convert';
import 'dart:io';

import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/common/video/audio_quality.dart';
import 'package:PiliPlus/models/common/video/video_type.dart';
import 'package:PiliPlus/services/download/audio_cache_service.dart';
import 'package:PiliPlus/services/download/download_manager.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/video_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:collection/collection.dart';
import 'package:PiliPlus/models/common/account_type.dart';
import 'package:PiliPlus/models_new/download/local_download_record.dart';
import 'package:PiliPlus/utils/storage.dart';

/// 「下载到本地」：把视频 / 音频按能直接播放的格式写进用户自己选的文件夹。
///
/// 与软件内缓存（[AudioCacheService] / DownloadService）的区别：
/// - 视频走 `fnval = 1` 的单文件流，服务端已经把视频和音频封装在同一个 MP4 里，
///   落盘就能用系统播放器播，不需要再拼 DASH 分片；
/// - 音频保持原始容器（m4a / mp3 / flac / wav ...），只做落盘不转码；
/// - 不写缓存索引、不进缓存列表，纯粹是本地文件。
class LocalDownloadService extends GetxService {
  /// 取流与落盘统一用 b 站自己的下载器 UA：durl（整段 MP4）直链对 UA 有校验，
  /// 用浏览器 UA 会被判 403，表现就是「下载失败 + 落盘 0B」。
  static const String _bilibiliUa = 'Bilibili Freedoooooom/MarkII';

  /// 与 [_bilibiliUa] 配套的 Referer。注意**带尾斜杠**：
  /// DownloadHttp 取 durl 用的就是这个值，缺尾斜杠在部分 CDN 上同样会被拒。
  static const String _bilibiliReferer = 'https://www.bilibili.com/';

  /// 下载档案（含进度）。非响应式：进度回调是高频的，逐条 push 会让整页重建，
  /// 界面统一靠 [recordsRevision] 感知变化。
  final List<LocalDownloadRecord> records = [];

  /// 档案变更计数，界面 Obx 读它刷新。
  final RxInt recordsRevision = 0.obs;

  static const String _recordKey = 'localDownloadRecords';

  @override
  void onInit() {
    super.onInit();
    _loadRecords();
  }

  void _loadRecords() {
    try {
      final raw = GStorage.localCache.get(_recordKey);
      if (raw is String && raw.isNotEmpty) {
        final list = jsonDecode(raw);
        if (list is List) {
          for (final item in list) {
            if (item is Map) {
              records.add(
                LocalDownloadRecord.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
        }
      }
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('load local download records: $e\n\n$s');
      }
    }
  }

  void _saveRecords() {
    try {
      GStorage.localCache.put(
        _recordKey,
        jsonEncode(records.map((e) => e.toJson()).toList()),
      );
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('save local download records: $e\n\n$s');
      }
    }
  }

  void _touchRecords({required bool save}) {
    recordsRevision.value++;
    if (save) {
      _saveRecords();
    }
  }

  /// 新建或覆盖一条档案（同一稿件重复下载时回到列表最前面）。
  LocalDownloadRecord _upsertRecord({
    required String id,
    required bool isAudio,
    required String title,
    required String path,
    String? ownerName,
    String? cover,
  }) {
    final exist = records.where((e) => e.id == id).firstOrNull;
    if (exist != null) {
      records.remove(exist);
    }
    final record = LocalDownloadRecord(
      id: id,
      isAudio: isAudio,
      title: title,
      path: path,
      ownerName: ownerName,
      cover: cover,
    );
    records.insert(0, record);
    _touchRecords(save: true);
    return record;
  }

  /// 删除档案对应的本地文件。档案**保留**，界面随之显示「本地文件已删除」，
  /// 再点「清理档案」才会从列表里消失。
  Future<void> deleteLocalFile(LocalDownloadRecord record) async {
    try {
      final file = File(record.path);
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('delete local file: $e\n\n$s');
      }
      SmartDialog.showToast(uiTx('删除失败，文件可能已被占用'));
      return;
    }
    _touchRecords(save: false);
  }

  /// 清理档案：只在本地文件已经不存在时才允许（界面已做限制，这里再兜一层）。
  void removeRecord(LocalDownloadRecord record) {
    if (!record.fileMissing) {
      return;
    }
    records.remove(record);
    _touchRecords(save: true);
  }

  /// 全部线路都失败时文件是空的：留在用户文件夹里只会变成一个 0B 的假视频。
  void _deleteIfEmpty(String filePath) {
    try {
      final file = File(filePath);
      if (file.existsSync() && file.lengthSync() == 0) {
        file.deleteSync();
      }
    } catch (_) {}
  }

  static const Set<String> _videoExts = {
    'mp4',
    'flv',
    'mov',
    'mkv',
    'm4s',
    'ts',
  };

  /// 文件名清洗：去掉各平台不允许的字符，避免落盘失败。
  static String sanitize(String name) {
    var s = name
        .replaceAll(RegExp(r'[\\/:*?"<>|\r\n\t]'), '_')
        .replaceAll(RegExp(r'[. ]+$'), '')
        .trim();
    if (s.isEmpty) {
      s = 'unnamed';
    }
    if (s.length > 80) {
      s = s.substring(0, 80);
    }
    return s;
  }

  static String _videoExt(String url) {
    final p = Uri.tryParse(url)?.path ?? '';
    final dot = p.lastIndexOf('.');
    if (dot == -1) {
      return 'mp4';
    }
    final ext = p.substring(dot + 1).toLowerCase();
    return _videoExts.contains(ext) ? ext : 'mp4';
  }

  /// 重名时加序号，不覆盖已有文件。
  static String uniquePath(String dir, String baseName, String ext) {
    var file = File(path.join(dir, '$baseName.$ext'));
    var i = 1;
    while (file.existsSync()) {
      file = File(path.join(dir, '$baseName($i).$ext'));
      i++;
    }
    return file.path;
  }

  String? _targetDir() {
    final dir = Pref.downloadLocalPath;
    if (dir == null || dir.isEmpty) {
      SmartDialog.showToast(uiTx('还没设置下载到本地的位置'));
      return null;
    }
    try {
      final d = Directory(dir);
      if (!d.existsSync()) {
        d.createSync(recursive: true);
      }
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('local download dir: $e\n\n$s');
      }
      SmartDialog.showToast(uiTx('下载位置不可用，请重新选择'));
      return null;
    }
    return dir;
  }

  /// 视频下载到本地：取 `fnval = 1` 的单文件流（已封装好的 MP4）。
  Future<bool> downloadVideo({
    required int avid,
    required String bvid,
    required int cid,
    required String title,
    int qn = 80,
    String? ownerName,
    String? cover,
  }) async {
    final dir = _targetDir();
    if (dir == null) {
      return false;
    }
    final isLogin = Accounts.get(AccountType.video).isLogin;
    final res = await VideoHttp.videoUrl(
      avid: avid,
      bvid: bvid,
      cid: cid,
      qn: qn,
      tryLook: !isLogin && Pref.p1080,
      videoType: VideoType.ugc,
      allowAppSource: false,
      fnval: 1,
    );
    if (res case Success(:final response)) {
      final durl = response.durl?.firstOrNull;
      final url = durl?.url;
      if (durl == null || url == null || url.isEmpty) {
        SmartDialog.showToast(uiTx('没有拿到可下载的视频流'));
        return false;
      }
      // durl（fnval=1 的整段 MP4）的直链签名是**跟 host 绑定**的：把 host 改写成
      // 别的 CDN（Akamai）会被服务端判成签名不匹配直接 403，表现就是「下载失败、
      // 落盘 0B」。所以这里**不做任何 CDN 改写**，直接用服务端给的第一条地址，
      // 备用地址按原顺序兜底 —— 与 DownloadHttp 取 durl 的做法一致。
      final urls = <String>[url, ...?durl.backupUrl];
      final ext = _videoExt(url);
      final filePath = uniquePath(dir, sanitize(title), ext);
      final record = _upsertRecord(
        id: '$avid-$cid-v',
        isAudio: false,
        title: title,
        path: filePath,
        ownerName: ownerName,
        cover: cover,
      );
      await _start(
        urls: urls,
        filePath: filePath,
        title: title,
        record: record,
        referer: _bilibiliReferer,
        userAgent: _bilibiliUa,
      );
      return true;
    }
    SmartDialog.showToast(uiTx('取流失败，无法下载到本地'));
    return false;
  }

  /// 音频下载到本地：沿用原始容器，不转码。
  Future<bool> downloadAudio({
    required int avid,
    required String bvid,
    required int cid,
    required String title,
    String? seasonId,
    int? epId,
    required AudioQuality quality,
    String? ownerName,
    String? cover,
  }) async {
    final dir = _targetDir();
    if (dir == null) {
      return false;
    }
    final isLogin = Accounts.get(AccountType.video).isLogin;
    final res = await VideoHttp.videoUrl(
      avid: avid,
      bvid: bvid,
      cid: cid,
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
        SmartDialog.showToast(uiTx('该视频没有可用的音频流'));
        return false;
      }
      final target = quality.code;
      final ids = audios.map((e) => e.id).toList()..sort();
      final lower = ids.where((e) => e <= target).toList();
      final pick = lower.isNotEmpty ? lower.last : ids.first;
      final item = audios.firstWhere((e) => e.id == pick);
      final raw = <String>[
        if (item.baseUrl case final b?) b,
        ...?item.backupUrl,
      ];
      final mainUrl = VideoUtils.getCdnUrl(
        raw,
        isAudio: true,
        preferAkamai: VideoUtils.downloadPreferAkamai,
      );
      final urls = <String>[mainUrl, ...raw.where((e) => e != mainUrl)];
      final akamai = VideoUtils.akamaiVariant(mainUrl);
      if (akamai != null && !urls.contains(akamai)) {
        urls.insert(1, akamai);
      }
      final ext = AudioCacheService.extFromMime(item.mimeType);
      final filePath = uniquePath(dir, sanitize(title), ext);
      final record = _upsertRecord(
        id: '$avid-$cid-a',
        isAudio: true,
        title: title,
        path: filePath,
        ownerName: ownerName,
        cover: cover,
      );
      await _start(
        urls: urls,
        filePath: filePath,
        title: title,
        record: record,
      );
      return true;
    }
    SmartDialog.showToast(uiTx('取流失败，无法下载到本地'));
    return false;
  }

  Future<void> _start({
    required List<String> urls,
    required String filePath,
    required String title,
    required LocalDownloadRecord record,
    String? referer,
    String? userAgent,
  }) async {
    SmartDialog.showToast(uiTxP('开始下载到本地: {0}', [title]));
    DownloadManager(
      urls: urls,
      path: filePath,
      referer: referer,
      userAgent: userAgent,
      onReceiveProgress: (received, total) {
        record.receivedBytes = received;
        if (total > 0) {
          record.totalBytes = total;
        }
        // 进度是高频回调：只刷界面，落盘交给节流后的 onDone。
        _touchRecords(save: false);
      },
      onDone: ([Object? error]) {
        if (error != null) {
          if (kDebugMode) {
            debugPrint('local download failed: $error');
          }
          record.failed = true;
          _deleteIfEmpty(filePath);
          _touchRecords(save: true);
          SmartDialog.showToast(uiTxP('{0} 下载失败', [title]));
          return;
        }
        record.done = true;
        record.failed = false;
        if (record.totalBytes > 0) {
          record.receivedBytes = record.totalBytes;
        }
        _touchRecords(save: true);
        SmartDialog.showToast(uiTxP('{0} 已下载到本地', [title]));
      },
    );
  }
}
