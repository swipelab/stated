import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import 'dispose.dart';
import 'emitter.dart';

mixin Value<T> {
  set value(T value);

  T get value;
}

class DelegatedValue<T> with Dispose, Value<T> {
  DelegatedValue({required this.setter, required this.getter});

  final ValueSetter<T> setter;
  final ValueGetter<T> getter;

  @override
  set value(T value) => setter(value);

  @override
  T get value => getter();
}

extension ValueAnimationControllerExtension on AnimationController {
  DelegatedValue<double> delegate() {
    return DelegatedValue<double>(
      setter: (e) => value = e,
      getter: () => value,
    );
  }

  // creates a two way link with a ValueEmitter
  DelegatedValue<double> link(ValueEmitter<double> other) {
    final it = delegate();

    void intoOther() {
      if (other.value == it.value) return;
      other.value = it.value;
    }

    void intoIt() {
      if (other.value == it.value) return;
      it.value = other.value;
    }

    subscribe(intoOther).disposeBy(it);
    other.subscribe(intoIt).disposeBy(it);

    return it;
  }
}
