import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'dart:io' show Platform;

import 'package:PiliPlus/common/widgets/animated_height.dart';
import 'package:PiliPlus/common/widgets/color_palette.dart';
import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/main.dart' show MyApp;
import 'package:PiliPlus/models/common/nav_bar_config.dart';
import 'package:PiliPlus/models/common/theme/theme_color_type.dart';
import 'package:PiliPlus/models/common/theme/theme_type.dart';
import 'package:PiliPlus/pages/home/view.dart';
import 'package:PiliPlus/pages/mine/controller.dart';
import 'package:PiliPlus/pages/setting/pages/widgets/theme_mode_card.dart';
import 'package:PiliPlus/pages/setting/widgets/popup_item.dart';
import 'package:PiliPlus/pages/setting/widgets/switch_item.dart';
import 'package:PiliPlus/utils/extension/get_ext.dart';
import 'package:PiliPlus/utils/extension/theme_ext.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/theme_utils.dart';
// mapIndexed 出自 collection：调色板那一段要用
import 'package:collection/collection.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 「主题与色彩」设置页。
///
/// 参照 animeko 的「主题 / 色彩」两段式布局：上半段决定明暗与取色方式，
/// 下半段决定具体配色。区别在于本项目额外保留了 FlexSchemeVariant 调色板风格，
/// 它能整批改变同一色相下所有容器色的生成方式，与选哪个色相互相独立。
class ColorSelectPage extends StatefulWidget {
  const ColorSelectPage({super.key});

  @override
  State<ColorSelectPage> createState() => _ColorSelectPageState();
}

class _ColorSelectPageState extends State<ColorSelectPage> {
  final ctr = Get.put(_ColorSelectController());
  FlexSchemeVariant _dynamicSchemeVariant = Pref.schemeVariant;

  Future<void> _onChanged([bool? val]) async {
    val ??= !ctr.dynamicColor.value;
    if (val && !await MyApp.initPlatformState()) {
      SmartDialog.showToast(uiTx('设备可能不支持动态取色'));
      if (kReleaseMode) {
        return;
      }
    }
    ctr.dynamicColor.value = val;
    await GStorage.setting.put(SettingBoxKey.dynamicColor, val);
    Get.updateMyAppTheme();
  }

  void _setThemeType(ThemeType type) {
    // 我的页也缓存了主题类型，两处都要同步，否则返回后显示不一致
    try {
      Get.find<MineController>().themeType.value = type;
    } catch (_) {}
    ctr.themeType.value = type;
    GStorage.setting.put(SettingBoxKey.themeMode, type.index);
    Get.changeThemeMode(ThemeUtils.themeMode = type.toThemeMode);
  }

  /// 预览用的配色必须与实际生效的配色同源，否则开启动态取色后
  /// 预览会和真实界面对不上。
  ColorScheme _seedScheme(Brightness brightness) =>
      colorThemeTypes[Pref.customColor].color.asColorSchemeSeed(
        _dynamicSchemeVariant,
        brightness,
      );

  ColorScheme? get _dynamicLight =>
      ctr.dynamicColor.value ? MyApp.dynamicColorSchemes.$1 : null;

  ColorScheme? get _dynamicDark =>
      ctr.dynamicColor.value ? MyApp.dynamicColorSchemes.$2 : null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.viewPaddingOf(
      context,
    ).copyWith(top: 0, bottom: 0);
    return SimpleScaffold(
      appBar: AppBar(title: Obx(() => Text(uiTx('主题与色彩')))),
      body: ListView(
        padding: .only(
          bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
        ),
        children: [
          // ─────────────── 主题 ───────────────
          Obx(() {
            final type = ctr.themeType.value;
            final light = _dynamicLight ?? _seedScheme(.light);
            final dark = _dynamicDark ?? _seedScheme(.dark);
            return Row(
              children: [
                Expanded(
                  child: ThemeModeCard(
                    label: uiTx('浅色'),
                    selected: type == .light,
                    light: light,
                    onTap: () => _setThemeType(.light),
                  ),
                ),
                Expanded(
                  child: ThemeModeCard(
                    label: uiTx('深色'),
                    selected: type == .dark,
                    dark: dark,
                    onTap: () => _setThemeType(.dark),
                  ),
                ),
                Expanded(
                  child: ThemeModeCard(
                    label: uiTx('跟随系统'),
                    selected: type == .system,
                    light: light,
                    dark: dark,
                    onTap: () => _setThemeType(.system),
                  ),
                ),
              ],
            );
          }),
          // 动态取色不用 SetSwitchItem：开关自己会先落盘，
          // 而这里需要在写盘之前先探测设备是否支持，不支持时要整项放弃。
          if (!Platform.isIOS)
            Obx(
              () => ListTile(
                title: Text(uiTx('动态取色')),
                subtitle: Text(
                  uiTx('跟随系统壁纸自动取色，仅部分设备支持'),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                leading: const Icon(Icons.palette_outlined),
                trailing: Switch(
                  value: ctr.dynamicColor.value,
                  onChanged: (val) => _onChanged(val),
                ),
                onTap: () => _onChanged(),
              ),
            ),
          // 译文是异步回来的，标题与开关文案都要裹在 Obx 里才会跟着刷新。
          // uiTx 内部会先读一次修订号，所以这些 Obx 都持有合法依赖，不会触发
          // GetX 的「空 Obx」报错。
          Obx(
            () => SetSwitchItem(
              title: uiTx('高对比度深色'),
              subtitle: uiTx('深色模式下背景纯黑，对比度更高，夜间更护眼'),
              leading: const Icon(Icons.contrast),
              setKey: SettingBoxKey.isPureBlackTheme,
              onChanged: (_) => Get.updateMyAppTheme(),
            ),
          ),
          Obx(
            () => SetSwitchItem(
              title: uiTx('视频播放页使用深色主题'),
              subtitle: uiTx('进入播放页时强制使用深色，不受上方主题模式影响'),
              leading: const Icon(Icons.dark_mode_outlined),
              setKey: SettingBoxKey.darkVideoPage,
              onChanged: (_) => Get.updateMyAppTheme(),
            ),
          ),
          // ─────────────── 色彩 ───────────────
          Obx(
            () => PopupListTile<FlexSchemeVariant>(
              enabled: !ctr.dynamicColor.value,
              leading: const Icon(Icons.auto_awesome_outlined),
              title: Text(uiTx('调色板风格')),
              value: () =>
                  (_dynamicSchemeVariant, _dynamicSchemeVariant.variantName),
              itemBuilder: (_) => FlexSchemeVariant.values
                  .map(
                    (e) => PopupMenuItem(value: e, child: Text(e.variantName)),
                  )
                  .toList(),
              onSelected: (value, setState) {
                _dynamicSchemeVariant = value;
                GStorage.setting
                    .put(SettingBoxKey.schemeVariant, value.index)
                    .whenComplete(Get.updateMyAppTheme);
              },
            ),
          ),
          Padding(
            padding: padding + const .all(12),
            child: Obx(
              () => AnimatedHeightWidgetExt(
                expand: !ctr.dynamicColor.value,
                duration: const Duration(milliseconds: 200),
                child: Wrap(
                  alignment: .center,
                  spacing: 22,
                  runSpacing: 18,
                  children: colorThemeTypes.mapIndexed(
                    (i, e) {
                      return GestureDetector(
                        behavior: .opaque,
                        onTap: () {
                          ctr.currentColor.value = i;
                          GStorage.setting
                              .put(SettingBoxKey.customColor, i)
                              .whenComplete(Get.updateMyAppTheme);
                        },
                        child: Column(
                          spacing: 3,
                          children: [
                            ColorPalette(
                              colorScheme: e.color.asColorSchemeSeed(
                                _dynamicSchemeVariant,
                                theme.brightness,
                              ),
                              selected: ctr.currentColor.value == i,
                            ),
                            Text(uiTx(e.label),
                              style: TextStyle(
                                fontSize: 12,
                                color: ctr.currentColor.value != i
                                    ? theme.colorScheme.outline
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
          ),
          Padding(
            padding: padding,
            child: ExcludeFocus(
              child: IgnorePointer(
                child: Container(
                  height: size.height / 2,
                  width: size.width,
                  color: theme.colorScheme.surface,
                  child: const HomePage(preview: true),
                ),
              ),
            ),
          ),
          ExcludeFocus(
            child: IgnorePointer(
              child: NavigationBar(
                destinations: NavigationBarType.values
                    .map(
                      (item) => NavigationDestination(
                        icon: item.icon,
                        label: item.label,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSelectController extends GetxController {
  final RxBool dynamicColor = Pref.dynamicColor.obs;
  final RxInt currentColor = Pref.customColor.obs;
  final Rx<ThemeType> themeType = Pref.themeType.obs;
}
