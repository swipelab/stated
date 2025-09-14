import 'package:flutter/widgets.dart';

import 'emitter.dart';
import 'functional.dart';

/// A subscription to multiple listenables that notifies when any of them
/// change. Optionally, a selector can be provided to only notify when the
/// selected value changes.
class Subscription with Emitter {
  /// Adds a listenable to the subscription.
  /// Registers [listenable]. Optional [select] narrows change detection;
  /// [when] gates notifications. Returns this for chaining.
  Subscription add<T extends Listenable>(
    T listenable, {
    /// - [select]->[R] can be used to only notify when [R] changes
    Object? Function(T)? select,

    /// - [when] can be used to only notify if [true]
    Predicate<T>? when,
  }) {
    var callback = notifyListeners;
    if (select != null) {
      callback = callback.pipe(
        (e) {
          var oldSelect = select(listenable);
          return () {
            final newSelect = select(listenable);
            if (newSelect != oldSelect) {
              oldSelect = newSelect;
              e();
            }
          };
        },
      );
    }
    if (when != null) {
      callback = callback.pipe(
        (e) => () {
          if (when(listenable)) {
            e();
          }
        },
      );
    }
    listenable.subscribe(callback).disposeBy(this);

    //ignore: avoid_returning_this
    return this;
  }
}

/// Creates a [Subscription] to listen to multiple listenables and rebuilds the
/// widget tree when any of them change.
///
/// The [register] callback is used to specify the listenables to subscribe to.
class SubscriptionBuilder extends StatefulWidget {
  const SubscriptionBuilder({
    required this.register,
    required this.builder,
    this.child,
    super.key,
  });

  /// Registers listenables given a [Subscription]
  final ValueSetter<Subscription> register;
  final TransitionBuilder builder;
  final Widget? child;

  @override
  State<SubscriptionBuilder> createState() => _SubscriptionBuilderState();
}

class _SubscriptionBuilderState extends State<SubscriptionBuilder> {
  late Subscription subscription;

  void register() {
    subscription = Subscription()
      ..pipe(widget.register)
      ..subscribe(() => setState(() {}));
  }

  @override
  void initState() {
    super.initState();
    register();
  }

  @override
  void didUpdateWidget(covariant SubscriptionBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    subscription.dispose();
    register();
  }

  @override
  void dispose() {
    subscription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, widget.child);
}
