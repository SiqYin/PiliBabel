/// 应用/翻译目标语言模型。
///
/// [name] 用该语言的“自称/原语写法”显示在界面上（如 English、日本語、繁體粵語）；
/// [toModel] 是发给翻译模型的提示词（含书写系统、地区用字规范等“只让 AI 知道、
/// 不显示给用户”的说明）；[chineseFamily] 标记该语言属于中文家族（简繁、粤、吴、
/// 闽南等），仅用于分组/展示。
///
/// **注意**：是否跳过翻译只看 `UiTranslateService.isSourceLanguage`，也就是
/// **只有简体中文**（B 站原文语言）跳过；繁体中文、粤语、吴语、闽南语虽然
/// chineseFamily 也是 true，但它们不是原文，仍然要调用 API 翻译。
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
  AppLanguage(
    'zh-CN',
    '简体中文',
    '简体中文（中国大陆用语规范；与原文一致，直接显示原文，不调用翻译 API）',
    chineseFamily: true,
  ),
  AppLanguage(
    'zh-TW',
    '繁體中文',
    '中國台灣地區繁體中文。請將中國大陸簡體中文原文轉換為中國台灣地區繁體中文；嚴格遵循中國台灣地區教育部門《國字標準字體表》及辭典的正體字形、用字和詞彙。使用當地慣用詞；不得輸出簡體字，不得混入粵語、吳語或閩南語詞彙。',
    chineseFamily: true,
  ),
  AppLanguage('en', 'English', 'English'),
  AppLanguage('ja', '日本語', '日本語'),
  AppLanguage('ko', '한국어', '한국어'),
  AppLanguage(
    'yue-Hans',
    '简体粤语',
    '香港粵語口語。請將中國大陸簡體中文原文改寫為自然地道的香港粵語書面白話，使用香港常用粵語詞彙、語氣助詞與表達；以簡體字書寫。使用香港粵語詞彙和句法，不得混入上海話/吳語或閩南語詞彙，也不要逐字硬譯成普通話句式。若原文為閩南語或吳語，仍須翻譯成香港粵語，不得將兩種方言內容接續混寫。',
    chineseFamily: true,
  ),
  AppLanguage(
    'yue-Hant',
    '繁體粵語',
    '香港粵語口語。請將中國大陸簡體中文原文改寫為自然地道的香港粵語書面白話，採用香港繁體字形及香港常用詞彙、語氣助詞與表達。遵循香港繁體中文用字習慣，不採用中國台灣地區專用詞彙；不得混入上海話/吳語或閩南語詞彙，也不要逐字硬譯成普通話句式。若原文為閩南語或吳語，仍須翻譯成香港粵語，不得將兩種方言內容接續混寫。',
    chineseFamily: true,
  ),
  AppLanguage(
    'wuu-Hans',
    '简体吴语',
    '目標語言是上海話為基底的吳語，使用簡體字。請把中國大陸簡體中文原文翻譯／改寫成自然、連貫的上海話書面表達；以上海話為準，參考蘇州話的詞彙與語感，僅在上海話缺少自然說法時借鑑蘇州話。每條輸出都必須是同一種連貫的上海吳語，不得混入閩南語、粵語或普通話句式；嚴禁把上海話和閩南語拼接成混合文本。輸出前自查方言一致性；不確定的詞優先採用上海話常用說法，不要自行拼接其他方言。',
    chineseFamily: true,
  ),
  AppLanguage(
    'wuu-Hant',
    '繁體吳語',
    '目標語言是上海話為基底的吳語，使用繁體字。請把中國大陸簡體中文原文翻譯／改寫成自然、連貫的上海話書面表達；以上海話為準，參考蘇州話的詞彙與語感，僅在上海話缺少自然說法時借鑑蘇州話。繁體字形一律採用《古籍表繁體》（古籍表標準）規定的字形，不採用中國台灣地區教育部門字形標準。每條輸出都必須是同一種連貫的上海吳語，不得混入閩南語、粵語或普通話句式；嚴禁把上海話和閩南語拼接成混合文本。輸出前自查方言一致性；不確定的詞優先採用上海話常用說法，不要自行拼接其他方言。',
    chineseFamily: true,
  ),
  AppLanguage(
    'nan-CN',
    '大陆闽南语',
    '中國大陸閩南語（使用簡體字書寫）。請把中國大陸簡體中文原文翻譯／改寫成自然的閩南語表達；保持閩南語，不得混入吳語或粵語詞彙。',
    chineseFamily: true,
  ),
  AppLanguage(
    'nan-TW',
    '臺灣閩南語',
    '目標語言是中國台灣地區閩南語（使用繁體字）。請把中國大陸簡體中文原文翻譯／改寫成自然的中國台灣地區閩南語表達；嚴格採用中國台灣地區教育部門《臺灣閩南語常用詞辭典》及《國字標準字體表》的用字、正體字形與詞彙標準。保持一致的台灣閩南語，不得混入上海話/吳語或粵語詞彙；不確定的詞優先採用辭典規範，不要自行拼接其他方言。',
    chineseFamily: true,
  ),

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
