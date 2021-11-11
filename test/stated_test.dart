import 'package:flutter_test/flutter_test.dart';
import 'package:stated/stated.dart';

void main() {
  test('lazy factory', () async {
    final store = Store();
    int instances = 0;
    store.addLazy<int>((e) async => ++instances);
    expect(await store.resolve<int>(), 1);
    expect(await store.resolve<int>(), 1);
  });

  test('transient factory', () async {
    final store = Store();
    int instances = 0;

    store.addTransient<int>((e) => ++instances);
    expect(await store.resolve<int>(), 1);
    expect(await store.resolve<int>(), 2);
    expect(await store.resolve<int>(), 3);
  });
}
