import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/models/common/video/cdn_type.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

/// 线路地区的识别与解析。
///
/// 取流时该优先走大陆镜像还是海外节点，完全取决于用户在哪 —— B 站下发的候选
/// 直链两边都有，选错了就是「每隔几秒卡一下」。这里负责回答「用户在哪个地区」。
///
/// 识别走 B 站自己的 `x/web-interface/zone`（按请求方 IP 返回
/// country/province/country_code），不引第三方定位，也不需要登录。
abstract final class CdnRegionResolver {
  /// 识别结果的有效期。用户可能出差/换网络，过期后重新识别一次；
  /// 期间不重复请求。
  static const Duration _ttl = Duration(days: 7);

  /// 上次识别到的地区；从未识别过或存档损坏时为 null。
  static CdnRegion? get detected => CdnRegion.fromName(
    GStorage.localCache.get(LocalCacheKey.detectedCdnRegion) as String?,
  );

  static DateTime? get detectedAt {
    final ts = GStorage.localCache.get(LocalCacheKey.detectedCdnRegionTime);
    return ts is int ? DateTime.fromMillisecondsSinceEpoch(ts) : null;
  }

  /// 当前**生效**的地区：用户手动指定优先，否则用识别结果。
  ///
  /// 三者都没有时给 [CdnRegion.other]——宁可偏海外线路（海外用户不会被钉在
  /// 大陆镜像上），也不要在未识别时按大陆处理。
  static CdnRegion get effective {
    final manual = Pref.cdnRegion;
    if (manual != CdnRegion.auto) {
      return manual;
    }
    return detected ?? CdnRegion.other;
  }

  /// 生效地区是否为「用户手动指定」的，用于 UI 提示。
  static bool get isManual => Pref.cdnRegion != CdnRegion.auto;

  static bool _isStale() {
    final at = detectedAt;
    if (at == null) {
      return true;
    }
    return DateTime.now().difference(at) > _ttl;
  }

  /// 需要时识别一次（首次启动 / 结果过期 / 强制）。
  ///
  /// 任何失败都静默返回 null：识别不出来只是线路策略退回默认，不该打扰用户，
  /// 更不该阻塞启动。
  static Future<CdnRegion?> ensureDetected({bool force = false}) async {
    if (!force && detected != null && !_isStale()) {
      return detected;
    }
    return detect();
  }

  /// 查询一次并落缓存。返回识别结果；失败返回 null（不清掉旧值）。
  static Future<CdnRegion?> detect() async {
    try {
      final res = await Request().get(Api.zone);
      if (res.data['code'] != 0) {
        return null;
      }
      final data = res.data['data'];
      if (data is! Map) {
        return null;
      }
      final region = CdnRegion.fromZone(
        country: data['country'] as String?,
        province: data['province'] as String?,
        countryCode: _asInt(data['country_code']),
      );
      await GStorage.localCache.put(
        LocalCacheKey.detectedCdnRegion,
        region.name,
      );
      await GStorage.localCache.put(
        LocalCacheKey.detectedCdnRegionTime,
        DateTime.now().millisecondsSinceEpoch,
      );
      if (kDebugMode) {
        debugPrint(
          'CdnRegion detected: ${region.name} '
          '(${data['country']}/${data['province']})',
        );
      }
      return region;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CdnRegion detect failed: $e');
      }
      return null;
    }
  }

  /// country_code 是 ISO 3166 数字码，正常是 int；兼容接口返回字符串的情况。
  static int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
