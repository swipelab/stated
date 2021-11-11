import 'package:flutter/widgets.dart';
import 'package:stated/src/bloc/bloc.dart';

class BlocBuilder<T> extends StatefulWidget {
  const BlocBuilder({
    Key? key,
    required this.create,
    required this.builder,
    this.child,
  }) : super(key: key);

  final Bloc<T> Function(BuildContext context) create;

  final Widget Function(
    BuildContext context,
    T state,
    Widget? child,
  ) builder;

  final Widget? child;

  @override
  _BlocBuilderState<T> createState() => _BlocBuilderState<T>();
}

class _BlocBuilderState<T> extends State<BlocBuilder<T>> {
  late Bloc<T> bloc;

  @override
  void initState() {
    super.initState();

    bloc = _initBloc();
  }

  @override
  void didUpdateWidget(BlocBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.create != widget.create ||
        oldWidget.builder != widget.builder ||
        oldWidget.child != widget.child) {
      _disposeBloc();
      bloc = _initBloc();
    }
  }

  Bloc<T> _initBloc() {
    return widget.create(context)..addListener(_handleUpdate);
  }

  void _disposeBloc() {
    bloc
      ..removeListener(_handleUpdate)
      ..dispose();
  }

  void _handleUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    _disposeBloc();
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
