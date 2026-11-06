import 'package:PiliPlus/services/ui_translate/app_language.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';

/// 旧版译文轨命名（`<主标签>-app-ai`，如 `zh-app-ai`）读取期迁移：
/// 从 `lanDoc` 里携带的「生成时目标语言自称」恢复完整目标代码
/// （`zh-Hant-app-ai`）。3.7.3 起写完整代码；旧文件没有字形子标签，
/// 中文家族目标下会被一律拒挂（正确的旧译文也被迫重翻）。恢复不出来
/// 就原样返回——宁可重翻，绝不把另一种字形的旧译文挂给当前目标。
///
/// 例：`legacyAppAiLanFor('zh-app-ai', '繁體中文 (AI)')` → `zh-Hant-app-ai`；
/// `legacyAppAiLanFor('zh-app-ai', 'Tiếng Việt (AI)')` → 原样（主标签对不上）。
String legacyAppAiLanFor(String lan, String? lanDoc) {
  const suffix = '-app-ai';
  final normalized = lan.toLowerCase().replaceAll('_', '-');
  if (!normalized.endsWith(suffix)) return lan;
  final prefix = normalized.substring(0, normalized.length - suffix.length);
  if (prefix.contains('-')) return lan; // 已是完整代码
  final doc = (lanDoc ?? '').trim();
  if (doc.isEmpty) return lan;
  for (final language in appLanguages) {
    if (language.code.toLowerCase().split('-').first != prefix) continue;
    if (doc.startsWith(language.name)) return '${language.code}$suffix';
  }
  return lan;
}

/// 下载缓存里的 AI 译文轨（`...-app-ai`）能否直接挂给当前目标语言。
///
/// 新格式是 `<完整目标语言代码>-app-ai`（如 `zh-Hant-app-ai`），必须精确匹配；
/// 旧格式只有主标签（`zh-app-ai`），不带字形信息，中文家族目标一律不挂载 ——
/// 否则用户在简体/繁體/粵語之间切换界面语言后，会把另一种字形的旧译文
/// 当成现成译文直接显示。其它语言沿用旧缓存，避免已有下载全部失效。
bool cachedTranslationLanMatches(String lan, String target) {
  const suffix = '-app-ai';
  final normalizedLan = lan.toLowerCase().replaceAll('_', '-');
  if (!normalizedLan.endsWith(suffix)) return false;
  final prefix = normalizedLan.substring(
    0,
    normalizedLan.length - suffix.length,
  );
  final normalizedTarget = target.toLowerCase().replaceAll('_', '-');
  if (prefix == normalizedTarget) return true;
  if (prefix.contains('-')) return false;
  if (prefix != normalizedTarget.split('-').first) return false;
  return !SubtitleTranslationOutput.isChineseFamilyTarget(target);
}

/// 字幕任务共用的「视频身份键」。
///
/// 状态键（`_key`）、产物键（`SubtitleTranslationArtifact.makeKey`）、缓存
/// sessionKey、封面按钮查询、播放页查询必须用**同一个** videoKey，否则会出现
/// 「后台已经翻完，播放页/卡片还显示没开始」或者「重翻另起一个任务」。
///
/// 之前这里散落着四套写法：
/// - 横/竖卡片：`'av:${aid}'`
/// - 自动预翻译：`'av$aid'` / `'ep$epId'` / `'$aid'`（无编号时退化成 `'0'`）
/// - 播放页：一律 `bvid`（番剧 pgc 的 bvid 是空串）
/// - 合集子任务：`'$bvid/$cid'`
///
/// 番剧卡片/播放页没有 bvid/aid，旧写法让所有这类视频共用 `''` 或 `'0'`
/// 一个状态键。这里统一按「bvid → aid → epId → seasonId」降级，四级都没有
/// 就返回空串，调用方据此不渲染按钮、也不启动后台任务。
String subtitleVideoKeyFor({
  String? bvid,
  int? aid,
  int? epId,
  Object? seasonId,
}) {
  final bv = bvid?.trim();
  if (bv != null && bv.isNotEmpty) return bv;
  if (aid != null && aid > 0) return 'av$aid';
  if (epId != null && epId > 0) return 'ep$epId';
  final ss = seasonId == null ? 0 : (int.tryParse('$seasonId') ?? 0);
  if (ss > 0) return 'ss$ss';
  return '';
}

/// 后台写缓存/产物时用的视频身份键。
///
/// [videoKey] 是调用方（卡片/播放页/批量 target）传进来的统一键，优先直接用它；
/// 只有调用方没给键时，才按 bvid → aid → epId → seasonId 重新推导。
///
/// 以前后台这两处硬写 `bvid ?? 'av$aid'`：番剧没有 bvid，键就退化成了
/// `avnull`，而播放页查的是 `ep<epId>` —— 后台翻完了播放页既找不到产物，
/// 也删不掉缓存。普通视频的键仍是 bvid，已有缓存继续命中。
String subtitleCacheVideoKeyFor({
  required String videoKey,
  String? bvid,
  int? aid,
  int? epId,
  Object? seasonId,
}) => videoKey.isNotEmpty
    ? videoKey
    : subtitleVideoKeyFor(
        bvid: bvid,
        aid: aid,
        epId: epId,
        seasonId: seasonId,
      );

/// 身份解析完成后的**规范键**。
///
/// 与 [subtitleCacheVideoKeyFor] 不同，这里优先使用解析出的真实编号：
/// 竖版番剧卡片启动时只有 `epId`（键是 `ep<id>`），但 pgc 详情解析出 bvid 后，
/// 播放页会以 bvid 为键。若继续沿用调用方的 `ep<id>`，同一集会被翻两遍，
/// 播放页也查不到卡片任务刚写下的产物。只有在所有编号都解析失败时，
/// 才退回调用方传入的键。
String subtitleResolvedVideoKeyFor({
  required String callerVideoKey,
  String? bvid,
  int? aid,
  int? epId,
  Object? seasonId,
}) {
  final resolved = subtitleVideoKeyFor(
    bvid: bvid,
    aid: aid,
    epId: epId,
    seasonId: seasonId,
  );
  return resolved.isNotEmpty ? resolved : callerVideoKey;
}
