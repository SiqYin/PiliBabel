import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/services/ui_translate/app_language.dart';

/// 启动时「系统语言 → 选择应用语言」的映射（app_language.dart 的
/// languageCodeFromLocale，onboarding.dart 的 detectSystemLanguageCode 包一层
/// Platform.localeName 调它）。语言同步引导每次启动都靠它做决定，映射错了
/// 等于每次启动都把用户切到错误的语言。
void main() {
  test('主子标签精确匹配', () {
    expect(languageCodeFromLocale('en_US'), 'en');
    expect(languageCodeFromLocale('ja_JP'), 'ja');
    expect(languageCodeFromLocale('ko_KR'), 'ko');
    expect(languageCodeFromLocale('th_TH'), 'th');
    expect(languageCodeFromLocale('vi_VN'), 'vi');
    expect(languageCodeFromLocale('en'), 'en');
  });

  test('中文变体按地区/文字归位', () {
    expect(languageCodeFromLocale('zh_CN'), 'zh-CN');
    expect(languageCodeFromLocale('zh_SG'), 'zh-CN');
    expect(languageCodeFromLocale('zh_TW'), 'zh-TW');
    expect(languageCodeFromLocale('zh_HK'), 'zh-TW');
    expect(languageCodeFromLocale('zh_MO'), 'zh-TW');
    // 桌面端 locale 可能带文字子标签：zh_Hant* 一律归繁體中文
    expect(languageCodeFromLocale('zh_Hant'), 'zh-TW');
    expect(languageCodeFromLocale('zh_Hant_TW'), 'zh-TW');
  });

  test('方言变体归现行清单（3.8.10 下线的代码不再产出）', () {
    expect(languageCodeFromLocale('yue'), 'yue-Hant');
    expect(languageCodeFromLocale('yue_HK'), 'yue-Hant');
    // 简体粤语（yue-Hans）已下线：系统就算给出 Hans 标签也归繁體粵語
    expect(languageCodeFromLocale('yue_Hans'), 'yue-Hant');
    // 大陆闽南语（nan-CN）已下线：一律归臺灣閩南语
    expect(languageCodeFromLocale('nan'), 'nan-TW');
    expect(languageCodeFromLocale('nan_TW'), 'nan-TW');
    expect(languageCodeFromLocale('wuu'), 'wuu-Hans');
    expect(languageCodeFromLocale('wuu_Hant'), 'wuu-Hant');
  });

  test('清单外语言退回英语兜底', () {
    expect(languageCodeFromLocale('xx_XX'), 'en');
    expect(languageCodeFromLocale(''), 'en');
  });

  test('映射结果必须都在现行清单上（绝不把清单外代码写进偏好）', () {
    const samples = [
      'en_US', 'ja_JP', 'ko_KR', 'th_TH', 'vi_VN', 'zh_CN', 'zh_TW', 'zh_HK',
      'zh_Hant_TW', 'yue', 'yue_Hans', 'nan', 'nan_TW', 'wuu', 'wuu_Hant',
    ];
    for (final locale in samples) {
      final code = languageCodeFromLocale(locale);
      expect(
        appLanguages.any((l) => l.code == code),
        true,
        reason: '$locale → $code 不在 appLanguages 清单里',
      );
    }
  });
}
