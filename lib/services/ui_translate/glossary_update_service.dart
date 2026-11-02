import 'dart:convert';

import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/services/ui_translate/game_glossary.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// 内置术语表的远端更新检查。
///
/// 术语表（`game_glossary.dart`）是**编译期内嵌**的，所以「更新」本质上是
/// 「检查有没有新版术语表可下载」。这里做三件事：
///
/// 1. 拉取远端 `manifest.json`（只有一个几 KB 的版本清单，不含词条本体）
/// 2. 与内置 `kGlossaryManifest` 逐游戏比对 `version` / `hash`
/// 3. 记住上次检查时间，避免每次进设置页都发请求
///
/// **为什么不在运行时直接抓游戏官网/ wiki**：8 款游戏 × 多个源 × 重型页面，
/// 又慢又容易触发反爬（BWIKI 会直接 567）。检查一个几 KB 的清单便宜又稳定；
/// 词条本体的重建放在构建侧（`glossary/` 里的脚本）完成后随版本发布。
///
/// 远端清单地址可用 `Pref.glossaryManifestUrl` 覆盖（便于自建镜像）。
class GlossaryUpdateService extends GetxService {
  /// 默认远端清单地址（与术语表数据同源发布）。
  static const String defaultManifestUrl =
      'https://raw.githubusercontent.com/SiqYin/PiliBabel/glossary/manifest.json';

  /// 两次自动检查之间的最小间隔。
  static const Duration _minGap = Duration(hours: 24);

  final _state = GlossaryUpdateState.idle.obs;
  GlossaryUpdateState get state => _state.value;

  /// 远端清单（检查成功后填充）。
  final _remote = Rxn<Map<String, dynamic>>();
  Map<String, dynamic>? get remote => _remote.value;

  /// 有更新的游戏列表：gameId -> {built, remote}
  final _updates = <String, GlossaryGameUpdate>{}.obs;
  Map<String, GlossaryGameUpdate> get updates => _updates;

  bool get hasUpdates => _updates.isNotEmpty;

  /// 上次检查时间（毫秒）。0 表示从未检查。
  static int get lastCheckedMs => Pref.glossaryLastChecked;

  /// 按需自动检查：距上次超过 24h 才真正发请求。
  Future<void> autoCheck({bool force = false}) async {
    if (!force && _state.value == GlossaryUpdateState.checking) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (!force && now - lastCheckedMs < _minGap.inMilliseconds) return;
    await check();
  }

  /// 立即检查（用户手动点「检查更新」时调用）。
  Future<void> check() async {
    _state.value = GlossaryUpdateState.checking;
    try {
      final url = Pref.glossaryManifestUrl;
      final res = await Dio().get<dynamic>(
        url,
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 10),
          headers: const {'Accept': 'application/json'},
          // 走系统代理；清单是公开数据，不需要 App 内代理链路
          followRedirects: true,
        ),
      );
      if (res.statusCode != 200) {
        _state.value = GlossaryUpdateState.failed;
        return;
      }
      final raw = res.data;
      final decoded = jsonDecode(raw is String ? raw : raw.toString());
      if (decoded is! Map<String, dynamic>) {
        _state.value = GlossaryUpdateState.failed;
        return;
      }
      _remote.value = decoded;
      _diff(decoded);
      Pref.glossaryLastChecked = DateTime.now().millisecondsSinceEpoch;
      _state.value = hasUpdates
          ? GlossaryUpdateState.outdated
          : GlossaryUpdateState.upToDate;
    } catch (_) {
      _state.value = GlossaryUpdateState.failed;
    }
  }

  /// 比对内置与远端清单。
  void _diff(Map<String, dynamic> remoteManifest) {
    _updates.clear();
    final remoteGames = remoteManifest['games'];
    if (remoteGames is! Map) return;
    for (final entry in remoteGames.entries) {
      final game = entry.key.toString();
      final remoteGame = entry.value;
      if (remoteGame is! Map) continue;
      final built = kGlossaryManifest[game];
      if (built == null) continue; // 本地没有这款游戏，忽略
      final remoteVer = remoteGame['version']?.toString() ?? '';
      final remoteHash = remoteGame['hash']?.toString() ?? '';
      final builtVer = built['version'] ?? '';
      final builtHash = built['hash'] ?? '';
      if (remoteVer != builtVer || (remoteHash.isNotEmpty && remoteHash != builtHash)) {
        _updates[game] = GlossaryGameUpdate(
          game: game,
          builtVersion: builtVer,
          remoteVersion: remoteVer,
          builtRows: int.tryParse(built['rows'] ?? '') ?? 0,
          remoteRows: remoteGame['rows'] is int
              ? remoteGame['rows'] as int
              : int.tryParse('${remoteGame['rows']}') ?? 0,
        );
      }
    }
  }

  /// 清空状态（离开设置页时用）。
  void reset() {
    _state.value = GlossaryUpdateState.idle;
    _updates.clear();
  }
}

enum GlossaryUpdateState { idle, checking, upToDate, outdated, failed }

class GlossaryGameUpdate {
  const GlossaryGameUpdate({
    required this.game,
    required this.builtVersion,
    required this.remoteVersion,
    required this.builtRows,
    required this.remoteRows,
  });

  final String game;
  final String builtVersion;
  final String remoteVersion;
  final int builtRows;
  final int remoteRows;
}
