import 'package:flutter/foundation.dart';

/// Generic [Disposer] mixin
/// Allows for the registration of dispose callbacks to be called on dispose
/// Also acts as a decorator to inform the framework the class is disposable
abstract class Disposer {
  void addDispose(VoidCallback disposeCallback);
}

class ReverseDisposer with Disposer {
  final List<VoidCallback> _disposers = [];

  /// Registers callback to be executed on dispose of [Disposer] in reversed insert order
  void addDispose(VoidCallback callback) {
    _disposers.add(callback);
  }

  void dispose() {
    _disposers.reversed.forEach((e) => e());
    _disposers.clear();
  }
}
