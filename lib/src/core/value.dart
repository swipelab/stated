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
  Disposable link(ValueEmitter<double> other) {
    final it = this;
    final diposer = Dispose();

    void intoOther() {
      if (other.value == it.value) return;
      other.value = it.value;
    }

    void intoIt() {
      if (other.value == it.value) return;
      it.value = other.value;
    }

    it.subscribe(intoOther).disposeBy(diposer);
    other.subscribe(intoIt).disposeBy(diposer);

    intoIt();

    return diposer;
  }
}
