import 'package:flutter/material.dart';

/// A shared-element widget that animates between two positions
/// when the [NaviStack] pushes or pops a page.
///
/// Place [NaviHero] widgets with the same [tag] on different pages.
/// When a transition occurs, the hero "flies" from the old position
/// to the new one inside an [Overlay].
class NaviHero extends StatefulWidget {
  const NaviHero({
    super.key,
    required this.tag,
    required this.child,
    this.createRectTween,
  });

  /// Identifier used to match heroes across pages.
  final Object tag;

  /// The widget to display (and animate during flight).
  final Widget child;

  /// Optional custom tween for the Rect interpolation.
  final CreateRectTween? createRectTween;

  @override
  State<NaviHero> createState() => NaviHeroState();
}

class NaviHeroState extends State<NaviHero> {
  Size? _placeholderSize;

  void startFlight() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    setState(() => _placeholderSize = box.size);
  }

  void endFlight() {
    if (!mounted) return;
    setState(() => _placeholderSize = null);
  }

  Rect? get globalRect {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return MatrixUtils.transformRect(
      box.getTransformTo(null),
      Offset.zero & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_placeholderSize != null) {
      return SizedBox.fromSize(size: _placeholderSize);
    }
    return widget.child;
  }
}

/// Registry + flight controller, owned by [NaviStackState].
class NaviHeroController {
  final Map<Object, NaviHeroState> _heroes = {};

  void register(Object tag, NaviHeroState state) => _heroes[tag] = state;
  void unregister(Object tag, NaviHeroState state) {
    if (_heroes[tag] == state) _heroes.remove(tag);
  }

  /// Snapshot current hero Rects. Call before the page list changes.
  Map<Object, Rect> snapshot() {
    final result = <Object, Rect>{};
    for (final entry in _heroes.entries) {
      final rect = entry.value.globalRect;
      if (rect != null) result[entry.key] = rect;
    }
    return result;
  }

  /// Start flights for any heroes whose position changed between
  /// [before] snapshot and the current state.
  void maybeStartFlights({
    required Map<Object, Rect> before,
    required Animation<double> animation,
    required OverlayState overlay,
  }) {
    for (final tag in before.keys) {
      final hero = _heroes[tag];
      if (hero == null) continue;
      final fromRect = before[tag]!;
      final toRect = hero.globalRect;
      if (toRect == null) continue;
      if (fromRect == toRect) continue;

      _startFlight(
        tag: tag,
        hero: hero,
        fromRect: fromRect,
        toRect: toRect,
        animation: animation,
        overlay: overlay,
      );
    }
  }

  void _startFlight({
    required Object tag,
    required NaviHeroState hero,
    required Rect fromRect,
    required Rect toRect,
    required Animation<double> animation,
    required OverlayState overlay,
  }) {
    hero.startFlight();

    final createTween = hero.widget.createRectTween;
    final rectTween = createTween != null
        ? createTween(fromRect, toRect)
        : RectTween(begin: fromRect, end: toRect);

    final child = hero.widget.child;
    OverlayEntry? entry;

    void onEnd(AnimationStatus status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        entry?.remove();
        entry = null;
        hero.endFlight();
        animation.removeStatusListener(onEnd);
      }
    }

    animation.addStatusListener(onEnd);

    entry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final rect = rectTween.evaluate(animation);
          if (rect == null) return const SizedBox.shrink();
          return Positioned(
            left: rect.left,
            top: rect.top,
            width: rect.width,
            height: rect.height,
            child: IgnorePointer(child: child),
          );
        },
      ),
    );

    overlay.insert(entry!);
  }
}
