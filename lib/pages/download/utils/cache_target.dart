import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 缓存方式。
enum CacheTarget {
  /// 软件内缓存：进 app 自己的缓存列表，可在缓存界面里播放和管理。
  inApp,

  /// 下载到本地：存成能直接播放的文件，放进用户选的文件夹。
  local,
}

/// 弹「软件内缓存 / 下载到本地」二选一。
Future<CacheTarget?> showCacheTargetPicker(BuildContext context) {
  return showModalBottomSheet<CacheTarget>(
    context: context,
    useSafeArea: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.download_done_outlined, size: 22),
            title: Text(uiTx('软件内缓存')),
            subtitle: Text(uiTx('存进 app 的缓存列表，可在缓存界面里播放和管理')),
            onTap: () => Navigator.of(context).pop(CacheTarget.inApp),
          ),
          ListTile(
            leading: const Icon(Icons.save_alt, size: 22),
            title: Text(uiTx('下载到本地')),
            subtitle: Text(uiTx('存成能直接播放的文件，放进你选的文件夹')),
            onTap: () => Navigator.of(context).pop(CacheTarget.local),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// 检查「下载到本地位置」是否配置过；没配置就提示并跳到设置页。
Future<bool> ensureLocalDownloadPath() async {
  final dir = Pref.downloadLocalPath;
  if (dir != null && dir.isNotEmpty) {
    return true;
  }
  SmartDialog.showToast(uiTx('先去设置里选一个「下载到本地位置」'));
  await Future.delayed(const Duration(milliseconds: 500));
  Get.toNamed('/setting', preventDuplicates: false);
  return false;
}
