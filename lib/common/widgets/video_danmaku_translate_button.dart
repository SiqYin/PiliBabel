import 'dart:async';

import 'package:PiliPlus/common/widgets/translate_progress_ring.dart';
import 'package:PiliPlus/services/ui_translate/danmaku_pretranslate_service.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 视频封面左上角的「翻译弹幕」按钮（纯图标，最上层的按钮）。
///
/// 尺寸/状态机与下方字幕、识图两按钮完全一致（见 CardTranslateButtons）：
/// 平常/完成是**小号**（13 图标 → 19 视觉块），点击加载时变**大号**（17 环 → 23），
/// 完成显示绿色小对勾并缩回小号，失败显示刷新图标（点一下重试）。
/// 位置由 CardTranslateButtons 统一编排，本组件只渲染按钮本体。
///
/// 点击 = 拉取该视频全部分段弹幕并整段批量预翻译（译文进持久缓存），
/// 完成后进播放页，弹幕分段命中缓存、出生即译文。
class VideoDanmakuTranslateButton extends StatefulWidget {
  const VideoDanmakuTranslateButton({
    super.key,
    required this.videoKey,
    this.bvid,
    this.aid,
    this.cid,
    this.epId,
    this.seasonId,
  });

  final String videoKey;
  final String? bvid;
  final int? aid;
  final int? cid;

  /// 番剧（pgc）单集只有 epId/seasonId 时靠它们定位。
  final int? epId;
  final int? seasonId;

  @override
  State<VideoDanmakuTranslateButton> createState() =>
      _VideoDanmakuTranslateButtonState();
}

class _VideoDanmakuTranslateButtonState
    extends State<VideoDanmakuTranslateButton> {
  @override
  void initState() {
    super.initState();
    unawaited(DanmakuPretranslateService.ensureInitialized());
  }

  void _start({bool force = false}) {
    SmartDialog.showToast(uiTx('正在翻译弹幕…'));
    DanmakuPretranslateService.start(
      videoKey: widget.videoKey,
      bvid: widget.bvid,
      aid: widget.aid,
      cid: widget.cid,
      epId: widget.epId,
      seasonId: widget.seasonId,
      force: force,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 与字幕按钮同一口径：AI 翻译关着 / 目标简中 / 弹幕翻译开关没开时不渲染。
    if (!DanmakuPretranslateService.needed) return const SizedBox.shrink();
    return Obx(() {
      final state = DanmakuPretranslateService.stateFor(
        videoKey: widget.videoKey,
        cid: widget.cid,
      );
      final theme = Theme.of(context);
      final (label, icon, color) = state.noSource
          ? (
              state.message ?? uiTx('没有可用的弹幕'),
              Icons.speaker_notes_off_outlined,
              Colors.white54,
            )
          : switch (state.phase) {
              DanmakuPretranslatePhase.complete => (
                uiTx('弹幕已预翻译'),
                Icons.check,
                Colors.greenAccent,
              ),
              DanmakuPretranslatePhase.failed => (
                uiTx('重试'),
                Icons.refresh,
                theme.colorScheme.errorContainer,
              ),
              DanmakuPretranslatePhase.preparing => (
                uiTx('准备中'),
                Icons.hourglass_top,
                Colors.white,
              ),
              DanmakuPretranslatePhase.translating => (
                '${(state.progress * 100).round()}%',
                Icons.comment_outlined,
                Colors.white,
              ),
              DanmakuPretranslatePhase.idle => (
                uiTx('翻译弹幕'),
                Icons.comment_outlined,
                Colors.white,
              ),
            };
      final hint = state.message ?? label;
      final isComplete = state.phase == DanmakuPretranslatePhase.complete;
      final isFailed = state.phase == DanmakuPretranslatePhase.failed;
      final isRunning = state.isRunning;
      // 小号 = 13 图标 + 3×2 内边距 = 19；大号（加载中）= 17 环 + 6 = 23。
      final block = isRunning ? 23.0 : 19.0;
      final content = isRunning ? 17.0 : 13.0;
      return Tooltip(
        message: hint,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: state.isRunning
              ? null
              : () => _start(force: isComplete || isFailed || state.noSource),
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
                    key: ValueKey('$isRunning${state.phase}'),
                    width: content,
                    height: content,
                    child: Center(
                      child: isRunning
                          ? TranslateProgressRing(
                              // 翻译阶段有真实进度；获取分段阶段做缓动估计。
                              value:
                                  state.phase ==
                                      DanmakuPretranslatePhase.translating
                                  ? state.progress
                                  : null,
                              color: color,
                              estimateTarget: 0.15,
                              estimateDuration: const Duration(seconds: 8),
                            )
                          : Icon(
                              isComplete ? Icons.check : icon,
                              size: 13,
                              color: isComplete ? Colors.greenAccent : color,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
