import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:PiliPlus/common/widgets/custom_icon.dart';
import 'package:PiliPlus/common/widgets/extra_hittest_stack.dart';
import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/models_new/live/live_superchat/item.dart';
import 'package:PiliPlus/pages/live_room/superchat/superchat_card.dart';
import 'package:PiliPlus/plugin/pl_player/utils/fullscreen.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:material_ui/material_ui.dart';

const kFullScreenSCWidth = 255.0;

class FullScreenScSize extends StatefulWidget {
  const FullScreenScSize({super.key});

  @override
  State<FullScreenScSize> createState() => _FullScreenScSizeState();
}

class _FullScreenScSizeState extends State<FullScreenScSize> {
  double _width = Pref.fullScreenSCWidth;
  double _opacity = Pref.fullScreenSCOpacity;
  double _scale = Pref.fullScreenSCScale;
  final _randomSC = SuperChatItem.random;
  late EdgeInsets _padding;
  late ColorScheme _colorScheme;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      landscapeLeftMode();
    } else if (Platform.isIOS) {
      landscapeRightMode();
    }
  }

  @override
  void dispose() {
    if (PlatformUtils.isMobile) {
      if (Pref.horizontalScreen) {
        fullMode();
      } else {
        portraitUpMode();
      }
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final padding = MediaQuery.viewPaddingOf(context);
    _padding = .only(
      right: padding.right + 17,
      left: padding.left + 25,
      bottom: padding.bottom + 25,
    );
    _colorScheme = ColorScheme.of(context);
  }

  void _onReset() {
    _width = kFullScreenSCWidth;
    GStorage.setting.delete(SettingBoxKey.fullScreenSCWidth);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SimpleScaffold(
      appBar: AppBar(
        title: Text(uiTx('全屏 SC 大小设置')),
        actions: [
          TextButton(onPressed: _onReset, child: Text(uiTx('重置'))),
        ],
      ),
      body: Padding(padding: _padding, child: _buildBody),
    );
  }

  Widget get _buildBody {
    return Column(
      children: [
        _slider(
          label: '透明度',
          value: _opacity,
          min: .2,
          max: 1.0,
          onChanged: (v) => setState(() => _opacity = v),
          onEnd: (v) =>
              GStorage.setting.put(SettingBoxKey.fullScreenSCOpacity, v),
        ),
        _slider(
          label: '缩放',
          value: _scale,
          min: .5,
          max: 1.5,
          onChanged: (v) => setState(() => _scale = v),
          onEnd: (v) =>
              GStorage.setting.put(SettingBoxKey.fullScreenSCScale, v),
        ),
        Expanded(
          child: Align(
            alignment: .bottomLeft,
      child: ExtraHitTestStack(
        clipBehavior: .none,
        children: [
          SizedBox(
            width: _width,
            child: IgnorePointer(
              child: Transform.scale(
                scale: _scale,
                alignment: Alignment.bottomLeft,
                child: Opacity(
                  opacity: _opacity,
                  child: SuperChatCard(
                    item: _randomSC,
                    persistentSC: true,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: -17,
            width: 34,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeRight,
              child: GestureDetector(
                behavior: .opaque,
                onHorizontalDragUpdate: _onHorizontalDragUpdate,
                onHorizontalDragEnd: _onHorizontalDragEnd,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: .circle,
                    color: _colorScheme.secondaryContainer.withValues(
                      alpha: .8,
                    ),
                  ),
                  child: Icon(
                    size: 18,
                    CustomIcons.open_in_full_rotate_45,
                    color: _colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ),
            ],
          ),
        ),
      ),
      ],
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onEnd,
  }) => Row(
    children: [
      SizedBox(width: 56, child: Text(uiTx(label))),
      Expanded(
        child: Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          onChangeEnd: onEnd,
        ),
      ),
    ],
  );

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _width = math.max(25.0, _width + details.delta.dx);
    setState(() {});
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    GStorage.setting.put(SettingBoxKey.fullScreenSCWidth, _width);
  }
}
