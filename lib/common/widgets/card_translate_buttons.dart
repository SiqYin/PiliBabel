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

/// 视频封面左下角的「识图 / 字幕 / 弹幕」三按钮组。
///
/// 从左到右：识图翻译（最左，贴角锚点）、字幕（中）、弹幕（最右）。
/// 界面为 RTL 时整行镜像：识图贴右角，向左延伸。
///
/// **尺寸口径（三按钮一致）**：平常/完成 = 小号（13 图标 → 19 视觉块）；
/// 点击加载中 = 大号（17 进度环 → 23 视觉块）；完成显示绿色小对勾并缩回小号。
/// 尺寸变化由各按钮自己的 AnimatedContainer 完成（200ms easeInOut）。
///
/// **位置联动**：三个按钮共用一条左下横行，任何一个进入大号态都会把**它右侧
/// 的按钮**再外推 4 像素，防止大按钮的边缘盖住小按钮的边缘；缩回小号后
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

  /// 视觉块宽/高：加载中 23（17 环 + 6 边距），其余 19（13 图标 + 6）。
  static const double _blockSmall = 19;
  static const double _blockBig = 23;
  static const double _gap = 2;
  static const double _coverBottom = 6;
  static const double _coverStart = 7;

  @override
  Widget build(BuildContext context) {
    final showSubtitle =
        widget.showSubtitle && SubtitleTranslateService.needed;
    final showDanmaku = widget.showDanmaku && DanmakuPretranslateService.needed;

    // 三层监听嵌套：识图（ValueNotifier）→ 字幕/弹幕（Obx，读 RxMap 注册依赖）。
    // 任一信号变化都会重算三个横向起点，AnimatedPositioned 接管过渡动画。
    // RTL：横行贴「文字起始侧」——LTR 从左下角向右延伸、RTL 从右下角向左
    // 延伸（栈不自动镜像 Positioned，这里手工切 left/right）。
    final rtl = Directionality.of(context) == ui.TextDirection.rtl;
    return Positioned.fill(
      child: ValueListenableBuilder<bool>(
        valueListenable: _coverLoading,
        builder: (context, _, __) => Obx(() {
          final coverBig = _coverLoading.value;
          final subBig = showSubtitle && _subtitleRunning;
          final coverW = coverBig ? _blockBig : _blockSmall;
          final subW = subBig ? _blockBig : _blockSmall;
          // 识图贴角是锚点（横向起点固定 7）；字幕/弹幕依次向阅读方向延伸。
          // 左侧按钮变大时把右侧的推出去，缩回时拉回来（bottom 一律贴角）。
          final subStart = _coverStart + coverW + _gap;
          final dmStart = showSubtitle ? subStart + subW + _gap : subStart;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // —— 最右：弹幕 ——
              if (showDanmaku)
                AnimatedPositioned(
                  key: const ValueKey('danmaku'),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: rtl ? null : dmStart,
                  right: rtl ? dmStart : null,
                  bottom: _coverBottom,
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
                  left: rtl ? null : subStart,
                  right: rtl ? subStart : null,
                  bottom: _coverBottom,
                  child: VideoSubtitleTranslateButton(
                    videoKey: widget.videoKey,
                    bvid: widget.bvid,
                    aid: widget.aid,
                    cid: widget.cid,
                    epId: widget.epId,
                    seasonId: widget.seasonId,
                  ),
                ),
              // —— 最左：识图（贴角锚点，位置固定；它变大时把右边两个推出去） ——
              AnimatedPositioned(
                key: const ValueKey('cover'),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: rtl ? null : _coverStart,
                right: rtl ? _coverStart : null,
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

