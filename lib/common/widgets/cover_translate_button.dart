import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 视频封面左下角的「翻译封面」按钮。
///
/// 点一下拿封面图去问内置多模态模型（Index-Translate 已支持识图），
/// 用当前界面语言说清楚封面上写了什么；图上没有文字就回一句「未识别到文字」。
/// 只在点击时发请求，不预取，所以列表里刷再多封面也不会有额外开销。
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
    final cover = widget.cover;
    if (cover == null || cover.isEmpty || _loading) return;
    if (!Get.isRegistered<UiTranslateService>()) return;
    setState(() => _loading = true);
    final text = await UiTranslateService.to.describeImage(cover);
    if (!mounted) return;
    setState(() => _loading = false);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Obx(() => Text(uiTx('封面翻译'))),
        content: SingleChildScrollView(
          child: Obx(() => Text(text ?? uiTx('封面翻译失败，请稍后重试'))),
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
      child: Obx(
        () => Tooltip(
          message: uiTx('翻译封面'),
          child: GestureDetector(
            onTap: _onTap,
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
