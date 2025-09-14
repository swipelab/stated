import 'package:flutter/widgets.dart';
import 'package:stated/src/stated/stated.dart';

/// Awaits an async creation of a [Stated] and rebuilds on its changes.
///
/// {@tool snippet}
/// Lazy async loading of a bloc.
/// ```dart
/// FutureStatedBuilder<CounterState>(
///   future: (ctx) async => CounterBloc()..increment(),
///   builder: (_, state, __) => Text('Loaded: \\${state.count}'),
/// );
/// ```
/// {@end-tool}
class FutureStatedBuilder<T> extends StatefulWidget {
  const FutureStatedBuilder({
    required this.future,
    required this.builder,
    this.child,
    Key? key,
  }) : super(key: key);

  final Widget? child;
  /// Async factory returning a [Stated] instance.
  final Future<Stated<T>> Function(BuildContext context) future;
  /// Builder invoked with the current state value once ready.
  final Widget Function(BuildContext context, T state, Widget? child) builder;

  @override
  State<FutureStatedBuilder<T>> createState() => _FutureStatedBuilderState<T>();
}

class _FutureStatedBuilderState<T> extends State<FutureStatedBuilder<T>> {
  @override
  void initState() {
    super.initState();
    _initBloc();
  }

  Stated<T>? _bloc;

  Future<void> _initBloc() async {
    final bloc = await widget.future(context);
    bloc.addListener(_notify);
    _bloc = bloc;

    // notify bloc is ready
    _notify();
  }

  void _notify() => setState(() {});

  void _disposeBloc() async {
    if (_bloc != null) {
      _bloc!
        ..removeListener(_notify)
        ..dispose();
      _bloc = null;
    }
  }

  @override
  void didUpdateWidget(FutureStatedBuilder<T> oldWidget) {
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
