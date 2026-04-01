import 'dart:async';

import 'package:flutter/material.dart';

import 'package:stated/src/navi/transitions.dart';

/// A page that can be rendered by [NaviStack] and managed by [NaviRouter].
///
/// Provides its own content via [buildPresenter] and controls
/// how it transitions in/out via [buildTransition].
mixin NaviPage<T> {
  // === rendering ===

  /// Build the page content.
  Widget buildPresenter(BuildContext context);

  /// Wrap [child] (the output of [buildPresenter]) in a transition
  /// driven by [animation] (0→1 on push, 1→0 on pop).
  ///
  /// Override to customise. The default is a platform slide.
  Widget buildTransition(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) => NaviTransitions.platformSlide(context, animation, child);

  /// Duration of the enter/exit animation.
  Duration get transitionDuration => const Duration(milliseconds: 300);

  /// Whether the iOS edge-swipe gesture should be enabled for this page.
  /// Set to `false` for bottom sheets and overlays that dismiss differently.
  bool get canSwipeBack => true;

  // === navigation ===

  /// Whether the back button / swipe should pop this page.
  bool get canPop => true;

  /// Custom back-button handling. Return `true` to consume the event.
  bool handleBack() => false;

  /// Called after the page is pushed onto the router.
  void onPush() {}

  // === pop lifecycle ===

  /// Whether this page has been popped (explicitly removed).
  bool popped = false;

  /// Set by the router when pushing. Called during [pop] to remove the page
  /// from the router stack and notify the delegate.
  VoidCallback? detach;

  /// Set by the router when pushing. Called from [onRemoved] after the exit
  /// animation completes for final cleanup (disposal).
  VoidCallback? removed;

  Completer<T?>? _completer;

  /// A future that completes with the result when the page is popped.
  Future<T?> get future {
    _completer ??= Completer<T?>();
    return _completer!.future;
  }

  /// Remove this page. Marks as popped, detaches from the router,
  /// and completes the [future] with [result].
  void pop([T? result]) {
    popped = true;
    onDetach();
    if (_completer?.isCompleted != true) {
      _completer?.complete(result);
    }
  }

  /// Called during [pop] before the future is completed.
  /// Override for cleanup that must happen before the exit animation.
  @mustCallSuper
  void onDetach() {
    detach?.call();
    detach = null;
  }

  /// Called after the exit animation completes and the page is fully removed.
  /// Override for cleanup that should happen after the page is off screen.
  @mustCallSuper
  void onRemoved() {
    if (popped) {
      removed?.call();
      removed = null;
    }
  }
}
