import 'package:flutter/cupertino.dart';

/// Generic [Disposer] mixin
/// Allows for the registration of dispose callbacks to be called on dispose
/// Also acts as a decorator to inform the framework the class is disposable
mixin Disposer {
  List<VoidCallback> _disposers = [];

  void addDispose(VoidCallback dispose) {
    _disposers.add(dispose);
  }

  void dispose() {
    _disposers.reversed.forEach((e) => e());
    _disposers.clear();
  }
}
