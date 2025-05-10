import 'package:stated/src/core/store/factory/instance_store_factory.dart';
import 'package:stated/src/core/store/factory/lazy_store_factory.dart';
import 'package:stated/src/core/store/factory/store_factory.dart';
import 'package:stated/src/core/store/factory/transient_store_factory.dart';

export 'package:stated/src/core/store/factory/instance_store_factory.dart';
export 'package:stated/src/core/store/factory/lazy_store_factory.dart';
export 'package:stated/src/core/store/factory/store_factory.dart';
export 'package:stated/src/core/store/factory/transient_store_factory.dart';

typedef LocatorCreateDelegate<T> = T Function(Locator e);
typedef ResolverCreateDelegate<T> = Future<T> Function(Resolver e);
typedef FactoryDelegate<T> = StoreFactory<T> Function(Resolver e);

/// Sync locator
mixin Locator {
  /// This cannot be used before the store is initialised
  /// Due to the fact services may implement [AsyncInit]
  T get<T>();
}

/// Async locator (mainly to enable lazy async)
mixin Resolver {
  Future<T> resolve<T>();
}

mixin Register on Resolver, Locator {
  Map<Type, StoreFactory> registry = {};

  /// Activates registered factories (except [TransientFactory])
  /// This will enable a safe use of [Locator.get]
  Future<void> init() async {
    await Future.wait<void>(
      registry.values.map((e) => e.future),
    );
  }

  void add<T>(T instance) {
    addFactory(
          (e) => InstanceStoreFactory(instance),
    );
  }

  void addFactory<T>(FactoryDelegate<T> factory) => registry[T] = factory(this);

  void addLazy<T>(ResolverCreateDelegate<T> delegate) =>
      addFactory(
            (e) =>
            LazyStoreFactory<T>(
              resolver: this,
              delegate: delegate,
            ),
      );

  void addTransient<T>(LocatorCreateDelegate<T> delegate) =>
      addFactory(
            (e) =>
            TransientStoreFactory<T>(
              locator: this,
              delegate: delegate,
            ),
      );
}

class Store with Locator, Resolver, Register {
  @override
  Future<T> resolve<T>() async {
    final entry = registry[T];
    if (entry == null) {
      throw Exception('$T is not registered (Store)');
    }
    final instance = await (entry.future as Future<T>);
    return instance;
  }

  @override
  T get<T>() {
    final entry = registry[T];
    if (entry == null) {
      throw Exception('$T is not registered (Store)');
    }
    return entry.instance as T;
  }
}
