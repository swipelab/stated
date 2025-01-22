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

/// A builder widget, meant to be used for creating and using a [Listenable] bloc
class StatedBuilder<T extends Listenable> extends StatefulWidget {
  const StatedBuilder({
    Key? key,
    required StatedCreateDelegate<T> create,
    required this.builder,
    this.child,
  })  : _value = null,
        _create = create,
        super(key: key);

  const StatedBuilder.value(
    T value, {
    Key? key,
    required this.builder,
    this.child,
  })  : _value = value,
        _create = null,
        super(key: key);

  /// Creates the bloc. Called once, the created bloc will be persisted after.
  /// Any used dependency values will be as of creation time.
  final StatedCreateDelegate<T>? _create;

  /// Externally-owned stated object.
  /// Will not be disposed by the builder.
  final T? _value;

  /// Delegate to build widget tree.
  /// [StatedBuilder] will rebuild this widget tree when [Rx] emits event.
  final StatedBuilderDelegate<T> builder;

  final Widget? child;

  @override
  _StatedBuilderState<T> createState() => _StatedBuilderState();
}

class _StatedBuilderState<T extends Listenable>
    extends State<StatedBuilder<T>> {
  late T stated;

  @override
  void initState() {
    super.initState();
    _initStated();
  }

  @override
  void dispose() {
    _disposeStated(widget);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StatedBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget._value != widget._value) {
      _disposeStated(oldWidget);
      _initStated();
      _triggerBuild();
    }
  }

  void _initStated() {
    stated = (widget._value ?? widget._create!(context))
      ..addListener(_triggerBuild);
  }

  void _disposeStated(StatedBuilder<T> widget) {
    stated.removeListener(_triggerBuild);
    if (stated is Disposable && widget._value == null) {
      (stated as Disposable).dispose();
    }
  }

  void _triggerBuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      stated,
      widget.child,
    );
  }
}
