import 'package:provider/single_child_widget.dart';
import 'package:stated/src/core/core.dart';
import 'package:stated/src/core/store/factory/legacy_provider.dart';

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
  SingleChildWidget get provider => legacyValueProvider(instance);
}
