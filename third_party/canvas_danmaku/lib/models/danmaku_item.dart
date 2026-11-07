import 'dart:ui' as ui;

import 'package:canvas_danmaku/models/danmaku_content_item.dart';
import 'package:canvas_danmaku/utils/utils.dart';

class DanmakuItem<T> {
  /// 弹幕内容
  ///
  /// 3.8.0 起可变：支持「原文→译文」原位换文（[replaceContent]），
  /// 其余字段（color/type/extra 等）由 [replaceContent] 原样拷贝。
  DanmakuContentItem<T> content;

  /// 弹幕宽度
  double width;

  /// 弹幕高度
  double height;

  /// 弹幕水平方向位置
  double xPosition;

  /// 上次绘制时间
  int? drawTick;

  /// 弹幕布局缓存
  ui.Image? image;

  bool expired = false;

  bool suspend = false;

  @pragma("vm:prefer-inline")
  bool needRemove(bool needRemove) {
    if (needRemove) {
      dispose();
    }
    return needRemove;
  }

  void dispose() {
    image?.dispose();
    image = null;
  }

  DanmakuItem({
    required this.content,
    required this.height,
    required this.width,
    this.xPosition = 0,
    this.image,
    this.drawTick,
  });

  /// 原位换文（3.8.0）：作废图像缓存并替换内容，其余属性原样保留。
  /// 下一帧 [drawParagraphIfNeeded] 会按当前选项重建段落并重新量宽高；
  /// xPosition 不动，飞行轨迹与时长不受影响。
  void replaceContent(String newText) {
    if (content.text == newText) return;
    content = DanmakuContentItem<T>(
      newText,
      color: content.color,
      type: content.type,
      selfSend: content.selfSend,
      isColorful: content.isColorful,
      count: content.count,
      countPosition: content.countPosition,
      fontSize: content.fontSize,
      extra: content.extra,
    );
    dispose();
  }

  void drawParagraphIfNeeded(
    double fontSize,
    int fontWeight,
    double strokeWidth,
    String? fontFamily,
  ) {
    if (image == null) {
      final paragraph = DmUtils.generateParagraph(
        content: content,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: fontFamily,
      );
      image = DmUtils.recordDanmakuImage(
        contentParagraph: paragraph,
        content: content,
        fontSize: fontSize,
        fontWeight: fontWeight,
        strokeWidth: strokeWidth,
        fontFamily: fontFamily,
      );
      width = paragraph.maxIntrinsicWidth +
          strokeWidth +
          (content.selfSend ? 4.0 : 0.0);
      height = paragraph.height + strokeWidth;
      paragraph.dispose();
    }
  }

  @override
  String toString() {
    return 'DanmakuItem(content=$content, xPos=$xPosition, size=${ui.Size(width, height)}, drawTick=$drawTick)';
  }
}
