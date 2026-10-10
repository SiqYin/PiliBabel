import 'package:PiliPlus/models/common/enum_with_label.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';

enum RcmdMode with EnumWithLabel {
  app('App端推荐'),
  web('Web端推荐'),
  merged('App+Web 合并'),
  ;

  /// 展示用原文；翻译放在 getter 里。
  final String _label;
  const RcmdMode(this._label);

  @override
  String get label => uiTx(_label);
}
