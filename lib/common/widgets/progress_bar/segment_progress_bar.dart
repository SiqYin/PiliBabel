/*
 * This file is part of PiliPlus
 *
 * PiliPlus is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * PiliPlus is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with PiliPlus.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:ui' as ui;

import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:get/get.dart' show Obx;
import 'package:PiliPlus/utils/extension/iterable_ext.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/rendering.dart' show BoxHitTestEntry;
import 'package:material_ui/material_ui.dart';

@immutable
sealed class BaseSegment {
  final double end;

  const BaseSegment({
    required this.end,
  });
}

@immutable
class Segment extends BaseSegment {
  final double start;
  final Color color;

  const Segment({
    required this.start,
    required super.end,
    required this.color,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is Segment) {
      return start == other.start && end == other.end && color == other.color;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(start, end, color);
}

@immutable
class ViewPointSegment extends BaseSegment {
  final String? title;
  final String? url;
  final int? from;
  final int? to;

  const ViewPointSegment({
    required super.end,
    this.title,
    this.url,
    this.from,
    this.to,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is ViewPointSegment) {
      return end == other.end &&
          title == other.title &&
          url == other.url &&
          from == other.from &&
          to == other.to;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(end, title, url, from, to);
}

class SegmentProgressBar extends BaseSegmentProgressBar<Segment> {
  const SegmentProgressBar({
    super.key,
    super.height,
    required super.segments,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderProgressBar(
      height: height,
      segments: segments,
    );
  }
}

class RenderProgressBar extends BaseRenderProgressBar<Segment> {
  RenderProgressBar({
    required super.height,
    required super.segments,
  });

  @override
  void paint(PaintingContext context, Offset offset) {
    final size = this.size;
    final canvas = context.canvas;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final segment in segments) {
      paint.color = segment.color;
      final segmentStart = offset.dx + segment.start * size.width;
      final segmentEnd = offset.dx + segment.end * size.width;

      if (segmentEnd > segmentStart ||
          (segmentEnd == segmentStart && segmentStart > 0)) {
        canvas.drawRect(
          Rect.fromLTRB(
            segmentStart,
            offset.dy,
            segmentEnd == segmentStart ? segmentStart + 2 : segmentEnd,
            size.height + offset.dy,
          ),
          paint,
        );
      }
    }
  }
}

/// 进度条上画的「分段名」是 UP 主自己写的原文，需要在渲染边界翻一次。
///
/// 这里套一层 [Obx] 读 [UiTranslateService.revision]：译文是异步落缓存的，
/// 画布只在 progress 变化时重绘，不订阅 revision 的话分段名会一直停在原文。
class ViewPointSegmentProgressBar extends StatelessWidget {
  const ViewPointSegmentProgressBar({
    super.key,
    this.height = 3.5,
    required this.segments,
    this.onSeek,
  });

  final double height;
  final List<ViewPointSegment> segments;
  final ValueSetter<Duration>? onSeek;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      UiTranslateService.to.revision.value;
      return _ViewPointSegmentProgressBar(
        height: height,
        segments: segments,
        onSeek: onSeek,
      );
    });
  }
}

class _ViewPointSegmentProgressBar
    extends BaseSegmentProgressBar<ViewPointSegment> {
  const _ViewPointSegmentProgressBar({
    super.height,
    required super.segments,
    this.onSeek,
  });

  final ValueSetter<Duration>? onSeek;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderViewPointProgressBar(
      height: height,
      segments: segments,
      onSeek: onSeek,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderViewPointProgressBar renderObject,
  ) {
    renderObject
      ..height = height
      ..segments = segments
      ..onSeek = onSeek
      // 标脏走 markNeedsLayout：分段名要在「排版期」按最新译文重新断行、
      // 并按最高分段重算条高——只 markNeedsPaint 的话条高和段落缓存都是旧的。
      ..markNeedsLayout();
  }
}

class RenderViewPointProgressBar
    extends BaseRenderProgressBar<ViewPointSegment> {
  RenderViewPointProgressBar({
    required super.height,
    required super.segments,
    ValueSetter<Duration>? onSeek,
  }) : _onSeek = onSeek,
       _hitTestSelf = onSeek != null {
    if (onSeek != null) {
      _tapGestureRecognizer = TapGestureRecognizer()..onTapUp = _onTapUp;
    }
  }

  /// 排版产物：与 segments 对齐，空标题占 null；另存全条需要的总高。
  List<ui.Paragraph?> _layoutCache = const <ui.Paragraph?>[];
  double _layoutBarHeight = _barHeight;

  @override
  void performLayout() {
    final width = constraints.maxWidth;
    // 在排版期按**当前译文**重新断行：长标题在各自分段宽度内自动换行，
    // 最多 3 行（放不下出省略号），字号恒定不再整段缩小；条高取最高分段，
    // 单行时保持 15px 与旧版完全一致。
    double maxTextHeight = 0;
    final cache = <ui.Paragraph?>[];
    double prevEnd = 0;
    for (final segment in segments) {
      final segmentEnd = segment.end * width;
      final segmentWidth = segmentEnd - prevEnd;
      ui.Paragraph? paragraph;
      final title = segment.title;
      if (title != null && title.isNotEmpty && segmentWidth > 0) {
        paragraph = _getParagraph(uiTx(title), segmentWidth);
        if (paragraph.height > maxTextHeight) {
          maxTextHeight = paragraph.height;
        }
      }
      cache.add(paragraph);
      prevEnd = segmentEnd + _dividerWidth;
    }
    _disposeCache();
    _layoutCache = cache;
    final barHeight = maxTextHeight + _verticalPadding * 2;
    _layoutBarHeight = barHeight > _barHeight ? barHeight : _barHeight;
    size = constraints.constrainDimensions(width, _layoutBarHeight);
  }

  void _disposeCache() {
    for (final paragraph in _layoutCache) {
      paragraph?.dispose();
    }
    _layoutCache = const <ui.Paragraph?>[];
  }

  static const double _barHeight = 15.0;
  static const double _dividerWidth = 2.0;
  static const double _fontSize = 10.0;
  static const double _verticalPadding = 2.5;
  /// 单个分段内最多显示的行数（3.9.6：换行代替整段缩小）。
  static const int _maxLines = 3;

  static ui.Paragraph _getParagraph(String title, double maxWidth) {
    final builder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              textDirection: .ltr,
              maxLines: _maxLines,
              ellipsis: '…',
              strutStyle: ui.StrutStyle(
                leading: 0,
                height: 1,
                fontSize: _fontSize,
              ),
            ),
          )
          ..pushStyle(.new(color: Colors.white, fontSize: _fontSize, height: 1))
          ..addText(title);
    return builder.build()..layout(ui.ParagraphConstraints(width: maxWidth));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final size = this.size;
    final canvas = context.canvas;
    final paint = Paint()..style = PaintingStyle.fill;

    if (offset != .zero) {
      canvas
        ..save()
        ..translate(offset.dx, offset.dy);
    }

    assert(segments.isSortedBy((i) => i.end));

    final barHeight = _layoutBarHeight;
    canvas.drawRect(
      Rect.fromLTRB(0, 0, size.width, barHeight),
      paint..color = Colors.grey[600]!.withValues(alpha: 0.45),
    );

    paint.color = Colors.black.withValues(alpha: 0.5);

    double prevEnd = 0.0;
    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final segmentEnd = segment.end * size.width;
      canvas.drawRect(
        Rect.fromLTRB(
          segmentEnd,
          0,
          segmentEnd + _dividerWidth,
          barHeight + height,
        ),
        paint,
      );
      // 段落已在排版期按分段宽度断好行（≤3 行），这里只做居中摆放；
      // 单个字都放不下时靠左画（dx 钳到 0），省略号由段落自身处理。
      final paragraph = i < _layoutCache.length ? _layoutCache[i] : null;
      if (paragraph != null) {
        final segmentWidth = segmentEnd - prevEnd;
        final textWidth = paragraph.maxIntrinsicWidth;
        final dx = segmentWidth > textWidth
            ? (segmentWidth - textWidth) / 2
            : 0.0;
        canvas.drawParagraph(
          paragraph,
          Offset(prevEnd + dx, (barHeight - paragraph.height) / 2),
        );
      }
      prevEnd = segmentEnd + _dividerWidth;
    }
    if (offset != .zero) canvas.restore();
  }

  ValueSetter<Duration>? _onSeek;
  set onSeek(ValueSetter<Duration>? value) {
    if (_onSeek == value) {
      return;
    }
    _onSeek = value;
  }

  TapGestureRecognizer? _tapGestureRecognizer;

  @override
  void dispose() {
    _disposeCache();
    _onSeek = null;
    _tapGestureRecognizer
      ?..onTapUp = null
      ..dispose();
    _tapGestureRecognizer = null;
    super.dispose();
  }

  final bool _hitTestSelf;
  @override
  bool hitTestSelf(Offset position) => _hitTestSelf;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tapGestureRecognizer?.addPointer(event);
    }
  }

  @pragma('vm:notify-debugger-on-exception')
  void _onTapUp(TapUpDetails details) {
    try {
      final seg = details.localPosition.dx / size.width;
      final item = _segments[_segments.lowerBoundByKey((i) => i.end, seg)];
      if (item.from case final from?) {
        _onSeek?.call(Duration(seconds: from));
      }
      // if (kDebugMode) debugPrint('${item.title},,${item.from}');
    } catch (_) {}
  }
}

abstract class BaseSegmentProgressBar<T extends BaseSegment>
    extends LeafRenderObjectWidget {
  const BaseSegmentProgressBar({
    super.key,
    this.height = 3.5,
    required this.segments,
  });

  final double height;
  final List<T> segments;

  @override
  void updateRenderObject(
    BuildContext context,
    BaseRenderProgressBar renderObject,
  ) {
    renderObject
      ..height = height
      ..segments = segments;
  }
}

class BaseRenderProgressBar<T extends BaseSegment> extends RenderBox {
  BaseRenderProgressBar({
    required this._height,
    required this._segments,
  });

  double _height;
  double get height => _height;
  set height(double value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  List<T> _segments;
  List<T> get segments => _segments;
  set segments(List<T> value) {
    if (listEquals(_segments, value)) return;
    _segments = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrainDimensions(constraints.maxWidth, height);
  }
}

class ViewPointDividerBar extends LeafRenderObjectWidget {
  const ViewPointDividerBar({
    super.key,
    required this.segments,
    this.progress = 0.0,
    this.dotRadius = 1.75,
  });

  final List<ViewPointSegment> segments;
  final double progress;
  final double dotRadius;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderViewPointDividerBar(
      segments: segments,
      progress: progress,
      dotRadius: dotRadius,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderViewPointDividerBar renderObject,
  ) {
    renderObject
      ..segments = segments
      ..progress = progress
      ..dotRadius = dotRadius;
  }
}

class RenderViewPointDividerBar extends RenderBox {
  RenderViewPointDividerBar({
    required this._segments,
    required this._progress,
    required this._dotRadius,
  });

  List<ViewPointSegment> _segments;
  set segments(List<ViewPointSegment> value) {
    if (listEquals(_segments, value)) return;
    _segments = value;
    markNeedsPaint();
  }

  double _progress;
  set progress(double value) {
    if (_progress == value) return;
    _progress = value;
    markNeedsPaint();
  }

  double _dotRadius;
  set dotRadius(double value) {
    if (_dotRadius == value) return;
    _dotRadius = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrainDimensions(
      constraints.maxWidth,
      _dotRadius * 2,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final paint = Paint()..style = PaintingStyle.fill;

    final centerY = offset.dy + size.height / 2;
    // ViewPointSegmentProgressBar uses a divider width of 2.0 starting at segment.end
    const double dividerWidth = 2.0;

    // Skip the last segment (its end = 1.0, which is the end of the bar)
    final count = _segments.length;
    for (int i = 0; i < count - 1; i++) {
      final segment = _segments[i];
      final segmentEnd = offset.dx + segment.end * size.width;

      // Unreached dots use white75, reached dots use solid white
      if (segment.end <= _progress) {
        paint.color = Colors.white;
      } else {
        paint.color = Colors.white.withValues(alpha: 0.75);
      }

      // Align the center of the dot to the center of the divider line
      final x = segmentEnd + dividerWidth / 2;
      canvas.drawCircle(Offset(x, centerY), _dotRadius, paint);
    }
  }
}
