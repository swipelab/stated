import 'dart:async';

import 'package:flutter/foundation.dart';

class Debouncer {
  Debouncer({
    required this.duration,
  });

  final Duration duration;
  Timer? timer;

  void run(FutureOr<void> Function() f) {
    timer?.cancel();
    timer = Timer(duration, f);
  }

  void cancel() => timer?.cancel();
}

/// Creates a closure that delays the execution by [duration] the invocation of [f]
/// If the the closure was invoked withing the [duration] again, it would reset the [elapsed] time
VoidCallback debounce(
  FutureOr<void> Function() f, [
  Duration duration = const Duration(milliseconds: 10),
]) {
  final debouncer = Debouncer(duration: duration);
  return () => debouncer.run(f);
}
