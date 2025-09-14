import 'package:stated/src/core/store/factory/store_factory.dart';

/// Factory wrapping a pre-instantiated singleton.
class InstanceStoreFactory<T> extends StoreFactory<T> {
  InstanceStoreFactory(T value) : _value = value;

  final T _value;

  Future<T> get future async => _value;

  @override
  T get instance => _value;

  @override
  String toString() => 'Instance: $T ${instance.runtimeType}';
}
