import 'package:stated/src/core/core.dart';

/// Always produces a fresh instance on access.
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

  @override
  String toString() => 'Transient $T';
}
