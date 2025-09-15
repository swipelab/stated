import 'package:flutter/foundation.dart';

import 'functional.dart';

/// Basic disposable contract.
abstract class Disposable {
  bool get disposed;

  void dispose();
}

/// Mixin that aggregates disposal callbacks. Call [addDispose] to register
/// cleanups; they execute in reverse insertion order when [dispose] is called.
mixin class Dispose implements Disposable {
  /// Registered callbacks executed (reversed) on [dispose].
  final List<VoidCallback> _dispose = [];

  void _assertNotDisposed() {
    assert(() {
      if (disposed) {
        throw FlutterError(
          'A ${runtimeType} was used after being disposed.\n'
          'Once you have called dispose() on a ${runtimeType}, it '
          'can no longer be used.',
        );
      }
      return true;
    }());
  }

  /// Registers a disposal [callback]. Ignored if already disposed.
  void addDispose(VoidCallback callback) {
    _assertNotDisposed();
    if (!disposed) {
      _dispose.add(callback);
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    _assertNotDisposed();

    _disposed = true;
    _dispose
      ..reversed.forEach(call)
      ..clear();
  }

  bool _disposed = false;

  @override
  bool get disposed => _disposed;

  static void object(Object? object) {
    if (object is Disposable) {
      object.dispose();
    } else if (object is ChangeNotifier) {
      object.dispose();
    }
  }
}

extension DisposableDisposerExtension on Disposable {
  /// Adds this object's [dispose] to another [Dispose] collector.
  void disposeBy(Dispose disposer) => disposer.addDispose(dispose);
}
