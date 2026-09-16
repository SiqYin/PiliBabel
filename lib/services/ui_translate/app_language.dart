/// 应用/翻译目标语言模型。
///
/// [name] 显示在界面上；[toModel] 是发给翻译模型的提示词（包含书写系统、
/// 地区用字规范等“只让 AI 知道、不显示给用户”的说明）；[chineseFamily]
/// 为 true 时按“中文家族”处理：本身已是中文的内容不再翻译，只有外文才译成中文。
class AppLanguage {
  const AppLanguage(
    this.code,
    this.name,
    this.toModel, {
    this.chineseFamily = false,
  });

  final String code;
  final String name;
  final String toModel;
  final bool chineseFamily;
}

/// 排序规则：
/// - 置顶组按固定顺序：简中、繁中、英、日、韩、简粤、繁粤、简吴、繁吴、
///   大陆闽南、台湾闽南；
/// - 其余语言按其英文名首字母 A–Z 排序。
const List<AppLanguage> appLanguages = <AppLanguage>[
  // ===== 置顶组（固定顺序）=====
  AppLanguage('zh-CN', '简体中文', '简体中文（中国大陆用语规范）', chineseFamily: true),
  AppLanguage('zh-TW', '繁体中文', '繁體中文（遵循台湾教育部《国字标准字体》与用字用词标准）', chineseFamily: true),
  AppLanguage('en', '英语', 'English'),
  AppLanguage('ja', '日语', '日本語'),
  AppLanguage('ko', '韩国语', '한국어'),
  AppLanguage('yue-Hans', '简体粤语', '粤语（书面白话，使用简体中文书写）', chineseFamily: true),
  AppLanguage('yue-Hant', '繁体粤语', '粤语（书面白话，使用繁体中文书写，遵循台湾教育部用字标准）', chineseFamily: true),
  AppLanguage('wuu-Hans', '简体吴语', '吴语（使用简体中文书写）', chineseFamily: true),
  AppLanguage('wuu-Hant', '繁体吴语', '吴语（使用繁体中文书写，遵循台湾教育部用字标准）', chineseFamily: true),
  AppLanguage('nan-CN', '大陆闽南语', '闽南语（使用简体中文书写）', chineseFamily: true),
  AppLanguage('nan-TW', '台湾闽南语', '闽南语（使用繁体中文书写，严格遵循台湾教育部《国字标准字体》与用字用词标准）', chineseFamily: true),

  // ===== 其余语言（按英文名 A–Z）=====
  AppLanguage('ar', '阿拉伯语', 'العربية (Arabic)'),
  AppLanguage('fil', '菲律宾语', 'Filipino (Tagalog)'),
  AppLanguage('fr', '法语', 'Français'),
  AppLanguage('de', '德语', 'Deutsch'),
  AppLanguage('he', '希伯来语', 'עברית (Hebrew)'),
  AppLanguage('hmn', '苗语', 'Hmong'),
  AppLanguage('id', '印尼语', 'Bahasa Indonesia'),
  AppLanguage('it', '意大利语', 'Italiano'),
  AppLanguage('ms', '马来语', 'Bahasa Melayu'),
  AppLanguage('mn', '蒙古语', 'Монгол (Кириллица)'),
  AppLanguage('ru', '俄语', 'Русский'),
  AppLanguage('es', '西班牙语', 'Español'),
  AppLanguage('th', '泰语', 'ไทย'),
  AppLanguage('bo', '藏语', 'བོད་སྐད་ (Tibetan)'),
  AppLanguage('tr', '土耳其语', 'Türkçe'),
  AppLanguage('ug', '维吾尔语', 'ئۇيغۇرچە (Uyghur)'),
  AppLanguage('vi', '越南语', 'Tiếng Việt'),
  AppLanguage('za', '壮语', 'Vahcuengh (Zhuang)'),
];

/// 默认应用语言：简体中文。
const AppLanguage defaultAppLanguage = AppLanguage(
  'zh-CN',
  '简体中文',
  '简体中文（中国大陆用语规范）',
  chineseFamily: true,
);

AppLanguage appLanguageByCode(String code) {
  for (final l in appLanguages) {
    if (l.code == code) return l;
  }
  return defaultAppLanguage;
}
