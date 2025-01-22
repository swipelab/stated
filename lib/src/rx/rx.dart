import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stated/src/core/core.dart';

abstract class Rx {
  /// Creates a ValueListenable with the [value] invalidated when any of the [listenables] notifies
  /// NOTE: it only notifies if the new value returned from [fn] differs from previous
  static LazyNotifier<T> map<T>(
      List<Listenable> listenables, ValueGetter<T> fn) {
    final notifier = LazyNotifier<T>(fn);

    listenables
        .map((e) => e.subscribe(notifier.update))
        .forEach(notifier.addDispose);

    return notifier;
  }

  static VoidCallback scheduled(VoidCallback callback) {
    var targetVersion = 0;
    var currentVersion = 0;
    return () {
      if (targetVersion == currentVersion) {
        targetVersion++;
        scheduleMicrotask(() {
          targetVersion = ++currentVersion;
          callback();
        });
      }
    };
  }
}
