import 'package:flutter/material.dart';
import 'package:stated/stated.dart';
import 'dispose.dart';

typedef BlocBuilderDelegate<T> = Widget Function(
  BuildContext context,
  T bloc,
  Widget? child,
);

typedef BlocBuilderCreateDelegate<T> = T Function(
  BuildContext context,
);

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
