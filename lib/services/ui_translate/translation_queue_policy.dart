/// UI 翻译队列调度的纯函数部分：不依赖 GetX / Pref / Hive，可独立测试。
///
/// 背景（`PROGRESS-3.6.4-3.6.7-2026-11-04.md` §六 的「翻译变慢」评估）：
/// `precache` 预热的 200+ 条文案曾全部进 `_pendingUrgent`，而 `_flush` 对
/// 优先队列**排他取空**——内置引擎逐条请求（batch=1、并发 10）排空要 15~40s，
/// 期间普通队列（下拉刷新出来的新标题）被饿死，表现为「下拉刷新的新一批标题
/// 很久才出译文」。当时按用户要求只评估未修；本版修复。
library;

/// 本轮 `_flush` 从优先队列（`_pendingUrgent`）还是普通队列（`_pending`）取。
///
/// - 只有一边非空：取非空的那边。
/// - 两边都非空：**交替**取（上一轮取过优先队列，这一轮就给普通队列），
///   保证任何一侧都不会被无限饿死。
bool nextFlushFromUrgent({
  required bool urgentNotEmpty,
  required bool pendingNotEmpty,
  required bool lastFlushTookUrgent,
}) {
  if (!urgentNotEmpty) return false;
  if (!pendingNotEmpty) return true;
  return !lastFlushTookUrgent;
}
