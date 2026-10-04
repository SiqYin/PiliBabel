import 'dart:async';
import 'dart:convert';

import 'package:PiliPlus/services/ai_chat/ai_chat_service.dart';
import 'package:PiliPlus/services/logger.dart';
import 'package:PiliPlus/services/ui_translate/app_language.dart';
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

  /// 当前选择的应用语言（含书写/地区规范说明，供模型使用）。
  AppLanguage get currentLanguage => appLanguageByCode(Pref.uiTranslateLang);

  /// 目标语言名称，直接作为提示词里的语言描述（发给模型，不显示给用户）。
  String get targetLang => currentLanguage.toModel;

  /// 目标是否中文家族：中文家族下，本身已是中文的内容不再翻译，仅译外文。
  bool get isChineseTarget => currentLanguage.chineseFamily;

  /// 目标语言是否就是**原文语言**——只有简体中文。
  ///
  /// 只有这一种情况才不调我们自己的 API：B 站是大陆平台，绝大多数内容本来就是
  /// 简体中文，所以"简体中文 → 简体中文"不需要翻译，也就不用花 token。
  ///
  /// **繁体中文 / 简体粤语 / 繁体粤语 / 简体吴语 / 繁体吴语 / 大陆闽南语 /
  /// 台湾闽南语都不是原文**，虽然同属中文家族，但仍要正常调用 API 翻译
  /// （简体原文 → 繁体/粤语/吴语/闽南语 是实打实的转换）。
  bool get isSourceLanguage => currentLanguage.code == 'zh-CN';

  /// 持久化缓存的内存副本。
  final Map<String, String> _cache = {};

  /// 已渲染但尚未翻译的字符串，等待批量 flush。
  final Set<String> _pending = <String>{};

  /// 翻译缓存写入进度（用于 UI 读取以触发 Obx 重建）。
  final RxInt revision = 0.obs;

  /// 正在翻译中标记，避免并发重复请求。
  bool _busy = false;

  Timer? _debounce;
  Timer? _persistTimer;

  /// 单批最大字符串条数。较小 → 单次模型请求更快返回、译文更早逐块出现；
  /// 靠更大并发与逐块应用保证总吞吐。
  static const int _batchSize = 16;

  /// 同时并发的批次数上限（越大越快，但更吃限流）。
  static const int _maxConcurrent = 10;

  /// 收集待翻译字符串的防抖窗口（较短，减少首屏等待）。
  static const Duration _debounceWindow = Duration(milliseconds: 180);

  /// 最近一次翻译失败的原因，供设置页诊断展示。
  final RxnString lastError = RxnString();

  /// 处于“显示原文”态的评论/动态条目 id 集合（按条切换）。
  final Set<String> _originalIds = <String>{};

  /// 原文/译文切换的版本号，供各条 Obx 订阅以刷新。
  final RxInt contentRev = 0.obs;

  /// 弹幕翻译运行时开关（默认关闭，不持久化；每次进入播放器需手动开启）。
  final RxBool danmakuTranslate = false.obs;

  /// 是否具备使用弹幕翻译的条件：界面翻译已启用，且已配置翻译独立接口地址与模型。
  bool get canTranslate =>
      enabled &&
      Pref.uiTranslateApiUrl.trim().isNotEmpty &&
      Pref.uiTranslateModel.trim().isNotEmpty;

  bool showOriginalFor(String id) => _originalIds.contains(id);

  void toggleShowOriginal(String id) {
    if (!_originalIds.remove(id)) _originalIds.add(id);
    contentRev.value++;
  }

  /// 评论/动态正文取词：该条处于“显示原文”态返回原文，否则返回译文。
  String commentText(String src, String id) {
    if (_originalIds.contains(id)) return src;
    return _tx(src);
  }

  /// 弹幕翻译确认弹窗的提示文案。
  ///
  /// **源文案用英文**，两个作用：
  /// 1. 兜底可读性——界面翻译没开、接口没配好或译文还没回来时，英文对非中文
  ///    用户总比中文可读；
  /// 2. 开启翻译后它照常按目标语言自动翻译（英文 → 目标语言）。目标语言是中文
  ///    家族时 `_tx` 不调我们的 API（见 _tx），所以那时它保持英文——这也正是
  ///    "英文兜底"要解决的场景。
  ///
  /// 三处引用（[prewarm] 列表、播放器按钮预热、弹窗正文）共用这一个常量，
  /// 避免抄成不同字符串导致"预热了 A、渲染的是 B"，预热永远不生效。
  static const String danmakuTranslateWarning =
      'Danmaku AI translation consumes a lot of tokens. Continue?';

  /// 需要“提前翻好”的高频交互文案（弹窗/按钮），避免首次出现时来不及译。
  static const List<String> _commonPrewarm = [
    danmakuTranslateWarning,
    '取消',
    '确定',
    '弹幕翻译',
  ];

  /// 预热常用文案：开启翻译后调用，使这些串尽早进入缓存。
  void prewarm() {
    if (!enabled) return;
    // 原文语言（简体中文）下 `_tx` 根本不会请求我们的 API（见 _tx），没有可预热的东西
    if (isSourceLanguage) return;
    var queued = false;
    for (final s in _commonPrewarm) {
      if (_cache.containsKey(s)) continue;
      if (_pending.add(s)) queued = true;
    }
    if (queued) _scheduleFlush();
  }

  @override
  void onInit() {
    super.onInit();
    _cache.addAll(Pref.uiTranslateCache);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _persistTimer?.cancel();
    _revisionTimer?.cancel();
    _persist();
    super.onClose();
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
    // 目标语言就是原文语言（简体中文）时：**完全不调我们自己配置的 API**。
    //
    // B 站是大陆平台，绝大多数内容本来就是简体中文，"简体中文 → 简体中文"没有
    // 可翻的东西，所以直接返回原文：既不花用户自己配的 API token，界面也不会
    // 因为多一次请求而闪。
    //
    // 评论区外文另有 B 站自带的**免费**翻译兜底：每条评论下面那个「翻译」按钮走
    // `ReplyGrpc.translateReply`（`bilibili.main.community.reply.v1.Reply/
    // TranslateReply`），与 PiliNara / PiliPlus 原版一致。
    //
    // 注意：**只有简体中文**走这条捷径。繁体中文 / 粤语 / 吴语 / 闽南语等虽然
    // 同属中文家族，但对简体原文来说并不是原文，仍然要正常调用 API 翻译。
    if (isSourceLanguage) return src;
    final hit = _cache[src];
    if (hit != null) return hit;
    // 尚未翻译：先显示原文，排进待翻队列。
    if (_pending.add(src)) _scheduleFlush();
    return src;
  }

  void _scheduleFlush() {
    // 关闭状态：清空待翻队列，绝不发起请求（保护用户的 API 额度/token）
    if (!enabled) {
      _pending.clear();
      return;
    }
    // 攒满一批立即开翻，避免大批量（如切换语言）时干等防抖窗口
    if (_pending.length >= _batchSize) {
      _debounce?.cancel();
      _flush();
      return;
    }
    // 已有待触发的定时器就不再重置，防止连续入队把 flush 无限推迟
    if (_debounce?.isActive ?? false) return;
    _debounce = Timer(_debounceWindow, _flush);
  }

  Future<void> _flush() async {
    if (_busy || _pending.isEmpty) return;
    // 关闭时（含已排队未触发的防抖）绝不再发请求，保护用户 API 额度
    if (!enabled) {
      _pending.clear();
      return;
    }
    _busy = true;
    try {
      final batch = _pending.toList(growable: false);
      _pending.clear();

      final uncached = batch
          .where((s) => !_cache.containsKey(s))
          .toSet()
          .toList(growable: false);
      if (uncached.isEmpty) return;

      // 切成小批
      final chunks = <List<String>>[];
      for (var i = 0; i < uncached.length; i += _batchSize) {
        final end = i + _batchSize < uncached.length
            ? i + _batchSize
            : uncached.length;
        chunks.add(uncached.sublist(i, end));
      }

      // worker 池：每块一返回就写缓存 + 递增 revision（渐进刷新），
      // 不再等整批全部完成，首屏因此更早出现译文。
      var next = 0;
      Future<void> worker() async {
        while (true) {
          final my = next;
          if (my >= chunks.length) return;
          next++;
          final chunk = chunks[my];
          final translated = await _translateChunk(chunk).catchError((_) {
            return <String>[];
          });
          var changed = false;
          for (var j = 0; j < chunk.length && j < translated.length; j++) {
            final value = translated[j].trim();
            if (value.isNotEmpty && value != chunk[j]) {
              _cache[chunk[j]] = value;
              changed = true;
            }
          }
          if (changed) {
            _bumpRevisionSoon();
            _schedulePersist();
            lastError.value = null;
          }
        }
      }

      await Future.wait(
        List.generate(
          _maxConcurrent < chunks.length ? _maxConcurrent : chunks.length,
          (_) => worker(),
        ),
      );
    } catch (e, st) {
      lastError.value = e.toString();
      logger.e('界面翻译失败', error: e, stackTrace: st);
      // 不自动重试，避免 API 未配置/持续失败时无限自旋；
      // 这些字符串仍显示原文，待下次界面重建时经 tx 自动重新排队。
    } finally {
      _busy = false;
      _persist();
      if (_pending.isNotEmpty) _scheduleFlush();
    }
  }

  /// 节流写盘：高频逐块更新时，合并持久化，避免每次 revision 都序列化整表。
  void _schedulePersist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(const Duration(milliseconds: 1200), _persist);
  }

  Timer? _revisionTimer;

  /// 节流刷新：worker 每块都会产生译文，而 revision 是全 App 级依赖（播放器界面
  /// 就有 ~39 处 uiTx），逐块或多个 300ms 周期刷新都会在播放时形成重建风暴。
  /// 合并为最多每 700ms 一次：译文出现略微变慢，换播放时的平稳。
  void _bumpRevisionSoon() {
    _revisionTimer?.cancel();
    _revisionTimer = Timer(const Duration(milliseconds: 700), () {
      revision.value++;
    });
  }

  /// 翻译使用独立的接口地址 / 密钥 / 模型（与视频总结完全分离，各配各的）。
  static String get translateApiUrl => Pref.uiTranslateApiUrl;
  static String get translateApiKey => Pref.uiTranslateApiKey;
  static String get translateModel => Pref.uiTranslateModel;

  Future<List<String>> _translateChunk(List<String> sources) async {
    // 最后一道防线（token 保护）：真正发请求前再确认一次开关，
    // 任何入队/换语言/关闭时序问题都不可能导致关闭状态下产生 API 调用。
    if (!enabled) {
      _pending.clear();
      return const [];
    }
    final lang = targetLang;
    final numbered = StringBuffer();
    for (var i = 0; i < sources.length; i++) {
      numbered.writeln('${i + 1}. ${sources[i]}');
    }

    final system =
        '你是应用界面本地化翻译引擎。用户会给出一个带编号的界面文案列表'
        '（每条可能为中文或外文），请把每一条翻译成『$lang』。'
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

    // 走翻译独立的接口地址与密钥；仍使用已验证可用的流式通道。
    final buf = StringBuffer();
    await for (final chunk in AiChatService.streamChat(
      messages: [
        {'role': 'system', 'content': system},
        {'role': 'user', 'content': user},
      ],
      model: translateModel,
      apiUrl: translateApiUrl,
      apiKey: translateApiKey,
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

/// 带占位符的模板翻译：把含 `{0}`/`{1}`… 的整句模板作为一个稳定 key 送翻译，
/// 再把参数回填（提示词已要求模型保留 `{n}` 占位符）。用于 `'共 {0} 条'` 这类句子。
String uiTxP(String template, List<Object?> args) {
  var out = UiTranslateService.tx(template);
  for (var i = 0; i < args.length; i++) {
    final token = '{$i}';
    if (out.contains(token)) {
      out = out.replaceAll(token, '${args[i]}');
    }
  }
  return out;
}

/// 评论/动态正文取词：按条目 id 遵循各自的“显示原文”开关。
String uiTxComment(String src, String id) =>
    Get.isRegistered<UiTranslateService>()
        ? UiTranslateService.to.commentText(src, id)
        : src;
