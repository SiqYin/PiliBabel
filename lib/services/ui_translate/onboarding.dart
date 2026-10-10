import 'dart:async';

import 'package:PiliPlus/pages/setting/ai_setting/controller.dart';
import 'package:PiliPlus/pages/setting/ui_translate/view.dart';
import 'package:PiliPlus/services/ui_translate/translate_provider.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

bool _showing = false;

/// 首次引导里默认选中的目标语言。
///
/// 弹窗本身用英文、进来的多半正是想把 B 站内容译成英文的人，所以默认英语。
/// 用户可以在紧接着弹出的语言列表里改。
const String onboardingDefaultLanguageCode = 'en';

/// 首次启动的 AI 翻译引导。
///
/// 文案固定用英文（最需要翻译的用户就是这个受众）。点 Agree 走完整链路：
/// 开翻译 → 切到 B 站官方免费模型（无需密钥）→ 目标语言默认英语 →
/// 跳到 AI 翻译设置页 → 自动弹出语言列表让用户挑。
/// 想自己配 API 的用户也能从设置页进去，这里不强推。
Future<void> showAiTranslateOnboardingIfNeeded() async {
  if (Pref.uiTranslateOnboarded || _showing) return;
  final context = Get.context;
  if (context == null) return;
  _showing = true;
  // Wait briefly so the first route / overlay is settled.
  await Future.delayed(const Duration(milliseconds: 700));
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
            unawaited(_startAiTranslation());
          },
          child: const Text('Agree'),
        ),
      ],
    ),
  );
  _showing = false;
}

/// Agree 之后的链路：开翻译 → 内置模型 → 默认英语 → 进设置页 → 弹语言列表。
///
/// 顺序有讲究：**先定语言再开开关** —— 开启时会 `prewarm()`，那一步要按最终
/// 语言去预热，反过来会先按旧语言发一批请求。
Future<void> _startAiTranslation() async {
  final controller = Get.isRegistered<AiSettingController>()
      ? Get.find<AiSettingController>()
      : Get.put(AiSettingController());

  // 内置官方引擎：免密钥，装完即可用。显式写一次，设置页里的选中态才是对的。
  Pref.uiTranslateProvider = TranslateProvider.builtin;
  controller.saveUiTranslateLang(onboardingDefaultLanguageCode);
  controller.saveUiTranslateEnabled(true);

  Get.toNamed('/aiTranslate');

  // 等设置页推上来、过渡结束再弹语言列表。用户选了才落库，取消就保持英语。
  await Future.delayed(const Duration(milliseconds: 600));
  final context = Get.context;
  if (context == null) return;
  final picked = await promptAppLanguagePicker(
    context,
    controller.uiTranslateLang.value,
  );
  if (picked != null) {
    controller.saveUiTranslateLang(picked);
  }
}
