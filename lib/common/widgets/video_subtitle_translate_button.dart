import 'dart:async';

import 'package:PiliPlus/services/ui_translate/subtitle_translate_service.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_background_service.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 视频封面左下角的「翻译字幕」按钮（纯图标）。
///
/// 位置和尺寸与 `CoverTranslateButton` 完全一致，叠在它正上方一点点：
/// 两个按钮是同一套视觉（28×28 命中区、3 的内边距、13 的图标、black54 圆角 4），
/// 区别只在图标本身 —— 上方字幕、下方识图翻译。
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
    this.bottom = 27,
    this.left = 7,
  });

  final String videoKey;
  final String? bvid;
  final int? aid;
  final int? cid;

  /// 与 `CoverTranslateButton` 同一套锚点：封面翻译按钮的视觉块占 bottom 6..25，
  /// 这里取 27 留 2 像素缝隙，看起来是「贴着它上方」而不是另一个角落。
  final double bottom;
  final double left;

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
    unawaited(
      SubtitleTranslationBackgroundService.start(
        videoKey: widget.videoKey,
        bvid: widget.bvid,
        aid: widget.aid,
        cid: widget.cid,
        force: force,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 没开 AI 翻译、或目标语言就是简体中文时，这个按钮没有任何可做的事：
    // 以前它照样出现，点一下立刻失败，看起来像坏了。干脆不渲染。
    // 仍然包在 Positioned 里、只把内容缩成 0，避免改变 Stack 的布局模型。
    return Positioned(
      left: widget.left,
      bottom: widget.bottom,
      child: !SubtitleTranslateService.needed
          ? const SizedBox.shrink()
          : Obx(() {
        final state = SubtitleTranslationBackgroundService.stateFor(
          videoKey: widget.videoKey,
          cid: widget.cid,
        );
        final theme = Theme.of(context);
        final hasNativeTrack = state.nativeTrackAvailable;
        // 「这个视频没有中文字幕」不是失败：图标置灰、不显示进度、点了也不重试。
        // 以前它走 failed 分支，红图标 + 「重试」，用户点多少次都是同样的结果。
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
        return Tooltip(
          message: hint,
          // 完成态点一下 = 重翻一次；失败态点一下 = 重试。之前这两个动作挂在
          // 胶囊里那个 1px 内边距的小刷新图标上，现在整块按钮就是一个大靶子。
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: state.isRunning || state.noSource
                ? null
                : () => _start(force: isComplete || isFailed),
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
                  child: state.isRunning
                      ? SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                            value:
                                state.phase ==
                                    SubtitleTranslationTaskPhase.translating
                                ? state.progress
                                : null,
                            strokeWidth: 2,
                            color: color,
                          ),
                        )
                      : Icon(icon, size: 13, color: color),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
