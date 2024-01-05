# stated

A neat set of tools

See: Stated, Store, Rx, Disposable, ListenableBuilder

# examples

## Rx.map with debounce
```dart

final ValueListenable<int> counter1 = someCounter;
final ValueListenable<int> counter2 = anotherCounter;

final ValueListenable<int> valueListenable = Rx.map([counter1, counter2], debounce(() => counter1.value + counter2.value));
```

## Basic Counter Example
```dart 
import 'package:flutter/material.dart';
import 'package:stated/stated.dart';

void main() {
  runApp(MyApp());
}

/// ViewModel of Counter
class CounterState {
  CounterState({
    required this.counter,
  });

  final int counter;
}

/// Counter logic
class CounterBloc extends Stated<CounterState> {
  int _counter = 0;

  @override
  CounterState build() => CounterState(
        counter: _counter,
      );
}

/// Counter presenter
class CounterWidget extends StatelessWidget {
  CounterWidget(this.state, this.bloc);
  final CounterState state;
  

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: state.increment,
        child: Text('Counter: ${state.counter}'),
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
          builder: (context, bloc, _) => CounterWidget(bloc.value),
        ),
      ),
    );
  }
}


```
