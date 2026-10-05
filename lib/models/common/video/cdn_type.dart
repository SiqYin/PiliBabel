// ignore_for_file: constant_identifier_names

//https://github.com/yujincheng08/BiliRoaming/blob/master/app/src/main/res/values/strings_raw.xml
//https://github.com/yujincheng08/BiliRoaming/blob/master/app/src/main/res/values/arrays.xml

/// 使用地区。决定取流时**如何在候选直链里挑线路**，以及 CDN 列表按地区归类。
///
/// 为什么需要它：B 站下发的候选直链里通常同时有大陆 upos 镜像和海外
/// （Akamai / *ov / hk_bcache）地址。两边的快慢完全取决于**用户在哪**：
///
/// * 大陆用户走大陆镜像最快；强挑海外地址会走到更远的边缘节点。
/// * 海外用户反过来 —— 大陆镜像对境外常被限速（实测约 100KB/s），必须走海外。
///
/// 所以这里不能「一刀切地都优先海外」。
enum CdnRegion {
  auto('自动识别'),
  mainland('中国大陆'),
  japan('日本'),
  hkMoTw('港澳台'),
  other('其他地区'),
  ;

  final String desc;

  const CdnRegion(this.desc);

  /// 非大陆地区：取流时应优先挑 B 站已下发的海外/Akamai 现成直链。
  bool get preferOverseas => this != CdnRegion.mainland;

  /// 由枚举名反查（存档里存的是 name，改名不会串档）。
  static CdnRegion? fromName(String? name) {
    if (name == null) {
      return null;
    }
    for (final e in values) {
      if (e.name == name) {
        return e;
      }
    }
    return null;
  }

  /// 由 B 站 `x/web-interface/zone` 的返回值推断地区。
  ///
  /// 优先用 `country_code`（ISO 3166 数字码，机器可读、不受语言影响）：
  /// 86 中国大陆 / 81 日本 / 852 香港 / 853 澳门 / 886 台湾。
  /// 拿不到码时退回中文地名匹配。识别不出来一律当 [other]——
  /// 那是最保守的选项（偏好海外线路），不会把海外用户钉在大陆镜像上。
  static CdnRegion fromZone({
    String? country,
    String? province,
    int? countryCode,
  }) {
    switch (countryCode) {
      case 86:
        return CdnRegion.mainland;
      case 81:
        return CdnRegion.japan;
      case 852:
      case 853:
      case 886:
        return CdnRegion.hkMoTw;
    }
    final text = '${country ?? ''}${province ?? ''}';
    if (text.isEmpty) {
      return CdnRegion.other;
    }
    const hkMoTwWords = ['香港', '澳门', '澳門', '台湾', '台灣', '臺'];
    for (final w in hkMoTwWords) {
      if (text.contains(w)) {
        return CdnRegion.hkMoTw;
      }
    }
    if (text.contains('日本')) {
      return CdnRegion.japan;
    }
    // 「中国」在 B 站接口里同时用于大陆与港澳台，所以港澳台要先判
    if (text.contains('中国') || text.contains('中國')) {
      return CdnRegion.mainland;
    }
    return CdnRegion.other;
  }
}

enum CDNService {
  baseUrl('基础URL（不推荐）'),
  backupUrl('备用URL'),
  ali('ali（阿里云）', 'upos-sz-mirrorali.bilivideo.com'),
  alib('alib（阿里云）', 'upos-sz-mirroralib.bilivideo.com'),
  alio1('alio1（阿里云）', 'upos-sz-mirroralio1.bilivideo.com'),
  cos('cos（腾讯云）', 'upos-sz-mirrorcos.bilivideo.com'),
  cosb('cosb（腾讯云，VOD加速类型）', 'upos-sz-mirrorcosb.bilivideo.com'),
  coso1('coso1（腾讯云）', 'upos-sz-mirrorcoso1.bilivideo.com'),
  hw('hw（华为云，融合CDN）', 'upos-sz-mirrorhw.bilivideo.com'),
  hwb('hwb（华为云，融合CDN）', 'upos-sz-mirrorhwb.bilivideo.com'),
  hwo1('hwo1（华为云，融合CDN）', 'upos-sz-mirrorhwo1.bilivideo.com'),
  hw_08c('08c（华为云，融合CDN）', 'upos-sz-mirror08c.bilivideo.com'),
  hw_08h('08h（华为云，融合CDN）', 'upos-sz-mirror08h.bilivideo.com'),
  hw_08ct('08ct（华为云，融合CDN）', 'upos-sz-mirror08ct.bilivideo.com'),
  tf_hw('tf_hw（华为云）', 'upos-tf-all-hw.bilivideo.com'),
  tf_tx('tf_tx（腾讯云）', 'upos-tf-all-tx.bilivideo.com'),
  akamai('akamai（Akamai海外）', 'upos-hz-mirrorakam.akamaized.net'),
  aliov('aliov（阿里云海外）', 'upos-sz-mirroraliov.bilivideo.com'),
  cosov('cosov（腾讯云海外）', 'upos-sz-mirrorcosov.bilivideo.com'),
  hwov('hwov（华为云海外）', 'upos-sz-mirrorhwov.bilivideo.com'),
  hk_bcache('hk_bcache（Bilibili海外）', 'cn-hk-eq-bcache-01.bilivideo.com'),
  ;

  final String desc;
  final String? host;

  const CDNService(this.desc, [this.host]);

  /// 这台主机的地理归属，用于把 CDN 列表按地区归类展示。
  ///
  /// 注意与「使用地区」[CdnRegion] 不是一回事：那是**用户在哪儿**，
  /// 这是**主机在哪儿**。海外主机（akamai / *ov）在日本、港澳台、其他地区
  /// 都能用，所以统一归到 [CdnRegion.other] 下展示。
  CdnRegion get region {
    switch (this) {
      case CDNService.ali:
      case CDNService.alib:
      case CDNService.alio1:
      case CDNService.cos:
      case CDNService.cosb:
      case CDNService.coso1:
      case CDNService.hw:
      case CDNService.hwb:
      case CDNService.hwo1:
      case CDNService.hw_08c:
      case CDNService.hw_08h:
      case CDNService.hw_08ct:
      case CDNService.tf_hw:
      case CDNService.tf_tx:
        return CdnRegion.mainland;
      case CDNService.hk_bcache:
        return CdnRegion.hkMoTw;
      case CDNService.akamai:
      case CDNService.aliov:
      case CDNService.cosov:
      case CDNService.hwov:
        return CdnRegion.other;
      case CDNService.baseUrl:
      case CDNService.backupUrl:
        // 不指定主机，交给 B 站按 IP 就近 —— 各地区都适用
        return CdnRegion.auto;
    }
  }

  /// 某地区下**值得选**的线路，按推荐顺序排列。
  ///
  /// 海外地区（日本/港澳台/其他）先给海外主机；港澳台额外把 [hk_bcache]
  /// 排在前面（B 站香港自建节点，对港澳台最近）。
  static List<CDNService> recommendFor(CdnRegion region) {
    const domestic = [
      CDNService.ali,
      CDNService.alib,
      CDNService.alio1,
      CDNService.cos,
      CDNService.cosb,
      CDNService.coso1,
      CDNService.hw,
      CDNService.hwb,
      CDNService.hwo1,
      CDNService.hw_08c,
      CDNService.hw_08h,
      CDNService.hw_08ct,
      CDNService.tf_hw,
      CDNService.tf_tx,
    ];
    const overseas = [
      CDNService.akamai,
      CDNService.aliov,
      CDNService.cosov,
      CDNService.hwov,
    ];
    switch (region) {
      case CdnRegion.mainland:
        return domestic;
      case CdnRegion.hkMoTw:
        return [CDNService.hk_bcache, ...overseas, ...domestic];
      case CdnRegion.japan:
      case CdnRegion.other:
        return [...overseas, CDNService.hk_bcache];
      case CdnRegion.auto:
        return values;
    }
  }
}

// from https://rec.danmuji.org/dev/cdn-info/
// {
//     'cn-ahwh-ct-': {'01': 16},
//     'cn-cq-ct-': {'01': 35, '02': 2},
//     'cn-gddg-ct-': {'01': 36},
//     'cn-gdfs-ct-': {'01': 28},
//     'cn-hblf-ct-': {'01': 21},
//     'cn-hbyc-ct-': {'02': 35},
//     'cn-hljheb-ct-': {'01': 12},
//     'cn-hnld-ct-': {'01': 56},
//     'cn-jsnt-ct-': {'01': 52},
//     'cn-jsyz-ct-': {'03': 52},
//     'cn-jxjj-ct-': {'01': 14},
//     'cn-sccd-ct-': {'01': 32},
//     'cn-sxxa-ct-': {'03': 14},
//     'cn-xj-ct-': {'01': 6},
//     'cn-zjjh-ct-': {'04': 37},
//     'cn-gddg-cu-': {'01': 15},
//     'cn-hncs-cu-': {'01': 14, 'v': 6},
//     'cn-hnly-cu-': {'01': 35},
//     'cn-jlcc-cu-': {'03': 16},
//     'cn-jstz-cu-': {'01': 14},
//     'cn-lnsy-cu-': {'01': 9, 'v': 4},
//     'cn-nmghhht-cu-': {'01': 15, 'v': 11},
//     'cn-sccd-cu-': {'01': 13},
//     'cn-sdqd-cu-': {'01': 25},
//     'cn-sxty-cu-': {'03': 10},
//     'cn-sxxa-cu-': {'02': 8},
//     'cn-zjhz-cu-': {'01': 8, 'v': 6},
//     'cn-cq-cm-': {'01': 30},
//     'cn-fjqz-cm-': {'01': 10},
//     'cn-gddg-cm-': {'01': 14},
//     'cn-gdst-cm-': {'01': 17},
//     'cn-hbsjz-cm-': {'02': 16},
//     'cn-hbwh-cm-': {'01': 23},
//     'cn-hncs-cm-': {'03': 24},
//     'cn-hnzz-cm-': {'01': 16},
//     'cn-jssz-cm-': {'01': 24, '02': 62},
//     'cn-jxnc-cm-': {'01': 20},
//     'cn-lnsy-cm-': {'01': 11},
//     'cn-nmghhht-cm-': {'01': 5},
//     'cn-sccd-cm-': {'03': 26},
//     'cn-sdjn-cm-': {'02': 14},
//     'cn-sxxa-cm-': {'01': 14},
//     'cn-tj-cm-': {'02': 16},
//     'cn-xj-cm-': {'02': 6},
//     'cn-zjhz-cm-': {'01': 29},
//     'cn-cq-gd-': {'01': 20},
//     'cn-gdgz-gd-': {'01': 20},
//     'cn-gzgy-gd-': {'01': 6},
//     'cn-hb-gd-': {'01': 4},
//     'cn-hbwh-gd-': {'01': 6},
//     'cn-hljheb-gd-': {'01': 2},
//     'cn-hncs-gd-': {'01': 8},
//     'cn-jlcc-gd-': {'01': 5},
//     'cn-jsnj-gd-': {'01': 8},
//     'cn-zjhz-gd-': {'02': 2},
//     'cn-bj-fx-': {'01': 6},
//     'cn-fjfz-fx-': {'01': 6},
//     'cn-gdgz-fx-': {'01': 18},
//     'cn-hbwh-fx-': {'01': 16},
//     'cn-hncs-fx-': {'01': 6},
//     'cn-hnzz-fx-': {'01': 8},
//     'cn-jsnj-fx-': {'02': 6},
//     'cn-sccd-fx-': {'01': 6},
//     'cn-sdjn-fx-': {'01': 6},
//     'cn-sh-fx-': {'01': 10},
//     'cn-tj-fx-': {'01': 6},
//     'cn-bj-se-': {'01': 8},
//     'cn-bj-cc-': {'03': 18},
//     'cn-gdfs-cc-': {'02': 21},
//     'cn-sh-cc-': {'01': 15},
//     'cn-zjhz-wasu-': {'03': 21, '04': 12},
//     'cn-sh-ix-': {'01': 13},
//     'cn-hk-eq-': {'01': 14}
// }
