import 'dart:async';

import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_proxy.dart';

typedef SubtitleTranslationJobFactory = SubtitleTranslationJob Function(
  SubtitleTranslationUpdate onUpdate,
  SubtitleTranslationPriorityHandle priority,
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
  }) {
    var session = _sessions[key];
    if (session == null) {
      session = _SubtitleTranslationSession(
        createJob,
        priority: priority,
        onFinished: () => _sessions.remove(key),
        onCompleted: onCompleted,
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

  void setPosition(int seconds) {
    if (!_detached) _session.job.setPosition(seconds);
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
  }) {
    priorityHandle = SubtitleTranslationPriorityHandle(priority);
    job = _createJob(_onUpdate, priorityHandle);
  }

  final SubtitleTranslationJobFactory _createJob;
  final void Function() onFinished;
  final void Function()? onCompleted;
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

  Future<void> _run() async {
    try {
      await job.loadCached();
      while (!_cancelled) {
        if (_progress?.isComplete == true) break;
        if (!_allowNewTranslation) return;
        try {
          await job.run();
        } catch (_) {
          // A listener or transient storage failure must not strand this
          // shared session forever. The normal retry delay below applies.
        }
        if (_cancelled || _progress?.isComplete == true) break;
        // Preserve failed chunks and retry their exact indexes without
        // hammering a temporarily unavailable translation service.
        final retryExponent = _backgroundRetryAttempt.clamp(0, 3).toInt();
        final baseSeconds = switch (priorityHandle.value) {
          SubtitleTranslationPriority.playback => 2,
          SubtitleTranslationPriority.userRequested => 4,
          SubtitleTranslationPriority.background => 6,
          SubtitleTranslationPriority.playlistPrefetch => 8,
        };
        final delay = Duration(
          seconds: (baseSeconds << retryExponent)
              .clamp(baseSeconds, 60)
              .toInt(),
        );
        _backgroundRetryAttempt = (_backgroundRetryAttempt + 1)
            .clamp(0, 3)
            .toInt();
        await Future<void>.delayed(delay);
      }
    } finally {
      _runFuture = null;
      final completed = _progress?.isComplete == true;
      if (_cancelled || completed || !_allowNewTranslation) {
        _finish(completed: completed);
      }
    }
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
    _vtt = vtt;
    _progress = progress;
    for (final listener in List<SubtitleTranslationUpdate>.from(
      listeners.values,
    )) {
      listener(vtt, progress);
    }
  }
}
