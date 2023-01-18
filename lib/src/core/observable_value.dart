import 'package:flutter/foundation.dart';
import 'package:stated/src/core/core.dart';

abstract class ObservableValue<T> extends ValueListenable<T>
    with Disposable
    implements Listenable {
  final _notifier = Notifier();

  @override
  void addListener(VoidCallback listener) {
    _notifier.addListener(listener);
  }

  @override
  void dispose() {
    _notifier.dispose();
  }

  @override
  void removeListener(VoidCallback listener) {
    _notifier.removeListener(listener);
  }

  @protected
  void notifyListeners() => _notifier.notify();
}
