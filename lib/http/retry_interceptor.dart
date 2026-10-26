import 'package:dio/dio.dart';
import 'package:http2/http2.dart';

class RetryInterceptor extends Interceptor {
  final Dio _client;
  final int _count;
  final int _delay;

  /// 撞上风控（412）时的刷新回调，由 `http/init.dart` 注入：重新激活 buvid
  /// 设备指纹后再重试。为空时只做退避重试。
  final Future<void> Function()? _onRiskControl;

  RetryInterceptor(
    this._client,
    this._count,
    this._delay, {
    Future<void> Function()? onRiskControl,
  }) : _onRiskControl = onRiskControl;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.requestOptions.responseType == ResponseType.stream) {
      return handler.next(err);
    }
    if (err.response != null) {
      final options = err.requestOptions;
      if (options.followRedirects && options.maxRedirects > 0) {
        final status = err.response!.statusCode;
        if (status != null && 300 <= status && status < 400) {
          var redirectUrl = err.response!.headers.value('location');
          if (redirectUrl != null) {
            var uri = Uri.parse(redirectUrl);
            if (!uri.hasScheme) {
              uri = options.uri.resolveUri(uri);
              redirectUrl = uri.toString();
            }
            (options..path = redirectUrl).maxRedirects--;
            if (status == 303) {
              options
                ..data = null
                ..method = 'GET';
            }
            _client
                .fetch(options)
                .then(
                  (i) => handler.resolve(
                    i
                      ..redirects.add(
                        RedirectRecord(status, options.method, uri),
                      )
                      ..isRedirect = true,
                  ),
                )
                .onError<DioException>((error, _) => handler.next(error));
            return;
          }
        }
      }
      // 服务器给了状态码：此前这里一律直接失败，于是 412（风控）、429（限流）
      // 和 5xx 全都变成「点一下没反应」。改为带退避重试，上限沿用 retryCount；
      // 412 额外刷新一次设备指纹（官方 APP 的自愈方式就是这个）。
      final status = err.response!.statusCode;
      if (status != null &&
          _retryableStatus(status) &&
          err.requestOptions.data is! Stream) {
        final rt = err.requestOptions.extra['_rt'] ??= 0;
        if (rt < _count) {
          err.requestOptions.extra['_rt'] = rt + 1;
          Future.delayed(
            Duration(milliseconds: (rt + 1) * _delay),
            () => _retryAfterStatus(err, handler, status),
          );
          return;
        }
      }
      return handler.next(err);
    } else {
      switch (err.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.unknown:
          if ((err.requestOptions.extra['_rt'] ??= 0) < _count &&
              err.error
                  is! TransportConnectionException // 网络中断, 此时请求可能已经被服务器所接收
                  ) {
            Future.delayed(
              Duration(
                milliseconds: ++err.requestOptions.extra['_rt'] * _delay,
              ),
              () => _client
                  .fetch(err.requestOptions)
                  .then(handler.resolve)
                  .onError<DioException>((error, _) => handler.reject(error)),
            );
          } else {
            handler.next(err);
          }
          return;
        default:
          return handler.next(err);
      }
    }
  }

  /// 412（风控拦截）、429（限流）与 5xx 才值得重试，其余状态码重试没有意义。
  static bool _retryableStatus(int status) =>
      status == 412 || status == 429 || status >= 500;

  /// 上一次刷新设备指纹的时间：一批请求同时撞 412 时只刷新一次。
  static DateTime? _lastRiskRefresh;

  Future<void> _retryAfterStatus(
    DioException err,
    ErrorInterceptorHandler handler,
    int status,
  ) async {
    if (status == 412) {
      await _refreshRiskTokenOnce();
    }
    _client
        .fetch(err.requestOptions)
        .then(handler.resolve)
        .onError<DioException>((error, _) => handler.reject(error));
  }

  /// 刷新 buvid 指纹；1 分钟内只做一次（412 往往是一批请求一起中）。
  Future<void> _refreshRiskTokenOnce() async {
    final now = DateTime.now();
    final last = _lastRiskRefresh;
    if (last != null && now.difference(last) < const Duration(minutes: 1)) {
      return;
    }
    _lastRiskRefresh = now;
    try {
      await _onRiskControl?.call();
    } catch (_) {}
  }

  RetryInterceptor copyWith({Dio? client, int? count, int? delay}) => .new(
    client ?? _client,
    count ?? _count,
    delay ?? _delay,
    onRiskControl: _onRiskControl,
  );
}
