import 'package:PiliPlus/http/constants.dart';
import 'package:PiliPlus/utils/host_health.dart';
import 'package:dio/dio.dart';

/// 并发限流拦截器（A3.4）：同一主机的并发请求超过上限就排队，避免一批请求同时
/// 挤在一条链路上把带宽抢光、反而拖慢首帧。
///
/// 只拦普通请求：流式响应（下载、媒体）会长时间占着连接，标了 noLimit 的请求
/// 也直接放行。
class HostLimiterInterceptor extends Interceptor {
  HostLimiterInterceptor({this.limit = HttpTimeout.maxConcurrentPerHost});

  final int limit;

  static const String _slotKey = '_hostSlot';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_skip(options)) return handler.next(options);
    final host = options.uri.host;
    if (host.isEmpty) return handler.next(options);
    final held = await HostLimiter.instance.acquire(host, limit);
    if (held) options.extra[_slotKey] = host;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _release(response.requestOptions);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _release(err.requestOptions);
    handler.next(err);
  }

  void _release(RequestOptions options) {
    final host = options.extra.remove(_slotKey);
    if (host is String) {
      HostLimiter.instance.release(host);
    }
  }

  static bool _skip(RequestOptions options) =>
      options.responseType == ResponseType.stream ||
      options.extra['noLimit'] == true;
}
