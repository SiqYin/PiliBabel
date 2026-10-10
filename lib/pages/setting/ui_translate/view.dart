import 'package:PiliPlus/pages/setting/ai_setting/controller.dart';
import 'package:PiliPlus/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPlus/services/ui_translate/app_language.dart';
import 'package:PiliPlus/services/ui_translate/translate_provider.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// 统一「AI 功能」一级设置页。
/// 「AI 视频总结」与「AI 界面翻译」各自使用独立的接口地址 / 密钥 / 模型。
/// 目标语言选择器使用不透明、可滚动的对话框，避免长语言列表覆盖下面的 API Key 输入框；
/// 语言名称以各自原名显示，不送入模型翻译，防止编号批次提示词污染选项标签。
/// 引导式配置的路由参数（见 `services/ui_translate/onboarding.dart`）。
///
/// 两种模式都会**当着用户的面**先滚到「AI 界面翻译」那一段，之后分岔：
/// * [kGuidedSetupFirstRun]：新装用户 —— 打开开关（开关自己播放动画）→ 弹语言列表
/// * [kGuidedSetupUpgrade]：从旧版升级的用户 —— 直接弹「翻译引擎」，让他一眼看到
///   已切到内置模型，想切回自备 API 也伸手就能点
///
/// 目的是让用户完整看一遍「这些设置在哪、长什么样」，而不是被丢一个弹窗就完事。
const String kGuidedSetupFirstRun = 'guidedTranslateFirstRun';
const String kGuidedSetupUpgrade = 'guidedTranslateUpgrade';

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
  /// 定位「AI 界面翻译」那一节，滚动靠它。
  final _aiSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final mode = widget.guidedSetup;
    if (mode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _runGuidedSetup(mode));
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

    // 先让用户看清「AI 功能」这一页长什么样，再滚到 AI 翻译那一段。
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    final sectionContext = _aiSectionKey.currentContext;
    if (sectionContext != null) {
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

    // 新装用户：当着面把开关打开（开关会自己播放一次动画），再弹语言列表。
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
          ? AppBar(title: Obx(() => Text(uiTx('AI 功能'))))
          : null,
      body: Obx(() {
        UiTranslateService.to.revision.value;
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // ================= AI 视频总结 =================
            _sectionTitle(theme, 'AI 视频总结'),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(uiTx('启用视频总结助手')),
                subtitle: Text(uiTx('在视频详情页用 AI 生成字幕分析/总结')),
                value: controller.enableAiChat.value,
                onChanged: (v) {
                  controller.enableAiChat.value = v;
                  Pref.enableAiChat = v;
                },
              ),
            ),
            _ApiFields(
              urlCtl: controller.apiUrlCtl,
              keyCtl: controller.apiKeyCtl,
              onUrl: controller.saveApiUrl,
              onKey: controller.saveApiKey,
            ),
            _ModelPicker(
              label: '视频总结模型',
              list: controller.modelList,
              current: controller.model,
              manualCtl: controller.modelCtl,
              loading: controller.isLoadingModels,
              onSelect: controller.saveModel,
              onFetch: controller.fetchModels,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.tune),
              title: Text(uiTx('提示词模板')),
              subtitle: Text(uiTx('管理视频总结的提示词模板')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed('/aiSetting'),
            ),
            const SizedBox(height: 24),

            // ================= AI 界面翻译 =================
            // 引导流程会滚到这里，所以标题要挂 key。
            KeyedSubtree(
              key: _aiSectionKey,
              child: _sectionTitle(theme, 'AI 界面翻译'),
            ),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(uiTx('启用 AI 翻译')),
                subtitle: Text(uiTx('将界面与外文内容翻译为所选应用语言')),
                value: controller.uiTranslateEnabled.value,
                onChanged: controller.saveUiTranslateEnabled,
              ),
            ),
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
                onTap: () =>
                    _showTranslateProviderPicker(context, controller),
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
                  Text(
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
                ],
              );
            }),
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
                    label: '翻译模型',
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
                                child: CircularProgressIndicator(strokeWidth: 2),
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
                        '• 视频总结与界面翻译各自配置独立的接口地址/Key/模型，互不影响\n'
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

  Widget _sectionTitle(ThemeData theme, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 2),
    child: Text(uiTx(text), style: theme.textTheme.titleMedium),
  );
}


/// 官方清单覆盖的语言数 / 清单外的数量，用于选择器顶部的说明。
final int kOfficialLanguageCount =
    appLanguages.where((e) => e.official).length;
final int kUnofficialLanguageCount =
    appLanguages.where((e) => !e.official).length;

/// 选择器的行：`(语言, 是否该变体组的基准条目)`。
///
/// 官方把地区 / 字形变体拆成了独立条目（阿拉伯语 5 条、库尔德语 3 条…），
/// 这里**只调整展示顺序**把变体并到基准条目后面，**不合并任何条目**
/// —— 就是「从分不从合」：清单里一个都不少，只是看起来成组。
final List<(AppLanguage, bool)> _pickerRows = () {
  final groups = <String, List<AppLanguage>>{};
  final order = <String>[];
  for (final l in appLanguages) {
    final key = l.variantOf ?? l.name;
    (groups[key] ??= <AppLanguage>[]).add(l);
    if (!order.contains(key)) order.add(key);
  }
  final rows = <(AppLanguage, bool)>[];
  for (final key in order) {
    final group = groups[key]!;
    if (group.length == 1) {
      rows.add((group.first, false));
      continue;
    }
    for (final l in group) {
      // 组内基准条目（没有 variantOf 的那个）当组头，加粗且不缩进。
      rows.add((l, l.variantOf == null));
    }
  }
  return rows;
}();

/// 翻译引擎选择器（内置官方模型 / 自备 API）。
Future<void> _showTranslateProviderPicker(
  BuildContext context,
  AiSettingController controller,
) async {
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
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Obx(() {
        UiTranslateService.to.revision.value;
        return Text(uiTx('选择应用语言'));
      }),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.sizeOf(dialogContext).height * 0.62,
        child: ListView.builder(
          itemCount: _pickerRows.length + 1,
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
                    [kOfficialLanguageCount, kUnofficialLanguageCount],
                  ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              );
            }
            final (language, isFamilyBase) = _pickerRows[index - 1];
            final selected = language.code == selectedCode;
            // 整行包 Obx。**这一步不能省**：下面的 uiTx 是异步拿译文的，没有 Obx 的话
            // 这一行只在构建那一刻取一次值，译文晚到就永远停在原文上 —— 而「哪一行
            // 恰好被重建过」取决于滚动时机，于是会出现「同为官方清单外，這行翻了、
            // 那行没翻」的随机现象。
            return Obx(
              // Language names are autonyms; keep them literal instead of asking
              // the selected target language to translate the language selector.
              () => ListTile(
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
                contentPadding: EdgeInsets.only(
                  left: isFamilyBase ? 16 : 36,
                  right: 16,
                ),
                title: Text(
                  language.name,
                  style: isFamilyBase
                      ? const TextStyle(fontWeight: FontWeight.w600)
                      : null,
                ),
                trailing: selected ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(dialogContext, language.code),
              ),
            );
          },
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
