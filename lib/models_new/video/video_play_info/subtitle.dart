class Subtitle implements Comparable<Subtitle> {
  late String lan;
  String? lanDoc;
  String? subtitleUrl;
  String? subtitleUrlV2;
  bool isAi = false;

  Subtitle({
    required this.lan,
    this.lanDoc,
    this.subtitleUrl,
    this.isAi = false,
  });

  Subtitle.fromJson(Map<String, dynamic> json) {
    // 接口偶发缺字段（尤其未登录/风控降级时）。以前直接把 null 赋给 late String
    // 会抛类型错误，整段字幕列表解析失败 → 表现为「一条字幕都没有」。
    lan = (json['lan'] as String?)?.trim() ?? '';
    isAi = json['type'] == 1;
    final doc = json['lan_doc'] as String?;
    lanDoc = doc == null || doc.isEmpty
        ? (lan.isEmpty ? null : lan)
        : '$doc${isAi ? '（AI）' : ''}';
    subtitleUrl = json['subtitle_url'] as String?;
    subtitleUrlV2 = json['subtitle_url_v2'] as String?;
  }

  /// 可用来下载字幕的 URL，按优先级排列（主地址 → v2 备用地址）。
  ///
  /// B 站有时只下发 `subtitle_url_v2`，有时主地址 404 而 v2 仍可用。合并前
  /// 所有下载点只读 `subtitleUrl`，前者那种轨会直接被判「没有可用字幕」。
  List<String> get subtitleUrlCandidates {
    final result = <String>[];
    for (final candidate in <String?>[subtitleUrl, subtitleUrlV2]) {
      final value = candidate?.trim();
      if (value != null && value.isNotEmpty && !result.contains(value)) {
        result.add(value);
      }
    }
    return result;
  }

  /// 语言标签（归一化）：剥掉 B 站 AI 轨的 `ai-` 前缀，只留主语言子标签。
  ///
  /// B 站同一门语言会用多种写法下发（`zh-CN` / `zh-Hans` / `ai-zh`），而
  /// 「按界面语言挑轨」只关心是不是同一门语言，所以一律收敛到主语言：
  /// `ai-en` → `en`、`zh-Hant` → `zh`。取不到时返回空串。
  String get langTag => _primaryOf(_stripAiPrefix(lan));

  static String _stripAiPrefix(String code) {
    if (code == 'ai') {
      return '';
    }
    return code.startsWith('ai-') ? code.substring(3) : code;
  }

  static String _primaryOf(String code) {
    final cut = code.indexOf(RegExp('[-_]'));
    return (cut > 0 ? code.substring(0, cut) : code).toLowerCase();
  }

  /// 中文家族主标签。粤语/吴语/闽南语在应用里也分 Hans / Hant 两档，
  /// 字形判定不能只认 `zh`。
  static const Set<String> _chinesePrimaryTags = <String>{
    'zh',
    'cmn',
    'yue',
    'wuu',
    'nan',
    'cdo',
    'cjy',
    'gan',
    'hak',
    'lzh',
  };

  /// 中文家族的字形/地区归一：`zh-cn`/`zh-hans`/`zh-sg` → `hans`，
  /// `zh-tw`/`zh-hk`/`zh-hant`/`zh-mo` → `hant`；非中文返回 null。
  ///
  /// 只对中文家族做这一层：简繁是两套书写系统，界面语言是简体时不该挑到
  /// 繁体轨；其它语言（如 `vi-VN`）里的 `VN` 不能被误读成字形。
  static String? _scriptOf(String code) {
    if (!_chinesePrimaryTags.contains(_primaryOf(code))) {
      return null;
    }
    if (code.contains('hant') ||
        code.contains('tw') ||
        code.contains('hk') ||
        code.contains('mo')) {
      return 'hant';
    }
    if (code.contains('hans') ||
        code.contains('cn') ||
        code.contains('sg')) {
      return 'hans';
    }
    return null;
  }

  /// 轨语言与界面语言的贴合度：3 = 完全一致，2 = 同语言，1 = 同语言但字形不同
  /// （简繁之别），0 = 不匹配。取分数最高的一条，即「跟随界面语言」的选轨结果。
  ///
  /// 用打分而不是直接判等，是因为 B 站下发的写法与界面语言的写法常常对不上：
  /// 界面是 `zh-CN`、轨可能是 `zh-Hans`，界面是 `en`、轨可能是 `ai-en`。
  static int langScore(String trackLan, String target) {
    if (trackLan.isEmpty || target.isEmpty) {
      return 0;
    }
    final a = _stripAiPrefix(trackLan).toLowerCase();
    final b = _stripAiPrefix(target).toLowerCase();
    if (a.isEmpty || b.isEmpty) {
      return 0;
    }
    if (a == b) {
      return 3;
    }
    if (_primaryOf(a) != _primaryOf(b)) {
      return 0;
    }
    final as = _scriptOf(a);
    final bs = _scriptOf(b);
    if (as != null && bs != null && as != bs) {
      return 1;
    }
    return 2;
  }

  /// 这条轨能否**直接当作目标语言字幕**显示（不需要 AI 翻译）。
  ///
  /// 选轨策略、后台源解析、播放轨标签三处必须共用这一个判据，否则会出现
  /// 「播放页说要翻译、后台说 B 站已有译文」这种互相打架的结果。
  ///
  /// 关键点 1：裸 `zh` / `ai-zh` 轨道没有写明字形，对繁體中文目标而言它大概率
  /// 是简体源轨，不能算现成译文 —— 以前后台解析器只比较主语言子标签，把
  /// 所有中文轨都当成 `nativeTarget`，繁中用户因此永远翻不出字幕。
  ///
  /// 关键点 2：`-app-ai` 是**我们自己翻译并落盘**的轨（下载缓存里的
  /// `<主标签>-app-ai`），它本来就是按当时的界面语言生成的。它没有字形子标签，
  /// 若也套用上面的「裸中文不算繁体现成译文」规则，繁中用户打开已缓存的视频
  /// 会被判成「还没有译文」，于是又从中文源重翻一遍。
  bool isNativeTarget(String targetLanguage) {
    if (langScore(lan, targetLanguage) < 2) return false;
    if (lan.toLowerCase().endsWith('-app-ai')) return true;
    final a = _stripAiPrefix(lan).toLowerCase();
    final b = _stripAiPrefix(targetLanguage).toLowerCase();
    return !(_scriptOf(a) == null && _scriptOf(b) == 'hant');
  }

  @override
  int compareTo(Subtitle other) {
    final thisHasZh = lan.contains('zh');
    final otherHasZh = other.lan.contains('zh');
    if (thisHasZh != otherHasZh) return thisHasZh ? -1 : 1;
    if (isAi != other.isAi) return isAi ? 1 : -1;
    return 0;
  }
}
