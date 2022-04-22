import 'package:flutter/widgets.dart';
import 'package:stated/src/core/core.dart';

typedef ListenableBuilderCreate<T extends Listenable> = T Function(
  BuildContext context,
);
typedef ListenableBuilderDelegate<T extends Listenable> = Widget Function(
  BuildContext context,
  T listenable,
  Widget? child,
);

/// A similar construct like Flutter's [AnimationBuilder] that also
/// provides the [listenable] via the [builder] delegate.
/// This can be useful when a complex expression is needed
/// to resolve the [listenable] instance.
/// Eg:
/// ListenableBuilder.value(
///   listenable: context.read<SomeListenable>(),
///   builder: (context, listenable, child) => Widget(listenable),
/// )
class ListenableBuilder<T extends Listenable> extends StatefulWidget {
  ListenableBuilder({
    required ListenableBuilderCreate<T> create,
    required this.builder,
    this.child,
    Key? key,
  })  : _create = create,
        _listenable = null,
        super(key: key);

  ListenableBuilder.value({
    required T listenable,
    required this.builder,
    this.child,
    Key? key,
  })  : _listenable = listenable,
        _create = null,
        super(key: key);

  final T? _listenable;

  final ListenableBuilderCreate<T>? _create;

  final ListenableBuilderDelegate<T> builder;

  final Widget? child;

  @override
  _ListenableBuilderState<T> createState() => _ListenableBuilderState<T>();
}

class _ListenableBuilderState<T extends Listenable>
    extends State<ListenableBuilder<T>> {
  late T listenable;

  @override
  void initState() {
    super.initState();
    listenable = widget._listenable ?? widget._create!(context);
  }

  @override
  void didUpdateWidget(covariant ListenableBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget._listenable != widget._listenable) {
      oldWidget._listenable?.removeListener(_notify);
      widget._listenable?.addListener(_notify);
    }
  }

  void _notify() => setState(() {});

  bool get _isCreated => widget._listenable == null;

  @override
  void dispose() {
    listenable.removeListener(_notify);
    if (_isCreated && listenable is Disposable) {
      (listenable as Disposable).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      listenable,
      widget.child,
    );
  }
}
