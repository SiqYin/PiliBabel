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

class DownloadManager {
  /// 候选直链：首个为按当前 CDN 策略选出的主线路，其余为备用/其它镜像。
  /// 当前线路速度过低或请求失败时，自动切换到下一条并断点续传。
  final List<String> urls;
  final String path;
  final void Function(int, int)? onReceiveProgress;
  final void Function([Object? error]) onDone;

  /// 低于该速度(B/s)持续一个窗口即换下一条线路
  static const int _minSpeedBytes = 64 * 1024;
  static const int _speedWindowMs = 5000;

  /// 首个线路至少跑满该时长才允许因慢速切换（排除冷启动抖动）
  static const int _minRunBeforeRotateMs = 8000;

  /// 完全停摆(0 字节)看门狗：超过该时长无进度即换线；已是最后一条则报错失败
  static const int _stallMs = 10000;

  DownloadStatus _status = DownloadStatus.downloading;

  DownloadStatus get status => _status;
  CancelToken? _cancelToken;
  int _urlIndex = 0;
  bool _stallRotate = false;
  late final Future<void> task;

  DownloadManager({
    required List<String> urls,
    required this.path,
    required this.onReceiveProgress,
    required this.onDone,
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
      _cancelToken = CancelToken();
      try {
        await _downloadFrom(file, urls[_urlIndex]);
        return; // completed（或用户取消等终态，已在内部处理）
      } on _RotateSignal {
        // 慢速/校验失败：换下一条线路，断点保留
      } on DioException {
        // 看门狗判定停摆而取消：视为换线，不算用户取消
        if (_stallRotate) {
          _stallRotate = false;
          continue;
        }
        // 网络异常：换下一条线路，断点保留；
        // 用户主动取消(pause/delete)时不轮转，直接结束。
        if (_cancelToken?.isCancelled ?? false) {
          return;
        }
      }
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
            validateStatus: (status) =>
                status != null &&
                (status == 416 || (status >= 200 && status < 300)),
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

    final data = response.data!;
    final contentLength = data.contentLength + received;
    if (received == 0) {
      onReceiveProgress?.call(0, contentLength);
    }

    int winStartMs = DateTime.now().millisecondsSinceEpoch;
    int winBytes = 0;
    int? last;

    // 停摆看门狗：连接 0 字节长期无进度（HTTP/2 适配器对流式响应可能
    // 不执行 receiveTimeout）时强制取消——外层据此换下一条线路；
    // 若已是最后一条，循环耗尽后统一走 _fail 报下载失败，绝不静默卡死。
    int lastProgressMs = DateTime.now().millisecondsSinceEpoch;
    int progressMark = received;
    final watchdog = Timer.periodic(const Duration(seconds: 3), (t) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (received != progressMark) {
        progressMark = received;
        lastProgressMs = now;
        return;
      }
      if (now - lastProgressMs >= _stallMs) {
        t.cancel();
        _stallRotate = true;
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
    _cancelToken?.cancel();
    return task;
  }
}
