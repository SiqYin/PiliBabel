import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/pages/dynamics/widgets/additional_panel.dart';
import 'package:PiliPlus/pages/dynamics/widgets/blocked_item.dart';
import 'package:PiliPlus/pages/dynamics/widgets/content_panel.dart';
import 'package:PiliPlus/pages/dynamics/widgets/module_panel.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

List<Widget> dynContent(
  BuildContext context, {
  required int floor,
  required ThemeData theme,
  required DynamicItemModel item,
  required bool isSave,
  required bool isDetail,
}) {
  final moduleDynamic = item.modules.moduleDynamic;
  return [
    if (item.type != 'DYNAMIC_TYPE_NONE')
      Obx(() {
        // 无条件读取，保证 Obx 始终有依赖（纯图/纯视频动态无正文时也不报错）
        UiTranslateService.to.revision.value;
        return content(
          context,
          theme: theme,
          isSave: isSave,
          isDetail: isDetail,
          item: item,
          floor: floor,
        );
      }),
    module(
      context,
      theme: theme,
      isSave: isSave,
      isDetail: isDetail,
      item: item,
      floor: floor,
    ),
    if (moduleDynamic?.additional case final additional?)
      ?addWidget(
        theme: theme,
        context,
        idStr: item.idStr,
        additional: additional,
        floor: floor,
      ),
    if (moduleDynamic?.major?.blocked case final blocked?)
      blockedItem(context, theme: theme, blocked: blocked),
  ];
}
