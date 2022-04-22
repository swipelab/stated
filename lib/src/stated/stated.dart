import 'package:flutter/foundation.dart';
import 'package:stated/src/core/core.dart';
import 'package:stated/src/stated/stated_builder.dart';

/// A Custom ValueListenable implementation
/// Can be used in with [ListenableBuilder] or [StatedBuilder]
/// The [value] is never assigned directly, but rather built using with [build]
abstract class Stated<T> implements Disposable, ValueListenable<T> {
  Stated({
    T? initialState,
    bool withHistory = false,
  }) : _withHistory = withHistory {
    _value = _nextValue(initialState);

    if (_withHistory && initialState != null) {
      history.add(initialState);
    }
  }

  final _Notifier _notifier = _Notifier();

  /// Enables history for produced values with [build]
  final bool _withHistory;

  /// After the [callback], produces the [value] and notifies listeners
  @protected
  @mustCallSuper
  void setState([VoidCallback? callback]) async {
    callback?.call();
    _value = _nextValue();
    _notifier.notify();
  }

  @override
  @mustCallSuper
  void addListener(VoidCallback callback) {
    _notifier.addListener(callback);
  }

  @override
  @mustCallSuper
  void removeListener(VoidCallback callback) {
    _notifier.removeListener(callback);
  }

  @mustCallSuper
  @override
  void dispose() {}

  T? _value;

  T get value => _value ??= _nextValue();

  /// This methods needs to be overridden to produce [value]
  @protected
  T build();

  /// Builds the [value] and keeps track of all produced [value]s.
  /// This can help with testing.
  T _nextValue([T? value]) {
    final nextValue = value ?? build();
    if (_withHistory) history.add(nextValue);
    return nextValue;
  }

  /// When [withHistory]==true we keep all the produced [value]s here.
  List<T> history = [];
}

class _Notifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
