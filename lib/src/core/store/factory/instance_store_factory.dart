import 'package:stated/src/core/store/factory/store_factory.dart';

class InstanceStoreFactory<T> extends StoreFactory<T> {
  InstanceStoreFactory(T value) : _value = value;

  final T _value;

  Future<T> get future async => _value;

  @override
  T get instance => _value;
}
