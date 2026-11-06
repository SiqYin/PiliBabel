import 'package:PiliPlus/pages/setting/ai_setting/controller.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPlus/pages/setting/ui_translate/glossary_tables.dart';
import 'package:PiliPlus/services/ui_translate/app_language.dart';
import 'package:PiliPlus/services/ui_translate/onboarding.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_proxy.dart';
import 'package:PiliPlus/services/ui_translate/translate_provider.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/services/ui_translate/game_glossary.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// 统一「AI 翻译」一级设置页。
/// 这里只管界面翻译；「AI 视频总结」的配置在 我的 → 设置 → 其它设置 → AI 视频总结。
/// 目标语言选择器使用不透明、可滚动的对话框，避免长语言列表覆盖下面的 API Key 输入框；
/// 语言名称以各自原名显示，不送入模型翻译，防止编号批次提示词污染选项标签。
/// 引导式配置的路由参数（见 `services/ui_translate/onboarding.dart`）。
///
/// 引导流程会**当着用户的面**先把这一页滚到可见处，之后分岔：
/// * [kGuidedSetupFirstRun]：新装用户 —— 打开开关（开关自己播放动画）→ 弹语言列表
/// * [kGuidedSetupUpgrade]：从旧版升级的用户 —— 直接弹「翻译引擎」，让他一眼看到
///   已切到内置模型，想切回自备 API 也伸手就能点
/// * [kGuidedSetupAutoEnable]：新装自动开启 —— 滚到 AI 翻译区 + 开关动画 →
///   弹「已开启」单按钮弹窗（系统语言已自动配置，无需选择）
///
/// 目的是让用户完整看一遍「这些设置在哪、长什么样」，而不是被丢一个弹窗就完事。
const String kGuidedSetupFirstRun = 'guidedTranslateFirstRun';
const String kGuidedSetupUpgrade = 'guidedTranslateUpgrade';
const String kGuidedSetupAutoEnable = 'guidedTranslateAutoEnable';

/// 官方接口故障时：替用户切到「自备 API」。
const String kGuidedSetupOutageCustom = 'guidedTranslateOutageCustom';

/// 官方接口恢复后：替用户切回内置官方模型。
const String kGuidedSetupOutageBuiltin = 'guidedTranslateOutageBuiltin';

class UiTranslateSettingPage extends StatefulWidget {
  const UiTranslateSettingPage({
    super.key,
    this.showAppBar = true,
    this.guidedSetup,
  });

  final bool showAppBar;

  /// 见 [kGuidedSetupFirstRun] / [kGuidedSetupUpgrade]。非空时页面自己跑一遍引导。
  final String? guidedSetup;

  @override
  State<UiTranslateSettingPage> createState() => _UiTranslateSettingPageState();
}

class _UiTranslateSettingPageState extends State<UiTranslateSettingPage> {
  /// 引导流程的滚动锚点：挂在页面第一项上（这一页只剩翻译设置）。
  final _aiSectionKey = GlobalKey();
  late int _subtitleChunkSize;
  late int _subtitleConcurrency;
  late int _subtitleContextOverlap;
  late int _subtitlePrefetchCount;

  @override
  void initState() {
    super.initState();
    _subtitleChunkSize = Pref.subtitleChunkSize;
    _subtitleConcurrency = Pref.subtitleConcurrency;
    _subtitleContextOverlap = Pref.subtitleContextOverlap;
    _subtitlePrefetchCount = Pref.subtitleTranslationPrefetchCount;
    final mode = widget.guidedSetup;
    if (mode != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _runGuidedSetup(mode),
      );
    }
  }

  /// 当着用户的面走一遍：滚过去 → 开开关 → 弹语言列表。
  ///
  /// 每一步之间的停顿**是刻意的**：动作本身要被看见，否则新用户根本不知道这些设置
  /// 藏在哪儿、开关长什么样。所有 await 之后都检查 `mounted`，用户中途返回时不会
  /// 因为拿不到 context 而崩 —— 早先那版靠固定延迟「等页面推上来」的做法，就卡在
  /// 这个风险上。
  Future<void> _runGuidedSetup(String mode) async {
    final controller = Get.isRegistered<AiSettingController>()
        ? Get.find<AiSettingController>()
        : Get.put(AiSettingController());

    // 先让用户看清「AI 翻译」这一页长什么样，再滚过去。
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    final sectionContext = _aiSectionKey.currentContext;
    if (sectionContext != null && sectionContext.mounted) {
      await Scrollable.ensureVisible(
        sectionContext,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOut,
      );
    }
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 400));

    // 升级用户：直接把「翻译引擎」打开 —— 让他亲眼看到已切到内置模型，
    // 想切回自己的 API 也就在这一个弹窗里。
    if (mode == kGuidedSetupUpgrade) {
      if (!mounted) return;
      await _showTranslateProviderPicker(context, controller);
      return;
    }

    // 官方接口故障 / 恢复的引导：同样先打开「翻译引擎」，让用户看清有哪两个
    // 选项，停一下再替他完成切换 —— 用户自己点了就以他点的为准。
    if (mode == kGuidedSetupOutageCustom || mode == kGuidedSetupOutageBuiltin) {
      if (!mounted) return;
      await _showTranslateProviderPicker(
        context,
        controller,
        autoPick: mode == kGuidedSetupOutageCustom
            ? TranslateProvider.custom
            : TranslateProvider.builtin,
      );
      return;
    }

    // 新装自动开启：滚到 AI 翻译区 + 开关动画（语言已自动配置），弹单按钮弹窗。
    if (mode == kGuidedSetupAutoEnable) {
      controller.saveUiTranslateEnabled(true);
      // 这两句先插到最高优先级队列：850ms 的开关动画放完，译文基本已经到了，
      // 用户第一眼看到的就是自己的语言，而不是先英文再跳成译文。
      UiTranslateService.precache(kOnboardingDialogStrings);
      await Future.delayed(const Duration(milliseconds: 850));
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Obx(
          () => AlertDialog(
            // 原文是英文（非中文用户也读得懂），译文走 uiTxUrgent。
            title: Text(uiTxUrgent(kAutoEnabledTitle)),
            content: Text(uiTxUrgent(kAutoEnabledBody)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(uiTxUrgent(kAutoEnabledAction)),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // 新装用户（旧路径）：当着面把开关打开（开关会自己播放一次动画），再弹语言列表。
    controller.saveUiTranslateEnabled(true);
    await Future.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    final picked = await promptAppLanguagePicker(
      context,
      controller.uiTranslateLang.value,
    );
    if (picked != null) {
      controller.saveUiTranslateLang(picked);
    }
  }

  int get _subtitleProxyCount {
    try {
      return SubtitleTranslationProxy.parseMany(
        Pref.subtitleTranslationProxies,
        defaultType: Pref.subtitleTranslationProxyType == 'socks5'
            ? SubtitleTranslationProxyType.socks5
            : SubtitleTranslationProxyType.http,
      ).length;
    } on FormatException {
      return 0;
    }
  }

  Future<void> _editSubtitleProxies() async {
    final controller = TextEditingController(
      text: Pref.subtitleTranslationProxies,
    );
    var type = Pref.subtitleTranslationProxyType;
    String? error;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(uiTx('字幕翻译代理')),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'http', label: Text('HTTP')),
                    ButtonSegment(value: 'socks5', label: Text('SOCKS5')),
                  ],
                  selected: {type},
                  onSelectionChanged: (value) =>
                      setDialogState(() => type = value.first),
                ),
                const SizedBox(height: 12),
                Text(
                  uiTx(
                    '每行一个代理：ip:port:user:pass。'
                    '示例：103.82.192.94:15406:w1t8:w1t8。'
                    '每个有效代理在设备直连线路之外增加 6 个并发；'
                    '连接失败的代理会被跳过，翻译继续走设备 IP。',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  minLines: 4,
                  maxLines: 8,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: '103.82.192.94:15406:w1t8:w1t8',
                    errorText: error,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(uiTx('取消')),
            ),
            FilledButton(
              onPressed: () {
                try {
                  SubtitleTranslationProxy.parseMany(
                    controller.text,
                    defaultType: type == 'socks5'
                        ? SubtitleTranslationProxyType.socks5
                        : SubtitleTranslationProxyType.http,
                  );
                  Pref.subtitleTranslationProxies = controller.text;
                  Pref.subtitleTranslationProxyType = type;
                  Navigator.pop(context);
                  setState(() {});
                } on FormatException {
                  setDialogState(
                    () => error = uiTx('格式无效，请使用 ip:port:user:pass'),
                  );
                }
              },
              child: Text(uiTx('保存')),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AiSettingController>()
        ? Get.find<AiSettingController>()
        : Get.put(AiSettingController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // AppBar 在下面那个 body Obx 之外，标题也得自己包一层，
      // 否则译文到了它不会刷新（会一直停在原文）。
      appBar: widget.showAppBar
          ? AppBar(title: Obx(() => Text(uiTx('AI 翻译'))))
          : null,
      body: Obx(() {
        UiTranslateService.to.revision.value;
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // 引导流程会滚到这里，所以锚点要挂 key。
            // 「AI 视频总结」已移回 我的 → 设置 → 其它设置（与 PiliNara 同位置）；
            // 这一页只剩翻译设置，因此不再需要分节标题 —— 大标题「AI 翻译」就是它。
            KeyedSubtree(
              key: _aiSectionKey,
              child: Obx(
                () => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(uiTx('启用 AI 翻译')),
                  subtitle: Text(uiTx('将界面与外文内容翻译为所选应用语言')),
                  value: controller.uiTranslateEnabled.value,
                  onChanged: controller.saveUiTranslateEnabled,
                ),
              ),
            ),
            Obx(() {
              final enabled = controller.uiTranslateEnabled.value;
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(uiTx('标题完全显示')),
                subtitle: Text(
                  uiTx(
                    enabled
                        ? '首页与动态的视频方块会纵向拉长，搜索页的热搜条目会变成上下两行，尽量完整显示翻译后的标题'
                        : '开启 AI 翻译后生效；当前翻译已关闭',
                  ),
                ),
                value: Pref.videoTitleFull,
                onChanged: (value) {
                  Pref.videoTitleFull = value;
                  setState(() {});
                  // 网格的 mainAxisExtent 是构建时读的，不强制重建的话
                  // 关掉开关后方块高度收不回去。
                  Get.forceAppUpdate();
                },
              );
            }),
            // 官方 AI 原声翻译声轨（B 站自己生成的外语配音）要不要跟着界面语言走。
            // 只影响「有官方声轨」的稿件；没有的照原声播放，我们不做本地合成兜底。
            // 必须包在 Obx 里：uiTx 只负责把原文排进翻译队列，
            // 译文回来后靠这个 Obx 监听 revision 重建才会换掉。
            // 之前这块直接放在页面体里，所以永远停在中文。
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(uiTx('声轨跟随界面语言')),
                subtitle: Text(
                  uiTx(
                    '稿件带官方 AI 原声翻译声轨、且其中有与界面语言一致的一轨时，'
                    '打开即自动选中；没有就保持原声。需已登录（未登录时官方接口不换流）',
                  ),
                ),
                value: Pref.audioTrackFollowUiLang,
                onChanged: (value) {
                  Pref.audioTrackFollowUiLang = value;
                  setState(() {});
                },
              ),
            ),
            // 术语集：每个词表一个开关，默认全开。点进去是独立页面，
            // 避免把十几个开关平铺在 AI 翻译设置页里。
            Obx(() {
              final total = kGlossaryManifest.length;
              // 计数只按「有开关的词表」算，禁用集合里的历史残留（如 `game`）
              // 不参与，否则 15 个全开会显示 14/15（见 enabledGlossaryTableCount）。
              final on = UiTranslateService.enabledGlossaryTableCount();
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.library_books_outlined),
                title: Text(uiTx('术语集')),
                subtitle: Text(
                  uiTxP(
                    '已内置 {0} 条专业术语，{1} / {2} 个术语集已启用',
                    [
                      kGlossaryNames.length.toString(),
                      on.toString(),
                      total.toString(),
                    ],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Get.to(GlossaryTablesPage.new),
              );
            }),
            // 翻译引擎：内置官方模型（默认、免密钥）/ 自备 API。
            // 两个引擎**共用同一份目标语言清单**，差异只在质量提示上。
            Obx(() {
              final builtin =
                  controller.uiTranslateProvider.value ==
                  TranslateProvider.builtin;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.memory_outlined),
                title: Text(uiTx('翻译引擎')),
                subtitle: Text(
                  builtin
                      ? uiTx('B 站官方免费模型 · 无需密钥 · 开箱即用')
                      : uiTx('自备 API · 自己填接口地址、密钥与模型'),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showTranslateProviderPicker(context, controller),
              );
            }),
            Obx(() {
              final lang = appLanguageByCode(controller.uiTranslateLang.value);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 用独立的滚动对话框而不是 DropdownButtonFormField：语言选项很多，
                  // 原生 dropdown 在屏幕底部会透出/压住下方 API Key 输入框（用户截图
                  // 中看到的重叠问题）。AlertDialog 自带不透明 Material 面板和独立滚动区。
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: uiTx('选择应用语言'),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: const Icon(Icons.translate),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    child: InkWell(
                      onTap: () async {
                        final selected = await promptAppLanguagePicker(
                          context,
                          lang.code,
                        );
                        if (selected != null) {
                          controller.saveUiTranslateLang(selected);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        // Language names are autonyms/identifiers, not UI copy.
                        // Do not send them through AI translation: numbered batch
                        // prompts can leak list indices into the rendered labels.
                        child: Text(lang.name),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 同样必须包 Obx，否则译文回来后不会重建（见上面声轨那处的说明）
                  Obx(
                    () => Text(
                      lang.code == 'zh-CN'
                          ? uiTx(
                              '当前是原文语言（简体中文）：不调用你配置的 API。'
                              '评论区外文可点每条评论下的「翻译」，走 B 站自带的免费翻译。',
                            )
                          : uiTx(
                              '简体中文以外的语言（含繁體中文、粤语、吴语、闽南语等）'
                              '都会用当前选定的翻译引擎翻译。',
                            ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              );
            }),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.subtitles_outlined),
              title: Text(uiTx('每组字幕翻译句数')),
              subtitle: Slider(
                min: 10,
                max: 40,
                divisions: 30,
                value: _subtitleChunkSize.toDouble(),
                onChanged: (value) =>
                    setState(() => _subtitleChunkSize = value.round()),
                onChangeEnd: (value) => Pref.subtitleChunkSize = value.round(),
              ),
              trailing: Text('$_subtitleChunkSize'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.speed_outlined),
              title: Text(uiTx('同时翻译组数')),
              subtitle: Slider(
                min: 1,
                max: 5,
                divisions: 4,
                value: _subtitleConcurrency.toDouble(),
                onChanged: (value) =>
                    setState(() => _subtitleConcurrency = value.round()),
                onChangeEnd: (value) =>
                    Pref.subtitleConcurrency = value.round(),
              ),
              trailing: Text('$_subtitleConcurrency'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.forum_outlined),
              title: Text(uiTx('字幕上下文前置句数')),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Slider(
                    min: 0,
                    max: 8,
                    divisions: 8,
                    value: _subtitleContextOverlap.toDouble(),
                    onChanged: (value) => setState(
                      () => _subtitleContextOverlap = value.round(),
                    ),
                    onChangeEnd: (value) =>
                        Pref.subtitleContextOverlap = value.round(),
                  ),
                  Text(
                    uiTx(
                      '发送分块前的若干原文句，保持人名称谓一致；不影响字幕时间轴。',
                    ),
                  ),
                ],
              ),
              trailing: Text('$_subtitleContextOverlap'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(uiTx('等翻译完成再播放')),
              subtitle: Text(
                uiTx(
                  '开始翻译时暂停视频，字幕全部翻译完成后自动恢复播放',
                ),
              ),
              value: Pref.subtitleTranslationWaitForComplete,
              onChanged: (value) {
                Pref.subtitleTranslationWaitForComplete = value;
                setState(() {});
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(uiTx('实时字幕不足时自动暂停')),
              subtitle: Text(
                uiTx(
                  '缓冲不足时暂停视频，译文达到60秒后自动继续；关闭后视频不中断，但未译区间可能暂时没有字幕',
                ),
              ),
              value: Pref.subtitleTranslationAutoPauseForBuffer,
              onChanged: (value) {
                Pref.subtitleTranslationAutoPauseForBuffer = value;
                setState(() {});
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.playlist_play_outlined),
              title: Text(uiTx('预翻译后续视频')),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Slider(
                    min: 0,
                    max: 5,
                    divisions: 5,
                    value: _subtitlePrefetchCount.toDouble(),
                    onChanged: (value) => setState(
                      () => _subtitlePrefetchCount = value.round(),
                    ),
                    onChangeEnd: (value) =>
                        Pref.subtitleTranslationPrefetchCount = value.round(),
                  ),
                  Text(
                    uiTx(
                      '后台预翻译后续 0–5 个视频/分P；0 表示关闭。当前播放的视频始终优先。',
                    ),
                  ),
                ],
              ),
              trailing: Text(
                _subtitlePrefetchCount == 0
                    ? uiTx('关闭')
                    : '$_subtitlePrefetchCount',
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.hub_outlined),
              title: Text(uiTx('字幕翻译代理（可选）')),
              subtitle: Text(
                _subtitleProxyCount == 0
                    ? uiTxP('未设置：使用设备 IP 的 {0} 个翻译线程', [
                        _subtitleConcurrency,
                      ])
                    : uiTxP(
                        '已设置 {0} 个代理：设备 IP {1} 个 + 代理 {2} 个 = {3} 个线程',
                        [
                          _subtitleProxyCount,
                          _subtitleConcurrency,
                          _subtitleProxyCount *
                              SubtitleTranslationProxyPool.workersPerProxy,
                          _subtitleConcurrency +
                              _subtitleProxyCount *
                                  SubtitleTranslationProxyPool.workersPerProxy,
                        ],
                      ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _editSubtitleProxies,
            ),
            // 只在「自备 API」时展开这三项。选内置时藏起来，但**不清空**用户
            // 已填的值 —— 切回自备立刻还能用（升级用户也是靠这一点保住原配置）。
            Obx(() {
              if (controller.uiTranslateProvider.value ==
                  TranslateProvider.builtin) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _ApiFields(
                    urlCtl: controller.translateApiUrlCtl,
                    keyCtl: controller.translateApiKeyCtl,
                    onUrl: controller.saveTranslateApiUrl,
                    onKey: controller.saveTranslateApiKey,
                  ),
                  _ModelPicker(
                    label: uiTx('翻译模型'),
                    list: controller.translateModelList,
                    current: controller.translateModel,
                    manualCtl: controller.translateModelCtl,
                    loading: controller.isLoadingTranslateModels,
                    onSelect: controller.saveTranslateModel,
                    onFetch: controller.fetchTranslateModels,
                  ),
                  // 思考模式与「测试翻译」**只对自备 API 有意义**，所以放在这一块里
                  // 跟着一起显示/隐藏：
                  // 内置的官方模型是翻译专精模型，本来就该直接出译文 —— 它不需要推理，
                  // 开了只会更慢；接口那头对 `enable_thinking` 也是忽略的（已实测，
                  // 传 true/false 都返回同样的译文）。
                  Obx(
                    () => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(uiTx('思考模式')),
                      subtitle: Text(
                        controller.thinking.value
                            ? uiTx('启用推理，翻译更准但可能更慢')
                            : uiTx('关闭推理，出结果更快（推荐）'),
                      ),
                      value: controller.thinking.value,
                      onChanged: controller.saveThinking,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => FilledButton.tonalIcon(
                        icon: controller.isTesting.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.bolt, size: 18),
                        label: Text(uiTx('测试翻译')),
                        onPressed: controller.isTesting.value
                            ? null
                            : controller.testTranslate,
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 8),
            // 清空缓存**两种引擎都要留**：换了引擎或换回旧语言后想重翻，都靠它。
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_sweep, size: 18),
                label: Text(uiTx('清空缓存')),
                onPressed: controller.clearTranslateCache,
              ),
            ),
            Obx(() {
              final err = Get.isRegistered<UiTranslateService>()
                  ? UiTranslateService.to.lastError.value
                  : null;
              if (err == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  uiTxP('最近错误：{0}', [err]),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            Card(
              color: colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      uiTx('使用说明'),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      uiTx(
                        '• 翻译引擎可选内置（B 站官方免费模型，无需密钥）或自备 API，'
                        '两者共用同一份语言清单\n'
                        '• 视频总结的设置已移到 我的 → 设置 → 其它设置 → AI 视频总结\n'
                        '• 应用语言默认简体中文：只把外文自动译成中文，中文内容不动\n'
                        '• 选择其它语言即把界面与内容整体翻译为该语言\n'
                        '• 升级到 1.0 后已自动切到内置模型；你原先填的接口地址/Key/模型'
                        '原样保留，切回「自备 API」即可复用\n'
                        '• 每条只翻译一次并本地持久固定，切换语言会清缓存重翻',
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        );
      }),
    );
  }
}

/// 官方清单覆盖的语言数 / 清单外的数量，用于选择器顶部的说明。
final int kOfficialLanguageCount = appLanguages.where((e) => e.official).length;
final int kUnofficialLanguageCount = appLanguages
    .where((e) => !e.official)
    .length;

// 列表顺序：1.0.0 之前内置的那 29 种（还没接 B 站官方翻译时的清单）按当年的
// 先后排在最前，其余按原有顺序（英文名 A–Z）跟在后面。常用语言始终在列表上方，
// 不用滚就能点到。
const List<String> _legacyLanguageOrder = <String>[
  'zh-CN',
  'zh-TW',
  'en',
  'ja',
  'ko',
  'yue-Hans',
  'yue-Hant',
  'wuu-Hans',
  'wuu-Hant',
  'nan-CN',
  'nan-TW',
  'ar',
  'fil',
  'fr',
  'de',
  'he',
  'hmn',
  'id',
  'it',
  'ms',
  'mn',
  'ru',
  'es',
  'th',
  'bo',
  'tr',
  'ug',
  'vi',
  'za',
];

final List<AppLanguage> _pickerRows = () {
  final legacy = <AppLanguage>[];
  final rest = <AppLanguage>[];
  for (final l in appLanguages) {
    (_legacyLanguageOrder.contains(l.code) ? legacy : rest).add(l);
  }
  legacy.sort(
    (a, b) => _legacyLanguageOrder
        .indexOf(a.code)
        .compareTo(_legacyLanguageOrder.indexOf(b.code)),
  );
  return <AppLanguage>[...legacy, ...rest];
}();

/// 翻译引擎选择器（内置官方模型 / 自备 API）。
/// [autoPick] 非空时（官方接口故障 / 恢复引导）会替用户做决定：弹窗照常打开，
/// 让用户看清有哪两个选项，1.5 秒后自动选中 [autoPick] 并关闭。用户在这段
/// 时间里自己点了就以他点的为准。
Future<void> _showTranslateProviderPicker(
  BuildContext context,
  AiSettingController controller, {
  TranslateProvider? autoPick,
}) async {
  // 用户先选了之后，延迟回调不能再 pop —— 那时弹窗已经关了，
  // 再 pop 会把设置页本身弹掉。
  var picked = false;
  if (autoPick != null) {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (picked || !context.mounted) return;
      Navigator.of(context, rootNavigator: true).maybePop(autoPick);
    });
  }
  final res = await showDialog<TranslateProvider>(
    context: context,
    // 包一层 Obx：下面那些 uiTx 是在弹窗「打开那一刻」求值的，而译文是异步到的。
    // 不包的话首开时若还没命中缓存，整个弹窗就会一直停在原文上。
    builder: (context) => Obx(
      () => SelectDialog<TranslateProvider>(
        title: uiTx('翻译引擎'),
        value: controller.uiTranslateProvider.value,
        // SelectDialog 只翻 title，选项文案要自己过一遍 uiTx
        values: TranslateProvider.values.map((e) => (e, uiTx(e.desc))).toList(),
      ),
    ),
  );
  picked = true;
  if (res != null) {
    controller.saveUiTranslateProvider(res);
  }
}

/// 目标语言选择器。
///
/// 除了设置页，**首次引导（`services/ui_translate/onboarding.dart`）也会调它**：
/// 用户点 Agree 后设置页刚推上来，立刻弹这个列表让他直接选语言。
/// 返回 null 表示用户取消。
Future<String?> promptAppLanguagePicker(
  BuildContext context,
  String selectedCode,
) {
  var query = '';
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) {
        // 搜索：按自称名过滤，한국어 / français 这种直接能搜到。
        final q = query.trim().toLowerCase();
        final rows = q.isEmpty
            ? _pickerRows
            : _pickerRows
                  .where(
                    (l) =>
                        l.name.toLowerCase().contains(q) ||
                        l.code.toLowerCase().contains(q),
                  )
                  .toList();
        return AlertDialog(
          title: Obx(() {
            UiTranslateService.to.revision.value;
            return Text(uiTx('选择应用语言'));
          }),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.sizeOf(dialogContext).height * 0.62,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(() {
                  UiTranslateService.to.revision.value;
                  return TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      hintText: uiTx('搜索语言的自称名，例如 한국어、français'),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => query = v),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 8),
                  child: Obx(() {
                    UiTranslateService.to.revision.value;
                    return Text(
                      uiTx('按该语言的自称名检索：想找韩语就输 한국어，想找法语就输 français。'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    );
                  }),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: rows.length + 1,
                    itemBuilder: (context, index) {
                      // 第 0 项是覆盖范围说明，跟着列表一起滚。
                      if (index == 0) {
                        // 必须包 Obx：译文是异步到的，没有 Obx 就只在构建那一刻取一次值。
                        return Obx(
                          () => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              // 带插值的整句必须走 uiTxP：Dart 的字符串插值会把「已填好数字的
                              // 整句」当成翻译 key，每条插值结果都是新 key，缓存永远命不中，
                              // 而且模型也不能保证回填后语序还对。uiTxP 把带 {0}/{1} 的模板
                              // 作为稳定 key 送翻，再回填参数。
                              //
                              // 另外**不要写 markdown 强调**：Flutter 的 Text 不解析 markdown，
                              // `**xxx**` 会原样显示成星号。
                              uiTxP(
                                '内置的 B 站官方模型覆盖 {0} 种语言。清单外的 {1} 种'
                                '（繁體中文、吴语、闽南语、壮语等）一样可以选，'
                                '但官方模型不保证效果 —— 想要这几种，建议在'
                                '「翻译引擎」里切换到自备 API。\n\n'
                                '若自行接入 API，还能翻译你自己的模型支持的任何其它语言，'
                                '不限于这份清单。',
                                [
                                  kOfficialLanguageCount,
                                  kUnofficialLanguageCount,
                                ],
                              ),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline,
                                  ),
                            ),
                          ),
                        );
                      }
                      final language = rows[index - 1];
                      final selected = language.code == selectedCode;
                      // 整行包 Obx。**这一步不能省**：下面的 uiTx 是异步拿译文的，没有 Obx 的话
                      // 这一行只在构建那一刻取一次值，译文晚到就永远停在原文上 —— 而「哪一行
                      // 恰好被重建过」取决于滚动时机，于是会出现「同为官方清单外，這行翻了、
                      // 那行没翻」的随机现象。
                      return Obx(() {
                        // 官方条目的 subtitle 是 null，行内一次 uiTx 都不调，也就是这个 Obx
                        // 里没有任何 observable。GetX 4.7.2 下这种行会在构建时抛错，而 release
                        // 不弹红屏、只静默丢行 —— 官方那 151 种语言于是整批从列表里消失，
                        // 只剩清单外那 6 种。所以这里也要显式读一次 revision。
                        UiTranslateService.to.revision.value;
                        // Language names are autonyms; keep them literal instead of asking
                        // the selected target language to translate the language selector.
                        return ListTile(
                          dense: true,
                          selected: selected,
                          // 官方清单外的几种提醒一句：它们能选，但想要好效果得自备模型。
                          subtitle: language.official
                              ? null
                              : Text(
                                  uiTx('官方清单外 · 建议自备 API'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          title: Text(language.name),
                          trailing: selected ? const Icon(Icons.check) : null,
                          onTap: () =>
                              Navigator.pop(dialogContext, language.code),
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Obx(() {
                UiTranslateService.to.revision.value;
                return Text(uiTx('取消'));
              }),
            ),
          ],
        );
      },
    ),
  );
}

/// 一组 API 配置：接口地址 + 密钥（两处功能各用各的实例）。
class _ApiFields extends StatefulWidget {
  const _ApiFields({
    required this.urlCtl,
    required this.keyCtl,
    required this.onUrl,
    required this.onKey,
  });

  final TextEditingController urlCtl;
  final TextEditingController keyCtl;
  final ValueChanged<String> onUrl;
  final ValueChanged<String> onKey;

  @override
  State<_ApiFields> createState() => _ApiFieldsState();
}

class _ApiFieldsState extends State<_ApiFields> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 12),
          child: TextField(
            controller: widget.urlCtl,
            decoration: InputDecoration(
              labelText: uiTx('接口地址（OpenAI 兼容）'),
              hintText: 'https://api.example.com/v1',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.link),
            ),
            onChanged: widget.onUrl,
          ),
        ),
        TextField(
          controller: widget.keyCtl,
          decoration: InputDecoration(
            labelText: uiTx('API Key'),
            hintText: 'sk-...',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.key),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          obscureText: _obscure,
          autocorrect: false,
          enableSuggestions: false,
          onChanged: widget.onKey,
        ),
      ],
    );
  }
}

/// 模型选择：有列表用下拉，否则手动输入；带一个拉取模型列表按钮。
class _ModelPicker extends StatelessWidget {
  const _ModelPicker({
    required this.label,
    required this.list,
    required this.current,
    required this.manualCtl,
    required this.loading,
    required this.onSelect,
    required this.onFetch,
  });

  final String label;
  final RxList<String> list;
  final RxString current;
  final TextEditingController manualCtl;
  final RxBool loading;
  final ValueChanged<String> onSelect;
  final VoidCallback onFetch;

  Widget _fetchSuffix() => IconButton(
    icon: Obx(
      () => loading.value
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh),
    ),
    tooltip: uiTx('拉取模型列表'),
    onPressed: onFetch,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Obx(() {
        if (list.isNotEmpty) {
          return DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: list.contains(current.value) ? current.value : null,
            isExpanded: true,
            items: list
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            decoration: InputDecoration(
              labelText: uiTx(label),
              border: const OutlineInputBorder(),
              isDense: true,
              prefixIcon: const Icon(Icons.smart_toy),
              suffixIcon: _fetchSuffix(),
            ),
            onChanged: (v) {
              if (v != null) onSelect(v);
            },
          );
        }
        return TextField(
          controller: manualCtl,
          decoration: InputDecoration(
            labelText: '${uiTx(label)}${uiTx('（可手填，或点右侧拉取）')}',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.smart_toy),
            suffixIcon: _fetchSuffix(),
          ),
          onChanged: onSelect,
        );
      }),
    );
  }
}
