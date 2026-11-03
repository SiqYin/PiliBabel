import 'package:material_ui/material_ui.dart'
    show BorderRadius, Radius, BoxConstraints, ButtonStyle, VisualDensity;

abstract final class Style {
  static const cardSpace = 8.0;
  static const safeSpace = 12.0;
  static const mdRadius = BorderRadius.all(imgRadius);
  static const imgRadius = Radius.circular(10);
  static const borderRadius6 = BorderRadius.all(.circular(6));
  static const aspectRatio = 16 / 10;
  static const aspectRatio16x9 = 16 / 9;

  /// 横向卡片（VideoCardH 一类）封面的**固定高度**。
  ///
  /// 为什么必须固定：横向卡片里封面用 `AspectRatio`，而 `Row` 给子项的宽度约束是
  /// 无限的，`AspectRatio` 于是**按可用高度反推宽度**。网格的 `mainAxisExtent`
  /// 会随「标题完全显示」开关 +38，一旦封面高度跟着容器走，封面就会被撑大、
  /// 把右侧标题栏挤窄 —— 这是反复出现「封面变大」类问题的**唯一根因**。
  ///
  /// 把封面钉死成这个常量后，容器怎么加高都只影响右侧文字区，封面尺寸恒定。
  /// 所有横向卡片都应使用它，不要各自再算「容器高 - padding」。
  static const cardHCoverHeight = 100.0;

  /// 给「同一组件被两种高度网格复用」用的封面高度。
  ///
  /// 典型是下载页的 `DetailItem`：它既出现在硬编码 `mainAxisExtent: 100` 的网格
  /// （缓存视频 / 文件夹），也出现在走 `GridMixin`、会随标题开关加高到 148 的网格
  /// （正在缓存 / 下载搜索）。这种情况**必须按最矮的容器**算，否则在高的那两页
  /// 封面就会变大。100 - 上下内边距各 5 = 90。
  static const cardHCoverHeightCompact = 90.0;
  static const imgMaxRatio = 2.6;
  static const bottomSheetRadius = BorderRadius.vertical(top: .circular(28));
  static const dialogFixedConstraints = BoxConstraints.tightFor(width: 420);
  static const topBarHeight = 52.0;
  static const buttonStyle = ButtonStyle(
    visualDensity: VisualDensity(horizontal: -2, vertical: -1.25),
    tapTargetSize: .shrinkWrap,
  );
  static const placeHolder = '\uFFFC';
}
