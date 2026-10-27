import 'package:PiliPlus/http/constants.dart';
import 'package:PiliPlus/utils/dns_resolver.dart';
import 'package:PiliPlus/utils/host_health.dart';
import 'package:PiliPlus/utils/net_error.dart';
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
      if (status != null) {
        final host = err.requestOptions.uri.host;
        if (HttpString.isPolicyHost(host)) {
          // 412 额外给主机加冷却（A5.3）：冷却期内优先走备选主机，
          // 避免反复撞同一台
          if (status == 412) {
            HostHealth.instance.recordRiskControl(host);
          } else if (status == 429 || status >= 500) {
            HostHealth.instance.recordFailure(host);
          }
        }
      }
      if (status != null &&
          _retryableStatus(status) &&
          err.requestOptions.data is! Stream) {
        final rt = err.requestOptions.extra['_rt'] ??= 0;
        if (rt < _count) {
          err.requestOptions.extra['_rt'] = rt + 1;
          Future.delayed(
            Duration(milliseconds: _backoff(rt)),
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
          final options = err.requestOptions;
          final kind = NetError.classify(err);
          final host = options.uri.host;
          if (HttpString.isPolicyHost(host)) {
            HostHealth.instance.recordFailure(host);
          }
          if (err.error is TransportConnectionException) {
            // 网络中断, 此时请求可能已经被服务器所接收
            return handler.next(err);
          }
          // 解析可能拿到坏 IP：作废这一台的解析结果，下次重新解析
          // （主机失败换解析、解析失败换主机，两条路互相解耦）
          if (NetError.isHostSwitchable(kind) && host.isNotEmpty) {
            DnsResolver.invalidateHost(host);
          }
          final rt = options.extra['_rt'] ??= 0;
          if (rt >= _count) {
            return handler.next(err);
          }
          options.extra['_rt'] = rt + 1;
          // 先换主机（仅 gRPC 主机组内），再原样退避重试
          _switchHostIfPossible(options, kind);
          Future.delayed(
            Duration(milliseconds: _backoff(rt)),
            () => _client
                .fetch(options)
                .then(handler.resolve)
                .onError<DioException>((error, _) => handler.reject(error)),
          );
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

  /// 成功一次就记一次：主机健康度（A2.4）靠这里积累样本。
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final host = response.requestOptions.uri.host;
    if (HttpString.isPolicyHost(host)) {
      HostHealth.instance.recordSuccess(host);
    }
    handler.next(response);
  }

  /// 指数退避（A3.3）：delay、2×delay、4×delay…，上限 8 秒。
  /// 等间隔重试会把请求堆在一起，弱网下反而把链路压垮。
  int _backoff(int attempt) {
    final base = _delay <= 0 ? 500 : _delay;
    final shift = attempt < 0 ? 0 : (attempt > 4 ? 4 : attempt);
    final value = base << shift;
    return value > 8000 ? 8000 : value;
  }

  /// 换主机重发（A2.3）：只对 gRPC 请求、且主机落在 grpc.biliapi.net /
  /// app.bilibili.com 这一组时生效。
  /// 直链（CDN）与 Web 接口一律不换：直链签名与主机绑定，换了必然失效；
  /// api.bilibili.com 与 app.bilibili.com 的接口面也不通用。
  static bool _switchHostIfPossible(RequestOptions options, NetErrorKind kind) {
    if (!NetError.isHostSwitchable(kind)) return false;
    if (options.extra['_hostSwitched'] == true) return false;
    final uri = options.uri;
    final alternatives = HttpString.grpcAlternatives(
      uri.host,
      isGrpc: _isGrpcRequest(options),
    );
    if (alternatives == null) return false;
    final next = HostHealth.instance.nextOf(alternatives, uri.host);
    if (next == null || next == uri.host) return false;
    options
      ..baseUrl = '${uri.scheme}://$next'
      ..path = uri.path.isEmpty ? '/' : uri.path
      ..queryParameters = uri.queryParametersAll;
    options.extra['_hostSwitched'] = true;
    return true;
  }

  static bool _isGrpcRequest(RequestOptions options) {
    const grpc = 'application/grpc';
    final contentType = options.contentType;
    if (contentType != null && contentType.startsWith(grpc)) return true;
    final header = options.headers['content-type'];
    return header is String && header.startsWith(grpc);
  }

  RetryInterceptor copyWith({Dio? client, int? count, int? delay}) => .new(
    client ?? _client,
    count ?? _count,
    delay ?? _delay,
    onRiskControl: _onRiskControl,
  );
}
