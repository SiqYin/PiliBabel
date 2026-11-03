import 'package:PiliPlus/pages/setting/ui_translate/view.dart';
import 'package:PiliPlus/services/ui_translate/translate_provider.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

bool _checking = false;

/// 应用启动时检查 B 站官方翻译（Index-Translate）是否可用，并按结果引导用户。
///
/// 两种情形：
/// * 当前用内置官方模型、但官方接口挂了 —— 弹英文提示，让用户在
///   「知道了」和「改用我自己的 AI 翻译配置」之间选；
/// * 用户当初就是被上一次故障引导切到自备 API 的、而官方现在恢复了 ——
///   弹提示问是否切回。这条文案走 `uiTx`，因为此时用户自己的翻译已经能用。
///
/// 只在「启用 AI 翻译」打开时检查：翻译没开的时候，官方接口挂没挂与用户无关，
/// 不该被打扰。
Future<void> checkBuiltinTranslateOutage() async {
  if (_checking) return;
  _checking = true;
  try {
    if (!Pref.uiTranslateEnabled) return;
    // 和首次引导一样，先等首个路由稳定，避免弹窗压在启动画面上。
    await Future.delayed(const Duration(milliseconds: 900));

    final provider = Pref.uiTranslateProvider;
    // 用户自己在用自备 API、又不是被故障引导切过去的，就没必要探测官方接口。
    if (provider != TranslateProvider.builtin &&
        !Pref.uiTranslateOutageSwitched) {
      return;
    }

    final healthy = await UiTranslateService.pingBuiltin();
    final context = Get.context;
    if (context == null) return;

    if (provider == TranslateProvider.builtin) {
      if (healthy) {
        // 官方恢复：清掉「已忽略」，下次再挂还能提示一次。
        Pref.uiTranslateOutageDismissed = false;
        return;
      }
      if (Pref.uiTranslateOutageDismissed) return;
      // 这段中间隔着 await（pingBuiltin），context 可能已经失效，弹窗前再确认一次。
      if (!context.mounted) return;
      await _showOutageDialog(context);
    } else {
      if (!healthy) return;
      if (!context.mounted) return;
      await _showRecoveredDialog(context);
    }
  } catch (_) {
    // 检测本身出问题绝不能影响启动，静默退出。
  } finally {
    _checking = false;
  }
}

/// 官方接口故障：**文案写死英文**。
///
/// 这时候翻译正是不可用的，走 uiTx 只会让用户看到中文原文；英文对非中文用户
/// 至少可读。与首次引导弹窗的做法一致。
Future<void> _showOutageDialog(BuildContext context) async {
  final useOwn = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('Index Translate is down'),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "bilibili's built-in translation service (Index Translate) is "
              'currently unavailable, so new content cannot be translated. '
              'Anything translated earlier is still shown as before.',
            ),
            SizedBox(height: 12),
            Text(
              'You can keep using the app and wait for it to come back, or '
              'switch to your own AI translation API.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Got it'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Use my own API'),
        ),
      ],
    ),
  );

  if (useOwn == true) {
    // 记住「是被故障引导切过去的」：官方恢复后才提示是否切回。
    Pref.uiTranslateOutageSwitched = true;
    // 引导动画：当着用户的面切到 我的 → 设置 → AI 翻译 → 翻译引擎。
    Get.toNamed('/aiTranslate', arguments: kGuidedSetupOutageCustom);
  } else {
    // 什么都不动，只记住别再反复弹；官方恢复时自动清掉。
    Pref.uiTranslateOutageDismissed = true;
  }
}

/// 官方接口恢复：文案走 `uiTx`（此时用户自己的 AI 翻译是能用的）。
Future<void> _showRecoveredDialog(BuildContext context) async {
  final back = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => Obx(
      // uiTx 必须在响应式作用域里，否则译文晚到就永远停在原文。
      () => AlertDialog(
        title: Text(uiTx('B 站官方翻译已恢复')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                uiTx(
                  'Index Translate 已经可以正常翻译了。'
                  '你之前因为官方接口故障，切到了自己的 AI 翻译配置。',
                ),
              ),
              const SizedBox(height: 12),
              Text(uiTx('是否切换回 B 站官方免费模型？')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(uiTx('保留当前配置')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(uiTx('切换回 B 站官方翻译')),
          ),
        ],
      ),
    ),
  );

  // 无论选哪个，这件事都结束了：用户保留自备配置后不该每次启动都被问一遍。
  Pref.uiTranslateOutageSwitched = false;
  if (back == true) {
    Get.toNamed('/aiTranslate', arguments: kGuidedSetupOutageBuiltin);
  }
}
