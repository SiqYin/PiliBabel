abstract final class HttpString {
  static const String baseUrl = 'https://www.bilibili.com';
  static const String apiBaseUrl = 'https://api.bilibili.com';
  static const String tUrl = 'https://api.vc.bilibili.com';
  static const String appBaseUrl = 'https://app.bilibili.com';

  /// 官方原生 gRPC 主机。实测（HTTP/2 与 HTTP/1.1 各打一次
  /// /bilibili.app.view.v1.View/View）：grpc.biliapi.net 与 app.bilibili.com
  /// 都直接回 application/grpc + grpc-status，可互为备份；api.bilibili.com
  /// 对 gRPC 路径是 404（它的接口面是 Web 那套），不是等价主机。
  static const String grpcBaseUrl = 'https://grpc.biliapi.net';

  /// gRPC 接口的主备主机：官方是「原生 gRPC 走 grpc.biliapi.net，Failover 走
  /// app.bilibili.com」，这里保持同样的顺序，实际顺序再按实测健康度调整。
  static const List<String> grpcHosts = [grpcBaseUrl, appBaseUrl];

  /// A2.1 主机清单表：主机 / 用途 / 是否走 gRPC / 是否参与故障切换。
  /// 这份表是「主机清单」的唯一登记处：新增主机先在这里写清用途，
  /// 再决定它要不要进 [grpcHosts] 这类参与切换的列表。
  static const List<HttpHostInfo> hostTable = [
    HttpHostInfo(
      'grpc.biliapi.net',
      '官方原生 gRPC 主机（动态、播放、评论等 App 侧接口）',
      grpc: true,
      switchable: true,
    ),
    HttpHostInfo(
      'app.bilibili.com',
      'App 侧主机：gRPC 的 Failover，同时挂 REST 接口（首页 feed 等）',
      grpc: true,
      switchable: true,
    ),
    HttpHostInfo(
      'api.bilibili.com',
      'Web 侧接口主机（gRPC 路径是 404，不参与 gRPC 切换）',
    ),
    HttpHostInfo('api.live.bilibili.com', '直播接口'),
    HttpHostInfo('api.vc.bilibili.com', '私信/会话接口'),
    HttpHostInfo('passport.bilibili.com', '账号登录'),
    HttpHostInfo('message.bilibili.com', '消息接口'),
    HttpHostInfo('t.bilibili.com', '动态分享页'),
    HttpHostInfo('space.bilibili.com', '空间'),
    HttpHostInfo('account.bilibili.com', '账号相关'),
    HttpHostInfo('mall.bilibili.com', '会员购'),
    HttpHostInfo('www.bilibili.com', 'Web 主站'),
  ];

  /// 该主机是否属于可互换的 gRPC 主机组。
  static bool isGrpcHost(String host) =>
      host == 'grpc.biliapi.net' || host == 'app.bilibili.com';

  /// 参与健康度统计与主备排序的主机。直链 CDN 主机不参与：它们由服务端下发、
  /// 与签名绑定，既不换主机也不需要排序。
  static bool isPolicyHost(String host) =>
      host == 'grpc.biliapi.net' ||
      host == 'app.bilibili.com' ||
      host == 'api.bilibili.com';

  /// gRPC 请求（content-type: application/grpc）的备选主机；非 gRPC 返回 null。
  ///
  /// 必须按请求类型区分：app.bilibili.com 上同时挂着 REST 接口
  /// （/x/v2/feed/index、/x/v2/view/like 等），这些接口在 grpc.biliapi.net
  /// 上不存在，换过去只会更糟。
  static List<String>? grpcAlternatives(
    String host, {
    required bool isGrpc,
  }) => isGrpc && isGrpcHost(host) ? grpcHosts : null;
  static const String liveBaseUrl = 'https://api.live.bilibili.com';
  static const String passBaseUrl = 'https://passport.bilibili.com';
  static const String messageBaseUrl = 'https://message.bilibili.com';
  static const String dynamicShareBaseUrl = 'https://t.bilibili.com';
  static const String opusBaseUrl = 'https://www.bilibili.com/opus';
  static const String spaceBaseUrl = 'https://space.bilibili.com';
  static const String accountBaseUrl = 'https://account.bilibili.com';
  static const String mallBaseUrl = 'https://mall.bilibili.com';

  static const String sponsorBlockBaseUrl = 'https://www.bsbsb.top';
}

/// 超时与连接参数（A3.1 / A3.2）：分层设置，长传输单独放宽。
abstract final class HttpTimeout {
  /// 连接超时：TCP + TLS 握手
  static const Duration connect = Duration(seconds: 10);

  /// 响应间隔超时：两次收到数据之间允许的最长间隔
  static const Duration receive = Duration(seconds: 10);

  /// 大体积传输（图片、下载、字幕）的间隔超时：放宽，避免大文件被中途掐断
  static const Duration receiveLarge = Duration(seconds: 30);

  /// 发送超时：POST 体积较大时用
  static const Duration send = Duration(seconds: 30);

  /// 下载/大文件流的间隔超时：断点续传要能容忍慢速链路
  static const Duration download = Duration(seconds: 20);

  /// 单主机并发上限：超出排队
  static const int maxConcurrentPerHost = 8;

  /// HTTP/1.1 每主机连接上限
  static const int maxConnectionsPerHost = 16;

  /// HTTP/1.1 空闲连接回收时间
  static const Duration idle = Duration(seconds: 15);
}


/// A2.1 主机清单表的行：用途、是否走 gRPC、是否参与故障切换。
class HttpHostInfo {
  const HttpHostInfo(
    this.host,
    this.purpose, {
    this.grpc = false,
    this.switchable = false,
  });

  final String host;
  final String purpose;
  final bool grpc;
  final bool switchable;
}
