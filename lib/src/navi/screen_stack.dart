import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PredictiveBackEvent;

import 'package:stated/src/core/functional.dart';
import 'package:stated/src/navi/hero.dart';
import 'package:stated/src/navi/screen.dart';

/// A purely declarative screen stack with animated transitions.
///
/// Receives a list of [Screen]s and renders them as a [Stack].
/// When the list changes, new screens animate in and removed screens
/// animate out. No [Route], no [ModalBarrier], no imperative pop.
class ScreenStack extends StatefulWidget {
  const ScreenStack({
    super.key,
    required this.pages,
    this.onRemoved,
  });

  final List<Screen> pages;
  final ValueChanged<Screen>? onRemoved;

  @override
  State<ScreenStack> createState() => ScreenStackState();

  static ScreenStackState of(BuildContext context) {
    return context.findAncestorStateOfType<ScreenStackState>()!;
  }

  static ScreenStackState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<ScreenStackState>();
  }
}

class ScreenStackState extends State<ScreenStack> with TickerProviderStateMixin {
  final List<ScreenSlot> _entries = [];
  final ScreenHeroController heroController = ScreenHeroController();

  bool _canPop = false;

  @override
  void initState() {
    super.initState();
    for (final page in widget.pages) {
      _entries.add(_createEntry(page, animated: false));
    }
    _updateCanPop();
  }

  void _updateCanPop() {
    final canPop = _entries.where((e) => !e.removing).length > 1;
    if (canPop == _canPop) return;
    _canPop = canPop;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) NavigationNotification(canHandlePop: canPop).dispatch(context);
    });
  }

  @override
  void didUpdateWidget(ScreenStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _diffPages(oldWidget.pages, widget.pages);
  }

  void _diffPages(List<Screen> oldPages, List<Screen> newPages) {
    final oldSet = oldPages.toSet();
    final newSet = newPages.toSet();
    final heroSnapshot = heroController.snapshot();

    // Screens removed: start exit animation.
    for (final entry in _entries.toList()) {
      if (entry.removing) continue;
      if (!newSet.contains(entry.page)) {
        _removeEntry(entry);
      }
    }

    // Screens added: create entry with enter animation.
    for (final page in newPages) {
      if (!oldSet.contains(page)) {
        _entries.add(_createEntry(page, animated: true));
      }
    }

    // Reorder to match newPages, keeping removing entries in their
    // original relative position (so an exiting child screen stays
    // above its parent, not behind it).
    final ordered = <ScreenSlot>[];
    for (final page in newPages) {
      ordered.add(_entries.firstWhere((e) => e.page == page && !e.removing));
    }
    final result = <ScreenSlot>[];
    int oi = 0;
    for (final entry in _entries) {
      if (entry.removing) {
        result.add(entry);
      } else if (oi < ordered.length) {
        result.add(ordered[oi++]);
      }
    }
    while (oi < ordered.length) {
      result.add(ordered[oi++]);
    }
    _entries
      ..clear()
      ..addAll(result);

    // Trigger hero flights.
    if (heroSnapshot.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final topEntry = _entries.lastWhereOrNull((e) => !e.removing);
        if (topEntry == null) return;
        final overlay = Overlay.maybeOf(context);
        if (overlay == null) return;
        heroController.maybeStartFlights(
          before: heroSnapshot,
          animation: topEntry.controller,
          overlay: overlay,
        );
      });
    }

    _updateCanPop();
    setState(() {});
  }

  ScreenSlot _createEntry(Screen page, {required bool animated}) {
    final controller = AnimationController(
      vsync: this,
      duration: page.transitionDuration,
      value: animated ? 0.0 : 1.0,
    );
    final entry = ScreenSlot(page: page, controller: controller);
    if (animated) controller.forward();
    return entry;
  }

  void _removeEntry(ScreenSlot entry) {
    entry.removing = true;
    entry.controller.reverse().then((_) {
      if (!mounted) return;
      _entries.remove(entry);
      entry.controller.dispose();
      entry.page.onRemoved();
      widget.onRemoved?.call(entry.page);
      setState(() {});
    });
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.controller.dispose();
    }
    super.dispose();
  }

  ScreenSlot? get _topEntry => _entries.lastWhereOrNull((e) => !e.removing);

  @override
  Widget build(BuildContext context) {
    final top = _topEntry;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        for (final entry in _entries)
          PredictiveBackHandler(
            key: entry.key,
            entry: entry,
            enabled: entry == top && _canPop,
            onPop: () => entry.page.pop(),
          ),
      ],
    );
  }
}

/// A slot in the [ScreenStack] that holds a [Screen] and manages its
/// transition animation.
class ScreenSlot {
  ScreenSlot({required this.page, required this.controller});

  final Screen page;
  final AnimationController controller;
  final key = GlobalKey();
  final contentKey = GlobalKey();
  bool removing = false;

  Widget build(BuildContext context) {
    final child = page is Listenable
        ? ListenableBuilder(
            listenable: page as Listenable,
            builder: (context, _) => page.buildPresenter(context),
          )
        : page.buildPresenter(context);

    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) =>
          page.buildTransition(context, controller, child!),
    );
  }
}

/// Wraps the top screen entry and handles Android predictive back gestures.
/// Drives the entry's [AnimationController] in response to gesture progress.
class PredictiveBackHandler extends StatefulWidget {
  const PredictiveBackHandler({
    super.key,
    required this.entry,
    required this.enabled,
    required this.onPop,
  });

  final ScreenSlot entry;
  final bool enabled;
  final VoidCallback onPop;

  @override
  State<PredictiveBackHandler> createState() => PredictiveBackHandlerState();
}

class PredictiveBackHandlerState extends State<PredictiveBackHandler>
    with WidgetsBindingObserver {
  bool _gestureInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (!widget.enabled || backEvent.isButtonEvent) return false;
    _gestureInProgress = true;
    widget.entry.controller.value = 1.0 - backEvent.progress;
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    if (!_gestureInProgress) return;
    widget.entry.controller.value = 1.0 - backEvent.progress;
  }

  @override
  void handleCommitBackGesture() {
    if (!_gestureInProgress) return;
    _gestureInProgress = false;
    widget.onPop();
  }

  @override
  void handleCancelBackGesture() {
    if (!_gestureInProgress) return;
    _gestureInProgress = false;
    widget.entry.controller.animateTo(1.0,
        duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
  }

  // ── iOS edge swipe ──

  bool _swiping = false;
  double _swipeStart = 0;

  static const _edgeWidth = 40.0;

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    if (!widget.enabled) return;
    if (!_swiping) {
      _swiping = true;
      _swipeStart = 0;
    }
    final width = context.size?.width ?? 400;
    final progress = ((d.localPosition.dx - _swipeStart) / width).clamp(0.0, 1.0);
    widget.entry.controller.value = 1.0 - progress;
  }

  void _onHorizontalDragEnd(DragEndDetails d) {
    if (!_swiping) return;
    _swiping = false;
    if (widget.entry.controller.value < 0.5 || d.velocity.pixelsPerSecond.dx > 300) {
      widget.onPop();
    } else {
      widget.entry.controller.animateTo(1.0,
          duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
    }
  }

  bool get _isIOSLike {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.entry.build(context),
        // Left edge swipe strip — sits on top to catch horizontal drags
        // without competing with the page's scroll views.
        if (_isIOSLike && widget.enabled && widget.entry.page.canSwipeBack)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: _edgeWidth,
            child: GestureDetector(
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              behavior: HitTestBehavior.translucent,
            ),
          ),
      ],
    );
  }
}
