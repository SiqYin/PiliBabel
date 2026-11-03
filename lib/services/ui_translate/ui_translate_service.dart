import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

import 'package:PiliPlus/http/browser_ua.dart';
import 'package:PiliPlus/services/ai_chat/ai_chat_service.dart';
import 'package:PiliPlus/services/ui_translate/translate_provider.dart';
import 'package:PiliPlus/services/logger.dart';
import 'package:PiliPlus/services/ui_translate/app_language.dart';
import 'package:PiliPlus/services/ui_translate/game_glossary.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/io.dart';

/// 调用处能容纳的译文宽度层级，供术语表选择全称/简称。
///
/// 分层口径（窄 → 宽）：[tight] 列表标题/按钮/Tab；[normal] 卡片标题等默认
/// 界面位置；[wide] 详情正文。越窄越倾向官方简称（ゼンゼロ、ブルアカ…）。
enum UiTextWidth { tight, normal, wide }

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

  /// **高优先级**待翻队列。
  ///
  /// 使用场景：更新弹窗在 App 启动那一刻就出现，而主页面同一时间会一次性把几十条
  /// 界面文案排进 [_pending]。如果按普通队列走，用户要对着未翻译的弹窗等很久。
  ///
  /// 所以弹窗正文走这里：flush 时**先翻完这一批**，再去处理普通队列
  /// （见 [_flush] 顶部的取队列逻辑）。
  final Set<String> _pendingUrgent = <String>{};

  /// 翻译缓存的写入进度（用于 UI 读取以触发 Obx 重建）。
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
    // 评论区按窄位选型：这里是社区语境，游戏术语优先用通行简称
    // （ゼンゼロ / スタレ / ブルアカ / アクナイ…），与用户口径一致。
    return _tx(src, UiTextWidth.tight);
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
    // 8：提示词新增「平行变体风格一致」约束（「缓存视频/缓存音频」这类成组词条必须
    // 用同一构词模式）。旧缓存里存的是风格不统一的译法，不重译就不会自愈。
    // 9：术语表接入 + 全称/简称机制。
    // 10：用户再次强调「内部统一」——之前的第 8 条约束写得太含糊（只说"同一构词模式"
    // 没说清「要么全 A 要么全 B」），模型仍产出「動画をキャッシュ」+「キャッシュ音響」
    // 这种混搭。这次把规则写成可判定的形式，并把缓存/下载那组成组词条直接钉死。
    const promptRevision = 10;
    if (Pref.uiTranslatePromptRevision < promptRevision) {
      Pref.uiTranslateCache = {};
      Pref.uiTranslatePromptRevision = promptRevision;
    }
    _loadCache(Pref.uiTranslateCache);
    _reverseCache.addAll(Pref.uiTranslateQueryCache);
    // 预热术语表索引：5 万多条形态的构建挪到启动后台，避免首帧卡死。
    // 只在已启用翻译时才需要；默认所有词表关闭，构建出来也是空表。
    warmGlossary();
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
  ///
  /// [width] 描述调用处能容纳的译文宽度层级（见 [UiTextWidth]）：术语表里的
  /// 全称/简称按它决定用哪一个。默认 [UiTextWidth.normal]，现有调用方无需改动；
  /// 列表标题 / 按钮这类最窄的位置用 [txTight]。
  static String tx(String src, {UiTextWidth width = UiTextWidth.normal}) {
    if (!Get.isRegistered<UiTranslateService>()) return src;
    final service = to;
    service.revision.value;
    if (src.isEmpty) return src;
    return service._tx(src, width);
  }

  /// [tx] 的窄位变体：列表标题 / 按钮 / Tab 等最窄处显式使用，
  /// 术语命中时倾向用官方简称（ゼンゼロ、ブルアカ这一类）。
  static String txTight(String src) => tx(src, width: UiTextWidth.tight);

  /// **高优先级**变体：译文插队到普通队列之前。
  ///
  /// 只给「用户一进 App 就盯着看、且必须等译文」的内容用 —— 目前只有更新弹窗。
  /// 主界面会在启动那一刻把几十条文案塞进普通队列，弹窗正文若也排队，
  /// 用户就得对着未翻译的更新说明干等（见 [_pendingUrgent]）。
  static String txUrgent(String src) {
    if (!Get.isRegistered<UiTranslateService>()) return src;
    final service = to;
    // 与 tx 一样先读 revision：这样调用点所在的 Obx 才能在译文回来后重建。
    service.revision.value;
    if (src.isEmpty) return src;
    return service._txUrgent(src);
  }

  /// 批量**预热**翻译：用户还没打开某个二级界面 / 弹窗时，先把里面可能出现的
  /// 文案排进队列翻好，等他真正点开就能直接看到译文。
  ///
  /// 场景：进入「我的 → 离线缓存」后，缓存视频右侧 ⋮ 会弹出十几个菜单项、
  /// 点删除还会再弹确认框——这些文案此时一个都没渲染过，自然也没进过翻译队列。
  /// 等用户点开才翻，就会先看到中文再跳成日文。
  ///
  /// 优先级：走 [_pendingUrgent]（与更新弹窗同一档），因为它们属于
  /// 「用户马上就要看」的内容，应当排在主界面那些滚动才可见的文案前面。
  ///
  /// 已缓存 / 已命中术语表的条目直接跳过，不产生请求。
  static void precache(Iterable<String> sources) {
    if (!Get.isRegistered<UiTranslateService>()) return;
    final service = to;
    if (!service.enabled) return;
    // currentLanguage 是**实例**成员（静态上下文里直接写会 Undefined name），
    // 先取一次；_pinnedTranslations 是 static const，直接类内引用即可。
    final langCode = service.currentLanguage.code;
    for (final src in sources) {
      if (src.isEmpty) continue;
      // 已经翻好的直接跳过（缓存命中是同步的，不花钱）
      if (service._cache.containsKey(src)) continue;
      if (_pinnedTranslations[src]?[langCode] != null) {
        continue;
      }
      service._pending.remove(src);
      service._pendingUrgent.add(src);
    }
    if (service._pendingUrgent.isNotEmpty) service._scheduleFlush();
  }
  /// [precache] 的延迟版：等首屏渲染完再排队。
  ///
  /// 页面 initState 里直接 precache 会和「首屏可见文案入队」撞在同一时刻，
  /// 挤进同一批反而拖慢首屏。延迟一会儿后首屏那批已经在发请求，
  /// 再把「点开才出现」的文案补进去，用户真正点开时刚好翻好。
  static void precacheLater(Iterable<String> sources) {
    final list = sources.toList(growable: false);
    Future<void>.delayed(
      const Duration(milliseconds: 600),
      () => precache(list),
    );
  }

  String _tx(String src, [UiTextWidth width = UiTextWidth.normal]) {
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
    // 缓存优先：稳态下这一步就是一次 map 查询，直接返回，不必碰术语表。
    //
    // 顺序很关键。之前是「术语表 → 缓存」，而术语表未命中整串时会退化成
    // 遍历上万个形态做子串扫描 —— 每个还没翻好的控件、每一帧都要跑一遍，
    // 这正是「打开 AI 翻译后界面整体变卡」的根因。
    final hit = _cache[src];
    if (hit != null) return hit;
    // 术语表其次：命中即返回官方译名（全称/简称按 [width] 决定），
    // 不发请求，也不会被模型结果覆盖。
    final glossary = _glossaryTranslate(src, currentLanguage.code, width);
    if (glossary != null) return glossary;
    // 尚未翻译：先显示原文，排进待翻队列。
    if (_pending.add(src)) _scheduleFlush();
    return src;
  }

  /// 与 [_tx] 相同，但把这条排进**高优先级队列**（[txUrgent] 的实例实现）。
  ///
  /// 唯一用途：App 启动时立刻弹出的「发现新版本」弹窗。主界面会在同一帧里把
  /// 几十条文案塞进普通队列，如果弹窗正文也走普通队列，用户就得对着未翻译的
  /// 更新说明干等。走这里可以整批插队，先把弹窗翻完。
  ///
  /// 命中缓存/术语表时与 [_tx] 完全一致（不发请求）。
  String _txUrgent(String src) {
    if (!enabled || src.isEmpty) return src;
    if (src == currentLanguage.code) return src;
    if (isSourceLanguage) return src;
    if (looksLikeNativeScript(src, currentLanguage.nativeScript)) return src;
    final pinned = _pinnedTranslations[src]?[currentLanguage.code];
    if (pinned != null) return pinned;
    final hit = _cache[src];
    if (hit != null) return hit;
    final glossary = _glossaryTranslate(src, currentLanguage.code, UiTextWidth.wide);
    if (glossary != null) return glossary;
    // 未翻译：先显示原文，但排进优先队列；同时把它从普通队列里摘掉，
    // 避免同一串文字被两个队列各翻一次。
    _pending.remove(src);
    if (_pendingUrgent.add(src)) _scheduleFlush();
    return src;
  }

  /// 人工固定的译名。结构：原文 → { 目标语言代码 → 固定译文 }。
  ///
  /// 有些界面词条的译法是有明确口径的，交给模型自由发挥会出现语气/长度都不对的
  /// 结果（例：「关注的人」在日语里官方口径就是「フォロー中」，模型可能给出
  /// 「フォローしている人」这类又长又不地道的说法）。钉住之后：
  /// 命中即直接返回，不走缓存、不发请求，也不会被模型结果覆盖。
  ///
  /// 游戏专有名词（原神/星铁/绝区零等七款）不在这里钉——它们走 [kGlossaryNames]
  /// 术语表 + 全称/简称规则（见 [_glossaryTranslate]），机制不与任何一条原文锁死。
  static const Map<String, Map<String, String>> _pinnedTranslations = {
    '关注的人': {'ja': 'フォロー中', 'ko': '팔로잉', 'en': 'Following'},
    // ---- 平行词条组：缓存 / 下载 ----
    //
    // 用户明确要求：「缓存视频 / 缓存音频」这类**成组词条必须构词一致**。
    // 中文是「动词 + 名词」的并列结构，译文也必须是同一构词模式：
    //   要么全部「名词 + 缓存」（キャッシュ動画 / キャッシュ音響）
    //   要么全部「名词 + を + サ変動詞」（動画をキャッシュ / 音響をキャッシュ）
    // 之前模型给出「動画をキャッシュ」（动宾）+「キャッシュ音響」（名词复合），
    // 两种构词混用，读起来不是一套。这里统一成**名词复合**（短、适合标签位）。
    //
    // 同理「下载视频/下载音频」「缓存失败/下载失败」也一并钉住，
    // 否则模型会各自发挥出不一致的形态。
    //
    // **每种目标语言都要钉**：只钉日语的话，切到韩语/英语时又会各译一套，
    // 成组词条照样对不齐。这里按语言逐个给出同一构词模式：
    //   日：名词+キャッシュ / 名词+ダウンロード（名词复合）
    //   韩：캐시+名词 / 다운로드+名词（同为名词复合）
    //   英：Cached + 名词 / Download + 名词
    '缓存视频': {
      'ja': 'キャッシュ動画',
      'ko': '캐시 동영상',
      'en': 'Cached Videos',
    },
    '缓存音频': {
      'ja': 'キャッシュ音響',
      'ko': '캐시 음성',
      'en': 'Cached Audio',
    },
    '下载视频': {
      'ja': 'ダウンロード動画',
      'ko': '동영상 다운로드',
      'en': 'Downloaded Videos',
    },
    '下载音频': {
      'ja': 'ダウンロード音声',
      'ko': '음성 다운로드',
      'en': 'Downloaded Audio',
    },
    '缓存': {'ja': 'キャッシュ', 'ko': '캐시', 'en': 'Cache'},
    '下载': {'ja': 'ダウンロード', 'ko': '다운로드', 'en': 'Download'},
    '正在缓存': {'ja': 'キャッシュ中', 'ko': '캐시 중', 'en': 'Caching'},
    '正在下载': {'ja': 'ダウンロード中', 'ko': '다운로드 중', 'en': 'Downloading'},
    '缓存失败': {'ja': 'キャッシュ失敗', 'ko': '캐시 실패', 'en': 'Caching Failed'},
    '下载失败': {'ja': 'ダウンロード失敗', 'ko': '다운로드 실패', 'en': 'Download Failed'},
    '缓存完成': {'ja': 'キャッシュ完了', 'ko': '캐시 완료', 'en': 'Caching Complete'},
    '下载完成': {'ja': 'ダウンロード完了', 'ko': '다운로드 완료', 'en': 'Download Complete'},
    '重新缓存': {'ja': '再キャッシュ', 'ko': '다시 캐시', 'en': 'Re-cache'},
    '重新下载': {'ja': '再ダウンロード', 'ko': '다시 다운로드', 'en': 'Re-download'},
    '还没有缓存音频': {
      'ja': 'キャッシュした音響はまだありません',
      'ko': '캐시한 음성이 없습니다',
      'en': 'No cached audio yet',
    },
    '还没有下载过音频': {
      'ja': 'ダウンロードした音声はまだありません',
      'ko': '다운로드한 음성이 없습니다',
      'en': 'No downloaded audio yet',
    },
    '还没有下载过视频': {
      'ja': 'ダウンロードした動画はまだありません',
      'ko': '다운로드한 동영상이 없습니다',
      'en': 'No downloaded videos yet',
    },
    '全部视频': {'ja': 'すべての動画', 'ko': '모든 동영상', 'en': 'All Videos'},
    '文件夹': {'ja': 'フォルダ', 'ko': '폴더', 'en': 'Folder'},
    '分离流': {'ja': '分離ストリーム', 'ko': '분리 스트림', 'en': 'Split Stream'},
    '本地文件已删除': {
      'ja': 'ローカルファイルが削除されました',
      'ko': '로컬 파일이 삭제되었습니다',
      'en': 'Local file deleted',
    },
  };

  /// 术语表运行时索引：任一语言的全称/简称 → 术语 id。懒构建一次。
  static Map<String, String>? _glossaryFormIndex;

  /// 词表是否启用（[recordId] 形如 `zzz|Phoenix`，取竖线前的 id）。
  ///
  /// 默认全部启用：`Pref.glossaryDisabledTables` 里只记录用户**关掉**的，
  /// 这样以后新增词表天然是启用的，无需迁移。
  static bool _glossaryTableEnabled(String recordId) {
    final bar = recordId.indexOf('|');
    if (bar <= 0) return false;
    final table = recordId.substring(0, bar);
    if (!_glossaryDefaultsApplied) {
      // 首次运行：把所有词表一次性标记为「关闭」。
      //
      // 用户要求默认全部关闭，由用户自己按需打开。用一次性标记而不是每次
      // 判空，是为了不覆盖用户之后自己做的选择。
      final all = <String>{};
      for (final key in kGlossaryNames.keys) {
        final b = key.indexOf('|');
        if (b > 0) all.add(key.substring(0, b));
      }
      all.addAll(kGlossaryManifest.keys);
      Pref.glossaryDisabledTables = all;
      Pref.glossaryDefaultsApplied = true;
      _glossaryDefaultsApplied = true;
      return false;
    }
    return !Pref.glossaryDisabledTables.contains(table);
  }

  /// 进程内缓存「默认关闭」标记，避免每条术语都读一次存储。
  static bool get _glossaryDefaultsApplied =>
      _defaultsAppliedCache ??= Pref.glossaryDefaultsApplied;
  static set _glossaryDefaultsApplied(bool v) => _defaultsAppliedCache = v;
  static bool? _defaultsAppliedCache;

  /// 术语表索引是否已预热。
  static bool get glossaryReady => _glossaryFormIndex != null;

  /// 预热术语表索引：把 5 万多条形态的构建从首帧挪到启动后台。
  ///
  /// **不要在这里解析 `to`。** `to` 会向 GetX 索取服务实例，而本方法是从
  /// `onInit` 里调用的 —— 那一刻服务还在注册过程中，解析自身实例会抛错；
  /// 异常顺着 `main()` 里同步的 `..put()` 冒出去，`runApp` 之前启动就断了，
  /// 表现就是**一直纯黑屏、也不闪退**（3.6.4 的问题）。
  ///
  /// 因此这里只读 Pref（普通存储读取，安全），并把整个流程包在 try 里：
  /// 预热只是性能优化，任何异常都不允许影响启动。
  static void warmGlossary() {
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      try {
        if (!Pref.uiTranslateEnabled) return;
        _warmNow();
      } catch (_) {
        // 预热失败不影响任何功能，直接放弃
      }
    });
  }

  /// 立即构建索引（构建结果是静态缓存的）。
  static void _warmNow() {
    _glossaryIndex.length;
    _glossaryFormsByFirstChar.length;
  }

  /// 用户改了某一类术语集的开关后调用：作废已构建的索引，下次查询按新状态重建。
  static void rebuildGlossaryIndex() {
    _glossaryFormIndex = null;
    _glossaryFormsSorted = null;
    _formsByFirstCharCache = null;
    if (Get.isRegistered<UiTranslateService>()) {
      to.revision.value++;
    }
  }

  static Map<String, String> get _glossaryIndex {
    final built = _glossaryFormIndex;
    if (built != null) return built;
    final index = <String, String>{};
    void put(Map<String, Map<String, String>> table) {
      table.forEach((id, names) {
        // 按用户的开关过滤：关闭的词表不参与匹配。
        if (!_glossaryTableEnabled(id)) return;
        for (final form in names.values) {
          final key = form.toLowerCase();
          // 全称优先登记；同一形态冲突时先到先得（确定性）。
          index.putIfAbsent(key, () => id);
        }
      });
    }

    put(kGlossaryNames);
    // 别名表：短名 / 其他写法 → 同一 id。
    //
    // 这是「标题里只写短名就翻不出来」的修复点。术语表里每条记录只存**一个**
    // 标准名（如 `菲欧妮・蕾法爱菈`），但标题、评论里通常只写短名（`菲欧妮`）。
    // 没有别名表时索引查不到「菲欧妮」，于是走模型音译，译名自然不对。
    //
    // 别名表把「菲欧妮」「フィオニー」「Phoenix」都指向同一条 id；
    // 取译文时仍按 id 拿该语言的标准名，所以短名也能得到正确译名。
    // 顺序上标准名先登记（put 在别名之前），同名冲突时标准名优先。
    kGlossaryAliasToId.forEach((form, id) {
      if (!_glossaryTableEnabled(id)) return;
      index.putIfAbsent(form.toLowerCase(), () => id);
    });
    // 简称也建立索引：源文本里出现 ゼンゼロ/ZZZ 时同样能命中该术语。
    put(kGlossaryShorts);
    _glossaryFormIndex = index;
    return index;
  }

  /// 术语表查找：[src] 与任一语言的全称/简称完全一致时返回目标语言译名。
  ///
  /// 全称/简称选择规则（简称机制的判断条件）：
  /// 1. 目标语言存在**通行简称**（官方或社区口径）且确实比全称短；
  /// 2. 且满足其一 ——
  ///    - 词条是 `shortOnly`（有社区通行简称的词条，如 ゼンレスゾーンゼロ→ゼンゼロ、
  ///      崩壊:スターレイル→スタレ）：除正文级宽度外一律用简称；
  ///    - 调用处声明了窄宽度（[UiTextWidth.tight]，列表标题/按钮）；
  ///    - 普通宽度下全称渲染宽度超过 12 个半角单位（约 6 个汉字）。
  /// 没有简称或条件不满足 → 用全称。术语不与任何一条原文锁死：
  /// 无论源文本以哪种语言写出该术语（含简称形式），都套用同一套规则。
  ///
  /// 社区口径说明（用户确认）：B 站游戏视频的评论区本身就是社区的一部分，
  /// 社区俚语简称在翻译中名正言顺、应当推荐——所以带通行简称的词条默认简称。
  String? _glossaryTranslate(String src, String langCode, UiTextWidth width) {
    final key = src.trim().toLowerCase();
    if (key.isEmpty) return null;

    // 索引未预热就放弃：宁可这一帧交给模型，也不要在首帧同步构建
    // 五万条索引导致界面卡死甚至闪退（见 [warmGlossary]）。
    if (_glossaryFormIndex == null) return null;

    // 1) 整串精确命中（最常见：标题/菜单项本身就是一个术语）
    final exact = _glossaryIndex[key];
    if (exact != null) return _glossaryPreferred(exact, langCode, width);

    // 2) 术语嵌在句子里：如「【绝区零】菲欧妮实战演示」。
    //
    // 之前只做精确匹配，所以这类标题永远命中不了，直接丢给模型音译——
    // 这就是「词表里明明有菲欧妮，App 里还是翻错」的另一半原因。
    //
    // 做法：按**首字符分桶**扫描句子，把命中的术语替换成目标语言的标准名。
    // 桶内按长度降序，「菲欧妮・蕾法爱菈」会先于「菲欧妮」被匹配到，
    // 不会把全名拆成两个短名分别替换。
    // **性能门控**：子串扫描只用于标题/标签这类短文本
    // （例「【绝区零】菲欧妮实战演示」）。长段落交给模型整句翻译更自然。
    if (src.length > _substringScanMaxChars) return null;

    final buckets = _glossaryFormsByFirstChar;
    if (buckets.isEmpty) return null;

    // **单趟游标扫描**（3.6.4 崩溃修复）
    //
    // 旧实现是「替换 → 从头重扫 → 只要还有命中就再来一轮」的 while 循环。
    // 但绝大多数术语是**自我包含**的：实测 53953 个形态中有 45601 个，
    // 其译文的小写形式仍含原文（例如键 `genshin impact` 的译名就是
    // `Genshin Impact`；日文名常与日文键完全相同）。于是替换后同一个形态
    // 又被找到，progress 永远为 true，循环永不退出；每轮都新建 StringBuffer
    // 且字符串不断变长，内存很快耗尽、进程被杀 ——
    // 表现就是「点进去什么都加载不出来，然后闪退」。
    //
    // 现在改为从头到尾只走一遍游标：命中就写入译文并把游标跳过匹配段，
    // 已写入的内容不再参与匹配。终止性由构造保证，不依赖数据性质。
    final lower = src.toLowerCase();
    final buf = StringBuffer();
    var cursor = 0;
    var hit = false;
    var steps = 0;
    while (cursor < src.length) {
      if (++steps > _substringScanMaxSteps) {
        buf.write(src.substring(cursor));
        break;
      }
      final forms = buckets[lower[cursor]];
      String? matched;
      String? repl;
      if (forms != null) {
        for (final form in forms) {
          if (!lower.startsWith(form, cursor)) continue;
          final id = _glossaryIndex[form];
          if (id == null) continue;
          final r = _glossaryPreferred(id, langCode, width);
          if (r == null || r.isEmpty) continue;
          matched = form;
          repl = r;
          break;
        }
      }
      if (matched != null && repl != null) {
        buf.write(repl);
        cursor += matched.length;
        hit = true;
      } else {
        buf.write(src[cursor]);
        cursor++;
      }
    }
    return hit ? buf.toString() : null;
  }

  /// 长度降序的术语形态表（供 [_glossaryTranslate] 的子串扫描用），懒构建一次。
  static List<String> get _glossarySortedForms {
    final cached = _glossaryFormsSorted;
    if (cached != null) return cached;
    final forms = _glossaryIndex.keys.toList(growable: false)
      ..sort((a, b) => b.length.compareTo(a.length));
    _glossaryFormsSorted = forms;
    return forms;
  }

  static List<String>? _glossaryFormsSorted;
  /// 术语形态按**首字符**分桶，供子串扫描用。
  ///
  /// 直接遍历全部形态在运行期是 O(2 万) 次 indexOf，每个文本控件每帧一次，
  /// 打开 AI 翻译后界面会明显卡（实测形态数 23282）。按首字符分桶后，
  /// 只比较「文本里确实出现过的首字符」对应的桶，通常是几十条。
  ///
  /// 桶内仍按长度降序，保证「菲欧妮・蕾法爱菈」先于「菲欧妮」被替换。
  /// **单字符与双字符形态不参与子串匹配**：单字术语几乎会命中任何中文句子，
  /// 替换出来只会是错的。
  static Map<String, List<String>> get _glossaryFormsByFirstChar {
    final cached = _formsByFirstCharCache;
    if (cached != null) return cached;
    final map = <String, List<String>>{};
    for (final form in _glossarySortedForms) {
      if (form.length < _minSubstringFormLength) continue;
      final fc = form[0];
      (map[fc] ??= <String>[]).add(form);
    }
    _formsByFirstCharCache = map;
    return map;
  }

  static Map<String, List<String>>? _formsByFirstCharCache;

  /// 参与子串匹配的最短形态长度。单/双字符太容易误命中，排除。
  static const int _minSubstringFormLength = 3;
  /// 做子串术语替换的最大文本长度：超过就跳过（长文本交给模型整句翻译）。
  static const int _substringScanMaxChars = 80;

  /// 单趟扫描的最大步数（安全阀，正常短文本远达不到）。
  static const int _substringScanMaxSteps = 4096;

  /// 按宽度层级选出该术语的目标语言形态（全称或通行简称）。
  static String? _glossaryPreferred(String id, String langCode, UiTextWidth width) {
    final full = kGlossaryNames[id]?[langCode];
    if (full == null || full.isEmpty) return null;
    final short = kGlossaryShorts[id]?[langCode];
    if (short == null || short.isEmpty || short == full) return full;
    final shortOnly = kGlossaryShortOnly.contains(id);
    final preferShort = switch (width) {
      UiTextWidth.tight => true,
      UiTextWidth.normal => shortOnly || _textWidth(full) > 12,
      UiTextWidth.wide => false,
    };
    return preferShort && _textWidth(short) < _textWidth(full) ? short : full;
  }

  /// 渲染宽度估算：全角字符（CJK/全角标点）按 2、其余按 1 计。
  static int _textWidth(String s) {
    var w = 0;
    for (final r in s.runes) {
      w += (r >= 0x1100 &&
              (r <= 0x115F || // Hangul Jamo
                  r == 0x2329 ||
                  r == 0x232A ||
                  (r >= 0x2E80 && r <= 0xA4CF && r != 0x303F) || // CJK..Yi
                  (r >= 0xAC00 && r <= 0xD7A3) || // Hangul Syllables
                  (r >= 0xF900 && r <= 0xFAFF) || // CJK Compatibility Ideographs
                  (r >= 0xFE30 && r <= 0xFE4F) || // CJK Compatibility Forms
                  (r >= 0xFF00 && r <= 0xFF60) || // Fullwidth Forms
                  (r >= 0xFFE0 && r <= 0xFFE6) ||
                  (r >= 0x20000 && r <= 0x3FFFD)))
          ? 2
          : 1;
    }
    return w;
  }

  /// 批量翻译前的术语注入：扫一遍待翻列表，把命中的术语作为「强制译法」
  /// 写进 system 提示词，让句子内的专有名词也走统一译名。
  ///
  /// 注入的是**社区通行口径**（与运行时 normal 宽度的选择一致）：带通行简称的
  /// 词条注入简称（评论区即社区语境，社区俚语简称名正言顺），其余注入全称。
  /// 每个术语给出「源形态 → 目标译名」，源形态是命中的那条原文里实际出现的写法
  /// （可能是任一语言的名称或简称）。
  static String _glossaryPromptHints(List<String> sources, String langCode) {
    if (sources.isEmpty) return '';
    final index = _glossaryIndex;
    if (index.isEmpty) return '';
    final hits = <String, String>{};
    for (final src in sources) {
      if (src.length > 200) continue; // 长文本（简介/评论）不做逐形态扫描
      final lower = src.toLowerCase();
      for (final entry in index.entries) {
        if (hits.length >= 20) break;
        final form = entry.key;
        if (form.length < 2) continue;
        var matched = false;
        if (_isAsciiForm(form)) {
          // 纯 ASCII 的短形态（HSR/ZZZ/BA…）必须整词出现，
          // 否则 "ba" 会命中任何含 "ba" 的英文单词（banner/bar…）。
          matched = form.length <= 4
              ? _hasAsciiWord(src, form)
              : lower.contains(form);
        } else {
          matched = lower.contains(form);
        }
        if (matched) {
          final chosen = _glossaryPreferred(entry.value, langCode, UiTextWidth.normal);
          if (chosen != null) {
            hits.putIfAbsent(form, () => chosen);
          }
        }
      }
    }
    if (hits.isEmpty) return '';
    final buf = StringBuffer('**术语译法**：下列对照为官方/社区通行译名，'
        '译文中出现的对应专有名词必须使用给出的译法（含其简称形式）：');
    hits.forEach((form, chosen) {
      buf.write('\n   - 「$form」→「$chosen」');
    });
    return buf.toString();
  }

  /// 形态是否纯 ASCII（字母/数字），用于选择匹配策略。
  static bool _isAsciiForm(String form) {
    for (final r in form.codeUnits) {
      if (r > 0x7F) return false;
    }
    return true;
  }

  /// 整词匹配（大小写不敏感；前后不能再是字母/数字）。
  ///
  /// 索引键统一小写，但原文里 HSR/ZZZ 这类简称通常是大写，所以这里对
  /// 大小写不敏感；误报由「整词边界」挡住——banner 里的 ba 后面跟着字母，
  /// 不会命中。
  static bool _hasAsciiWord(String src, String word) {
    final hay = src.toLowerCase();
    final needle = word.toLowerCase();
    var start = 0;
    while (true) {
      final idx = hay.indexOf(needle, start);
      if (idx < 0) return false;
      final beforeOk =
          idx == 0 || !_isWordChar(hay.codeUnitAt(idx - 1));
      final end = idx + needle.length;
      final afterOk =
          end >= hay.length || !_isWordChar(hay.codeUnitAt(end));
      if (beforeOk && afterOk) return true;
      start = idx + 1;
    }
  }

  static bool _isWordChar(int r) =>
      (r >= 0x30 && r <= 0x39) || // 0-9
      (r >= 0x41 && r <= 0x5A) || // A-Z
      (r >= 0x61 && r <= 0x7A); // a-z

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
      _pendingUrgent.clear();
      return;
    }
    // 优先队列不攒批、不防抖：用户正对着更新弹窗等译文，越早发越好。
    if (_pendingUrgent.isNotEmpty) {
      _debounce?.cancel();
      _flush();
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
    if (_busy || (_pending.isEmpty && _pendingUrgent.isEmpty)) return;
    // 关闭时（含已排队未触发的防抖）绝不再发请求，保护用户 API 额度
    if (!enabled) {
      _pending.clear();
      _pendingUrgent.clear();
      return;
    }
    _busy = true;
    // 这一轮请求用的是**发起时**的目标语言：译文只能写进这个语言的桶。
    // 否则用户在请求返回前切换了语言，老语言译文会以新语言的名义落进缓存，
    // 表现为「切到 B 后个别文本还留在 A」。
    final reqLang = currentLanguage.code;
    try {
      // **优先队列**：更新弹窗这类「用户正盯着看」的内容先翻。
      // 只要 _pendingUrgent 非空就只取它，普通队列留到下一轮 —— 这样弹窗
      // 不用和主界面几十条文案抢同一个批次。
      final fromUrgent = _pendingUrgent.isNotEmpty;
      final Set<String> source;
      if (fromUrgent) {
        source = _pendingUrgent;
      } else {
        source = _pending;
      }
      final batch = source.toList(growable: false);
      source.clear();

      final uncached = batch
          .where((s) => !_cache.containsKey(s))
          .toSet()
          .toList(growable: false);
      if (uncached.isEmpty) {
        // 这一批全是缓存命中：立即把机会让给剩下的队列
        _busy = false;
        if (_pending.isNotEmpty || _pendingUrgent.isNotEmpty) _scheduleFlush();
        return;
      }

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
      // 两个队列都要接着跑：优先队列非空时 _flush 会先取它，所以这里
      // 只要有一个非空就再排一次即可。
      if (_pending.isNotEmpty || _pendingUrgent.isNotEmpty) _scheduleFlush();
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
      // 逐条注入术语强制译法：本条原文里命中术语表的游戏专有名词。
      final glossaryRule = _glossaryPromptHints([src], currentLanguage.code);
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
                '${labelRule.isEmpty ? '' : '\n$labelRule'}'
                '${glossaryRule.isEmpty ? '' : '\n\n$glossaryRule'}',
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
    // 术语强制译法：本批原文里命中术语表的游戏专有名词。
    final glossaryRule = _glossaryPromptHints(sources, currentLanguage.code);
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
        '7) **成组词条必须完全同构**（最容易做错，请严格执行）：'
        '当列表里出现「同一个词 + 不同对象」的并列项时'
        '（例：缓存视频/缓存音频、下载视频/下载音频、图片/视频/音频），'
        '所有成员的译文必须能套进**同一个模板**，只在对象词位置替换。'
        '判定方法：把各成员的译文并列写出，遮住对象词后，'
        '剩下的框架必须**逐字相同**。'
        '反例（不合格）：「動画をキャッシュ」（動画＋を＋キャッシュ，动宾）'
        '与「キャッシュ音響」（キャッシュ＋音響，名词复合）——框架不同；'
        '正例（合格）：「キャッシュ動画」与「キャッシュ音響」（同为「キャッシュ＋对象」），'
        '或「動画をキャッシュ」与「音響をキャッシュ」（同为「对象＋を＋キャッシュ」）。'
        '**不要**把其中一个译成动宾、另一个译成名词复合，'
        '也不要只给其中一个加助词。'
        '若原文是「名词+名词」复合结构，译文全部用名词复合；'
        '若原文是「动词+宾语」动宾结构，译文全部用动宾结构。'
        '${labelRule.isEmpty ? '' : '\n8) $labelRule'}'
        // 术语表注入：本批原文里出现的游戏专有名词 → 官方译名（第二条链路）。
        '${glossaryRule.isEmpty ? '' : '\n\n$glossaryRule'}';
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

/// 窄位便捷入口：列表标题 / 卡片标题 / 按钮 / Tab 这类空间紧张的位置用它。
///
/// 命中的游戏术语会倾向用**通行简称**（ゼンゼロ、スタレ、ブルアカ、アクナイ…），
/// 详见 [UiTextWidth.tight]。与 [uiTx] 的区别只在术语选型，其余行为完全一致
/// （同一份缓存、同一套队列），两者混用不会导致重复翻译。
String uiTxTight(String src) =>
    UiTranslateService.tx(src, width: UiTextWidth.tight);

/// **高优先级**入口：译文会插队到普通队列之前。
///
/// 只给「用户一进 App 就盯着看、且必须等译文」的内容用 —— 目前只有更新弹窗。
/// 普通界面文案请继续用 [uiTx] / [uiTxTight]，否则会把启动优化白做。
String uiTxUrgent(String src) => UiTranslateService.txUrgent(src);

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
