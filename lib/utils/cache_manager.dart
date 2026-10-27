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
  /// 两个要点，缺一都会让图要么加载不出、要么把整机网络拖死：
  ///
  /// 1) **不走本机 DNS 解析代理（findProxy = DIRECT）**。main.dart 的
  ///    `_CustomHttpOverrides` 会把所有 `HttpClient` 的 findProxy 指向
  ///    `DnsProxy`（127.0.0.1 的 CONNECT 隧道）。图片数量巨大且每张图片都会
  ///    新开一条隧道，一旦并发上来就把代理的 socket / 事件循环挤爆，连带
  ///    API 数据请求（同样经由该代理）一起饿死——表现为首页、动态、收藏、
  ///    历史全部加载不出来。图片域名（hdslb 等）用系统解析完全够用，
  ///    不需要自解析，所以这里明确直连，把代理留给数据请求。
  /// 2) **并发上限放大到 32**。此前是 6：首屏几十张封面抢 6 个槽位，抢不到
  ///    的落在连接超时上，errorBuilder 落回灰占位且不再自动重试，只能下拉
  ///    刷新重建 widget 才重新加载（v3.0.5 图片是库默认的无上限并发，没有这个
  ///    现象）。直连之后不再有代理可挤，放大到 32 即可贴近 v3.0.5 的并行度，
  ///    又不至于把文件句柄用光。
  static final http.Client _imageClient = _ImageHttpClient(
    IOClient(
      HttpClient()
        ..userAgent = BrowserUa.pc
        ..idleTimeout = const Duration(seconds: 15)
        ..maxConnectionsPerHost = 32
        // 关键字：绕开 DnsProxy，图片直连。HttpOverrides 已经给它挂上了代理，
        // 这里在同一实例上再覆盖一次，确保生效。
        ..findProxy = ((_) => 'DIRECT'),
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
    // 只限制「多久没来数据」，不掐断慢速下载：连接 15s、数据块间隔 30s。
    // 有上限并发 + 直连后，这里主要用来兜住真正卡死的连接，避免永远占位块。
    connectionParameters: ConnectionParameters(
      connectionTimeout: const Duration(seconds: 15),
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
