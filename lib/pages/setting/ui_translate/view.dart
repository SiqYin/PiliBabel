import 'package:PiliPlus/pages/setting/ui_translate/controller.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// 「AI 界面翻译」一级设置页。竖屏下作为独立页推入，平板下嵌入设置右栏。
class UiTranslateSettingPage extends StatelessWidget {
  const UiTranslateSettingPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UiTranslateSettingController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('AI 界面翻译')) : null,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 启用开关
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('启用 AI 界面翻译'),
              subtitle: const Text('用自配模型把界面文案翻译为目标语言，每条只翻译一次并持久固定'),
              value: controller.uiTranslateEnabled.value,
              onChanged: controller.saveEnabled,
            ),
          ),
          const SizedBox(height: 8),

          // 目标语言
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('目标语言', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: controller.uiTranslateLang.value,
                      items: UiTranslateSettingController.langOptions
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.translate),
                      ),
                      onChanged: (value) {
                        if (value != null) controller.saveLang(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 操作
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('测试与缓存', style: theme.textTheme.titleMedium),
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.bolt, size: 18),
                            label: const Text('测试翻译'),
                            onPressed:
                                controller.isTesting.value
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
                          onPressed: controller.clearCache,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final err = controller.lastError;
                    if (err == null) return const SizedBox.shrink();
                    return Text(
                      '最近错误：$err',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    );
                  }),
                  Obx(() {
                    controller.uiTranslateLang.value;
                    return Text(
                      '已缓存译文条数：${controller.cachedCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // API 配置入口（与 AI 视频总结共用）
          Card(
            child: ListTile(
              leading: Obx(
                () => Icon(
                  controller.hasApiConfigured.value
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color: controller.hasApiConfigured.value
                      ? colorScheme.primary
                      : colorScheme.error,
                ),
              ),
              title: const Text('API 配置'),
              subtitle: Obx(
                () => Text(
                  controller.hasApiConfigured.value
                      ? '已配置（与「AI 视频总结」共用同一地址与模型）'
                      : '未配置：请先设置接口地址与模型，翻译才能生效',
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed('/aiSetting'),
            ),
          ),
          const SizedBox(height: 24),

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
                    '• 界面翻译与「AI 视频总结」使用同一套 OpenAI 兼容接口\n'
                    '• 每条文本只翻译一次，结果本地持久化，重开不再重复翻译\n'
                    '• 首次出现的文字会先显示原文，后台翻译完成后自动刷新\n'
                    '• 切换目标语言会清空缓存并按新语言重新翻译\n'
                    '• 覆盖范围：首页与底部导航、标题、UP 主名、评论/动态等',
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
}
