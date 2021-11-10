import 'package:flutter/foundation.dart';

extension ListenableExtension on Listenable {
  /// returns closure to remove the listener ([callback])
  VoidCallback subscribe(VoidCallback callback) {
    addListener(callback);
    return () => removeListener(callback);
  }
}
