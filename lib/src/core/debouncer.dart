import 'dart:async';

import 'package:flutter/foundation.dart';

/// Utility that delays execution of the last scheduled callback until
/// [duration] has elapsed without a new schedule.
class Debouncer {
  Debouncer({
    required this.duration,
  });

  final Duration duration;
  Timer? timer;

  /// Schedules [f] to run after [duration]; resets the timer if called again.
  void run(FutureOr<void> Function() f) {
    timer?.cancel();
    timer = Timer(duration, f);
  }

  /// Cancels a pending scheduled callback, if any.
  void cancel() => timer?.cancel();
}

/// Returns a closure that debounces calls to [f] by [duration]. Re‑invocation
/// resets the timer. Useful for text search, resize, etc.
VoidCallback debounce(
  FutureOr<void> Function() f, [
  Duration duration = const Duration(milliseconds: 10),
]) {
  final debouncer = Debouncer(duration: duration);
  return () => debouncer.run(f);
}
