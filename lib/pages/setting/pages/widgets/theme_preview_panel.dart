import 'package:material_ui/material_ui.dart';

/// 主题模式选择卡里的迷你界面预览。
///
/// 按真实界面的骨架（顶栏 / 内容卡片 / 底栏）用当前配色画一遍，
/// 让用户在切换浅色 / 深色之前就看到大致效果，而不是切完才知道。
/// 纯示意，不追求与真实页面像素一致。
class ThemePreviewPanel extends StatelessWidget {
  const ThemePreviewPanel({
    super.key,
    required this.colorScheme,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  final ColorScheme colorScheme;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: ColoredBox(
        color: colorScheme.surface,
        child: Column(
          children: [
            // 顶栏
            SizedBox(
              height: 13,
              child: ColoredBox(
                color: colorScheme.primaryContainer,
                child: Row(
                  children: [
                    const SizedBox(width: 5),
                    Expanded(
                      child: _pill(colorScheme.onPrimaryContainer, height: 4),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
            // 内容卡片
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 7, 6, 5),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    _card(colorScheme.surfaceContainerHighest, 16),
                    const SizedBox(height: 5),
                    _card(colorScheme.surfaceContainerHigh, 22),
                    const Spacer(),
                    // 底部导航的三个点
                    Row(
                      mainAxisAlignment: .spaceAround,
                      children: [
                        _dot(colorScheme.primary),
                        _dot(colorScheme.secondary),
                        _dot(colorScheme.tertiary),
                      ],
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Color color, double height) => Container(
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
    ),
  );

  Widget _dot(Color color) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: .circle),
  );

  Widget _pill(Color color, {required double height}) => Container(
    height: height,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(height),
    ),
  );
}

/// 「跟随系统」用的对角拼接预览：左上浅色、右下深色，
/// 一眼就能看出这个模式会随系统切换。
class MixedThemePreviewPanel extends StatelessWidget {
  const MixedThemePreviewPanel({
    super.key,
    required this.light,
    required this.dark,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  final ColorScheme light;
  final ColorScheme dark;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          Positioned.fill(
            child: ThemePreviewPanel(
              colorScheme: light,
              borderRadius: BorderRadius.zero,
            ),
          ),
          ClipPath(
            clipper: _LowerRightTriangleClipper(),
            child: ThemePreviewPanel(
              colorScheme: dark,
              borderRadius: BorderRadius.zero,
            ),
          ),
        ],
      ),
    );
  }
}

/// 裁出「左下—右上」对角线右下方的三角形区域。
class _LowerRightTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
