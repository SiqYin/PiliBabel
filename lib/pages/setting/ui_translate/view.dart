import 'package:PiliPlus/pages/setting/ai_setting/controller.dart';
import 'package:PiliPlus/services/ui_translate/app_language.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// 统一「AI 功能」一级设置页。
/// 「AI 视频总结」与「AI 界面翻译」各自使用独立的接口地址 / 密钥 / 模型。
class UiTranslateSettingPage extends StatelessWidget {
  const UiTranslateSettingPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AiSettingController>()
        ? Get.find<AiSettingController>()
        : Get.put(AiSettingController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(uiTx('AI 功能'))) : null,
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
          _sectionTitle(theme, 'AI 界面翻译'),
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(uiTx('启用 AI 翻译')),
              subtitle: Text(uiTx('将界面与外文内容翻译为所选应用语言')),
              value: controller.uiTranslateEnabled.value,
              onChanged: controller.saveUiTranslateEnabled,
            ),
          ),
          Obx(() {
            final lang = appLanguageByCode(controller.uiTranslateLang.value);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: lang.code,
                  isExpanded: true,
                  items: appLanguages
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.code,
                          child: Text(e.name),
                        ),
                      )
                      .toList(),
                  decoration: InputDecoration(
                    labelText: uiTx('选择应用语言'),
                    border: const OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: const Icon(Icons.translate),
                  ),
                  onChanged: (v) {
                    if (v != null) controller.saveUiTranslateLang(v);
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  lang.chineseFamily
                      ? uiTx('当前为中文：外文内容会被翻译成该中文，本身是中文的内容保持不变。')
                      : uiTx('若选择非简体中文，需要在下方配置 API 才能实现 AI 翻译。'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            );
          }),
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
          const SizedBox(height: 4),
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
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
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  label: Text(uiTx('清空缓存')),
                  onPressed: controller.clearTranslateCache,
                ),
              ),
            ],
          ),
          Obx(() {
            final err = Get.isRegistered<UiTranslateService>()
                ? UiTranslateService.to.lastError.value
                : null;
            if (err == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(uiTx('最近错误：$err'),
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
                      '• 视频总结与界面翻译各自配置独立的接口地址/Key/模型，互不影响\n'
                      '• 应用语言默认简体中文：只把外文自动译成中文，中文内容不动\n'
                      '• 选择其它语言即把界面与内容整体翻译为该语言（需配置翻译 API）\n'
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
