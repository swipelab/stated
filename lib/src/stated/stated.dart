import 'package:flutter/foundation.dart';
import 'package:stated/src/core/core.dart';
import 'package:stated/src/stated/stated_builder.dart';

/// A Custom ValueListenable implementation
/// Can be used in with [ListenableBuilder] or [StatedBuilder]
/// The [value] is never assigned directly, but rather built using with [build]
abstract class Stated<T> with Disposer, Notifier implements ValueListenable<T> {
  Stated({
    bool withHistory = false,
  }) : _withHistory = withHistory;

  /// Enables history for produced values with [build]
  final bool _withHistory;

  /// After the [callback], produces the [value] and [notifyListeners]
  @protected
  @nonVirtual
  @override
  void notifyListeners([NotifierCallback? callback]) async {
    await callback?.call();
    _value = _build();
    super.notifyListeners();
  }

  T? _value;

  T get value => _value ??= _build();

  /// This methods needs to be overridden to produce [value]
  @protected
  T build();

  /// Builds the [value] and keeps track of all produced [value]s.
  /// This can help with testing.
  T _build() {
    final newState = _build();
    if (_withHistory) history.add(newState);
    return newState;
  }

  /// When [withHistory]==true we keep all the produced [value]s here.
  List<T> history = [];
}
