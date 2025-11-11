const kEpsilon = 0.001;

/// Generic function taking no params returning [T].
typedef Callback<T> = T Function();

/// Truthy test used across selection APIs.
typedef Predicate<T> = bool Function(T e);

extension ObjectFunctional<T> on T {
  /// Functional pipe: `value.pipe(fn)` -> `fn(value)`.
  R pipe<R>(R Function(T e) e) => e(this);
}

/// Identity helper (returns input unchanged).
T self<T>(T e) => e;

/// Executes a zero‑arg [Callback].
void call<T>(Callback<T> e) => e();
