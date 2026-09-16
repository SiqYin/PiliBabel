import 'dart:async';
import 'dart:convert';

import 'package:PiliPlus/services/ai_chat/ai_chat_service.dart';
import 'package:PiliPlus/services/logger.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:get/get.dart';

/// AI 界面翻译服务（路线 B 的落地核心）。
///
/// 设计要点：
/// 1. 持久化「源中文 -> 译文」缓存表：任何字符串只翻译一次，命中即复用，
///    关闭重开不二次翻译（严格满足“译法固定”的需求）。
/// 2. 运行期在渲染边界同步返回：有缓存返回译文，无缓存先返回原文并入队，
///    后台批量翻译完成后写入缓存并自增 [revision] 触发 Obx 局部重建。
/// 3. 批量翻译：把攒到的一批字符串塞进一次 chat 请求（编号列表 -> JSON 数组），
///    显著降低冷启动时的 API 调用次数。
class UiTranslateService extends GetxService {
  static UiTranslateService get to => Get.find<UiTranslateService>();

  /// 是否开启界面翻译（跟随设置页开关，运行期可即时生效）。
  bool get enabled => Pref.uiTranslateEnabled;

  /// 目标语言名称，直接作为提示词里的语言描述（如 English / 日本語）。
  String get targetLang => Pref.uiTranslateLang;

  /// 持久化缓存的内存副本。
  final Map<String, String> _cache = {};

  /// 已渲染但尚未翻译的字符串，等待批量 flush。
  final Set<String> _pending = <String>{};

  /// 翻译缓存写入进度（用于 UI 读取以触发 Obx 重建）。
  final RxInt revision = 0.obs;

  /// 正在翻译中标记，避免并发重复请求。
  bool _busy = false;

  Timer? _debounce;

  /// 单批最大字符串条数，避免超出模型上下文。
  static const int _batchSize = 40;

  /// 首次翻译时同时并发的批次数上限（越大越快，但更吃限流）。
  static const int _maxConcurrent = 4;

  /// 收集待翻译字符串的防抖窗口。
  static const Duration _debounceWindow = Duration(milliseconds: 500);

  /// 最近一次翻译失败的原因，供设置页诊断展示。
  final RxnString lastError = RxnString();

  @override
  void onInit() {
    super.onInit();
    _cache.addAll(Pref.uiTranslateCache);
  }

  /// 全局静态入口：把任意要显示的源字符串映射为译文。
  ///
  /// 该函数是同步的、必须在 build 里安全调用。未开启、空串、未命中缓存时
  /// 一律回退原文，同时把原文入队等待后台翻译。
  static String tx(String src) {
    if (src.isEmpty) return src;
    if (!Get.isRegistered<UiTranslateService>()) return src;
    return to._tx(src);
  }

  String _tx(String src) {
    // 始终读取一次修订号：即便翻译关闭，也能让包裹本调用的 Obx 拥有合法依赖，
    // 避免 GetX “空 Obx” 运行时报错；开启时则据此在译文回来后刷新。
    revision.value;
    if (!enabled) return src;
    final hit = _cache[src];
    if (hit != null) return hit;
    // 尚未翻译：先显示原文，排进待翻队列。
    if (_pending.add(src)) _scheduleFlush();
    return src;
  }

  void _scheduleFlush() {
    _debounce?.cancel();
    _debounce = Timer(_debounceWindow, _flush);
  }

  Future<void> _flush() async {
    if (_busy || _pending.isEmpty) return;
    final batch = _pending.toList(growable: false);
    _pending.clear();

    final uncached =
        batch.where((s) => !_cache.containsKey(s)).toSet().toList(growable: false);
    if (uncached.isEmpty) return;

    _busy = true;
    try {
      // 切分成批次
      final chunks = <List<String>>[];
      for (var i = 0; i < uncached.length; i += _batchSize) {
        final end = i + _batchSize < uncached.length
            ? i + _batchSize
            : uncached.length;
        chunks.add(uncached.sublist(i, end));
      }

      var changed = false;
      // 有限并发：一次最多发 _maxConcurrent 批，缩短首次翻译总等待
      for (var i = 0; i < chunks.length; i += _maxConcurrent) {
        final wave = chunks.sublist(
          i,
          i + _maxConcurrent < chunks.length ? i + _maxConcurrent : chunks.length,
        );
        final results = await Future.wait(
          wave.map((chunk) => _translateChunk(chunk).catchError((_) {
            return <String>[];
          })),
        );
        for (var w = 0; w < wave.length; w++) {
          final chunk = wave[w];
          final translated = results[w];
          for (var j = 0; j < chunk.length && j < translated.length; j++) {
            final value = translated[j].trim();
            if (value.isNotEmpty && value != chunk[j]) {
              _cache[chunk[j]] = value;
              changed = true;
            }
          }
        }
      }

      if (changed) {
        _persist();
        revision.value++;
        lastError.value = null;
      }
    } catch (e, st) {
      lastError.value = e.toString();
      logger.e('界面翻译失败', error: e, stackTrace: st);
      // 不自动重试，避免 API 未配置/持续失败时无限自旋；
      // 这些字符串仍显示原文，待下次界面重建时经 tx 自动重新排队。
    } finally {
      _busy = false;
      if (_pending.isNotEmpty) _scheduleFlush();
    }
  }

  /// 翻译专用模型：为空则回退到视频总结所用模型。
  static String get translateModel =>
      Pref.uiTranslateModel.isNotEmpty ? Pref.uiTranslateModel : Pref.aiModel;

  Future<List<String>> _translateChunk(List<String> sources) async {
    final lang = targetLang;
    final numbered = StringBuffer();
    for (var i = 0; i < sources.length; i++) {
      numbered.writeln('${i + 1}. ${sources[i]}');
    }

    final system =
        '你是应用界面本地化翻译引擎。用户会给出一个带编号的中文界面文案列表，'
        '请把每一条翻译成『$lang』。'
        '严格要求：'
        '1) 只输出一个 JSON 数组，元素个数与输入条数相同、顺序一一对应，'
        '每个元素是该条的译文纯文本；'
        '2) 不要输出任何解释、说明或 Markdown 代码块围栏；'
        '3) 保留原文中的数字、占位符、标点、换行与专有名词，'
        '界面词尽量简短、术语一致。';
    final user = '待翻译列表：\n$numbered';

    // 思考模式：开=启用推理(更准但慢)；关=显式关闭推理以求更快。
    final thinking = Pref.uiTranslateThinking;
    final extraBody = <String, dynamic>{'enable_thinking': thinking};

    // 与「AI 视频总结」使用同一条已验证可用的流式通道：
    // 部分 OpenAI 兼容网关只支持 stream:true，非流式会直接报错。
    final buf = StringBuffer();
    await for (final chunk in AiChatService.streamChat(
      messages: [
        {'role': 'system', 'content': system},
        {'role': 'user', 'content': user},
      ],
      model: translateModel,
      extraBody: extraBody,
    )) {
      buf.write(chunk);
    }
    return _parseArray(buf.toString(), sources.length);
  }

  /// 从模型输出里稳健地解析出 JSON 数组；解析失败退化为按行切分。
  static List<String> _parseArray(String raw, int expected) {
    var s = raw.trim();
    // 去掉可能的 ```json ... ``` 围栏。
    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
    final m = fence.firstMatch(s);
    if (m != null) s = m.group(1)!.trim();
    // 截取第一个 [ 到最后一个 ]。
    final start = s.indexOf('[');
    final end = s.lastIndexOf(']');
    if (start != -1 && end != -1 && end > start) {
      final slice = s.substring(start, end + 1);
      try {
        final list = jsonDecode(slice);
        if (list is List) {
          return List.generate(
            expected,
            (i) => i < list.length ? list[i].toString() : '',
          );
        }
      } catch (_) {}
    }
    // 兜底：按行切分（模型偶尔输出裸行）。
    final lines = raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return List.generate(expected, (i) => i < lines.length ? lines[i] : '');
  }

  void _persist() => Pref.uiTranslateCache = _cache;

  /// 清空翻译缓存（下次遇到同一字符串会重新翻译）。
  void clearCache() {
    _cache.clear();
    _pending.clear();
    lastError.value = null;
    Pref.uiTranslateCache = {};
    revision.value++;
  }

  /// 目标语言切换后调用：清缓存以按新语言重新翻译。
  void resetForNewLanguage() => clearCache();

  /// 已缓存的字符串条数。
  int get cachedCount => _cache.length;

  /// 供设置页「测试翻译」使用：立即用当前目标语言翻译样例，
  /// 走与真实翻译完全相同的通道，成功返回译文，失败抛异常并记录 lastError。
  Future<String> debugTranslate([String sample = '直播']) async {
    try {
      final out = await _translateChunk([sample]);
      final result = out.isEmpty ? '' : out.first.trim();
      if (result.isEmpty) {
        throw Exception('模型返回空内容');
      }
      lastError.value = null;
      return result;
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    }
  }
}

/// 顶层便捷入口：把源字符串映射为译文。
/// 需在被 Obx（或任何读取了 UiTranslateService 修订号）的构建里调用，
/// 才能在异步译文回来后自动刷新；否则仅在界面重建时取到缓存译文。
String uiTx(String src) => UiTranslateService.tx(src);
