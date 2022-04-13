import 'package:flutter/foundation.dart';
import 'package:stated/src/core/core.dart';

///
abstract class Stated<T> with Disposer, Notifier implements ValueListenable<T> {
  @protected
  @nonVirtual
  @override
  void notifyListeners([VoidCallback? callback]) {
    callback?.call();
    _value = null;
    super.notifyListeners();
  }

  T? _value;

  T get value => _value ??= build();

  @protected
  T build();
}
