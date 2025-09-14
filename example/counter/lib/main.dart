import 'package:flutter/material.dart';
import 'package:stated/stated.dart';

void main() {
  runApp(MyApp());
}

class CounterState {
  CounterState({
    required this.counter,
  });

  final int counter;
}

class CounterBloc extends Stated<CounterState> {
  int _counter = 0;

  @override
  CounterState buildState() {
    return CounterState(
      counter: _counter,
    );
  }

  void increment() {
    _counter++;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stated',
      home: StatedBuilder<CounterBloc>(
        create: (context) => CounterBloc(),
        builder: (context, bloc, _) => Scaffold(
          appBar: AppBar(
            title: Text('Stated demo'),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
                textAlign: TextAlign.center,
              ),
              Text(
                '${bloc.value.counter}',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: bloc.increment,
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
