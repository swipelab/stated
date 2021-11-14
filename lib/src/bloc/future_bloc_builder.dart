import 'package:flutter/widgets.dart';
import 'package:stated/src/bloc/bloc.dart';
import 'package:stated/src/core/extension/listenable.dart';
import 'package:stated/src/core/extension/void_callback.dart';

class FutureBlocBuilder<T> extends StatefulWidget {
  const FutureBlocBuilder({
    required this.future,
    required this.builder,
    this.child,
    Key? key,
  }) : super(key: key);

  final Widget? child;
  final Future<Bloc<T>> Function(BuildContext context) future;
  final Widget Function(BuildContext context, T state, Widget? child) builder;

  @override
  State<FutureBlocBuilder<T>> createState() => _FutureBlocBuilderState<T>();
}

class _FutureBlocBuilderState<T> extends State<FutureBlocBuilder<T>> {
  @override
  void initState() {
    super.initState();
    _initBloc();
  }

  Bloc<T>? _bloc;

  Future<void> _initBloc() async {
    final bloc = await widget.future(context);
    bloc.subscribe(() => setState(() {})).disposeBy(bloc);
    _bloc = bloc;
    // notify bloc is ready
    setState(() {});
  }

  void _disposeBloc() async {
    _bloc?.dispose();
    _bloc = null;
  }

  @override
  void didUpdateWidget(FutureBlocBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.future != widget.future ||
        oldWidget.builder != widget.builder ||
        oldWidget.child != widget.child) {
      _disposeBloc();
      _initBloc();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _bloc == null
        ? SizedBox.shrink()
        : widget.builder(
            context,
            _bloc!.value,
            widget.child,
          );
  }
}