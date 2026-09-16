import 'package:PiliPlus/services/ai_chat/ai_chat_service.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class AiSettingController extends GetxController {
  final enableAiChat = true.obs;
  final apiUrl = ''.obs;
  final apiKey = ''.obs;
  final model = ''.obs;
  final modelList = <String>[].obs;
  final isLoadingModels = false.obs;
  final templates = <AiPromptTemplate>[].obs;

  // --- AI 界面翻译 ---
  final uiTranslateEnabled = false.obs;
  final uiTranslateLang = 'English'.obs;
  final translateModel = ''.obs;
  final thinking = false.obs;
  static const List<MapEntry<String, String>> uiTranslateLangOptions = [
    MapEntry('English', '英语 English'),
    MapEntry('日本語', '日语 日本語'),
    MapEntry('한국어', '韩语 한국어'),
    MapEntry('Français', '法语 Français'),
    MapEntry('Deutsch', '德语 Deutsch'),
    MapEntry('Español', '西班牙语 Español'),
    MapEntry('Русский', '俄语 Русский'),
  ];

  late final TextEditingController apiUrlCtl;
  late final TextEditingController apiKeyCtl;
  late final TextEditingController modelCtl;

  @override
  void onInit() {
    super.onInit();
    enableAiChat.value = Pref.enableAiChat;
    apiUrl.value = Pref.aiApiUrl;
    apiKey.value = Pref.aiApiKey;
    model.value = Pref.aiModel;
    apiUrlCtl = TextEditingController(text: apiUrl.value);
    apiKeyCtl = TextEditingController(text: apiKey.value);
    modelCtl = TextEditingController(text: model.value);
    templates.value = AiChatService.getTemplates();
    uiTranslateEnabled.value = Pref.uiTranslateEnabled;
    uiTranslateLang.value = Pref.uiTranslateLang;
    translateModel.value = Pref.uiTranslateModel;
    thinking.value = Pref.uiTranslateThinking;
    _loadCachedModels();
  }

  @override
  void onClose() {
    apiUrlCtl.dispose();
    apiKeyCtl.dispose();
    modelCtl.dispose();
    super.onClose();
  }

  void _loadCachedModels() {
    final cacheTime = Pref.aiModelListCacheTime;
    final now = DateTime.now().millisecondsSinceEpoch;
    // Cache valid for 1 hour
    if (now - cacheTime < 3600000) {
      modelList.value = Pref.aiModelListCache;
    }
  }

  Future<void> fetchModels() async {
    isLoadingModels.value = true;
    try {
      final models = await AiChatService.fetchModels();
      modelList.value = models;
      Pref.aiModelListCache = models;
      Pref.aiModelListCacheTime = DateTime.now().millisecondsSinceEpoch;
      if (models.isEmpty) {
        SmartDialog.showToast('未获取到模型列表，请检查 API 配置');
      }
    } catch (e) {
      SmartDialog.showToast('获取模型列表失败: $e');
    } finally {
      isLoadingModels.value = false;
    }
  }

  void saveApiUrl(String value) {
    apiUrl.value = value;
    Pref.aiApiUrl = value;
  }

  void saveApiKey(String value) {
    apiKey.value = value;
    Pref.aiApiKey = value;
  }

  void saveModel(String value) {
    model.value = value;
    Pref.aiModel = value;
  }

  void saveUiTranslateEnabled(bool value) {
    uiTranslateEnabled.value = value;
    Pref.uiTranslateEnabled = value;
  }

  void saveTranslateModel(String value) {
    translateModel.value = value;
    Pref.uiTranslateModel = value;
  }

  void saveThinking(bool value) {
    thinking.value = value;
    Pref.uiTranslateThinking = value;
  }

  void saveUiTranslateLang(String value) {
    if (uiTranslateLang.value == value) return;
    uiTranslateLang.value = value;
    Pref.uiTranslateLang = value;
    if (Get.isRegistered<UiTranslateService>()) {
      UiTranslateService.to.resetForNewLanguage();
    }
  }

  void clearTranslateCache() {
    if (Get.isRegistered<UiTranslateService>()) {
      UiTranslateService.to.clearCache();
    } else {
      Pref.uiTranslateCache = {};
    }
    SmartDialog.showToast('已清空界面翻译缓存');
  }

  final isTesting = false.obs;

  Future<void> testTranslate() async {
    if (!Get.isRegistered<UiTranslateService>()) {
      SmartDialog.showToast('翻译服务未就绪');
      return;
    }
    if (Pref.aiApiUrl.isEmpty || Pref.aiModel.isEmpty) {
      SmartDialog.showToast('请先配置 API 地址并选择模型');
      return;
    }
    isTesting.value = true;
    try {
      final out = await UiTranslateService.to.debugTranslate('直播');
      SmartDialog.showToast('测试成功：直播 → $out');
    } catch (e) {
      SmartDialog.showToast('测试失败：$e');
    } finally {
      isTesting.value = false;
    }
  }

  void addTemplate(String name, String prompt) {
    templates.add(AiPromptTemplate(name: name, prompt: prompt));
    _saveTemplates();
  }

  void updateTemplate(int index, String name, String prompt) {
    templates[index] = AiPromptTemplate(name: name, prompt: prompt);
    templates.refresh();
    _saveTemplates();
  }

  void deleteTemplate(int index) {
    templates.removeAt(index);
    _saveTemplates();
  }

  void reorderTemplate(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = templates.removeAt(oldIndex);
    templates.insert(newIndex, item);
    _saveTemplates();
  }

  void restoreDefaults() {
    templates.value = List.from(AiChatService.defaultTemplates);
    _saveTemplates();
  }

  void _saveTemplates() {
    AiChatService.saveTemplates(templates);
  }
}
