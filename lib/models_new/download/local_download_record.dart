import 'dart:io';

/// 「下载到本地」的一条档案。
///
/// 只记录 [LocalDownloadService] 写进用户自己文件夹的文件，与软件内缓存
/// （DownloadService / AudioCacheService）无关：那是另一套索引，页面也不同。
/// 存在的意义是让用户能看见「下载过哪些、下到多少了、文件还在不在」，
/// 而不是把这些都放在幕后。
class LocalDownloadRecord {
  LocalDownloadRecord({
    required this.id,
    required this.isAudio,
    required this.title,
    required this.path,
    this.ownerName,
    this.cover,
    this.totalBytes = 0,
    this.receivedBytes = 0,
    this.done = false,
    this.failed = false,
  });

  /// 唯一键：`<avid>-<cid>-<v|a>`，同一稿件重复下载会覆盖旧档案。
  final String id;

  /// true = 下载音频，false = 下载视频。
  final bool isAudio;

  final String title;

  /// 落盘的绝对路径。
  final String path;

  final String? ownerName;
  final String? cover;

  int totalBytes;
  int receivedBytes;
  bool done;
  bool failed;

  /// 本地文件是否已被删除（用户自己删了、换了存储、卸载了外部存储……）。
  ///
  /// **不落盘**，每次实时判断：这样用户删掉文件后，列表下一次刷新就能显示
  /// 「本地文件已删除」，也才允许「清理档案」。
  bool get fileMissing {
    try {
      return !File(path).existsSync();
    } catch (_) {
      return true;
    }
  }

  /// 下载进度 0~1；总大小未知时按「完成与否」给值，界面显示已下载字节数。
  double get progress {
    if (totalBytes <= 0) {
      return done ? 1 : 0;
    }
    final v = receivedBytes / totalBytes;
    if (v < 0) {
      return 0;
    }
    return v > 1 ? 1 : v;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'is_audio': isAudio,
    'title': title,
    'path': path,
    'owner_name': ownerName,
    'cover': cover,
    'total_bytes': totalBytes,
    'received_bytes': receivedBytes,
    'done': done,
    'failed': failed,
  };

  static LocalDownloadRecord fromJson(Map<String, dynamic> json) =>
      LocalDownloadRecord(
        id: json['id'] as String? ?? '',
        isAudio: json['is_audio'] as bool? ?? false,
        title: json['title'] as String? ?? '',
        path: json['path'] as String? ?? '',
        ownerName: json['owner_name'] as String?,
        cover: json['cover'] as String?,
        totalBytes: json['total_bytes'] as int? ?? 0,
        receivedBytes: json['received_bytes'] as int? ?? 0,
        done: json['done'] as bool? ?? false,
        failed: json['failed'] as bool? ?? false,
      );
}
