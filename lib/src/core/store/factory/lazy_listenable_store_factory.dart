import 'package:flutter/foundation.dart';
import 'package:provider/single_child_widget.dart';
import 'package:stated/src/core/core.dart';
import 'package:stated/src/core/store/factory/legacy_provider.dart';

class LazyListenableStoreFactory<T extends Listenable>
    implements StoreFactory<T> {
  LazyListenableStoreFactory({
    required this.resolver,
    required this.delegate,
  });

  final ResolverCreateDelegate<T> delegate;
  final Resolver resolver;
  T? _instance;

  Future<T> get future async {
    if (_instance == null) {
      final instance = await delegate(resolver);
      if (instance is AsyncInit) {
        await (instance as AsyncInit).init();
      }
      _instance = instance;
    }
    return _instance!;
  }

  @override
  T get instance => _instance == null
      ? throw Exception('Service not initialized: $T')
      : _instance!;

  @override
  SingleChildWidget get provider => legacyListenableProvider(instance);
}
