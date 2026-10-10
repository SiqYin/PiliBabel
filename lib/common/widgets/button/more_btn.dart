import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:material_ui/material_ui.dart';

/// 「查看更多」按钮。
///
/// [text] 为空时回退到译后的「查看更多」。这里不能用默认参数 `= '查看更多'`：
/// 默认值必须是编译期常量，没法调 uiTx。
Widget moreTextButton({
  String? text,
  required VoidCallback onTap,
  EdgeInsets? padding,
  Color? color,
}) {
  Widget child = Text.rich(
    style: TextStyle(color: color, height: 1),
    strutStyle: const StrutStyle(leading: 0, height: 1),
    TextSpan(
      children: [
        TextSpan(text: text ?? uiTx('查看更多')),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Icon(
            size: 22,
            color: color,
            Icons.keyboard_arrow_right,
          ),
        ),
      ],
    ),
  );
  if (padding != null) {
    child = Padding(padding: padding, child: child);
  }
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: child,
  );
}
