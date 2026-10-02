import 'dart:async';
import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show Directory, File;

import 'package:PiliPlus/grpc/dm.dart';
import 'package:PiliPlus/http/download.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/sponsor_block.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/models_new/download/bili_download_entry_info.dart';
import 'package:PiliPlus/models_new/download/bili_download_media_file_info.dart';
import 'package:PiliPlus/models_new/download/playback_meta.dart';
import 'package:PiliPlus/models_new/pgc/pgc_info_model/episode.dart' as pgc;
import 'package:PiliPlus/models_new/pgc/pgc_info_model/result.dart';
import 'package:PiliPlus/models_new/sponsor_block/segment_item.dart';
import 'package:PiliPlus/models_new/video/video_detail/data.dart';
import 'package:PiliPlus/models_new/video/video_detail/episode.dart' as ugc;
import 'package:PiliPlus/models_new/video/video_detail/page.dart';
import 'package:PiliPlus/models_new/video/video_play_info/subtitle.dart';
import 'package:PiliPlus/pages/danmaku/controller.dart';
import 'package:PiliPlus/services/download/download_manager.dart';
import 'package:PiliPlus/utils/cache_manager.dart';
import 'package:PiliPlus/utils/danmaku_utils.dart';
import 'package:PiliPlus/utils/extension/file_ext.dart';
import 'package:PiliPlus/utils/extension/string_ext.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:synchronized/synchronized.dart';

// ref https://github.com/10miaomiao/bilimiao2/blob/master/bilimiao-download/src/main/java/cn/a10miaomiao/bilimiao/download/DownloadService.kt

class DownloadService extends GetxService {
  static const _entryFile = 'entry.json';
  static const _indexFile = 'index.json';
  static const _maxDanmakuConcurrency = 4;

  final _lock = Lock();

  /// 弹幕下载锁：批量更新时外层 Future.wait 会并发调用多次 downloadDanmaku，
  /// 此锁确保同一时间只有一个视频在下载弹幕，避免总并发超过 _maxDanmakuConcurrency。
  final _danmakuLock = Lock();

  final flagNotifier = SetNotifier();
  final completedEntryNotifier = Set<ValueChanged<BiliDownloadEntryInfo>>();
  final waitDownloadQueue = RxList<BiliDownloadEntryInfo>();
  final downloadList = <BiliDownloadEntryInfo>[];

  int? _curCid;
  int? get curCid => _curCid;
  final curDownload = Rxn<BiliDownloadEntryInfo>();
  void _updateCurStatus(DownloadStatus status) {
    if (curDownload.value != null) {
      curDownload
        ..value!.status = status
        ..refresh();
    }
  }

  DownloadManager? _downloadManager;
  DownloadManager? _audioDownloadManager;

  /// 音频失败自动重试：直链有 deadline/偶发 403，失败后重取 playurl 并
  /// 从已有断点续传（不清空视频进度）；重试耗尽才标记失败。
  static const int _maxAudioRetries = 2;
  int _audioRetryLeft = 0;
  bool _audioRetrying = false;

  late Future<void> waitForInitialization;

  @override
  void onInit() {
    super.onInit();
    initDownloadList();
  }

  void initDownloadList() {
    waitForInitialization = _readDownloadList();
  }

  Future<void> _readDownloadList() async {
    downloadList.clear();
    final downloadDir = Directory(await _getDownloadPath());
    await for (final dir in downloadDir.list()) {
      if (dir is Directory) {
        downloadList.addAll(await _readDownloadDirectory(dir));
      }
    }
    downloadList.sort((a, b) => b.timeUpdateStamp.compareTo(a.timeUpdateStamp));
  }

  @pragma('vm:notify-debugger-on-exception')
  Future<List<BiliDownloadEntryInfo>> _readDownloadDirectory(
    Directory pageDir,
  ) async {
    final result = <BiliDownloadEntryInfo>[];

    if (!pageDir.existsSync()) {
      return result;
    }

    await for (final entryDir in pageDir.list()) {
      if (entryDir is Directory) {
        final entryFile = File(path.join(entryDir.path, _entryFile));
        if (entryFile.existsSync()) {
          try {
            final entryJson = await entryFile.readAsString();
            final entry = BiliDownloadEntryInfo.fromJson(jsonDecode(entryJson))
              ..pageDirPath = pageDir.path
              ..entryDirPath = entryDir.path;
            if (entry.isCompleted) {
              result.add(entry);
            } else {
              waitDownloadQueue.add(entry..status = DownloadStatus.wait);
            }
          } catch (_) {}
        }
      }
    }

    return result;
  }

  void downloadVideo(
    Part page,
    VideoDetailData? videoDetail,
    ugc.EpisodeItem? videoArc,
    VideoQuality videoQuality, {
    String? autoFolderTitle,
    String? autoFolderSourceKey,
  }) {
    final cid = page.cid!;
    if (downloadList.indexWhere((e) => e.cid == cid) != -1) {
      return;
    }
    if (waitDownloadQueue.indexWhere((e) => e.cid == cid) != -1) {
      return;
    }
    final pageData = PageInfo(
      cid: cid,
      page: page.page!,
      from: page.from,
      part: page.part,
      vid: page.vid,
      hasAlias: false,
      tid: 0,
      width: 0,
      height: 0,
      rotate: 0,
      downloadTitle: '视频已缓存完成',
      downloadSubtitle: videoDetail?.title ?? videoArc!.title,
    );
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final entry = BiliDownloadEntryInfo(
      mediaType: 2,
      hasDashAudio: false,
      isCompleted: false,
      totalBytes: 0,
      downloadedBytes: 0,
      title: videoDetail?.title ?? videoArc!.title!,
      typeTag: videoQuality.code.toString(),
      cover: (videoDetail?.pic ?? videoArc!.cover!).http2https,
      preferedVideoQuality: videoQuality.code,
      qualityPithyDescription: videoQuality.desc,
      guessedTotalBytes: 0,
      totalTimeMilli: (page.duration ?? 0) * 1000,
      danmakuCount:
          videoDetail?.stat?.danmaku ?? videoArc?.arc?.stat?.danmaku ?? 0,
      timeUpdateStamp: currentTime,
      timeCreateStamp: currentTime,
      canPlayInAdvance: true,
      interruptTransformTempFile: false,
      avid: videoDetail?.aid ?? videoArc!.aid!,
      spid: 0,
      seasonId: null,
      ep: null,
      source: null,
      bvid: videoDetail?.bvid ?? videoArc!.bvid!,
      ownerId: videoDetail?.owner?.mid ?? videoArc?.arc?.author?.mid,
      ownerName: videoDetail?.owner?.name ?? videoArc?.arc?.author?.name,
      pageData: pageData,
      autoFolderTitle: autoFolderTitle,
      autoFolderSourceKey: autoFolderSourceKey,
    );
    _createDownload(entry);
  }

  void downloadBangumi(
    int index,
    PgcInfoModel pgcItem,
    pgc.EpisodeItem episode,
    VideoQuality quality,
  ) {
    final cid = episode.cid!;
    if (downloadList.indexWhere((e) => e.cid == cid) != -1) {
      return;
    }
    if (waitDownloadQueue.indexWhere((e) => e.cid == cid) != -1) {
      return;
    }
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final source = SourceInfo(
      avId: episode.aid!,
      cid: cid,
    );
    final ep = EpInfo(
      avId: source.avId,
      page: index,
      danmaku: source.cid,
      cover: episode.cover!,
      episodeId: episode.id!,
      index: episode.title!,
      indexTitle: episode.longTitle ?? '',
      showTitle: episode.showTitle,
      from: episode.from ?? 'bangumi',
      seasonType: pgcItem.type ?? (episode.from == 'pugv' ? -1 : 0),
      width: 0,
      height: 0,
      rotate: 0,
      link: episode.link ?? '',
      bvid: episode.bvid ?? IdUtils.av2bv(source.avId),
      sortIndex: index,
    );
    final entry = BiliDownloadEntryInfo(
      mediaType: 2,
      hasDashAudio: false,
      isCompleted: false,
      totalBytes: 0,
      downloadedBytes: 0,
      title: pgcItem.seasonTitle ?? pgcItem.title ?? '',
      typeTag: quality.code.toString(),
      cover: episode.cover!,
      preferedVideoQuality: quality.code,
      qualityPithyDescription: quality.desc,
      guessedTotalBytes: 0,
      totalTimeMilli:
          (episode.duration ?? 0) *
          (episode.from == 'pugv' ? 1000 : 1), // pgc millisec,, pugv sec
      danmakuCount: pgcItem.stat?.danmaku ?? 0,
      timeUpdateStamp: currentTime,
      timeCreateStamp: currentTime,
      canPlayInAdvance: true,
      interruptTransformTempFile: false,
      spid: 0,
      seasonId: pgcItem.seasonId!.toString(),
      bvid: episode.bvid ?? IdUtils.av2bv(source.avId),
      avid: source.avId,
      ep: ep,
      source: source,
      ownerId: pgcItem.upInfo?.mid,
      ownerName: pgcItem.upInfo?.uname,
      pageData: null,
    );
    _createDownload(entry);
  }

  Future<void> _createDownload(BiliDownloadEntryInfo entry) async {
    final entryDir = await _getDownloadEntryDir(entry);
    final entryJsonFile = File(path.join(entryDir.path, _entryFile));
    await entryJsonFile.writeAsString(jsonEncode(entry.toJson()));
    entry
      ..pageDirPath = entryDir.parent.path
      ..entryDirPath = entryDir.path
      ..status = DownloadStatus.wait;
    waitDownloadQueue.add(entry);
    if (curDownload.value?.status.isDownloading != true) {
      startDownload(entry);
    }
  }

  Future<Directory> _getDownloadEntryDir(BiliDownloadEntryInfo entry) async {
    late final String dirName;
    late final String pageDirName;
    if (entry.ep case final ep?) {
      dirName = 's_${entry.seasonId}';
      pageDirName = ep.episodeId.toString();
    } else if (entry.pageData case final page?) {
      dirName = entry.avid.toString();
      pageDirName = 'c_${page.cid}';
    }
    final pageDir = Directory(
      path.join(await _getDownloadPath(), dirName, pageDirName),
    );
    if (!pageDir.existsSync()) {
      await pageDir.create(recursive: true);
    }
    return pageDir;
  }

  static Future<String> _getDownloadPath() async {
    final dir = Directory(downloadPath);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  /// 等待某个下载器收尾，最多 10s。
  /// 兜底：万一旧任务因异常路径没返回，也不能把 [_lock] 永久占住——
  /// 那会让「切换到队列里的其它项」彻底失效（点别的没反应）。
  /// 超时后旧实例的回调由 mgr 身份校验丢弃，不会污染新任务。
  Future<void> _cancelAndWait(
    DownloadManager? manager, {
    required bool isDelete,
  }) async {
    if (manager == null) {
      return;
    }
    await manager
        .cancel(isDelete: isDelete)
        .timeout(const Duration(seconds: 10), onTimeout: () {});
  }

  Future<void> startDownload(BiliDownloadEntryInfo entry) {
    return _lock.synchronized(() async {
      await _cancelAndWait(_downloadManager, isDelete: false);
      await _cancelAndWait(_audioDownloadManager, isDelete: false);
      _downloadManager = null;
      _audioDownloadManager = null;
      if (curDownload.value case final curEntry?) {
        if (curEntry.status.isDownloading) {
          curEntry.status = DownloadStatus.pause;
        }
      }

      _curCid = entry.cid;
      curDownload.value = entry;
      waitDownloadQueue.refresh();
      await _startDownload(entry);
    });
  }

  Future<bool> downloadDanmaku({
    required BiliDownloadEntryInfo entry,
    bool isUpdate = false,
  }) async {
    final cid = entry.pageData?.cid ?? entry.source?.cid;
    if (cid == null) {
      return false;
    }
    return _danmakuLock.synchronized<bool>(() async {
    final danmakuFile = File(
      path.join(entry.entryDirPath, PathUtils.danmakuName),
    );
    if (isUpdate || !danmakuFile.existsSync()) {
      try {
        if (!isUpdate) {
          _updateCurStatus(DownloadStatus.getDanmaku);
        }
        final seg = (entry.totalTimeMilli / DmUtils.segLength).ceil();
        if (seg <= 0) {
          throw StateError('Invalid danmaku segment count: $seg');
        }

        // 弹幕不是播放必需，而海外 grpc 有可能整段挂死：这里给一个总时限。
        // 挂在这一步会连带占住 startDownload 的下载锁——表现就是
        // 「正在下载」长期不动、点队列里其它等待项也没反应。
        final bytes = await _fetchDanmakuBytes(
          cid,
          seg,
        ).timeout(_danmakuBudget, onTimeout: () => null);
        if (bytes == null) {
          // 超时/风控/分段不全：不落盘（文件存在即代表完整，之后可再更新）。
          // 首次缓存不因此中断视频下载；手动「更新弹幕」则如实返回失败。
          return !isUpdate;
        }
        await danmakuFile.writeAsBytes(bytes);

        return true;
      } catch (e) {
        if (!isUpdate) {
          _updateCurStatus(DownloadStatus.failDanmaku);
        }
        if (kDebugMode) SmartDialog.showToast(e.toString());
        return false;
      }
    }
    return true;
    });
  }

  /// 弹幕分段拉取的总时限
  static const Duration _danmakuBudget = Duration(seconds: 60);

  /// 逐段拉取弹幕（并发 [_maxDanmakuConcurrency]）。
  /// 返回序列化结果；任一段失败/首段无数据则返回 null，调用方据此**不落盘**，
  /// 保证「文件存在即完整」，之后仍可用「更新弹幕」补齐。
  Future<Uint8List?> _fetchDanmakuBytes(int cid, int seg) async {
    final first = (await DmGrpc.dmSegMobile(
      cid: cid,
      segmentIndex: 1,
    )).dataOrNull;
    if (first == null) {
      return null;
    }
    var complete = true;
    for (var start = 2; start <= seg; start += _maxDanmakuConcurrency) {
      final end = start + _maxDanmakuConcurrency - 1;
      final responses = await Future.wait([
        for (var index = start; index <= seg && index <= end; index++)
          DmGrpc.dmSegMobile(cid: cid, segmentIndex: index),
      ]);
      for (final response in responses) {
        final data = response.dataOrNull;
        if (data == null) {
          complete = false;
          continue;
        }
        first.elems.addAll(data.elems);
      }
      responses.clear();
    }
    if (!complete) {
      return null;
    }
    return first.writeToBuffer();
  }

  Future<void> _downloadSubtitles({
    required BiliDownloadEntryInfo entry,
  }) async {
    try {
      final cid = entry.pageData?.cid ?? entry.source?.cid;
      if (cid == null) return;

      final res = await VideoHttp.playInfo(
        bvid: entry.bvid,
        cid: cid,
        seasonId: entry.seasonId,
        epId: entry.ep?.episodeId,
      );
      final List<Subtitle>? subtitleList;
      if (res case Success(:final response)) {
        subtitleList = response.subtitle?.subtitles;
      } else {
        return;
      }
      if (subtitleList == null || subtitleList.isEmpty) return;

      final vttResults = await Future.wait(
        subtitleList.map((sub) async {
          if (sub.subtitleUrl?.isNotEmpty != true) return null;
          try {
            return await VideoHttp.getSubtitles(sub.subtitleUrl!);
          } catch (_) {
            return null;
          }
        }),
      );

      final subsDir = Directory(
        path.join(entry.entryDirPath, PathUtils.subtitlesDirName),
      );
      if (!subsDir.existsSync()) {
        await subsDir.create(recursive: true);
      }

      final successfulSubs = <Subtitle>[];
      for (int i = 0; i < subtitleList.length; i++) {
        final vtt = vttResults[i];
        if (vtt == null) continue;
        final sub = subtitleList[i];
        try {
          await File(
            path.join(subsDir.path, PathUtils.subtitleVttName(sub.lan)),
          ).writeAsString(vtt);
          successfulSubs.add(sub);
        } catch (_) {}
      }
      if (successfulSubs.isEmpty) return;

      final indexJson = successfulSubs
          .map(
            (sub) => {
              'lan': sub.lan,
              'lan_doc': sub.isAi
                  ? sub.lanDoc!.substring(
                      0,
                      sub.lanDoc!.length - '（AI）'.length,
                    )
                  : sub.lanDoc ?? '',
              'subtitle_url': sub.subtitleUrl ?? '',
              'subtitle_url_v2': sub.subtitleUrlV2,
              'type': sub.isAi ? 1 : 0,
            },
          )
          .toList();
      await File(
        path.join(subsDir.path, PathUtils.subtitleIndexName),
      ).writeAsString(jsonEncode(indexJson));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('_downloadSubtitles failed: $e');
      }
    }
  }

  Future<bool> _downloadCover({
    required BiliDownloadEntryInfo entry,
  }) async {
    try {
      final filePath = path.join(entry.entryDirPath, PathUtils.coverName);
      if (File(filePath).existsSync()) {
        return true;
      }
      final file = (await CacheManager.manager.getFileFromCache(
        entry.cover,
      ))?.file;
      if (file != null) {
        await file.copy(filePath);
      } else {
        await Request.dio.download(entry.cover, filePath);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<DownloadPlaybackChapters?> _queryPlaybackChapters({
    required BiliDownloadEntryInfo entry,
    required int fetchedAt,
  }) async {
    try {
      final res = await VideoHttp.playInfo(
        bvid: entry.bvid,
        cid: entry.cid,
        seasonId: entry.seasonId,
        epId: entry.ep?.episodeId,
      );
      if (res case Success(:final response)) {
        final viewPoints = response.viewPoints;
        if (viewPoints != null &&
            viewPoints.isNotEmpty &&
            viewPoints.first.type == 2) {
          return DownloadPlaybackChapters(
            fetchedAt: fetchedAt,
            items: viewPoints
                .map(
                  (item) => DownloadPlaybackChapter(
                    type: item.type,
                    fromMs: item.from == null ? null : item.from! * 1000,
                    toMs: item.to == null ? null : item.to! * 1000,
                    content: item.content,
                    imgUrl: item.imgUrl,
                  ),
                )
                .toList(),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('download playback chapters failed: $e');
      }
    }
    return null;
  }

  Future<DownloadPlaybackSkipSegments?> _querySponsorBlockSegments({
    required BiliDownloadEntryInfo entry,
    required int fetchedAt,
  }) async {
    try {
      final res = await SponsorBlock.getSkipSegments(
        bvid: entry.bvid,
        cid: entry.cid,
      );
      switch (res) {
        case Success(:final response) when response.isNotEmpty:
          return DownloadPlaybackSkipSegments(
            fetchedAt: fetchedAt,
            items: response
                .map(DownloadPlaybackSkipSegment.fromSegmentItemModel)
                .toList(),
          );
        case Error(:final code) when code != 404:
          if (kDebugMode) {
            debugPrint('download sponsorblock failed: $res');
          }
        default:
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('download sponsorblock exception: $e');
      }
    }
    return null;
  }

  Future<void> _writePlaybackMeta({
    required BiliDownloadEntryInfo entry,
    List<SegmentItemModel>? clipInfoList,
  }) async {
    try {
      final fetchedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final results = await Future.wait<Object?>([
        _queryPlaybackChapters(entry: entry, fetchedAt: fetchedAt),
        _querySponsorBlockSegments(entry: entry, fetchedAt: fetchedAt),
      ]);
      final meta = DownloadPlaybackMeta(
        chapters: results[0] as DownloadPlaybackChapters?,
        sponsorBlock: results[1] as DownloadPlaybackSkipSegments?,
        clipInfo: clipInfoList?.isNotEmpty == true
            ? DownloadPlaybackSkipSegments(
                fetchedAt: fetchedAt,
                items: clipInfoList!
                    .map(DownloadPlaybackSkipSegment.fromSegmentItemModel)
                    .toList(),
              )
            : null,
      );
      final playbackMetaFile = File(
        path.join(entry.entryDirPath, PathUtils.playbackMetaName),
      );
      if (meta.isEmpty) {
        if (playbackMetaFile.existsSync()) {
          await playbackMetaFile.tryDel();
        }
        return;
      }
      await playbackMetaFile.writeAsString(jsonEncode(meta.toJson()));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('write playback meta failed: $e');
      }
    }
  }

  Future<void> _startDownload(BiliDownloadEntryInfo entry) async {
    _audioRetryLeft = _maxAudioRetries;
    _audioRetrying = false;
    try {
      if (!await downloadDanmaku(entry: entry)) {
        return;
      }

      _updateCurStatus(DownloadStatus.getPlayUrl);

      // playurl 响应体大、海外易超时，且偶发风控(code!=0)：
      // 失败自动重试（“不存在”类永久错误除外），耗尽才标 failPlayUrl。
      const maxPlayUrlAttempts = 3;
      var playUrlAttempt = 0;
      late final DownloadVideoUrlResult downloadResult;
      while (true) {
        playUrlAttempt++;
        try {
          downloadResult = await DownloadHttp.getVideoUrl(
            entry: entry,
            ep: entry.ep,
            source: entry.source,
            pageData: entry.pageData,
          );
          break;
        } catch (e) {
          final msg = e.toString();
          if (playUrlAttempt >= maxPlayUrlAttempts || msg.contains('不存在')) {
            rethrow;
          }
          await Future.delayed(Duration(seconds: 2 * playUrlAttempt));
        }
      }
      final mediaFileInfo = downloadResult.mediaFileInfo;

      final videoDir = Directory(path.join(entry.entryDirPath, entry.typeTag));
      if (!videoDir.existsSync()) {
        await videoDir.create(recursive: true);
      }

      final mediaJsonFile = File(path.join(videoDir.path, _indexFile));
      await Future.wait([
        mediaJsonFile.writeAsString(jsonEncode(mediaFileInfo.toJson())),
        _downloadCover(entry: entry),
        _writePlaybackMeta(
          entry: entry,
          clipInfoList: downloadResult.clipInfoList,
        ),
      ]);

      if (curDownload.value?.cid != entry.cid) {
        return;
      }

      unawaited(_downloadSubtitles(entry: entry));

      switch (mediaFileInfo) {
        case Type1 mediaFileInfo:
          final first = mediaFileInfo.segmentList.first;
          // 回调只认「当前在用的下载器」：_cancelAndWait 超时兜底或切换队列项后，
          // 旧实例的进度/完成回调一律丢弃，避免污染新任务的状态与进度。
          late final DownloadManager videoMgr;
          videoMgr = DownloadManager(
            urls: [first.url],
            path: path.join(videoDir.path, PathUtils.videoNameType1),
            onReceiveProgress: (p, t) {
              if (identical(_downloadManager, videoMgr)) {
                _onReceive(p, t);
              }
            },
            onDone: ([e]) {
              if (identical(_downloadManager, videoMgr)) {
                _onDone(e);
              }
            },
            shouldDefer: _shouldDeferCurrent,
          );
          _downloadManager = videoMgr;
          break;
        case Type2 mediaFileInfo:
          late final DownloadManager videoMgr;
          videoMgr = DownloadManager(
            urls: downloadResult.videoUrls ??
                <String>[mediaFileInfo.video.first.baseUrl],
            path: path.join(videoDir.path, PathUtils.videoNameType2),
            onReceiveProgress: (p, t) {
              if (identical(_downloadManager, videoMgr)) {
                _onReceive(p, t);
              }
            },
            onDone: ([e]) {
              if (identical(_downloadManager, videoMgr)) {
                _onDone(e);
              }
            },
            shouldDefer: _shouldDeferCurrent,
          );
          _downloadManager = videoMgr;
          final audio = mediaFileInfo.audio;
          if (audio != null && audio.isNotEmpty) {
            late final DownloadManager audioMgr;
            audioMgr = DownloadManager(
              urls: downloadResult.audioUrls ??
                  <String>[audio.first.baseUrl],
              path: path.join(videoDir.path, PathUtils.audioNameType2),
              onReceiveProgress: null,
              onDone: ([e]) {
                if (identical(_audioDownloadManager, audioMgr)) {
                  _onAudioDone(e);
                }
              },
              shouldDefer: _shouldDeferCurrent,
            );
            _audioDownloadManager = audioMgr;
          }
          late final first = mediaFileInfo.video.first;
          entry.pageData
            ?..width = first.width
            ..height = first.height;
          entry.ep
            ?..width = first.width
            ..height = first.height;
          _updateBiliDownloadEntryJson(entry);
          break;
        default:
          break;
      }
    } catch (e) {
      _updateCurStatus(DownloadStatus.failPlayUrl);
      if (kDebugMode) {
        debugPrint('get download url error: $e');
      }
    }
  }

  Future<void> _updateBiliDownloadEntryJson(BiliDownloadEntryInfo entry) {
    final entryJsonFile = File(path.join(entry.entryDirPath, _entryFile));
    return entryJsonFile.writeAsString(jsonEncode(entry.toJson()));
  }

  void _onReceive(int progress, int total) {
    if (curDownload.value case final entry?) {
      if (progress == 0 && total != 0) {
        _updateBiliDownloadEntryJson(entry..totalBytes = total);
      }
      entry
        ..downloadedBytes = progress
        ..status = DownloadStatus.downloading;
      curDownload.refresh();
    }
  }

  void _onDone([Object? error]) {
    if (error is StallDeferred) {
      // 停摆且队列还有其它项：让位，先下别的
      _deferCurrentToQueue();
      return;
    }
    if (error != null) {
      _updateCurStatus(_downloadManager?.status ?? DownloadStatus.pause);
      return;
    }

    final audioStatus = _audioDownloadManager?.status;
    if (audioStatus == DownloadStatus.failDownload) {
      // 视频已完成但音频失败：只补音频（带重试+断点续传），不重下视频。
      _updateCurStatus(DownloadStatus.audioDownloading);
      _onAudioFailed();
      return;
    }

    final status = switch (audioStatus) {
      DownloadStatus.downloading => DownloadStatus.audioDownloading,
      _ => _downloadManager?.status ?? DownloadStatus.pause,
    };
    _updateCurStatus(status);

    if (curDownload.value case final curEntryInfo?) {
      curEntryInfo.downloadedBytes = curEntryInfo.totalBytes;
      if (status == DownloadStatus.completed) {
        _completeDownload();
      } else {
        _updateBiliDownloadEntryJson(curEntryInfo);
      }
    }
  }

  void _onAudioDone([Object? error]) {
    if (error is StallDeferred) {
      _deferCurrentToQueue();
      return;
    }
    if (error != null) {
      // 音频失败：自动重试（重取 playurl + 断点续传），不推倒视频进度。
      _onAudioFailed();
      return;
    }
    if (_downloadManager?.status == DownloadStatus.completed) {
      _completeDownload();
    }
  }

  final Map<int, int> _deferCounts = {};
  bool _deferHandling = false;

  /// 同一下载项最多让位次数（防乒乓），超出后由 DownloadManager 明确报失败。
  static const int _maxDefersPerEntry = 3;

  /// 停摆/龟速时是否让位：
  /// * 队列里还有其它未完成项 → 先让别人下；
  /// * 只剩自己 → 也退回队尾：下一轮会重新取一次 playurl（拿到一批全新的
  ///   已签名候选地址）再从断点续传。否则会出现「最后一条线路几十K慢慢爬，
  ///   既不报错也不见进度」的永久卡死。
  bool _shouldDeferCurrent() {
    final entry = curDownload.value;
    if (entry == null) {
      return false;
    }
    final count = _deferCounts[entry.cid] ?? 0;
    if (count >= _maxDefersPerEntry) {
      return false;
    }
    _deferCounts[entry.cid] = count + 1;
    return true;
  }

  /// 停摆让位：当前条退回队尾（保留断点），先下队列中的其它项；
  /// 之后再轮到它时会自动重取直链并从断点续传。
  void _deferCurrentToQueue() {
    if (_deferHandling) {
      return;
    }
    final entry = curDownload.value;
    if (entry == null) {
      return;
    }
    _deferHandling = true;
    unawaited(
      _lock
          .synchronized(() async {
            await _cancelAndWait(_downloadManager, isDelete: false);
            await _cancelAndWait(_audioDownloadManager, isDelete: false);
            _downloadManager = null;
            _audioDownloadManager = null;
            entry.status = DownloadStatus.wait;
            waitDownloadQueue.removeWhere((e) => e.cid == entry.cid);
            waitDownloadQueue.add(entry);
            _curCid = null;
            curDownload.value = null;
            waitDownloadQueue.refresh();
            flagNotifier.refresh();
          })
          .whenComplete(() {
            _deferHandling = false;
            nextDownload();
          }),
    );
  }

  void _onAudioFailed() {
    final entry = curDownload.value;
    if (entry == null || _audioRetrying) {
      return;
    }
    if (_audioRetryLeft <= 0) {
      final status =
          _audioDownloadManager?.status ?? DownloadStatus.failDownloadAudio;
      _updateCurStatus(
        status == DownloadStatus.failDownload
            ? DownloadStatus.failDownloadAudio
            : status,
      );
      return;
    }
    _audioRetryLeft--;
    _audioRetrying = true;
    _updateCurStatus(DownloadStatus.audioDownloading);
    unawaited(_retryAudioDownload(entry));
  }

  /// 重取一份新的 playurl（直链带 deadline，失败重试时旧链可能已过期），
  /// 然后仅重建音频下载器——DownloadManager 会对已有音频断点做 Range 续传，
  /// 因此重试不会从头下载音频，更不会影响已完成的视频。
  Future<void> _retryAudioDownload(BiliDownloadEntryInfo entry) async {
    try {
      final result = await DownloadHttp.getVideoUrl(
        entry: entry,
        ep: entry.ep,
        source: entry.source,
        pageData: entry.pageData,
      );
      final mediaFileInfo = result.mediaFileInfo;
      if (mediaFileInfo is Type2 && mediaFileInfo.audio?.isNotEmpty == true) {
        if (curDownload.value?.cid != entry.cid) {
          _audioRetrying = false;
          return;
        }
        late final DownloadManager audioMgr;
        audioMgr = DownloadManager(
          urls: result.audioUrls ??
              <String>[mediaFileInfo.audio!.first.baseUrl],
          path: path.join(
            entry.entryDirPath,
            entry.typeTag,
            PathUtils.audioNameType2,
          ),
          onReceiveProgress: null,
          onDone: ([e]) {
            // 只认当前在用的音频下载器（与 _startDownload 一致）
            if (identical(_audioDownloadManager, audioMgr)) {
              _onAudioDone(e);
            }
          },
          shouldDefer: _shouldDeferCurrent,
        );
        _audioDownloadManager = audioMgr;
        _audioRetrying = false;
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('retry audio download failed: $e');
      }
    }
    _audioRetrying = false;
    _onAudioFailed(); // 剩余次数内继续重试
  }

  Future<void> _completeDownload() async {
    final entry = curDownload.value;
    if (entry == null) {
      return;
    }
    entry
      ..downloadedBytes = entry.totalBytes
      ..isCompleted = true;
    _deferCounts.remove(entry.cid);
    await _updateBiliDownloadEntryJson(entry);
    waitDownloadQueue.remove(entry);
    downloadList.insert(0, entry);
    completedEntryNotifier.notify(entry);
    flagNotifier.refresh();
    _curCid = null;
    curDownload.value = null;
    _downloadManager = null;
    _audioDownloadManager = null;
    nextDownload();
  }

  void nextDownload() {
    if (waitDownloadQueue.isNotEmpty) {
      startDownload(waitDownloadQueue.first);
    }
  }

  Future<void> deleteDownload({
    required BiliDownloadEntryInfo entry,
    bool removeList = false,
    bool removeQueue = false,
    bool refresh = true,
    bool downloadNext = true,
  }) async {
    if (removeList) {
      downloadList.remove(entry);
    }
    if (removeQueue) {
      waitDownloadQueue.remove(entry);
    }
    if (curDownload.value?.cid == entry.cid) {
      await cancelDownload(
        isDelete: true,
        downloadNext: downloadNext,
      );
    }
    final downloadDir = Directory(entry.pageDirPath);
    if (downloadDir.existsSync()) {
      if (!await downloadDir.lengthGte(2)) {
        await downloadDir.tryDel(recursive: true);
      } else {
        final entryDir = Directory(entry.entryDirPath);
        if (entryDir.existsSync()) {
          await entryDir.tryDel(recursive: true);
        }
      }
    }
    if (refresh) {
      flagNotifier.refresh();
    }
  }

  Future<void> deletePage({
    required String pageDirPath,
    bool refresh = true,
  }) async {
    await Directory(pageDirPath).tryDel(recursive: true);
    downloadList.removeWhere((e) => e.pageDirPath == pageDirPath);
    if (refresh) {
      flagNotifier.refresh();
    }
  }

  Future<void> cancelDownload({
    required bool isDelete,
    bool downloadNext = true,
  }) async {
    await _cancelAndWait(_downloadManager, isDelete: isDelete);
    await _cancelAndWait(_audioDownloadManager, isDelete: isDelete);
    _downloadManager = null;
    _audioDownloadManager = null;
    if (!isDelete) {
      final entry = curDownload.value;
      if (entry != null) {
        await _updateBiliDownloadEntryJson(entry);
      }
    }
    if (isDelete) {
      _curCid = null;
      curDownload.value = null;
    } else {
      _updateCurStatus(DownloadStatus.pause);
    }
    if (downloadNext) {
      nextDownload();
    }
  }

  static String get _exportBasePath =>
      path.join('/storage/emulated/0/Download', 'PiliBabel');

  static Future<String> exportEntry(
    BiliDownloadEntryInfo entry,
    ValueChanged<double>? onProgress,
  ) async {
    final srcDir = Directory(entry.entryDirPath);
    if (!srcDir.existsSync()) throw '缓存目录不存在';

    final baseDir = Directory(_exportBasePath);
    if (!baseDir.existsSync()) await baseDir.create(recursive: true);

    final nomedia = File(path.join(_exportBasePath, '.nomedia'));
    if (!nomedia.existsSync()) await nomedia.create();

    final dirName = _sanitizeDirName(entry.title, entry.avid);
    final subDirName = path.basename(entry.entryDirPath);
    final destDir = Directory(path.join(_exportBasePath, dirName, subDirName));
    final destPath = destDir.path;

    if (destDir.existsSync() && !await _dirHasDifference(srcDir, destDir)) {
      return destPath;
    }

    final totalSize = await _dirSize(srcDir);
    int copiedSize = 0;

    await _copyDir(srcDir, destDir, (fileCopied) {
      copiedSize += fileCopied;
      if (totalSize > 0) onProgress?.call(copiedSize / totalSize);
    });

    return destPath;
  }

  static Future<void> _copyDir(
    Directory src,
    Directory dest,
    void Function(int bytesCopied) onProgress,
  ) async {
    if (!dest.existsSync()) await dest.create(recursive: true);
    await for (final entity in src.list()) {
      if (entity is File) {
        final target = File(path.join(dest.path, path.basename(entity.path)));
        if (!target.existsSync() ||
            target.lengthSync() != entity.lengthSync()) {
          await entity.copy(target.path);
        }
        onProgress(entity.lengthSync());
      } else if (entity is Directory) {
        await _copyDir(
          entity,
          Directory(path.join(dest.path, path.basename(entity.path))),
          onProgress,
        );
      }
    }
  }

  static Future<int> _dirSize(Directory dir) async {
    int size = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) size += await entity.length();
    }
    return size;
  }

  static Future<bool> _dirHasDifference(
    Directory src,
    Directory dest,
  ) async {
    await for (final entity in src.list(recursive: true)) {
      if (entity is! File) continue;
      final relPath = path.relative(entity.path, from: src.path);
      final target = File(path.join(dest.path, relPath));
      if (!target.existsSync()) return true;
      final diff = (await entity.length()) - (await target.length());
      if (diff.abs() > 1024) return true;
      if (diff == 0) continue;
      if (target.lastModifiedSync().isBefore(entity.lastModifiedSync())) {
        return true;
      }
    }
    return false;
  }

  static String _sanitizeDirName(String title, int avid) {
    final clean = title
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
    return '${clean.isEmpty ? 'video' : clean}_$avid';
  }
}

typedef SetNotifier = Set<VoidCallback>;

extension SetNotifierExt on SetNotifier {
  void refresh() {
    for (final i in this) {
      i();
    }
  }
}

extension EntryNotifierExt on Set<ValueChanged<BiliDownloadEntryInfo>> {
  void notify(BiliDownloadEntryInfo entry) {
    for (final i in this) {
      i(entry);
    }
  }
}
