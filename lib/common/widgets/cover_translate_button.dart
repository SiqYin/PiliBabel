import 'dart:async';

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
/// 弹窗与更新弹窗同一套写法（SmartDialog + AlertDialog + ColorScheme），
/// 主题跟随 App；失败时把真实错误原文显示出来，便于定位。
class CoverTranslateButton extends StatefulWidget {
  const CoverTranslateButton({
    super.key,
    required this.cover,
    this.bottom = 6,
    this.left = 7,
    this.isLongPic = false,
  });

  final String? cover;
  final double bottom;
  final double left;
  /// 长图（高度/宽度超过阈值、界面上带「长图」角标的那种）走带进度的弹窗
  final bool isLongPic;

  @override
  State<CoverTranslateButton> createState() => _CoverTranslateButtonState();
}

class _CoverTranslateButtonState extends State<CoverTranslateButton> {
  bool _loading = false;

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
    setState(() => _loading = true);
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
            .describeImage(cover)
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
      // 用 uiTxP 模板而不是先插值再 uiTx：否则每个不同的错误内容都会变成一条新词条
      msg = await uiTxPAsync('请求出错：{0}', [e]);
    }

    if (mounted) {
      setState(() => _loading = false);
    }
    try {
      // 和更新弹窗用同一套写法：SmartDialog + AlertDialog + ColorScheme，
      // 主题跟随 App，不再是自绘的黑底容器
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
              // 两个按钮都用默认主色：给「关闭」单独上灰色会让人以为它不可点
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
    return Positioned(
      left: widget.left,
      bottom: widget.bottom,
      // 视觉上还是原来的小按钮，但点击区是 28x28 的实心命中块，手指不容易点空
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 13,
                      height: 13,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.translate, size: 13, color: Colors.white),
            ),
          ),
        ),
      ),
    );
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
