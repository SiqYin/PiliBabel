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
    this.qn = 0,
    this.audioQa = 0,
    this.extraPath,
  });

  /// 唯一键：`<avid>-<cid>-<v|a>`，同一稿件重复下载会覆盖旧档案。
  final String id;

  /// true = 下载音频，false = 下载视频。
  final bool isAudio;

  final String title;

  /// 落盘的绝对路径。视频高画质（1080P60 及以上）走 DASH 分离流时，
  /// 这里是视频轨的路径，音轨见 [extraPath]。
  final String path;

  /// 分离流下载时音频轨的落盘路径（与 [path] 一起构成完整内容）。
  final String? extraPath;

  final String? ownerName;
  final String? cover;

  int totalBytes;
  int receivedBytes;
  bool done;
  bool failed;

  /// 视频下载所用画质 code（1080P=80）。旧档案为 0，重新下载时按 1080P 处理。
  int qn;

  /// 音频下载所用音质 code（见 [AudioQuality]）。旧档案为 0。
  int audioQa;

  /// 是否为 DASH 分离流（视频轨 + 音频轨两个文件）。
  bool get splitStream => !isAudio && extraPath != null;

  /// 从档案 id（`<avid>-<cid>-<v|a>`）解析出 avid；解析失败返回 0。
  int get avid {
    final parts = id.split('-');
    return parts.length >= 2 ? (int.tryParse(parts[0]) ?? 0) : 0;
  }

  /// 从档案 id 解析出 cid；解析失败返回 0。
  int get cid {
    final parts = id.split('-');
    return parts.length >= 2 ? (int.tryParse(parts[1]) ?? 0) : 0;
  }

  /// 本地文件是否已被删除（用户自己删了、换了存储、卸载了外部存储……）。
  ///
  /// **不落盘**，每次实时判断：这样用户删掉文件后，列表下一次刷新就能显示
  /// 「本地文件已删除」，也才允许「清理档案」。
  bool get fileMissing {
    try {
      if (!File(path).existsSync()) {
        return true;
      }
      final extra = extraPath;
      return extra != null && !File(extra).existsSync();
    } catch (_) {
      return true;
    }
  }

  /// 是否应当显示「本地文件已删除」这类完整性告警。
  ///
  /// **下载进行中绝不能做这个检测**：文件要等下载写完才落盘，中途 `fileMissing`
  /// 必然为 true，界面就会一边显示进度、一边红字说「文件已删除」（实际文件的
  /// 下载还在进行）。
  /// 只有两种情况需要检测：下载**已完成**（万一之后被用户删了/存储丢了），
  /// 或者下载**已失败**（此时没有文件才说明确实不可用）。
  bool get shouldCheckIntegrity => done || failed;

  /// 需要显示「本地文件已删除」时的值；下载进行中恒为 false。
  bool get fileMissingAndSettled => shouldCheckIntegrity && fileMissing;

  /// 下载失败（fail）后若文件其实不在，同样属于不可用。
  bool get isUnusable => shouldCheckIntegrity && (failed || fileMissing);

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
    'qn': qn,
    'audio_qa': audioQa,
    'extra_path': extraPath,
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
        qn: json['qn'] as int? ?? 0,
        audioQa: json['audio_qa'] as int? ?? 0,
        extraPath: json['extra_path'] as String?,
      );
}
