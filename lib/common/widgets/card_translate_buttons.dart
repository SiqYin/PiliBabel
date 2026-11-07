import 'dart:ui' as ui;

import 'package:PiliPlus/common/widgets/cover_translate_button.dart';
import 'package:PiliPlus/common/widgets/video_danmaku_translate_button.dart';
import 'package:PiliPlus/common/widgets/video_subtitle_translate_button.dart';
import 'package:PiliPlus/services/ui_translate/danmaku_pretranslate_service.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translate_service.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_background_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 视频封面左下角的「弹幕 / 字幕 / 识图」三按钮组。
///
/// 从上到下：弹幕（最上）、字幕（中）、识图翻译（最下，贴角）。
///
/// **尺寸口径（三按钮一致）**：平常/完成 = 小号（13 图标 → 19 视觉块）；
/// 点击加载中 = 大号（17 进度环 → 23 视觉块）；完成显示绿色小对勾并缩回小号。
/// 尺寸变化由各按钮自己的 AnimatedContainer 完成（200ms easeInOut）。
///
/// **位置联动**：三个按钮共用一条左下竖列，任何一个进入大号态都会把**它上方
/// 的按钮**再抬高 4 像素，防止大按钮的上边缘盖住小按钮的下边缘；缩回小号后
/// 回到原位。位移用 AnimatedPositioned（200ms，与尺寸动画同曲线同时长），
/// 大小的 morph 和位置的让位是同一套动效，看起来是一个整体在呼吸。
///
/// 组合规则（用户 2026-11-07 指定的七种状态全部覆盖）：
/// 上/中/下任一加载、上中/中下/上下两两加载、上中下同时加载——
/// 每个按钮的 bottom = 6 + 下方所有按钮的视觉块高之和 + 每层 2px 缝隙。
/// 三个信号源（识图 ValueNotifier、字幕 Rx、弹幕 Rx）任一变化都会让整组
/// 重算位置；识图按钮自己不位移，只负责把上面两个顶起来。
class CardTranslateButtons extends StatefulWidget {
  const CardTranslateButtons({
    super.key,
    required this.cover,
    required this.videoKey,
    this.bvid,
    this.aid,
    this.cid,
    this.epId,
    this.seasonId,
    this.showSubtitle = true,
    this.showDanmaku = true,
  });

  final String? cover;

  /// 视频（字幕/弹幕）身份参数，原样透传给两个按钮。
  final String videoKey;
  final String? bvid;
  final int? aid;
  final int? cid;
  final int? epId;
  final int? seasonId;

  /// 卡片没有视频身份（纯图片内容）时不渲染对应按钮。
  final bool showSubtitle;
  final bool showDanmaku;

  @override
  State<CardTranslateButtons> createState() => _CardTranslateButtonsState();
}

class _CardTranslateButtonsState extends State<CardTranslateButtons> {
  /// 下方识图按钮的加载态：识图按钮自己维护状态，这里只订阅外发信号。
  final ValueNotifier<bool> _coverLoading = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _coverLoading.dispose();
    super.dispose();
  }

  /// 视觉块高度：加载中 23（17 环 + 6 边距），其余 19（13 图标 + 6）。
  static const double _blockSmall = 19;
  static const double _blockBig = 23;
  static const double _gap = 2;
  static const double _coverBottom = 6;

  @override
  Widget build(BuildContext context) {
    final showSubtitle =
        widget.showSubtitle && SubtitleTranslateService.needed;
    final showDanmaku = widget.showDanmaku && DanmakuPretranslateService.needed;

    // 三层监听嵌套：识图（ValueNotifier）→ 字幕/弹幕（Obx，读 RxMap 注册依赖）。
    // 任一信号变化都会重算三个 bottom，AnimatedPositioned 接管过渡动画。
    // RTL：竖列贴「文字起始侧」——LTR 贴左、RTL 贴右（栈不自动镜像 Positioned，
    // 这里手工切 left/right）。图标/徽章等封面内容本身不做镜像。
    final rtl = Directionality.of(context) == ui.TextDirection.rtl;
    return Positioned.fill(
      child: ValueListenableBuilder<bool>(
        valueListenable: _coverLoading,
        builder: (context, _, __) => Obx(() {
          final coverBig = _coverLoading.value;
          final subBig = showSubtitle && _subtitleRunning;
          final coverH = coverBig ? _blockBig : _blockSmall;
          final subH = subBig ? _blockBig : _blockSmall;
          final subBottom = _coverBottom + coverH + _gap;
          final dmBottom = showSubtitle ? subBottom + subH + _gap : subBottom;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // —— 最上：弹幕 ——
              if (showDanmaku)
                AnimatedPositioned(
                  key: const ValueKey('danmaku'),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: rtl ? null : 7,
              right: rtl ? 7 : null,
                  bottom: dmBottom,
                  child: VideoDanmakuTranslateButton(
                    videoKey: widget.videoKey,
                    bvid: widget.bvid,
                    aid: widget.aid,
                    cid: widget.cid,
                    epId: widget.epId,
                    seasonId: widget.seasonId,
                  ),
                ),
              // —— 中：字幕 ——
              if (showSubtitle)
                AnimatedPositioned(
                  key: const ValueKey('subtitle'),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: rtl ? null : 7,
              right: rtl ? 7 : null,
                  bottom: subBottom,
                  child: VideoSubtitleTranslateButton(
                    videoKey: widget.videoKey,
                    bvid: widget.bvid,
                    aid: widget.aid,
                    cid: widget.cid,
                    epId: widget.epId,
                    seasonId: widget.seasonId,
                  ),
                ),
              // —— 最下：识图（贴角，位置固定；它变大时推着上面两个上移） ——
              AnimatedPositioned(
                key: const ValueKey('cover'),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: rtl ? null : 7,
              right: rtl ? 7 : null,
                bottom: _coverBottom,
                child: CoverTranslateButton(
                  cover: widget.cover,
                  loadingNotifier: _coverLoading,
                  embedded: true,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  bool get _subtitleRunning =>
      SubtitleTranslationBackgroundService
          .stateFor(videoKey: widget.videoKey, cid: widget.cid)
          .isRunning;
}

