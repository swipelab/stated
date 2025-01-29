import 'package:flutter/foundation.dart';
import 'package:stated/src/rx/rx.dart';

import 'dispose.dart';

mixin class Notifier implements Dispose, Listenable {
  final Dispose _dispose = Dispose();
  final _ChangeNotifier _notifier = _ChangeNotifier();

  @override
  @mustCallSuper
  void addDispose(VoidCallback callback) => _dispose.addDispose(callback);

  @override
  @mustCallSuper
  void addListener(VoidCallback listener) {
    _notifier.addListener(listener);
  }

  @override
  @mustCallSuper
  void removeListener(VoidCallback listener) {
    _notifier.removeListener(listener);
  }

  @protected
  void notifyListeners() => _notifier.notifyListeners();

  @override
  @mustCallSuper
  void dispose() {
    _dispose.dispose();
    _notifier.dispose();
  }

  @override
  bool get disposed => _dispose.disposed;

  bool get hasListeners => _notifier.hasListeners;
}

/// [ScheduledNotifier] allows for the listeners to be notified post frame
/// Usage: Allows for changes during setState of a stateful widget
/// [NOT RECOMMENDED]
class ScheduledNotifier with Notifier {
  ScheduledNotifier();

  late final VoidCallback _scheduledNotifyListeners = Rx.scheduled(
      super.notifyListeners);

  @override
  void notifyListeners() => _scheduledNotifyListeners();
}

/// Provides public access the [notifyListeners].
class PublicNotifier extends Notifier {
  @override
  void notifyListeners() => super.notifyListeners();
}

class _ChangeNotifier extends ChangeNotifier {
  @override
  void notifyListeners() => super.notifyListeners();

  @override
  bool get hasListeners => super.hasListeners;
}

class NotifierOf<T> with Notifier implements ValueNotifier<T> {
  NotifierOf(this._value);

  T _value;

  @override
  T get value => _value;

  @override
  set value(T newValue) {
    if (_value == newValue) {
      return;
    }
    _value = newValue;
    notifyListeners();
  }
}

class LazyNotifier<T> with Notifier implements ValueListenable<T> {
  LazyNotifier(this.fn);

  final ValueGetter<T> fn;

  void update() {
    if (!hasListeners) return;

    final newValue = fn();
    if (newValue == _value) {
      return;
    }
    _value = newValue;
    notifyListeners();
  }

  T? _value;

  @override
  T get value => _value ??= fn();
}

extension ListenableExtension on Listenable {
  /// returns closure to remove the listener ([callback])
  VoidCallback subscribe(VoidCallback callback) {
    addListener(callback);
    return () => removeListener(callback);
  }
}

extension VoidCallbackExtension on VoidCallback {
  /// When creating subscriptions that can be disposed using a callback we can add them to a [Dispose]
  void disposeBy(Dispose disposer) {
    disposer.addDispose(this);
  }
}
