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
  /// Returns a synchronously available instance (throws if not initialised
  /// or registered; lazy entries must be warmed by [Register.init]).
  T get<T>();
}

/// Async locator (mainly to enable lazy async)
mixin Resolver {
  /// Resolves (and initialises if lazy) a registered service asynchronously.
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

  /// Registers a pre‑built singleton [instance].
  void add<T>(T instance) => addFactory((e) => InstanceStoreFactory(instance));

  /// Registers a custom factory.
  void addFactory<T>(FactoryDelegate<T> factory) => registry[T] = factory(this);

  /// Registers a lazily created, cached async/sync singleton.
  void addLazy<T>(ResolverCreateDelegate<T> delegate) => addFactory(
        (e) => LazyStoreFactory<T>(resolver: this, delegate: delegate),
      );

  /// Registers a transient factory (new instance each request).
  void addTransient<T>(LocatorCreateDelegate<T> delegate) => addFactory(
        (e) => TransientStoreFactory<T>(locator: this, delegate: delegate),
      );
}

/// Concrete store implementing locator + resolver behaviour.
///
/// {@tool snippet}
/// ```dart
/// final store = Store()
///   ..add(Logger())
///   ..addLazy<Config>((r) async => Config())
///   ..addTransient<DateTime>((l) => DateTime.now());
///
/// await store.init(); // warm lazy singletons
/// final logger = store.get<Logger>(); // sync
/// final config = await store.resolve<Config>(); // async
/// ```
/// {@end-tool}
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

  T? tryGet<T>() {
    try {
      return get<T>();
    } catch (e) {
      return null;
    }
  }
}

class ScopedLocator with Locator {
  ScopedLocator(this.parent);

  Locator parent;

  final Map<Type, StoreFactory> _registry = {};

  @override
  T get<T>() => _registry[T]?.instance ?? parent.get<T>();

  void add<T>(T instance) {
    _registry[T] = InstanceStoreFactory(instance);
  }
}

extension LocatorExtension on Locator {
  ScopedLocator scoped() => ScopedLocator(this);
}
