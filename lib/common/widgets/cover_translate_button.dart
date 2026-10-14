import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 视频封面左下角的「翻译封面」按钮。
///
/// 点一下拿封面图去问内置多模态模型（Index-Translate 已支持识图），
/// 用当前界面语言说清楚封面上写了什么；图上没有文字就回一句「未识别到文字」。
/// 只在点击时发请求，不预取，所以列表里刷再多封面也不会有额外开销。
///
/// 点击路径上没有任何静默返回：只要手指落在按钮上，就一定会弹出对话框
/// （成功给结果，失败给原因），不会再出现「点了没反应」。
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
    // 先把反馈做出来，后面的任何失败都只影响对话框里的文案
    setState(() => _loading = true);
    String? text;
    try {
      final cover = widget.cover;
      if (cover == null || cover.isEmpty) {
        text = null;
      } else {
        text = await UiTranslateService.to.describeImage(cover);
      }
    } catch (_) {
      text = null;
    }
    if (!mounted) return;
    setState(() => _loading = false);
    await showDialog<void>(
      context: context,
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
      // 32x32 的点击区，比图标本身大一圈，手指不容易点空
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(6),
          ),
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.translate, size: 19, color: Colors.white),
        ),
      ),
    );
  }
}
