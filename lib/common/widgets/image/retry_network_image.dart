import 'dart:async';

import 'package:PiliPlus/utils/net_status.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:material_ui/material_ui.dart';

/// 首载失败会自动重试的网络图片。
///
/// 背景：[CachedNetworkImage] 的 errorBuilder 是终态——一张图第一次没拉下来，
/// 只要这个 widget 不被重建，它就一直是占位块，用户只能靠下拉刷新、切页或重进
/// App 才能重新触发加载。图片域（i0.hdslb.com 等）在海外/弱网下抖动一次，
/// 表现就是「封面、UP 主头像、动态图、表情包随机加载不出来」。
///
/// 这里在 errorBuilder 里挂一次退避重试：先清掉这次失败的缓存条目（内存
/// ImageCache + 磁盘缓存），再用变化的 key 重建整个 CachedNetworkImage 子树，
/// 逼它重新走一遍网络。次数用尽后落回占位图；断网时不空转，等网络恢复广播
/// （[NetStatus.restored]）再重试。
class RetryNetworkImage extends StatefulWidget {
  const RetryNetworkImage({
    super.key,
    required this.imageUrl,
    required this.placeholder,
    required this.errorPlaceholder,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.memCacheWidth,
    this.memCacheHeight,
    this.fadeOutDuration = const Duration(milliseconds: 120),
    this.fadeInDuration = const Duration(milliseconds: 120),
    this.filterQuality = FilterQuality.low,
    this.colorBlendMode,
    this.color,
    this.maxRetries = 2,
  });

  final String imageUrl;

  /// 加载中占位（也是磁盘缓存未命中时的第一帧）。
  final ValueGetter<Widget> placeholder;

  /// 重试用尽后的最终占位。
  final ValueGetter<Widget> errorPlaceholder;

  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Duration fadeOutDuration;
  final Duration fadeInDuration;
  final FilterQuality filterQuality;
  final BlendMode? colorBlendMode;
  final Color? color;

  /// 最多重试几次（不含首次加载）。默认 2 次，退避 600ms / 1200ms。
  final int maxRetries;

  @override
  State<RetryNetworkImage> createState() => _RetryNetworkImageState();
}

class _RetryNetworkImageState extends State<RetryNetworkImage> {
  /// 已安排过的重试次数。同时用作子树的 key：值一变，CachedNetworkImage
  /// 连同它内部的 OctoImage 一起重建，ImageProvider 才会被重新 resolve。
  /// 只 evict 缓存而不换 key 是不行的——provider 的 == 只比 url/scale，
  /// 而 ImageStreamCompleter 一旦以错误结束，会把这个错误原样回放给之后
  /// 每一个新监听者，不重建就一直读同一个错误。
  int _attempt = 0;

  bool _retryScheduled = false;
  bool _exhausted = false;
  Timer? _timer;

  /// 只有「失败过」的图才需要监听网络恢复。
  ///
  /// 首页一屏就是几十个封面、头像、表情，全都在 initState 里往
  /// [NetStatus.restored] 挂监听的话，一个页面就有上百个监听器，且绝大多数
  /// 永远不会用到。改成首次进 errorBuilder 时才挂，成功后立刻摘掉。
  bool _listeningNetRestore = false;

  void _startListeningNetRestore() {
    if (_listeningNetRestore) return;
    _listeningNetRestore = true;
    NetStatus.restored.addListener(_onNetRestored);
  }

  void _stopListeningNetRestore() {
    if (!_listeningNetRestore) return;
    _listeningNetRestore = false;
    NetStatus.restored.removeListener(_onNetRestored);
  }

  @override
  void dispose() {
    _stopListeningNetRestore();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(RetryNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _timer?.cancel();
      _attempt = 0;
      _retryScheduled = false;
      _exhausted = false;
      _stopListeningNetRestore();
    }
  }

  /// 网络恢复：此前失败过的图（含断网时挂起的）全部重新来一次。
  void _onNetRestored() {
    if (!mounted) return;
    if (_attempt == 0 && !_exhausted && !_retryScheduled) return;
    _timer?.cancel();
    // 断网期间失败留下的错误 completer 同样要先摘掉，否则「恢复」后第一次
    // resolve 还是立刻拿到那个旧错误，白等一轮退避。
    unawaited(
      _evictImageCache().whenComplete(() {
        if (!mounted) return;
        setState(() {
          _attempt = 0;
          _retryScheduled = false;
          _exhausted = false;
        });
      }),
    );
  }

  void _scheduleRetry() {
    _startListeningNetRestore();
    if (_retryScheduled || _exhausted) return;
    if (_attempt >= widget.maxRetries) {
      _exhausted = true;
      return;
    }
    _retryScheduled = true;
    // 断网时退避拉长到 5 秒（空转没意义），网络恢复广播会把它提前触发。
    // 不能干脆不排：一旦恢复广播因为任何原因没到（监听注册晚于恢复、
    // 平台通道没上报），这张图就永久卡在占位图上——那正是要修的症状。
    final delay = NetStatus.online.value
        ? Duration(milliseconds: 600 * (1 << _attempt))
        : const Duration(seconds: 5);
    _timer?.cancel();
    _timer = Timer(delay, _doRetry);
  }

  Future<void> _doRetry() async {
    _retryScheduled = false;
    if (!mounted) return;
    try {
      await _evictImageCache();
    } catch (e) {
      if (kDebugMode) debugPrint('RetryNetworkImage evict failed: $e');
    }
    if (!mounted) return;
    setState(() {
      _attempt++;
    });
  }

  /// 把这张图在**两层**缓存里都清掉。
  ///
  /// 只清磁盘是不够的，甚至只清内层 ImageProvider 的键也不够：
  /// [CachedNetworkImage] 内部把 provider 交给 OctoImage，OctoImage 只要拿到
  /// memCacheWidth/Height 就会把它包成 [ResizeImage]；而 [ResizeImage] 的缓存
  /// 键是私有的 ResizeImageKey，图片库出错时回调的
  /// `imageCache.evict(内层 key)` 命中不了外层这个键。
  ///
  /// 更关键的是 Flutter 的 [ImageCache.putIfAbsent]：它给 completer 挂的监听
  /// 只有 onImage、没有 onError，所以一张图**加载失败时 pending 条目不会自动
  /// 移除**，那个已经带错误的 completer 会一直回放给之后每一个相同 key 的请求。
  /// 这就是「第一次没加载出来，之后怎么等都不出来，只有刷新才好」的机制。
  /// 因此重试前必须显式 evict，外层 ResizeImage 键也要一起清。
  Future<void> _evictImageCache() async {
    // 磁盘缓存 + 内层 provider 键
    await CachedNetworkImage.evictFromCache(widget.imageUrl);
    // 外层 ResizeImage 键（OctoImage 按 memCacheWidth/Height 包出来的那层）
    final width = widget.memCacheWidth;
    final height = widget.memCacheHeight;
    if (width != null || height != null) {
      await ResizeImage(
        CachedNetworkImageProvider(widget.imageUrl),
        width: width,
        height: height,
      ).evict();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      key: ValueKey<int>(_attempt),
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      memCacheWidth: widget.memCacheWidth,
      memCacheHeight: widget.memCacheHeight,
      fit: widget.fit,
      alignment: widget.alignment,
      fadeOutDuration: widget.fadeOutDuration,
      fadeInDuration: widget.fadeInDuration,
      filterQuality: widget.filterQuality,
      placeholder: (ctx, _) => widget.placeholder(),
      errorBuilder: (ctx, _, _) {
        _scheduleRetry();
        return widget.errorPlaceholder();
      },
      colorBlendMode: widget.colorBlendMode,
      color: widget.color,
    );
  }
}
