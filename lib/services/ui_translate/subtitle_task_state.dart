/// 字幕后台任务的状态模型与多分P汇总逻辑。
///
/// 单独放在纯 Dart 文件里：后台服务本身依赖 GetX / SmartDialog / 播放器组件，
/// 回归测试只要引用它就会把整套 UI 拉进测试 isolate（本机 SDK 与项目 patched
/// SDK 有差异时会直接编译失败）。状态判定是纯逻辑，必须能独立测试。
enum SubtitleTranslationTaskPhase {
  idle,
  preparing,
  translating,
  verifying,
  complete,
  failed,
}

class SubtitleTranslationTaskState {
  const SubtitleTranslationTaskState({
    this.phase = SubtitleTranslationTaskPhase.idle,
    this.progress = 0,
    this.message,
    this.nativeTrackAvailable = false,
    this.noSource = false,
  });

  final SubtitleTranslationTaskPhase phase;
  final double progress;
  final String? message;

  /// 本站（Bilibili）已提供目标语言字幕，无需 AI 翻译。
  final bool nativeTrackAvailable;

  /// 这个视频根本没有可用的中文字幕轨。
  ///
  /// 必须和「失败」分开：B 站大多数视频没有 CC 字幕，按下按钮必然没东西可翻。
  /// 以前这种情况被当成失败（红图标 + 「点击重试」），看起来像功能坏了，而重试
  /// 永远不可能成功 —— 因为源本来就不存在。
  final bool noSource;

  bool get isRunning =>
      phase == SubtitleTranslationTaskPhase.preparing ||
      phase == SubtitleTranslationTaskPhase.translating ||
      phase == SubtitleTranslationTaskPhase.verifying;
}

/// 多个分P状态汇总，给没有 cid 的封面按钮看。
///
/// 一个 videoKey 可能有多个 cid（多P / 合集）。以前用「单跳别名」把卡片键
/// 指向最后一个任务键，最后一个分P的状态会覆盖前面所有分P：先完成的谎报
/// 「已翻译」，或后完成的让卡片一直转圈。这里改为按优先级聚合：
///
/// 1. 任一在跑 → 取进度最低的在跑任务（别显示 100% 其实还有分P没开始）；
/// 2. 任一失败 → 失败（可点重试）；
/// 3. 全部是完成/无需翻译 → 完成；
/// 4. 有完成但仍有未开始（idle）的分P → 准备中 + 已完成比例，绝不谎报完成；
///    全部 idle 则返回 idle。
SubtitleTranslationTaskState aggregateCardStates(
  Iterable<SubtitleTranslationTaskState> states,
) {
  final list = states.toList(growable: false);
  if (list.isEmpty) return const SubtitleTranslationTaskState();
  final running = list.where((state) => state.isRunning).toList()
    ..sort((a, b) => a.progress.compareTo(b.progress));
  if (running.isNotEmpty) return running.first;
  for (final state in list) {
    if (state.phase == SubtitleTranslationTaskPhase.failed) return state;
  }
  final settled = list
      .where(
        (state) =>
            state.phase == SubtitleTranslationTaskPhase.complete ||
            state.noSource ||
            state.nativeTrackAvailable,
      )
      .length;
  if (settled == list.length) {
    for (final state in list) {
      if (state.phase == SubtitleTranslationTaskPhase.complete) return state;
    }
    return list.first;
  }
  if (list.every(
    (state) => state.phase == SubtitleTranslationTaskPhase.idle,
  )) {
    return const SubtitleTranslationTaskState();
  }
  // 到这里说明「有完成的、也有没开始的」：返回准备中，卡片继续转圈。
  // 直接返回最后一个非 idle 会把 complete 显示出来，用户以为整片都翻好了。
  return SubtitleTranslationTaskState(
    phase: SubtitleTranslationTaskPhase.preparing,
    progress: settled / list.length,
  );
}
