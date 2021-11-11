import 'package:flutter/foundation.dart';
import 'package:stated/src/core/core.dart';

abstract class Bloc<T> extends Observable implements ValueListenable<T> {
  @protected
  @nonVirtual
  void setState([VoidCallback? callback]) {
    callback?.call();
    _value = null;
    notify();
  }

  T? _value;

  T get value => _value ??= build();

  @protected
  T build();
}
