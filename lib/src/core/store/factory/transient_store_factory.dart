import 'package:stated/src/core/core.dart';

class TransientStoreFactory<T> extends StoreFactory<T> with TransientFactory {
  TransientStoreFactory({
    required this.locator,
    required this.delegate,
  });

  final LocatorCreateDelegate<T> delegate;
  final Locator locator;

  Future<T> get future async => instance;

  @override
  T get instance => delegate(locator);
}
