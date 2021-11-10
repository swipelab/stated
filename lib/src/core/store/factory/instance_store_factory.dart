import 'package:provider/single_child_widget.dart';
import 'package:stated/src/core/core.dart';
import 'package:stated/src/core/store/factory/legacy_provider.dart';

class InstanceStoreFactory<T> implements StoreFactory<T> {
  InstanceStoreFactory(T value) : _value = value;

  final T _value;

  Future<T> get future async => _value;

  @override
  T get instance => _value;

  @override
  SingleChildWidget get provider => legacyValueProvider(instance);
}
