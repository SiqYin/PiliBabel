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

/// 从系统 locale 推断应用语言代码（映射与兜底规则见 [languageCodeFromLocale]）。
String detectSystemLanguageCode() => languageCodeFromLocale(Platform.localeName);

/// 应用启动时的语言入口。两条路**互斥**，各走各的时机：
///
/// * **旧版升级提示（一次性）**：1.0 之前就在用的用户，告知已默认切到
///   B 站官方免费模型。靠 [Pref.uiTranslateUpgradeNoticeShown] 这一个布尔量
///   判「有没有弹过」（不记版本号，少一个要维护的字段）。
/// * **系统语言同步（每次启动）**：检测系统语言，只要「选择应用语言」与它
///   不一致，就跳设置页演一段引导动画并自动切换（见 [kGuidedSetupLanguageSync]）；
///   一致时什么都不发生。新装用户的「自动开启 AI 翻译」也并入这条路径
///   （见 [_syncLanguageWithSystem]）。
///
/// 升级提示弹出的那一轮不再做语言同步：两条路都会跳设置页，叠在一起没法看；
/// 下一轮启动如果语言仍不一致，同步照常进行。
Future<void> showTranslationOnboardingIfNeeded() async {
  if (_showing) return;
  _showing = true;
  try {
    // Wait briefly so the first route / overlay is settled.
    await Future.delayed(const Duration(milliseconds: 700));
    final context = Get.context;
    if (context == null) return;
    // 上面有一次 await（等待首个路由稳定），context 可能已失效，弹窗前再确认一次。
    if (!context.mounted) return;

    if (!Pref.uiTranslateUpgradeNoticeShown) {
      // 「用过本应用」的痕迹。0.3.x 每次启动都会走到那段英文引导并把它置上，
      // 所以老用户必然命中；全新建档则两项都不成立。
      final usedBefore =
          Pref.uiTranslateOnboarded ||
          Pref.uiTranslateApiUrl.isNotEmpty ||
          Pref.uiTranslateModel.isNotEmpty;
      if (usedBefore) {
        await _showUpgradeNotice(context);
        // 关掉之后才落标记：用户确实看过了才算数；中途被系统回收则下次还能
        // 看到，这比「没看到却再也看不到」更稳妥。
        Pref.uiTranslateUpgradeNoticeShown = true;
        return;
      }
      // 全新安装：把「升级提示」这扇一次性门闩直接落上。它服务的对象是
      // 1.0 之前的老用户；新装用户日后自己填了自备 API 也不该被误当成
      // 老用户、弹一次莫名其妙的迁移提示。
      Pref.uiTranslateUpgradeNoticeShown = true;
    }

    await _syncLanguageWithSystem();
  } finally {
    _showing = false;
  }
}

/// 把「选择应用语言」对齐到系统语言（每次启动都检查，只在真正不一致时打扰）。
///
/// * **全新安装**（没有任何用过的痕迹）：沿用 3.6.9 的产品决定 —— 直接用
///   内置官方模型、自动开启 AI 翻译，不弹任何确认框。系统本就是简体中文时，
///   这一步在界面上什么都不会发生（简体中文是原文语言），纯静默。
/// * **语言不一致**：跳设置页演引导动画 —— 滚到「选择应用语言」那一项、
///   弹出语言选择器、停一拍后自动选中系统语言（用户自己先点了就以他点的为准）。
///
/// 「选择应用语言」下方有一枚「跟随系统语言／锁定自选语言」开关：锁定一侧
/// （[Pref.uiTranslateLangFollowSystem] = false）时整个同步跳过 —— 用户明确
/// 说「别带着我的语言走」，启动时就不检测也不打扰。
Future<void> _syncLanguageWithSystem() async {
  final controller = Get.isRegistered<AiSettingController>()
      ? Get.find<AiSettingController>()
      : Get.put(AiSettingController());

  if (!Pref.uiTranslateOnboarded &&
      Pref.uiTranslateApiUrl.isEmpty &&
      Pref.uiTranslateModel.isEmpty) {
    // 全新建档：自动开启（内置官方模型，不花钱）。
    Pref.uiTranslateProvider = TranslateProvider.builtin;
    controller.saveUiTranslateEnabled(true);
    Pref.uiTranslateOnboarded = true;
  }

  // 锁定自选语言：不做检测、不做同步。
  if (!Pref.uiTranslateLangFollowSystem) return;

  final target = detectSystemLanguageCode();
  if (target == Pref.uiTranslateLang) return;

  // 引导里要弹的选择器标题/取消按钮要过 uiTx：当前界面语言不是简体中文时，
  // 先把它们排进最高优先级队列，弹出来就尽量已是用户读得懂的语言。
  UiTranslateService.precache(const ['选择应用语言', '取消']);
  Get.toNamed('/aiTranslate', arguments: kGuidedSetupLanguageSync);
}

/// 从旧版升级上来的用户：告知已默认切到内置的官方免费模型，并说明自备 API 还在。
///
/// 这条文案走 `uiTx`（不写死英文）：受众是已经在用这个应用的人，
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

/// 封面按钮说明弹窗里出现的所有文案，给 [UiTranslateService.precache] 预热用。
const List<String> kCoverButtonsHintStrings = [
  kCoverButtonsHintTitle,
  kCoverButtonsHintTop,
  kCoverButtonsHintMiddle,
  kCoverButtonsHintBottom,
  kCoverButtonsHintAction,
];

/// 首页首次可见时，说明封面左下角那两个按钮各是干什么的。
///
/// 触发条件（缺一不可）：
/// * [Pref.coverButtonsHintShown] 还是 false —— 只弹一次；
/// * 启动语言入口已经处理完（[Pref.uiTranslateUpgradeNoticeShown] 已落）——
///   否则两个弹窗会叠在一起；
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
    UiTranslateService.precache(kCoverButtonsHintStrings);

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
