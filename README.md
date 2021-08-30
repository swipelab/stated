# stated

Final state

# example


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
    required this.increment,
  });

  final VoidCallback increment;
  final int counter;
}

/// Counter logic
class CounterBloc extends Bloc<CounterState> {
  int _counter = 0;

  @override
  CounterState build() => CounterState(
        counter: _counter,
        increment: () => setState(() => _counter++),
      );
}

/// Counter presenter
class CounterWidget extends StatelessWidget {
  CounterWidget(this.state);
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
        body: BlocBuilder<CounterState>(
          create: (context) => CounterBloc(),
          builder: (context, state, _) => CounterWidget(state),
        ),
      ),
    );
  }
}


```
