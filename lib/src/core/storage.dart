import 'package:stated/src/core/core.dart';

abstract class Storage with Disposer, Notifier {
  T? get<T>(String path);

  void set<T>(String path, T? value);
}
