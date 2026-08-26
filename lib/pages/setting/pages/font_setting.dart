import 'dart:io';

import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/models/common/danmaku/danmaku_font_sync_mode.dart';
import 'package:PiliPlus/utils/app_font.dart';
import 'package:PiliPlus/utils/danmaku_font.dart';
import 'package:PiliPlus/utils/extension/box_ext.dart';
import 'package:PiliPlus/utils/extension/get_ext.dart';
import 'package:PiliPlus/utils/extension/num_ext.dart';
import 'package:PiliPlus/utils/font_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 弹幕字体来源（下拉内置项）；已导入的独立字体以下拉字符串值表示
enum DanmakuFontSource { global, system }

class FontSettingPage extends StatefulWidget {
  const FontSettingPage({super.key});

  @override
  State<FontSettingPage> createState() => _FontSettingPageState();
}

class _FontSettingPageState extends State<FontSettingPage> {
  String? _selectedFont = Pref.appFont;
  int _selectedWeight = Pref.appFontWeight;
  double _selectedScale = Pref.defaultTextScale;

  /// 弹幕字体选择：DanmakuFontSource 或已导入字体的字体族名
  Object? _selectedDanmaku = _initialDanmakuSelection();

  late final List<String> _fonts;
  late ColorScheme colorScheme;

  static Object? _initialDanmakuSelection() {
    if (!Pref.enableCustomDanmakuFont) {
      return DanmakuFontSource.system;
    }
    return switch (Pref.danmakuFontSyncMode) {
      DanmakuFontSyncMode.system => DanmakuFontSource.system,
      DanmakuFontSyncMode.custom =>
        Pref.customDanmakuFontFamily ?? DanmakuFontSource.global,
      _ => DanmakuFontSource.global,
    };
  }

  @override
  void initState() {
    super.initState();
    _fonts = FontUtils.getFont().toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    colorScheme = ColorScheme.of(context);
  }

  String? get _danmakuFontFamily => switch (_selectedDanmaku) {
    DanmakuFontSource.global => _selectedFont,
    DanmakuFontSource.system => null,
    String family => family,
    _ => null,
  };

  void _saveFontSetting() {
    final (enable, mode) = switch (_selectedDanmaku) {
      DanmakuFontSource.global => (true, DanmakuFontSyncMode.global),
      String _ => (true, DanmakuFontSyncMode.custom),
      _ => (false, DanmakuFontSyncMode.system),
    };

    GStorage.setting.putAllNE({
      SettingBoxKey.appFont: _selectedFont,
      SettingBoxKey.appFontWeight: _selectedWeight,
      SettingBoxKey.defaultTextScale: _selectedScale,
      SettingBoxKey.enableCustomDanmakuFont: enable,
      SettingBoxKey.danmakuFontSyncMode: mode.index,
    });

    Get
      ..back()
      ..updateMyAppTheme();
  }

  Future<void> _importAppFont() async {
    try {
      if (await AppFont.pickAndApply()) {
        setState(() => _selectedFont = Pref.customFontFamily);
      }
    } catch (e) {
      SmartDialog.showToast('字体加载失败: $e');
    }
  }

  Future<void> _deleteAppFont() async {
    final family = Pref.customFontFamily;
    await AppFont.clear();
    setState(() {
      if (_selectedFont == family || family == null) {
        _selectedFont = null;
      }
    });
  }

  Future<void> _importDanmakuFont() async {
    try {
      if (await DanmakuFont.pickAndApply()) {
        setState(() => _selectedDanmaku = Pref.customDanmakuFontFamily);
      }
    } catch (e) {
      SmartDialog.showToast('字体加载失败: $e');
    }
  }

  Future<void> _deleteDanmakuFont() async {
    final family = Pref.customDanmakuFontFamily;
    await DanmakuFont.clear();
    setState(() {
      if (_selectedDanmaku == family || family == null) {
        _selectedDanmaku = DanmakuFontSource.global;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleScaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _selectedFont = null;
              _selectedWeight = -1;
              _selectedScale = 1;
            }),
            child: const Text('重置'),
          ),
          TextButton(
            onPressed: _saveFontSetting,
            child: const Text('确定'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    Text(
                      'abcdefghijklmnopqrstuvwxyz\n'
                      'ABCDEFGHIJKLMNOPQRSTUVWXYZ\n'
                      '1234567890.:,;\'"(!?)+-*/=\n'
                      '${Platform.isWindows
                          ? "中国智造，惠及全球"
                          : Platform.isMacOS || Platform.isIOS
                          ? "汉体书写信息技术标准相容"
                          : "我能吞下玻璃而不伤身体"}\n\n'
                      '注：部分字体可能无法应用',
                      style: TextStyle(
                        fontFamily: _selectedFont,
                        fontWeight: _selectedWeight == -1
                            ? null
                            : FontWeight.values[_selectedWeight],
                        fontSize: 14 * _selectedScale,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '弹幕预览：前方高能反应 666',
                      style: TextStyle(
                        fontFamily: _danmakuFontFamily,
                        fontSize: 14 * _selectedScale,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildItem(
              Row(
                mainAxisSize: .min,
                children: [
                  const Text('字体：', style: TextStyle(fontWeight: .bold)),
                  Expanded(
                    child: DropdownButton<String>(
                      focusColor: Colors.transparent,
                      value: _selectedFont,
                      isExpanded: true,
                      items: [
                        if (Pref.customFontFamily case final importedFamily?)
                          DropdownMenuItem(
                            value: importedFamily,
                            child: Text(
                              '${AppFont.currentFontName ?? importedFamily}（导入）',
                              style: TextStyle(fontFamily: importedFamily),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ..._fonts.map(
                          (font) => DropdownMenuItem(
                            value: font,
                            child: Text(
                              font,
                              style: TextStyle(fontFamily: font),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(
                          () => _selectedFont == value
                              ? _selectedFont = null
                              : _selectedFont = value,
                        );
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: '导入字体文件（TTF/OTF）',
                    icon: const Icon(Icons.file_open_outlined),
                    onPressed: _importAppFont,
                  ),
                  if (Pref.customFontFamily != null)
                    IconButton(
                      tooltip: '删除已导入字体',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _deleteAppFont,
                    ),
                ],
              ),
            ),
            _buildItem(
              Row(
                children: [
                  const Text('字重：', style: TextStyle(fontWeight: .bold)),
                  const SizedBox(
                    width: 40,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '默认/\n'),
                          TextSpan(
                            text: 'w100',
                            style: TextStyle(fontWeight: .w100),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      padding: .zero,
                      value: _selectedWeight.toDouble(),
                      min: -1,
                      max: 8,
                      divisions: 9,
                      label: _selectedWeight == -1
                          ? '默认'
                          : 'w${(_selectedWeight + 1) * 100}',
                      onChanged: (value) {
                        setState(() => _selectedWeight = value.toInt());
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                    child: Align(
                      alignment: .centerRight,
                      child: Text('w900', style: TextStyle(fontWeight: .w900)),
                    ),
                  ),
                ],
              ),
            ),
            _buildItem(
              Row(
                children: [
                  const Text('字号：', style: TextStyle(fontWeight: .bold)),
                  const SizedBox(
                    width: 40,
                    child: Text('小', style: TextStyle(fontSize: 11.9)),
                  ),
                  Expanded(
                    child: Slider(
                      padding: .zero,
                      value: _selectedScale,
                      min: 0.85,
                      max: 1.6,
                      divisions: 15,
                      secondaryTrackValue: 1,
                      label: _selectedScale == 1.0
                          ? '默认'
                          : _selectedScale.toStringAsFixed(2),
                      onChanged: (value) =>
                          setState(() => _selectedScale = value.toPrecision(2)),
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                    child: Align(
                      alignment: .centerRight,
                      child: Text('大', style: TextStyle(fontSize: 22.4)),
                    ),
                  ),
                ],
              ),
            ),
            _buildItem(
              Text(
                '弹幕字体',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: .bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            _buildItem(
              Row(
                mainAxisSize: .min,
                children: [
                  const Text('弹幕：', style: TextStyle(fontWeight: .bold)),
                  Expanded(
                    child: DropdownButton<Object>(
                      focusColor: Colors.transparent,
                      value: _selectedDanmaku,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                          value: DanmakuFontSource.global,
                          child: Text('跟随应用字体'),
                        ),
                        const DropdownMenuItem(
                          value: DanmakuFontSource.system,
                          child: Text('系统默认弹幕字体'),
                        ),
                        if (Pref.customDanmakuFontFamily
                            case final importedFamily?)
                          DropdownMenuItem(
                            value: importedFamily,
                            child: Text(
                              '${DanmakuFont.currentFontName ?? importedFamily}（导入）',
                              style: TextStyle(fontFamily: importedFamily),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(
                          () => _selectedDanmaku == value
                              ? _selectedDanmaku = DanmakuFontSource.global
                              : _selectedDanmaku = value,
                        );
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: '导入弹幕字体文件（TTF/OTF）',
                    icon: const Icon(Icons.file_open_outlined),
                    onPressed: _importDanmakuFont,
                  ),
                  if (Pref.customDanmakuFontFamily != null)
                    IconButton(
                      tooltip: '删除已导入弹幕字体',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _deleteDanmakuFont,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(Widget child) {
    return Container(
      padding: const .symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
        ),
      ),
      child: child,
    );
  }
}
