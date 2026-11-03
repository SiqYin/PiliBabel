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
                // 「标题完全显示」打开时关键词最多两行。
                //
                // 标签**不能另起一行**：译文比中文长得多，常常正好占满行宽，标签再
                // 独占一行的话一条热搜会凭空多出一行，而那一行往往只剩一两个字、
                // 后面全是空白。这里让标签始终和文字同一行（靠右、垂直居中）。
                final full = Pref.videoTitleFull;
                // 标签用 WidgetSpan 直接跟在文字流里：译文常常是一行多出几个字，
                // 第二行还空着大半行，标签就该紧跟在最后一个字后面，而不是被挤到
                // 单独一行（那样一条热搜会白占一行、行间距看着莫名其妙地大）。
                final keyword = Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: uiTxTight(i.keyword!)),
                      if (tag != null)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const .only(left: 4),
                            child: tag,
                          ),
                        ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  // 默认一行；「标题完全显示」打开后两行（不是三行）。
                  // 标签是 WidgetSpan，会随文字流换行，不会独占一行，
                  // 所以两行足够容纳「文字 + 标签」。
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
                        child: Padding(
                          padding: const .fromLTRB(6, 5, 2, 5),
                          child: keyword,
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
