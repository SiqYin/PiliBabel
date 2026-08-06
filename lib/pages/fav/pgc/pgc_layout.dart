import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show BoxHitTestResult, BoxParentData;

enum PgcType { toolbar, body }

class PgcLayout
    extends SlottedMultiChildRenderObjectWidget<PgcType, RenderBox> {
  const PgcLayout({
    super.key,
    required this.body,
    required this.toolbar,
  });

  final Widget body;
  final Widget toolbar;

  @override
  Iterable<PgcType> get slots => PgcType.values;

  @override
  Widget childForSlot(slot) => switch (slot) {
    .toolbar => toolbar,
    .body => body,
  };

  @override
  SlottedContainerRenderObjectMixin<PgcType, RenderBox> createRenderObject(
    BuildContext context,
  ) {
    return _RenderPgcLayout();
  }
}

class _RenderPgcLayout extends RenderBox
    with SlottedContainerRenderObjectMixin<PgcType, RenderBox> {
  RenderBox get body => childForSlot(.body)!;
  RenderBox get toolbar => childForSlot(.toolbar)!;

  Offset _getOffset(RenderBox child) {
    return (child.parentData as BoxParentData).offset;
  }

  void _setOffset(RenderBox child, Offset offset) {
    (child.parentData as BoxParentData).offset = offset;
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    size = constraints.biggest;

    final body = this.body..layout(constraints);
    _setOffset(body, .zero);

    final toolbar = this.toolbar
      ..layout(BoxConstraints.tightFor(width: constraints.maxWidth));
    _setOffset(toolbar, Offset(0, constraints.maxHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    void doPaint(RenderBox child) {
      context.paintChild(child, _getOffset(child) + offset);
    }

    doPaint(body);
    doPaint(toolbar);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final child in children) {
      final bool isHit = result.addWithPaintOffset(
        offset: _getOffset(child),
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
    }
    return false;
  }
}
