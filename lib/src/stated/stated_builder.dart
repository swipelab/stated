import 'package:flutter/widgets.dart';
import 'package:stated/stated.dart';

typedef StatedBuilderDelegate<T extends Listenable> = Widget Function(
  BuildContext context,
  T bloc,
  Widget? child,
);

typedef StatedCreateDelegate<T extends Listenable> = T Function(
  BuildContext context,
);

class StatedBuilder<T extends Listenable> extends StatefulWidget {
  const StatedBuilder({
    Key? key,
    required this.create,
    required this.builder,
    this.child,
  }) : super(key: key);

  /// Delegate to create [Stated] to which this [StatedBuilder] gets connected.
  final StatedCreateDelegate<T> create;

  /// Delegate to build widget tree.
  /// [StatedBuilder] will rebuild this widget tree when [Stated] emits event.
  final StatedBuilderDelegate<T> builder;

  final Widget? child;

  @override
  _StatedBuilderState<T> createState() => _StatedBuilderState<T>();
}

class _StatedBuilderState<T extends Listenable>
    extends State<StatedBuilder<T>> {
  /// [Stated] to which this [StatedBuilder] responds.
  late T value;

  @override
  void initState() {
    super.initState();
    value = widget.create(context)..addListener(_notify);
  }

  @override
  void dispose() {
    value..removeListener(_notify);

    if (value is Disposable) {
      (value as Disposable).dispose();
    }

    super.dispose();
  }

  /// Notifies the widget that the [value] has changed.
  /// This will trigger a rebuild of the widget.
  void _notify() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      value,
      widget.child,
    );
  }
}
