<div align="center">

# stated

Small, composable primitives for reactive state, async task sequencing, DI, and lightweight widget rebuilding in
Flutter.

<p>
<a href="https://pub.dev/packages/stated"><img src="https://img.shields.io/pub/v/stated.svg" alt="pub version" /></a>
<a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="license" /></a>
</p>

</div>

## ✨ What is this?

`stated` is a minimal toolkit that lets you build structure without ceremony:

* A `Stated<T>` base for lazily computed immutable view state
* Simple builder widgets (`StatedBuilder`, `FutureStatedBuilder`, `BlocBuilder`)
* Reactive primitives (`Emitter`, `ValueEmitter`, `LazyEmitter`, `ListEmitter`)
* Multi-source subscriptions (`Subscription` / `SubscriptionBuilder`)
* Async task sequencing & cancellation (`Tasks` mixin)
* Debouncing utilities (`debounce`, `Debouncer`)
* An ultra–lean service locator / DI container (`Store`) with sync, lazy, transient and async init support
* A small event bus (`Publisher`) with type filtering
* URI pattern parsing & canonicalisation (`UriParser`, `PathMatcher`)
* Deterministic resource disposal (`Dispose`, `Disposable`)

You can adopt one piece at a time. Nothing forces a framework-wide migration.

## 🧠 Core Concepts

| Concept                     | Summary                                                                                             |
|-----------------------------|-----------------------------------------------------------------------------------------------------|
| `Stated<T>`                 | Lazily builds a value via `buildState()`. Notifies only if value changes.                           |
| `StatedBuilder`             | Creates & listens to a `Listenable` (disposes if disposable).                                       |
| `FutureStatedBuilder`       | Awaits async creation of a `Stated` before building.                                                |
| `BlocBuilder`               | Simple create-once builder for any object (optionally disposable).                                  |
| `Emitter`                   | Mixin exposing `notifyListeners()`. Basis for all reactive primitives.                              |
| `ValueEmitter<T>`           | Mutable value + change notifications.                                                               |
| `LazyEmitter<T>`            | Computes value on demand & caches until dependencies trigger update.                                |
| `Emitter.map`               | Combine multiple `Listenable`s into a derived `ValueListenable`.                                    |
| `ListEmitter<T>`            | A `List<T>` implementation emitting on structural changes.                                          |
| `Subscription`              | Aggregate multiple listenables with optional `select` & `when` filters.                             |
| `Tasks`                     | Sequential async queue with cancellation tokens.                                                    |
| `debounce()`                | Wraps a callback with delayed execution.                                                            |
| `Store`                     | Register: direct instance, lazy async, transient factory. Resolve via `get<T>()` or `resolve<T>()`. |
| `AsyncInit`                 | Optional mixin for async post-construction initialisation in lazy factories.                        |
| `Publisher<T>`              | Fire events & listen by subtype.                                                                    |
| `UriParser` / `PathMatcher` | Declarative path pattern matching with typed extraction.                                            |

### Counter with `Stated`

```dart
import 'package:flutter/material.dart';
import 'package:stated/stated.dart';

// Immutable view state
class CounterState {
  const CounterState(this.count);

  final int count;
}

class CounterBloc extends Stated<CounterState> {
  int _count = 0;

  void increment() => notifyListeners(() => _count++); // calls buildState afterwards
  @override
  CounterState buildState() => CounterState(_count);
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) =>
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: StatedBuilder<CounterBloc>(
              create: (_) => CounterBloc(),
              builder: (_, bloc, __) =>
                  GestureDetector(
                    onTap: bloc.increment,
                    child: Text('Count: ${bloc.value.count}'),
                  ),
            ),
          ),
        ),
      );
}
```

## 🧩 Builders

```dart
// StatedBuilder: rebuilds when Listenable changes
StatedBuilder<MyBloc>
(
create: (ctx) => MyBloc(),
builder: (ctx, bloc, child) => Text(bloc.value.title),
);

// Provide externally managed instance
StatedBuilder.value(existingBloc, builder: ...);

// Async creation
FutureStatedBuilder<MyState>(
future: (ctx) async => MyAsyncBloc(),
builder: (ctx, state, child) => Text(state.toString()),
);

// Simple life-cycle wrapper (no listening)
BlocBuilder<ExpensiveService>(
create: (ctx) => ExpensiveService(),
builder: (ctx, service, _
)
=>
...
,
);
```

## 🔄 Reactive Primitives

### ValueEmitter

```dart

final counter = ValueEmitter<int>(0);
counter.addListener
(
() => print('now: ${counter.value}'));
counter.value++; // triggers
```

### Derived values with Emitter.map + debounce

```dart

final a = ValueEmitter(1);
final b = ValueEmitter(2);
final sum = Emitter.map([a, b], debounce(() => a.value + b.value));
sum.addListener
(
() => print('sum: ${sum.value}'));
a.value = 10;
b
.
value
=
30; // debounced single recompute
```

### LazyEmitter manual invalidation

```dart

final derived = LazyEmitter(() => heavyCompute());
// attach derived.update to dependencies:
someListenable.addListener
(
derived
.
update
);
```

### ListEmitter

```dart

final todos = ListEmitter<String>();
todos.addListener
(
() => print('changed: ${todos.length}'));
todos.add('Write docs
'
);
```

### Subscription

```dart
SubscriptionBuilder
(
register: (sub) => sub
    .add(counter, select: (_) => counter.value) // only when value changes
    .add(todos, when: (l) => l.length.isOdd),
builder: (_, __) => Text('reactive block
'
)
,
);
```

## ⏱️ Task Queue (Sequential Async)

```dart
class Loader with Tasks, Dispose {
  Future<void> loadFiles(List<String> ids) async {
    for (final id in ids) {
      await enqueue(() async {
        /* await network for id */
      });
    }
  }

  @override
  void dispose() {
    cancelTasks();
    super.dispose();
  }
}
```

Inside a cancellable task use the provided token:

```dart
await enqueueCancellable
(
(token) async {
final data = await fetch();
token.ensureRunning(); // throws if cancelled
process(data);
});
```

## 🛰️ Debounce

```dart

final search = ValueEmitter('');
final runSearch = debounce(() {
  print('Query: ${search.value}');
}, const Duration(milliseconds: 300));
search.addListener
(
runSearch
);
```

## 📦 Store (Service Locator / DI)

Register services:

```dart

final store = Store()
  ..add(Logger()) // instance
  ..addLazy<Database>((r) async => Database()) // lazy singleton (async ok)
  ..addTransient<HttpClient>((l) => HttpClient()); // new each call

await
store.init
(); // pre-warm lazy (optional)

final logger = store.get<Logger>(); // sync (must be initialised)
final db = await
store.resolve<Database>
(); // safe async
```

Support async init phase:

```dart
class SessionManager with AsyncInit {
  Future<void> init() async {
    /* load tokens */
  }
}
store.addLazy<SessionManager>
(
(
r
)
async
=>
SessionManager
(
)
);
```

## 📣 Publisher (Event Bus)

```dart
sealed class AppEvent {}

class UserLoggedIn extends AppEvent {
  UserLoggedIn(this.userId);

  final String userId;
}

class UserLoggedOut extends AppEvent {}

final events = Publisher<AppEvent>();

events.on<UserLoggedIn>
().addListener
(
() => print('login event'));

events.publish(UserLoggedIn('42'));
```

## 🌐 URI Parsing

```dart

final parser = UriParser<String, void>(
  routes: [
    UriMap('/users/{id:#}', (m) => 'User #${m.pathParameters['id']}'),
    UriMap.many(['/posts/{slug:w}', '/blog/{slug:w}'], (m) => 'Post ${m.pathParameters['slug']}'),
  ],
  canonical: {
    'lang': (raw) =>
    switch(raw) {
      'en-US' => 'en', 'en' => 'en', _ => null
    },
  },
);

parser.parse
(
Uri.parse('/users/123'), null); // => 'User #123'
```

Patterns:

* `{field}` word / dash / underscore
* `{field:#}` digits
* `{field:w}` word chars
* `{field:*}` greedy
* `{*}` wildcard segment

## 🧪 Testing Patterns

All primitives are pure Dart / Flutter-friendly. Example:

```dart
test
('lazy factory resolves only once
'
, () async {
final store = Store();
var created = 0;
store.addLazy<int>((r) async => ++created);
expect(await store.resolve<int>(), 1);
expect(await store.resolve<int>(), 1);
});
```

For `Stated` just mutate via `notifyListeners` wrapper:

```dart
class Flag extends Stated<bool> {
  bool _v = false;

  void toggle() => notifyListeners(() => _v = !_v);

  @override bool buildState() => _v;
}
```

## 🆚 Comparison (High Level)

| Library  | Focus                       | Philosophy                 |
|----------|-----------------------------|----------------------------|
| provider | DI + Inherited              | Widget-driven              | 
| riverpod | Compile-safe reactive graph | Opinionated, layered       |
| bloc     | Event/state pattern         | Structured flows           |
| stated   | Tiny primitives             | Compose only what you need |

Use `stated` when you want low ceremony & control, or to augment existing setups.

## 🍳 Cookbook

### Combine multiple counters into a derived state

```dart

final a = ValueEmitter(0);
final b = ValueEmitter(0);
final sum = Emitter.map([a, b], () => a.value + b.value);
```

### Debounced text field

```dart
onChanged: (
value) { text.value = value; }, // where text is ValueEmitter<String>
text.addListener(debounce(() => search
(
text
.
value
)
)
);
```

### Cancel pending tasks on dispose

```dart
class Loader with Tasks, Dispose {
  Future<void> refresh() =>
      enqueue(() async {
        /* network */
      });

  @override void dispose() {
    cancelTasks();
    super.dispose();
  }
}
```

## ❓ FAQ

**Why not use ChangeNotifier directly?**  `Stated<T>` formalizes immutable snapshot building & avoids redundant
notifications.

**Does Store replace Provider?** It is a minimal locator—use it alongside Provider if you like.

**Is this production ready?** The code is intentionally small; review and adopt incrementally.

## 🤝 Contributing

Issues & PRs welcome. Please keep features focused & composable.

## 🧭 Possible Next Steps / Roadmap

These are intentionally not included yet to keep scope tight, but may be explored:

* DevTools integration helpers (inspecting `Stated` trees)
* Flutter extension widgets for Provider / InheritedWidget bridging
* Async task progress utilities (percent / state enum)
* Stream adapters (Emitter <-> Stream)
* Code generation for DI registration (optional layer)
* More collection emitters (`MapEmitter`, `SetEmitter`)
* Documentation site with interactive examples
* Lint rules to encourage immutable state models

## 📄 License

MIT - see [LICENSE](./LICENSE)

## 📜 Changelog

See [CHANGELOG.md](./CHANGELOG.md)

---
If this library helps you, consider starring the repo so others can find it.

