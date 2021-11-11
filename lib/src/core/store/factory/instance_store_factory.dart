import 'package:stated/src/core/core.dart';

class InstanceStoreFactory<T> implements StoreFactory<T> {
  InstanceStoreFactory(T value) : _value = value;

  final T _value;

  Future<T> get future async => _value;

  @override
  T get instance => _value;

  @override
  R pipeInstance<R>(R Function<T>(T instance) fn) => (fn as dynamic)<T>(instance);
}
