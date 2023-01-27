import 'package:stated/src/core/core.dart';

extension DisposableDisposerExtension on Disposable {
  void disposeBy(Disposer disposer) {
    disposer.addDispose(dispose);
  }
}
