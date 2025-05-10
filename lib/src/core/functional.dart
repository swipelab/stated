typedef Callback<T> = T Function();
typedef Predicate<T> = bool Function(T e);

extension IterableFunctional<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E e) test) {
    for (final item in this) {
      if (test(item)) {
        return item;
      }
    }
    return null;
  }
}

extension ObjectFunctional<T> on T {
  R pipe<R>(R Function(T e) e) => e(this);
}

T self<T>(T e) => e;

void call<T>(Callback<T> e) => e();
