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

  void _start() {
    unawaited(
      SubtitleTranslationBackgroundService.start(
        videoKey: widget.videoKey,
        bvid: widget.bvid,
        aid: widget.aid,
        cid: widget.cid,
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
        );
        final theme = Theme.of(context);
        final (label, icon, color) = switch (state.phase) {
          SubtitleTranslationTaskPhase.complete => (
            uiTx('Đã dịch'),
            Icons.check,
            Colors.greenAccent,
          ),
          SubtitleTranslationTaskPhase.failed => (
            uiTx('Thử lại'),
            Icons.refresh,
            theme.colorScheme.errorContainer,
          ),
          SubtitleTranslationTaskPhase.preparing => (
            uiTx('Chuẩn bị'),
            Icons.hourglass_top,
            Colors.white,
          ),
          SubtitleTranslationTaskPhase.translating => (
            '${(state.progress * 100).round()}%',
            Icons.subtitles_outlined,
            Colors.white,
          ),
          SubtitleTranslationTaskPhase.idle => (
            uiTx('Dịch sub'),
            Icons.subtitles_outlined,
            Colors.white,
          ),
        };
        final hint = state.message ?? label;
        return Tooltip(
          message: hint,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap:
                state.isRunning ||
                    state.phase == SubtitleTranslationTaskPhase.complete
                ? null
                : _start,
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
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
