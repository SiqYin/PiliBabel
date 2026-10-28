import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'dart:async' show Completer;
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
      // 有界退避重试：覆盖「启动瞬间网络/代理尚未就绪」的窗口。更新检查本是
      // fire-and-forget 的异步任务，这里多等几秒换来的是不再因为一次瞬时失败而
      // 丢掉整个版本的更新提示（连续多版「收不到弹窗」的根因之一）。
      final res = await _fetchReleasesWithRetry();
      if (_isEmptyPayload(res)) {
        if (!isAuto) {
          SmartDialog.showToast(uiTx('检查更新失败，GitHub接口未返回数据，请检查网络'));
        } else {
          _logCheckFailed();
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

  /// 带**有界退避重试**的更新拉取：最多 [kMaxUpdateRetries] 轮，间隔逐轮拉长。
  ///
  /// 目的：更新检查在启动时只被调一次（fire-and-forget），若那一次恰好撞上
  /// DnsProxy→GitHub 隧道抖动 / 网络瞬时未就绪，旧逻辑就直接静默失败，整个安装
  /// 周期再无机会。这里把它变成多轮重试，覆盖「启动瞬间链路未热」的窗口，
  /// 显著提高收到更新提示的命中率；代价仅是多等最多约十几秒（后台异步，不影响 UI）。
  static const int _kMaxUpdateRetries = 3;

  static Future<Response> _fetchReleasesWithRetry() async {
    Response? last;
    for (var attempt = 0; attempt < _kMaxUpdateRetries; attempt++) {
      last = await _fetchReleases();
      if (!_isEmptyPayload(last)) {
        return last; // 非空即成功，第一时间返回
      }
      _logCheckFailed();
      if (attempt < _kMaxUpdateRetries - 1) {
        // 退避间隔：500ms / 2000ms / 4500ms（平方递增），给瞬时网络/代理自愈留时间
        await Future<void>.delayed(
          Duration(milliseconds: 500 * (attempt + 1) * (attempt + 1)),
        );
      }
    }
    // 全部轮次都失败：返回最后一次的结果（可能仍为空），调用方据此静默/提示
    return last!;
  }

  /// 更新检查失败留痕：release 版 debugPrint 被裁剪，这里至少把失败次数打进
  /// kDebugMode 的日志，方便 debug 构建定位。真正的失败可观测依赖调用方（见
  /// checkUpdate 的 isAuto 分支处理）。
  static void _logCheckFailed() {
    if (kDebugMode) debugPrint('update check failed');
  }

  /// 拉 GitHub Releases。**多路并发赛马**：任一路**最早拿到非空 releases 列表即胜**。
  ///
  /// 背景（连续多版「收不到更新弹窗」的真根因之一）：更新检查在依赖单条网络请求，
  /// 而 App 默认开 HTTP/2，更新请求被套进为 B 站调优的本机 DnsProxy 隧道（init.dart
  /// `_createPool` 把连接池 proxy 指向 127.0.0.1 本机代理），api.github.com 也要绕这
  /// 一圈代理才到 GitHub。隧道里任何一环抖动都会让这唯一一次请求静默失败。
  ///
  /// 这次改成**并行赛马**而不是「先等 dio 完整失败再串行直连」：
  /// - 路1：dio 主链路（保留 HTTP/2 + 共享连接池，正常时最快）；
  /// - 路2：裸 HttpClient `findProxy=DIRECT` 直连（绕开本机代理与连接池）。
  ///
  /// 实现为**真正的先到先得**：用 [Completer]，任一路返回非空结果就立刻 complete 返回，
  /// 不等另一路 settle。注意不能用 `Future.wait`——它要等**所有** future 完成，只要直连
  /// 那路慢（甚至挂到 15s 超时），即使 dio 半秒就返回也会被拖到十几秒才弹窗。这正是
  /// 「进 APP 后 5~10 秒才弹更新」的根因，这里把它修成极速：谁先有数据谁胜。
  static Future<Response> _fetchReleases() {
    final completer = Completer<Response>();
    var done = false;
    void settle(Response? r) {
      if (done) return; // 已有人胜出，忽略其余晚到结果
      if (r != null && !_isEmptyPayload(r)) {
        done = true;
        completer.complete(r);
      }
    }

    void fail() {
      if (done) return;
      done = true;
      completer.complete(
        Response(
          data: const <String, dynamic>{'message': 'releases fetch failed'},
          statusCode: -1,
          requestOptions: RequestOptions(path: Api.latestApp),
        ),
      );
    }

    var settled = 0;
    const total = 2;
    void onSettled(Response? r) {
      settle(r);
      settled++;
      // 两路都到齐且都是空：没有可用结果，按失败处理
      if (settled == total && !done) fail();
    }

    _safeFetchViaDio().then(
      onSettled,
      onError: (_) => onSettled(null),
    );
    _safeFetchDirect().then(
      onSettled,
      onError: (_) => onSettled(null),
    );
    return completer.future;
  }

  /// 路1：走 dio 主链路（HTTP/2 + 连接池）。任何异常都转为失败 Response，不抛出。
  /// 显式加 4s 超时：更新检查不该被代理链路拖久，超时就放弃这条路，让路2 直连接管。
  static Future<Response?> _safeFetchViaDio() async {
    try {
      final options = Options(
        headers: {'user-agent': BrowserUa.mob},
        extra: {'account': const NoAccount()},
      );
      final res = await Request()
          .get(Api.latestApp, options: options)
          .timeout(const Duration(seconds: 4));
      return res;
    } catch (e) {
      // Request().get 通常已把 DioException 转成 Map Response，这里兜住其余异常
      if (kDebugMode) debugPrint('update via dio failed: $e');
      return null;
    }
  }

  /// 路2：裸 HttpClient 直连（绕过本机解析代理与 HTTP/2 连接池）。异常自行吞掉。
  static Future<Response?> _safeFetchDirect() async {
    try {
      return await _fetchReleasesDirect().timeout(
        const Duration(seconds: 12),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('update direct failed: $e');
      return null;
    }
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
