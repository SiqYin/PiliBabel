import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'dart:async' show FutureOr;
import 'dart:io' show File, Platform;
import 'dart:math' as math;
import 'dart:typed_data' show Uint8List;

import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/utils/cache_manager.dart';
import 'package:PiliPlus/utils/device_utils.dart';
import 'package:PiliPlus/utils/extension/file_ext.dart';
import 'package:PiliPlus/utils/extension/string_ext.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:PiliPlus/utils/permission_handler.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/share_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/utils.dart';
// 本文件有自己的 CacheManager（PiliPlus/utils/cache_manager.dart），
// 与 cached_network_image_ce 导出的同名类冲突，hide 掉后者。
import 'package:cached_network_image_ce/cached_network_image.dart'
    hide CacheManager;
import 'package:clipboard/clipboard.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:live_photo_maker/live_photo_maker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';

abstract final class ImageUtils {
  static bool silentDownImg = Pref.silentDownImg;
  static final _albumPath = Platform.isAndroid
      ? 'Pictures/${Constants.appName}'
      : Constants.appName;

  // 图片分享
  static Future<void> onShareImg(String url) async {
    try {
      SmartDialog.showLoading();
      final res = await CacheManager.manager.getSingleFile(
        url.http2https,
      );
      SmartDialog.dismiss();
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(res.path)],
          sharePositionOrigin: await ShareUtils.sharePositionOrigin,
        ),
      );
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }

  // 复制图片到剪贴板
  static Future<void> copyImg(String url) async {
    try {
      SmartDialog.showLoading(msg: uiTx('正在复制'));
      final file = (await CacheManager.manager.getFileFromCache(
        url.http2https,
      ))?.file;
      File? tempFile;
      final filePath = file?.path ??
          () {
            final name = Utils.getFileName(url);
            final path = '$tmpDirPath/$name';
            tempFile = File(path);
            return path;
          }();
      if (file == null) {
        final res = await Request().downloadFile(url.http2https, filePath);
        if (res.statusCode != 200) throw '${res.statusCode}';
      }
      final bytes = await (file ?? tempFile!).readAsBytes();
      await FlutterClipboard.copyImage(bytes);
      SmartDialog.dismiss(status: SmartStatus.loading);
      SmartDialog.showToast(uiTx('已复制'));
      tempFile?.tryDel();
    } catch (e) {
      SmartDialog.dismiss(status: SmartStatus.loading);
      SmartDialog.showToast(uiTx('复制失败: $e'));
    }
  }

  // 获取存储权限
  static Future<bool> requestPer() async {
    final status = Platform.isAndroid
        ? await Permission.storage.request()
        : await Permission.photos.request();
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      SmartDialog.show(
        builder: (context) => AlertDialog(
          title: Text(uiTx('提示')),
          content: Text(uiTx('存储权限未授权')),
          actions: [
            TextButton(
              onPressed: () {
                SmartDialog.dismiss();
                openAppSettings();
              },
              child: Text(uiTx('去授权')),
            ),
          ],
        ),
      );
      return false;
    } else {
      return true;
    }
  }

  static FutureOr<bool> checkPermissionDependOnSdkInt() {
    if (Platform.isAndroid) {
      if (DeviceUtils.sdkInt < 29) {
        return requestPer();
      } else {
        return true;
      }
    }
    return requestPer();
  }

  static Future<bool> downloadLivePhoto({
    required String url,
    required String liveUrl,
    required int width,
    required int height,
  }) async {
    try {
      if (PlatformUtils.isMobile && !await checkPermissionDependOnSdkInt()) {
        return false;
      }
      if (!silentDownImg) SmartDialog.showLoading(msg: uiTx('正在下载'));

      String videoName = "video_${Utils.getFileName(liveUrl)}";
      String videoPath = '$tmpDirPath/$videoName';

      final res = await Request().downloadFile(liveUrl.http2https, videoPath);
      if (res.statusCode != 200) throw '${res.statusCode}';

      if (Platform.isIOS) {
        final imageFile = await CacheManager.manager.getSingleFile(
          url.http2https,
        );
        if (!silentDownImg) SmartDialog.showLoading(msg: uiTx('正在保存'));
        bool success = await LivePhotoMaker.create(
          coverImage: imageFile.path,
          imagePath: null,
          voicePath: videoPath,
          width: width,
          height: height,
        ).whenComplete(File(videoPath).tryDel);
        if (success) {
          SmartDialog.showToast(uiTx(' 已保存 '));
        } else {
          SmartDialog.showToast(uiTx('保存失败'));
          return false;
        }
      } else {
        if (!silentDownImg) SmartDialog.showLoading(msg: uiTx('正在保存'));
        await saveFileImg(
          filePath: videoPath,
          fileName: videoName,
          type: FileType.video,
          needToast: true,
        );
      }
      return true;
    } catch (err) {
      SmartDialog.showToast(err.toString());
      return false;
    } finally {
      if (!silentDownImg) SmartDialog.dismiss(status: SmartStatus.loading);
    }
  }

  static Future<bool> downloadImg(List<String> imgList) async {
    if (PlatformUtils.isMobile && !await checkPermissionDependOnSdkInt()) {
      return false;
    }
    CancelToken? cancelToken;
    if (!silentDownImg) {
      cancelToken = CancelToken();
      SmartDialog.showLoading(
        msg: uiTx('正在下载原图'),
        clickMaskDismiss: true,
        onDismiss: cancelToken.cancel,
      );
    }
    try {
      final futures = imgList.map((url) async {
        final name = Utils.getFileName(url);

        final file = await CacheManager.manager.getSingleFile(
          url.http2https,
        );
        return (filePath: file.path, name: name, statusCode: 200);
      });
      final result = await Future.wait(futures, eagerError: true);
      bool success = true;
      if (PlatformUtils.isMobile) {
        final saveList = <SaveFileData>[];
        for (final i in result) {
          if (i.statusCode == 200) {
            saveList.add(
              SaveFileData(
                filePath: i.filePath,
                fileName: i.name,
                albumPath: _albumPath,
              ),
            );
          } else {
            success = false;
          }
        }
        await SaverGallery.saveFiles(saveList, skipIfExists: false);
      } else {
        for (final res in result) {
          if (res.statusCode == 200) {
            await saveFileImg(filePath: res.filePath, fileName: res.name);
          } else {
            success = false;
          }
        }
      }
      if (cancelToken?.isCancelled == true) {
        SmartDialog.showToast(uiTx('已取消下载'));
        return false;
      } else {
        SmartDialog.showToast(success ? uiTx(' 已保存 ') : uiTx('保存失败'));
      }
      return success;
    } catch (e) {
      if (cancelToken?.isCancelled == true) {
        SmartDialog.showToast(uiTx('已取消下载'));
      } else {
        SmartDialog.showToast(e.toString());
      }
      return false;
    } finally {
      if (!silentDownImg) SmartDialog.dismiss(status: SmartStatus.loading);
    }
  }

  static final _suffixRegex = RegExp(
    r'\.(jpg|jpeg|png|webp|gif|avif)$',
    caseSensitive: false,
  );
  static String safeThumbnailUrl(String? src) {
    if (src != null && _suffixRegex.hasMatch(src)) {
      return thumbnailUrl(src);
    }
    return src.http2https;
  }

  static final _thumbRegex = RegExp(
    r'(@(\d+[a-z]_?)*)(\..*)?$',
    caseSensitive: false,
  );
  static String thumbnailUrl(String? src, [int maxQuality = 1]) {
    if (src != null && maxQuality != 100) {
      maxQuality = math.max(maxQuality, GlobalData().imgQuality);
      bool hasMatch = false;
      src = src.splitMapJoin(
        _thumbRegex,
        onMatch: (match) {
          hasMatch = true;
          String suffix = match.group(3) ?? '.webp';
          return '${match.group(1)}_${maxQuality}q$suffix';
        },
        onNonMatch: (String str) {
          return str;
        },
      );
      if (!hasMatch) {
        src += '@${maxQuality}q.webp';
      }
    }
    return src.http2https;
  }

  /// 预取图片（封面预取用）：把按 [thumbnailUrl] 同规格的地址提前拉进
  /// CachedNetworkImage 的缓存，滚到那一条时直接命中，不再等网络。
  /// 用 ImageStream 监听触发加载、首帧即断开监听（图已在缓存里）。
  ///
  /// 退回 v3.0.5 实现：一次性对所有 url 立即 resolve（不再做有界队列 + 40ms 间隔
  /// + 并发上限 2 的逐个发）。排队逐个发会拖慢首页首屏封面的出图节奏（实测约 10 秒
  /// 才全部出来），此处按用户要求完全回退到 v3.0.5 的全量并发预取。
  static void prefetchImages(Iterable<String?> urls, {int quality = 1}) {
    for (final url in urls) {
      if (url == null || url.isEmpty) {
        continue;
      }
      final provider = CachedNetworkImageProvider(
        thumbnailUrl(url, quality),
      );
      final stream = provider.resolve(const ImageConfiguration());
      late final ImageStreamListener listener;
      listener = ImageStreamListener((image, synchronousCall) {
        stream.removeListener(listener);
      }, onError: (_, _) {
        stream.removeListener(listener);
      });
      stream.addListener(listener);
    }
  }

  static Future<SaveResult?> saveByteImg({
    required Uint8List bytes,
    required String fileName,
    String ext = 'png',
  }) async {
    SaveResult? res;
    fileName += '.$ext';
    if (PlatformUtils.isMobile) {
      SmartDialog.showLoading(msg: uiTx('正在保存'));
      res = await SaverGallery.saveImage(
        bytes,
        fileName: fileName,
        albumPath: _albumPath,
        skipIfExists: false,
      );
      SmartDialog.dismiss();
      if (res.isSuccess) {
        SmartDialog.showToast(uiTx(' 已保存 '));
      } else {
        SmartDialog.showToast(uiTx('保存失败，${res.errorMessage}'));
      }
    } else {
      SmartDialog.dismiss();
      final savePath = await FilePicker.saveFile(
        type: FileType.image,
        fileName: fileName,
        bytes: Uint8List(0),
      );
      if (savePath == null) {
        SmartDialog.showToast(uiTx("取消保存"));
        return null;
      }
      await File(savePath.toFilePath()).writeAsBytes(bytes);
      SmartDialog.showToast(uiTx(' 已保存 '));
      res = SaveResult(true, null);
    }
    return res;
  }

  static Future<void> saveFileImg({
    required String filePath,
    required String fileName,
    FileType type = FileType.image,
    bool needToast = false,
  }) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      SmartDialog.showToast(uiTx("文件不存在"));
      return;
    }
    SaveResult? res;
    if (PlatformUtils.isMobile) {
      res = await SaverGallery.saveFile(
        filePath: filePath,
        fileName: fileName,
        albumPath: _albumPath,
        skipIfExists: false,
      );
    } else {
      final savePath = await FilePicker.saveFile(
        type: type,
        fileName: fileName,
        bytes: Uint8List(0),
      );
      if (savePath == null) {
        SmartDialog.showToast(uiTx("取消保存"));
        return;
      }
      await file.copy(savePath.toFilePath());
      res = SaveResult(true, null);
    }
    if (needToast) {
      if (res.isSuccess) {
        SmartDialog.showToast(uiTx(' 已保存 '));
      } else {
        SmartDialog.showToast(uiTx('保存失败，${res.errorMessage}'));
      }
    }
  }
}
