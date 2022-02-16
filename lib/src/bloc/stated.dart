import 'package:flutter/foundation.dart';
import 'package:stated/src/core/core.dart';

abstract class Stated<T> extends Observable implements ValueListenable<T> {
  @protected
  @nonVirtual
  void setState([VoidCallback? callback]) {
    callback?.call();
    _value = null;
    notifyListeners();
  }

  T? _value;

  T get value => _value ??= build();

  @protected
  T build();
}
