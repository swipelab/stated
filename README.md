# stated

A neat set of tools

See: Stated, Store, Disposable, Emitter

# examples

## Emitter.map with debounce
```dart

final ValueListenable<int> counter1 = someCounter;
final ValueListenable<int> counter2 = anotherCounter;

final ValueListenable<int> sumOfCounters = Emitter.map([counter1, counter2], debounce(() => counter1.value + counter2.value));
```

## Basic Counter Example
```dart 
import 'package:flutter/material.dart';
import 'package:stated/stated.dart';

void main() {
  runApp(MyApp());
}

/// Model of Counter
class CounterState {
  CounterState({
    required this.counter,
  });

  final int counter;
}

/// Counter ViewModel
class CounterBloc extends Stated<CounterState> {
  int _counter = 0;

  void increment() {
    _counter++;
    setState();
  }

  @override
  CounterState build() =>
      CounterState(
        counter: _counter,
      );
}

/// Counter View
class CounterWidget extends StatelessWidget {
  CounterWidget(this.bloc);

  final CounterBloc bloc;

  @override
  Widget build(BuildContext context) =>
      GestureDetector(
        onTap: bloc.increment,
        child: Text('Counter: ${bloc.value.counter}'),
      );
}

/// Usage
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stated',
      home: Scaffold(
        body: StatedBuilder<CounterState>(
          create: (context) => CounterBloc(),
          builder: (context, bloc, _) => CounterWidget(bloc),
        ),
      ),
    );
  }
}


```
