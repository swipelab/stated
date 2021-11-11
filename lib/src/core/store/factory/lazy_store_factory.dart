import 'package:stated/src/core/core.dart';

class LazyStoreFactory<T> extends StoreFactory<T> {
  LazyStoreFactory({
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
        await instance.init();
      }
      _instance = instance;
    }
    return _instance!;
  }

  @override
  T get instance => _instance == null
      ? throw Exception('Service not initialized: $T')
      : _instance!;
}
