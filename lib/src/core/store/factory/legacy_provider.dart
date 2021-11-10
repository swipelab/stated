import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

SingleChildWidget legacyValueProvider<T>(T value) =>
    Provider.value(value: value);

SingleChildWidget legacyListenableProvider<T extends Listenable>(T value) =>
    ListenableProvider<T>.value(value: value);
