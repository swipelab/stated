import 'package:flutter/foundation.dart';
import 'package:stated/src/core/core.dart';
import 'package:stated/src/stated/stated_builder.dart';

/// Base class for view models exposing a lazily built immutable state value.
/// Use with [ListenableBuilder] / [StatedBuilder]. Call [notifyListeners]
/// with an optional mutation callback to rebuild & emit only on value change.
///
/// {@tool snippet}
/// Simple counter bloc using [Stated] and consumed via [StatedBuilder].
/// ```dart
/// class CounterState { const CounterState(this.count); final int count; }
/// class CounterBloc extends Stated<CounterState> {
///   int _count = 0;
///   void increment() => notifyListeners(() => _count++);
///   @override CounterState buildState() => CounterState(_count);
/// }
///
/// Widget build(BuildContext context) => StatedBuilder<CounterBloc>(
///   create: (_) => CounterBloc(),
///   builder: (_, bloc, __) => Text('Count: \\${bloc.value.count}'),
/// );
/// ```
/// {@end-tool}
abstract class Stated<T> with Emitter, Tasks implements ValueListenable<T> {
  /// The current value of the [Stated].
  T? _value;

  /// The current value of the [Stated].
  /// If [value] is null, [buildState] is called to build the value.
  T get value => _value ??= buildState();

  /// Override to build the derived state snapshot.
  @protected
  T buildState();

  /// Runs optional [callback], rebuilds state; notifies only if new value
  /// differs (using `==`).
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
