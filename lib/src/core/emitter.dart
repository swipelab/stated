import 'dart:async';

import 'package:flutter/foundation.dart';

import 'dispose.dart';

mixin class Emitter implements Dispose, Listenable {
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

  /// Creates a [LazyEmitter] with the [value] invalidated when any of the [listenables] notifies
  /// NOTE: it only notifies if the new value returned from [fn] differs from previous
  static LazyEmitter<T> map<T>(
      List<Listenable> listenables, ValueGetter<T> fn) {
    final notifier = LazyEmitter<T>(fn);

    listenables
        .map((e) => e.subscribe(notifier.update))
        .forEach(notifier.addDispose);

    return notifier;
  }

  static VoidCallback scheduled(VoidCallback callback) {
    var targetVersion = 0;
    var currentVersion = 0;
    return () {
      if (targetVersion == currentVersion) {
        targetVersion++;
        scheduleMicrotask(() {
          targetVersion = ++currentVersion;
          callback();
        });
      }
    };
  }
}

/// [ScheduledEmitter] allows for the listeners to be notified post frame
/// Usage: Allows for changes during setState of a stateful widget
/// [NOT RECOMMENDED]
class ScheduledEmitter with Emitter {
  ScheduledEmitter();

  late final VoidCallback _scheduledNotifyListeners =
      Emitter.scheduled(super.notifyListeners);

  @override
  void notifyListeners() => _scheduledNotifyListeners();
}

/// Provides public access the [notifyListeners].
class PublicEmitter extends Emitter {
  @override
  void notifyListeners() => super.notifyListeners();
}

class _ChangeNotifier extends ChangeNotifier {
  @override
  void notifyListeners() => super.notifyListeners();

  @override
  bool get hasListeners => super.hasListeners;
}

class ValueEmitter<T> with Emitter implements ValueNotifier<T> {
  ValueEmitter(this._value);

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

class LazyEmitter<T> with Emitter implements ValueListenable<T> {
  LazyEmitter(this.fn);

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
