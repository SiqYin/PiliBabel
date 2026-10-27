import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'dart:convert' show json, utf8;
import 'dart:io' show HttpClient, HttpStatus, Platform;

import 'package:collection/collection.dart';
import 'package:PiliPlus/build_config.dart';
import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/browser_ua.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

abstract final class Update {
  // 检查更新
  static Future<void> checkUpdate([bool isAuto = true]) async {
    if (kDebugMode) return;
    SmartDialog.dismiss();
    try {
      final res = await _fetchReleases();
      if (res.data is Map || res.data.isEmpty) {
        if (!isAuto) {
          SmartDialog.showToast(uiTx('检查更新失败，GitHub接口未返回数据，请检查网络'));
        }
        return;
      }
      final bool includePreRelease = Pref.preReleaseUpdate;
      final data = (res.data as List).firstWhere(
        (e) => includePreRelease || e['prerelease'] != true,
        orElse: () => null,
      );
      if (data == null) {
        if (!isAuto) {
          SmartDialog.showToast(uiTx('已是最新版本'));
        }
        return;
      }
      // 判据改成**版本号比较**，不再只比 created_at 与构建时刻。
      //
      // 原来那一行是 `BuildConfig.buildTime >= created_at` 就判「已是最新」。
      // buildTime 是 CI 构建那一刻的秒级时间戳（lib/scripts/build.ps1 写入
      // pili_release.json），于是有两个必然的坑：
      //   1. 任何比线上 Release 更晚构建的包（本地构建、debug 包、CI 重跑、
      //      或者只是时区/时钟偏差）都会被判成「比线上新」，永远不提示更新；
      //   2. 时间戳完全不看版本号，而「谁更新」本质上是版本号的语义。
      // 版本号才是唯一正确依据：tag_name 形如 v3.3.6，与当前 versionName 逐段比。
      // 只有版本号解析不出来（本地构建的 SNAPSHOT）时才退回原来的时间戳判据，
      // 免得把本地包的更新检查也一起关掉。
      final latestTag = '${data['tag_name']}';
      final cmp = _compareVersion(latestTag, BuildConfig.versionName);
      final bool hasUpdate;
      if (cmp != null) {
        hasUpdate = cmp > 0;
      } else {
        final int latest = DateTime.parse(
          data['created_at'],
        ).millisecondsSinceEpoch ~/ 1000;
        hasUpdate = BuildConfig.buildTime < latest;
      }
      if (!hasUpdate) {
        if (!isAuto) {
          SmartDialog.showToast(uiTx('已是最新版本'));
        }
      } else if (isAuto && Pref.skipVersion == data['tag_name']) {
        // 用户已选择跳过此版本，静默忽略
      } else {
        Map<String, dynamic>? bestAsset;
        if (Platform.isAndroid) {
          bestAsset = await _findBestAsset(data);
        }
        SmartDialog.show(
          animationType: SmartAnimationType.centerFade_otherSlide,
          builder: (context) {
            final colorScheme = ColorScheme.of(context);
            Widget downloadBtn(String text, {String? ext, String? url}) =>
                TextButton(
                  onPressed: () => onDownload(data, ext: ext, url: url),
                  child: Text(text),
                );
            // 整个弹窗包在 Obx 里：Release 说明正文（data['body']）走 uiTx——
            // 弹窗先以原文出现，译文在后台翻好后随 revision 自动刷新；
            // 缓存按语言持久化，同一版本的正文只翻译一次。
            return Obx(
              () => AlertDialog(
                title: Text(uiTx('🎉 发现新版本 ')),
                content: SizedBox(
                  height: 280,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data['tag_name']}',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 8),
                        Text(uiTx(data['body'] ?? '')),
                        TextButton(
                          onPressed: () => PageUtils.launchURL(
                            '${Constants.sourceCodeUrl}/commits/main',
                          ),
                          child: Text(uiTx("点此查看完整更新(即commit)内容"),
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  if (isAuto)
                    TextButton(
                      onPressed: () {
                        SmartDialog.dismiss();
                        GStorage.setting.put(
                          SettingBoxKey.skipVersion,
                          data['tag_name'],
                        );
                      },
                      child: Text(uiTx('不再提醒'),
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ),
                  TextButton(
                    onPressed: SmartDialog.dismiss,
                    child: Text(uiTx('取消'),
                      style: TextStyle(color: colorScheme.outline),
                    ),
                  ),
                  if (Platform.isWindows) ...[
                    downloadBtn('zip', ext: 'zip'),
                    downloadBtn('exe', ext: 'exe'),
                  ] else if (Platform.isLinux) ...[
                    downloadBtn('rpm', ext: 'rpm'),
                    downloadBtn('deb', ext: 'deb'),
                    downloadBtn('targz', ext: 'tar.gz'),
                  ] else if (Platform.isAndroid) ...[
                    if (bestAsset != null)
                      downloadBtn(
                        uiTxP('下载 APK ({0})', [bestAsset['name']]),
                        url: bestAsset['browser_download_url'],
                      )
                    else
                      downloadBtn('Github'),
                  ] else
                    downloadBtn('Github'),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('failed to check update: $e');
    }
  }

  // 下载适用于当前系统的安装包
  static Future<void> onDownload(Map data, {String? ext, String? url}) async {
    SmartDialog.dismiss();
    if (url != null) {
      PageUtils.launchURL(url);
      return;
    }
    try {
      void download(String plat) {
        if (data['assets'].isNotEmpty) {
          for (Map<String, dynamic> i in data['assets']) {
            final String name = i['name'];
            if (name.contains(plat) &&
                (ext == null || ext.isEmpty ? true : name.endsWith(ext))) {
              PageUtils.launchURL(i['browser_download_url']);
              return;
            }
          }
          throw UnsupportedError('platform not found: $plat');
        }
      }

      if (Platform.isAndroid) {
        // 获取设备信息
        AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
        // [arm64-v8a]
        download(androidInfo.supportedAbis.first);
      } else {
        download(Platform.operatingSystem);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('download error: $e');
      PageUtils.launchURL('${Constants.sourceCodeUrl}/releases/latest');
    }
  }

  /// 拉 GitHub Releases。失败时**再直连重试一次**。
  ///
  /// 主链路是 dio（默认开 HTTP/2，而 HTTP/2 通道的 socket 由 ConnectionManager
  /// 建，被统一指向了本机解析代理 DnsProxy）。也就是说更新检查是**绕了一圈本机
  /// 代理**才到 GitHub 的：代理里任何一个环节抖动（上游建连超时、TLS 首包被
  /// 丢、idle 断链）都会让这次检查静默失败，而 checkUpdate 的 catch 是静默的
  /// ——用户侧表现就是「永远收不到更新提示」。
  ///
  /// 更新检查是一次性、非关键的请求，没必要为它承担代理链路的风险：第一次失败
  /// 后用裸 HttpClient 直连再试一次（不走代理、不共享连接池）。
  static Future<Response> _fetchReleases() async {
    final options = Options(
      headers: {'user-agent': BrowserUa.mob},
      extra: {'account': const NoAccount()},
    );
    final first = await Request().get(Api.latestApp, options: options);
    if (!_isEmptyPayload(first)) return first;
    return _fetchReleasesDirect();
  }

  static bool _isEmptyPayload(Response res) =>
      res.data is Map || res.data == null || (res.data is List && res.data.isEmpty);

  /// 直连 GitHub（绕过本机解析代理与 HTTP/2 连接池）。
  static Future<Response> _fetchReleasesDirect() async {
    final uri = Uri.parse(Api.latestApp);
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..idleTimeout = const Duration(seconds: 5)
      // 关键：强制直连。main.dart 里给所有 HttpClient 都挂了 findProxy 指向
      // 本机代理，这里显式覆盖回 DIRECT，才能真的绕开那条链路。
      ..findProxy = ((_) => 'DIRECT');
    try {
      final req = await client.getUrl(uri).timeout(
        const Duration(seconds: 10),
      );
      req.headers
        ..set('user-agent', BrowserUa.mob)
        ..set('accept', 'application/vnd.github+json');
      final res = await req.close().timeout(const Duration(seconds: 15));
      if (res.statusCode != HttpStatus.ok) {
        return Response(
          data: <String, dynamic>{'message': 'http ${res.statusCode}'},
          statusCode: res.statusCode,
          requestOptions: RequestOptions(path: Api.latestApp),
        );
      }
      final body = await res
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 15));
      return Response(
        data: json.decode(body),
        statusCode: res.statusCode,
        requestOptions: RequestOptions(path: Api.latestApp),
      );
    } catch (_) {
      return Response(
        data: const <String, dynamic>{'message': 'direct fetch failed'},
        statusCode: -1,
        requestOptions: RequestOptions(path: Api.latestApp),
      );
    } finally {
      client.close(force: true);
    }
  }

  /// 比较两个版本号字符串：返回 >0 表示 [a] 比 [b] 新，0 表示相同，<0 表示更旧；
  /// 任一侧解析不出数字段时返回 **null**（调用方据此退回时间戳判据）。
  ///
  /// 只取数字段逐段比，前缀 `v`、后缀 `-commitHash` / `+buildNumber` 都不参与：
  /// * `v3.3.6` vs `3.3.5` → 1
  /// * `3.3.6` vs `3.3.6` → 0（装的就是最新，不弹窗）
  /// * `3.3.6-abc123456`（CI 给 Android 的 versionName 会拼 commit 短哈希）
  ///   vs `3.3.6` → 0，不会被当成新版本反复提示
  static int? _compareVersion(String a, String b) {
    final va = _parseVersion(a);
    final vb = _parseVersion(b);
    if (va == null || vb == null) return null;
    final len = va.length > vb.length ? va.length : vb.length;
    for (var i = 0; i < len; i++) {
      final x = i < va.length ? va[i] : 0;
      final y = i < vb.length ? vb[i] : 0;
      if (x != y) return x.compareTo(y);
    }
    return 0;
  }

  /// 从 `v3.3.6` / `3.3.6-abc123` / `3.3.6+6307` 里取出数字段 [3, 3, 6]。
  static List<int>? _parseVersion(String src) {
    final match = RegExp(r'(\d+(?:\.\d+)*)').firstMatch(src);
    if (match == null) return null;
    final parts = match.group(1)!.split('.');
    final out = <int>[];
    for (final part in parts) {
      final v = int.tryParse(part);
      if (v == null) return null;
      out.add(v);
    }
    return out.isEmpty ? null : out;
  }

  static Future<Map<String, dynamic>?> _findBestAsset(Map data) async {
    final List assets = data['assets'] ?? [];
    if (assets.isEmpty) return null;

    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo =
          await DeviceInfoPlugin().androidInfo;
      final List<String> abis = androidInfo.supportedAbis;
      for (final String abi in abis) {
        final asset = assets.firstWhereOrNull(
          (e) => e['name'].toString().toLowerCase().contains(abi.toLowerCase()),
        );
        if (asset != null) return asset;
      }
      // fallback to universal if available
      return assets.firstWhereOrNull(
        (e) => e['name'].toString().toLowerCase().contains('universal'),
      );
    }
    return null;
  }
}
