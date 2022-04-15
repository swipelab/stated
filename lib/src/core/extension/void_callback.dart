import 'package:flutter/material.dart';
import 'package:stated/src/core/core.dart';

extension VoidCallbackExtension on VoidCallback {
  /// When creating subscriptions that can be disposed using a callback we can add them to a [Disposer]
  void disposeBy(Disposer disposer) {
    disposer.addDispose(this);
  }
}
