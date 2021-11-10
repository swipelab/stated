import 'package:flutter/foundation.dart';
import 'package:provider/single_child_widget.dart';
import 'package:stated/src/core/store/factory/legacy_provider.dart';
import 'package:stated/src/core/store/store.dart';



class InstanceListenableStoreFactory<T extends Listenable>
    implements StoreFactory<T> {
  InstanceListenableStoreFactory(T value) : _value = value;

  final T _value;

  Future<T> get future async => _value;

  @override
  T get instance => _value;

  @override
  SingleChildWidget get provider => legacyListenableProvider(instance);
}
