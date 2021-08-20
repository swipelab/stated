import 'package:flutter/foundation.dart';
import 'tasks.dart';

abstract class Bloc<T> extends ChangeNotifier
    with Tasks
    implements ValueListenable<T> {
  
  @protected
  @nonVirtual
  void setState(VoidCallback callback) {
    callback();

    _value = build();
    notifyListeners();
  }

  T? _value;

  T get value => _value ??= build();

  @protected  
  T build();
}
