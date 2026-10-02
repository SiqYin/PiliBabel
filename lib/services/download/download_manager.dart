import 'dart:async';
import 'dart:io';

import 'package:PiliPlus/http/browser_ua.dart';
import 'package:PiliPlus/http/constants.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/models_new/download/bili_download_entry_info.dart';
import 'package:PiliPlus/utils/extension/file_ext.dart';
import 'package:PiliPlus/utils/extension/string_ext.dart';
import 'package:dio/dio.dart';

/// 触发"换下一条线路"的内部信号（当前线路速度过低）
class _RotateSignal implements Exception {
  final String reason;
  _RotateSignal(this.reason);
}

/// 停摆时让位给队列中的其他下载项（由 DownloadService 处理善后）
class StallDeferred implements Exception {
  const StallDeferred();
}

class DownloadManager {
  /// 候选直链：首个为按当前 CDN 策略选出的主线路，其余为备用/其它镜像。
  /// 当前线路速度过低或请求失败时，自动切换到下一条并断点续传。
  final List<String> urls;
  final String path;
  final void Function(int, int)? onReceiveProgress;
  final void Function([Object? error]) onDone;

  /// 停摆时是否应"让位"给队列中的其它下载项（有排队项则让位、否则换线）
  final bool Function()? shouldDefer;

  /// 低于该速度(B/s)持续一个窗口即换下一条线路
  static const int _minSpeedBytes = 64 * 1024;
  static const int _speedWindowMs = 5000;

  /// 首个线路至少跑满该时长才允许因慢速切换（排除冷启动抖动）
  static const int _minRunBeforeRotateMs = 8000;

  /// 停摆(0 字节)看门狗——两级阈值（与需求一致）：
  /// * 满 5s 无字节且队列里还有其它等待项 → 先「让位」，回去排到队尾，让别人先下；
  /// * 满 10s 无字节 → 强制换下一条线路；已是最后一条则循环耗尽走 [_fail] 报下载失败，
  ///   绝不静默卡住不动。
  static const int _deferStallMs = 5000;
  static const int _rotateStallMs = 10000;

  /// 看门狗轮询间隔（1s：让两级阈值尽量贴准时）
  static const Duration _watchdogTick = Duration(seconds: 1);

  DownloadStatus _status = DownloadStatus.downloading;

  DownloadStatus get status => _status;
  CancelToken? _cancelToken;
  int _urlIndex = 0;
  bool _stallRotate = false;
  bool _deferred = false;

  /// 取消标记（粘滞）：换线窗口内 _cancelToken 会被替换，只靠 token 判断
  /// 会漏掉「恰好发生在两条线路之间」的取消，导致本任务继续跑下去；
  /// service 侧 await task 就永远不返回 → 下载锁被卡死 → 表现为
  /// 「正在下载音频时无法切换到其它等待项」。
  bool _cancelRequested = false;

  late final Future<void> task;

  DownloadManager({
    required List<String> urls,
    required this.path,
    required this.onReceiveProgress,
    required this.onDone,
    this.shouldDefer,
  }) : urls = urls.isEmpty ? const [''] : urls {
    task = _start();
  }

  Future<void> _start() async {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    if (urls.isEmpty) {
      await _fail('no download url');
      return;
    }
    for (_urlIndex = 0; _urlIndex < urls.length; _urlIndex++) {
      if (_cancelRequested) {
        return;
      }
      _cancelToken = CancelToken();
      try {
        await _downloadFrom(file, urls[_urlIndex]);
        return; // completed（或用户取消等终态，已在内部处理）
      } on _RotateSignal {
        // 慢速/校验失败：换下一条线路，断点保留
        if (_cancelRequested) {
          return;
        }
      } on DioException catch (e) {
        // 用户/服务侧已取消：静默收尾，不再让位或换线
        if (_cancelRequested) {
          return;
        }
        // 看门狗判定停摆且应"让位"：交回 service 排到队尾，先下其它项
        if (_deferred) {
          _deferred = false;
          _status = DownloadStatus.pause;
          onDone(const StallDeferred());
          return;
        }
        // 看门狗判定停摆而取消：视为换线，不算用户取消
        if (_stallRotate) {
          _stallRotate = false;
          continue;
        }
        // 用户主动取消(pause/delete)时不轮转，直接结束。
        if (_cancelToken?.isCancelled ?? false) {
          return;
        }
        final code = e.response?.statusCode ?? 0;
        if (code == 403 || code == 410 || code == 412 || code == 416) {
          // 续传 Range 被拒 / 直链签名失效 / 断点被污染：丢弃可疑断点，
          // 换下一条线路从 0 重下（否则表现为反复"断连"）。
          try {
            if (file.existsSync()) {
              await file.tryDel();
            }
          } catch (_) {}
          continue;
        }
      }
    }
    if (_cancelRequested) {
      return;
    }
    await _fail('all ${urls.length} candidates failed');
  }

  /// 从 [url] 的 [offset] 字节处续传；完成/失败/换线都先关 sink。
  Future<void> _downloadFrom(File file, String url) async {
    int received = file.existsSync() ? await file.length() : 0;
    IOSink sink = file.openWrite(
      mode: received == 0 ? FileMode.writeOnly : FileMode.writeOnlyAppend,
    );
    final urlStartMs = DateTime.now().millisecondsSinceEpoch;

    Future<void> closeSink() async {
      try {
        await sink.close();
      } catch (_) {}
    }

    // Akamai 等海外 CDN 会校验 Referer/UA：缺省 UA(Dart/3.6) 且无 Referer
    // 会被 403。与播放器 setMediaHeader 的 referer/UA 保持一致。
    Future<Response<ResponseBody>> getStream(int offset) =>
        Request.http11Dio.get<ResponseBody>(
          url.http2https,
          options: Options(
            headers: {
              'range': 'bytes=$offset-',
              'referer': HttpString.baseUrl,
              'user-agent': BrowserUa.pc,
            },
            responseType: ResponseType.stream,
            receiveTimeout: const Duration(seconds: 20),
            // 注意：不能把 416 当成功——它的响应体是错误文本，会被写进文件
            // 污染断点（音频小而常续传，最易中招 → 表现为"一直断连"）。
            validateStatus: (status) =>
                status != null && status >= 200 && status < 300,
          ),
          cancelToken: _cancelToken,
        );

    Response<ResponseBody> response;
    try {
      response = await getStream(received);
    } on DioException {
      // 403/410/412/超时等：断点保留，交由外层换下一条线路
      await closeSink();
      rethrow;
    }
    if (_cancelRequested) {
      // 响应回来的瞬间已被取消：不再写入/轮转
      await closeSink();
      return;
    }

    final data = response.data!;
    final contentLength = data.contentLength + received;
    if (received == 0) {
      onReceiveProgress?.call(0, contentLength);
    }

    int winStartMs = DateTime.now().millisecondsSinceEpoch;
    int winBytes = 0;
    int? last;

    // 停摆看门狗：连接 0 字节长期无进度（HTTP/2 适配器对流式响应可能
    // 不执行 receiveTimeout）时强制收尾——
    // 5s 无字节 + 队列里有其它等待项 → 让位给别人先下；
    // 10s 无字节 → 换下一条线路；最后一条也挂满 10s → 循环耗尽走 _fail
    // 报下载失败，绝不静默卡住不动。
    int lastProgressMs = DateTime.now().millisecondsSinceEpoch;
    int progressMark = received;
    final watchdog = Timer.periodic(_watchdogTick, (t) {
      if (_cancelRequested) {
        t.cancel();
        return;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      if (received != progressMark) {
        progressMark = received;
        lastProgressMs = now;
        return;
      }
      final stalled = now - lastProgressMs;
      if (stalled >= _rotateStallMs) {
        t.cancel();
        _stallRotate = true;
        _cancelToken?.cancel();
        return;
      }
      if (stalled >= _deferStallMs && (shouldDefer?.call() ?? false)) {
        // 队列里还有其它等待项：让位，之后轮到它时自动重取直链+断点续传
        t.cancel();
        _deferred = true;
        _cancelToken?.cancel();
      }
    });

    try {
      await for (final chunk in data.stream) {
        sink.add(chunk);
        received += chunk.length;
        winBytes += chunk.length;
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (last != now) {
          last = now;
          onReceiveProgress?.call(received, contentLength);
        }
        final elapsed = DateTime.now().millisecondsSinceEpoch - winStartMs;
        if (elapsed >= _speedWindowMs) {
          final speed = winBytes * 1000 / elapsed;
          final runMs = DateTime.now().millisecondsSinceEpoch - urlStartMs;
          if (speed < _minSpeedBytes &&
              runMs >= _minRunBeforeRotateMs &&
              _urlIndex < urls.length - 1) {
            throw _RotateSignal('slow: $speed B/s');
          }
          winStartMs = DateTime.now().millisecondsSinceEpoch;
          winBytes = 0;
        }
      }
      await sink.close();
      _status = DownloadStatus.completed;
      onDone();
    } catch (e) {
      // 中途异常（含看门狗取消/慢速换线）：保留断点，交由外层换线或失败
      await closeSink();
      rethrow;
    } finally {
      watchdog.cancel();
    }
  }

  Future<void> _fail(String message) async {
    if (_status == DownloadStatus.downloading) {
      _status = DownloadStatus.failDownload;
    }
    onDone(message);
  }

  Future<void> cancel({required bool isDelete}) {
    if (!isDelete && _status == DownloadStatus.downloading) {
      _status = DownloadStatus.pause;
    }
    _cancelRequested = true;
    _cancelToken?.cancel();
    return task;
  }
}
