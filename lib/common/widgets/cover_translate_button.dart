import 'dart:async';

import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

/// 视频封面左下角的「翻译封面」按钮。
///
/// 点一下拿封面图去问内置多模态模型（Index-Translate 已支持识图），
/// 先用当前界面语言把封面上的文字识别并翻译出来，再顺带描述画面；
/// 图上没有文字就说明未检测到文字并描述画面内容。
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
  });

  final String? cover;
  final double bottom;
  final double left;

  @override
  State<CoverTranslateButton> createState() => _CoverTranslateButtonState();
}

class _CoverTranslateButtonState extends State<CoverTranslateButton> {
  bool _loading = false;

  Future<void> _onTap() async {
    if (_loading) return;
    setState(() => _loading = true);
    SmartDialog.showToast(uiTx('正在翻译封面…'));

    String msg;
    try {
      final cover = widget.cover;
      if (cover == null || cover.isEmpty) {
        msg = uiTx('这张封面没有可用的图片地址');
      } else {
        // 识图比纯文字翻译慢得多（下封面 + 传 base64 图 + 视觉模型推理），
        // dio 那层给的是 60s 发送 / 120s 接收，这里不能掐得比它还早。
        final text = await UiTranslateService.to
            .describeImage(cover)
            .timeout(const Duration(seconds: 60));
        msg = (text?.trim().isNotEmpty == true)
            ? text!
            : uiTx('接口没有返回内容（请求已发出，但没有拿到译文）');
      }
    } on TimeoutException {
      msg = uiTx('请求超时：识图比纯文字翻译慢，网络不好时更明显。'
          '可以点左下角「再次检测」重试');
    } catch (e) {
      // 用 uiTxP 模板而不是先插值再 uiTx：否则每个不同的错误内容都会变成一条新词条
      msg = uiTxP('请求出错：{0}', [e]);
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
          final colorScheme = ColorScheme.of(context);
          return AlertDialog(
            title: Text(uiTx('封面翻译')),
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
                child: Text(
                  uiTx('关闭'),
                  style: TextStyle(color: colorScheme.outline),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      SmartDialog.showToast(uiTxP('弹窗失败：{0}', [e]));
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
