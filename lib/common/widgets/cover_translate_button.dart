import 'dart:ui' as ui;

import 'dart:async';

import 'package:PiliPlus/common/widgets/translate_progress_ring.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

/// 视频封面左下角的「翻译封面」按钮。
///
/// 点一下拿封面图去问内置多模态模型（Index-Translate 已支持识图），
/// 先用当前界面语言把图上的文字识别并翻译出来，再顺带描述画面；
/// 图上没有文字就说明未检测到文字并描述画面内容。
/// 视频封面、评论区图片、专栏插图共用这一个按钮；动图由服务层拦掉。
/// 只在点击时发请求，不预取，所以列表里刷再多封面也不会有额外开销。
///
/// 尺寸口径（与上方弹幕/字幕两按钮完全一致，见 CardTranslateButtons）：
/// 平常/完成是**小号**（13 图标 + 3 内边距 = 19 视觉块），点击加载时变**大号**
/// （17 进度环 → 23 视觉块），完成后显示绿色小对勾并缩回小号。
///
/// 进度环是**真实进度**：图片下载阶段用 dio 的字节回调（0~100%，映射到环的
/// 0~55%）；下载完成进入模型推理后没有服务端进度，环按缓动估计从 55% 爬向
/// 95%，拿到译文瞬间跳到 100% 并弹结果弹窗。
///
/// 弹窗与更新弹窗同一套写法（SmartDialog + AlertDialog + ColorScheme），
/// 主题跟随 App；失败时把真实错误原文显示出来，便于定位。
class CoverTranslateButton extends StatefulWidget {
  const CoverTranslateButton({
    super.key,
    required this.cover,
    this.bottom = 6,
    this.left = 7,
    this.isLongPic = false,
    this.loadingNotifier,
    this.embedded = false,
  });

  final String? cover;
  final double bottom;
  final double left;
  /// 长图（高度/宽度超过阈值、界面上带「长图」角标的那种）走带进度的弹窗
  final bool isLongPic;

  /// 加载状态外发（卡片三按钮组据此联动排版）：true = 大号加载中。
  final ValueNotifier<bool>? loadingNotifier;

  /// 嵌入 CardTranslateButtons 时为 true：不再自带 Positioned（位置由
  /// 按钮组统一编排），只渲染按钮本体。
  final bool embedded;

  /// 本会话里已翻译完成的封面：卡片重建（Obx 刷新/滚动回收）不丢完成态。
  static final Set<String> _doneCovers = <String>{};

  @override
  State<CoverTranslateButton> createState() => _CoverTranslateButtonState();
}

class _CoverTranslateButtonState extends State<CoverTranslateButton> {
  bool _loading = false;
  bool _done = false;
  int _downloadPercent = 0;
  bool _downloadDone = false;

  @override
  void initState() {
    super.initState();
    final cover = widget.cover;
    if (cover != null && CoverTranslateButton._doneCovers.contains(cover)) {
      _done = true;
    }
  }

  @override
  void didUpdateWidget(covariant CoverTranslateButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cover = widget.cover;
    if (cover != oldWidget.cover) {
      _done = cover != null && CoverTranslateButton._doneCovers.contains(cover);
      _loading = false;
      _downloadPercent = 0;
      _downloadDone = false;
      widget.loadingNotifier?.value = false;
    }
  }

  Future<void> _onTap() async {
    if (_loading) return;
    final cover0 = widget.cover;
    if (cover0 == null || cover0.isEmpty) {
      SmartDialog.showToast(uiTx('这张封面没有可用的图片地址'));
      return;
    }
    // 长图单独走一条路：文字多、耗时明显长，需要看得见两段进度，也需要能中途关掉
    if (widget.isLongPic) {
      await SmartDialog.show(
        animationType: SmartAnimationType.centerFade_otherSlide,
        builder: (context) => _LongImageTranslateDialog(cover: cover0),
      );
      return;
    }
    setState(() {
      _loading = true;
      _done = false;
      _downloadPercent = 0;
      _downloadDone = false;
    });
    widget.loadingNotifier?.value = true;
    SmartDialog.showToast(uiTx('正在翻译图片…'));

    String msg;
    try {
      final cover = widget.cover;
      if (cover == null || cover.isEmpty) {
        msg = await UiTranslateService.to.txAsync('这张封面没有可用的图片地址');
      } else {
        // 识图比纯文字翻译慢得多（下封面 + 传 base64 图 + 视觉模型推理），
        // dio 那层给的是 60s 发送 / 120s 接收，这里不能掐得比它还早。
        final text = await UiTranslateService.to
            .describeImage(
              cover,
              onDownloadProgress: (percent) {
                if (!mounted) return;
                setState(() => _downloadPercent = percent);
              },
              onDownloadComplete: () {
                if (!mounted) return;
                setState(() => _downloadDone = true);
              },
            )
            .timeout(const Duration(seconds: 120));
        msg = (text?.trim().isNotEmpty == true)
            ? text!
            : await UiTranslateService.to
                .txAsync('接口没有返回内容（请求已发出，但没有拿到译文）');
      }
    } on TimeoutException {
      msg = await UiTranslateService.to.txAsync(
          '请求超时：识图比纯文字翻译慢，网络不好时更明显。可以点左下角「再次检测」重试');
    } catch (e) {
      // 不把原始异常文本送进翻译模型（以前 DioException 原文会被模型"翻译"
      // 成一大段说明书，见 504 截图），这里映射成固定短句再走翻译。
      msg = await UiTranslateService.to.txAsync(_friendlyVisionError(e));
    }

    if (mounted) {
      setState(() {
        _loading = false;
        if (widget.cover != null) {
          _done = true;
          CoverTranslateButton._doneCovers.add(widget.cover!);
        }
      });
    }
    widget.loadingNotifier?.value = false;
    try {
      // 和更新弹窗用同一套写法：SmartDialog + AlertDialog + ColorScheme，主题跟随 App
      await SmartDialog.show(
        animationType: SmartAnimationType.centerFade_otherSlide,
        builder: (context) {
          return AlertDialog(
            title: Text(uiTx('图片翻译')),
            content: SizedBox(
              width: 320,
              child: SingleChildScrollView(
                child: SelectableText(msg),
              ),
            ),
            actions: [
              // 左下角：重新识别一次（关掉当前弹窗后重跑一遍请求）
              TextButton(
                onPressed: () {
                  SmartDialog.dismiss();
                  _onTap();
                },
                child: Text(uiTx('再次检测')),
              ),
              // 右下角：满意就直接关掉
              TextButton(
                onPressed: SmartDialog.dismiss,
                child: Text(uiTx('关闭')),
              ),
            ],
          );
        },
      );
    } catch (e) {
      SmartDialog.showToast(await uiTxPAsync('弹窗失败：{0}', [e]));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 小号 = 13 图标 + 3×2 内边距 = 19；大号（加载中）= 17 环 + 6 = 23。
    final block = _loading ? 23.0 : 19.0;
    final content = _loading ? 17.0 : 13.0;
    final Widget button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: block,
            height: block,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                key: ValueKey(
                  '$_loading$_done$_downloadPercent$_downloadDone',
                ),
                width: content,
                height: content,
                child: Center(
                  child: _loading
                      ? TranslateProgressRing(
                          color: Colors.white,
                          // 下载阶段是真实字节进度（映射到环 0~55%）；
                          // 下载完成进入推理后按缓动估计爬向 95%。
                          value: _downloadDone
                              ? null
                              : (_downloadPercent / 100) * 0.55,
                          estimateTarget: 0.95,
                          estimateDuration: const Duration(seconds: 35),
                        )
                      : Icon(
                          _done ? Icons.check : Icons.translate,
                          size: 13,
                          color: _done ? Colors.greenAccent : Colors.white,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (widget.embedded) {
      return button;
    }
    // RTL：整列贴文字起始侧（镜像后贴右）。图片内容本身不镜像。
    final rtl = Directionality.of(context) == ui.TextDirection.rtl;
    return Positioned(
      left: rtl ? null : widget.left,
      right: rtl ? widget.left : null,
      bottom: widget.bottom,
      child: button,
    );
  }

  /// 把识图链路的异常映射成固定短句：重试已在上游做过（5xx/连接中断各两次
  /// 退避重试），走到这里的都是重试后仍然失败的情况，给用户一句话即可。
  static String _friendlyVisionError(Object e) {
    if (e is DioException) {
      final code = e.response?.statusCode ?? 0;
      if (code >= 500) {
        return '图片翻译服务暂时不可用（HTTP $code），请稍后再试';
      }
      switch (e.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return '连接中断或超时，请检查网络后重试';
        default:
          break;
      }
    }
    final text = e.toString();
    if (text.contains('图片下载失败')) return '封面图片下载失败，请稍后再试';
    if (text.contains('接口返回内容为空')) return '接口没有返回内容，请稍后再试';
    if (text.contains('动图不支持翻译')) return '动图不支持翻译';
    return '图片翻译请求失败，请稍后再试';
  }
}

/// 长图翻译的进度弹窗：两段进度 + 结果 + 关闭。
///
/// 关闭按钮同时取消在途请求 —— 长图可能要等很久，不想等就该能直接走开。
class _LongImageTranslateDialog extends StatefulWidget {
  const _LongImageTranslateDialog({required this.cover});

  final String cover;

  @override
  State<_LongImageTranslateDialog> createState() =>
      _LongImageTranslateDialogState();
}

class _LongImageTranslateDialogState extends State<_LongImageTranslateDialog> {
  final CancelToken _cancel = CancelToken();
  Timer? _tick;
  double _dl = 0;
  double _tx = 0;
  String? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  void dispose() {
    _tick?.cancel();
    if (!_cancel.isCancelled) _cancel.cancel('用户关闭');
    super.dispose();
  }

  Future<void> _run() async {
    // 第二阶段没有服务端进度可读，用一个缓动估计：越接近 95% 走得越慢，
    // 拿到结果再跳到 100%。只是让等待有参照，不假装是服务端报的精确值。
    _tick = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted || _result != null || _error != null) return;
      setState(() => _tx = _tx + (0.95 - _tx) * 0.05);
    });
    try {
      final text = await UiTranslateService.to
          .describeImage(
            widget.cover,
            isLongImage: true,
            cancelToken: _cancel,
            onDownloadProgress: (p) {
              if (mounted) setState(() => _dl = p / 100);
            },
          )
          .timeout(const Duration(seconds: 300));
      // 译文要等：await 必须写在 setState 之外，闭包里不能有 await
      final msg = (text?.trim().isNotEmpty == true)
          ? text!.trim()
          : await UiTranslateService.to
              .txAsync('接口没有返回内容（请求已发出，但没有拿到译文）');
      if (!mounted) return;
      setState(() {
        _dl = 1;
        _tx = 1;
        _result = msg;
      });
    } on TimeoutException {
      final msg = await UiTranslateService.to
          .txAsync('请求超时：长图识图很慢，网络不好时更明显');
      if (mounted) setState(() => _error = msg);
    } catch (e) {
      if (mounted) {
        final msg = await uiTxPAsync('请求出错：{0}', [e]);
        if (mounted) setState(() => _error = msg);
      }
    } finally {
      _tick?.cancel();
    }
  }

  Widget _stage(String label, double v) {
    final value = v.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text('${(value * 100).round()}%'),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(value: value, minHeight: 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final done = _result != null || _error != null;
    return AlertDialog(
      title: Text(uiTx('图片翻译')),
      content: SizedBox(
        width: 320,
        child: done
            ? ConstrainedBox(
                // 译文很长时在弹窗内部滚动，不把弹窗撑出屏幕
                constraints: const BoxConstraints(maxHeight: 360),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: SelectableText(_result ?? _error ?? ''),
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(uiTx('正在翻译长图，时间可能较长，请稍后'))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _stage(uiTx('图片加载'), _dl),
                  const SizedBox(height: 10),
                  _stage(uiTx('文本识别翻译'), _tx),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (!_cancel.isCancelled) _cancel.cancel('用户关闭');
            SmartDialog.dismiss();
          },
          child: Text(uiTx('关闭')),
        ),
      ],
    );
  }
}
