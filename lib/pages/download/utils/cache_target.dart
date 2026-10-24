import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
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
Future<VideoQuality?> showLocalVideoQualityPicker(BuildContext context) {
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
          for (final quality in localDownloadVideoQualities)
            ListTile(
              dense: true,
              title: Text(quality.desc, style: const TextStyle(fontSize: 14)),
              onTap: () => Navigator.of(context).pop(quality),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
