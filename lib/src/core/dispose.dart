import 'package:flutter/foundation.dart';

import 'functional.dart';

abstract class Disposable {
  bool get disposed;

  void dispose();
}

mixin class Dispose implements Disposable {
  final List<VoidCallback> _dispose = [];

  _assertNotDisposed() {
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
      ..reversed.forEach(invoke)
      ..clear();
  }

  bool _disposed = false;

  @override
  bool get disposed => _disposed;
}

extension DisposableDisposerExtension on Disposable {
  void disposeBy(Dispose disposer) {
    disposer.addDispose(dispose);
  }
}