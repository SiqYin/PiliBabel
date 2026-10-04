import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/models/common/setting_type.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class CommonSetting extends StatefulWidget {
  const CommonSetting({
    super.key,
    required this.settingType,
    this.showAppBar = true,
  });

  final bool showAppBar;
  final SettingType settingType;

  @override
  State<CommonSetting> createState() => _CommonSettingState();
}

class _CommonSettingState extends State<CommonSetting> {
  late EdgeInsets padding;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    padding = MediaQuery.viewPaddingOf(context);
  }

  @override
  Widget build(BuildContext context) {
    final showAppBar = widget.showAppBar;
    return SimpleScaffold(
      appBar: showAppBar
          ? AppBar(title: Text(uiTx(widget.settingType.title)))
          : null,
      // 列表必须在 Obx 里现取，不能像以前那样在 initState 里缓存成字段：
      // 每个 SettingsModel 的 title/subtitle 都是**构造时**经 uiTx 取译文的，
      // 缓存住之后就再也不会跟着刷新——关闭 AI 翻译后这些小字仍停在译文上。
      // 放进 Obx 里现取，revision 一变（开关翻译/译文回来）就整列表重取。
      body: Obx(() {
        final settings = widget.settingType.settings;
        return ListView.builder(
          key: ValueKey(widget.settingType),
          padding: EdgeInsets.only(
            left: showAppBar ? padding.left : 0,
            right: showAppBar ? padding.right : 0,
            bottom: padding.bottom + 100,
          ),
          itemCount: settings.length,
          itemBuilder: (context, index) => settings[index].widget,
        );
      }),
    );
  }
}
