import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:stated/src/core/dispose.dart';
import 'package:stated/src/core/emitter.dart';
import 'package:stated/src/core/functional.dart';
import 'package:stated/src/core/list_emitter.dart';
import 'package:stated/src/core/store/store.dart';
import 'package:stated/src/core/uri.dart';
import 'package:stated/src/navi/screen_stack.dart';
import 'package:stated/src/navi/screen.dart';

/// Generic stack-based screen router.
///
/// Manages a [home] screen and a [stack] of pushed screens, rendering them
/// via [ScreenStack]. Subclass and override [pages] to add guards
/// (e.g. auth checks) before the default screen list.
class StatedRouter extends BackButtonDispatcher with Dispose, ScreenShell {
  StatedRouter({required this.home, this.routeParser});

  final Screen home;
  final RouteInformationParser<Object>? routeParser;
  late final stack = ListEmitter<Screen>()..disposeBy(this);
  late final delegate = StatedRouterDelegate(router: this);
  late final backDispatcher = StatedRouterBack(router: this);

  Screen? get currentConfiguration => stack.lastOrNull ?? home;

  Iterable<Screen> _expand(Screen page) sync* {
    yield page;
    if (page is ScreenShell) {
      for (final screen in (page as ScreenShell).pages) {
        if (!screen.popped) yield screen;
      }
    }
  }

  List<Screen> get pages => [
    ..._expand(home),
    for (final page in stack) ..._expand(page),
  ];

  late final _overlayEntry = OverlayEntry(builder: _buildContent);

  bool get canPop {
    if (stack.isNotEmpty) return true;
    if (home is ScreenShell) {
      for (final screen in (home as ScreenShell).pages) {
        if (!screen.popped) return true;
      }
    }
    return false;
  }

  void _updateSystemBack() {
    SystemNavigator.setFrameworkHandlesBack(canPop);
  }

  Widget _buildContent(BuildContext context) {
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: Material(
        child: NotificationListener<NavigationNotification>(
          onNotification: (_) => true, // absorb — router manages system back directly
          child: ScreenStack(pages: pages),
        ),
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
    if (home is ScreenShell) {
      for (final screen in (home as ScreenShell).pages.toList()) {
        screen.pop();
      }
    }
  }

  Future<T?> push<T>(Screen<T> page) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (home == page) {
      popAll();
      return SynchronousFuture(null);
    }

    final top = stack.lastOrNull ?? home;
    if (top case final ScreenShell host when host.accept(page)) {
      page.detach = () {
        delegate.notifyListeners();
      };
      page.removed = () {
        host.remove(page);
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

  Future<void> setNewRoutePath(Screen? configuration) {
    if (configuration == null || configuration == home) {
      popAll();
      return SynchronousFuture(null);
    }
    return push(configuration);
  }
}

class StatedRouterBack extends RootBackButtonDispatcher {
  StatedRouterBack({required this.router});

  final StatedRouter router;

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

class StatedRouterDelegate extends RouterDelegate<Screen> with Emitter {
  StatedRouterDelegate({required this.router});

  final StatedRouter router;

  @override
  Widget build(BuildContext context) => router.build(context);

  @override
  Future<bool> popRoute() => router.backDispatcher.didPopRoute();

  @override
  Future<void> setNewRoutePath(Screen? configuration) async =>
      router.setNewRoutePath(configuration);

  @override
  void notifyListeners() {
    super.notifyListeners();
    router._updateSystemBack();
  }

  @override
  Screen? get currentConfiguration => router.currentConfiguration;
}

/// Mixin for screens that can host other screens (e.g. a tab host showing
/// a detail screen alongside the tab bar).
///
/// When a screen is pushed, the router asks the current top screen's shell
/// whether to [accept] it. If accepted, the screen is managed by the shell
/// instead of the router's main stack.
mixin ScreenShell {
  /// Whether this shell wants to own [screen]. Return `true` to intercept
  /// the push — the screen will not go onto the router stack.
  bool accept(Screen screen) => false;

  /// Called after a hosted screen's exit animation completes.
  void remove(Screen screen) {}

  /// The screens currently hosted by this shell. The router flattens
  /// these into the [ScreenStack] alongside the main stack.
  Iterable<Screen> get pages => const [];
}

/// Mixin for screens that support deep-linking via a URL.
mixin Deeplink<T> on Screen<T> {
  String get restoreUrl;
}

/// A [RouteInformationParser] that converts URIs into [Screen]s
/// using a [UriParser], and restores URLs from [Deeplink] screens.
class ScreenRouteParser extends RouteInformationParser<Object> {
  ScreenRouteParser({required this.parser, this.normalize});

  final UriParser<Screen, dynamic> parser;
  final Uri Function(Uri)? normalize;

  Screen? parse(Uri? uri) {
    if (uri == null) return null;
    if (normalize != null) uri = normalize!(uri);
    return parser.parse(uri, null);
  }

  @override
  Future<Object> parseRouteInformation(RouteInformation routeInformation) async {
    return parse(routeInformation.uri) as Object;
  }

  @override
  RouteInformation? restoreRouteInformation(Object configuration) {
    return (configuration is Deeplink ? configuration.restoreUrl : null)
        ?.pipe(Uri.tryParse)
        ?.pipe((uri) => RouteInformation(uri: uri));
  }
}

/// The root widget for a stated app.
///
/// Resolves a [StatedRouter] from the [Store] and sets up theming,
/// localization, scroll behavior, and back-button dispatching —
/// without pulling in Flutter's [Navigator] or [MaterialApp].
class StatedApp extends StatelessWidget {
  const StatedApp({
    super.key,
    required this.store,
    this.title = '',
    this.theme,
    this.debugShowCheckedModeBanner = true,
    this.localizationsDelegates,
    this.supportedLocales = const [Locale('en')],
    this.scrollBehavior,
  });

  final Store store;
  final String title;
  final ThemeData? theme;
  final bool debugShowCheckedModeBanner;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Iterable<Locale> supportedLocales;
  final ScrollBehavior? scrollBehavior;

  @override
  Widget build(BuildContext context) {
    final router = store.get<StatedRouter>();
    final data = theme ?? ThemeData();

    return Title(
      title: title,
      color: data.primaryColor,
      child: MediaQuery.fromView(
        view: View.of(context),
        child: Localizations(
          locale: supportedLocales.first,
          delegates: [
            ...?localizationsDelegates,
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          child: AnimatedTheme(
            data: data,
            child: ScrollConfiguration(
              behavior: scrollBehavior ?? const MaterialScrollBehavior(),
              child: ScaffoldMessenger(
                child: Shortcuts(
                  shortcuts: WidgetsApp.defaultShortcuts,
                  child: Actions(
                    actions: WidgetsApp.defaultActions,
                    child: DefaultTextEditingShortcuts(
                      child: Router(
                        routeInformationParser: router.routeParser,
                        routerDelegate: router.delegate,
                        backButtonDispatcher: router.backDispatcher,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
