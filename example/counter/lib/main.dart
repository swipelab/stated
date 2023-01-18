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
class CounterBloc extends Stated<CounterState> {
  int _counter = 0;

  @override
  CounterState build() => CounterState(
        counter: _counter,
        increment: () {
          setState(() => _counter++);
        },
      );
}

/// Counter presenter
class CounterDisplayWidget extends StatelessWidget {
  CounterDisplayWidget(this.state);

  final CounterState state;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'You have pushed the button this many times:',
          ),
          Text(
            '${state.counter}',
            style: Theme.of(context).textTheme.headline4,
          ),
        ],
      );
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
          body: Center(
            child: CounterDisplayWidget(bloc.value),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: bloc.value.increment,
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
