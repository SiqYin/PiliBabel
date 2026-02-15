import 'package:flutter/gestures.dart'
    show TapGestureRecognizer, PointerDownEvent, DoubleTapGestureRecognizer;

class ImageTapGestureRecognizer extends TapGestureRecognizer {
  ImageTapGestureRecognizer({
    super.debugOwner,
    super.supportedDevices,
    super.allowedButtonsFilter,
    super.preAcceptSlopTolerance,
    super.postAcceptSlopTolerance,
  });

  int? _pointer;

  @override
  void addPointer(PointerDownEvent event) {
    if (_pointer == event.pointer) {
      return;
    }
    _pointer = event.pointer;
    super.addPointer(event);
  }
}

class ImageDoubleTapGestureRecognizer extends DoubleTapGestureRecognizer {
  ImageDoubleTapGestureRecognizer({
    super.debugOwner,
    super.supportedDevices,
    super.allowedButtonsFilter,
  });

  int? _pointer;

  @override
  void addPointer(PointerDownEvent event) {
    if (_pointer == event.pointer) {
      return;
    }
    _pointer = event.pointer;
    super.addPointer(event);
  }
}
