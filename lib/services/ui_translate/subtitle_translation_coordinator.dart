import 'dart:async';

import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_proxy.dart';

typedef SubtitleTranslationJobFactory = SubtitleTranslationJob Function(
  SubtitleTranslationUpdate onUpdate,
  SubtitleTranslationPriorityHandle priority,
);

typedef SubtitleTranslationRetryDelay = Duration Function(
  SubtitleTranslationPriority priority,
  int attempt,
);

/// Keeps translation work alive independently from a video page/controller.
///
/// A page only attaches a listener. Leaving a video detaches that listener,
/// while the shared session keeps checkpointing and retries failed chunks.
class SubtitleTranslationCoordinator {
  SubtitleTranslationCoordinator._();

  static final Map<String, _SubtitleTranslationSession> _sessions = {};
  static var _nextListenerId = 0;

  static SubtitleTranslationSubscription attach({
    required String key,
    required SubtitleTranslationJobFactory createJob,
    required SubtitleTranslationUpdate onUpdate,
    required bool allowNewTranslation,
    SubtitleTranslationPriority priority =
        SubtitleTranslationPriority.background,
    void Function()? onCompleted,
    SubtitleTranslationRetryDelay? retryDelay,
  }) {
    var session = _sessions[key];
    if (session == null) {
      session = _SubtitleTranslationSession(
        createJob,
        priority: priority,
        onFinished: () => _sessions.remove(key),
        onCompleted: onCompleted,
        retryDelay: retryDelay,
      );
      _sessions[key] = session;
    } else {
      session.promote(priority);
    }
    final listenerId = _nextListenerId++;
    final hadLatestUpdate = session.hasLatestUpdate;
    session.listeners[listenerId] = onUpdate;
    session.start(allowNewTranslation);
    if (hadLatestUpdate) session.emitLatestTo(onUpdate);
    return SubtitleTranslationSubscription._(session, listenerId);
  }
}

class SubtitleTranslationSubscription {
  SubtitleTranslationSubscription._(this._session, this._listenerId);

  final _SubtitleTranslationSession _session;
  final int _listenerId;
  bool _detached = false;

  Future<void> get whenComplete => _session.whenComplete;

  bool get isCancelled => _session.isCancelled;

  /// 分块失败的真实原因（见 [SubtitleTranslationJob.lastError]）。
  Object? get lastError => _session.job.lastError;

  void setPosition(int seconds) {
    if (!_detached) _session.job.setPosition(seconds);
  }

  /// 起播定位：把播放页真实起播位置写进（可能被复用的）共享会话。
  ///
  /// 后台预翻译先于播放页在 onInit 建会话，那时位置恒为 0；播放页 attach
  /// 时同一个缓存身份键会复用该会话，`createJob` 不再执行，构造参数里的
  /// `positionSeconds` 就丢了。必须在 attach 后显式补写，否则队列仍按
  /// 位置 0 排序，从中间续播要先把前面的分块全部翻完。
  void primePosition(int seconds) {
    if (!_detached) _session.job.primePosition(seconds);
  }

  /// Retry the existing failed chunks immediately without creating a second
  /// job or discarding chunks that have already passed validation.
  void retryNow() {
    if (!_detached) _session.retryNow();
  }

  /// Stop receiving updates but deliberately keep the background translation.
  void detach() {
    if (_detached) return;
    _detached = true;
    _session.listeners.remove(_listenerId);
  }

  /// Used only for an explicit user subtitle override.
  void cancel() {
    if (_detached) return;
    _detached = true;
    _session.listeners.remove(_listenerId);
    _session.cancel();
  }
}

class _SubtitleTranslationSession {
  _SubtitleTranslationSession(
    this._createJob, {
    required SubtitleTranslationPriority priority,
    required this.onFinished,
    this.onCompleted,
    SubtitleTranslationRetryDelay? retryDelay,
  }) {
    _retryDelay = retryDelay ?? _defaultRetryDelay;
    priorityHandle = SubtitleTranslationPriorityHandle(priority);
    job = _createJob(_onUpdate, priorityHandle);
  }

  final SubtitleTranslationJobFactory _createJob;
  final void Function() onFinished;
  final void Function()? onCompleted;
  late final SubtitleTranslationRetryDelay _retryDelay;
  final listeners = <int, SubtitleTranslationUpdate>{};
  late final SubtitleTranslationJob job;
  late final SubtitleTranslationPriorityHandle priorityHandle;
  final _completion = Completer<void>();
  String? _vtt;
  SubtitleTranslationProgress? _progress;
  Future<void>? _runFuture;
  bool _allowNewTranslation = false;
  bool _cancelled = false;
  bool _finished = false;
  int _backgroundRetryAttempt = 0;
  int _bestTranslatedCues = 0;
  int _retryRequest = 0;
  int _consumedRetryRequest = 0;
  Completer<void>? _retryWakeSignal;

  Future<void> get whenComplete => _completion.future;

  bool get isCancelled => _cancelled;

  bool get hasLatestUpdate => _vtt != null && _progress != null;

  void promote(SubtitleTranslationPriority priority) {
    priorityHandle.promote(priority);
  }

  void start(bool allowNewTranslation) {
    _allowNewTranslation = _allowNewTranslation || allowNewTranslation;
    // A cache miss used to be completely silent until the first network chunk
    // finished. Let attached players show the original subtitles and progress
    // from zero immediately when a new translation is allowed.
    if (_progress == null && allowNewTranslation) job.emitCurrent();
    _runFuture ??= _run();
  }

  void retryNow() {
    if (_cancelled || _finished) return;
    _allowNewTranslation = true;
    _backgroundRetryAttempt = 0;
    _retryRequest++;
    priorityHandle.promote(SubtitleTranslationPriority.userRequested);
    final signal = _retryWakeSignal;
    if (signal != null && !signal.isCompleted) signal.complete();
    _runFuture ??= _run();
  }

  void emitLatestTo(SubtitleTranslationUpdate listener) {
    final vtt = _vtt;
    final progress = _progress;
    if (vtt != null && progress != null) listener(vtt, progress);
  }

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    job.cancel();
    _finish();
  }

  /// 连续多少轮「一个已校验分块都没新增」就放弃。
  ///
  /// 之前这里没有上限：所有分块都翻不出来时（接口拒绝、校验全不通过），
  /// `job.run()` 每轮都返回、进度永远是 0，`whenComplete` 就永远不完成 ——
  /// 调用方 `await` 住不放，UI 停在「翻译中」一直转圈，既不报错也不结束。
  /// 现在连续 3 轮毫无进展就收尾，把失败交回给调用方去显示。
  static const int _maxIdleRounds = 3;

  Future<void> _run() async {
    var idleRounds = 0;
    var gaveUp = false;
    try {
      await job.loadCached();
      while (!_cancelled) {
        if (_progress?.isComplete == true) break;
        if (!_allowNewTranslation) return;
        final translatedBefore = _bestTranslatedCues;
        try {
          await job.run();
        } catch (_) {
          // A listener or transient storage failure must not strand this
          // shared session forever. The normal retry delay below applies.
        }
        if (_cancelled || _progress?.isComplete == true) break;
        // 只有「有新的已校验分块」才算有进展；全失败时这一轮等于白跑。
        idleRounds = _bestTranslatedCues > translatedBefore
            ? 0
            : idleRounds + 1;
        if (idleRounds >= _maxIdleRounds) {
          gaveUp = true;
          break;
        }
        if (_retryRequest != _consumedRetryRequest) {
          _consumedRetryRequest = _retryRequest;
          continue;
        }
        // Preserve failed chunks and retry their exact indexes without
        // hammering a temporarily unavailable translation service.
        final attempt = _backgroundRetryAttempt.clamp(0, 3).toInt();
        final delay = _retryDelay(priorityHandle.value, attempt);
        _backgroundRetryAttempt = (_backgroundRetryAttempt + 1)
            .clamp(0, 3)
            .toInt();
        await _waitForRetry(delay);
        _consumedRetryRequest = _retryRequest;
      }
    } finally {
      _runFuture = null;
      final completed = _progress?.isComplete == true;
      // gaveUp 必须一起收尾：否则 break 出来以后既不 complete 也不 finish，
      // 又会退回到「永远转圈」那种状态。
      if (_cancelled || completed || gaveUp || !_allowNewTranslation) {
        _finish(completed: completed);
      }
    }
  }

  Future<void> _waitForRetry(Duration delay) async {
    final signal = Completer<void>();
    _retryWakeSignal = signal;
    try {
      await Future.any([Future<void>.delayed(delay), signal.future]);
    } finally {
      if (identical(_retryWakeSignal, signal)) _retryWakeSignal = null;
    }
  }

  static Duration _defaultRetryDelay(
    SubtitleTranslationPriority priority,
    int attempt,
  ) {
    final baseSeconds = switch (priority) {
      SubtitleTranslationPriority.playback => 2,
      SubtitleTranslationPriority.userRequested => 4,
      SubtitleTranslationPriority.background => 6,
      SubtitleTranslationPriority.playlistPrefetch => 8,
    };
    return Duration(
      seconds: (baseSeconds << attempt).clamp(baseSeconds, 60).toInt(),
    );
  }

  void _finish({bool completed = false}) {
    if (_finished) return;
    _finished = true;
    if (!_completion.isCompleted) _completion.complete();
    onFinished();
    if (completed) {
      try {
        onCompleted?.call();
      } catch (_) {
        // Completion hooks are optional prefetch work, never playback work.
      }
    }
  }

  void _onUpdate(String vtt, SubtitleTranslationProgress progress) {
    if (_cancelled) return;
    if (progress.translatedCues > _bestTranslatedCues) {
      _bestTranslatedCues = progress.translatedCues;
      // Any newly validated chunk proves the route is making progress. Future
      // failures restart at the short delay instead of inheriting stale
      // exponential backoff from an earlier outage.
      _backgroundRetryAttempt = 0;
    }
    _vtt = vtt;
    _progress = progress;
    for (final listener in List<SubtitleTranslationUpdate>.from(
      listeners.values,
    )) {
      listener(vtt, progress);
    }
  }
}
