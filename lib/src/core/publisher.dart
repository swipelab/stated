import 'package:flutter/foundation.dart';

import 'dispose.dart';
import 'emitter.dart';

class Publisher<T> with Dispose {
  final List<ValueSetter> _subscriptions = [];

  VoidCallback subscribe(ValueSetter callback) {
    _subscriptions.add(callback);
    return () => _subscriptions.remove(callback);
  }

  void publish(T msg) {
    for (final subscription in _subscriptions.toList()) {
      subscription(msg);
    }
  }

  Emitter on<E extends T>([ValueSetter<E>? callback]) {
    final notifier = PublicEmitter();
    subscribe((e) {
      if (e is E) {
        callback?.call(e);
        notifier.notifyListeners();
      }
    }).disposeBy(notifier);
    return notifier;
  }
}
