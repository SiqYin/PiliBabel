import 'package:PiliPlus/models/common/video/audio_quality.dart';

/// 一条「缓存音频」记录。
///
/// 音频缓存不套用 B 站官方下载的目录结构，而是每个条目一个目录，
/// 目录里直接放原格式的音频文件（m4a / mp3 / flac / wav ...），
/// 文件名保持人类可读，方便用户拿到别的播放器里用。
class AudioCacheEntry {
  final int avid;
  final String bvid;
  final int cid;
  final String title;
  final String cover;
  final String? ownerName;
  final int? ownerId;
  final int durationMs;

  /// 音质档位码（[AudioQuality.code]）
  final int qualityCode;

  /// 音质描述，展示用
  final String qualityDesc;

  /// 音频文件绝对路径
  final String filePath;

  /// 文件扩展名（m4a / mp3 / flac / wav ...）
  final String ext;

  int fileSize;
  final int timeCreateStamp;

  AudioCacheEntry({
    required this.avid,
    required this.bvid,
    required this.cid,
    required this.title,
    required this.cover,
    this.ownerName,
    this.ownerId,
    this.durationMs = 0,
    required this.qualityCode,
    required this.qualityDesc,
    required this.filePath,
    required this.ext,
    this.fileSize = 0,
    required this.timeCreateStamp,
  });

  String get id => '${bvid}_$cid';

  /// 找不到对应档位时退到 192K，只用于播放页展示，不参与下载决策。
  AudioQuality get quality => AudioQuality.values.firstWhere(
    (e) => e.code == qualityCode,
    orElse: () => AudioQuality.k192,
  );

  factory AudioCacheEntry.fromJson(Map<String, dynamic> json) =>
      AudioCacheEntry(
        avid: json['avid'] as int,
        bvid: json['bvid'] as String,
        cid: json['cid'] as int,
        title: json['title'] as String,
        cover: json['cover'] as String? ?? '',
        ownerName: json['owner_name'] as String?,
        ownerId: json['owner_id'] as int?,
        durationMs: json['duration_ms'] as int? ?? 0,
        qualityCode: json['quality_code'] as int,
        qualityDesc: json['quality_desc'] as String? ?? '',
        filePath: json['file_path'] as String,
        ext: json['ext'] as String? ?? 'm4a',
        fileSize: json['file_size'] as int? ?? 0,
        timeCreateStamp: json['time_create_stamp'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'avid': avid,
    'bvid': bvid,
    'cid': cid,
    'title': title,
    'cover': cover,
    'owner_name': ownerName,
    'owner_id': ownerId,
    'duration_ms': durationMs,
    'quality_code': qualityCode,
    'quality_desc': qualityDesc,
    'file_path': filePath,
    'ext': ext,
    'file_size': fileSize,
    'time_create_stamp': timeCreateStamp,
  };
}
