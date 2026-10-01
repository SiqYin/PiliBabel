import 'package:PiliPlus/models/common/video/cdn_type.dart';
import 'package:PiliPlus/models/common/video/video_decode_type.dart';
import 'package:PiliPlus/models_new/live/live_room_play_info/codec.dart';
import 'package:PiliPlus/utils/cdn_node_store.dart';
import 'package:PiliPlus/utils/extension/iterable_ext.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

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
    return CdnNodeStore.labelOf(host) ?? '自定义：$host';
  }

  /// [customHost] 显式指定自定义节点（节点测速用）；未传时按 [applyCustomCDN]
  /// 决定是否采用全局自定义节点。全局自定义生效时完全旁路枚举语义。
  static String getCdnUrl(
    Iterable<String> urls, {
    CDNService? defaultCDNService,
    String? customHost,
    bool applyCustomCDN = true,
    bool isAudio = false,
  }) {
    defaultCDNService ??= cdnService;
    customHost ??= applyCustomCDN ? customCDNUrl : null;
    if (isAudio && disableAudioCDN) {
      customHost = null;
    }

    if (customHost == null && defaultCDNService == CDNService.baseUrl) {
      return urls.first;
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
          if (isAudio && disableAudioCDN) {
            return url;
          }
          if (defaultCDNService == CDNService.backupUrl) {
            // 默认线路（未显式选 CDN）：把国内 upos/estg 镜像改写到 Akamai 全球
            // 边缘，对齐 B 站海外的通行做法。android_hd 的 playurl 从海外常返回
            // 国内 upos-sz-* 镜像，直接沿用会让海外 4K 卡顿、下载变慢/偶发失败；
            // 播放与下载都走这里，一处修复两端受益。仍可在设置里手选国内 CDN。
            return uri.replace(host: CDNService.akamai.host!).toString();
          }
          return uri
              .replace(host: defaultCDNService.host ?? CDNService.ali.host)
              .toString();
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
        // 让全球用户都能拿到就近可播地址（此前会回退硬编码成国内 ali）。
        return uri.replace(host: CDNService.akamai.host!).toString();
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
}
