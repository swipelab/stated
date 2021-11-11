import 'package:stated/src/core/core.dart';

class TransientStoreFactory<T>
    with TransientFactory
    implements StoreFactory<T> {
  TransientStoreFactory({
    required this.locator,
    required this.delegate,
  });

  final LocatorCreateDelegate<T> delegate;
  final Locator locator;

  Future<T> get future async => instance;

  @override
  T get instance => delegate(locator);

  @override
  R pipeInstance<R>(R Function<T>(T instance) fn) =>
      (fn as dynamic)<T>(instance);
}
