import 'package:flutter/foundation.dart';
import 'package:stated/src/core/core.dart';
import 'package:stated/src/stated/stated_builder.dart';

/// A Custom [ValueListenable] implementation
/// Can be used in with [ListenableBuilder] or [StatedBuilder]
/// The [value] is never assigned directly, but rather built using [build]
abstract class Stated<T>
    with Disposable, Tasks
    implements ValueListenable<T>, Disposer {
  final Notifier _notifier = Notifier();
  final _disposer = ReverseDisposer();

  /// The current value of the [Stated].
  T? _value;

  /// The current value of the [Stated].
  /// If [value] is null, [build] is called to build the value.
  T get value => _value ??= build();

  /// This methods needs to be overridden to produce [value].
  @protected
  T build();

  /// After the [callback] it produces the [value].
  /// Notifies listeners only when [value] changes.
  @protected
  @mustCallSuper
  void setState([VoidCallback? callback]) async {
    callback?.call();
    final oldValue = _value;
    _value = build();

    if (oldValue != _value) {
      _notifier.notify();
    }
  }

  @mustCallSuper
  @override
  void addDispose(VoidCallback callback) => _disposer.addDispose(callback);

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
  void dispose() {
    disposeTasks();
    _disposer.dispose();
    _notifier.dispose();
  }
}
