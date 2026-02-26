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

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'
    show
        ContainerRenderObjectMixin,
        MultiChildLayoutParentData,
        RenderBoxContainerDefaultsMixin,
        BoxHitTestResult;

const double kHeaderHeight = 135.0;

const double kAvatarSize = 80.0;
const double _kAvatarLeftPadding = 20.0;
const double _kAvatarTopPadding = 110.0;
const double _kAvatarEffectiveHeight =
    kAvatarSize - (kHeaderHeight - _kAvatarTopPadding);

const double _kActionsTopPadding = 140.0;
const double _kActionsLeftPadding = 160.0;
const double _kActionsRightPadding = 15.0;

enum HeaderType { header, avatar, actions }

class HeaderLayoutWidget extends MultiChildRenderObjectWidget {
  const HeaderLayoutWidget({
    super.key,
    super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderHeaderWidget();
  }
}

class RenderHeaderWidget extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = MultiChildLayoutParentData();
    }
  }

  @override
  void performLayout() {
    double height = kHeaderHeight;
    RenderBox? child = firstChild;
    final maxWidth = constraints.maxWidth;
    while (child != null) {
      final childParentData = child.parentData! as MultiChildLayoutParentData;

      switch (childParentData.id as HeaderType) {
        case HeaderType.header:
          child.layout(constraints);
          childParentData.offset = .zero;
        case HeaderType.avatar:
          child.layout(constraints);
          childParentData.offset = const Offset(
            _kAvatarLeftPadding,
            _kAvatarTopPadding,
          );
        case HeaderType.actions:
          final childSize =
              (child..layout(
                    BoxConstraints(
                      maxWidth:
                          maxWidth -
                          _kActionsLeftPadding -
                          _kActionsRightPadding,
                    ),
                    parentUsesSize: true,
                  ))
                  .size;
          height += (math.max(_kAvatarEffectiveHeight, childSize.height)) + 5.0;
          childParentData.offset = Offset(
            maxWidth - childSize.width - _kActionsRightPadding,
            _kActionsTopPadding,
          );
      }

      child = childParentData.nextSibling;
    }

    size = constraints.constrainDimensions(maxWidth, height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
