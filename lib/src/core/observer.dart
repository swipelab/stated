import 'package:flutter/widgets.dart';
import 'package:stated/stated.dart';

typedef ObserverBuilder<T extends Observable> = Widget Function(
  BuildContext context,
  T observable,
  Widget? child,
);

/// A similar construct like Flutter's [AnimationBuilder] that also
/// provides the [observable] via the [builder] delegate.
/// This can be useful when a complex expression is needed
/// to resolve the [observable].
/// Eg:
/// Observer(
///   observable: context.read<SomeObservable>(),
///   builder: (context, observable, child) => Widget(observable),
/// )
class Observer<T extends Observable> extends StatefulWidget {
  const Observer({
    Key? key,
    required this.observable,
    required this.builder,
    this.child,
  }) : super(key: key);

  final T observable;

  final ObserverBuilder<T> builder;

  final Widget? child;

  @override
  _ObserverState<T> createState() => _ObserverState<T>();
}

class _ObserverState<T extends Observable> extends State<Observer<T>> {
  @override
  void initState() {
    super.initState();
    widget.observable.addListener(_notify);
  }

  @override
  void didUpdateWidget(covariant Observer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.observable != widget.observable) {
      oldWidget.observable.removeListener(_notify);
      widget.observable.addListener(_notify);
    }
  }

  void _notify() => setState(() {});

  @override
  void dispose() {
    widget.observable.removeListener(_notify);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      widget.observable,
      widget.child,
    );
  }
}
