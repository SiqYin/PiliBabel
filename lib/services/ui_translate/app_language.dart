/// 应用/翻译目标语言模型。
///
/// [name] 用该语言的“自称/原语写法”显示在界面上（如 English、日本語、繁體粵語）；
/// [toModel] 是发给翻译模型的提示词（含书写系统、地区用字规范等“只让 AI 知道、
/// 不显示给用户”的说明）；[chineseFamily] 为 true 时按“中文家族”处理：本身已是
/// 中文的内容不再翻译，只有外文才译成中文。
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

/// 排序：置顶组按固定顺序（简中、繁中、英、日、韩、简粤、繁粤、简吴、繁吴、
/// 大陆闽南、台湾闽南）；其余语言按其英文名首字母 A–Z 排序（界面显示各自原语）。
const List<AppLanguage> appLanguages = <AppLanguage>[
  // ===== 置顶组（固定顺序）=====
  AppLanguage('zh-CN', '简体中文', '简体中文（中国大陆用语规范）', chineseFamily: true),
  AppLanguage('zh-TW', '繁體中文', '繁體中文（遵循台湾教育部《国字标准字体》与用字用词标准）', chineseFamily: true),
  AppLanguage('en', 'English', 'English'),
  AppLanguage('ja', '日本語', '日本語'),
  AppLanguage('ko', '한국어', '한국어'),
  AppLanguage('yue-Hans', '简体粤语', '粤语（书面白话，使用简体中文书写）', chineseFamily: true),
  AppLanguage('yue-Hant', '繁體粵語', '粤语（书面白话，使用繁体中文书写，遵循台湾教育部用字标准）', chineseFamily: true),
  AppLanguage('wuu-Hans', '简体吴语', '吴语（使用简体中文书写）', chineseFamily: true),
  AppLanguage('wuu-Hant', '繁體吳語', '吴语（使用繁体中文书写，遵循台湾教育部用字标准）', chineseFamily: true),
  AppLanguage('nan-CN', '大陆闽南语', '闽南语（使用简体中文书写）', chineseFamily: true),
  AppLanguage('nan-TW', '臺灣閩南語', '闽南语（使用繁体中文书写，严格遵循台湾教育部《国字标准字体》与用字用词标准）', chineseFamily: true),

  // ===== 其余语言（按英文名 A–Z）=====
  AppLanguage('ar', 'العربية', 'العربية (Arabic)'),
  AppLanguage('fil', 'Filipino', 'Filipino (Tagalog)'),
  AppLanguage('fr', 'Français', 'Français'),
  AppLanguage('de', 'Deutsch', 'Deutsch'),
  AppLanguage('he', 'עברית', 'עברית (Hebrew)'),
  AppLanguage('hmn', 'Hmong', 'Hmong'),
  AppLanguage('id', 'Bahasa Indonesia', 'Bahasa Indonesia'),
  AppLanguage('it', 'Italiano', 'Italiano'),
  AppLanguage('ms', 'Bahasa Melayu', 'Bahasa Melayu'),
  AppLanguage('mn', 'Монгол', 'Монгол (Кириллица)'),
  AppLanguage('ru', 'Русский', 'Русский'),
  AppLanguage('es', 'Español', 'Español'),
  AppLanguage('th', 'ไทย', 'ไทย'),
  AppLanguage('bo', 'བོད་སྐད་', 'བོད་སྐད་ (Tibetan)'),
  AppLanguage('tr', 'Türkçe', 'Türkçe'),
  AppLanguage('ug', 'ئۇيغۇرچە', 'ئۇيغۇرچە (Uyghur)'),
  AppLanguage('vi', 'Tiếng Việt', 'Tiếng Việt'),
  AppLanguage('za', 'Vahcuengh', 'Vahcuengh (Zhuang)'),
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
