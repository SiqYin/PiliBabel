/// 应用字体的内置选项与存储取值约定。
///
/// 存储位置：[SettingBoxKey.appFont]（字符串或 null），取值只有三种含义：
///
/// * `null`                        —— 从未设置过（含旧版本升级上来的用户）。
///                                    解析为**内置字体**，即 1.1.0 起的新默认。
/// * [AppFont.systemSentinel]      —— 用户显式选择「系统默认」，解析为 `null`，
///                                    即交给平台默认字体。
/// * 其它字体族名                   —— 系统字体名或已导入字体的族名，原样使用。
///
/// 之所以把「未设置」与「显式选系统默认」区分开：1.1.0 内嵌了霞鹜文楷并希望
/// 老用户也能直接看到，但又要允许用户明确地退回系统字体。两者在旧数据里
/// 都是 `null`，无法区分，于是给「显式系统默认」单独一个哨兵值。
abstract final class AppFont {
  /// 内置字体（随安装包分发）的字体族名。
  ///
  /// 必须与 `pubspec.yaml` 中 `fonts:` 声明的 family 完全一致，
  /// 且该 family 与字体文件内部 name 表的 Family 名相同
  /// （霞鹜文楷 = `LXGW WenKai`），避免同名歧义。
  static const String bundledFamily = 'LXGW WenKai';

  /// 内置字体在界面上显示的名字（中文名，便于识别）
  static const String bundledLabel = '霞鹜文楷';

  /// 内置字体项目主页，用于致谢
  static const String bundledHomepage = 'https://github.com/lxgw/LxgwWenKai';

  /// 「显式选择系统默认」的哨兵值。正常字体族名不会长成这个样子。
  static const String systemSentinel = '__system_default__';

  /// 该存储值是否指向内置字体（含未设置的情形）
  static bool isBundled(String? stored) =>
      stored == null || stored == bundledFamily;

  /// 该存储值是否表示「系统默认」
  static bool isSystem(String? stored) => stored == systemSentinel;

  /// 把存储值解析成实际交给 Flutter 的 `fontFamily`：
  /// 系统默认返回 `null`（用平台默认），其余返回具体字体族名。
  ///
  /// 未设置时返回内置字体：旧版本升级上来的用户会直接看到霞鹜文楷。
  static String? resolve(String? stored) {
    if (isSystem(stored)) return null;
    return stored ?? bundledFamily;
  }
}
