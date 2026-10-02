import 'dart:async';
import 'dart:io';

import 'package:PiliPlus/http/browser_ua.dart';
import 'package:PiliPlus/http/constants.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/models_new/download/bili_download_entry_info.dart';
import 'package:PiliPlus/utils/extension/file_ext.dart';
import 'package:PiliPlus/utils/extension/string_ext.dart';
import 'package:dio/dio.dart';

class DownloadManager {
  final String url;
  final String path;
  final void Function(int, int)? onReceiveProgress;
  final void Function([Object? error]) onDone;

  DownloadStatus _status = DownloadStatus.downloading;

  DownloadStatus get status => _status;
  final _cancelToken = CancelToken();
  late Future<void> task;

  DownloadManager({
    required this.url,
    required this.path,
    required this.onReceiveProgress,
    required this.onDone,
  }) {
    task = _start();
  }

  Future<void> _start() async {
    int received;

    final file = File(path);
    if (file.existsSync()) {
      received = await file.length();
    } else {
      file.createSync(recursive: true);
      received = 0;
    }

    var sink = file.openWrite(
      mode: received == 0 ? FileMode.writeOnly : FileMode.writeOnlyAppend,
    );

    Future<void> onError(Object e, {bool delete = false}) async {
      try {
        await sink.close();
      } catch (_) {}
      if (_status == DownloadStatus.downloading) {
        _status = DownloadStatus.failDownload;
        if (delete && file.existsSync()) {
          await file.tryDel();
        }
      }
      onDone(e);
    }

    // Akamai 等海外 CDN 会校验 Referer/UA：缺省 UA(Dart/3.6) 且无 Referer
    // 会被 403（国内 upos 镜像较宽容，所以换 Akamai 后才暴露）。
    // 与播放器 setMediaHeader 的 referer/UA 保持一致。
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
            validateStatus: (status) =>
                status != null &&
                (status == 416 || (status >= 200 && status < 300)),
          ),
          cancelToken: _cancelToken,
        );

    Response<ResponseBody> response;
    try {
      try {
        response = await getStream(received);
      } on DioException catch (e) {
        final code = e.response?.statusCode ?? 0;
        // 403/410/412：多为断点失效(直链过期)或 CDN 校验失败——
        // 清掉断点从头重试一次；再失败则走原有失败流程。
        if ((code == 403 || code == 410 || code == 412) && received > 0) {
          try {
            await sink.close();
          } catch (_) {}
          try {
            if (file.existsSync()) {
              await file.tryDel();
            }
          } catch (_) {}
          received = 0;
          sink = file.openWrite(mode: FileMode.writeOnly);
          response = await getStream(0);
        } else {
          rethrow;
        }
      }
    } on DioException catch (e) {
      await onError(e, delete: true);
      return;
    }
    final data = response.data!;
    final contentLength = data.contentLength + received;

    if (received == 0) {
      onReceiveProgress?.call(0, contentLength);
    }

    int? last;
    try {
      await for (final chunk in data.stream) {
        sink.add(chunk);
        received += chunk.length;
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (last != now) {
          last = now;
          onReceiveProgress?.call(received, contentLength);
        }
      }
      await sink.close();
      _status = DownloadStatus.completed;
      onDone();
    } catch (e) {
      await onError(e);
      return;
    }
  }

  Future<void> cancel({required bool isDelete}) {
    if (!isDelete && _status == DownloadStatus.downloading) {
      _status = DownloadStatus.pause;
    }
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel();
    }
    return task;
  }
}
