import 'dart:math' as math;

import 'package:PiliPlus/grpc/bilibili/community/service/dm/v1.pb.dart';
import 'package:PiliPlus/grpc/dm.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

abstract final class DanmakuDensityTrend {
  static const int segmentLengthMs = 60 * 6 * 1000;
  static const int densityWindowMs = 5000;
  static const int _targetPointCount = 600;
  static const int _minStepMs = 1000;
  static const int _defaultFontSize = 25;
  static const int _maxConcurrentRequests = 2;
  static const double _densityPower = 0.8;

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
    var elemCount = 0;

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
          elemCount += response.elems.length;
          _applyElems(
            response.elems,
            diff: diff,
            pointCount: pointCount,
            stepMs: stepMs,
            durationMs: durationMs,
          );
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
    if (successCount == 0 || elemCount == 0) return null;

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
    return result;
  }

  static void _applyElems(
    Iterable<DanmakuElem> elems, {
    required List<double> diff,
    required int pointCount,
    required int stepMs,
    required int durationMs,
  }) {
    for (final elem in elems) {
      if (!_isDensityElem(elem)) continue;
      final progress = elem.progress;
      if (progress < 0 || progress > durationMs + densityWindowMs) continue;

      final density = _dispval(elem);
      if (density <= 0) continue;

      final start = (progress / stepMs).floor().clamp(0, pointCount - 1).toInt();
      final end = ((progress + densityWindowMs) / stepMs)
          .floor()
          .clamp(0, pointCount - 1)
          .toInt();

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
