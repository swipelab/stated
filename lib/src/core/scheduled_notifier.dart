import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core.dart';

typedef NotifierCallback = FutureOr<void> Function();

/// UI friendly implementation of Listenable
/// ChangeNotifier notifies listeners a bit too eagerly
/// Ensures that Listeners will not be notified more than once using [notifyListeners] per frame
mixin ScheduledNotifier implements Listenable {
  VoidCallback? __notify;

  VoidCallback get _notify =>
      __notify ??= Tasks.scheduled(this._notifyListeners);

  @protected
  @mustCallSuper
  void notifyListeners([NotifierCallback? callback]) async {
    await callback?.call();
    _notify();
  }

  List<VoidCallback> _listeners = [];

  @protected
  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    if (_listeners.isEmpty) return;

    final localListeners = _listeners.toList();
    for (final entry in localListeners) {
      try {
        entry();
      } catch (_) {}
    }
  }
}
