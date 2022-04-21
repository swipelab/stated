import 'package:flutter/widgets.dart';
import 'package:stated/src/stated/stated.dart';

typedef StatedBuilderDelegate<T> = Widget Function(
  BuildContext context,
  T state,
  Widget? child,
);

class StatedBuilder<T> extends StatefulWidget {
  const StatedBuilder({
    Key? key,
    required this.create,
    required this.builder,
    this.child,
  }) : super(key: key);

  final Stated<T> Function(BuildContext context) create;

  final StatedBuilderDelegate<T> builder;

  final Widget? child;

  @override
  _StatedBuilderState<T> createState() => _StatedBuilderState<T>();
}

class _StatedBuilderState<T> extends State<StatedBuilder<T>> {
  late Stated<T> bloc;

  @override
  void initState() {
    super.initState();
    bloc = widget.create(context)..addListener(_notify);
  }

  void _notify() => setState(() {});

  @override
  void dispose() {
    bloc
      ..removeListener(_notify)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      bloc.value,
      widget.child,
    );
  }
}
