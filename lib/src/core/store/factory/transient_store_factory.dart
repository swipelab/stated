import 'package:stated/src/core/core.dart';
import 'package:stated/src/core/store/factory/store_factory.dart';

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
