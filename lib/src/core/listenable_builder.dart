import 'package:flutter/widgets.dart';
import 'package:stated/stated.dart';

typedef ListenableBuilderCreate<T extends Listenable> = T Function(
  BuildContext context,
);
typedef ListenableBuilderDelegate<T extends Listenable> = Widget Function(
  BuildContext context,
  T state,
  Widget? child,
);

typedef ListenableBuilderDispose<T> = void Function(T listenable);

class ListenableBuilder<T extends Listenable> extends StatefulWidget {
  const ListenableBuilder._({
    required this.create,
    required this.builder,
    this.child,
    Key? key,
    required ListenableBuilderDispose dispose,
  })  : _dispose = dispose,
        super(key: key);

  ListenableBuilder({
    required this.create,
    required this.builder,
    this.child,
    Key? key,
  }) : _dispose = _listenableCreateDispose;

  ListenableBuilder.value({
    required T value,
    required this.builder,
    this.child,
    Key? key,
  })  : _dispose = _listenableValueDispose,
        create = _listenableValueCreate(value),
        super(key: key);

  final ListenableBuilderCreate<T> create;

  final ListenableBuilderDelegate<T> builder;

  final ListenableBuilderDispose<T> _dispose;

  static ListenableBuilderCreate<T>
      _listenableValueCreate<T extends Listenable>(T value) =>
          (BuildContext context) => value;

  static void _listenableCreateDispose(dynamic e) {
    if (e is Disposer) {
      e.dispose();
    }
  }

  static void _listenableValueDispose(dynamic e) {}

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
    listenable = widget.create(context)..addListener(_notify);
  }

  void _notify() => setState(() {});

  @override
  void dispose() {
    listenable.removeListener(_notify);
    widget._dispose.call(listenable);
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
