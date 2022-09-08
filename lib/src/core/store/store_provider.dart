import 'package:flutter/widgets.dart';
import 'package:stated/src/core/core.dart';

/// This will not add a widget dependency, hence allowing for use during initState
class StoreProvider extends StatelessWidget {
  StoreProvider({
    required this.store,
    required this.child,
    Key? key,
  }) : super(key: key);

  final Store store;
  final Widget child;

  static StoreProvider of(BuildContext context) {
    final result = context.findAncestorWidgetOfExactType<StoreProvider>();
    assert(result != null, 'StoreProvider not found');
    return result!;
  }

  @override
  Widget build(BuildContext context) => child;
}

extension StoreProviderExtension on BuildContext {
  T get<T>() => StoreProvider.of(this).store.get<T>();
}
