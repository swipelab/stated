import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:stated/src/core/dispose.dart';
import 'package:stated/src/core/emitter.dart';
import 'package:stated/src/core/list_emitter.dart';
import 'package:stated/src/navi/navigator.dart';
import 'package:stated/src/navi/page.dart';

/// Generic stack-based page router.
///
/// Manages a [home] page and a [stack] of pushed pages, rendering them
/// via [NaviStack]. Subclass and override [pages] to add guards
/// (e.g. auth checks) before the default page list.
class NaviRouter extends BackButtonDispatcher with Dispose, PageHost {
  NaviRouter({required this.home, this.routeParser});

  final NaviPage home;
  final RouteInformationParser<Object>? routeParser;
  late final stack = ListEmitter<NaviPage>()..disposeBy(this);
  late final delegate = NaviRouterDelegate(router: this);
  late final backDispatcher = NaviRouterBack(router: this);

  NaviPage? get currentConfiguration => stack.lastOrNull ?? home;

  Iterable<NaviPage> _expand(NaviPage page) sync* {
    yield page;
    if (page is PageHost) {
      for (final child in (page as PageHost).expandedPages) {
        if (!child.popped) yield child;
      }
    }
  }

  List<NaviPage> get pages => [
    ..._expand(home),
    for (final page in stack) ..._expand(page),
  ];

  late final _overlayEntry = OverlayEntry(builder: _buildContent);

  Widget _buildContent(BuildContext context) {
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: Material(
        child: NaviStack(pages: pages),
      ),
    );
  }

  Widget build(BuildContext context) {
    _overlayEntry.markNeedsBuild();
    return Overlay(initialEntries: [_overlayEntry]);
  }

  void popAll() {
    while (stack.isNotEmpty) {
      stack.last.pop();
    }
    if (home is PageHost) {
      for (final child in (home as PageHost).expandedPages.toList()) {
        child.pop();
      }
    }
  }

  Future<T?> push<T>(NaviPage<T> page) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (home == page) {
      popAll();
      return SynchronousFuture(null);
    }

    final top = stack.lastOrNull ?? home;
    if (top case final PageHost host when host.acceptChild(page)) {
      page.detach = () {
        delegate.notifyListeners();
      };
      page.removed = () {
        host.removeChild(page);
        Dispose.object(page);
      };
      page.onPush();
      delegate.notifyListeners();
      return page.future;
    }

    page.detach = () {
      FocusManager.instance.primaryFocus?.unfocus();
      stack.remove(page);
      delegate.notifyListeners();
    };
    page.removed = () => Dispose.object(page);
    page.onPush();
    stack.add(page);

    delegate.notifyListeners();
    return page.future;
  }

  Future<void> setNewRoutePath(NaviPage? configuration) {
    if (configuration == null || configuration == home) {
      popAll();
      return SynchronousFuture(null);
    }
    return push(configuration);
  }
}

class NaviRouterBack extends RootBackButtonDispatcher {
  NaviRouterBack({required this.router});

  final NaviRouter router;

  @override
  Future<bool> didPopRoute() async {
    for (final page in router.stack.reversed) {
      if (page.handleBack()) return true;
    }
    if (router.home.handleBack()) return true;
    final page = router.stack.lastOrNull;
    if (page != null) {
      page.pop();
      return true;
    }
    return super.didPopRoute();
  }
}

class NaviRouterDelegate extends RouterDelegate<NaviPage> with Emitter {
  NaviRouterDelegate({required this.router});

  final NaviRouter router;

  @override
  Widget build(BuildContext context) => router.build(context);

  @override
  Future<bool> popRoute() => router.backDispatcher.didPopRoute();

  @override
  Future<void> setNewRoutePath(NaviPage? configuration) async =>
      router.setNewRoutePath(configuration);

  @override
  NaviPage? get currentConfiguration => router.currentConfiguration;

  @override
  void notifyListeners() => super.notifyListeners();
}

/// Mixin for pages that can host child pages (e.g. a tab host showing
/// a detail page alongside the tab bar).
mixin PageHost {
  bool acceptChild(NaviPage child) => false;
  void removeChild(NaviPage child) {}
  Iterable<NaviPage> get expandedPages => const [];
}

/// Mixin for pages that support deep-linking via a URL.
mixin PageRestore<T> on NaviPage<T> {
  String get restoreUrl;
}

/// A [MaterialApp] wired to a [NaviRouter].
class NaviApp extends StatelessWidget {
  const NaviApp({
    super.key,
    required this.router,
    this.title = '',
    this.theme,
    this.debugShowCheckedModeBanner = true,
    this.localizationsDelegates,
    this.supportedLocales = const [Locale('en')],
    this.scaffoldMessengerKey,
    this.scrollBehavior,
    this.builder,
  });

  final NaviRouter router;
  final String title;
  final ThemeData? theme;
  final bool debugShowCheckedModeBanner;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Iterable<Locale> supportedLocales;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final ScrollBehavior? scrollBehavior;
  final TransitionBuilder? builder;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: title,
      theme: theme,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales,
      routeInformationParser: router.routeParser,
      routerDelegate: router.delegate,
      backButtonDispatcher: router.backDispatcher,
      scaffoldMessengerKey: scaffoldMessengerKey,
      scrollBehavior: scrollBehavior,
      builder: builder,
    );
  }
}
