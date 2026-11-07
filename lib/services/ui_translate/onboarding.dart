import 'dart:async';
import 'dart:io' show Platform;

import 'package:PiliPlus/pages/setting/ai_setting/controller.dart';
import 'package:PiliPlus/pages/setting/ui_translate/view.dart';
import 'package:PiliPlus/services/ui_translate/app_language.dart';
import 'package:PiliPlus/services/ui_translate/translate_provider.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

bool _showing = false;
bool _coverHintShowing = false;

/// 首次引导里默认选中的目标语言（系统语言匹配不到时的兜底）。
const String onboardingFallbackLanguageCode = 'en';

/// 从系统 locale 推断目标语言代码。
///
/// [Platform.localeName] 形如 `vi_VN` / `ja_JP` / `zh_CN` / `en_US`。
/// 取主语言子标签后按优先级匹配：
///   1. 精确匹配（`vi` → `vi`）
///   2. 中文变体：`zh_TW` / `zh_Hant` → `zh-TW`，其余 `zh_*` → `zh-CN`
///   3. 粤语变体：`yue` → `yue-Hant`
///   4. 闽南语变体：`nan_TW` → `nan-TW`，其余 `nan_*` → `nan-CN`
///   5. 吴语变体：`wuu` → `wuu-Hans`
///   6. 都匹配不到 → [onboardingFallbackLanguageCode]
String detectSystemLanguageCode() {
  final locale = Platform.localeName;
  final parts = locale.split(RegExp(r'[_-]'));
  final lang = parts.isNotEmpty ? parts.first.toLowerCase() : '';
  final region = parts.length > 1 ? parts[1].toUpperCase() : '';

  // 精确匹配
  if (appLanguages.any((l) => l.code == lang)) return lang;

  // 中文变体
  if (lang == 'zh') {
    if (region == 'TW' || region == 'HK' || region == 'MO') return 'zh-TW';
    return 'zh-CN';
  }
  // 粤语
  if (lang == 'yue') return region == 'Hans' ? 'yue-Hans' : 'yue-Hant';
  // 闽南语
  if (lang == 'nan') return region == 'TW' ? 'nan-TW' : 'nan-CN';
  // 吴语
  if (lang == 'wuu') return region == 'Hant' ? 'wuu-Hant' : 'wuu-Hans';

  return onboardingFallbackLanguageCode;
}

/// 应用启动时的 AI 翻译引导入口。
///
/// 两条路**互斥、且各只走一次**：
/// * **新装**（没有用过本应用的痕迹）→ 自动识别系统语言 → 自动开启 AI 翻译 →
///   引导动画（滚到 AI 翻译设置区）→ 弹「已开启」单按钮弹窗
/// * **从旧版升级**（用过、或自己配过接口）→ 告知「已默认替你切到 B 站官方免费模型」
///
/// **「只出现一次」靠 [Pref.uiTranslateUpgradeNoticeShown] 这一个布尔量**，不记版本号：
/// 要满足的是「只弹一次」，判据是「有没有弹过」，与上次是什么版本无关，少一个需要
/// 维护和比较的字段。于是 0.3.8 → 1.0.0 会看到一次，而 1.0.0 → 1.0.1 不会再看到。
Future<void> showTranslationOnboardingIfNeeded() async {
  if (_showing || Pref.uiTranslateUpgradeNoticeShown) return;
  _showing = true;

  // 「用过本应用」的痕迹。0.3.x 每次启动都会走到那段英文引导并把它置上，
  // 所以老用户必然命中；全新建档则两项都不成立。
  final usedBefore =
      Pref.uiTranslateOnboarded ||
      Pref.uiTranslateApiUrl.isNotEmpty ||
      Pref.uiTranslateModel.isNotEmpty;

  // Wait briefly so the first route / overlay is settled.
  await Future.delayed(const Duration(milliseconds: 700));
  final context = Get.context;
  if (context == null) {
    _showing = false;
    return;
  }
  // 上面有一次 await（等待首个路由稳定），context 可能已失效，弹窗前再确认一次。
  if (!context.mounted) {
    _showing = false;
    return;
  }

  if (usedBefore) {
    await _showUpgradeNotice(context);
  } else {
    await _autoSetupAndGuide(context);
  }
  // 关掉之后才落标记：用户确实看过了才算数；中途被系统回收则下次还能看到，
  // 这比「没看到却再也看不到」更稳妥。
  Pref.uiTranslateUpgradeNoticeShown = true;
  _showing = false;
}

/// 新装用户：自动识别系统语言 → 自动开启 AI 翻译 → 引导动画 → 单按钮弹窗。
///
/// 不弹任何选择框：直接按系统语言配置好（走 B 站官方免费模型，不花钱），
/// 然后跳到设置页做一段引导动画（滚到 AI 翻译区、开关自己播一次动画），
/// 最后弹「已开启」单按钮弹窗。
Future<void> _autoSetupAndGuide(BuildContext context) async {
  final controller = Get.isRegistered<AiSettingController>()
      ? Get.find<AiSettingController>()
      : Get.put(AiSettingController());

  // 自动识别系统语言并配置
  final lang = detectSystemLanguageCode();
  Pref.uiTranslateProvider = TranslateProvider.builtin;
  controller.saveUiTranslateLang(lang);
  // 自动开启
  controller.saveUiTranslateEnabled(true);
  Pref.uiTranslateOnboarded = true;
  // 两个引导弹窗的文案先排队翻（最高优先级）：等页面动画走完再翻就晚了。
  UiTranslateService.precache(kOnboardingDialogStrings);

  // 跳到设置页做引导动画（滚到 AI 翻译区 + 开关动画），结束后弹单按钮弹窗
  Get.toNamed('/aiTranslate', arguments: kGuidedSetupAutoEnable);
}

/// 从旧版升级上来的用户：告知已默认切到内置的官方免费模型，并说明自备 API 还在。
///
/// 这条文案走 `uiTx`（而不是像新装弹窗那样写死英文）：受众是已经在用这个应用的人，
/// 界面语言多半是中文，需要时也会跟着他们选的目标语言翻译。
Future<void> _showUpgradeNotice(BuildContext context) async {
  final go = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => Obx(
      // uiTx 必须在响应式作用域里，否则译文晚到就永远停在原文（见 1.0.1 的教训）。
      () => AlertDialog(
        title: Text(uiTx('翻译已内置 B 站官方模型')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                uiTx(
                  '1.0 起内置了 B 站开源的免费翻译模型，已默认替你切过去：'
                  '不用再填接口地址和密钥，装好就能翻译。',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                uiTx(
                  '你原先配置的接口地址、密钥和模型都原样保留着。'
                  '想继续用自己的 API，在下方「翻译引擎」里切回「自备 API」即可。',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(uiTx('知道了')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(uiTx('去看看')),
          ),
        ],
      ),
    ),
  );
  if (go == true) {
    // 带着「升级」模式跳过去：设置页会滚到 AI 翻译那一段，并直接弹出引擎选择器，
    // 想切回自备 API 的话伸手就能点。
    Get.toNamed('/aiTranslate', arguments: kGuidedSetupUpgrade);
  }
}


/// 首页「封面上的三个按钮」说明弹窗的文案。
///
/// **故意写成英文**：这两句是「用户还没配好目标语言之前」就出现的说明，
/// 中文原文会让非中文用户完全读不懂；英文原文 + 最高优先级翻译，才能保证
/// 弹窗一出现就有译文。字符串集中在常量里，[UiTranslateService.precache]
/// 与 `uiTxUrgent` 用的是同一份 key，不会因为插值产生新词条。
const String kCoverButtonsHintTitle = 'Three buttons on every cover';
const String kCoverButtonsHintTop =
    'Right button: pre-translates this video\'s danmaku (bullet comments) in '
    'the background.';
const String kCoverButtonsHintMiddle =
    'Middle button: pre-translates this video\'s subtitles in the background.';
const String kCoverButtonsHintBottom =
    'Left button: reads the cover image and translates the text on it.';
const String kCoverButtonsHintAction = 'Got it';

/// 「已开启 AI 翻译」弹窗的文案（同样是英文原文 + 优先翻译）。
const String kAutoEnabledTitle = 'AI translation is on';
const String kAutoEnabledBody =
    'The translation language was taken from your system language. '
    'It runs on bilibili\'s free built-in model — no API key needed.';
const String kAutoEnabledAction = 'Got it';

/// 这些弹窗里出现的所有文案，给 [UiTranslateService.precache] 预热用。
const List<String> kOnboardingDialogStrings = [
  kCoverButtonsHintTitle,
  kCoverButtonsHintTop,
  kCoverButtonsHintMiddle,
  kCoverButtonsHintBottom,
  kCoverButtonsHintAction,
  kAutoEnabledTitle,
  kAutoEnabledBody,
  kAutoEnabledAction,
];

/// 首页首次可见时，说明封面左下角那两个按钮各是干什么的。
///
/// 触发条件（缺一不可）：
/// * [Pref.coverButtonsHintShown] 还是 false —— 只弹一次；
/// * 首次引导已经结束（[Pref.uiTranslateUpgradeNoticeShown]）—— 否则两个弹窗
///   会叠在一起；
/// * 当前路由是首页 `/` —— 用户被引导带去设置页时，不该在那里弹首页的说明。
///
/// 引导结束的时间点并不确定（用户可能停在设置页很久），所以这里用轮询而不是
/// 固定延迟；等不到就放弃，下次启动再弹（标记只在用户真的看过之后才落）。
Future<void> showCoverButtonsHintIfNeeded() async {
  if (_coverHintShowing || Pref.coverButtonsHintShown) return;
  _coverHintShowing = true;
  try {
    // 最多等 45 秒（90 × 500ms）：足够用户看完引导弹窗再退出设置页。
    for (var tick = 0; tick < 90; tick++) {
      if (Pref.coverButtonsHintShown) return;
      final settled =
          Pref.uiTranslateUpgradeNoticeShown && Get.currentRoute == '/';
      if (settled && Get.context != null) break;
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (tick == 89) return;
    }

    // 排队翻这几句，弹出来时就已经是目标语言；uiTxUrgent 只是兜底。
    UiTranslateService.precache(kOnboardingDialogStrings);

    final context = Get.context;
    if (context == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Obx(
        // uiTx 必须放在 Obx 里，译文晚到才能重建（见 1.0.1 的教训）。
        () => AlertDialog(
          title: Text(uiTxUrgent(kCoverButtonsHintTitle)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.comment_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(uiTxUrgent(kCoverButtonsHintTop))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.subtitles_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(uiTxUrgent(kCoverButtonsHintMiddle))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.translate, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(uiTxUrgent(kCoverButtonsHintBottom))),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(uiTxUrgent(kCoverButtonsHintAction)),
            ),
          ],
        ),
      ),
    );
    Pref.coverButtonsHintShown = true;
  } finally {
    _coverHintShowing = false;
  }
}
