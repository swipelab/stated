import 'package:flutter/widgets.dart';
import 'package:stated/stated.dart';

class ObservableBuilder<T extends Observable> extends StatefulWidget {
  const ObservableBuilder({
    Key? key,
    required this.create,
    required this.builder,
    this.child,
  }) : super(key: key);

  final T Function(BuildContext context) create;

  final Widget Function(
    BuildContext context,
    T state,
    Widget? child,
  ) builder;

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
    listenable = widget.create(context)..addListener(_handleUpdate);
  }

  void _handleUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    listenable
      ..removeListener(_handleUpdate)
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
