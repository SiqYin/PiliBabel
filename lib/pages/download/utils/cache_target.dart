import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/connectivity_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:material_ui/material_ui.dart';

/// 下载到本地的目标类型。
enum LocalDownloadTarget {
  /// 下载视频：存成可直接播放的单文件。
  video,

  /// 下载音频：保持原始格式，不转码。
  audio,
}

/// 确保「下载到本地位置」已配置。
/// 没配置过就直接弹出系统文件管理器让用户选一个文件夹；返回目录是否可用。
Future<bool> ensureLocalDownloadPath() async {
  final dir = Pref.downloadLocalPath;
  if (dir != null && dir.isNotEmpty) {
    return true;
  }
  final path = await FilePicker.getDirectoryPath();
  if (path == null || path.isEmpty) {
    SmartDialog.showToast(uiTx('还没设置下载到本地的位置'));
    return false;
  }
  await Pref.setDownloadLocalPath(path);
  SmartDialog.showToast(uiTx('已设置下载到本地位置'));
  return true;
}

/// 点「下载到本地」后，选下载视频还是下载音频。
Future<LocalDownloadTarget?> showLocalDownloadTargetPicker(
  BuildContext context,
) {
  return showModalBottomSheet<LocalDownloadTarget>(
    context: context,
    useSafeArea: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Text(
                  uiTx('下载到本地'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.videocam_outlined, size: 20),
            title: Text(uiTx('下载视频'), style: const TextStyle(fontSize: 14)),
            subtitle: Text(
              uiTx('存成可直接播放的文件，放进你选的文件夹'),
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () => Navigator.of(context).pop(LocalDownloadTarget.video),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.music_note_outlined, size: 20),
            title: Text(uiTx('下载音频'), style: const TextStyle(fontSize: 14)),
            subtitle: Text(
              uiTx('保持原格式不转码，放进你选的文件夹'),
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () => Navigator.of(context).pop(LocalDownloadTarget.audio),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// 下载到本地时可选的视频画质，从高到低。
/// 服务端会按实际可用档位下发，选了拿不到的档位会自动降档。
const List<VideoQuality> localDownloadVideoQualities = [
  VideoQuality.super8k,
  VideoQuality.dolbyVision,
  VideoQuality.hdr,
  VideoQuality.super4K,
  VideoQuality.high108060,
  VideoQuality.high1080plus,
  VideoQuality.high1080,
  VideoQuality.high72060,
  VideoQuality.high720,
  VideoQuality.clear480,
  VideoQuality.fluent360,
  VideoQuality.speed240,
];

/// 选下载视频的画质；返回 null 表示用户取消。
///
/// 档位太多容易挑花眼：把「按用户在 音视频设置 里的默认画质 + 当前是 WiFi
/// 还是蜂窝」推断出的档位**标蓝提示**（不代选，仍由用户自己点）。用户设置里
/// 的档位若不在本列表（或高于全部可选档），向下取最接近的一档。
Future<VideoQuality?> showLocalVideoQualityPicker(BuildContext context) async {
  final isWiFi = await ConnectivityUtils.isWiFi;
  final target = isWiFi ? Pref.defaultVideoQa : Pref.defaultVideoQaCellular;
  // 列表本身从高到低：取不高于设置档位的最高一档；全都高于时取最低档。
  final fit = localDownloadVideoQualities
      .where((e) => e.code <= target)
      .toList();
  final recommended = fit.isNotEmpty
      ? fit.first
      : localDownloadVideoQualities.last;
  if (!context.mounted) {
    return null;
  }
  return showModalBottomSheet<VideoQuality>(
    context: context,
    useSafeArea: true,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Text(
                  uiTx('选择画质'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              uiTx('蓝色项是按你的播放设置与当前网络推荐的画质，仅供参考'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          for (final quality in localDownloadVideoQualities)
            Builder(
              builder: (context) {
                final colorScheme = ColorScheme.of(context);
                final isRecommended = quality == recommended;
                return ListTile(
                  dense: true,
                  title: Text(
                    quality.desc,
                    style: TextStyle(
                      fontSize: 14,
                      color: isRecommended ? colorScheme.primary : null,
                      fontWeight: isRecommended ? FontWeight.w600 : null,
                    ),
                  ),
                  trailing: isRecommended
                      ? Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: colorScheme.primary,
                        )
                      : null,
                  // 1080P 以上的档位在服务端只有 DASH 分离流（就算登录了大会员，
                  // 单文件 MP4 也拿不到这些画质），下载会落「视频轨 + 音频轨」两个文件。
                  subtitle: quality.code > 80
                      ? Text(
                          uiTx('分离流下载：视频轨与音频轨两个文件'),
                          style: const TextStyle(fontSize: 12),
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(quality),
                );
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
