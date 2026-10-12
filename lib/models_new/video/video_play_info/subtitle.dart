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
    lan = json["lan"];
    isAi = json["type"] == 1;
    lanDoc = '${json["lan_doc"]}${isAi ? '（AI）' : ''}';
    subtitleUrl = json["subtitle_url"];
    subtitleUrlV2 = json["subtitle_url_v2"];
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

  /// 中文家族的字形/地区归一：`zh-cn`/`zh-hans`/`zh-sg` → `hans`，
  /// `zh-tw`/`zh-hk`/`zh-hant`/`zh-mo` → `hant`；非中文返回 null。
  ///
  /// 只对中文做这一层：简繁是两套书写系统，界面语言是简体时不该挑到繁体轨。
  static String? _scriptOf(String code) {
    if (_primaryOf(code) != 'zh') {
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

  @override
  int compareTo(Subtitle other) {
    final thisHasZh = lan.contains('zh');
    final otherHasZh = other.lan.contains('zh');
    if (thisHasZh != otherHasZh) return thisHasZh ? -1 : 1;
    if (isAi != other.isAi) return isAi ? 1 : -1;
    return 0;
  }
}
