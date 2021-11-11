import 'package:stated/src/core/store/factory/instance_store_factory.dart';
import 'package:stated/src/core/store/factory/lazy_store_factory.dart';
import 'package:stated/src/core/store/factory/transient_store_factory.dart';

typedef LocatorCreateDelegate<T> = T Function(Locator e);
typedef ResolverCreateDelegate<T> = Future<T> Function(Resolver e);
typedef FactoryDelegate<T> = StoreFactory<T> Function(Resolver e);

/// Sync locator
mixin Locator {
  T get<T>();
}

/// Async locator (mainly to enable lazy async)
mixin Resolver {
  Future<T> resolve<T>();
}

/// Decorator for [StoreFactory]
/// It will emit a new instance each time it's requested
/// Note: This is not an enforcement, only a hint
mixin TransientFactory {}

abstract class StoreFactory<T> {
  /// Enables [Resolves] usage
  Future<T> get future;

  /// Enables [Locator] usage
  T get instance;

  /// A little workaround to retain T on the caller side
  R pipeInstance<R>(R Function<T>(T instance) fn) => fn<T>(instance);
}

mixin Register on Resolver, Locator {
  Map<Type, StoreFactory> registry = {};

  /// Activates registered factories (except [TransientFactory])
  /// This will enable a safe use of [Locator.get]
  Future<void> init() async {
    await Future.wait(registry.values
        .where((e) => !(e is TransientFactory))
        .map((e) => e.future));
  }

  void add<T>(T instance) {
    addFactory((e) => InstanceStoreFactory(instance));
  }

  void addFactory<T>(FactoryDelegate<T> factory) => registry[T] = factory(this);

  void addLazy<T>(ResolverCreateDelegate<T> delegate) =>
      addFactory((e) => LazyStoreFactory<T>(
            resolver: this,
            delegate: delegate,
          ));

  void addTransient<T>(LocatorCreateDelegate<T> delegate) {
    addTransient((e) => TransientStoreFactory(
          locator: this,
          delegate: delegate,
        ));
  }
}

class Store with Locator, Resolver, Register {
  @override
  Future<T> resolve<T>() {
    final entry = registry[T];
    if (entry == null) {
      throw Exception('Service not registered: $T');
    }
    return entry.future as Future<T>;
  }

  @override
  T get<T>() {
    final entry = registry[T];
    if (entry == null) {
      throw Exception('Service not registered: $T');
    }
    return entry.instance as T;
  }
}
