import 'dart:async';
import 'dart:io';

import 'package:PiliPlus/http/browser_ua.dart';
import 'package:PiliPlus/http/constants.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/models_new/download/bili_download_entry_info.dart';
import 'package:PiliPlus/utils/extension/file_ext.dart';
import 'package:PiliPlus/utils/extension/string_ext.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// 触发"换下一条线路"的内部信号（当前线路速度过低）
class _RotateSignal implements Exception {
  final String reason;
  _RotateSignal(this.reason);
}

/// 停摆时让位给队列中的其他下载项（由 DownloadService 处理善后）
class StallDeferred implements Exception {
  const StallDeferred();
}

/// 龟速升级信号：最后一条线路也已经持续低速——
/// [defer] = true 交回 service 重取直链/让位给别人先下；false 则明确报下载失败。
/// 专治「一直显示正在下载、速度几十K、永远不动也不报错」。
class _GiveUpSignal implements Exception {
  final bool defer;
  _GiveUpSignal(this.defer);
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

  /// 已经是最后一条线路时，连续这么多个低速窗口(≈15s)仍爬不动，
  /// 就不再"无限慢速下载"：交回 service 重取直链（会拿到一批新的已签名
  /// 候选地址、并按断点续传），额度用尽则明确报下载失败。
  /// 中速(32~64KB/s)不触发，避免误伤本来就慢的网络。
  static const int _crawlSpeedBytes = 32 * 1024;
  static const int _maxSlowWindows = 3;

  /// 首个线路至少跑满该时长才允许因慢速切换（排除冷启动抖动）
  static const int _minRunBeforeRotateMs = 8000;

  /// 停摆规则（与需求一致）：**5 秒零字节即换下一条候选线路，最多换 2 次
  /// （即一条任务最多用 3 条线路）**；换无可换就结束这一项：
  /// 队列里还有其它等待项 → 自动让位（断点保留、退回队尾，先下别的，
  /// 轮到它时重取直链拿到一批新线路）；只剩它自己 → 明确报「下载失败」，
  /// 绝不出现停在某个字节数不动也不报错的情况。
  static const int _stallMs = 5000;
  static const int _maxRotations = 2;

  /// 本次任务已经换过几次线路
  int _rotations = 0;

  /// 全局兜底看门狗：连续这么久没有任何一个新字节，就按同一套停摆规则处理。
  /// 阈值与线路内看门狗一致（5 秒），因为线路内那只「已经在收流」才上岗，
  /// 管不到「换线后请求已发出、响应头一直不来」和断点重开的间隙——
  /// 曾经就卡在这里：进度停在某个 MB 几十分钟不动、不报错，还把下载锁占死。
  static const int _noProgressMs = _stallMs;
  static const Duration _globalWatchdogTick = Duration(seconds: 1);

  /// 已收字节（跨线路累计，供全局看门狗判断是否有进展）
  int _received = 0;

  /// 最近一次「有新字节」的时刻
  int _lastByteMs = DateTime.now().millisecondsSinceEpoch;

  /// 看门狗轮询间隔（1s：让 5 秒阈值尽量贴准时）
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
      await _fail('没有可用的下载直链');
      return;
    }

    // 全局兜底看门狗：任何阶段连续 [_noProgressMs] 没有新字节，就强制取消当前
    // 请求（含「响应头一直不来」——那时线路内看门狗还没上岗），
    // 之后按同一套停摆规则换线 / 让位 / 报错，绝不静默卡死。
    final globalWatchdog = Timer.periodic(_globalWatchdogTick, (t) {
      if (_cancelRequested || _status != DownloadStatus.downloading) {
        t.cancel();
        return;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastByteMs < _noProgressMs) {
        return;
      }
      _lastByteMs = now; // 再给一轮预算，避免同一位置反复触发
      _escalateStall();
      _cancelToken?.cancel();
    });
    try {
      await _runUrls(file);
    } catch (e) {
      // 兜底：非 Dio 异常（磁盘写满、文件系统/权限异常、sink 抛错等）也必须
      // 落到 onDone。否则 task 以错误结束而没人 await 它 → 状态永远停在
      // 「正在下载」、进度字节一动不动，也不报失败——正是最难查的那种卡死。
      if (!_cancelRequested && _status == DownloadStatus.downloading) {
        await _fail(e);
      }
    } finally {
      globalWatchdog.cancel();
    }
  }

  /// 停摆升级（线路内看门狗与全局兜底看门狗共用一套判定）：
  /// 先换下一条候选线路，最多换 [_maxRotations] 次；换无可换时——
  /// 队列里还有其它未完成项就让位（pass），只剩自己就报下载失败。
  void _escalateStall() {
    if (_urlIndex < urls.length - 1 && _rotations < _maxRotations) {
      _rotations++;
      _stallRotate = true;
      return;
    }
    if (shouldDefer?.call() ?? false) {
      _deferred = true;
    } else {
      // 没有其它排队项（或让位额度用尽）：继续换到候选耗尽，由 _fail 明确报错
      _stallRotate = true;
    }
  }

  Future<void> _runUrls(File file) async {
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
      } on _GiveUpSignal catch (g) {
        // 最后一条线路仍持续龟速：让位重取直链，额度用尽则明确失败
        if (g.defer) {
          _status = DownloadStatus.pause;
          onDone(const StallDeferred());
        } else {
          await _fail('线路太慢，已停止本次缓存');
        }
        return;
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
    await _fail('所有下载线路均失败');
  }

  /// 从 [url] 的断点处续传；完成/失败/换线都先关 sink。
  Future<void> _downloadFrom(File file, String url) async {
    _received = file.existsSync() ? await file.length() : 0;
    final received = _received;
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
    int slowWindows = 0;
    int? last;

    // 线路内停摆看门狗：收流阶段 0 字节满 5 秒（HTTP/1.1 与 HTTP/2 适配器都
    // 可能不执行 receiveTimeout）即按 [_escalateStall] 处理——
    // 换下一条线路（一条任务最多换 2 次、共 3 条线路）；换无可换时，
    // 队列里还有其它等待项就让位（pass，断点保留），只剩自己就报「下载失败」。
    int lastProgressMs = DateTime.now().millisecondsSinceEpoch;
    int progressMark = _received;
    final watchdog = Timer.periodic(_watchdogTick, (t) {
      if (_cancelRequested) {
        t.cancel();
        return;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      if (_received != progressMark) {
        progressMark = _received;
        lastProgressMs = now;
        return;
      }
      final stalled = now - lastProgressMs;
      if (stalled >= _stallMs) {
        // 5 秒零字节：换下一条线路（最多换 2 次）；换无可换就让位或报错
        t.cancel();
        _escalateStall();
        _cancelToken?.cancel();
      }
    });

    try {
      await for (final chunk in data.stream) {
        sink.add(chunk);
        _received += chunk.length;
        _lastByteMs = DateTime.now().millisecondsSinceEpoch;
        winBytes += chunk.length;
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (last != now) {
          last = now;
          onReceiveProgress?.call(_received, contentLength);
        }
        final elapsed = DateTime.now().millisecondsSinceEpoch - winStartMs;
        if (elapsed >= _speedWindowMs) {
          final speed = winBytes * 1000 / elapsed;
          final runMs = DateTime.now().millisecondsSinceEpoch - urlStartMs;
          if (speed < _minSpeedBytes && runMs >= _minRunBeforeRotateMs) {
            if (_urlIndex < urls.length - 1) {
              throw _RotateSignal('slow: $speed B/s');
            }
            // 已是最后一条：低速到明显没救才累计升级；中速继续下，不误伤慢网络
            if (speed < _crawlSpeedBytes) {
              slowWindows++;
              if (slowWindows >= _maxSlowWindows) {
                final defer = shouldDefer?.call() ?? false;
                _cancelToken?.cancel();
                throw _GiveUpSignal(defer);
              }
            }
          } else {
            slowWindows = 0;
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

  Future<void> _fail(Object reason) async {
    if (kDebugMode) {
      debugPrint('download failed: $reason (candidates=${urls.length} index=$_urlIndex rot=$_rotations)');
    }
    if (_status == DownloadStatus.downloading) {
      _status = DownloadStatus.failDownload;
    }
    onDone(reason);
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
