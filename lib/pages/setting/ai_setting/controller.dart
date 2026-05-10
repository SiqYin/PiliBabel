import 'package:PiliPlus/services/ai_chat/ai_chat_service.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class AiSettingController extends GetxController {
  final apiUrl = ''.obs;
  final apiKey = ''.obs;
  final model = ''.obs;
  final modelList = <String>[].obs;
  final isLoadingModels = false.obs;
  final templates = <AiPromptTemplate>[].obs;

  @override
  void onInit() {
    super.onInit();
    apiUrl.value = Pref.aiApiUrl;
    apiKey.value = Pref.aiApiKey;
    model.value = Pref.aiModel;
    templates.value = AiChatService.getTemplates();
    _loadCachedModels();
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
    AiChatService.resetClient();
  }

  void saveApiKey(String value) {
    apiKey.value = value;
    Pref.aiApiKey = value;
    AiChatService.resetClient();
  }

  void saveModel(String value) {
    model.value = value;
    Pref.aiModel = value;
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

  void _saveTemplates() {
    AiChatService.saveTemplates(templates);
  }
}
