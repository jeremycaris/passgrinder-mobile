import 'dart:async';
import 'package:flutter/foundation.dart';

class AutoResetTimer {
  final Duration duration;
  final VoidCallback onReset;
  Timer? _timer;

  AutoResetTimer({
    required this.duration,
    required this.onReset,
  });

  /// Call this on every user interaction to restart the countdown.
  void reset() {
    _timer?.cancel();
    _timer = Timer(duration, () {
      onReset();
    });
  }

  /// Cancel the timer entirely (e.g. when widget is disposed).
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
