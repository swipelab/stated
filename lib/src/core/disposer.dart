import 'package:flutter/foundation.dart';

import 'disposable.dart';

/// Generic [Disposer] mixin
/// Allows for the registration of dispose callbacks to be called on dispose
/// Also acts as a decorator to inform the framework the class is disposable
mixin Disposer implements Disposable {
  final List<VoidCallback> _onDispose = [];

  /// Registers callback to be executed on dispose of [Disposer] in reversed insert order
  @mustCallSuper
  void addDispose(VoidCallback onDispose) {
    _onDispose.add(onDispose);
  }

  @mustCallSuper
  void dispose() {
    _onDispose.reversed.forEach((e) => e());
    _onDispose.clear();
  }
}
