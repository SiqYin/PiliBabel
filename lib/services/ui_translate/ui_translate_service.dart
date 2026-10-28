import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

import 'package:PiliPlus/http/browser_ua.dart';
import 'package:PiliPlus/services/ai_chat/ai_chat_service.dart';
import 'package:PiliPlus/services/ui_translate/translate_provider.dart';
import 'package:PiliPlus/services/logger.dart';
import 'package:PiliPlus/services/ui_translate/app_language.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/io.dart';

/// AI 界面翻译服务（路线 B 的落地核心）。
///
/// 设计要点：
/// 1. 持久化「源中文 -> 译文」缓存表：任何字符串只翻译一次，命中即复用，
///    关闭重开不二次翻译（严格满足“译法固定”的需求）。
/// 2. 运行期在渲染边界同步返回：有缓存返回译文，无缓存先返回原文并入队，
///    后台批量翻译完成后写入缓存并自增 [revision] 触发 Obx 局部重建。
/// 3. 批量翻译：把攒到的一批字符串塞进一次 chat 请求（编号列表 -> JSON 数组），
///    显著降低冷启动时的 API 调用次数。

// 图片翻译的下载/请求统一走这里。两条路径分开：
//   - 接口请求（翻译 API）走系统代理，和 app 的 Request 层一致；
//   - 图床下载直连优先 —— app 里的封面图就是直连加载的，实测能通，而走系统
//     代理时这一段可能不通（Network is unreachable, errno 101），表现就是
//     封面正常、只有图片翻译失败。直连失败才退回代理兜底。
// 失败后立刻丢弃客户端：Dart 的 HttpClient 会把 DNS 解析和连接池留在实例里，
// 坏掉的状态会被一直复用，只有重启 app 才好。
Dio? _uiTxDio;
Dio? _uiTxDioDirect;
StreamSubscription<List<ConnectivityResult>>? _uiTxNetSub;

Dio _uiTxBuild(bool useProxy) {
  final dio = Dio(
    BaseOptions(connectTimeout: const Duration(seconds: 15)),
  );
  final host = Pref.systemProxyHost;
  final port = int.tryParse(Pref.systemProxyPort);
  final proxy =
      useProxy && Pref.enableSystemProxy && host.isNotEmpty && port != null;
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: proxy
        ? () => HttpClient()
            ..idleTimeout = const Duration(seconds: 15)
            ..findProxy = ((_) => 'PROXY $host:$port')
            ..badCertificateCallback = (cert, h, p) => true
        : () => HttpClient()..idleTimeout = const Duration(seconds: 15),
  );
  _uiTxNetSub ??= Connectivity().onConnectivityChanged.listen((_) {
    _uiTxDio = null;
    _uiTxDioDirect = null;
  });
  return dio;
}

/// 接口请求：走系统代理
Dio _uiTxClient() => _uiTxDio ??= _uiTxBuild(true);

/// 图床下载：直连优先
Dio _uiTxDirectClient() => _uiTxDioDirect ??= _uiTxBuild(false);

void _dropUiTxClient() {
  final a = _uiTxDio;
  final b = _uiTxDioDirect;
  _uiTxDio = null;
  _uiTxDioDirect = null;
  if (a != null) a.close(force: true);
  if (b != null) b.close(force: true);
}

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

  /// 译文缓存：**目标语言 -> (原文 -> 译文)**。
  ///
  /// 键里必须带目标语言。以前是「原文 -> 译文」一张平表：切换语言时虽然会整表
  /// 清空，但**切换那一刻仍在飞的老语言请求**回来后会照样写进这张表，于是那几条
  /// （常见是卡片上的 UP 名、标题）永远停在旧语言、还随缓存落盘，用户除了手动
  /// 「清除缓存」没有别的办法 —— 这就是「切到 B 语言后个别文本还留在 A 语言」的
  /// 成因。按语言分桶后，老语言的译文只会落进它自己的桶：既不会串进新语言，
  /// 切回原语言时还能直接复用。
  final Map<String, Map<String, String>> _cacheByLang = {};

  /// 语言码与原文之间的分隔符（原文里不会出现这个控制字符）。
  static const String _langSep = '\u0001';

  static String _bucketKey(String lang, String src) => '$lang$_langSep$src';

  /// 当前目标语言的缓存桶。
  Map<String, String> get _cache => _cacheByLang.putIfAbsent(
        currentLanguage.code,
        () => <String, String>{},
      );

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
  /// 判断搜索词是不是（简体）中文原文。
  ///
  /// 含汉字、且不含日文假名/韩文谚文时算中文。B 站搜索接口只认中文原文：
  /// 用户直接输入中文时它本身就是接口要的词，再过一遍翻译纯属浪费，
  /// 界面翻译开着时还会把中文当外文翻一遍，反而搜不到。
  static bool isSourceLanguageChinese(String text) =>
      looksLikeSimplifiedChinese(text);

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
    // 输入的就是简体中文：它本身就是接口要的原文，不用过翻译。
    if (isSourceLanguageChinese(query)) return null;

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
    // 反向缓存的方向是「界面语言文本 -> 简体中文」，语言一换就不成立：
    // 请求回来时语言已经变了的话，这条结果不能再写回。
    final reqLang = currentLanguage.code;
    try {
      final out = await _translateChunkToSource([query]);
      final result = out.isEmpty ? '' : out.first.trim();
      if (result.isEmpty) return null;
      if (reqLang == currentLanguage.code) {
        _reverseCache[query] = result;
        _schedulePersistQuery();
      }
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
    // 评论区排序标签（左上/右上）：高频出现，提前译好，避免首屏显示原文。
    '最新评论',
    '最新',
    '最热评论',
    '最热',
    '精选评论',
    '精选',
    // 缓存/下载界面状态（见 bili_download_entry_info.dart）：
    '正在下载',
    '正在下载音频',
    '获取弹幕',
    '获取播放地址',
    '下载完成',
    '下载失败',
    '音频下载失败',
    '获取弹幕失败',
    '获取播放地址失败',
    '暂停中',
    '等待中',
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
    // 5：提示词新增「只做翻译、不解答」与「无需翻译时原样输出」，
    // 且空输入判据由「非空」收紧为「含可译字符」——旧译文必须重译。
    // 6：日语下界面标签改固定短译（已关注→フォロー中、关注→フォローする）。
    // 旧译文里已经缓存了「フォローしました」这类长译法，而缓存以原文为 key、
    // 光改提示词不会自愈，必须清一次让它重译。
    // 7：缓存从「原文 -> 译文」平表改成「语言 + 原文 -> 译文」。旧表没有语言维度，
    // 里面混着历史切换语言时被老语言请求写进去的坏条目、无法判断归属，只能整体
    // 丢弃重译一次（一次性代价，换来以后切换语言不再串语言）。
    const promptRevision = 7;
    if (Pref.uiTranslatePromptRevision < promptRevision) {
      Pref.uiTranslateCache = {};
      Pref.uiTranslatePromptRevision = promptRevision;
    }
    _loadCache(Pref.uiTranslateCache);
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
    // 纯空白同样算「没有可翻的东西」——**不能只判 isEmpty**。
    //
    // 只判空串会漏掉「只有空格 / 换行 / 零宽字符」的内容，而模型收到这样的
    // user 消息时会回一句**元信息**而不是译文（实测原文：
    // 「（ユーザーからのメッセージが空であるため、翻訳できません。）」）。
    // 那句话是非空的，于是被当成译文写进缓存、显示在评论区里 —— 用户看到的就是
    // 「译文里混进了模型自己的说明」。这是本问题在接入内置引擎**之前**就存在的
    // 原因：它与提示词放在 system 还是 user 无关，纯属空输入没拦住。
    if (!_hasTranslatableText(src)) return src;
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
    // 人工固定译名优先于缓存与模型：钉住的译法必须始终生效。
    final pinned = _pinnedTranslations[src]?[currentLanguage.code];
    if (pinned != null) return pinned;
    final hit = _cache[src];
    if (hit != null) return hit;
    // 尚未翻译：先显示原文，排进待翻队列。
    if (_pending.add(src)) _scheduleFlush();
    return src;
  }

  /// 人工固定的译名。结构：原文 → { 目标语言代码 → 固定译文 }。
  ///
  /// 有些界面词条的译法是有明确口径的，交给模型自由发挥会出现语气/长度都不对的
  /// 结果（例：「关注的人」在日语里官方口径就是「フォロー中」，模型可能给出
  /// 「フォローしている人」这类又长又不地道的说法）。钉住之后：
  /// 命中即直接返回，不走缓存、不发请求，也不会被模型结果覆盖。
  static const Map<String, Map<String, String>> _pinnedTranslations = {
    '关注的人': {'ja': 'フォロー中'},
  };

  /// 与 [tx] 同源，但**等译文真正到齐再返回**。
  ///
  /// toast / 弹窗这类只渲染一次、之后不会重建的地方必须用它：`tx` 是同步读缓存的，
  /// 显示那一刻缓存里还没有译文，用户看到的就永远是原文（网络错误提示、图片翻译
  /// 报错都栽在这里）。翻译关闭、原文就是目标语言、没有可翻内容时原样返回。
  Future<String> txAsync(String src) async {
    final now = _tx(src);
    if (now != src) return now;
    if (!enabled || !_hasTranslatableText(src)) return src;
    // 与 _flush 同理：结果归属**发起时**的语言，不归属当前语言。
    final reqLang = currentLanguage.code;
    try {
      final res = await _translateChunk([src]);
      final value = res.isNotEmpty ? res.first.trim() : '';
      if (value.isNotEmpty && value != src) {
        _cacheByLang.putIfAbsent(
          reqLang,
          () => <String, String>{},
        )[src] = value;
        if (reqLang == currentLanguage.code) _bumpRevisionSoon();
        _schedulePersist();
        return value;
      }
    } catch (_) {}
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
    // 这一轮请求用的是**发起时**的目标语言：译文只能写进这个语言的桶。
    // 否则用户在请求返回前切换了语言，老语言译文会以新语言的名义落进缓存，
    // 表现为「切到 B 后个别文本还留在 A」。
    final reqLang = currentLanguage.code;
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
          final bucket = _cacheByLang.putIfAbsent(
            reqLang,
            () => <String, String>{},
          );
          for (var j = 0; j < chunk.length && j < translated.length; j++) {
            final value = translated[j].trim();
            if (value.isNotEmpty && value != chunk[j]) {
              bucket[chunk[j]] = value;
              changed = true;
            }
          }
          if (changed) {
            // 语言已经换掉时不再刷新界面：这批译文属于老语言，落进它自己的桶
            // 就够了（切回去还能复用），刷新只会白重建一轮。
            if (reqLang == currentLanguage.code) _bumpRevisionSoon();
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
  /// 是否含有「值得翻译」的字符（拉丁字母 / 假名 / 汉字 / 谚文 / 泰文等）。
  ///
  /// 纯空白、**纯标点、纯数字、纯表情**都不含可译内容。这一条比「非空」严格得多，
  /// 而它是必须的：评论正文是按「表情 / 话题 / @ / 链接」切段后**逐段**翻译的
  /// （见 `reply_item_grpc.dart` 的 `addPlainTextSpan`），相邻表情之间会切出
  /// 空白或纯符号的小段。把这些段发给模型，它不会返回译文，而是回一句
  /// 「（ユーザーからのメッセージが空であるため、翻訳できません。）」——
  /// 那句话非空，于是被当成译文插在评论中间（截图里每个表情后面各跟一句、
  /// 一条评论里出现四五次，就是这么来的）。
  static final _translatableRegExp = RegExp(
    r'[A-Za-z\u00c0-\u024f' // 拉丁（含带音标字母）
    r'\u0370-\u03ff' // 希腊
    r'\u0400-\u04ff' // 西里尔
    r'\u0590-\u05ff' // 希伯来
    r'\u0600-\u06ff' // 阿拉伯
    r'\u0900-\u097f' // 天城文
    r'\u0e00-\u0e7f' // 泰文
    r'\u3040-\u30ff' // 平假名 / 片假名
    r'\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff' // 汉字（含扩展 A / 兼容）
    r'\uac00-\ud7af]', // 谚文
  );

  static bool _hasTranslatableText(String s) =>
      _translatableRegExp.hasMatch(s);

  /// 模型自己的「说明句」而非译文。实测形态（可能被括号包住）：
  /// 「（ユーザーからのメッセージが空であるため、翻訳できません。）」
  ///
  /// **故意不去匹配「翻译」二字本身** —— 正常评论完全可能就在讲翻译，那样会误伤。
  static final _metaNoteRegExp = RegExp(
    r'[（(][^（()）]{0,80}?'
    r'(?:翻訳できません|翻訳することができません|无法翻译|無法翻譯|不能翻译|翻译不了'
    r'|メッセージが空|消息为空|内容为空|文本为空|入力が空|内容が空)'
    r'[^（()）]{0,80}?[）)]'
    r'|翻訳できません|翻訳することができません|无法翻译|無法翻譯|不能翻译|翻译不了',
  );

  /// 把模型输出里的**元信息句剥掉**，而不是整条丢弃。
  ///
  /// 实测这些说明会插在**正常译文中间**、且同一段里出现多次；整条丢弃会把好译文
  /// 也一起丢掉（用户看到的会是原文），所以逐个删除。删完若什么都不剩，调用方
  /// 才退回原文。
  static String _stripMetaNotes(String s) => s.replaceAll(_metaNoteRegExp, '');

  /// 日语下界面标签的固定短译。
  ///
  /// 只在「整条内容本身就是一个独立标签 / 按钮文字」时套用；同一个词出现在
  /// 句子或正文里（整条不只有这个词）仍按正常翻译走。这个适用条件写进提示词
  /// 让模型判断，而不是在客户端按字符串相等改写译文 —— 后者会误伤
  /// 「这句话里提到了已关注」这类正常内容。
  ///
  /// 只给日语配：中文「已关注」直译成「フォローしました」在标签里过长，
  /// 首页视频卡片下方会把紧邻的 UP 名挤掉。
  String get _japaneseLabelRule {
    if (currentLanguage.code != 'ja') return '';
    return '**日语界面标签固定短译**：'
        '如果某一条内容整体就是一个独立的界面标签或按钮文字'
        '（整条只有该词本身、不含其他成分），必须使用下面的固定短译，'
        '不得使用更长的说法：「已关注」必须译为「フォロー中」，'
        '不要译成「フォローしました」；'
        '「关注」必须译为「フォローする」，不要译成「フォロー」。'
        '如果这些词是作为句子或正文的一部分出现（整条不只有这个词），'
        '则按正常翻译处理，不要套用上面的固定短译。';
  }

  /// 探测内置官方模型（Index-Translate）是否可用。
  ///
  /// 走一次最小的真实翻译请求：拿到任意一段非空输出就算通，任何异常、超时、
  /// 空输出都算不通。它判断的是「官方接口本身挂没挂」，所以**不读用户当前的
  /// 引擎设置**，永远打官方地址 —— 用户已经切到自备 API 时也要能测出官方恢复了。
  static Future<bool> pingBuiltin() async {
    try {
      return await _pingBuiltinOnce().timeout(const Duration(seconds: 15));
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _pingBuiltinOnce() async {
    final buf = StringBuffer();
    await for (final chunk in AiChatService.streamChat(
      messages: const [
        {
          'role': 'system',
          'content': '请把 user 消息翻译为日语。只输出译文本身。',
        },
        {'role': 'user', 'content': '你好'},
      ],
      model: BuiltinTranslate.model,
      apiUrl: BuiltinTranslate.apiUrl,
      apiKey: BuiltinTranslate.apiKey,
      extraBody: const <String, dynamic>{'enable_thinking': false},
    )) {
      buf.write(chunk);
      if (buf.toString().trim().isNotEmpty) return true;
    }
    return buf.toString().trim().isNotEmpty;
  }

  Future<List<String>> _builtinTranslate(List<String> sources) async {
    final lang = targetLang;
    final rule = currentLanguage.scriptRule;
    final labelRule = _japaneseLabelRule;
    final results = <String>[];
    for (final src in sources) {
      // 没有可翻内容的条目**原样返回、绝不发请求**（理由见 _tx 里对纯空白的说明）
      if (!_hasTranslatableText(src)) {
        results.add(src);
        continue;
      }
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
                '请将 user 消息翻译为$lang。只做翻译，'
                '只输出译文本身：不要回答、解释、评论、补充，'
                '也不要就原文提出的任何问题给出看法。'
                '如果内容无需翻译（纯符号、纯数字、纯表情等），原样输出，'
                '不要添加任何说明。'
                '${labelRule.isEmpty ? '' : '\n$labelRule'}',
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
      final raw = buf.toString().trim();
      // 安全网：模型会在译文中间插入自己的说明句（见 _stripMetaNotes）。
      // 这里把说明句剥离掉、保留正常译文；剥完什么都不剩才退回原文。
      final out = _stripMetaNotes(raw).trim();
      results.add(out.isEmpty ? src : out);
    }
    return _normalizeScripts(results, currentLanguage.script);
  }

  /// 用内置多模态能力描述一张图片（视频封面）上的文字。
  ///
  /// Index-Translate 支持图片输入（`image_url` 走 OpenAI 兼容格式，由服务端
  /// 自行抓取图片）。返回可直接展示的文案；识别不到文字时模型会按提示词
  /// 回一句说明，所以这里不做二次判断。失败返回 null，由界面兜底。
  /// [isLongImage] 为真时走长图分支：只出译文、不列原文，超时也放宽。
  /// [onDownloadProgress] 回调图片下载百分比（0~100），[cancelToken] 供弹窗「关闭」中断。
  Future<String?> describeImage(
    String imageUrl, {
    bool isLongImage = false,
    void Function(int percent)? onDownloadProgress,
    CancelToken? cancelToken,
  }) async {
    final base = _normalizeApiBase(translateApiUrl);
    if (base.isEmpty) {
      throw Exception('翻译接口地址为空');
    }
    if (imageUrl.isEmpty) {
      throw Exception('这张图片没有可用的图片地址');
    }
    // 动图不接：GIF 按后缀直接挡掉，WebP 动图拿到字节后再判一次
    if (_isAnimatedUrl(imageUrl)) {
      throw Exception('动图不支持翻译');
    }
    final lang = currentLanguage.toModel;

    // 图片先由 App 自己抓下来，转成 data URI 一起发。
    // 之前是把 B 站图床的直链交给服务端去抓，那一步会静默失败（图床需要 Referer），
    // 表现出来就是「请求已发出但拿不到译文」。
    //
    // 抓取顺序：先要图床的压缩版本，再退原图。识图只要文字看得清，而原图动辄
    // 上兆 —— 下载和 base64 上传都随之变大，这正是「偶尔要等很久」的主要来源。
    List<int>? bytes;
    Object? lastErr;
    final fallback = imageUrl.startsWith('http://')
        ? 'https://${imageUrl.substring(7)}'
        : imageUrl;
    final candidateUrls = [_smallImageUrl(imageUrl), fallback];
    // 两轮尝试：先全部直连（app 里的封面图就是直连加载的，实测能通），再全部
    // 走系统代理兜底。之前一律走代理，代理到图床这一段不通时就一直失败，
    // 表现就是封面正常、只有图片翻译报 Network is unreachable。
    for (var idx = 0; idx < candidateUrls.length * 2; idx++) {
      final url = candidateUrls[idx % candidateUrls.length];
      final client =
          idx < candidateUrls.length ? _uiTxDirectClient() : _uiTxClient();
      try {
        final img = await client.get<List<int>>(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {
              'Referer': 'https://www.bilibili.com/',
              'User-Agent': BrowserUa.mob,
            },
            sendTimeout: const Duration(seconds: 20),
            receiveTimeout: Duration(seconds: isLongImage ? 120 : 60),
          ),
          cancelToken: cancelToken,
          onReceiveProgress: (r, total) {
            if (total > 0) onDownloadProgress?.call((r * 100 ~/ total));
          },
        );
        final data = img.data;
        if (data != null && data.isNotEmpty) {
          bytes = data;
          break;
        }
      } catch (e) {
        lastErr = e;
        _dropUiTxClient();
      }
    }
    if (bytes == null) {
      throw Exception('图片下载失败：$lastErr');
    }
    if (_isAnimatedBytes(bytes)) {
      throw Exception('动图不支持翻译');
    }
    final dataUri = 'data:${_imageMime(bytes)};base64,${base64Encode(bytes)}';

    Map<String, dynamic> body(String image) => {
      'model': translateModel,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': isLongImage
              ? '这是一张长图，图中文字可能很多，请用$lang完成下面这件事：'
                  '输出语言必须是$lang。'
                  '【最重要的要求】除了照抄的原文之外，回答里每一句都必须用$lang书写：'
                  '译文用$lang、两个标签用$lang、最后的画面描述也用$lang。'
                  '图片里的文字是简体中文、或者这段指令本身是简体中文，'
                  '都不是你用简体中文回答的理由；只要$lang不是简体中文，'
                  '回答里就不该出现简体中文的句子。'
                                    '直接输出$lang译文，不要输出原文，也不要逐段标注「原文／译文」，'
                  '按图中文字从上到下的顺序译出，尽量保持原有分段。'
                  '即使某段文字本身就是$lang，也照样译出、保持原样，不要跳过。'
                  '识别时不要猜字，看不清的不要编。'
                  '同一段译文只输出一次，绝不重复；一旦发现自己开始重复，立刻停止。'
                  '原文或译文为空的段落直接跳过。'
                  '只输出译文本身，不要客套、不要解释你在做什么。'
              : '你是翻译引擎，请完成下面这件事，'
                  '输出语言必须是$lang。'
                  '【最重要的要求】除了照抄的原文之外，回答里每一句都必须用$lang书写：'
                  '译文用$lang、两个标签用$lang、最后的画面描述也用$lang。'
                  '图片里的文字是简体中文、或者这段指令本身是简体中文，'
                  '都不是你用简体中文回答的理由；只要$lang不是简体中文，'
                  '回答里就不该出现简体中文的句子。'
                                    '先逐段识别图片中的文字，再给出每段对应的译文。'
                  '即使图中某一段文字本身就是$lang，也照样把它作为原文列出并给出译文，'
                  '不要因为「看起来已经是目标语言」就跳过不译；原文也可能有中英日混排。'
                  '格式：每一段先写「原文」标签再照抄图上原文（保持原语言），'
                  '然后写「译文」标签再写$lang译文；'
                  '这两个标签本身也必须用$lang书写'
                  '（$lang是英语时写 Original 和 Translation，是日语时写 原文 和 訳文）。'
                  '图中有几段文字就分成几组、一组一行，逐组列出。'
                  '图上只有一两个字、只有一组文字时，就只列这一组，'
                  '不要为了凑数补任何空条目，也不要把同一组重复列出来。'
                  '每一组文字只允许出现一次；原文或译文为空的那一组直接不要写。'
                  '如果你发现自己开始重复同样的内容，立刻停下来。'
                  '识别时不要猜字，图上有什么就写什么，看不清的不要编。'
                  '列完文字之后必须再用一两句话用$lang描述图片的内容。'
                  '这一段是必须的：不能省略、不能跳过、不能用「同上」代替，'
                  '哪怕图中只有一两个字也要写。'
                  '如果图中没有文字，就用$lang说明未检测到文字，然后用$lang描述图片内容。'
                  '只输出结果本身，不要客套、不要解释你在做什么。',
            },
            {
              'type': 'image_url',
              'image_url': {'url': image},
            },
          ],
        },
      ],
      'enable_thinking': false,
      'max_tokens': isLongImage ? 8000 : 2500,
    };

    final uri = '$base/chat/completions';
    final opts = Options(
      headers: translateApiKey.isEmpty
          ? null
          : {'Authorization': 'Bearer $translateApiKey'},
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 300),
    );

    Response<Map<String, dynamic>> res;
    try {
      res = await _uiTxClient().post<Map<String, dynamic>>(
        uri,
        options: opts,
        data: body(dataUri),
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 0;
      if (code >= 500) {
        // 服务端不认 data URI 时退回直发图片地址，由服务端自己抓图
        _dropUiTxClient();
        res = await _uiTxClient().post<Map<String, dynamic>>(
          uri,
          options: opts,
          data: body(imageUrl),
        );
      } else {
        rethrow;
      }
    }

    final choices = res.data?['choices'];
    if (choices is List && choices.isNotEmpty) {
      final message = choices.first['message'];
      final content = message is Map ? message['content'] : null;
      if (content is String && content.trim().isNotEmpty) {
        return _cleanImageOutput(content);
      }
    }
    throw Exception('接口返回内容为空（HTTP ${res.statusCode}）');
  }

  /// 模型在图里文字很少时会退化成无限重复（补空条目，或整段循环刷同一两句），
  /// 这里做兜底：丢掉空条目、切掉重复的循环尾巴、限制总行数。
  /// 提示词里已经要求不要重复，但模型不保证听话，所以输出侧再兜一层。
  static String _cleanImageOutput(String raw) {
    final lines = <String>[];
    for (final line in raw.split('\n')) {
      final t = line.trim();
      if (t.isEmpty) continue;
      // 丢掉「原文：」这种冒号后面什么都没有的空条目
      final i = t.lastIndexOf('：') > t.lastIndexOf(':')
          ? t.lastIndexOf('：')
          : t.lastIndexOf(':');
      if (i >= 0 && t.substring(i + 1).trim().isEmpty) continue;
      lines.add(t);
    }
    // 切掉重复循环：从末尾找一个最短周期，若与前一周期完全相同，
    // 说明模型开始刷同一段内容了，把重复的部分整段砍掉
    for (var period = 1; period <= 8; period++) {
      if (lines.length < period * 2) break;
      final n = lines.length;
      final tail = lines.sublist(n - period).join('\u0001');
      final prev = lines.sublist(n - period * 2, n - period).join('\u0001');
      if (tail == prev) {
        var cut = n - period;
        while (cut - period >= 0 &&
            lines.sublist(cut - period, cut).join('\u0001') == tail) {
          cut -= period;
        }
        return lines.sublist(0, cut).join('\n');
      }
    }
    // 兜底：正常的图文翻译不会有几百行
    if (lines.length > 300) {
      return lines.sublist(0, 300).join('\n');
    }
    return lines.join('\n');
  }

  /// 图床压缩版：B 站图片服务支持 `@<quality>q.<fmt>` 后缀。
  /// 已带处理参数的地址不再叠加，避免拼出无效参数。
  static String _smallImageUrl(String url) {
    final fixed = url.startsWith('http://')
        ? 'https://${url.substring(7)}'
        : url;
    if (fixed.contains('@')) {
      return fixed;
    }
    final dot = fixed.lastIndexOf('.');
    if (dot <= fixed.lastIndexOf('/')) {
      return fixed;
    }
    // 720w 限宽 + 60q：识图只要文字看得清，原图动辄几兆、下载就能吃掉十几秒
    return '${fixed.substring(0, dot)}@720w_1e_60q.webp';
  }

  /// GIF 一律当动图（B 站评论区的动图基本都是 gif 后缀）
  static bool _isAnimatedUrl(String url) =>
      url.split('@').first.toLowerCase().endsWith('.gif');

  /// 字节级判动图：GIF87a/GIF89a，以及带 ANIM 块的 WebP
  static bool _isAnimatedBytes(List<int> b) {
    if (b.length > 6 && b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46) {
      return true;
    }
    if (b.length > 12 &&
        b[0] == 0x52 &&
        b[1] == 0x49 &&
        b[2] == 0x46 &&
        b[3] == 0x46 &&
        b[8] == 0x57 &&
        b[9] == 0x45 &&
        b[10] == 0x42 &&
        b[11] == 0x50) {
      for (var i = 12; i + 4 <= b.length; i++) {
        if (b[i] == 0x41 &&
            b[i + 1] == 0x4E &&
            b[i + 2] == 0x49 &&
            b[i + 3] == 0x4D) {
          return true; // 'ANIM'
        }
      }
    }
    return false;
  }

  /// 按字节头判断图片真实格式：B 站图床对移动端 UA 会返回 WebP，
  /// 一律按 jpeg 声明会让服务端解码失败。
  static String _imageMime(List<int> b) {
    if (b.length > 12 &&
        b[0] == 0x52 &&
        b[1] == 0x49 &&
        b[2] == 0x46 &&
        b[3] == 0x46 &&
        b[8] == 0x57 &&
        b[9] == 0x45 &&
        b[10] == 0x42 &&
        b[11] == 0x50) {
      return 'image/webp';
    }
    if (b.length > 8 &&
        b[0] == 0x89 &&
        b[1] == 0x50 &&
        b[2] == 0x4E &&
        b[3] == 0x47) {
      return 'image/png';
    }
    if (b.length > 4 && b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46) {
      return 'image/gif';
    }
    if (b.length > 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
      return 'image/jpeg';
    }
    return 'image/jpeg';
  }

  /// 兼容两种写法：`.../v1` 直接用，只有域名时补上 `/v1`。
  static String _normalizeApiBase(String url) {
    var u = url.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    if (u.isEmpty) return '';
    return u.contains('/v1') ? u : '\$u/v1';
  }

  /// 供字幕这类大段正文复用：把一批文本翻成当前界面语言。
  /// 翻译不可用、或返回条数对不上时原样返回，调用方不必自己兜底。
  Future<List<String>> translateTexts(List<String> sources) async {
    if (!translateContent || sources.isEmpty) return sources;
    try {
      final out = await _translateChunk(sources);
      if (out.length == sources.length) return out;
    } catch (_) {}
    return sources;
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
    final labelRule = _japaneseLabelRule;
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
        '如果原文本身就使用了目标语言的文字体系，原样保留其字形，不要改写；'
        '6) **只做翻译**：不要回答、解释、评论或补充原文提出的任何问题，'
        '也不要输出任何说明性文字；某条内容无需翻译（纯符号/数字/表情）时，'
        '原样返回该条。'
        '${labelRule.isEmpty ? '' : '\n7) $labelRule'}';
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

  /// 从持久化表还原分语言缓存；没有语言前缀的旧条目一律丢弃（见 promptRevision 7）。
  void _loadCache(Map<String, String> raw) {
    for (final entry in raw.entries) {
      final i = entry.key.indexOf(_langSep);
      if (i <= 0) continue;
      _cacheByLang.putIfAbsent(
        entry.key.substring(0, i),
        () => <String, String>{},
      )[entry.key.substring(i + 1)] = entry.value;
    }
  }

  void _persist() {
    final out = <String, String>{};
    for (final bucket in _cacheByLang.entries) {
      for (final item in bucket.value.entries) {
        out[_bucketKey(bucket.key, item.key)] = item.value;
      }
    }
    Pref.uiTranslateCache = out;
  }

  void _persistQuery() => Pref.uiTranslateQueryCache = _reverseCache;

  /// 清空翻译缓存（下次遇到同一字符串会重新翻译）。
  void clearCache() {
    _cacheByLang.clear();
    _reverseCache.clear();
    _queryInFlight.clear();
    _pending.clear();
    lastError.value = null;
    Pref.uiTranslateCache = {};
    Pref.uiTranslateQueryCache = {};
    revision.value++;
  }

  /// 目标语言切换后调用。
  ///
  /// **不再整表清空**：译文缓存已按语言分桶，旧语言的译文留在自己的桶里，
  /// 切回去还能直接复用。这里只做三件事：
  /// 1. 丢掉「反向缓存」与在飞的检索词翻译 —— 它们的方向是「界面语言文本 ->
  ///    简体中文」，语言一换就不成立；
  /// 2. 清空待翻队列（这些字符串会在重建时按新语言重新入队）；
  /// 3. 自增 revision 触发全量重建，让新语言立刻生效。
  void resetForNewLanguage() {
    _reverseCache.clear();
    _queryInFlight.clear();
    _pending.clear();
    lastError.value = null;
    Pref.uiTranslateQueryCache = {};
    revision.value++;
  }

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
/// [uiTxP] 的异步版：先把模板填好，再等译文到齐。toast / 弹窗用这个。
Future<String> uiTxPAsync(String template, List<Object?> args) =>
    UiTranslateService.to.txAsync(uiTxP(template, args));

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
