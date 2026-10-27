import 'dart:io' show Directory, File, HttpClient;

import 'package:PiliPlus/http/browser_ua.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

abstract final class CacheManager {
  static late final DefaultCacheManager manager;

  /// 图片下载统一用这一个 client。
  ///
  /// 此前图片由图片库内部自建连接：每张图一条新连接、带裸 Dart UA、没有
  /// Referer，海外访问图片域既慢又容易被降速。这里换成共享 HttpClient
  /// （keep-alive 复用连接）+ 浏览器 UA + Referer，与 App 其它请求的
  /// 指纹保持一致。
  static final http.Client _imageClient = _ImageHttpClient(
    IOClient(
      HttpClient()
        ..userAgent = BrowserUa.pc
        ..idleTimeout = const Duration(seconds: 15)
        ..maxConnectionsPerHost = 6,
    ),
  );

  static Future<void> ensureInitialized() => DefaultCacheManager.init(
    cacheDirectoryProvider:
        PlatformUtils.isDesktop
            ? () async {
              final appSupportDirectory =
                  await getApplicationSupportDirectory();
              return Directory(
                path.join(appSupportDirectory.path, 'cached_network_image_ce'),
              );
            }
            : getTemporaryDirectory,
    maxNrOfCacheLength: Pref.maxCacheSize.toInt(),
    httpClientFactory: () => _imageClient,
    // 此前不设任何超时：一张图卡住就一直挂着，页面永远是占位块。连接 10s、
    // 数据块间隔 30s（只限制「多久没来数据」，不会掐断慢速下载）。
    connectionParameters: ConnectionParameters(
      connectionTimeout: const Duration(seconds: 10),
      requestTimeout: const Duration(seconds: 30),
    ),
  ).then((i) => manager = i);

  // 获取缓存目录
  @pragma('vm:notify-debugger-on-exception')
  static Future<int> loadApplicationCache() async {
    try {
      if (PlatformUtils.isDesktop) {
        return manager.getTotalLength();
      }

      final Directory tempDirectory = await getTemporaryDirectory();
      if (tempDirectory.existsSync()) {
        return await getTotalSizeOfFilesInDir(tempDirectory);
      }
    } catch (_) {}
    return 0;
  }

  // 循环计算文件的大小
  @pragma('vm:notify-debugger-on-exception')
  static Future<int> getTotalSizeOfFilesInDir(Directory file) async {
    int total = 0;
    await for (final child in file.list(recursive: false)) {
      if (child is File) {
        total += await child.length();
      } else if (child is Directory) {
        if (path.equals(child.path, manager.cacheDir)) {
          total += manager.getTotalLength();
        } else {
          await for (final i in child.list(recursive: true)) {
            if (i is File) {
              total += await i.length();
            }
          }
        }
      }
    }
    return total;
  }

  // 缓存大小格式转换
  static String formatSize(num value) {
    const unitArr = ['B', 'K', 'M', 'G', 'T', 'P'];
    int index = 0;
    while (value >= 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return size + (unitArr.elementAtOrNull(index) ?? '');
  }

  // 清除 Library/Caches 目录及文件缓存
  @pragma('vm:notify-debugger-on-exception')
  static Future<void> clearLibraryCache() async {
    try {
      await manager.emptyCache();
      if (PlatformUtils.isDesktop) return;

      final tempDirectory = await getTemporaryDirectory();
      if (tempDirectory.existsSync()) {
        await for (final file in tempDirectory.list(recursive: false)) {
          if (file is Directory && path.equals(file.path, manager.cacheDir)) {
            continue;
          }
          await file.delete(recursive: true);
        }
      }
    } catch (_) {}
  }
}

/// 给图片请求统一补上浏览器 UA 与 Referer：B 站图片域对裸 Dart UA、无 Referer
/// 的请求会降速，海外 IP 下尤其明显。调用方自带同名头时不覆盖。
final class _ImageHttpClient extends http.BaseClient {
  _ImageHttpClient(this._inner);

  final http.Client _inner;

  static const _referer = 'https://www.bilibili.com/';

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.putIfAbsent('user-agent', () => BrowserUa.pc);
    request.headers.putIfAbsent('referer', () => _referer);
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
