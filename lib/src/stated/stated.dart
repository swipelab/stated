import 'package:flutter/foundation.dart';
import 'package:stated/src/core/core.dart';
import 'package:stated/src/stated/stated_builder.dart';

/// A Custom [ValueListenable] implementation
/// Can be used in with [ListenableBuilder] or [StatedBuilder]
/// The [value] is never assigned directly, but rather built using [buildState]
abstract class Stated<T> with Emitter, Tasks implements ValueListenable<T> {
  /// The current value of the [Stated].
  T? _value;

  /// The current value of the [Stated].
  /// If [value] is null, [buildState] is called to build the value.
  T get value => _value ??= buildState();

  /// This methods needs to be overridden to produce [value].
  @protected
  T buildState();

  /// After the [callback] it produces the [value].
  /// Notifies listeners only when [value] changes.
  @override
  @protected
  @mustCallSuper
  void notifyListeners([VoidCallback? callback]) async {
    callback?.call();
    final oldValue = _value;
    _value = buildState();

    if (oldValue != _value) {
      super.notifyListeners();
    }
  }

  @mustCallSuper
  @override
  void dispose() {
    disposeTasks();
    super.dispose();
  }
}
