import 'package:flutter/foundation.dart';
import 'package:stated/src/core/core.dart';

abstract class Rx {
  /// Creates a ValueListenable with the [value] invalidated when any of the [listenables] notifies
  /// NOTE: it only notifies if the new value returned from [fn] differs from previous
  static RxNotifier<T> map<T>(List<Listenable> listenables, ValueGetter<T> fn) {
    final notifier = RxNotifier<T>._(fn);

    final subs = listenables.map((e) => e.subscribe(notifier._update)).toList();
    notifier._onDispose = () {
      for (final sub in subs) {
        sub();
      }
    };

    return notifier;
  }
}

class RxNotifier<T> implements ValueListenable<T>, Disposable {
  RxNotifier._(this.fn);

  final ValueGetter<T> fn;
  final Notifier _notifier = Notifier();
  VoidCallback? _onDispose;

  void _update() {
    final newValue = fn();
    if (newValue == _value) {
      return;
    }
    _value = newValue;
    _notifier.notify();
  }

  @override
  void addListener(VoidCallback listener) {
    _notifier.addListener(listener);
  }

  @override
  void dispose() {
    _onDispose?.call();
    _notifier.dispose();
  }

  @override
  void removeListener(VoidCallback listener) {
    _notifier.removeListener(listener);
  }

  T? _value;

  @override
  T get value => _value ??= fn();
}
