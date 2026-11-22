import 'package:PiliPlus/pages/setting/ai_setting/controller.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPlus/pages/setting/ui_translate/glossary_tables.dart';
import 'package:PiliPlus/pages/setting/ui_translate/language_search.dart';
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
/// * [kGuidedSetupUpgrade]：从旧版升级的用户 —— 直接弹「翻译引擎」，让他一眼看到
///   已切到内置模型，想切回自备 API 也伸手就能点
/// * [kGuidedSetupLanguageSync]：系统语言同步 —— 再滚到「选择应用语言」那一项，
///   弹出语言选择器，停一拍后自动选中系统语言（用户自己先点了就以他点的为准）
///
/// 目的是让用户完整看一遍「这些设置在哪、长什么样」，而不是被丢一个弹窗就完事。
const String kGuidedSetupUpgrade = 'guidedTranslateUpgrade';

/// 应用启动时检测到「选择应用语言」与系统语言不一致（见
/// `services/ui_translate/onboarding.dart` 的启动同步），跳进来做语言切换引导。
const String kGuidedSetupLanguageSync = 'guidedTranslateLanguageSync';

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

  /// 见 [kGuidedSetupUpgrade] / [kGuidedSetupLanguageSync]。非空时页面自己跑一遍引导。
  final String? guidedSetup;

  @override
  State<UiTranslateSettingPage> createState() => _UiTranslateSettingPageState();
}

class _UiTranslateSettingPageState extends State<UiTranslateSettingPage> {
  /// 引导流程的滚动锚点：挂在页面第一项上（这一页只剩翻译设置）。
  final _aiSectionKey = GlobalKey();

  /// 语言同步引导的落点：挂在「选择应用语言」那一项上。
  final _languageFieldKey = GlobalKey();

  /// 「跟随系统语言 / 锁定自选语言」开关（默认跟随）。锁定后启动不再做
  /// 语言同步，用户自己选的语言也不会被系统语言顶掉。
  late bool _langFollowSystem;
  late int _subtitleChunkSize;
  late int _subtitleConcurrency;
  late int _subtitleContextOverlap;
  late int _subtitlePrefetchCount;

  @override
  void initState() {
    super.initState();
    _langFollowSystem = Pref.uiTranslateLangFollowSystem;
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

  /// 当着用户的面走一遍：先滚到 AI 翻译区看清楚这一页，再按模式分岔。
  ///
  /// 每一步之间的停顿**是刻意的**：动作本身要被看见，否则用户根本不知道这些设置
  /// 藏在哪儿、长什么样。所有 await 之后都检查 `mounted`，用户中途返回时不会
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

    // 系统语言同步：从 AI 翻译区顶部再一步一步走到「选择应用语言」那一项，
    // 弹出选择器让用户看清清单，停一拍后自动选中系统语言。
    if (mode == kGuidedSetupLanguageSync) {
      final fieldContext = _languageFieldKey.currentContext;
      if (fieldContext != null && fieldContext.mounted) {
        await Scrollable.ensureVisible(
          fieldContext,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOut,
        );
      }
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      final target = detectSystemLanguageCode();
      // 从启动检测到弹窗之间隔着几秒动画，期间语言可能已被别处改动；
      // 已一致就不要再「替」用户选一遍。
      if (target == controller.uiTranslateLang.value) return;
      final picked = await promptAppLanguagePicker(
        context,
        controller.uiTranslateLang.value,
        autoPick: target,
      );
      if (picked != null) {
        controller.saveUiTranslateLang(picked);
      }
    }
  }

  /// 保存「跟随系统语言 / 锁定自选语言」开关。
  ///
  /// 切回「跟随」时**立刻对齐一次**：当前语言与系统语言不一致的话，当场弹出
  /// 选择器并代选系统语言（与启动同步同一套代选节奏），不用等下次启动；
  /// 切到「锁定」什么都不做 —— 锁定的意思就是从现在起别动我的语言。
  Future<void> _saveLangFollowSystem(bool value) async {
    if (_langFollowSystem == value) return;
    setState(() => _langFollowSystem = value);
    Pref.uiTranslateLangFollowSystem = value;
    if (!value) return;

    final controller = Get.isRegistered<AiSettingController>()
        ? Get.find<AiSettingController>()
        : Get.put(AiSettingController());
    final target = detectSystemLanguageCode();
    if (target == controller.uiTranslateLang.value) return;
    // 选择器标题/取消按钮先排队翻，弹出来尽量已是当前界面语言。
    UiTranslateService.precache(const ['选择应用语言', '取消']);
    if (!mounted) return;
    final picked = await promptAppLanguagePicker(
      context,
      controller.uiTranslateLang.value,
      autoPick: target,
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
            // 3.8.8：点开视频自动预翻译字幕 / 弹幕，两个开关（默认都开）。
            // 用户用其它语言时，自动那部分该不该替用户跑，现在交给用户决定；
            // 关掉只影响「自动」，手动点封面上的翻译按钮照常可用。
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(uiTx('自动翻译字幕')),
                subtitle: Text(
                  uiTx(
                    '点开视频时自动在后台预翻译字幕（含后台预翻译后续视频）；'
                    '关闭后需要手动点封面上的「翻译字幕」',
                  ),
                ),
                value: Pref.uiTranslateAutoSubtitle,
                onChanged: (value) {
                  Pref.uiTranslateAutoSubtitle = value;
                  setState(() {});
                },
              ),
            ),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(uiTx('自动翻译弹幕')),
                subtitle: Text(
                  uiTx(
                    '点开视频时自动在后台预翻译弹幕（含弹幕载入时的批量预翻译）；'
                    '关闭后需要手动点封面上的「翻译弹幕」',
                  ),
                ),
                value: Pref.uiTranslateAutoDanmaku,
                onChanged: (value) {
                  Pref.uiTranslateAutoDanmaku = value;
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
                  // 语言同步引导会滚到这里（_languageFieldKey）。
                  // 用独立的滚动对话框而不是 DropdownButtonFormField：语言选项很多，
                  // 原生 dropdown 在屏幕底部会透出/压住下方 API Key 输入框（用户截图
                  // 中看到的重叠问题）。AlertDialog 自带不透明 Material 面板和独立滚动区。
                  InputDecorator(
                    key: _languageFieldKey,
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
                  const SizedBox(height: 12),
                  // 「跟随系统语言 / 锁定自选语言」开关（默认跟随）：跟随 =
                  // 每次启动把应用语言对齐到系统语言（见 onboarding 的启动同步），
                  // 不一致时会有引导动画；锁定 = 不再自动切换。文案走 uiTx。
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'follow',
                          label: Text(uiTx('跟随系统语言')),
                        ),
                        ButtonSegment(
                          value: 'lock',
                          label: Text(uiTx('锁定自选语言')),
                        ),
                      ],
                      selected: {_langFollowSystem ? 'follow' : 'lock'},
                      onSelectionChanged: (value) =>
                          _saveLangFollowSystem(value.first == 'follow'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    uiTx(
                      _langFollowSystem
                          ? '已跟随系统语言：每次启动自动把应用语言对齐到当前系统语言'
                          : '已锁定自选语言：不再随系统语言自动切换，以你在上面选的语言为准',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
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
/// 除了设置页，**系统语言同步引导（`services/ui_translate/onboarding.dart` →
/// [kGuidedSetupLanguageSync]）也会调它**：设置页滚到「选择应用语言」后弹这个列表，
/// 让用户看清清单后自动选中系统语言。返回 null 表示用户取消。
///
/// [autoPick] 非空时（语言同步引导）：弹窗照常打开，让用户看清清单，1.5 秒后
/// 替他选中 [autoPick] 并关闭；这段时间里用户自己点了（选了别的语言或取消）
/// 就以他点的为准。与「翻译引擎」故障引导的代选是同一套节奏。
///
/// **3.8.8 修复**：搜索框此前完全失效（3.8.2 起监听器只更新了 query 变量、
/// 从不触发重建，输入什么都不出结果）。搜索与过滤已抽到独立的
/// [LanguageSearchList] 组件里，由它自己持有状态并 `setState`。
Future<String?> promptAppLanguagePicker(
  BuildContext context,
  String selectedCode, {
  String? autoPick,
}) {
  // 代选只认「弹窗还没被用户处理过」：任何一条用户路径（选中/取消）都会置位，
  // 迟到的定时器就不能再把弹窗（或它下面的页面）顶掉。
  var resolved = false;
  if (autoPick != null) {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (resolved || !context.mounted) return;
      Navigator.of(context, rootNavigator: true).maybePop(autoPick);
    });
  }
  return showDialog<String>(
    context: context,
    // 引导代选期间不允许点弹窗外关闭：点外头等于「没决定」，代选定时器会落空。
    // 手动使用（autoPick 为空）保持默认行为 —— 点外面等于取消。
    barrierDismissible: autoPick == null,
    builder: (dialogContext) => AlertDialog(
      title: Obx(() {
        touchUiTranslateRevision();
        return Text(uiTx('选择应用语言'));
      }),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.sizeOf(dialogContext).height * 0.62,
        child: LanguageSearchList(
          selectedCode: selectedCode,
          onSelected: (code) {
            resolved = true;
            Navigator.pop(dialogContext, code);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            resolved = true;
            Navigator.pop(dialogContext);
          },
          child: Obx(() {
            touchUiTranslateRevision();
            return Text(uiTx('取消'));
          }),
        ),
      ],
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
