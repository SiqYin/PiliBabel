/// 翻译引擎。
///
/// 两个引擎**共用同一份目标语言清单**（见 `app_language.dart`），差异只在
/// 「清单内的语言质量有官方保证」这条提示上，不在「能不能选」。
///
/// * [builtin]：B 站官方开源的 Index-Translate 免费公网接口。**无需密钥**，
///   装完即可翻译 —— 所有用户的默认值（含从旧版本升级上来的用户，见下）。
/// * [custom]：用户自填的 OpenAI 兼容接口（base URL / 密钥 / 模型）。
///
/// **升级行为**：provider 的默认值就是 [builtin]，所以从 0.3.x 升级到 1.0 的用户
/// 会自动切到官方模型；而他们原先填的 `uiTranslateApiUrl / ApiKey / Model`
/// **原样保留、不会被覆盖**，随时切回 [custom] 即可继续用。
enum TranslateProvider {
  builtin('B站官方模型'),
  custom('自备 API'),
  ;

  final String desc;

  const TranslateProvider(this.desc);

  /// 由枚举名反查。缺省（含旧版本存档里没有这个键）一律 [builtin]。
  static TranslateProvider fromName(String? name) {
    for (final e in values) {
      if (e.name == name) {
        return e;
      }
    }
    return TranslateProvider.builtin;
  }
}

/// 内置引擎的固定配置：B 站官方免费公网推理接口，完全兼容 OpenAI 规范，
/// **不需要 API Key**（`call_api.py` 官方示例同样不带头）。
abstract final class BuiltinTranslate {
  static const String apiUrl = 'https://index-translate.bilibili.com/v1';
  static const String model = 'Index-Translate-35B-A3B';
  static const String apiKey = '';
}
