import 'package:PiliPlus/pages/setting/ai_setting/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiSettingPage extends StatelessWidget {
  const AiSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiSettingController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('AI 视频总结设置')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // API 地址
          Obx(
            () => TextField(
              controller: TextEditingController(text: controller.apiUrl.value)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.apiUrl.value.length),
                ),
              decoration: const InputDecoration(
                labelText: 'API 地址',
                hintText: 'https://api.example.com',
                border: OutlineInputBorder(),
              ),
              onSubmitted: controller.saveApiUrl,
            ),
          ),
          const SizedBox(height: 16),

          // API Key
          _ApiKeyField(controller: controller),
          const SizedBox(height: 16),

          // 模型选择
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('模型选择', style: theme.textTheme.titleMedium),
                      const Spacer(),
                      Obx(
                        () => controller.isLoadingModels.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.refresh),
                                tooltip: '拉取模型列表',
                                onPressed: controller.fetchModels,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (controller.modelList.isNotEmpty) {
                      return DropdownButtonFormField<String>(
                        initialValue:
                            controller.modelList.contains(
                              controller.model.value,
                            )
                            ? controller.model.value
                            : null,
                        items: controller.modelList
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          if (value != null) controller.saveModel(value);
                        },
                      );
                    }
                    return TextField(
                      controller: TextEditingController(
                        text: controller.model.value,
                      ),
                      decoration: const InputDecoration(
                        labelText: '模型名称',
                        hintText: 'gpt-4o-mini',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: controller.saveModel,
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 模板管理
          Row(
            children: [
              Text('提示词模板', style: theme.textTheme.titleMedium),
              const Spacer(),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.add),
                label: const Text('添加'),
                onPressed: () => _showTemplateDialog(context, controller),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.templates.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      '暂无模板，点击右上角添加',
                      style: TextStyle(color: colorScheme.outline),
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: List.generate(controller.templates.length, (index) {
                final t = controller.templates[index];
                return Card(
                  child: ListTile(
                    title: Text(t.name),
                    subtitle: Text(
                      t.prompt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showTemplateDialog(
                            context,
                            controller,
                            index: index,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: colorScheme.error,
                          ),
                          onPressed: () => controller.deleteTemplate(index),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showTemplateDialog(
    BuildContext context,
    AiSettingController controller, {
    int? index,
  }) {
    final isEdit = index != null;
    final existing = isEdit ? controller.templates[index] : null;
    final nameCtl = TextEditingController(text: existing?.name ?? '');
    final promptCtl = TextEditingController(text: existing?.prompt ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? '编辑模板' : '添加模板'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtl,
              decoration: const InputDecoration(
                labelText: '模板名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: promptCtl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: '提示词内容',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(color: ColorScheme.of(context).outline),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = nameCtl.text.trim();
              final prompt = promptCtl.text.trim();
              if (name.isEmpty || prompt.isEmpty) return;
              if (isEdit) {
                controller.updateTemplate(index, name, prompt);
              } else {
                controller.addTemplate(name, prompt);
              }
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
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
    return Obx(
      () => TextField(
        controller: TextEditingController(text: widget.controller.apiKey.value),
        decoration: InputDecoration(
          labelText: 'API Key',
          hintText: 'sk-...',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        obscureText: _obscure,
        onSubmitted: widget.controller.saveApiKey,
      ),
    );
  }
}
