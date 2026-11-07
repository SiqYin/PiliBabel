import 'dart:async';

import 'package:PiliPlus/common/widgets/translate_progress_ring.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translate_service.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_background_service.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 视频封面左下角的「翻译字幕」按钮（纯图标，居中一层）。
///
/// 尺寸/状态机与下方识图按钮、上方弹幕按钮完全一致（见 CardTranslateButtons）：
/// 平常/完成是**小号**（13 图标 → 19 视觉块），点击加载时变**大号**（17 环 → 23），
/// 完成显示绿色小对勾并缩回小号，失败显示刷新图标（点一下重试）。
/// 位置由 CardTranslateButtons 统一编排，本组件只渲染按钮本体。
///
/// 之前这里是「图标 + 文字」的小胶囊（还带一个额外的重试图标），在封面上比
/// 旁边的翻译按钮宽一倍，挤在角落很显眼。文案改由 Tooltip 承载，按钮本体只留
/// 图标：进度用环形进度圈表示，完成变对勾，失败变刷新图标，点一下就是重翻。
class VideoSubtitleTranslateButton extends StatefulWidget {
  const VideoSubtitleTranslateButton({
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

  /// 番剧（pgc）单集没有 bvid/aid 时，靠这两个编号拉取字幕列表。
  final int? epId;
  final int? seasonId;

  @override
  State<VideoSubtitleTranslateButton> createState() =>
      _VideoSubtitleTranslateButtonState();
}

class _VideoSubtitleTranslateButtonState
    extends State<VideoSubtitleTranslateButton> {
  @override
  void initState() {
    super.initState();
    unawaited(SubtitleTranslationBackgroundService.ensureInitialized());
  }

  void _start({bool force = false}) {
    SmartDialog.showToast(uiTx('正在翻译字幕…'));
    unawaited(
      SubtitleTranslationBackgroundService.start(
        videoKey: widget.videoKey,
        bvid: widget.bvid,
        aid: widget.aid,
        cid: widget.cid,
        epId: widget.epId,
        seasonId: widget.seasonId,
        force: force,
      ),
    );
  }

  /// 运行中点按 = 取消；已完成点按 = 撤销并清缓存（3.7.12）。
  void _cancelOrUndo() {
    SubtitleTranslationBackgroundService.cancelOrUndo(
      videoKey: widget.videoKey,
      cid: widget.cid,
    );
    SmartDialog.showToast(uiTx('已取消并清除字幕缓存'));
  }

  @override
  Widget build(BuildContext context) {
    // 没开 AI 翻译、或目标语言就是简体中文时，这个按钮没有任何可做的事：
    // 以前它照样出现，点一下立刻失败，看起来像坏了。干脆不渲染。
    if (!SubtitleTranslateService.needed) return const SizedBox.shrink();
    return Obx(() {
      final state = SubtitleTranslationBackgroundService.stateFor(
        videoKey: widget.videoKey,
        cid: widget.cid,
      );
      final theme = Theme.of(context);
      final hasNativeTrack = state.nativeTrackAvailable;
      // 「这个视频没有中文字幕」不是失败：图标置灰、不显示进度。
      // 以前它走 failed 分支，红图标 + 「重试」，用户点多少次都是同样的结果；
      // 但也不能把点击彻底禁掉 —— 未登录导致的空字幕列表，登录后要能点回来。
      final (label, icon, color) = state.noSource
          ? (
              state.message ?? uiTx('没有可用的中文字幕'),
              Icons.subtitles_off_outlined,
              Colors.white54,
            )
          : switch (state.phase) {
              SubtitleTranslationTaskPhase.complete => (
                uiTx(hasNativeTrack ? 'B站已有译文' : '已翻译'),
                Icons.check,
                Colors.greenAccent,
              ),
              SubtitleTranslationTaskPhase.failed => (
                uiTx('重试'),
                Icons.refresh,
                theme.colorScheme.errorContainer,
              ),
              SubtitleTranslationTaskPhase.preparing => (
                uiTx('准备中'),
                Icons.hourglass_top,
                Colors.white,
              ),
              SubtitleTranslationTaskPhase.translating => (
                '${(state.progress * 100).round()}%',
                Icons.subtitles_outlined,
                Colors.white,
              ),
              SubtitleTranslationTaskPhase.verifying => (
                uiTx('校验中'),
                Icons.verified_outlined,
                Colors.white,
              ),
              SubtitleTranslationTaskPhase.idle => (
                uiTx('翻译字幕'),
                Icons.subtitles_outlined,
                Colors.white,
              ),
            };
      final hint = state.message ?? label;
      final isComplete = state.phase == SubtitleTranslationTaskPhase.complete;
      final isFailed = state.phase == SubtitleTranslationTaskPhase.failed;
      // 进度画满（100%）就立刻呈现完成态，不等 phase 翻转：
      // 以前「圆环画完整一圈」后要等后台把 phase 改成 complete 才变勾，
      // 中间任何一步慢了/卡了，用户看到的就是一个不消失的整圆环。
      final hitDone = state.isRunning && state.progress >= 1;
      final showCheck = isComplete || hitDone;
      final isRunning = state.isRunning && !showCheck;
      // 小号 = 13 图标 + 3×2 内边距 = 19；大号（加载中）= 17 环 + 6 = 23。
      final block = isRunning ? 23.0 : 19.0;
      final content = isRunning ? 17.0 : 13.0;
      return Tooltip(
        message: hint,
        // 完成态点一下 = 重翻一次；失败态点一下 = 重试。
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // noSource（没有中文字幕）不是失败，图标置灰；但仍然允许点一下重查：
          // 未登录时 B 站对有 CC 的视频也返回空字幕列表，用户登录后必须能
          // 直接点这个按钮恢复，否则状态会永久停在置灰、点不动。
          // 三态点按（3.7.12）：运行中 = 取消；已完成 = 撤销；其余 = 开始。
          onTap:
              state.isRunning || isComplete
              ? _cancelOrUndo
              : () => _start(force: isFailed || state.noSource),
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
                    key: ValueKey('$isRunning$showCheck${state.phase}'),
                    width: content,
                    height: content,
                    child: Center(
                      child: isRunning
                          ? TranslateProgressRing(
                              // 只有「翻译中」有真实进度；准备中/校验中是
                              // 未知进度，交给组件做顺时针缓动。
                              value:
                                  state.phase ==
                                      SubtitleTranslationTaskPhase.translating
                                  ? state.progress
                                  : null,
                              color: color,
                              // 准备中只是拉字幕列表，别装成已经翻了 90%。
                              estimateTarget: 0.12,
                              estimateDuration: const Duration(seconds: 5),
                            )
                          : Icon(
                              showCheck ? Icons.check : icon,
                              size: 13,
                              color: showCheck ? Colors.greenAccent : color,
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
