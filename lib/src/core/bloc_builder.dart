import 'package:flutter/material.dart';
import 'dispose.dart';

/// Signature for the widget building function used by [BlocBuilder].
typedef BlocBuilderDelegate<T> = Widget Function(
  BuildContext context,
  T bloc,
  Widget? child,
);

/// Signature for the create callback that instantiates the bloc once.
typedef BlocBuilderCreateDelegate<T> = T Function(
  BuildContext context,
);

/// Lightweight life‑cycle helper: creates a bloc/object once and disposes it
/// if it implements [Disposable] or [ChangeNotifier]. Does NOT listen / rebuild
/// automatically – use when you only need construction & disposal wiring.
class BlocBuilder<T> extends StatefulWidget {
  const BlocBuilder({
    /// NOTE: if the create returns a Disposable/ChangeNotifier the `dispose` will be called
    /// when the [BlocBuilder] is disposed
    required this.create,
    required this.builder,
    this.child,
    super.key,
  });

  /// Creates the bloc
  final BlocBuilderCreateDelegate<T> create;

  /// Builds the widget given the created bloc
  final BlocBuilderDelegate<T> builder;
  final Widget? child;

  @override
  State<BlocBuilder<T>> createState() => _BlocBuilderState<T>();
}

class _BlocBuilderState<T> extends State<BlocBuilder<T>> {
  late T bloc;

  @override
  void initState() {
    super.initState();
    bloc = widget.create(context);
  }

  /// Disposes underlying bloc if it supports disposal semantics.
  void _dispose(BlocBuilder<T> widget) {
    final bloc = this.bloc;
    switch (bloc) {
      case Disposable():
        bloc.dispose();
      case ChangeNotifier():
        bloc.dispose();
    }
  }

  @override
  void dispose() {
    _dispose(widget);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      bloc,
      widget.child,
    );
  }
}
