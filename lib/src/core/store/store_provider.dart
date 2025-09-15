import 'package:flutter/widgets.dart';
import 'package:stated/src/core/core.dart';

/// Provides a [Store] to the widget tree without creating an inherited
/// dependency (safe for `initState` reads).
///
/// Useful extension to be added.
/// extension StoreProviderExtension on BuildContext {
//   /// Shortcut for `StoreProvider.of(context).store.get<T>()`.
//   T get<T>() => StoreProvider.of(this).store.get<T>();
// }
class StoreProvider extends StatelessWidget {
  const StoreProvider({
    required this.store,
    required this.builder,
    Key? key,
  }) : super(key: key);

  final Store store;
  final WidgetBuilder builder;

  static StoreProvider of(BuildContext context) {
    final result = context.findAncestorWidgetOfExactType<StoreProvider>();
    assert(result != null, 'StoreProvider not found');
    return result!;
  }

  @override
  Widget build(BuildContext context) => Builder(builder: builder);
}
