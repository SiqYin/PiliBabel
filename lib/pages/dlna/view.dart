import 'dart:async';

import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/common/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/pages/dlna/ssdp.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
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
  final _discovery = SsdpDiscovery();
  final Map<String, DLNADevice> _deviceList = {};
  StreamSubscription<Map<String, DLNADevice>>? _sub;
  late final _url = Get.parameters['url']!;
  late final _title = Get.parameters['title'];

  Timer? _timer;
  bool _isSearching = false;

  /// 搜索过程中的异常（socket 失败等）。与「搜完没设备」区分开，
  /// 否则用户只会看到一个误导性的「没有设备」。
  String? _searchError;

  DLNADevice? _lastDevice;
  String? _lastDeviceKey;

  /// 搜索超时。20 秒足够跑完 7 轮 M-SEARCH（最后一轮在第 12 秒）。
  static const _searchTimeout = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    _onSearch(isInit: true);
  }

  Future<void> _onSearch({bool isInit = false}) async {
    if (_isSearching) return;
    _searchError = null;
    if (mounted) {
      setState(() {
        _isSearching = true;
        if (!isInit) {
          _lastDevice = null;
          _deviceList.clear();
        }
      });
    }

    // 组播锁由原生侧持有：MainActivity 在 onStart/onStop 之间持锁，覆盖整个前台
    // 生命周期。这里只在搜索开始时确认一次，失败也不阻断——搜索不到设备时
    // 错误提示里会给出排查线索。
    unawaited(PiliAndroidHelper.acquireMulticastLock());

    await _sub?.cancel();
    _sub = null;

    try {
      final stream = await _discovery.start();
      if (!mounted) {
        unawaited(_discovery.stop());
        return;
      }
      _sub = stream.listen(
        (devices) {
          if (!mounted) return;
          setState(() {
            _deviceList
              ..clear()
              ..addAll(devices);
          });
        },
        onError: (Object e) {
          if (kDebugMode) debugPrint('DLNA device stream error: $e');
        },
      );
      // 收尾只有一个入口：超时。不依赖「设备流结束」——流是设备持续上报的，
      // 旧实现把状态复位写在 await for 的 finally 里，一旦流不结束就永远转圈。
      _timer?.cancel();
      _timer = Timer(_searchTimeout, _finishSearch);
    } catch (e) {
      if (kDebugMode) debugPrint('DLNASearch failed: $e');
      _searchError = uiTx('投屏搜索失败，请重试');
      _finishSearch();
    }
  }

  /// 结束一轮搜索：停定时器、关 socket、复位状态。
  void _finishSearch() {
    _timer?.cancel();
    _timer = null;
    unawaited(_discovery.stop());
    if (mounted) {
      setState(() => _isSearching = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    unawaited(_sub?.cancel());
    _sub = null;
    unawaited(_discovery.stop());
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
            onPressed: _isSearching ? null : _onSearch,
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
    if (_isSearching && _deviceList.isEmpty) {
      // 搜索中也要有明确文案：旧实现在这里返回空 sliver，配上顶部的
      // 进度条就是「一直加载、什么都不显示」。
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              Text(
                uiTx('正在搜索投屏设备…'),
                style: TextStyle(color: colorScheme.outline),
              ),
              const SizedBox(height: 8),
              Text(
                uiTx('请确认电视已开启投屏，并与手机处于同一 Wi-Fi。'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (!_isSearching && _deviceList.isEmpty) {
      // 区分两种失败：socket 异常 vs 确实没搜到设备。后者多半是网络隔离或
      // 电视没开 DLNA，补一句可操作的提示比光说「没有设备」有用。
      // HttpError 只有 errMsg，所以提示直接拼在消息里。
      final msg =
          _searchError ??
          '${uiTx('没有找到设备')}\n'
              '${uiTx('请确认电视已开启投屏，并与手机处于同一 Wi-Fi；部分路由器开启了设备隔离，也会导致搜不到。')}';
      return HttpError(
        errMsg: msg,
        onReload: _onSearch,
        btnText: uiTx('重试'),
      );
    }
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
}
