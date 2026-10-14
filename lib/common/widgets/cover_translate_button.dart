import 'dart:async';

import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

/// 视频封面左下角的「翻译封面」按钮。
///
/// 点一下拿封面图去问内置多模态模型（Index-Translate 已支持识图），
/// 用当前界面语言说清楚封面上写了什么；图上没有文字就回一句「未识别到文字」。
/// 只在点击时发请求，不预取，所以列表里刷再多封面也不会有额外开销。
///
/// 按下到出结果之间没有任何静默期：手指一落就先弹 toast 并让按钮转圈，
/// 请求成功给译文、失败给原因、超时也给原因，四条路径都会弹对话框。
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
    // 按下立刻给可见反馈，不等请求回来
    SmartDialog.showToast('正在翻译封面…');
    String? text;
    try {
      final cover = widget.cover;
      text = (cover == null || cover.isEmpty)
          ? null
          : await UiTranslateService.to
                .describeImage(cover)
                .timeout(const Duration(seconds: 15));
    } catch (_) {
      text = null;
    }
    if (mounted) {
      setState(() => _loading = false);
    }
    // 用项目里的全局弹窗（SmartDialog），不依赖卡片自身的 context，
    // 列表重建、卡片被回收都不会影响这次点击的结果
    SmartDialog.show(
      builder: (dialogContext) => AlertDialog(
        title: Obx(() => Text(uiTx('封面翻译'))),
        content: SingleChildScrollView(
          child: Text(
            text?.trim().isNotEmpty == true
                ? text!
                : (widget.cover?.isNotEmpty == true
                      ? uiTx('封面翻译失败，请稍后重试')
                      : uiTx('这张封面没有可用的图片地址')),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Obx(() => Text(uiTx('关闭'))),
          ),
        ],
      ),
    );
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
