import 'package:PiliPlus/models/common/enum_with_label.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';

enum RcmdMode with EnumWithLabel {
  app('App端推荐'),
  web('Web端推荐'),
  merged('App+Web 合并'),
  // 与官方 Windows 客户端一致：同一个公开网页接口，改用它的参数组合
  // （plat=1 / feed_version=V1 / x_num·y_num 网格 / 每页 30 条）。
  desktop('桌面端推荐'),
  ;

  /// 展示用原文；翻译放在 getter 里。
  final String _label;
  const RcmdMode(this._label);

  @override
  String get label => uiTx(_label);
}
