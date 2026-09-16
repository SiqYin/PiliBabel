import 'package:PiliPlus/pages/setting/ai_setting/controller.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// 统一「AI 功能」一级设置页：
/// 顶部共用 API 接入；下面分「AI 视频总结」「AI 界面翻译」两块，各自可选模型。
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
      appBar: showAppBar ? AppBar(title: const Text('AI 功能')) : null,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ===== AI 接入（共用）=====
          _sectionTitle(theme, 'AI 接入'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller.apiUrlCtl,
                    decoration: const InputDecoration(
                      labelText: '接口地址（OpenAI 兼容）',
                      hintText: 'https://api.example.com/v1',
                      helperText:
                          '填到版本路径为止，自动补全 /models、/chat/completions',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                    onChanged: controller.saveApiUrl,
                  ),
                  const SizedBox(height: 12),
                  _ApiKeyField(controller: controller),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ===== AI 视频总结 =====
          _sectionTitle(theme, 'AI 视频总结'),
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('启用视频总结助手'),
              subtitle: const Text('在视频详情页用 AI 生成字幕分析/总结'),
              value: controller.enableAiChat.value,
              onChanged: (v) {
                controller.enableAiChat.value = v;
                Pref.enableAiChat = v;
              },
            ),
          ),
          _ModelDropdown(
            controller: controller,
            label: '视频总结模型',
            value: controller.model,
            onSelect: controller.saveModel,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.tune),
            title: const Text('提示词模板'),
            subtitle: const Text('管理视频总结的提示词模板'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed('/aiSetting'),
          ),
          const SizedBox(height: 20),

          // ===== AI 界面翻译 =====
          _sectionTitle(theme, 'AI 界面翻译'),
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('启用界面翻译'),
              subtitle: const Text('把界面与内容翻译为目标语言，每条只翻一次并持久固定'),
              value: controller.uiTranslateEnabled.value,
              onChanged: controller.saveUiTranslateEnabled,
            ),
          ),
          Obx(
            () => DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: controller.uiTranslateLang.value,
              items: AiSettingController.uiTranslateLangOptions
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              decoration: const InputDecoration(
                labelText: '目标语言',
                border: OutlineInputBorder(),
                isDense: true,
                prefixIcon: Icon(Icons.translate),
              ),
              onChanged: (v) {
                if (v != null) controller.saveUiTranslateLang(v);
              },
            ),
          ),
          const SizedBox(height: 12),
          _TranslateModelDropdown(controller: controller),
          const SizedBox(height: 4),
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('思考模式'),
              subtitle: Text(
                controller.thinking.value
                    ? '启用推理，翻译更准但更慢'
                    : '关闭推理，出结果更快（推荐）',
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
                    label: const Text('测试翻译'),
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
                  label: const Text('清空缓存'),
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
              child: Text(
                '最近错误：$err',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            );
          }),
          const SizedBox(height: 20),

          // 说明
          Card(
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '使用说明',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 两个功能共用上面的接口地址与 Key，可各自选择模型\n'
                    '• 界面翻译每条只翻一次、本地持久固定，切语言会清缓存重翻\n'
                    '• 首次出现的文字先显示原文，后台翻完自动刷新\n'
                    '• 追求速度可关「思考模式」，并为翻译单独选一个更快的模型',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: theme.textTheme.titleMedium),
  );
}

/// 视频总结模型选择（沿用控制器已拉取的 modelList，含手动输入兜底）。
class _ModelDropdown extends StatelessWidget {
  const _ModelDropdown({
    required this.controller,
    required this.label,
    required this.value,
    required this.onSelect,
  });

  final AiSettingController controller;
  final String label;
  final RxString value;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Obx(() {
        if (controller.modelList.isNotEmpty) {
          return DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: controller.modelList.contains(value.value)
                ? value.value
                : null,
            items: controller.modelList
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              isDense: true,
              prefixIcon: const Icon(Icons.smart_toy),
              suffixIcon: IconButton(
                icon: controller.isLoadingModels.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                tooltip: '拉取模型列表',
                onPressed: controller.fetchModels,
              ),
            ),
            onChanged: (v) {
              if (v != null) onSelect(v);
            },
          );
        }
        return TextField(
          controller: controller.modelCtl,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.smart_toy),
            suffixIcon: IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '拉取模型列表',
              onPressed: controller.fetchModels,
            ),
          ),
          onChanged: onSelect,
        );
      }),
    );
  }
}

/// 界面翻译模型选择：多一个「跟随视频总结模型」空选项。
class _TranslateModelDropdown extends StatelessWidget {
  const _TranslateModelDropdown({required this.controller});

  final AiSettingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.translateModel.value;
      if (controller.modelList.isNotEmpty) {
        final items = <DropdownMenuItem<String>>[
          const DropdownMenuItem(value: '', child: Text('跟随视频总结模型')),
          ...controller.modelList.map(
            (e) => DropdownMenuItem(value: e, child: Text(e)),
          ),
        ];
        return DropdownButtonFormField<String>(
          // ignore: deprecated_member_use
          value: items.any((it) => it.value == current) ? current : '',
          items: items,
          decoration: const InputDecoration(
            labelText: '翻译模型',
            border: OutlineInputBorder(),
            isDense: true,
            prefixIcon: Icon(Icons.auto_awesome),
          ),
          onChanged: (v) {
            if (v != null) controller.saveTranslateModel(v);
          },
        );
      }
      return TextField(
        controller: TextEditingController(text: current)
          ..selection = TextSelection.collapsed(offset: current.length),
        decoration: const InputDecoration(
          labelText: '翻译模型（留空=跟随视频总结）',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.auto_awesome),
        ),
        onChanged: controller.saveTranslateModel,
      );
    });
  }
}

class _ApiKeyField extends StatefulWidget {
  const _ApiKeyField({required this.controller});
  final AiSettingController controller;

  @override
  State<_ApiKeyField> createState() => _ApiKeyFieldState();
}

class _ApiKeyFieldState extends State<_ApiKeyField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller.apiKeyCtl,
      decoration: InputDecoration(
        labelText: 'API Key',
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
      onChanged: widget.controller.saveApiKey,
    );
  }
}
