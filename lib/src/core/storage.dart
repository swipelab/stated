import 'package:stated/src/core/core.dart';

abstract class Storage with AsyncInit, Disposer, Notifier {
  T? get<T>(String path);

  void set<T>(String path, T? value);
}
