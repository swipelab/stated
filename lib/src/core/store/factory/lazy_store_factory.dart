import 'dart:async';

import 'package:stated/src/core/core.dart';
import 'package:stated/src/core/store/factory/store_factory.dart';

class LazyStoreFactory<T> extends StoreFactory<T> {
  LazyStoreFactory({
    required this.resolver,
    required this.delegate,
  });

  final ResolverCreateDelegate<T> delegate;
  final Resolver resolver;
  Completer<T>? _completer;
  T? _instance;

  Future<T> get future async {
    if (_completer == null) {
      _completer = Completer<T>();
      final instance = await delegate(resolver);
      if (instance is AsyncInit) {
        await instance.init();
      }
      _instance = instance;
      _completer!.complete(instance);
    }
    return _completer!.future;
  }

  @override
  T get instance => _instance == null
      ? throw Exception('Service not initialized: $T')
      : _instance!;
}
