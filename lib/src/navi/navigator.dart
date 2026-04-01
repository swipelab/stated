import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PredictiveBackEvent;

import 'package:stated/src/core/functional.dart';
import 'package:stated/src/navi/hero.dart';
import 'package:stated/src/navi/page.dart';

/// A purely declarative page stack with animated transitions.
///
/// Receives a list of [NaviPage]s and renders them as a [Stack].
/// When the list changes, new pages animate in and removed pages
/// animate out. No [Route], no [ModalBarrier], no imperative pop.
class NaviStack extends StatefulWidget {
  const NaviStack({
    super.key,
    required this.pages,
    this.onRemoved,
  });

  final List<NaviPage> pages;
  final ValueChanged<NaviPage>? onRemoved;

  @override
  State<NaviStack> createState() => NaviStackState();

  static NaviStackState of(BuildContext context) {
    return context.findAncestorStateOfType<NaviStackState>()!;
  }

  static NaviStackState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<NaviStackState>();
  }
}

class NaviStackState extends State<NaviStack> with TickerProviderStateMixin {
  final List<NavEntry> _entries = [];
  final NaviHeroController heroController = NaviHeroController();

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
  void didUpdateWidget(NaviStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _diffPages(oldWidget.pages, widget.pages);
  }

  void _diffPages(List<NaviPage> oldPages, List<NaviPage> newPages) {
    final oldSet = oldPages.toSet();
    final newSet = newPages.toSet();
    final heroSnapshot = heroController.snapshot();

    // Pages removed: start exit animation.
    for (final entry in _entries.toList()) {
      if (entry.removing) continue;
      if (!newSet.contains(entry.page)) {
        _removeEntry(entry);
      }
    }

    // Pages added: create entry with enter animation.
    for (final page in newPages) {
      if (!oldSet.contains(page)) {
        _entries.add(_createEntry(page, animated: true));
      }
    }

    // Reorder to match newPages, keeping removing entries in their
    // original relative position (so an exiting child page stays
    // above its parent, not behind it).
    final ordered = <NavEntry>[];
    for (final page in newPages) {
      ordered.add(_entries.firstWhere((e) => e.page == page && !e.removing));
    }
    final result = <NavEntry>[];
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

  NavEntry _createEntry(NaviPage page, {required bool animated}) {
    final controller = AnimationController(
      vsync: this,
      duration: page.transitionDuration,
      value: animated ? 0.0 : 1.0,
    );
    final entry = NavEntry(page: page, controller: controller);
    if (animated) controller.forward();
    return entry;
  }

  void _removeEntry(NavEntry entry) {
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

  NavEntry? get _topEntry => _entries.lastWhereOrNull((e) => !e.removing);

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

class NavEntry {
  NavEntry({required this.page, required this.controller});

  final NaviPage page;
  final AnimationController controller;
  final key = GlobalKey();
  final contentKey = GlobalKey();
  bool removing = false;
}

class NavEntryWidget extends StatelessWidget {
  const NavEntryWidget({required this.entry});

  final NavEntry entry;

  @override
  Widget build(BuildContext context) {
    final child = entry.page is Listenable
        ? ListenableBuilder(
            listenable: entry.page as Listenable,
            builder: (context, _) => entry.page.buildPresenter(context),
          )
        : entry.page.buildPresenter(context);

    return AnimatedBuilder(
      animation: entry.controller,
      child: child,
      builder: (context, child) =>
          entry.page.buildTransition(context, entry.controller, child!),
    );
  }
}

/// Wraps the top page entry and handles Android predictive back gestures.
/// Drives the entry's [AnimationController] in response to gesture progress.
class PredictiveBackHandler extends StatefulWidget {
  const PredictiveBackHandler({
    super.key,
    required this.entry,
    required this.enabled,
    required this.onPop,
  });

  final NavEntry entry;
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
        NavEntryWidget(entry: widget.entry),
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
