import 'package:flutter/material.dart';

/// Built-in transition builders for use in [NaviPage.buildTransition].
abstract final class NaviTransitions {
  /// Slide from right (push) / slide to right (pop).
  static Widget platformSlide(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    final position = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
    return SlideTransition(position: position, child: child);
  }

  /// Simple opacity fade.
  static Widget fade(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }

  /// Slide up from the bottom edge.
  static Widget slideUp(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    final position = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
    return SlideTransition(position: position, child: child);
  }

  /// Fade on wide screens, slide on narrow. Stable widget tree — no
  /// unmount/remount when the screen width crosses the threshold.
  static Widget responsive(
    BuildContext context,
    Animation<double> animation,
    Widget child, {
    double breakpoint = 600,
  }) {
    final wide = MediaQuery.sizeOf(context).width >= breakpoint;
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    final position = Tween<Offset>(
      begin: wide ? Offset.zero : const Offset(1, 0),
      end: Offset.zero,
    ).animate(curved);
    return FadeTransition(
      opacity: wide ? curved : const AlwaysStoppedAnimation(1.0),
      child: SlideTransition(position: position, child: child),
    );
  }

  /// No animation — instant swap.
  static Widget none(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) => child;
}
