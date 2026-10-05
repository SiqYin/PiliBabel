import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'dart:async';

import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/common/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/utils/android/android_helper.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class DLNAPage extends StatefulWidget {
  const DLNAPage({super.key});

  @override
  State<DLNAPage> createState() => _DLNAPageState();
}

class _DLNAPageState extends State<DLNAPage> {
  final _searcher = DLNAManager();
  final Map<String, DLNADevice> _deviceList = {};
  late final _url = Get.parameters['url']!;
  late final _title = Get.parameters['title'];

  Timer? _timer;
  bool _isSearching = false;

  /// 搜索过程中的异常（socket 失败等）。与「搜完没设备」区分开，
  /// 否则用户只会看到一个误导性的「没有设备」。
  String? _searchError;

  DLNADevice? _lastDevice;
  String? _lastDeviceKey;

  @override
  void initState() {
    super.initState();
    _onSearch(isInit: true);
  }

  Future<void> _onSearch({bool isInit = false}) async {
    if (_isSearching) return;
    _isSearching = true;
    _searchError = null;
    if (!isInit && mounted) {
      _lastDevice = null;
      _deviceList.clear();
      setState(() {});
    }

    // 组播锁由原生侧持有：MainActivity 在 onStart/onStop 之间持锁，覆盖整个前台
    // 生命周期。这里只在搜索开始时确认一次，失败也不阻断——搜索不到设备时
    // 错误提示里会给出排查线索。
    unawaited(PiliAndroidHelper.acquireMulticastLock());

    try {
      // reusePort:上一次 stop() 到这次 bind(1900) 之间旧 socket 可能尚未释放，
      // 不允许复用端口会直接抛 SocketException(Address already in use)，
      // 那样连重试入口都进不去。
      final deviceManager = await _searcher.start(reusePort: true);
      if (!mounted) return;

      // 上一轮的 timer 必须先取消，否则旧回调会提前 stop 掉本轮搜索。
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 20), _stopSearch);

      await for (final deviceList in deviceManager.devices.stream) {
        if (mounted) {
          _deviceList.addAll(deviceList);
          setState(() {});
        }
      }
    } catch (e) {
      // 以前这里没有 try/catch：start() 一旦抛异常（端口占用最常见），
      // 后面的代码全被跳过，_isSearching 永远卡在 true，界面永久转圈、
      // 连「没有设备」和重试按钮都不会出现。
      if (kDebugMode) debugPrint('DLNASearch failed: $e');
      if (mounted) {
        setState(() => _searchError = uiTx('投屏搜索失败，请重试'));
      }
    } finally {
      // 无论成功、失败还是页面已卸载，都要把状态复位，否则再也点不动重试。
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _stopSearch() {
    _searcher.stop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _searcher.stop();
    // 组播锁由原生侧管理，退出页面不释放：锁要覆盖整个前台生命周期，
    // 在这里释放会让「离开投屏页后再次进入」失去组播。
    _lastDevice = null;
    _lastDeviceKey = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return SimpleScaffold(
      appBar: AppBar(
        title: Text(uiTx('投屏')),
        actions: [
          IconButton(
            tooltip: uiTx('搜索'),
            onPressed: _onSearch,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          if (_isSearching) linearLoading,
          ViewSliverSafeArea(sliver: _buildBody(colorScheme)),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (!_isSearching && _deviceList.isEmpty) {
      // 区分两种失败：socket 异常 vs 确实没搜到设备。后者多半是网络隔离或
      // 电视没开 DLNA，补一句可操作的提示比光说「没有设备」有用。
      // HttpError 只有 errMsg，所以提示直接拼在消息里。
      final msg = _searchError ??
          '${uiTx('没有找到设备')}\n'
              '${uiTx('请确认电视已开启投屏，并与手机处于同一 Wi-Fi；部分路由器开启了设备隔离，也会导致搜不到。')}';
      return HttpError(
        errMsg: msg,
        onReload: _onSearch,
        btnText: uiTx('重试'),
      );
    }
    if (_deviceList.isNotEmpty) {
      final keys = _deviceList.keys.toList();
      return SliverList.builder(
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          final device = _deviceList[key]!;
          final isCurr = key == _lastDeviceKey;
          return ListTile(
            title: Text(
              device.info.friendlyName,
              style: isCurr ? TextStyle(color: colorScheme.primary) : null,
            ),
            subtitle: Text(key),
            onTap: () async {
              if (isCurr) return;
              _lastDevice?.pause();
              _lastDevice = device;
              _lastDeviceKey = key;
              setState(() {});
              await device.setUrl(_url, title: _title ?? '');
              await device.play();
            },
          );
        },
      );
    }
    return const SliverToBoxAdapter();
  }
}
