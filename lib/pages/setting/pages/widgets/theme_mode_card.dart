import 'package:material_ui/material_ui.dart';

import 'package:PiliPlus/pages/setting/pages/widgets/theme_preview_panel.dart';

/// 主题模式（浅色 / 深色 / 跟随系统）的一张选择卡。
///
/// 结构参考 animeko 的 DarkModeSelectPanel：上方一小块真实配色的界面预览，
/// 下方单选圈 + 文字。整卡可点。
class ThemeModeCard extends StatelessWidget {
  const ThemeModeCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.light,
    this.dark,
  });

  /// 模式名，如「浅色」「跟随系统」
  final String label;

  final bool selected;
  final VoidCallback onTap;

  /// 浅色配色；跟随系统模式下会同时用到 [light] 与 [dark] 拼对角预览
  final ColorScheme? light;
  final ColorScheme? dark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final panel = (light != null && dark != null)
        ? MixedThemePreviewPanel(light: light!, dark: dark!)
        // 只有一个配色时按单色画；两者都没给才退回当前主题
        : ThemePreviewPanel(colorScheme: light ?? dark ?? colorScheme);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: .min,
            children: [
              SizedBox(height: 108, child: panel),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Radio(selected: selected, colorScheme: colorScheme),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: selected ? null : colorScheme.onSurfaceVariant,
                        fontWeight: selected ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 自绘单选圈。用 [Radio] 的话在 M3 下还要额外套 [RadioGroup]，
/// 这里只需要一个选中态标记，自绘更省事也更可控。
class _Radio extends StatelessWidget {
  const _Radio({required this.selected, required this.colorScheme});

  final bool selected;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: .circle,
        color: selected ? colorScheme.primary : Colors.transparent,
        border: selected
            ? null
            : Border.all(color: colorScheme.outline, width: 1.6),
      ),
      child: selected
          ? Icon(
              Icons.check_rounded,
              size: 14,
              color: colorScheme.onPrimary,
            )
          : null,
    );
  }
}
