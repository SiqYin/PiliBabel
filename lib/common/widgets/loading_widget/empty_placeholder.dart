import 'package:PiliPlus/common/assets.dart';
import 'package:PiliPlus/common/widgets/selection_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// 空态占位：数据请求成功、但列表里确实一条都没有时用。
///
/// 与 [HttpError] 的区别是「不提供重试按钮」——没有数据不是失败，再点一次也
/// 还是空的；此前空态复用了 HttpError，于是「0 条评论」和「加载失败」长得
/// 一模一样，都是「还没有评论 + 点击重试」。
class EmptyPlaceholder extends StatelessWidget {
  const EmptyPlaceholder({
    super.key,
    this.isSliver = true,
    this.msg,
    this.safeArea = true,
  });

  final bool isSliver;
  final String? msg;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = Column(
      mainAxisSize: .min,
      mainAxisAlignment: .center,
      crossAxisAlignment: .center,
      children: [
        const SizedBox(height: 40),
        SvgPicture.asset(Assets.error, height: 200),
        const SizedBox(height: 30),
        Padding(
          padding: const .symmetric(horizontal: 16, vertical: 5),
          child: SelectionText(
            msg ?? '没有数据',
            textAlign: .center,
            style: theme.textTheme.titleSmall,
          ),
        ),
        if (safeArea)
          SizedBox(height: 40 + MediaQuery.viewPaddingOf(context).bottom),
      ],
    );

    return isSliver
        ? SliverToBoxAdapter(child: child)
        : SizedBox(width: double.infinity, child: child);
  }
}
