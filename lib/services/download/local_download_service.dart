import 'dart:async';
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
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/video_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:collection/collection.dart';
import 'package:PiliPlus/models/common/account_type.dart';
import 'package:PiliPlus/models_new/download/local_download_record.dart';
import 'package:PiliPlus/models/video/play/url.dart' show BaseItem;
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

  /// 正在下载中的档案 id，防止同一内容被并发触发两次下载
  /// （入口多点、重复点「重新下载」等）。
  final Set<String> _activeIds = {};

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
    int qn = 0,
    int audioQa = 0,
    String? extraPath,
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
      qn: qn,
      audioQa: audioQa,
      extraPath: extraPath,
    );
    records.insert(0, record);
    _touchRecords(save: true);
    return record;
  }

  /// 重新下载一条档案：沿用当时选的画质 / 音质，不再弹选择器。
  ///
  /// 只在下载失败或本地文件已删除的场景由界面提供入口；这里直接按档案里的
  /// avid / cid / 画质（旧档案没有则按 1080P / 192K 兜底）重新走一遍下载。
  Future<void> redownload(LocalDownloadRecord record) async {
    final avid = record.avid;
    final cid = record.cid;
    if (avid <= 0 || cid <= 0) {
      SmartDialog.showToast(uiTx('该档案缺少重新下载所需的信息'));
      return;
    }
    if (_activeIds.contains(record.id)) {
      SmartDialog.showToast(uiTx('该内容正在下载'));
      return;
    }
    final bvid = IdUtils.av2bv(avid);
    if (record.isAudio) {
      final qa = record.audioQa == 0
          ? AudioQuality.k192
          : AudioQuality.values
                .where((e) => e.code == record.audioQa)
                .firstOrNull ?? AudioQuality.k192;
      await downloadAudio(
        avid: avid,
        bvid: bvid,
        cid: cid,
        title: record.title,
        quality: qa,
        ownerName: record.ownerName,
        cover: record.cover,
      );
    } else {
      await downloadVideo(
        avid: avid,
        bvid: bvid,
        cid: cid,
        title: record.title,
        qn: record.qn == 0 ? 80 : record.qn,
        ownerName: record.ownerName,
        cover: record.cover,
      );
    }
  }

  /// 删除档案对应的本地文件。档案**保留**，界面随之显示「本地文件已删除」，
  /// 再点「清理档案」才会从列表里消失。
  Future<void> deleteLocalFile(LocalDownloadRecord record) async {
    try {
      for (final p in [record.path, ?record.extraPath]) {
        final file = File(p);
        if (file.existsSync()) {
          await file.delete();
        }
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

  String? _targetDir({String? collectionName}) {
    final dir = Pref.downloadLocalPath;
    if (dir == null || dir.isEmpty) {
      SmartDialog.showToast(uiTx('还没设置下载到本地的位置'));
      return null;
    }
    // 合集/多 P 视频：在所选目录下建一个以合集名命名的子文件夹，
    // 这样同一合集里后续追加下载的其它分集会自动落进同一个文件夹。
    // 合集名会做一次文件名净化（去掉路径分隔符等非法字符），避免建目录失败。
    final sub = _sanitizeFolderName(collectionName);
    final target = sub == null ? dir : path.join(dir, sub);
    try {
      final d = Directory(target);
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
    return target;
  }

  /// 把合集名净化成安全的目录名；没有可用字符时返回 null（表示不建子目录）。
  static String? _sanitizeFolderName(String? raw) {
    if (raw == null) {
      return null;
    }
    var name = raw.trim();
    if (name.isEmpty) {
      return null;
    }
    // Windows / macOS / Linux 都不允许的字符，统一换成下划线
    name = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '_');
    // 去掉首尾的点与空格（Windows 不允许以点结尾）
    name = name.replaceAll(RegExp(r'^[.\s]+|[.\s]+$'), '');
    if (name.isEmpty) {
      return null;
    }
    // 目录名过长会触发文件系统限制，截断到 80 个字符
    if (name.length > 80) {
      name = name.substring(0, 80);
    }
    return name;
  }

  /// 1080P（qn=80）是单文件 MP4（fnval=1 的 durl）能拿到的上限：
  /// 1080P60 / 1080P+ / 4K / 杜比 / HDR / 8K 这些档位在服务端只有 DASH
  /// 分离流，就算登录了大会员，走 durl 也只会拿到降级画质甚至空地址——
  /// 这正是「选高画质下载失败」的根因。所以高于 80 的画质改走 DASH。
  static const int _singleFileMaxQn = 80;

  /// 视频下载到本地。
  ///
  /// - 画质 ≤ 1080P：取 `fnval = 1` 的单文件流（已封装好的 MP4，落盘即播）；
  /// - 画质 > 1080P（1080P60、4K、杜比、HDR、8K……）：这些档位只有 DASH
  ///   分离流，下载「视频轨 + 音频轨」两个文件（mp4 + m4a），进度合并在
  ///   同一条档案里；两个文件都在，播放器（mpv / VLC 等）可一起播放或再合并。
  Future<bool> downloadVideo({
    required int avid,
    required String bvid,
    required int cid,
    required String title,
    int qn = 80,
    String? ownerName,
    String? cover,
    String? collectionName,
  }) async {
    final dir = _targetDir(collectionName: collectionName);
    if (dir == null) {
      return false;
    }
    final id = '$avid-$cid-v';
    if (_activeIds.contains(id)) {
      SmartDialog.showToast(uiTx('该内容正在下载'));
      return false;
    }
    if (qn > _singleFileMaxQn) {
      return _downloadVideoDash(
        avid: avid,
        bvid: bvid,
        cid: cid,
        title: title,
        qn: qn,
        ownerName: ownerName,
        cover: cover,
        dir: dir,
      );
    }
    _activeIds.add(id);
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
        _activeIds.remove(id);
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
        id: id,
        isAudio: false,
        title: title,
        path: filePath,
        ownerName: ownerName,
        cover: cover,
        qn: qn,
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
    _activeIds.remove(id);
    SmartDialog.showToast(uiTx('取流失败，无法下载到本地'));
    return false;
  }

  /// 高画质（> 1080P）的视频下载：DASH 取流，落「视频轨 + 音频轨」两个文件。
  Future<bool> _downloadVideoDash({
    required int avid,
    required String bvid,
    required int cid,
    required String title,
    required int qn,
    String? ownerName,
    String? cover,
    required String dir,
  }) async {
    final id = '$avid-$cid-v';
    _activeIds.add(id);
    final isLogin = Accounts.get(AccountType.video).isLogin;
    // fnval 默认 4048（DASH），fourk=1 已由请求层固定携带。
    final res = await VideoHttp.videoUrl(
      avid: avid,
      bvid: bvid,
      cid: cid,
      qn: qn,
      tryLook: !isLogin && Pref.p1080,
      videoType: VideoType.ugc,
      allowAppSource: false,
    );
    if (res case Success(:final response)) {
      final videos = response.dash?.video;
      if (videos == null || videos.isEmpty) {
        _activeIds.remove(id);
        SmartDialog.showToast(uiTx('没有拿到可下载的视频流'));
        return false;
      }
      // 档位选择：优先不高于所选 qn 的最高档，都高于时退到最低档（与音频一致）。
      final fit = videos.where((e) => e.id <= qn).toList();
      final takeHighest = fit.isNotEmpty;
      final pool = takeHighest ? fit : videos;
      final video = pool.reduce(
        (a, b) => takeHighest ? (a.id > b.id ? a : b) : (a.id < b.id ? a : b),
      );
      if (video.id != qn) {
        SmartDialog.showToast(
          uiTxP('所选画质不可用，已按 {0} 下载', [video.quality.shortDesc]),
        );
      }
      // 音轨取当前账号可用的最高档（Hi-Res > 杜比 > 320K > …，列表已按此序）。
      final audio = response.dash?.audio
          ?.reduce((a, b) => a.id > b.id ? a : b);

      String mainUrlOf(BaseItem item, {bool isAudio = false}) {
        return VideoUtils.getCdnUrl(
          item.playUrls,
          isAudio: isAudio,
          preferAkamai: VideoUtils.downloadPreferAkamai,
        );
      }

      final videoMain = mainUrlOf(video);
      final videoUrls = <String>[
        videoMain,
        ...video.playUrls.where((u) => u != videoMain),
      ];
      final videoPath = uniquePath(
        dir,
        '${sanitize(title)} (${sanitize(video.quality.shortDesc)})',
        'mp4',
      );
      String? audioPath;
      List<String>? audioUrls;
      if (audio?.baseUrl?.isNotEmpty == true) {
        final audioMain = mainUrlOf(audio!, isAudio: true);
        audioUrls = <String>[
          audioMain,
          ...audio.playUrls.where((u) => u != audioMain),
        ];
        audioPath = uniquePath(
          dir,
          '${sanitize(title)} (${sanitize(audio.quality)})',
          AudioCacheService.extFromMime(audio.mimeType),
        );
      }
      final record = _upsertRecord(
        id: id,
        isAudio: false,
        title: title,
        path: videoPath,
        ownerName: ownerName,
        cover: cover,
        qn: qn,
        extraPath: audioPath,
      );
      await _startSplitStreams(
        videoUrls: videoUrls,
        videoPath: videoPath,
        audioUrls: audioUrls,
        audioPath: audioPath,
        title: title,
        record: record,
      );
      return true;
    }
    _activeIds.remove(id);
    SmartDialog.showToast(uiTx('取流失败，无法下载到本地'));
    return false;
  }

  /// 分离流下载：先视频轨、后音频轨，串行执行，进度合并到同一条档案。
  Future<void> _startSplitStreams({
    required List<String> videoUrls,
    required String videoPath,
    required List<String>? audioUrls,
    required String? audioPath,
    required String title,
    required LocalDownloadRecord record,
  }) async {
    SmartDialog.showToast(uiTxP('开始下载到本地: {0}', [title]));

    /// 下载一条轨。[baseBytes] 是已完成轨的实际字节数，进度在此基础上累加。
    Future<bool> runTrack(
      List<String> urls,
      String filePath,
      int baseBytes,
    ) {
      final completer = Completer<bool>();
      DownloadManager(
        urls: urls,
        path: filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            record.totalBytes = baseBytes + total;
          }
          record.receivedBytes = baseBytes + received;
          _touchRecords(save: false);
        },
        onDone: ([Object? error]) {
          if (error != null) {
            if (kDebugMode) {
              debugPrint('local download (split) failed: $error');
            }
          }
          completer.complete(error == null);
        },
      );
      return completer.future;
    }

    final videoOk = await runTrack(videoUrls, videoPath, 0);
    if (!videoOk) {
      record.failed = true;
      _deleteIfEmpty(videoPath);
      if (audioPath != null) {
        _deleteIfEmpty(audioPath);
      }
      _touchRecords(save: true);
      _activeIds.remove(record.id);
      SmartDialog.showToast(uiTxP('{0} 下载失败', [title]));
      return;
    }
    final videoBytes = () {
      try {
        return File(videoPath).lengthSync();
      } catch (_) {
        return record.receivedBytes;
      }
    }();
    if (audioUrls != null && audioPath != null) {
      final audioOk = await runTrack(audioUrls, audioPath, videoBytes);
      if (!audioOk) {
        record.failed = true;
        _deleteIfEmpty(audioPath);
        _touchRecords(save: true);
        _activeIds.remove(record.id);
        SmartDialog.showToast(uiTxP('{0} 下载失败', [title]));
        return;
      }
    }
    record
      ..done = true
      ..failed = false;
    if (record.totalBytes > 0) {
      record.receivedBytes = record.totalBytes;
    }
    _touchRecords(save: true);
    _activeIds.remove(record.id);
    SmartDialog.showToast(uiTxP('{0} 已下载到本地', [title]));
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
    String? collectionName,
  }) async {
    final dir = _targetDir(collectionName: collectionName);
    if (dir == null) {
      return false;
    }
    final id = '$avid-$cid-a';
    if (_activeIds.contains(id)) {
      SmartDialog.showToast(uiTx('该内容正在下载'));
      return false;
    }
    _activeIds.add(id);
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
      // 4048（DASH 全家桶）不含 4096（Hi-Res 无损位）：不补这一位，取流结果里
      // 永远不会有 Hi-Res（30251）轨，「下载 Hi-Res」会静默退化成 320K。
      fnval: 4048 | 4096,
    );
    if (res case Success(:final response)) {
      final audios = response.dash?.audio;
      if (audios == null || audios.isEmpty) {
        _activeIds.remove(id);
        SmartDialog.showToast(uiTx('该视频没有可用的音频流'));
        return false;
      }
      final target = quality.code;
      final ids = audios.map((e) => e.id).toList()..sort();
      final lower = ids.where((e) => e <= target).toList();
      final pick = lower.isNotEmpty ? lower.last : ids.first;
      if (pick != target) {
        final picked = AudioQuality.values
            .where((e) => e.code == pick)
            .firstOrNull;
        SmartDialog.showToast(
          uiTxP('所选音质不可用，已按 {0} 下载', [picked?.desc ?? '$pick']),
        );
      }
      final item = audios.firstWhere((e) => e.id == pick);
      final raw = <String>[
        ?item.baseUrl,
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
        id: id,
        isAudio: true,
        title: title,
        path: filePath,
        ownerName: ownerName,
        cover: cover,
        audioQa: pick,
      );
      await _start(
        urls: urls,
        filePath: filePath,
        title: title,
        record: record,
      );
      return true;
    }
    _activeIds.remove(id);
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
        _activeIds.remove(record.id);
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
        record
          ..done = true
          ..failed = false;
        if (record.totalBytes > 0) {
          record.receivedBytes = record.totalBytes;
        }
        _touchRecords(save: true);
        SmartDialog.showToast(uiTxP('{0} 已下载到本地', [title]));
      },
    );
  }
}
