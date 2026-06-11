import 'dart:math' as math;

import 'package:PiliPlus/grpc/bilibili/community/service/dm/v1.pb.dart';
import 'package:PiliPlus/grpc/dm.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

abstract final class DanmakuDensityTrend {
  static const int segmentLengthMs = 60 * 6 * 1000;
  static const int _targetPointCount = 400;
  static const int _minStepMs = 1000;
  static const int _defaultFontSize = 25;
  static const int _maxConcurrentRequests = 2;
  static const double _densityPower = 0.8;

  // Dynamic window bounds based on danmaku density
  static const double _minDensityPerMin = 1.0;
  static const double _maxDensityPerMin = 15.0;
  static const double _maxWindowMs = 20000.0;
  static const double _minWindowMs = 5000.0;

  static Future<List<double>?> build({
    required int cid,
    required int durationMs,
    bool Function()? shouldCancel,
  }) async {
    if (durationMs <= 0 || cid <= 0) return null;

    final int stepMs = math.max(
      _minStepMs,
      durationMs ~/ _targetPointCount,
    ).toInt();
    final pointCount = (durationMs / stepMs).ceil() + 1;
    if (pointCount <= 1) return null;

    final diff = List<double>.filled(pointCount + 1, 0);
    final segmentCount = (durationMs / segmentLengthMs).ceil();
    var successCount = 0;
    final allElems = <DanmakuElem>[];

    Future<void> requestSegment(int segmentIndex) async {
      if (shouldCancel?.call() == true) return;
      try {
        final res = await DmGrpc.dmSegMobile(
          cid: cid,
          segmentIndex: segmentIndex,
        );
        if (shouldCancel?.call() == true) return;
        if (res case Success(:final response)) {
          successCount++;
          allElems.addAll(response.elems);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('DanmakuDensityTrend segment=$segmentIndex: $e');
        }
      }
    }

    var nextSegment = 1;
    Future<void> worker() async {
      while (true) {
        if (shouldCancel?.call() == true) return;
        final segmentIndex = nextSegment++;
        if (segmentIndex > segmentCount) return;
        await requestSegment(segmentIndex);
      }
    }

    final workerCount = math.min(_maxConcurrentRequests, segmentCount);
    await Future.wait(List.generate(workerCount, (_) => worker()));

    if (shouldCancel?.call() == true) return null;
    if (successCount == 0 || allElems.isEmpty) return null;

    final densityWindowMs = _calculateDynamicWindow(
      allElems.length,
      durationMs,
    );

    _applyElems(
      allElems,
      diff: diff,
      pointCount: pointCount,
      stepMs: stepMs,
      durationMs: durationMs,
      densityWindowMs: densityWindowMs,
    );

    final result = List<double>.filled(pointCount, 0);
    var current = 0.0;
    var maxVal = 0.0;
    for (var i = 0; i < pointCount; i++) {
      current += diff[i];
      if (current < 0) current = 0;
      final value = current <= 0 ? 0.0 : math.pow(current, _densityPower).toDouble();
      result[i] = value;
      if (value > maxVal) maxVal = value;
    }

    if (maxVal <= 0) return null;

    // Gaussian smoothing [0.25, 0.5, 0.25]
    for (var i = 1; i < result.length - 1; i++) {
      result[i] = result[i - 1] * 0.25 + result[i] * 0.5 + result[i + 1] * 0.25;
    }

    return result;
  }

  static double _calculateDynamicWindow(int elemCount, int durationMs) {
    if (durationMs <= 0 || elemCount <= 0) return _minWindowMs;

    final durationMinutes = durationMs / 1000 / 60;
    final density = elemCount / durationMinutes;

    final clampedDensity = density.clamp(_minDensityPerMin, _maxDensityPerMin);
    final t = (clampedDensity - _minDensityPerMin) /
        (_maxDensityPerMin - _minDensityPerMin);

    return _maxWindowMs + (_minWindowMs - _maxWindowMs) * t;
  }

  static void _applyElems(
    Iterable<DanmakuElem> elems, {
    required List<double> diff,
    required int pointCount,
    required int stepMs,
    required int durationMs,
    required double densityWindowMs,
  }) {
    for (final elem in elems) {
      if (!_isDensityElem(elem)) continue;
      final progress = elem.progress;
      if (progress < 0 || progress > durationMs + densityWindowMs.toInt()) continue;

      final density = _dispval(elem);
      if (density <= 0) continue;

      final halfWindow = (densityWindowMs / 2).round();
      final startTime = (progress - halfWindow).clamp(0, durationMs);
      final endTime = (progress + halfWindow).clamp(0, durationMs);

      final start = (startTime / stepMs).floor().clamp(0, pointCount - 1).toInt();
      final end = (endTime / stepMs).floor().clamp(0, pointCount - 1).toInt();

      diff[start] += density;
      final endIndex = end + 1;
      if (endIndex < diff.length) {
        diff[endIndex] -= density;
      }
    }
  }

  static bool _isDensityElem(DanmakuElem elem) {
    if (elem.content.isEmpty) return false;
    // Code/BAS danmaku are not normal on-screen text density.
    if (elem.mode == 8 || elem.mode == 9) return false;
    return true;
  }

  /// Weighted density contribution inspired by pakku.js `dispval()`.
  static double _dispval(DanmakuElem elem) {
    final textLength = elem.content.characters.length;
    if (textLength <= 0) return 0;

    final fontSize = elem.fontsize > 0 ? elem.fontsize : _defaultFontSize;
    final sizeFactor = (fontSize / _defaultFontSize).clamp(0.7, 2.5);
    return math.sqrt(textLength) * math.pow(sizeFactor, 1.5).toDouble();
  }
}
