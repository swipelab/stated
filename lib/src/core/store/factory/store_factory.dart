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
