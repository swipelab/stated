import 'package:flutter/foundation.dart';

import 'dispose.dart';
import 'emitter.dart';

/// Minimal synchronous event bus for simple message fan‑out.
///
/// {@tool snippet}
/// ```dart
/// sealed class AppEvent {}
/// class SignedIn extends AppEvent { SignedIn(this.user); final String user; }
/// final bus = Publisher<AppEvent>();
/// bus.on<SignedIn>((e) => print('Hello \\${e.user}'));
/// bus.publish(SignedIn('Alice'));
/// ```
/// {@end-tool}
class Publisher<T> with Dispose {
  final List<ValueSetter> _subscriptions = [];

  /// Adds a raw subscription returning a removal callback.
  VoidCallback subscribe(ValueSetter callback) {
    _subscriptions.add(callback);
    return () => _subscriptions.remove(callback);
  }

  /// Publishes an event to all current subscribers.
  void publish(T msg) {
    for (final subscription in _subscriptions.toList()) {
      subscription(msg);
    }
  }

  /// Filters events of subtype [E]. Optional immediate [callback] plus a
  /// returned [Emitter] for builder/listener integration.
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
