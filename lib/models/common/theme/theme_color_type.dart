import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:material_ui/material_ui.dart';

/// 调色板种子色。
///
/// **按 HCT 色相排序**，让相邻色块在视觉上连续（此前顺序是随手排的，
/// 相邻两格经常跳色，看着突兀）。排成 5 列 × 3 行正好铺满。
///
/// ## 为什么是 15 个而不是原来的 19 个
///
/// 色块画的是 `asColorSchemeSeed` **生成后**的配色方案（primary /
/// tertiary / primaryContainer），而生成规则（FlexTones.material3Legacy）
/// **固定彩度：primary 48、tertiary 24，且 tertiary 色相 = 种子色相 + 60**。
/// 也就是说**种子的明度和饱和度被完全丢弃，色块只由色相决定** ——
/// 两个原始色差很大的种子，只要色相接近，色块就几乎一样。
///
/// 按这个口径实测（色块三色的平均 ΔE，浅色/深色主题都算），删掉下面 4 个后，
/// 剩余 15 个两两最小 ΔE 从 2.0 提升到 8.0：
///
/// | 删除 | 原因 |
/// |---|---|
/// | 默认绿 `#5CB67B` | 与「绿色」色相仅差 10°，色块 ΔE 7.8；品牌色另由默认值承担 |
/// | 灰色 `#9E9E9E` | **渲染出来根本不是灰色**：中性灰经 CAM16 得到的色相是 209.5°，material3Legacy 又强制彩度 48，于是它变成青蓝色，与「蓝绿色」色块 ΔE 仅 2.0（等于重复） |
/// | 浅蓝色 `#03A9F4` | 与「蓝色」色相仅差 11°，色块 ΔE 6.3 |
/// | 棕色 `#795548` | 与「红色」色相仅差 13°，色块 ΔE 7.0 |
///
/// 「红色」被保留（虽然与棕色接近）—— 它是用户预期中的必备色。
/// 「青色」(186°) 与「蓝绿色」(212°) 相差 26°，实测可辨，两者都保留。
const List<({Color color, String label})> colorThemeTypes = [
  (color: Color(0xFFFF7299), label: '粉红色'),
  (color: Color(0xFFF44336), label: '红色'),
  (color: Color(0xFFFF9800), label: '橙色'),
  (color: Color(0xFFFFC107), label: '琥珀色'),
  (color: Color(0xFFFFEB3B), label: '黄色'),
  (color: Color(0xFFCDDC39), label: '酸橙色'),
  (color: Color(0xFF8BC34A), label: '浅绿色'),
  (color: Color(0xFF4CAF50), label: '绿色'),
  (color: Color(0xFF009688), label: '青色'),
  (color: Color(0xFF00BCD4), label: '蓝绿色'),
  (color: Color(0xFF607D8B), label: '蓝灰色'),
  (color: Color(0xFF2196F3), label: '蓝色'),
  (color: Color(0xFF3F51B5), label: '靛蓝色'),
  (color: Color(0xFF673AB7), label: '深紫色'),
  (color: Color(0xFF9C27B0), label: '紫色'),
];

/// 旧 19 色表 → 新 15 色表的**下标迁移**表。
///
/// `Pref.customColor` 存的是数组下标，删色会让下标整体错位：不做迁移，
/// 选了「蓝色」(old 12) 的用户升级后会静默变成别的颜色。表里每一项是
/// 「旧下标 → 新下标」，被删掉的色映射到**视觉最接近**的保留色：
///
/// * 默认绿 → 绿色（同色系）
/// * 浅蓝色 → 蓝色（色相仅差 11°）
/// * 棕色 → 红色（色相仅差 13°）
/// * 灰色 → 蓝绿色（灰色原本就渲染成青蓝色，映射过去保持用户看到的观感不变）
const List<int> _legacyColorIndexMap = [
  7, // 0 默认绿  → 绿色
  0, // 1 粉红色  → 粉红色
  1, // 2 红色    → 红色
  2, // 3 橙色    → 橙色
  3, // 4 琥珀色  → 琥珀色
  4, // 5 黄色    → 黄色
  5, // 6 酸橙色  → 酸橙色
  6, // 7 浅绿色  → 浅绿色
  7, // 8 绿色    → 绿色
  8, // 9 青色    → 青色
  9, // 10 蓝绿色 → 蓝绿色
  11, // 11 浅蓝色 → 蓝色
  11, // 12 蓝色   → 蓝色
  12, // 13 靛蓝色 → 靛蓝色
  14, // 14 紫色   → 紫色
  13, // 15 深紫色 → 深紫色
  10, // 16 蓝灰色 → 蓝灰色
  1, // 17 棕色   → 红色
  9, // 18 灰色   → 蓝绿色
];

/// 新色表的版本号。每次增删颜色都要 +1，否则老用户的下标不会迁移。
const int _colorPaletteRevision = 1;

/// 把旧下标迁移到新表。只需跑一次（靠版本号标记），在 `main()` 里
/// `GStorage.init()` 之后调用。
///
/// 不做迁移的后果是静默的：用户不会看到任何报错，只是主题颜色莫名其妙变了。
void migrateColorPalette() {
  final stored = GStorage.setting.get(SettingBoxKey.colorPaletteRevision);
  if (stored is int && stored >= _colorPaletteRevision) return;

  final old = Pref.customColor;
  if (old >= 0 && old < _legacyColorIndexMap.length) {
    final mapped = _legacyColorIndexMap[old];
    if (mapped != old) {
      GStorage.setting.put(SettingBoxKey.customColor, mapped);
    }
  }
  // 越界（比旧表还大）时不动它，交由 Pref.customColor 的兜底处理
  GStorage.setting.put(SettingBoxKey.colorPaletteRevision, _colorPaletteRevision);
}
