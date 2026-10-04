import 'dart:math' show max, min;

import 'package:PiliPlus/grpc/bilibili/app/playurl/v1.pb.dart';
import 'package:PiliPlus/models/common/video/audio_quality.dart';
import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/models_new/sponsor_block/segment_item.dart';
import 'package:PiliPlus/utils/extension/iterable_ext.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// bilibili `codecid` → `codecs` 前缀。上层（`VideoUtils.selectCodec` /
/// `findVideoByQa`）都按前缀匹配首选解码格式，所以这里只给前缀即可。
/// 杜比视界是独立解码格式（`dvh1`），B 站不用 codecid 区分，只能看清晰度档位。
String _codecsFromCodecid(int codecid, int quality) {
  if (quality == 126) {
    return 'dvh1';
  }
  return switch (codecid) {
    12 => 'hev1',
    13 => 'av01',
    _ => 'avc1',
  };
}

final _videoQualityMap = {for (final i in VideoQuality.values) i.code: i};
final _audioQualityMap = {for (final i in AudioQuality.values) i.code: i};

class PlayUrlModel {
  PlayUrlModel({
    this.from,
    this.result,
    this.message,
    this.quality,
    this.format,
    this.timeLength,
    this.acceptFormat,
    this.acceptDesc,
    this.acceptQuality,
    this.videoCodecid,
    this.seekParam,
    this.seekType,
    this.dash,
    this.supportFormats,
    this.volume,
    this._lastPlayTime = 0,
    this.lastPlayCid,
    this.isAppSource = false,
  });

  String? from;
  String? result;
  String? message;
  int? quality;
  String? format;
  int? timeLength;
  String? acceptFormat;
  List<dynamic>? acceptDesc;
  List<int>? acceptQuality;
  int? videoCodecid;
  String? seekParam;
  String? seekType;
  Dash? dash;
  List<Durl>? durl;
  List<FormatItem>? supportFormats;
  Volume? volume;

  late int _lastPlayTime;
  int get lastPlayTime => _lastPlayTime;
  set lastPlayTime(int? value) {
    if (value != null && value > 0) {
      _lastPlayTime = value;
    } else {
      _lastPlayTime = 0;
    }
  }

  int? lastPlayCid;
  String? curLanguage;
  Language? language;
  List<SegmentItemModel>? clipInfoList;

  /// 直链是否来自官方 APP 的取流接口（gRPC `PlayView`）。
  ///
  /// 这个标记决定**两件事**，缺一不可（实测：只换取流接口、不换请求指纹会全线 403）：
  /// 1. 媒体请求指纹：APP 令牌必须不带 `Referer`；
  /// 2. 候选地址顺序：官方 APP 直接播 B 站下发的第一条，不做任何挑选/改写。
  bool isAppSource;

  int findAvailableVideoQuality(int preferredQuality) {
    final curHighestVideoQa = dash!.video!.first.quality.code;
    if (acceptQuality case final qualitys?
        when preferredQuality <= curHighestVideoQa) {
      return qualitys.findClosestTarget((e) => e <= preferredQuality, max);
    } else {
      return curHighestVideoQa;
    }
  }

  @pragma('vm:notify-debugger-on-exception')
  int get missingVideoQualityBelowHighest {
    int best = -1;
    try {
      final video = dash!.video!;
      final available = video.availableVideoQualities;
      final highest = video.first.id;

      for (final item in supportFormats!) {
        final quality = item.quality;
        if (quality != null &&
            best < quality &&
            quality < highest &&
            !available.contains(quality)) {
          best = quality;
        }
      }
    } catch (_) {}
    return best;
  }

  /// 官方 APP（gRPC `PlayView`）取流结果 → 播放模型。
  ///
  /// 字段是一一对应的：`stream_list[].stream_info` ↔ Web 的 `support_formats`，
  /// `stream_list[].dash_video` ↔ `dash.video`，`video_info.dash_audio` ↔
  /// `dash.audio`。所以转换后上层的画质/音质选择、菜单渲染逻辑完全不用改。
  ///
  /// 无权限的档位只会出现在 `stream_info` 里而没有 `dash_video`（与 Web 端
  /// `accept_quality` 列出全部、`dash.video` 只给有权限的一致）。
  factory PlayUrlModel.fromPlayViewReply(PlayViewReply reply) {
    final info = reply.videoInfo;

    final videos = <VideoItem>[];
    final formats = <FormatItem>[];
    final qualities = <int>[];
    // 同一清晰度会有多条 stream（AVC / HEVC / AV1 各一条），必须把 codecs 合并，
    // 否则画质菜单里的解码格式提示只会显示"先到的那条"。
    final codecsOfQuality = <int, Set<String>>{};
    final infoOfQuality = <int, StreamInfo>{};

    for (final stream in info.streamList) {
      if (!stream.hasStreamInfo()) {
        continue;
      }
      final si = stream.streamInfo;
      final quality = si.quality;
      // 枚举里没有的档位无法展示、也无法被画质选择命中（`VideoQuality.fromCode`
      // 对未知档位会抛异常），所以只保留认得的档位
      final videoQuality = _videoQualityMap[quality];
      if (videoQuality == null) {
        continue;
      }
      if (!qualities.contains(quality)) {
        qualities.add(quality);
      }
      infoOfQuality[quality] = si;

      if (!stream.hasDashVideo()) {
        continue;
      }
      final dv = stream.dashVideo;
      if (dv.baseUrl.isEmpty) {
        continue;
      }
      final codec = _codecsFromCodecid(dv.codecid, quality);
      (codecsOfQuality[quality] ??= <String>{}).add(codec);
      videos.add(
        VideoItem(
          id: quality,
          baseUrl: dv.baseUrl,
          backupUrl: dv.backupUrl.isEmpty ? null : dv.backupUrl.toList(),
          bandWidth: dv.bandwidth,
          mimeType: 'video/mp4',
          codecs: codec,
          codecid: dv.codecid,
          width: dv.width,
          height: dv.height,
          frameRate: dv.frameRate.isEmpty ? null : dv.frameRate,
          quality: videoQuality,
        ),
      );
    }

    for (final quality in qualities) {
      final si = infoOfQuality[quality]!;
      final fallbackDesc = _videoQualityMap[quality]?.desc ?? '$quality';
      formats.add(
        FormatItem(
          quality: quality,
          format: si.format,
          newDesc: si.newDescription.isNotEmpty
              ? si.newDescription
              : (si.description.isNotEmpty ? si.description : fallbackDesc),
          displayDesc: si.displayDesc,
          // 无权限档位一条 dash_video 都没有，也要给个占位：
          // 上层 `supportFormats[x].codecs!` 是直接解引用的
          codecs: (codecsOfQuality[quality] ?? const {'avc1'}).toList(),
        ),
      );
    }

    // dash.video.first 必须是"当前可用的最高档"（上层靠它夹持画质上限）
    videos.sort((a, b) => b.id.compareTo(a.id));
    qualities.sort((a, b) => b - a);

    final audios = <AudioItem>[];
    void addAudio(DashItem item) {
      if (item.baseUrl.isEmpty || _audioQualityMap[item.id] == null) {
        return;
      }
      audios.add(
        AudioItem(
          id: item.id,
          baseUrl: item.baseUrl,
          backupUrl: item.backupUrl.isEmpty ? null : item.backupUrl.toList(),
          bandWidth: item.bandwidth,
          mimeType: 'audio/mp4',
          codecid: item.codecid,
        ),
      );
    }

    // 与 Dash.fromJson 的拼接顺序保持一致：无损 → 杜比 → 常规
    if (info.hasLossLessItem() && info.lossLessItem.isLosslessAudio) {
      addAudio(info.lossLessItem.audio);
    }
    if (info.hasDolby()) {
      for (final item in info.dolby.audio) {
        addAudio(item);
      }
    }
    for (final item in info.dashAudio) {
      addAudio(item);
    }

    Volume? volume;
    if (info.hasVolume()) {
      final v = info.volume;
      volume = Volume(
        measuredI: v.measuredI,
        measuredLra: v.measuredLra,
        measuredTp: v.measuredTp,
        measuredThreshold: v.measuredThreshold,
        targetOffset: v.targetOffset,
        targetI: v.targetI,
        targetTp: v.targetTp,
      );
    }

    final hasVideo = videos.isNotEmpty;
    return PlayUrlModel(
      from: 'app',
      quality: info.quality,
      format: info.format,
      timeLength: info.hasTimelength() ? info.timelength.toInt() : null,
      videoCodecid: info.videoCodecid,
      acceptQuality: qualities,
      supportFormats: formats,
      volume: volume,
      isAppSource: true,
      dash: hasVideo
          ? Dash(
              duration: info.hasTimelength() ? info.timelength.toInt() : null,
              video: videos,
              audio: audios.isEmpty ? null : audios,
            )
          : null,
    );
  }

  PlayUrlModel.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    result = json['result'];
    message = json['message'];
    quality = json['quality'];
    format = json['format'];
    timeLength = json['timelength'];
    acceptFormat = json['accept_format'];
    acceptDesc = json['accept_description'];
    acceptQuality = (json['accept_quality'] as List?)
        ?.map<int>((e) => e as int)
        .toList();
    videoCodecid = json['video_codecid'];
    seekParam = json['seek_param'];
    seekType = json['seek_type'];
    dash = json['dash'] != null ? Dash.fromJson(json['dash']) : null;
    durl = (json['durl'] as List?)?.map<Durl>((e) => Durl.fromJson(e)).toList();
    supportFormats = (json['support_formats'] as List?)
        ?.map<FormatItem>((e) => FormatItem.fromJson(e))
        .toList();
    volume = json['volume'] == null ? null : Volume.fromJson(json['volume']);
    lastPlayTime = json['last_play_time'];
    lastPlayCid = json['last_play_cid'];
    curLanguage = json['cur_language'];
    language = json['language'] == null
        ? null
        : Language.fromJson(json['language']);
    // debug
    // final clipInfoList = [
    //   {
    //     "start": 0,
    //     "end": 150,
    //     "clipType": "CLIP_TYPE_OP",
    //   },
    //   {
    //     "start": timeLength! ~/ 1000 - 150,
    //     "end": timeLength! ~/ 1000,
    //     "clipType": "CLIP_TYPE_ED",
    //   },
    // ];
    try {
      final List? clipInfoList = json['clip_info_list'];
      if (clipInfoList != null && clipInfoList.isNotEmpty) {
        this.clipInfoList = clipInfoList
            .map((e) => SegmentItemModel.fromPgcJson(e, timeLength))
            .toList();
      }
    } catch (_) {
      if (kDebugMode) rethrow;
    }
  }
}

class Language {
  Language({
    this.support,
    this.items,
  });

  bool? support;
  List<LanguageItem>? items;

  Language.fromJson(Map<String, dynamic> json) {
    support = json['support'];
    items =
        (json['items'] as List?)?.map((e) => LanguageItem.fromJson(e)).toList()
          ?..sort((a, b) {
            final aHasZh = a.lang?.contains('zh') ?? false;
            final bHasZh = b.lang?.contains('zh') ?? false;
            if (aHasZh != bHasZh) return aHasZh ? -1 : 1;
            if (a.isAi != b.isAi) return a.isAi ? 1 : -1;
            return 0;
          });
  }
}

class LanguageItem {
  LanguageItem({
    this.lang,
    this.title,
    this.subtitleLang,
  });

  String? lang;
  String? title;
  String? subtitleLang;
  bool isAi = false;

  LanguageItem.fromJson(Map<String, dynamic> json) {
    lang = json['lang'];
    isAi = json['production_type'] == 2;
    title = '${json['title']}${isAi ? '（AI）' : ''}';
    subtitleLang = json['subtitle_lang'];
  }
}

class Dash {
  Dash({
    this.duration,
    this.minBufferTime,
    this.video,
    this.audio,
  });

  int? duration;
  double? minBufferTime;
  List<VideoItem>? video;
  List<AudioItem>? audio;

  Dash.fromJson(Map<String, dynamic> json) {
    duration = json['duration'];
    minBufferTime = json['minBufferTime'];
    video = (json['video'] as List?)
        ?.map<VideoItem>((e) => VideoItem.fromJson(e))
        .toList();
    final audio = [
      if (json['flac']?['audio'] case Map<String, dynamic> flac)
        AudioItem.fromJson(flac),
      if (json['dolby']?['audio'] case List list)
        ...list.map((e) => AudioItem.fromJson(e)),
      if (json['audio'] case List list)
        ...list.map((e) => AudioItem.fromJson(e)),
    ];
    this.audio = audio.isEmpty ? null : audio;
  }
}

class Durl {
  int? order;
  int? length;
  int? size;
  String? ahead;
  String? vhead;
  String? url;
  List<String>? backupUrl;

  Durl({
    this.order,
    this.length,
    this.size,
    this.ahead,
    this.vhead,
    this.url,
    this.backupUrl,
  });

  factory Durl.fromJson(Map<String, dynamic> json) {
    return Durl(
      order: json['order'],
      length: json['length'],
      size: json['size'],
      ahead: json['ahead'],
      vhead: json['vhead'],
      url: json['url'],
      backupUrl: (json['backup_url'] as List?)?.fromCast<String>(),
    );
  }

  Iterable<String> get playUrls sync* {
    if (url?.isNotEmpty == true) yield url!;
    if (backupUrl?.isNotEmpty == true) yield* backupUrl!;
  }
}

abstract class BaseItem {
  late int id;
  String? baseUrl;
  List<String>? backupUrl;
  int? bandWidth;
  String? mimeType;
  String? codecs;
  int? width;
  int? height;
  String? frameRate;
  String? sar;
  int? startWithSap;
  Map? segmentBase;
  int? codecid;

  BaseItem({
    required this.id,
    this.baseUrl,
    this.backupUrl,
    this.bandWidth,
    this.mimeType,
    this.codecs,
    this.width,
    this.height,
    this.frameRate,
    this.sar,
    this.startWithSap,
    this.segmentBase,
    this.codecid,
  });

  BaseItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    baseUrl = json['baseUrl'] ?? json['base_url'];
    backupUrl = ((json['backupUrl'] ?? json['backup_url']) as List?)
        ?.fromCast<String>();
    bandWidth = json['bandWidth'] ?? json['bandwidth'];
    mimeType = json['mime_type'];
    codecs = json['codecs'];
    width = json['width'];
    height = json['height'];
    frameRate = json['frameRate'] ?? json['frame_rate'];
    sar = json['sar'];
    startWithSap = json['startWithSap'] ?? json['start_with_sap'];
    segmentBase = json['segmentBase'] ?? json['segment_base'];
    codecid = json['codecid'];
  }

  Iterable<String> get playUrls sync* {
    if (baseUrl?.isNotEmpty == true) yield baseUrl!;
    if (backupUrl?.isNotEmpty == true) yield* backupUrl!;
  }
}

class VideoItem extends BaseItem {
  late VideoQuality quality;

  VideoItem({
    required super.id,
    super.baseUrl,
    super.backupUrl,
    super.bandWidth,
    super.mimeType,
    super.codecs,
    super.width,
    super.height,
    super.frameRate,
    super.sar,
    super.startWithSap,
    super.segmentBase,
    super.codecid,
    required this.quality,
  });

  VideoItem.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    quality = VideoQuality.fromCode(json['id']);
  }
}

class AudioItem extends BaseItem {
  late String quality;

  AudioItem({
    required super.id,
    super.baseUrl,
    super.backupUrl,
    super.bandWidth,
    super.mimeType,
    super.codecs,
    super.codecid,
  }) {
    quality = _audioQualityMap[id]?.desc ?? '$id';
  }

  AudioItem.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    quality = AudioQuality.fromCode(json['id']).desc;
  }
}

extension BaseItemExt<T extends BaseItem> on List<T> {
  void merge(List<T>? other) {
    if (other == null) return;
    final keys = {for (final item in this) (item.id, item.codecid)};
    for (final item in other) {
      if (keys.add((item.id, item.codecid))) {
        add(item);
      }
    }
    sort((a, b) => b.id.compareTo(a.id));
  }

  Set<int> get availableVideoQualities => map((i) => i.id).toSet();
}

class FormatItem {
  FormatItem({
    this.quality,
    this.format,
    this.newDesc,
    this.displayDesc,
    this.codecs,
  });

  int? quality;
  String? format;
  String? newDesc;
  String? displayDesc;
  List<String>? codecs;

  FormatItem.fromJson(Map<String, dynamic> json) {
    quality = json['quality'];
    format = json['format'];
    newDesc = json['new_description'];
    displayDesc = json['display_desc'];
    codecs = (json['codecs'] as List?)?.fromCast<String>();
  }
}

class Volume {
  Volume({
    required this.measuredI,
    required this.measuredLra,
    required this.measuredTp,
    required this.measuredThreshold,
    required this.targetOffset,
    required this.targetI,
    required this.targetTp,
    // required this.multiSceneArgs,
  });

  final num measuredI;
  final num measuredLra;
  final num measuredTp;
  final num measuredThreshold;
  final num targetOffset;
  final num targetI;
  final num targetTp;

  // final MultiSceneArgs? multiSceneArgs;

  // FFmpeg loudnorm 滤镜的标准有效范围（https://ffmpeg.org/ffmpeg-filters.html#loudnorm）
  static const double minTpValue = -9.0;
  static const double maxTpValue = 0.0;

  factory Volume.fromJson(Map<String, dynamic> json) {
    return Volume(
      measuredI: json["measured_i"] ?? 0,
      measuredLra: json["measured_lra"] ?? 0,
      measuredTp: json["measured_tp"] ?? 0,
      measuredThreshold: json["measured_threshold"] ?? 0,
      targetOffset: json["target_offset"] ?? 0,
      targetI: json["target_i"] ?? 0,
      targetTp: json["target_tp"] ?? 0,
      // multiSceneArgs: json["multi_scene_args"] == null ? null : MultiSceneArgs.fromJson(json["multi_scene_args"]),
    );
  }

  String format(Map<String, num> config) {
    final lra = max(config['lra'] ?? 11, measuredLra);
    num i = config['i'] ?? targetI;
    final tp = min(
      config['tp'] ?? targetTp,
      measuredTp,
    ).clamp(minTpValue, maxTpValue);
    final offset = config['offset'] ?? targetOffset;
    num measuredI = this.measuredI;
    if (measuredI > 0) {
      i -= measuredI;
      measuredI = 0;
    }
    num measuredThreshold = this.measuredThreshold;
    if (measuredThreshold > 0) {
      measuredThreshold = 0;
    }

    return 'LRA=$lra:I=$i:TP=$tp:offset=$offset:linear=true:measured_I=$measuredI:measured_LRA=$measuredLra:measured_TP=$measuredTp:measured_thresh=$measuredThreshold';
  }

  bool get isNotEmpty =>
      measuredI != 0 ||
      measuredLra != 0 ||
      measuredTp != 0 ||
      measuredThreshold != 0;
}
