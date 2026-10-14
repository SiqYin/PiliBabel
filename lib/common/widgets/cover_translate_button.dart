import 'dart:async';

import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

/// 视频封面左下角的「翻译封面」按钮。
///
/// 点一下拿封面图去问内置多模态模型（Index-Translate 已支持识图），
/// 用当前界面语言说清楚封面上写了什么；图上没有文字就回一句「未识别到文字」。
/// 只在点击时发请求，不预取，所以列表里刷再多封面也不会有额外开销。
///
/// 弹窗刻意不用 AlertDialog：它依赖 MaterialLocalizations，而全局弹窗的
/// overlay 不一定提供这套上下文，构造失败时会只剩一个变暗的遮罩、什么都看不到。
/// 这里用不依赖任何 Material 上下文的普通容器，并把真实错误原文显示出来。
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
        final text = await UiTranslateService.to
            .describeImage(cover)
            .timeout(const Duration(seconds: 15));
        msg = (text?.trim().isNotEmpty == true)
            ? text!
            : uiTx('接口没有返回内容（请求已发出，但没有拿到译文）');
      }
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
