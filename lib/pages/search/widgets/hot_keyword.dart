import 'package:PiliPlus/common/assets.dart';
import 'package:PiliPlus/models_new/search/search_trending/list.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/extension/string_ext.dart';
import 'package:PiliPlus/utils/image_utils.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/rendering.dart'
    show
        ContainerRenderObjectMixin,
        MultiChildLayoutParentData,
        RenderBoxContainerDefaultsMixin,
        BoxHitTestResult;
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class SliverHotKeyword extends StatelessWidget {
  final List<SearchTrendingItemModel> hotSearchList;
  final Function? onClick;
  const SliverHotKeyword({
    super.key,
    required this.hotSearchList,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    late final style = TextStyle(
      fontSize: 14,
      color: ColorScheme.of(context).outline,
    );

    late final cacheHeight = (MediaQuery.devicePixelRatioOf(context) * 15.0)
        .round();

    return SliverToBoxAdapter(
      child: Obx(() => _HotKeywordGrid(
        mainAxisSpacing: 5,
        crossAxisSpacing: 0.4,
        crossAxisCount: 2,
        children: hotSearchList
            .map(
              (i) {
                // 条目后面的小标签：`icon` 与服务端下发的图标图片、「直播中」是内置
                // 动图，两者都没法接文本翻译；只有推荐理由是文字。
                final Widget? tag = !i.icon.isNullOrEmpty
                    ? CachedNetworkImage(
                        height: 15,
                        memCacheHeight: cacheHeight,
                        imageUrl: ImageUtils.thumbnailUrl(i.icon!),
                        placeholder: (_, _) => const SizedBox.shrink(),
                      )
                    : i.showLiveIcon == true
                    ? Image.asset(
                        Assets.livingRect,
                        width: 48,
                        height: 15,
                        cacheHeight: cacheHeight,
                      )
                    : i.recommendReason?.isNotEmpty == true
                    ? Text(uiTx(i.recommendReason!), style: style)
                    : null;
                // 「标题完全显示」打开时改成上下两行：关键词最多两行、标签另起一行。
                // 译文通常比中文原文长得多，和标签横排并在一起会把关键词挤成省略号，
                // 用户根本看不出这条热搜是什么。
                final full = Pref.videoTitleFull;
                final keyword = Text(
                  uiTxTight(i.keyword!),
                  overflow: TextOverflow.ellipsis,
                  maxLines: full ? 2 : 1,
                  style: const TextStyle(fontSize: 14),
                );
                return Material(
                  type: .transparency,
                  borderRadius: const .all(.circular(3)),
                  child: InkWell(
                    borderRadius: const .all(.circular(3)),
                    onTap: () => onClick?.call(i.keyword),
                    child: Padding(
                      padding: const .only(left: 2, right: 10),
                      child: Tooltip(
                        message: uiTxTight(i.keyword!),
                        child: full
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const .fromLTRB(6, 5, 0, 0),
                                    child: keyword,
                                  ),
                                  if (tag != null)
                                    Padding(
                                      padding: const .fromLTRB(6, 3, 0, 5),
                                      child: tag,
                                    )
                                  else
                                    const SizedBox(height: 5),
                                ],
                              )
                            : Row(
                                children: [
                                  Flexible(
                                    child: Padding(
                                      padding: const .fromLTRB(6, 5, 0, 5),
                                      child: keyword,
                                    ),
                                  ),
                                  if (tag != null)
                                    Padding(
                                      padding: const .only(left: 4),
                                      child: tag,
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ),
                );
              },
            )
            .toList(),
      )),
    );
  }
}

class _HotKeywordGrid extends MultiChildRenderObjectWidget {
  const _HotKeywordGrid({
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    required super.children,
  }) : assert(crossAxisCount > 0),
       assert(mainAxisSpacing >= 0.0),
       assert(crossAxisSpacing >= 0.0);

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderHotKeywordGrid(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderHotKeywordGrid renderObject,
  ) {
    renderObject
      ..crossAxisCount = crossAxisCount
      ..mainAxisSpacing = mainAxisSpacing
      ..crossAxisSpacing = crossAxisSpacing;
  }
}

class _RenderHotKeywordGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  _RenderHotKeywordGrid({
    required this._crossAxisCount,
    required this._mainAxisSpacing,
    required this._crossAxisSpacing,
  });

  int _crossAxisCount;
  int get crossAxisCount => _crossAxisCount;
  set crossAxisCount(int value) {
    if (_crossAxisCount == value) return;
    _crossAxisCount = value;
    markNeedsLayout();
  }

  double _mainAxisSpacing;
  double get mainAxisSpacing => _mainAxisSpacing;
  set mainAxisSpacing(double value) {
    if (_mainAxisSpacing == value) return;
    _mainAxisSpacing = value;
    markNeedsLayout();
  }

  double _crossAxisSpacing;
  double get crossAxisSpacing => _crossAxisSpacing;
  set crossAxisSpacing(double value) {
    if (_crossAxisSpacing == value) return;
    _crossAxisSpacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = MultiChildLayoutParentData();
    }
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    final childWidth =
        (constraints.maxWidth - mainAxisSpacing * (crossAxisCount - 1)) /
        crossAxisCount;
    final c = BoxConstraints(maxWidth: childWidth);
    // 两遍布局：条目高度不再假定一致。「标题完全显示」打开后关键词最多两行、
    // 标签另起一行，有没有标签、文字长短都会让高度不同；沿用首个子节点的高度
    // 去套整张表，高出来的条目会压到下一行上去。
    final heights = <double>[];
    var child = firstChild;
    while (child != null) {
      child.layout(c, parentUsesSize: true);
      heights.add(child.size.height);
      child = (child.parentData as MultiChildLayoutParentData).nextSibling;
    }
    final count = heights.length;
    final rowCount = count == 0 ? 0 : (count / crossAxisCount).ceil();
    final rowHeights = List<double>.filled(rowCount, 0);
    final rowTops = List<double>.filled(rowCount, 0);
    for (var i = 0; i < count; i++) {
      final r = i ~/ crossAxisCount;
      if (heights[i] > rowHeights[r]) rowHeights[r] = heights[i];
    }
    var top = 0.0;
    for (var r = 0; r < rowCount; r++) {
      rowTops[r] = top;
      top += rowHeights[r] + (r == rowCount - 1 ? 0 : crossAxisSpacing);
    }
    child = firstChild;
    var index = 0;
    while (child != null) {
      final parentData = child.parentData as MultiChildLayoutParentData
        ..offset = Offset(
          (childWidth + mainAxisSpacing) * (index % crossAxisCount),
          rowTops[index ~/ crossAxisCount],
        );
      child = parentData.nextSibling;
      index++;
    }
    size = constraints.constrainDimensions(
      constraints.maxWidth,
      rowCount == 0 ? 0.0 : top,
    );
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
