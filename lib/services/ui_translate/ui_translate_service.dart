import 'dart:async';
import 'dart:convert';

import 'package:PiliPlus/services/ai_chat/ai_chat_service.dart';
import 'package:PiliPlus/services/ui_translate/translate_provider.dart';
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

  /// 反向缓存：「界面语言文本 -> 简体中文」。
  ///
  /// 搜索时要把用户用界面语言输入的关键词翻回简体中文再检索（见
  /// [translateQuery]）。方向与 [_cache] 相反，所以单独一份，键值不能混。
  final Map<String, String> _reverseCache = {};

  /// 同一个搜索词被多个分栏同时请求时，只发一次翻译请求。
  final Map<String, Future<String?>> _queryInFlight = {};

  /// 正在翻译检索词的并发数；>0 时结果页显示「正在翻译搜索词…」提示。
  final RxInt queryTranslateBusy = 0.obs;

  /// 已渲染但尚未翻译的字符串，等待批量 flush。
  final Set<String> _pending = <String>{};

  /// 翻译缓存写入进度（用于 UI 读取以触发 Obx 重建）。
  final RxInt revision = 0.obs;

  /// 正在翻译中标记，避免并发重复请求。
  bool _busy = false;

  Timer? _debounce;
  Timer? _persistTimer;
  Timer? _persistQueryTimer;

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

  /// 弹幕翻译运行时开关。默认值随引擎走：
  /// * 内置官方模型——免费、不消耗用户配额，**默认开**，点了直接生效；
  /// * 自备 API——消耗用户自己的 token，**默认关**，首次开启仍弹确认框。
  /// 不持久化：每次进入播放器重新按默认值来。
  final RxBool danmakuTranslate = RxBool(usingBuiltinTranslate);

  /// 是否具备使用弹幕翻译的条件：界面翻译已启用，且翻译通道的地址与模型可用。
  ///
  /// 注意用**解析后**的 [translateApiUrl] / [translateModel] 而不是直接读
  /// `Pref.uiTranslateApiUrl` / `Pref.uiTranslateModel`——后者在内置引擎下
  /// 是空串（内置的地址/模型来自 BuiltinTranslate），会让按钮对内置用户消失。
  bool get canTranslate =>
      enabled && translateApiUrl.trim().isNotEmpty && translateModel.trim().isNotEmpty;

  /// 内容型文本（视频/专栏/直播标题等）是否需要翻译。
  ///
  /// 与界面文案的区别：内容量很大，且**只有目标语言不是原文（简体中文）时**
  /// 才值得翻——简体中文界面下这些标题本来就是中文，原样显示即可。
  bool get translateContent => enabled && !isSourceLanguage;

  /// 供 Obx 订阅的版本：读一次 [revision] 建立依赖，语言切换/关闭翻译后能重建。
  ///
  /// 搜索结果里的标题默认走「按 `<em>` 高亮分段渲染」那条路，逐段文本翻不了；
  /// 只有本方法返回 true 时才改成整句走 [tx]。所以调用点必须在 Obx 里读它，
  /// 才能跟着语言切换即时刷新。
  static bool contentTranslationActive() {
    if (!Get.isRegistered<UiTranslateService>()) return false;
    final service = to;
    service.revision.value;
    return service.translateContent;
  }

  /// 是否正在把搜索词翻成简体中文（结果页据此显示等待提示）。
  bool get isTranslatingQuery => queryTranslateBusy.value > 0;

  /// 把用户在搜索框里输入的词（当前界面语言）翻回简体中文。
  ///
  /// 返回 `null` 表示**不需要翻译**：界面翻译没开、目标语言本来就是简体中文、
  /// 输入为空、或翻译失败。调用方此时应直接用原词检索——搜索绝不能因为
  /// 翻译不可用而整个失效。
  ///
  /// 三条快路径，命中任一都不发请求：
  /// 1. 反向缓存命中（同一个词本次会话搜过）；
  /// 2. **反查译文缓存**——用户搜的词正好等于某条已译内容，直接反查出中文原文。
  ///    这正是「视频标题被译成日语后，用日语标题去搜」的场景，零成本；
  /// 3. 并发去重（结果页 5 个分栏同时开搜同一个词，只发一次请求）。
  Future<String?> translateQuery(String text) async {
    final query = text.trim();
    if (query.isEmpty || !translateContent) return null;

    final cached = _reverseCache[query];
    if (cached != null) return cached;

    final reversed = _reverseLookup(query);
    if (reversed != null) {
      _reverseCache[query] = reversed;
      _schedulePersistQuery();
      return reversed;
    }

    final pending = _queryInFlight[query];
    if (pending != null) return pending;

    final future = _translateToSource(query);
    _queryInFlight[query] = future;
    try {
      return await future;
    } finally {
      _queryInFlight.remove(query);
    }
  }

  /// 在「中文原文 -> 界面语言译文」缓存里反查：找出译文恰好等于 [text] 的原文。
  String? _reverseLookup(String text) {
    for (final entry in _cache.entries) {
      if (entry.value == text) return entry.key;
    }
    return null;
  }

  Future<String?> _translateToSource(String query) async {
    queryTranslateBusy.value++;
    try {
      final out = await _translateChunkToSource([query]);
      final result = out.isEmpty ? '' : out.first.trim();
      if (result.isEmpty) return null;
      _reverseCache[query] = result;
      _schedulePersistQuery();
      return result;
    } catch (e, st) {
      lastError.value = e.toString();
      logger.e('搜索词回译失败', error: e, stackTrace: st);
      return null;
    } finally {
      queryTranslateBusy.value--;
    }
  }

  bool showOriginalFor(String id) => _originalIds.contains(id);

  void toggleShowOriginal(String id) {
    if (!_originalIds.remove(id)) _originalIds.add(id);
    contentRev.value++;
  }

  /// 评论/动态正文取词：该条处于“显示原文”态返回原文，否则返回译文。
  ///
  /// 与 [tx] 同理，**先读一次 [revision] 再走提前返回**：这条路径同样会被
  /// `Obx(() => Text(...))` 包住，处于「显示原文」态时若直接返回，外层 Obx 就成了
  /// 空 Obx，会运行时报错并显示成灰色错误块。
  String commentText(String src, String id) {
    revision.value;
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
    // Target definitions are part of the translation contract. When prompts
    // change, old translations must not mask the new rules. The cache is
    // scoped to the currently selected language (language changes clear it),
    // so invalidate it once on upgrade.
    //
    // revision 4 (1.2.0): 内置引擎把指令从 user 挪进 system。在此之前产生的
    // 译文里可能混着我们指令的译文（表现为评论里反复出现「直接翻訳結果のみを
    // 出力し…」且随页面渲染轮数叠加）。这些坏译文已落盘、且以原文为 key，
    // **光改提示词不会自愈**——必须清一次缓存让它们重译。
    // 这次的提示词改动影响所有目标语言，所以不再按 revisedTargets 挑语言。
    const promptRevision = 4;
    if (Pref.uiTranslatePromptRevision < promptRevision) {
      Pref.uiTranslateCache = {};
      Pref.uiTranslatePromptRevision = promptRevision;
    }
    _cache.addAll(Pref.uiTranslateCache);
    _reverseCache.addAll(Pref.uiTranslateQueryCache);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _persistTimer?.cancel();
    _persistQueryTimer?.cancel();
    _revisionTimer?.cancel();
    _persist();
    _persistQuery();
    super.onClose();
  }

  /// 全局静态入口：把任意要显示的源字符串映射为译文。
  ///
  /// 该函数是同步的、必须在 build 里安全调用。未开启、空串、未命中缓存时
  /// 一律回退原文，同时把原文入队等待后台翻译。
  ///
  /// **必须在任何提前返回之前读一次 [revision]。** 调用方大量写成
  /// `Obx(() => Text(uiTx(x)))`，而 GetX 的 Obx 若整次 build 没读到任何可观察量
  /// 就直接运行时报错；报错后 release 构建会把该子树替换成灰色的错误块
  /// （`RenderErrorBox`）—— 用户看到的就是卡片里凭空多出一块灰。
  ///
  /// 空串是最容易踩到的提前返回分支：没填 UP 名的条目 `RcmdOwner.name` 就是 `''`，
  /// 于是「UP 名」那一行的 Obx 变成空 Obx、整行变灰。同理还有标题为空的信息流条目。
  static String tx(String src) {
    if (!Get.isRegistered<UiTranslateService>()) return src;
    final service = to;
    service.revision.value;
    if (src.isEmpty) return src;
    return service._tx(src);
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
    // 原文本来就用目标语言书写（日语界面里的日文标题、韩语界面里的韩文标题）
    // → 不需要翻译，原样返回：既省 token，也不会把专有名词译歪。
    // 只在「文字与语言一一对应」时才这么判（见 looksLikeNativeScript）。
    if (looksLikeNativeScript(src, currentLanguage.nativeScript)) return src;
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
    if (_pending.length >= _effectiveBatchSize) {
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
      for (var i = 0; i < uncached.length; i += _effectiveBatchSize) {
        final end = i + _effectiveBatchSize < uncached.length
            ? i + _effectiveBatchSize
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

  /// 反向（搜索词）缓存的节流写盘，与正缓存各自一个 timer，互不推迟。
  void _schedulePersistQuery() {
    _persistQueryTimer?.cancel();
    _persistQueryTimer = Timer(
      const Duration(milliseconds: 1200),
      _persistQuery,
    );
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
  ///
  /// 具体走哪一套由 [Pref.uiTranslateProvider] 决定：
  /// * **内置（默认）** → B 站官方免费接口的固定配置，**不需要密钥**；
  /// * **自备** → 用户填的 url / key / model。
  ///
  /// 两个引擎**共用同一份目标语言清单**，差异只在质量提示上。
  static bool get usingBuiltinTranslate =>
      Pref.uiTranslateProvider == TranslateProvider.builtin;

  static String get translateApiUrl => usingBuiltinTranslate
      ? BuiltinTranslate.apiUrl
      : Pref.uiTranslateApiUrl;
  static String get translateApiKey => usingBuiltinTranslate
      ? BuiltinTranslate.apiKey
      : Pref.uiTranslateApiKey;
  static String get translateModel =>
      usingBuiltinTranslate ? BuiltinTranslate.model : Pref.uiTranslateModel;

  /// 内置引擎**逐条**请求；自备引擎按 [_batchSize] 批量。
  ///
  /// 内置那个是翻译专精模型，官方推荐的调用方式就是单条模板；而接口免费，
  /// 没必要为省请求去赌批量格式能稳住。自备 API（多半按 token 计费）仍走批量。
  int get _effectiveBatchSize => usingBuiltinTranslate ? 1 : _batchSize;


  /// 内置官方模型的**逐条**翻译。
  ///
  /// 提示词刻意贴着官方文档给的模板写：单条、点明目标语言、要求直接输出译文。
  /// 不做 JSON 数组解析（只需要模型吐一段纯文本），出错面积因此小得多 —— 这是
  /// 「求稳」的取舍。字形归一化仍保留：简体/繁體目标由客户端兜底纠正。
  Future<List<String>> _builtinTranslate(List<String> sources) async {
    final lang = targetLang;
    final rule = currentLanguage.scriptRule;
    final results = <String>[];
    for (final src in sources) {
      final buf = StringBuffer();
      await for (final chunk in AiChatService.streamChat(
        messages: [
          // 指令必须放 system、user 只放纯正文。
          //
          // 两者挤在同一条 user 消息里时，正文越短、指令占比越高，Index-Translate
          // 越可能把整条消息当成待译内容一起翻——于是用户会看到「直接翻訳結果のみを
          // 出力し、いかなる説明も加えないでください」这种我们指令的日文译文混进评论，
          // 而且译文再被当成原文翻一次就会重复叠加（实测同一评论在列表页重复 3 次、
          // 详情页 5 次）。放进 system 即被排除在待译正文之外，实测输出干净。
          {
            'role': 'system',
            'content': '${rule.isEmpty ? '' : '$rule\n\n'}'
                '请将 user 消息翻译为$lang，只输出译文本身，不要添加任何说明。',
          },
          {'role': 'user', 'content': src},
        ],
        model: translateModel,
        apiUrl: translateApiUrl,
        apiKey: translateApiKey,
        // 内置引擎**固定关掉思考输出**，不看 Pref.uiTranslateThinking：
        // 官方接口虽然接受这个参数，但实测传 true / false 返回完全一样（它并不
        // 走思维链），而官方文档对这类接入的要求就是「强制关闭思考输出」。
        // 界面上这个开关也只对「自备 API」显示，这里固定 false 可以避免用户
        // 之前在自备 API 下开过、之后切到内置还带着 true 发过去。
        extraBody: const <String, dynamic>{'enable_thinking': false},
      )) {
        buf.write(chunk);
      }
      final out = buf.toString().trim();
      results.add(out.isEmpty ? src : out);
    }
    return _normalizeScripts(results, currentLanguage.script);
  }

  Future<List<String>> _translateChunk(List<String> sources) async {
    // 最后一道防线（token 保护）：真正发请求前再确认一次开关，
    // 任何入队/换语言/关闭时序问题都不可能导致关闭状态下产生 API 调用。
    if (!enabled) {
      _pending.clear();
      return const [];
    }
    // 内置官方模型走逐条模板，不走下面那套「编号列表 + JSON 数组」的批量格式。
    if (usingBuiltinTranslate) {
      return _builtinTranslate(sources);
    }
    final lang = targetLang;
    final numbered = StringBuffer();
    for (var i = 0; i < sources.length; i++) {
      numbered.writeln('${i + 1}. ${sources[i]}');
    }

    // 字形硬约束（简繁/方言目标才有内容）：放在最前面，模型对靠前的指令更敏感。
    final scriptRule = currentLanguage.scriptRule;
    final system =
        '${scriptRule.isEmpty ? '' : '$scriptRule\n\n'}'
        '你是应用界面本地化翻译引擎。用户会给出一个带编号的界面文案列表'
        '（每条可能为中文或外文），请把每一条翻译成『$lang』。'
        '严格要求：'
        '1) 只输出一个 JSON 数组，元素个数与输入条数相同、顺序一一对应，'
        '每个元素是该条的译文纯文本；'
        '2) 不要输出任何解释、说明或 Markdown 代码块围栏；'
        '3) 保留原文中的数字、占位符、标点、换行与专有名词，'
        '界面词尽量简短、术语一致；'
        '4) 严格遵守目标语言说明中的方言、地区与文字规范。每条译文必须完整使用'
        '同一个目标语言/方言，不得混用其他汉语方言，不得把不同方言拼成一句；'
        '原文含其他方言词时，也要统一转换为指定目标方言；'
        '5) **字形一致性**：每一条译文的字形必须统一——简体目标不得出现任何'
        '繁体字形，繁體目标不得出現任何簡體字形。'
        '如果原文本身就使用了目标语言的文字体系，原样保留其字形，不要改写。';
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
    return _normalizeScripts(
      _parseArray(buf.toString(), sources.length),
      currentLanguage.script,
    );
  }

  /// 反向翻译：把界面语言的检索词还原成中国大陆简体中文的搜索用词。
  ///
  /// 走与正向翻译完全相同的接口/模型/流式通道，只是提示词方向相反。
  Future<List<String>> _translateChunkToSource(List<String> sources) async {
    if (!enabled) return const [];
    final lang = currentLanguage.toModel;
    final numbered = StringBuffer();
    for (var i = 0; i < sources.length; i++) {
      numbered.writeln('${i + 1}. ${sources[i]}');
    }

    final system =
        '你是搜索词归一化引擎。用户会给出一个带编号的关键词列表，'
        '每个关键词的书写语言是『$lang』。'
        '请把每一条翻译成**中国大陆简体中文**的检索用词，'
        '用于在中文视频网站（哔哩哔哩）上检索。'
        '严格要求：'
        '1) 只输出一个 JSON 数组，元素个数与输入条数相同、顺序一一对应，'
        '每个元素是该条对应的简体中文检索词；'
        '2) 不要输出任何解释、说明或 Markdown 代码块围栏；'
        '3) 保留人名、作品名、数字与专有名词；专有名词在中文圈有通行译名时'
        '用通行译名，不要音译成生僻写法；'
        '4) 如果原文已经是简体中文，原样返回；'
        '5) 只输出检索词本身，不要加引号、书名号之外的解释，'
        '也不要加「搜索」「关键词」之类前缀。';
    final user = '待归一化列表：\n$numbered';

    final thinking = Pref.uiTranslateThinking;
    final extraBody = <String, dynamic>{'enable_thinking': thinking};

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
    // 反向翻译的目标固定是简体中文（B 站搜索只认简体），
    // 同样做一次字形归一化，免得把繁体词拿去搜。
    return _normalizeScripts(
      _parseArray(buf.toString(), sources.length),
      'Hans',
    );
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

  /// 按目标字形把一批译文做确定性归一化。
  ///
  /// 提示词只能"尽量"约束模型不串字形，模型偶发仍会漏一两个繁体/简体字；
  /// 这里用一张无歧义的字表兜底，保证落库的译文不再混字形。
  /// [script] 为 null（非中文家族）时是空操作。
  static List<String> _normalizeScripts(
    List<String> values,
    String? script,
  ) {
    if (script == null) return values;
    return values
        .map((value) => normalizeScript(value, script))
        .toList(growable: false);
  }

  void _persist() => Pref.uiTranslateCache = _cache;

  void _persistQuery() => Pref.uiTranslateQueryCache = _reverseCache;

  /// 清空翻译缓存（下次遇到同一字符串会重新翻译）。
  void clearCache() {
    _cache.clear();
    _reverseCache.clear();
    _pending.clear();
    lastError.value = null;
    Pref.uiTranslateCache = {};
    Pref.uiTranslateQueryCache = {};
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
