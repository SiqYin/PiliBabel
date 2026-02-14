import 'package:PiliPlus/common/widgets/gesture/horizontal_drag_gesture_recognizer.dart';
import 'package:flutter/gestures.dart';

typedef IsBoundaryAllowed =
    bool Function(Offset? initialPosition, OffsetPair lastPosition);

class ImageHorizontalDragGestureRecognizer
    extends CustomHorizontalDragGestureRecognizer {
  ImageHorizontalDragGestureRecognizer({
    super.debugOwner,
    super.supportedDevices,
    super.allowedButtonsFilter,
  });

  IsBoundaryAllowed? isBoundaryAllowed;

  int? _pointer;

  @override
  void addPointer(PointerDownEvent event) {
    if (_pointer == event.pointer) {
      return;
    }
    _pointer = event.pointer;
    super.addPointer(event);
  }

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    return super.hasSufficientGlobalDistanceToAccept(
          pointerDeviceKind,
          deviceTouchSlop,
        ) &&
        (isBoundaryAllowed?.call(initialPosition, lastPosition) ?? true);
  }

  @override
  void dispose() {
    isBoundaryAllowed = null;
    super.dispose();
  }
}
