import 'dart:math';

import 'package:PiliPlus/common/skeleton/video_card_h.dart';
import 'package:PiliPlus/common/sliver_single_child_delegate.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

mixin GridMixin {
  /// 复用 VideoCardH 的网格统一用这个 delegate。
  ///
  /// 高度补偿（`+ (Pref.videoTitleFull ? 38 : 0)`）放在 delegate 内部统一处理，
  /// 这样所有调用方（GridMixin、搜索「全部」页…）都会自动跟随「标题两行/四行」开关，
  /// 不会再出现某个页面漏加补偿、第 4 行被格子裁掉的情况。
  /// 注意：VideoCardH 里的封面是固定高度的，多出来的高度只给右侧标题区，
  /// 所以这里加高不会把封面撑大。
  /// 注意这里是 **getter 而不是 `late final`**：`late final` 只会在首次访问时算一次，
  /// 而不少使用 GridMixin 的页面带 `AutomaticKeepAliveClientMixin`（搜索、收藏、历史…），
  /// State 一直活着，于是用户在设置里切换「标题完全显示」后，网格仍拿着旧的
  /// mainAxisExtent —— 表现就是「点了开关没反应，非得重启」。
  /// 改成 getter 后每次构建都按当前设置取新值，开关能立即生效。
  SliverGridDelegateWithMaxCrossAxisExtent get gridDelegate =>
      Grid.videoCardHDelegate();

  Widget get gridSkeleton => SliverGrid(
    gridDelegate: gridDelegate,
    delegate: const SliverSingleChildDelegate(
      count: 10,
      child: VideoCardHSkeleton(),
    ),
  );
}

abstract final class Grid {
  static final double smallCardWidth = Pref.smallCardWidth;

  /// 复用 VideoCardH 的网格统一用这个 delegate。
  ///
  /// 高度补偿（`+ 38`）写在这里，所有调用方（GridMixin、搜索「全部」页…）自动跟随
  /// 「标题完全显示」开关，不会再出现某页漏加补偿、第 4 行被格子裁掉。
  /// 前提：VideoCardH 的封面高度已固定，加高只会把空间给右侧标题区，不会撑大封面。
  static SliverGridDelegateWithMaxCrossAxisExtent videoCardHDelegate({
    double mainAxisExtent = 110,
  }) => SliverGridDelegateWithMaxCrossAxisExtent(
    mainAxisSpacing: 2,
    mainAxisExtent: mainAxisExtent + (Pref.videoTitleFull ? 38 : 0),
    maxCrossAxisExtent: Grid.smallCardWidth * 2,
  );
}

class SliverGridDelegateWithExtentAndRatio extends SliverGridDelegate {
  /// Creates a delegate that makes grid layouts with tiles that have a maximum
  /// cross-axis extent.
  ///
  /// The [maxCrossAxisExtent], [mainAxisExtent], [mainAxisSpacing],
  /// and [crossAxisSpacing] arguments must not be negative.
  /// The [childAspectRatio] argument must be greater than zero.
  SliverGridDelegateWithExtentAndRatio({
    required this.maxCrossAxisExtent,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent = 0.0,
  }) : assert(maxCrossAxisExtent > 0),
       assert(mainAxisSpacing >= 0),
       assert(crossAxisSpacing >= 0),
       assert(childAspectRatio > 0);

  /// The maximum extent of tiles in the cross axis.
  ///
  /// This delegate will select a cross-axis extent for the tiles that is as
  /// large as possible subject to the following conditions:
  ///
  ///  - The extent evenly divides the cross-axis extent of the grid.
  ///  - The extent is at most [maxCrossAxisExtent].
  ///
  /// For example, if the grid is vertical, the grid is 500.0 pixels wide, and
  /// [maxCrossAxisExtent] is 150.0, this delegate will create a grid with 4
  /// columns that are 125.0 pixels wide.
  final double maxCrossAxisExtent;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each child.
  final double childAspectRatio;

  /// The extent of each tile in the main axis. If provided, it would add
  /// after [childAspectRatio] is used.
  final double mainAxisExtent;

  bool _debugAssertIsValid(double crossAxisExtent) {
    assert(crossAxisExtent > 0.0);
    assert(maxCrossAxisExtent > 0.0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(childAspectRatio > 0.0);
    return true;
  }

  SliverGridLayout? layoutCache;
  double? crossAxisExtentCache;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    // invoked before each frame
    assert(_debugAssertIsValid(constraints.crossAxisExtent));
    if (layoutCache != null &&
        constraints.crossAxisExtent == crossAxisExtentCache) {
      return layoutCache!;
    }
    crossAxisExtentCache = constraints.crossAxisExtent;
    // Ensure a minimum count of 1, can be zero and result in an infinite extent
    // below when the window size is 0.
    final crossAxisCount = max(
      1,
      (constraints.crossAxisExtent / (maxCrossAxisExtent + crossAxisSpacing))
          .ceil(),
    );
    final double usableCrossAxisExtent = max(
      0.0,
      constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1),
    );
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final double childMainAxisExtent =
        childCrossAxisExtent / childAspectRatio + mainAxisExtent;
    return layoutCache = SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithExtentAndRatio oldDelegate) {
    final flag =
        oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.childAspectRatio != childAspectRatio ||
        oldDelegate.mainAxisExtent != mainAxisExtent;
    if (flag) layoutCache = null;
    return flag;
  }
}

class SliverGridDelegateWithMaxCrossAxisExtent extends SliverGridDelegate {
  /// Creates a delegate that makes grid layouts with tiles that have a maximum
  /// cross-axis extent.
  ///
  /// The [maxCrossAxisExtent], [mainAxisExtent], [mainAxisSpacing],
  /// and [crossAxisSpacing] arguments must not be negative.
  /// The [childAspectRatio] argument must be greater than zero.
  SliverGridDelegateWithMaxCrossAxisExtent({
    required this.maxCrossAxisExtent,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
  }) : assert(maxCrossAxisExtent > 0),
       assert(mainAxisSpacing >= 0),
       assert(crossAxisSpacing >= 0),
       assert(childAspectRatio > 0),
       assert(mainAxisExtent == null || mainAxisExtent >= 0);

  /// The maximum extent of tiles in the cross axis.
  ///
  /// This delegate will select a cross-axis extent for the tiles that is as
  /// large as possible subject to the following conditions:
  ///
  ///  - The extent evenly divides the cross-axis extent of the grid.
  ///  - The extent is at most [maxCrossAxisExtent].
  ///
  /// For example, if the grid is vertical, the grid is 500.0 pixels wide, and
  /// [maxCrossAxisExtent] is 150.0, this delegate will create a grid with 4
  /// columns that are 125.0 pixels wide.
  final double maxCrossAxisExtent;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each child.
  final double childAspectRatio;

  /// The extent of each tile in the main axis. If provided it would define the
  /// logical pixels taken by each tile in the main-axis.
  ///
  /// If null, [childAspectRatio] is used instead.
  final double? mainAxisExtent;

  bool _debugAssertIsValid(double crossAxisExtent) {
    assert(crossAxisExtent > 0.0);
    assert(maxCrossAxisExtent > 0.0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(childAspectRatio > 0.0);
    return true;
  }

  SliverGridLayout? layoutCache;
  double? crossAxisExtentCache;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid(constraints.crossAxisExtent));
    if (layoutCache != null &&
        constraints.crossAxisExtent == crossAxisExtentCache) {
      return layoutCache!;
    }
    crossAxisExtentCache = constraints.crossAxisExtent;
    // Ensure a minimum count of 1, can be zero and result in an infinite extent
    // below when the window size is 0.
    final crossAxisCount = max(
      1,
      (constraints.crossAxisExtent / (maxCrossAxisExtent + crossAxisSpacing))
          .ceil(),
    );
    final double usableCrossAxisExtent = max(
      0.0,
      constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1),
    );
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final double childMainAxisExtent =
        mainAxisExtent ?? childCrossAxisExtent / childAspectRatio;
    return layoutCache = SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithMaxCrossAxisExtent oldDelegate) {
    final flag =
        oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.childAspectRatio != childAspectRatio ||
        oldDelegate.mainAxisExtent != mainAxisExtent;
    if (flag) layoutCache = null;
    return flag;
  }
}
