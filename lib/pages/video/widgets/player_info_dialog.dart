import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart' show NativePlayer;

import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/utils.dart';

/// 播放诊断面板：每秒自刷新 + 一键复制。
///
/// 为什么需要它：「卡顿」至少有两种完全不同的病因，界面上却长得一模一样 ——
///  * **取流/带宽侧**：mpv 缓冲被抽干 → `paused-for-cache=yes`、
///    `cache-buffering-state` 掉下去、`cache-speed` 明显小于 `video-bitrate`；
///  * **解码/渲染侧**：缓冲一直很健康（`demuxer-cache-duration` 还剩好几秒），
///    但 `decoder-frame-drop-count` / `frame-drop-count` 在涨。
///
/// 之前三轮猜测（AV1 软解 → `display-resample` → surface 挂载时机）都猜错了，
/// 所以这里不再靠推理定案：把能一锤定音的计数器全摆出来。面板开着播 30 秒，
/// 点「复制全部」发回，一次就能定位到是哪一侧、瓶颈的具体数值是多少。
///
/// 属性名与释义均按 mpv 手册（DOCS/man/input.rst）核对过；读不到的属性
/// （例如纯音频时没有视频）显示 `-`，不影响其余数据。
class PlayerInfoDialog extends StatefulWidget {
  const PlayerInfoDialog({required this.player, super.key});

  final NativePlayer player;

  @override
  State<PlayerInfoDialog> createState() => _PlayerInfoDialogState();
}

class _PlayerInfoDialogState extends State<PlayerInfoDialog> {
  Timer? _timer;

  /// 计数器区块，每秒重算
  String _diag = '';

  /// 原来那批一次性信息（分辨率/轨道/Media 等），也一起重算，
  /// 顺带避免播放页退出、player 已 dispose 时在 build 里抛异常
  String _info = '';

  /// DASH 的 edl:// 里套着两条直链，取第一个 http(s) 主机名即可看出走的是哪条线
  static final RegExp _hostReg = RegExp(r'https?://([^/]+)');

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _p(String name) {
    try {
      final v = widget.player.getProperty(name);
      return v.isEmpty ? '-' : v;
    } catch (_) {
      return '-';
    }
  }

  static String _bytesPerSec(String raw) {
    final v = int.tryParse(raw.trim());
    if (v == null) return raw;
    if (v >= 1048576) return '${(v / 1048576).toStringAsFixed(2)} MB/s';
    if (v >= 1024) return '${(v / 1024).toStringAsFixed(0)} KB/s';
    return '$v B/s';
  }

  void _refresh() {
    final diag = <String>[];
    void sec(String title) => diag.add('── $title ──');
    void row(String key, String value) =>
        diag.add('${key.padRight(24)}$value');

    sec('decode / render');
    row('hwdec-current', _p('hwdec-current'));
    row('current-vo', _p('current-vo'));
    row('vo-configured', _p('vo-configured'));
    row('video-codec', _p('video-codec'));
    row('display-fps', _p('display-fps'));
    row('container-fps', _p('container-fps'));
    row('estimated-vf-fps', _p('estimated-vf-fps'));

    // 判据：卡顿 30 秒后回来对比，只有这几个数在涨才是解码/渲染侧的问题
    sec('dropped frames');
    row('frame-drop-count', _p('frame-drop-count'));
    row('decoder-frame-drop', _p('decoder-frame-drop-count'));
    row('mistimed-frame-count', _p('mistimed-frame-count'));
    row('vo-delayed-frame-count', _p('vo-delayed-frame-count'));

    // 判据：paused-for-cache=yes 或 cache-buffering-state 掉到 100 以下，
    // 且 cache-speed << video-bitrate，就是这条线带不动当前码率
    sec('network / cache');
    row('paused-for-cache', _p('paused-for-cache'));
    row('cache-buffering-state', _p('cache-buffering-state'));
    row('demuxer-cache-duration', _p('demuxer-cache-duration'));
    row('demuxer-cache-idle', _p('demuxer-cache-idle'));
    row('cache-speed', _bytesPerSec(_p('cache-speed')));
    row('video-bitrate', _bytesPerSec(_p('video-bitrate')));
    row('audio-bitrate', _bytesPerSec(_p('audio-bitrate')));
    row('eof-reached', _p('eof-reached'));

    sec('clock');
    row('time-pos', _p('time-pos'));
    row('core-idle', _p('core-idle'));

    final path = _p('path');
    row('line host', _hostReg.firstMatch(path)?.group(1) ?? '-');

    var info = '-';
    try {
      final state = widget.player.state;
      final volume = '${(double.tryParse(_p('volume')) ?? 0).toStringAsFixed(1)}%';
      info = [
        'Resolution      ${state.width}x${state.height}',
        'rate            ${state.rate}',
        'Volume          $volume',
        'VideoParams     ${state.videoParams}',
        'AudioParams     ${state.audioParams}',
        'VideoTrack      ${state.track.video}',
        'AudioTrack      ${state.track.audio}',
        'Media           ${state.playlist}',
      ].join('\n');
    } catch (_) {
      // 播放页已退出：面板还开着但 player 已释放
    }

    if (!mounted) return;
    setState(() {
      _diag = diag.join('\n');
      _info = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final mono = TextStyle(
      fontSize: 11.5,
      height: 1.45,
      color: colorScheme.onSurface,
    );
    return AlertDialog(
      title: Text(uiTx('播放信息')),
      contentPadding: const EdgeInsets.only(top: 16),
      content: Material(
        type: MaterialType.transparency,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                uiTx('数据每秒自动刷新。卡住时点「复制全部」发回，才能定位是缓冲还是解码。'),
                style: TextStyle(fontSize: 12, color: colorScheme.outline),
              ),
              const SizedBox(height: 10),
              SelectableText(_diag, style: mono),
              const Divider(height: 28),
              SelectableText(_info, style: mono),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Utils.copyText('PiliBabel 播放诊断\n\n$_diag\n\n$_info'),
          child: Text(uiTx('复制全部')),
        ),
        TextButton(
          onPressed: Get.back,
          child: Text(
            uiTx('确定'),
            style: TextStyle(color: colorScheme.outline),
          ),
        ),
      ],
    );
  }
}
