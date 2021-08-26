import 'package:flutter/foundation.dart';
import 'tasks.dart';

abstract class Bloc<T> extends ChangeNotifier
    with Tasks
    implements ValueListenable<T> {
  Bloc() {
    _notify = Tasks.scheduled(notifyListeners);
  }

  late VoidCallback _notify;

  @protected
  @nonVirtual
  void setState([VoidCallback? callback]) {
    callback?.call();
    _value = null;
    _notify();
  }

  T? _value;

  T get value => _value ??= build();

  @protected
  T build();

  @override
  @mustCallSuper
  void dispose() {
    closeTasks();
    super.dispose();
  }
}
