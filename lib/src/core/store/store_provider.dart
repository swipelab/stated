import 'package:flutter/widgets.dart';
import 'package:stated/src/core/core.dart';

/// Provides a [Store] to the widget tree without creating an inherited
/// dependency (safe for `initState` reads).
class StoreProvider extends StatelessWidget {
  StoreProvider({
    required this.store,
    required this.child,
    Key? key,
  }) : super(key: key);

  final Store store;
  final Widget child;

  /// Finds the nearest ancestor [StoreProvider].
  static StoreProvider of(BuildContext context) {
    final result = context.findAncestorWidgetOfExactType<StoreProvider>();
    assert(result != null, 'StoreProvider not found');
    return result!;
  }

  @override
  Widget build(BuildContext context) => child;
}

extension StoreProviderExtension on BuildContext {
  /// Shortcut for `StoreProvider.of(context).store.get<T>()`.
  T get<T>() => StoreProvider.of(this).store.get<T>();
}
