import 'package:PiliPlus/grpc/bilibili/app/dynamic/v1.pb.dart'
    show DynVideoReqReply;
import 'package:PiliPlus/grpc/bilibili/app/dynamic/v2.pb.dart'
    show DynAllReply, DynSpaceRsp;

/// E3.2 动态 gRPC 响应 -> App 现有模型能吃的 web 结构。
///
/// App 的动态 UI 与解析器（DynamicsDataModel / DynamicItemModel）建立在
/// web-dynamic 的 modules 结构上，而 gRPC（DynAll / DynVideo / DynSpace）返回的
/// 动态卡是同源结构：同样是一串 modules，只是键名是 proto 的 lowerCamelCase、
/// 数值型 ID 是字符串、卡片类型是 proto 枚举名。这里只做三件确定的事：
///   1. 键名统一转成下划线风格（moduleAuthor -> module_author）；
///   2. 卡片类型枚举名转成 web 的 DYNAMIC_TYPE_* 字面量；
///   3. 已知的数值字段把字符串还原成数字（proto3 JSON 把 int64 输出成字符串）。
/// 实现走 proto3Json 再统一改键名，所以 v1（DynVideo）与 v2（DynAll/DynSpace）
/// 两个命名空间共用同一套转换。
/// 认不出的卡片类型、或转换中出现任何意外，一律返回 null —— 调用方整页回退 REST，
/// 绝不出现「半页 gRPC、半页空白」这种状态。
abstract final class DynGrpcBridge {
  /// 只列确认能对齐的卡片类型；其余（转发、直播、付费等）整页回退 REST。
  static const Set<String> _supported = {
    'AV',
    'DRAW',
    'WORD',
    'ARTICLE',
    'COURSES',
    'PGC',
  };

  /// 这些字段在 web 结构里是数字，proto3 JSON 会输出成字符串，这里还原
  static const Set<String> _numeric = {
    'aid',
    'cid',
    'mid',
    'uid',
    'duration',
    'pub_ts',
    'rpid',
    'view',
    'like',
    'reply',
    'repost',
    'danmaku',
    'coin',
    'favorite',
    'season_id',
    'ep_id',
    'rid',
    'type_id',
    'up_mid',
    'count',
  };

  /// 动态主 feed（全部等标签页）
  static Map<String, dynamic>? fromDynAll(DynAllReply reply) {
    final j = _map(reply.toProto3Json());
    if (j == null) {
      return null;
    }
    final list = j['dynamic_list'];
    if (list is! Map<String, dynamic>) {
      return null;
    }
    return _page(list['list'], list['history_offset'], _truthy(list['has_more']));
  }

  /// 动态页的视频标签页（v1 命名空间）
  static Map<String, dynamic>? fromDynVideo(DynVideoReqReply reply) {
    final j = _map(reply.toProto3Json());
    if (j == null) {
      return null;
    }
    return _page(j['list'], j['history_offset'], _truthy(j['has_more']));
  }

  /// 空间页动态
  static Map<String, dynamic>? fromDynSpace(DynSpaceRsp rsp) {
    final j = _map(rsp.toProto3Json());
    if (j == null) {
      return null;
    }
    return _page(rsp.list.isEmpty ? null : j['list'], j['history_offset'],
        _truthy(j['has_more']));
  }

  static Map<String, dynamic>? _page(
    dynamic rawList,
    dynamic offset,
    bool hasMore,
  ) {
    if (rawList is! List) {
      return null;
    }
    final items = <Map<String, dynamic>>[];
    for (final raw in rawList) {
      final w = _item(_map(raw));
      if (w == null) {
        return null;
      }
      items.add(w);
    }
    return {
      'items': items,
      'offset': offset is String ? offset : '',
      'has_more': hasMore,
    };
  }

  static Map<String, dynamic>? _item(Map<String, dynamic>? item) {
    if (item == null) {
      return null;
    }
    final type = _typeName(item['card_type']?.toString());
    if (type == null) {
      return null;
    }
    final modules = <String, dynamic>{};
    if (item['modules'] case final List rawModules) {
      for (final m in rawModules) {
        final json = _map(m);
        if (json == null) {
          continue;
        }
        json.remove('module_type');
        modules.addAll(json);
      }
    }
    final ext = _map(item['extend']);
    final author = modules['module_author'];
    final basic = author is Map<String, dynamic>
        ? <String, dynamic>{
            'uid': _asInt(author['mid']),
            'name': author['name'],
            'face': author['face'],
          }
        : null;
    return {
      'id_str': ext?['dyn_id_str'] ?? '',
      'type': type,
      'modules': modules,
      'basic': ?basic,
    };
  }

  static String? _typeName(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    // proto 枚举名可能是 dyn_av / dynAv / DYN_AV，统一成 AV 再拼 web 字面量
    var s = raw.replaceAll('_', '').toUpperCase();
    if (s.startsWith('DYN')) {
      s = s.substring(3);
    }
    if (!_supported.contains(s)) {
      return null;
    }
    return 'DYNAMIC_TYPE_$s';
  }

  static Map<String, dynamic>? _map(dynamic v) {
    final s = _snake(v);
    return s is Map<String, dynamic> ? s : null;
  }

  static dynamic _snake(dynamic v) {
    if (v is Map) {
      final out = <String, dynamic>{};
      v.forEach((k, val) {
        final key = _snakeKey(k.toString());
        final value = _snake(val);
        // proto3 JSON 把 int64 输出成字符串，web 结构里这些字段是数字
        out[key] = _numeric.contains(key) ? _asInt(value) : value;
      });
      return out;
    }
    if (v is List) {
      return v.map(_snake).toList();
    }
    return v;
  }

  static String _snakeKey(String k) {
    final buf = StringBuffer();
    for (var i = 0; i < k.length; i++) {
      final c = k[i];
      final lower = c.toLowerCase();
      if (c != lower && i > 0) {
        buf.write('_');
      }
      buf.write(lower);
    }
    return buf.toString();
  }

  static bool _truthy(dynamic v) {
    if (v is bool) {
      return v;
    }
    if (v is int) {
      return v != 0;
    }
    return false;
  }

  static dynamic _asInt(dynamic v) {
    if (v is int) {
      return v;
    }
    if (v is String) {
      return int.tryParse(v) ?? v;
    }
    return v;
  }
}
