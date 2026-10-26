import 'dart:io';

import 'package:dio/dio.dart';

/// 网络错误分类（A5.1）：把 dio 抛出来的各种异常收敛成少数几类，让重试、换主机、
/// 换解析、提示各走各的策略，而不是一律「请求失败」。
enum NetErrorKind {
  /// 本机没有网络 / 网络正在切换
  noNetwork,

  /// 域名解析失败
  dns,

  /// 连接超时（TCP / TLS 握手没完成）
  connectTimeout,

  /// 首包超时（连上了但迟迟没有响应）
  receiveTimeout,

  /// 发送超时
  sendTimeout,

  /// 连接被重置或中断
  connection,

  /// 证书问题
  tls,

  /// 风控拦截（412）
  riskControl,

  /// 限流（429）
  rateLimited,

  /// 服务端错误（5xx）
  server,

  /// 请求被取消
  cancelled,

  unknown,
}

abstract final class NetError {
  /// 从 dio 异常分类。有响应就先按状态码判：能拿到响应说明网络本身是通的。
  static NetErrorKind classify(DioException err) {
    final status = err.response?.statusCode;
    if (status != null) return classifyStatus(status);
    final error = err.error;
    if (error is SocketException) {
      final message =
          '${error.message} ${error.osError?.message ?? ''}'.toLowerCase();
      if (message.contains('failed host lookup') ||
          message.contains('nodename nor servname') ||
          message.contains('no address associated') ||
          message.contains('temporary failure in name resolution')) {
        return NetErrorKind.dns;
      }
      return NetErrorKind.connection;
    }
    if (error is HandshakeException) return NetErrorKind.tls;
    if (error is HttpException) return NetErrorKind.connection;
    return switch (err.type) {
      DioExceptionType.connectionTimeout => NetErrorKind.connectTimeout,
      DioExceptionType.sendTimeout => NetErrorKind.sendTimeout,
      DioExceptionType.receiveTimeout => NetErrorKind.receiveTimeout,
      DioExceptionType.transformTimeout => NetErrorKind.receiveTimeout,
      DioExceptionType.badCertificate => NetErrorKind.tls,
      DioExceptionType.badResponse => NetErrorKind.unknown,
      DioExceptionType.cancel => NetErrorKind.cancelled,
      DioExceptionType.connectionError => NetErrorKind.connection,
      DioExceptionType.unknown => NetErrorKind.unknown,
    };
  }

  static NetErrorKind classifyStatus(int status) {
    if (status == 412) return NetErrorKind.riskControl;
    if (status == 429) return NetErrorKind.rateLimited;
    if (status >= 500) return NetErrorKind.server;
    return NetErrorKind.unknown;
  }

  /// 值得原样重试的：连接层问题 + 风控 / 限流 / 服务端错误。
  static bool isRetryable(NetErrorKind kind) => switch (kind) {
    NetErrorKind.connectTimeout ||
    NetErrorKind.receiveTimeout ||
    NetErrorKind.sendTimeout ||
    NetErrorKind.connection ||
    NetErrorKind.dns ||
    NetErrorKind.riskControl ||
    NetErrorKind.rateLimited ||
    NetErrorKind.server =>
      true,
    _ => false,
  };

  /// 值得换主机再试的：这台连不上或解析不到，换一台可能就好。
  /// 风控 / 限流是服务端按身份判的，换主机没有意义。
  static bool isHostSwitchable(NetErrorKind kind) => switch (kind) {
    NetErrorKind.dns ||
    NetErrorKind.connectTimeout ||
    NetErrorKind.connection =>
      true,
    _ => false,
  };

  /// 属于「网络问题」：断网恢复后值得自动补拉当前页面。
  static bool isNetworkKind(NetErrorKind kind) => switch (kind) {
    NetErrorKind.noNetwork ||
    NetErrorKind.dns ||
    NetErrorKind.connectTimeout ||
    NetErrorKind.receiveTimeout ||
    NetErrorKind.sendTimeout ||
    NetErrorKind.connection =>
      true,
    _ => false,
  };
}
