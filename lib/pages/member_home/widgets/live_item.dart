import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

const _maxWith = 400.0;

class LiveItem extends SingleChildRenderObjectWidget {
  const LiveItem({
    super.key,
    required this.color,
    required Widget super.child,
  });

  final Color color;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLiveItem(color: color);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderLiveItem renderObject) {
    renderObject.color = color;
  }
}

class _RenderLiveItem extends RenderProxyBox {
  _RenderLiveItem({required this._color});

  Color _color;
  Color get color => _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    final maxWidth = constraints.maxWidth;
    if (maxWidth > _maxWith) {
      child?.layout(const BoxConstraints.tightFor(width: _maxWith), parentUsesSize: true);
    } else {
      child?.layout(constraints, parentUsesSize: true);
    }
    size = constraints.constrainDimensions(maxWidth, child?.size.height ?? 0);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawRect(offset & size, Paint()..color = _color);
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}
