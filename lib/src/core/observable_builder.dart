import 'package:flutter/widgets.dart';
import 'package:stated/stated.dart';

typedef ObservableBuilderCtor<T extends Observable> = T Function(
  BuildContext context,
);
typedef ObservableBuilderDelegate<T extends Observable> = Widget Function(
  BuildContext context,
  T state,
  Widget? child,
);

class ObservableBuilder<T extends Observable> extends StatefulWidget {
  const ObservableBuilder({
    Key? key,
    required this.create,
    required this.builder,
    this.child,
  }) : super(key: key);

  final ObservableBuilderCtor<T> create;

  final ObservableBuilderDelegate<T> builder;

  final Widget? child;

  @override
  _ObservableBuilderState<T> createState() => _ObservableBuilderState<T>();
}

class _ObservableBuilderState<T extends Observable>
    extends State<ObservableBuilder<T>> {
  late T listenable;

  @override
  void initState() {
    super.initState();
    listenable = widget.create(context)..addListener(_notify);
  }

  void _notify() => setState(() {});

  @override
  void dispose() {
    listenable
      ..removeListener(_notify)
      ..dispose();
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
