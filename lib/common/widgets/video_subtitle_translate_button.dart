import 'dart:async';

import 'package:PiliPlus/services/ui_translate/subtitle_translation_background_service.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// A compact card-cover action for caching an AI subtitle translation.
class VideoSubtitleTranslateButton extends StatefulWidget {
  const VideoSubtitleTranslateButton({
    super.key,
    required this.videoKey,
    this.bvid,
    this.aid,
    this.cid,
    this.bottom = 6,
    this.left = 40,
  });

  final String videoKey;
  final String? bvid;
  final int? aid;
  final int? cid;
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
    return Positioned(
      left: widget.left,
      bottom: widget.bottom,
      child: Obx(() {
        final state = SubtitleTranslationBackgroundService.stateFor(
          videoKey: widget.videoKey,
          cid: widget.cid,
        );
        final theme = Theme.of(context);
        final hasNativeTrack = state.nativeTrackAvailable;
        final (label, icon, color) = switch (state.phase) {
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
        return Tooltip(
          message: hint,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: state.isRunning || isComplete ? null : _start,
            child: Container(
              constraints: const BoxConstraints(minWidth: 54, minHeight: 28),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.isRunning)
                    SizedBox(
                      width: 12,
                      height: 12,
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
                  else
                    Icon(icon, size: 13, color: color),
                  const SizedBox(width: 3),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 9),
                  ),
                  if (isComplete) ...[
                    const SizedBox(width: 2),
                    Tooltip(
                      message: uiTx('重新翻译字幕'),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _start(force: true),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.refresh,
                            size: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
