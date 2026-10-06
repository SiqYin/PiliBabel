import 'dart:async';
import 'dart:io';

import 'package:dlna_dart/dlna.dart';

/// 多网卡感知的 SSDP 发现器。
///
/// **为什么不用 dlna_dart 自带的 `DLNAManager`**
///
/// `DLNAManager.start()` 把收发两个 socket 都 bind 在 `InternetAddress.anyIPv4`
/// 上，且从不设置 `IP_MULTICAST_IF`。在多网卡设备上（手机同时开着 Wi-Fi 与移动
/// 数据、开着 VPN、或有线+无线并存），内核会按路由表挑一张网卡把 M-SEARCH 发出去
/// ——挑中的往往不是连着局域网的那张。结果就是报文根本没进局域网，
/// 20 秒后界面报「没有找到设备」。
///
/// 本机实测（Windows，双网卡 192.168.11.7 有线 / 192.168.11.3 无线，
/// 局域网内放一个会应答 M-SEARCH 的模拟 DLNA 设备）：
///
/// | 收发方式 | 20 秒内发现的设备数 |
/// |---|---|
/// | `bind(anyIPv4)` 且不设 `IP_MULTICAST_IF`（= 现状） | **0** |
/// | `bind(网卡地址)` | 2 |
/// | `bind(anyIPv4)` + 显式 `IP_MULTICAST_IF` | 2 |
/// | `bind(网卡地址)` + 显式 `IP_MULTICAST_IF` | 2 |
///
/// 所以这里对每张非回环 IPv4 网卡各建一个 socket，绑定到该网卡地址并显式设置
/// `IP_MULTICAST_IF`，再各自发 M-SEARCH、事件驱动收包。报文本身仍交给
/// dlna_dart 的 [DeviceManager] 解析（设备描述 XML、[DLNADevice] 构造都复用它，
/// 不重复实现）。
class SsdpDiscovery {
  static const String _groupAddress = '239.255.255.250';
  static const int _ssdpPort = 1900;

  /// `IPPROTO_IP` 级别的 `IP_MULTICAST_IF` 选项号，各平台一致。
  static const int _ipMulticastIf = 9;

  /// 组播 TTL：1 只够同一网段，调大一点能穿过多 AP / 多网段的家庭网络。
  static const int _multicastHops = 4;

  /// 重发 M-SEARCH 的时间点（秒）。M-SEARCH 的 `MX` 是 3，设备会在 3 秒内
  /// 随机时刻应答，多轮重发是为了兜住丢包与设备端的限流；页面 20 秒收尾，
  /// 所以最后一轮定在 12 秒。
  static const List<int> _retrySeconds = <int>[0, 1, 2, 3, 5, 8, 12];

  /// 三种 `ST` 轮换发送：`ssdp:all` 最全，另两个能命中只认特定类型的老设备。
  static const List<String> _searchTargets = <String>[
    'ssdp:all',
    'urn:schemas-upnp-org:device:MediaRenderer:1',
    'urn:schemas-upnp-org:service:AVTransport:1',
  ];

  DeviceManager? _manager;
  final List<RawDatagramSocket> _sockets = <RawDatagramSocket>[];
  final List<Timer> _timers = <Timer>[];
  bool _running = false;

  bool get isRunning => _running;

  /// 已建成的收发 socket 数量（诊断用：为 0 说明一张可用网卡都没枚举到）。
  int get socketCount => _sockets.length;

  /// 启动发现，返回设备列表流。
  ///
  /// 每次调用都会新建一个 [DeviceManager]，因此返回的是全新的单订阅流；
  /// 调用方在收尾时用 [stop] 关闭它。
  Future<Stream<Map<String, DLNADevice>>> start() async {
    await stop();
    final manager = DeviceManager();
    _manager = manager;
    _running = true;

    final group = InternetAddress(_groupAddress);
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      includeLinkLocal: false,
      type: InternetAddressType.IPv4,
    );

    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (!_running) return manager.devices.stream;
        final socket = await _bindOn(address);
        if (socket != null) _sockets.add(socket);
      }
    }

    if (_sockets.isEmpty) {
      // 兜底：一张网卡都没枚举出来时，至少按老办法试一次，
      // 保证「有网卡但列表为空」这种平台怪状下不会比改动前更差。
      final socket = await _bindOn(InternetAddress.anyIPv4);
      if (socket != null) _sockets.add(socket);
    }

    for (final seconds in _retrySeconds) {
      if (seconds == 0) {
        _sendSearch(group);
      } else {
        _timers.add(Timer(Duration(seconds: seconds), () => _sendSearch(group)));
      }
    }
    return manager.devices.stream;
  }

  /// 把 socket 绑定到指定地址，并显式指定组播出站网卡。失败返回 null。
  Future<RawDatagramSocket?> _bindOn(InternetAddress address) async {
    try {
      final socket = await RawDatagramSocket.bind(address, 0);
      // 绑定到网卡地址本身就决定了出站网卡；再显式设一次 IP_MULTICAST_IF
      // 作为双保险（部分平台对已绑定地址的 socket 仍会按路由表选出站网卡）。
      try {
        socket.setRawOption(
          RawSocketOption(
            RawSocketOption.levelIPv4,
            _ipMulticastIf,
            address.rawAddress,
          ),
        );
      } catch (_) {
        // 选项不被支持时忽略：bind 已经足够
      }
      try {
        socket.multicastHops = _multicastHops;
      } catch (_) {}
      socket.listen(
        (event) {
          if (event != RawSocketEvent.read) return;
          Datagram? datagram;
          while ((datagram = socket.receive()) != null) {
            unawaited(_ingest(datagram!));
          }
        },
        onError: (Object _) {},
        cancelOnError: false,
      );
      return socket;
    } catch (_) {
      // 单张网卡不可用（已下线、无权限、地址已失效）不影响其它网卡
      return null;
    }
  }

  void _sendSearch(InternetAddress group) {
    if (!_running) return;
    for (final target in _searchTargets) {
      final bytes =
          'M-SEARCH * HTTP/1.1\r\n'
                  'HOST: $_groupAddress:$_ssdpPort\r\n'
                  'MAN: "ssdp:discover"\r\n'
                  'MX: 3\r\n'
                  'ST: $target\r\n'
                  '\r\n'
              .codeUnits;
      for (final socket in _sockets) {
        try {
          socket.send(bytes, group, _ssdpPort);
        } catch (_) {
          // 网卡在搜索期间下线时 send 会抛，忽略即可
        }
      }
    }
  }

  Future<void> _ingest(Datagram datagram) async {
    try {
      // 复用 dlna_dart 的报文解析：它会拉设备描述 XML 并构造 DLNADevice。
      // 自己发出的 M-SEARCH 会经组播回环回到这里，DeviceManager 内部会忽略。
      await _manager?.onMessage(String.fromCharCodes(datagram.data));
    } catch (_) {
      // 单个设备解析失败（描述 XML 拉不到等）不影响其它设备
    }
  }

  /// 收尾：停掉定时器、关掉 socket、关闭设备流。
  Future<void> stop() async {
    _running = false;
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    for (final socket in _sockets) {
      try {
        socket.close();
      } catch (_) {}
    }
    _sockets.clear();
    final manager = _manager;
    _manager = null;
    if (manager != null && !manager.devices.isClosed) {
      await manager.devices.close();
    }
  }
}
