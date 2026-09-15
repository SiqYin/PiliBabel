import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

/// 「AI 界面翻译」一级设置页控制器。
/// 复用与「AI 视频总结」相同的 API 配置（Pref.aiApiUrl / aiApiKey / aiModel），
/// 本页只负责界面翻译本身的开关、目标语言、测试与缓存管理。
class UiTranslateSettingController extends GetxController {
  final uiTranslateEnabled = false.obs;
  final uiTranslateLang = 'English'.obs;
  final isTesting = false.obs;

  /// 供设置项展示的 API 配置状态。
  final hasApiConfigured = false.obs;

  static const List<MapEntry<String, String>> langOptions = [
    MapEntry('English', '英语 English'),
    MapEntry('日本語', '日语 日本語'),
    MapEntry('한국어', '韩语 한국어'),
    MapEntry('Français', '法语 Français'),
    MapEntry('Deutsch', '德语 Deutsch'),
    MapEntry('Español', '西班牙语 Español'),
    MapEntry('Русский', '俄语 Русский'),
    MapEntry('ไทย', '泰语 ไทย'),
    MapEntry('Tiếng Việt', '越南语 Tiếng Việt'),
  ];

  @override
  void onInit() {
    super.onInit();
    uiTranslateEnabled.value = Pref.uiTranslateEnabled;
    uiTranslateLang.value = Pref.uiTranslateLang;
    _refreshApiStatus();
  }

  void _refreshApiStatus() {
    hasApiConfigured.value =
        Pref.aiApiUrl.trim().isNotEmpty && Pref.aiModel.trim().isNotEmpty;
  }

  void saveEnabled(bool value) {
    uiTranslateEnabled.value = value;
    Pref.uiTranslateEnabled = value;
  }

  void saveLang(String value) {
    if (uiTranslateLang.value == value) return;
    uiTranslateLang.value = value;
    Pref.uiTranslateLang = value;
    if (Get.isRegistered<UiTranslateService>()) {
      UiTranslateService.to.resetForNewLanguage();
    }
  }

  Future<void> testTranslate() async {
    _refreshApiStatus();
    if (!Get.isRegistered<UiTranslateService>()) {
      SmartDialog.showToast('翻译服务未就绪');
      return;
    }
    if (!hasApiConfigured.value) {
      SmartDialog.showToast('请先在「AI 视频总结」中配置 API 地址并选择模型');
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

  void clearCache() {
    if (Get.isRegistered<UiTranslateService>()) {
      UiTranslateService.to.clearCache();
    } else {
      Pref.uiTranslateCache = {};
    }
    SmartDialog.showToast('已清空界面翻译缓存');
  }

  int get cachedCount =>
      Get.isRegistered<UiTranslateService>()
          ? UiTranslateService.to.cachedCount
          : 0;

  String? get lastError =>
      Get.isRegistered<UiTranslateService>()
          ? UiTranslateService.to.lastError.value
          : null;
}
