import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'dart:async';

import 'package:PiliPlus/models/common/video/audio_quality.dart';
import 'package:PiliPlus/models/common/video/cdn_type.dart';
import 'package:PiliPlus/models/common/video/video_decode_type.dart';
import 'package:PiliPlus/models/video/play/url.dart'
    show AudioItem, VideoItem, FormatItem;
import 'package:PiliPlus/models_new/live/live_room_play_info/codec.dart';
import 'package:PiliPlus/utils/cdn_node_store.dart';
import 'package:PiliPlus/utils/cdn_speed_test.dart';
import 'package:PiliPlus/utils/cdn_region.dart';
import 'package:PiliPlus/utils/extension/iterable_ext.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:PiliPlus/utils/host_health.dart';

abstract final class VideoUtils {
  static CDNService cdnService = Pref.defaultCDNService;
  static String? customCDNUrl = Pref.customCDNUrl;
  static String? liveCdnUrl = Pref.liveCdnUrl;
  static bool disableAudioCDN = Pref.disableAudioCDN;

  static const _proxyTf = 'proxy-tf-all-ws.bilivideo.com';

  static final _mirrorRegex = RegExp(
    r'^https?://(?:upos-\w+-(?!302)\w+|(?:upos|proxy)-tf-[^/]+)\.(?:bilivideo|akamaized)\.(?:com|net)/upgcxcode',
  );

  static final _mCdnTfRegex = RegExp(
    r'^https?://(?:(?:(?:\d{1,3}\.){3}\d{1,3}|[^/]+\.mcdn\.bilivideo\.(?:com|cn|net))(?:\:\d{1,5})?/v\d/resource)',
  );

  static const _mediaHostSuffixes = [
    '.bilivideo.com',
    '.bilivideo.cn',
    '.acgvideo.com',
    '.akamaized.net',
  ];

  // host 首段为 API/上报类前缀的域名不参与自定义节点替换
  static final _blockedHostPrefix = RegExp(r'^(?:bvc|data|pbp|api)\w*\.');

  /// B 站海外/Akamai 直链主机：akamaized.net、*mirror(cos|ali|hw)ov*（海外）、
  /// cn-hk-eq-bcache*（HK）。这些地址由 B 站自己下发、签名有效，海外可直接用。
  static final _overseasHostRegex = RegExp(
    r'(?:^|\.)(?:akamaized\.net|bilivideo\.tv)$'
    r'|mirror(?:cos|ali|hw)ov\.'
    r'|^cn-hk-eq-bcache',
    caseSensitive: false,
  );

  /// B 站海外 upos 镜像（mirror*ov）。
  static final _mirrorOvRegex = RegExp(
    r'mirror(?:cos|ali|hw)ov\.',
    caseSensitive: false,
  );

  /// 海外候选的静态优先级（越小越优先）：Akamai 全球边缘（anycast，海外各洲
  /// 一般都近）> mirror*ov（B 站海外 upos 镜像）> 其它（cn-hk-eq-bcache 香港
  /// 边缘、bilivideo.tv——对欧美方向常被限速）。服务器按它自己的调度下发候选
  /// 顺序，对第三方客户端未必友好。
  static int _overseasTier(String url) {
    final host = hostOf(url) ?? '';
    if (host.endsWith('akamaized.net')) {
      return 0;
    }
    if (_mirrorOvRegex.hasMatch(host)) {
      return 1;
    }
    return 2;
  }

  /// 从候选直链中挑一条"海外可用"的现成地址（不改写主机，避免签名失效）。
  ///
  /// 开了 [Pref.cdnSpeedTest]（默认开）时优先用实测最快的：B 站下发的海外候选
  /// 里可能好几条都"看起来可用"，但实际速率差很多，静态取第一条没有兜底 ——
  /// 挑中一条被限速的，就是「画面卡住、声音照走」。测速本身是异步的，而
  /// [getCdnUrl] 是同步方法，所以这里「有结果就用实测最优，同时把这一轮测出来
  /// 给下次用」；第一次播放仍按原顺序，同一条视频的后续取流、换线、切清晰度就
  /// 能吃到实测结果。
  static String? _firstOverseasUrl(
    Iterable<String> urls, {
    Set<String>? excludeHosts,
  }) {
    final candidates = <String>[];
    for (final url in urls) {
      final host = hostOf(url);
      if (host == null) {
        continue;
      }
      if (excludeHosts != null && excludeHosts.contains(host)) {
        continue;
      }
      if (_overseasHostRegex.hasMatch(host)) {
        candidates.add(url);
      }
    }
    if (candidates.isEmpty) {
      return null;
    }
    if (Pref.cdnSpeedTest) {
      final best = CdnSpeedTest.bestOf(candidates);
      unawaited(CdnSpeedTest.test(candidates));
      if (best != null) {
        return best;
      }
    }
    // 无实测结果（冷启动首次播放等）：按静态优先级挑，Akamai 最优先
    candidates.sort((a, b) => _overseasTier(a).compareTo(_overseasTier(b)));
    return candidates.first;
  }

  /// A4.3 首帧优先：冷启动（还没有任何实测分）时，给候选一个有限预算的探测窗口，
  /// 谁先回来就用谁，再交给播放器；已有实测分、或超出预算就直接返回，不拖起播。
  ///
  /// 调用点放在取流回来之后、选流之前，等待正好与播放器初始化重叠，等于不额外
  /// 增加起播延迟；超预算时用已经探到的那部分分（CdnSpeedTest 每探完一台就落分）。
  static Future<void> awaitColdProbe(
    Iterable<String> urls, {
    Duration budget = const Duration(milliseconds: 1500),
  }) async {
    if (!Pref.cdnSpeedTest || CdnSpeedTest.hasResult) return;
    final candidates = urls.where((e) => e.isNotEmpty).toList(growable: false);
    if (candidates.isEmpty) return;
    try {
      await CdnSpeedTest.test(candidates).timeout(budget);
    } catch (_) {
      // 超预算：带着已有结果往下走
    }
  }

  /// 下载专用：把 B 站**大陆** upos 镜像直链改写成 Akamai 全球边缘，作为额外候选线路。
  /// 大陆镜像对境外访问常被限速到 100KB/s 上下，而这条主机改写对下载是安全的
  /// （上游「自定义 CDN 节点」也是同理会改写主机）；**播放侧绝不可这样改写**
  /// ——部分直链签名与主机绑定，改写会 403 卡“加载中”（v0.1.8 教训）。
  /// 返回 null 表示这条不适合改写（不是 upos 镜像、或本来就是海外节点）。
  static String? akamaiVariant(String url) {
    if (!_mirrorRegex.hasMatch(url)) {
      return null;
    }
    final uri = Uri.tryParse(url);
    final host = uri?.host;
    if (host == null || host.isEmpty) {
      return null;
    }
    if (_overseasHostRegex.hasMatch(host) || host == CDNService.akamai.host) {
      return null;
    }
    final akamai = CDNService.akamai.host;
    if (akamai == null) {
      return null;
    }
    return uri!.replace(host: akamai).toString();
  }

  static bool _isReplaceableMediaHost(String host) {
    final lower = host.toLowerCase();
    if (_blockedHostPrefix.hasMatch(lower)) {
      return false;
    }
    return lower == 'edge.mountaintoys.cn' ||
        _mediaHostSuffixes.any(lower.endsWith);
  }

  /// 完整 URL 提取 host；纯 host 不得含路径/查询/锚点；空白视为 null
  static String? normalizeCustomCDNHost(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return null;
    }
    if (uri.hasScheme) {
      return uri.host.isEmpty ? null : uri.host;
    }
    if (trimmed.contains('/') ||
        trimmed.contains('?') ||
        trimmed.contains('#') ||
        trimmed.contains(' ')) {
      return null;
    }
    return trimmed;
  }

  /// 当前生效 CDN 的展示文本：自定义节点优先反查节点表标注地区运营商
  static String effectiveCdnDesc() {
    final host = customCDNUrl;
    if (host == null) {
      return cdnService.desc;
    }
    return CdnNodeStore.labelOf(host) ?? uiTxP('自定义：{0}', [host]);
  }

  /// 下载时是否把大陆 upos 镜像改写成 Akamai 全球边缘。
  ///
  /// 只有海外用户需要：大陆镜像对境外访问常被限速到 100KB/s 上下。大陆用户
  /// 反过来 —— 大陆镜像本来就是最快的，绕到 Akamai 全球边缘更慢。所以这里跟随
  /// [CdnRegionResolver] 的识别结果，而不是无条件改写。
  ///
  /// （下载侧改写主机是安全的：直链签名与主机绑定这条约束只影响**播放**，
  /// 上游「自定义 CDN 节点」同样走改写。）
  static bool get downloadPreferAkamai =>
      CdnRegionResolver.effective.preferOverseas;

  /// 本次播放内被判定为「坏节点」的主机（响应被服务端截断，见 [markBadHost]）。
  ///
  /// 故障是**主机级**的：某条 CDN 地址会把视频分片截断（ffmpeg 报
  /// `Stream ends prematurely`，或重试只回几百字节），而**同一个主机常出现在
  /// 候选列表的多个下标上** —— 只按下标拉黑，换线仍会落回同一台机器。
  static final Set<String> badHosts = <String>{};

  static String? hostOf(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }
    final host = Uri.tryParse(url)?.host;
    return (host == null || host.isEmpty) ? null : host;
  }

  static void markBadHost(String? url) {
    final host = hostOf(url);
    if (host != null) {
      badHosts.add(host);
    }
  }

  static void clearBadHosts() => badHosts.clear();

  static String _firstUsable(Iterable<String> urls, {Set<String>? excludeHosts}) {
    final list = urls.toList();
    if (list.isEmpty) {
      return '';
    }
    final usable = (excludeHosts == null || excludeHosts.isEmpty)
        ? list
        : list
              .where((url) {
                final host = hostOf(url);
                return host == null || !excludeHosts.contains(host);
              })
              .toList();
    if (usable.isEmpty) {
      return list.first;
    }
    // 有实测结果时优先实测最优。测速只在海外分支触发过，所以大陆用户的
    // _score 为空、bestOf 返回 null，行为与改动前完全一致。
    // C2.2：主机健康度（含 A4.2 从测速共享进来的实测速率）也纳入选流。
    // 音频与视频走的是同一个 _firstUsable，所以两边共用同一套候选结论：
    // 正在冷却的主机（412 / 连续失败）先排除，除非全都在冷却。
    final healthy = usable.where((url) {
      final host = hostOf(url);
      return host == null || !HostHealth.instance.isCoolingDown(host);
    }).toList();
    final pool = healthy.isEmpty ? usable : healthy;
    if (Pref.cdnSpeedTest) {
      final best = CdnSpeedTest.bestOf(pool);
      if (best != null) {
        return best;
      }
    }
    return pool.first;
  }

  /// [customHost] 显式指定自定义节点（节点测速用）；未传时按 [applyCustomCDN]
  /// 决定是否采用全局自定义节点。全局自定义生效时完全旁路枚举语义。
  /// [nativeOrder] 为真时**不改写主机**，只在 B 站已下发的候选里挑：
  /// 海外地区（见 [CdnRegionResolver]）优先挑一条海外/Akamai 地址，否则取第一条。
  ///
  /// 用于**官方 APP 同源直链**（gRPC `PlayView`）：这类令牌的媒体指纹是「不带
  /// Referer」。令牌与主机绑定，所以**绝不能改写主机**（乱换会 403，v0.1.8 教训）；
  /// 但候选列表里每一条都是 B 站针对各自主机单独签发的，换用其中一条不影响签名
  /// 有效性 —— 海外用户必须挑，否则会拿到对境外限速的大陆镜像。
  static String getCdnUrl(
    Iterable<String> urls, {
    Set<String>? excludeHosts,
    CDNService? defaultCDNService,
    String? customHost,
    bool applyCustomCDN = true,
    bool isAudio = false,
    bool preferAkamai = false,
    bool nativeOrder = false,
  }) {
    if (nativeOrder && urls.isNotEmpty) {
      // 官方 APP 同源直链：**绝不改写主机**（直链签名与主机、请求指纹绑定，
      // 改写必 403，v0.1.8 教训）。
      //
      // 但"挑一条 B 站已经签好的候选"是另一回事 —— 列表里每条地址都是 B 站
      // 针对这台主机单独签发的，换用其中一条不会让签名失效。海外用户必须这么做：
      // B 站 APP 接口下发的第一条常是**大陆镜像**，对境外访问被限速（实测约
      // 100KB/s），于是视频流被饿死、而码率小得多的音频流还活着 —— 表现就是
      // 「画面卡住/丢帧、声音和进度条照走」。这正是只按第一条取流时看海外视频
      // 会周期性卡顿的成因。
      //
      // 大陆用户保持原样（第一条就是 B 站按 IP 就近的结果），行为不变。
      if (CdnRegionResolver.effective.preferOverseas) {
        final overseas = _firstOverseasUrl(urls, excludeHosts: excludeHosts);
        if (overseas != null) {
          return overseas;
        }
      }
      return _firstUsable(urls, excludeHosts: excludeHosts);
    }
    defaultCDNService ??= cdnService;
    customHost ??= applyCustomCDN ? customCDNUrl : null;
    if (isAudio && disableAudioCDN) {
      customHost = null;
    }

    if (customHost == null &&
        !(isAudio && disableAudioCDN) &&
        CdnRegionResolver.effective.preferOverseas) {
      // 海外可用性优先：B 站的候选列表里通常自带 Akamai/海外镜像直链
      // （其签名有效，可直接使用）。此前"视频链接打开失败→重试"多因主线路
      // 是国内 upos 镜像；注意不可把国内直链"改写"成 Akamai 主机（签名不
      // 匹配会 403，v0.1.8 即栽在此），这里只做"挑选现成的海外地址"。
      //
      // **只在用户确实位于海外时才这样挑**：大陆镜像对大陆用户最快，
      // 强挑海外地址反而会落到更远的边缘节点 —— 那正是「每隔几秒卡一下」
      // 的成因之一。地区由 `CdnRegionResolver` 自动识别（可手动指定）。
      final overseas = _firstOverseasUrl(urls, excludeHosts: excludeHosts);
      if (overseas != null) {
        return overseas;
      }
    }

    if (customHost == null && defaultCDNService == CDNService.baseUrl) {
      return _firstUsable(urls, excludeHosts: excludeHosts);
    }

    String? mcdnTf;
    String? mcdnUpgcxcode;

    String last = '';
    for (final url in urls) {
      last = url;
      if (_mirrorRegex.hasMatch(url)) {
        final uri = Uri.parse(url);
        if (uri.queryParameters['os'] == 'mcdn') {
          // upos-sz-mirrorcoso1.bilivideo.com os=mcdn
          mcdnUpgcxcode = url;
        } else {
          if (customHost != null) {
            return uri.replace(host: customHost).toString();
          }
          if (defaultCDNService == CDNService.backupUrl ||
              (isAudio && disableAudioCDN)) {
            // 下载（preferAkamai）：国内镜像海外慢/易限速，改写 Akamai 全球边缘；
            // 播放默认沿用 B 站按 IP 就近返回的镜像（部分直链签名与 Akamai
            // 主机不匹配会 403 → 卡"加载中"，故播放不强改，见下方回退说明）。
            if (preferAkamai) {
              return uri.replace(host: CDNService.akamai.host!).toString();
            }
            return url;
          }
          return uri.replace(host: defaultCDNService.host).toString();
        }
      }

      if (_mCdnTfRegex.hasMatch(url)) {
        mcdnTf = url;
        continue;
      }

      // upos-\w*-302.* & bcache & mcdn host but upgcxcode path
      if (url.contains('/upgcxcode/')) {
        mcdnUpgcxcode = url;
        continue;
      }

      // may be deprecated
      if (url.contains('szbdyd.com')) {
        final uri = Uri.parse(url);
        final hostname =
            uri.queryParameters['xy_usource'] ??
            customHost ??
            defaultCDNService.host;
        return uri
            .replace(scheme: 'https', host: hostname, port: 443)
            .toString();
      }

      if (kDebugMode) {
        debugPrint('unknown cdn type: $url');
      }
    }

    if (mcdnUpgcxcode != null) {
      final uri = Uri.parse(mcdnUpgcxcode);
      if (customHost != null && _isReplaceableMediaHost(uri.host)) {
        return uri.replace(host: customHost).toString();
      }
      final host = defaultCDNService.host;
      if (host == null) {
        // 未显式指定线路（base/backupUrl）：列表里若只剩 mcdn/PCDN(P2P) 源，
        // 说明 B 站按国内视角给了 P2P 线路。海外用 P2P 会因节点在国内而卡帧，
        // 这里对齐 B 站海外的通行做法——改写到 Akamai 全局边缘、绕开国内 PCDN，
        // 让全球用户拿到可播地址（此前会回退硬编码成国内 ali）。
        // 回退说明：部分直链签名与 Akamai 主机不匹配会 403 → 播放卡"加载中"，
        // 故恢复沿用 B 站就近地址。
        //
        // 1.4.0 已实现"播放失败自动回退备用线路"（`_switchToNextLine` 换线前会先
        // 用相同指纹探测目标地址，只切到真的能拿到 200/206 的那条），所以这里**也
        // 不再需要**改写成 Akamai 来试运气 —— 交给回退机制挑一条能用的即可。
        // 海外 PCDN 的「主动绕开」保持不变：P2P 节点在国内，对海外只会更慢。
        if (preferAkamai) {
          // 下载走 Akamai 海外（国内 P2P 节点对海外无效且慢）
          return uri.replace(host: CDNService.akamai.host!).toString();
        }
        return mcdnUpgcxcode;
      }
      return uri.replace(host: host).toString();
    }
    return mcdnTf == null
        ? last
        : Uri(
            scheme: 'https',
            host: _proxyTf,
            queryParameters: {'url': mcdnTf},
          ).toString();
  }

  static String getLiveCdnUrl(CodecItem e, {int index = 0}) {
    final urlInfo = e.urlInfo.getOrFirst(index);
    return (liveCdnUrl ?? urlInfo.host) + e.baseUrl + urlInfo.extra;
  }

  static VideoDecodeFormatType selectCodec(
    Iterable<String> codecs,
    List<VideoDecodeFormatType> preferCodecs,
  ) {
    if (preferCodecs.isNotEmpty) {
      int bestIndex = preferCodecs.length;
      for (final e in codecs) {
        for (int i = 0; i < bestIndex; i++) {
          if (preferCodecs[i].codes.any(e.startsWith)) {
            bestIndex = i;
            if (bestIndex == 0) {
              return preferCodecs[0];
            }
            break;
          }
        }
      }
      if (bestIndex < preferCodecs.length) {
        return preferCodecs[bestIndex];
      }
    }
    return VideoDecodeFormatType.fromString(codecs.first);
  }

  static int _findAvailableVideoQuality(
    List<VideoItem> videoList,
    List<int>? acceptQuality,
    int preferQuality,
  ) {
    if (acceptQuality != null && acceptQuality.isNotEmpty) {
      return acceptQuality.findTargetMedia((e) => e, preferQuality);
    }

    return videoList
        .findTargetMedia((e) => e.quality.code, preferQuality)
        .quality
        .code;
  }

  static (
    int targetQuality,
    FormatItem targetFormat,
    VideoDecodeFormatType targetDecode,
    VideoItem targetVideo,
  )
  findTargetVideo(
    List<VideoItem> videoList,
    int preferQuality,
    List<int>? acceptQuality,
    List<FormatItem> supportFormats,
    List<VideoDecodeFormatType> preferCodecs,
  ) {
    assert(videoList.isNotEmpty);

    final targetQuality = _findAvailableVideoQuality(
      videoList,
      acceptQuality,
      preferQuality,
    );

    final targetFormat = supportFormats.firstWhere(
      (e) => e.quality == targetQuality,
      orElse: () => supportFormats.first,
    );

    final targetDecode = VideoUtils.selectCodec(
      targetFormat.codecs!,
      preferCodecs,
    );

    final targetQaVideoList = videoList
        .where((e) => e.quality.code == targetQuality)
        .toList();

    final targetVideo = targetQaVideoList.firstWhere(
      (e) => targetDecode.codes.any(e.codecs!.startsWith),
      orElse: () => targetQaVideoList.first,
    );

    return (targetQuality, targetFormat, targetDecode, targetVideo);
  }

  static AudioItem findTargetAudio(
    List<AudioItem> audioList,
    int preferQuality,
  ) {
    assert(audioList.isNotEmpty);

    final preferredRank = AudioQuality.fromCode(preferQuality).rank;
    return audioList.findTargetMedia(
      (audio) => AudioQuality.fromCode(audio.id).rank,
      preferredRank,
    );
  }
}
