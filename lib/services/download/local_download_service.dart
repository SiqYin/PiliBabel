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

/// 「下载到本地」：把视频 / 音频按能直接播放的格式写进用户自己选的文件夹。
///
/// 与软件内缓存（[AudioCacheService] / DownloadService）的区别：
/// - 视频走 `fnval = 1` 的单文件流，服务端已经把视频和音频封装在同一个 MP4 里，
///   落盘就能用系统播放器播，不需要再拼 DASH 分片；
/// - 音频保持原始容器（m4a / mp3 / flac / wav ...），只做落盘不转码；
/// - 不写缓存索引、不进缓存列表，纯粹是本地文件。
class LocalDownloadService extends GetxService {
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
      final raw = <String>[url, ...?durl.backupUrl];
      final mainUrl = VideoUtils.getCdnUrl(
        raw,
        preferAkamai: VideoUtils.downloadPreferAkamai,
      );
      final urls = <String>[mainUrl, ...raw.where((e) => e != mainUrl)];
      final akamai = VideoUtils.akamaiVariant(mainUrl);
      if (akamai != null && !urls.contains(akamai)) {
        urls.insert(1, akamai);
      }
      final ext = _videoExt(mainUrl);
      await _start(
        urls: urls,
        filePath: uniquePath(dir, sanitize(title), ext),
        title: title,
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
      final raw = <String>[item.baseUrl, ...?item.backupUrl];
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
      await _start(
        urls: urls,
        filePath: uniquePath(dir, sanitize(title), ext),
        title: title,
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
  }) async {
    SmartDialog.showToast(uiTxP('开始下载到本地: {0}', [title]));
    DownloadManager(
      urls: urls,
      path: filePath,
      onReceiveProgress: null,
      onDone: ([Object? error]) {
        if (error != null) {
          if (kDebugMode) {
            debugPrint('local download failed: $error');
          }
          SmartDialog.showToast(uiTxP('{0} 下载失败', [title]));
          return;
        }
        SmartDialog.showToast(uiTxP('{0} 已下载到本地', [title]));
      },
    );
  }
}
