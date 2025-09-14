/// Decorator for [StoreFactory]
/// It will emit a new instance each time it's requested
/// Note: This is not an enforcement, only a hint
/// Marker mixin indicating a factory yields transient (non-cached) instances.
mixin TransientFactory {}

abstract class StoreFactory<T> {
  /// Future for async resolution / warm-up path.
  Future<T> get future;

  /// Synchronous instance access (may throw if not ready for lazy types).
  T get instance;

  /// Passes strongly typed instance to [fn] while retaining generic [T].
  R pipeInstance<R>(R Function<T>(T instance) fn) => fn<T>(instance);
}
