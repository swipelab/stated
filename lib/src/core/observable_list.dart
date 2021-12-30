import 'dart:math';

import 'package:stated/src/core/core.dart';

class ObservableList<T> with Disposer, Notifier implements List<T> {
  List<T> _list;

  ObservableList([Iterable<T>? items]) : _list = List<T>.from(items ?? [] as Iterable<T>);

  @override
  T get first => _list.first;

  set first(T value) {
    _list.first = value;
    notifyListeners();
  }

  @override
  T get last => _list.last;

  set last(T value) {
    _list.last = value;
    notifyListeners();
  }

  @override
  int get length => _list.length;

  set length(int value) {
    _list.length = value;
    notifyListeners();
  }

  @override
  List<T> operator +(List<T> other) {
    return _list + other;
  }

  @override
  T operator [](int index) => _list[index];

  @override
  void operator []=(int index, T value) {
    _list[index] = value;
    notifyListeners();
  }

  @override
  void add(T value) {
    _list.add(value);
    notifyListeners();
  }

  @override
  void addAll(Iterable<T> iterable) {
    _list.addAll(iterable);
    notifyListeners();
  }

  @override
  bool any(bool Function(T element) test) => _list.any(test);

  @override
  Map<int, T> asMap() => _list.asMap();

  @override
  List<R> cast<R>() => _list.cast<R>();

  @override
  void clear() {
    _list.clear();
    notifyListeners();
  }

  @override
  bool contains(Object? element) => _list.contains(element);

  @override
  T elementAt(int index) => _list.elementAt(index);

  @override
  bool every(bool Function(T element) test) => _list.every(test);

  @override
  Iterable<R> expand<R>(Iterable<R> f(T element)) => _list.expand<R>(f);

  @override
  void fillRange(int start, int end, [T? fillValue]) =>
      _list.fillRange(start, end, fillValue);

  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _list.firstWhere(test, orElse: orElse);

  @override
  R fold<R>(R initialValue, R Function(R previousValue, T element) combine) =>
      _list.fold(initialValue, combine);

  @override
  Iterable<T> followedBy(Iterable<T> other) => _list.followedBy(other);

  @override
  void forEach(void Function(T element) f) => _list.forEach(f);

  @override
  Iterable<T> getRange(int start, int end) => _list.getRange(start, end);

  @override
  int indexOf(T element, [int start = 0]) => _list.indexOf(element, start);

  @override
  int indexWhere(bool Function(T element) test, [int start = 0]) =>
      _list.indexWhere(test, start);

  @override
  void insert(int index, T element) {
    _list.insert(index, element);
    notifyListeners();
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    _list.insertAll(index, iterable);
    notifyListeners();
  }

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  Iterator<T> get iterator => _list.iterator;

  @override
  String join([String separator = ""]) => _list.join(separator);

  @override
  int lastIndexOf(T element, [int? start]) => _list.lastIndexOf(element, start);

  @override
  int lastIndexWhere(bool Function(T element) test, [int? start]) =>
      _list.lastIndexWhere(test, start);

  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _list.lastWhere(test, orElse: orElse);

  @override
  Iterable<R> map<R>(R Function(T e) f) => _list.map<R>(f);

  @override
  T reduce(T Function(T value, T element) combine) => _list.reduce(combine);

  @override
  bool remove(Object? value) {
    final result = _list.remove(value);
    if (result) notifyListeners();
    return result;
  }

  @override
  T removeAt(int index) {
    final result = _list.removeAt(index);
    notifyListeners();
    return result;
  }

  @override
  T removeLast() {
    final result = _list.removeLast();
    notifyListeners();
    return result;
  }

  @override
  void removeRange(int start, int end) {
    _list.removeRange(start, end);
    notifyListeners();
  }

  @override
  void removeWhere(bool Function(T element) test) {
    _list.removeWhere(test);
    notifyListeners();
  }

  @override
  void replaceRange(int start, int end, Iterable<T> replacement) {
    _list.replaceRange(start, end, replacement);
    notifyListeners();
  }

  void replaceWith(Iterable<T> replacement) {
    _list.clear();
    _list.addAll(replacement);
    notifyListeners();
  }

  void swap(List<T> list) {
    _list = list;
    notifyListeners();
  }

  @override
  void retainWhere(bool Function(T element) test) {
    _list.retainWhere(test);
    notifyListeners();
  }

  @override
  Iterable<T> get reversed => _list.reversed;

  @override
  void setAll(int index, Iterable<T> iterable) {
    _list.setAll(index, iterable);
    notifyListeners();
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    _list.setRange(start, end, iterable, skipCount);
    notifyListeners();
  }

  @override
  void shuffle([Random? random]) {
    _list.shuffle(random);
    notifyListeners();
  }

  @override
  T get single => _list.single;

  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _list.singleWhere(test, orElse: orElse);

  @override
  Iterable<T> skip(int count) => _list.skip(count);

  @override
  Iterable<T> skipWhile(bool Function(T value) test) => _list.skipWhile(test);

  @override
  void sort([int Function(T a, T b)? compare]) {
    _list.sort(compare);
    notifyListeners();
  }

  @override
  List<T> sublist(int start, [int? end]) => _list.sublist(start, end);

  @override
  Iterable<T> take(int count) => _list.take(count);

  @override
  Iterable<T> takeWhile(bool Function(T value) test) => _list.takeWhile(test);

  @override
  List<T> toList({bool growable = true}) => _list.toList(growable: growable);

  @override
  Set<T> toSet() => _list.toSet();

  @override
  Iterable<T> where(bool Function(T element) test) => _list.where(test);

  @override
  Iterable<R> whereType<R>() => _list.whereType<R>();
}