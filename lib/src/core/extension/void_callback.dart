import 'package:flutter/material.dart';
import 'package:stated/src/core/core.dart';

extension VoidCallbackExtension on VoidCallback {
  void disposeBy(Disposer disposer) {
    disposer.addDispose(this);
  }
}