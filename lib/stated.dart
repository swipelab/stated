/// stated: small composable primitives for reactive state, async task
/// sequencing, lightweight DI, eventing, and URI pattern parsing.
///
/// Exports core building blocks:
/// - State & builders (`Stated`, `StatedBuilder`, `FutureStatedBuilder`)
/// - Reactive primitives (`Emitter`, `ValueEmitter`, `LazyEmitter`, `ListEmitter`)
/// - Async utilities (`Tasks`, `debounce`, `Debouncer`)
/// - DI container (`Store`, lazy & transient factories, `AsyncInit`)
/// - Event bus (`Publisher`)
/// - URI parsing (`UriParser`, `PathMatcher`)
///
/// See the README for an overview & examples.
library stated;

export 'src/core/core.dart';
export 'src/stated/future_stated_builder.dart';
export 'src/stated/stated.dart';
export 'src/stated/stated_builder.dart';
