import 'package:flutter/foundation.dart';

/// This only helps to access the protected [notifyListeners].
class Notifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
