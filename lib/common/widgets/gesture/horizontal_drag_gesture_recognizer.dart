import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/gestures.dart';

class CustomHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  CustomHorizontalDragGestureRecognizer({
    super.debugOwner,
    super.supportedDevices,
    super.allowedButtonsFilter,
  });

  Offset? _initialPosition;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    _initialPosition = event.position;
  }

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    return globalDistanceMoved.abs() > _computeHitSlop(pointerDeviceKind) &&
        _cacl(_initialPosition!, lastPosition.global, gestureSettings);
  }

  static bool _cacl(
    Offset initialPosition,
    Offset lastPosition,
    DeviceGestureSettings? gestureSettings,
  ) {
    final offset = lastPosition - initialPosition;
    return offset.dx.abs() > offset.dy.abs() * 3;
  }
}

double touchSlopH = Pref.touchSlopH;

double _computeHitSlop(PointerDeviceKind kind) {
  switch (kind) {
    case PointerDeviceKind.mouse:
      return kPrecisePointerHitSlop;
    case PointerDeviceKind.stylus:
    case PointerDeviceKind.invertedStylus:
    case PointerDeviceKind.unknown:
    case PointerDeviceKind.touch:
    case PointerDeviceKind.trackpad:
      return touchSlopH;
  }
}
