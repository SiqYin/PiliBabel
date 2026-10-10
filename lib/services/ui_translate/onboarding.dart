import 'dart:async';

import 'package:PiliPlus/pages/setting/ai_setting/controller.dart';
import 'package:PiliPlus/pages/setting/ui_translate/view.dart';
import 'package:PiliPlus/services/ui_translate/translate_provider.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

bool _showing = false;

/// 首次引导里默认选中的目标语言。
///
/// 弹窗本身用英文、进来的多半正是想把 B 站内容译成英文的人，所以默认英语。
/// 用户可以在紧接着弹出的语言列表里改。
const String onboardingDefaultLanguageCode = 'en';

/// 应用启动时的 AI 翻译引导入口。
///
/// 两条路**互斥、且各只走一次**：
/// * **新装**（没有用过本应用的痕迹）→ 英文弹窗问要不要开启翻译 → 引导式开启
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

  if (usedBefore) {
    await _showUpgradeNotice(context);
  } else {
    await _showFirstRunDialog(context);
  }
  // 关掉之后才落标记：用户确实看过了才算数；中途被系统回收则下次还能看到，
  // 这比「没看到却再也看不到」更稳妥。
  Pref.uiTranslateUpgradeNoticeShown = true;
  _showing = false;
}

/// 新装用户：英文弹窗，问要不要开启翻译。
Future<void> _showFirstRunDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('Turn on AI translation'),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PiliBabel can translate the whole app — menus, video titles, '
              'authors, comments and danmaku — into the language you choose.',
            ),
            SizedBox(height: 12),
            Text(
              "It works out of the box: bilibili's own free translation model "
              'is built in, and no API key is needed. If you would rather use '
              'your own API, you can switch to it later in Settings.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Pref.uiTranslateOnboarded = true;
            Get.back();
          },
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () {
            Pref.uiTranslateOnboarded = true;
            Get.back();
            _startAiTranslation();
          },
          child: const Text('Agree'),
        ),
      ],
    ),
  );
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

/// 新装那条路：开翻译 → 内置模型 → 默认英语 → 进设置页 → 弹语言列表。
///
/// 顺序有讲究：**先定语言再交给设置页开开关** —— 开启时会 `prewarm()`，那一步要按
/// 最终语言去预热。
void _startAiTranslation() {
  final controller = Get.isRegistered<AiSettingController>()
      ? Get.find<AiSettingController>()
      : Get.put(AiSettingController());

  // 内置官方引擎：免密钥，装完即可用。
  Pref.uiTranslateProvider = TranslateProvider.builtin;
  // 目标语言先定成英语；**开关先不开** —— 那一下要留给设置页当着用户的面打开。
  controller.saveUiTranslateLang(onboardingDefaultLanguageCode);

  Get.toNamed('/aiTranslate', arguments: kGuidedSetupFirstRun);
}
