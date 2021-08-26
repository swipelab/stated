import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

typedef TaskDelegate = Future<void> Function();

typedef TypedTaskDelegate<T> = Future<T> Function();

class TaskCancelledException implements Exception {}

class _Task<T> {
  _Task(this._task);

  final TaskDelegate _task;

  final _completer = Completer<T?>();

  void complete([FutureOr<T?> value]) => _completer.complete(value);

  void completeError(Object error) => _completer.completeError(error);

  Future<void> run() => _task.call();

  Future<T?> get future => _completer.future;
}

mixin Tasks {
  final _queue = Queue<_Task<void>>();

  /// Enqueues [task] for execution and return the completion future
  Future<void> enqueue(TaskDelegate task) {
    final completer = _Task<void>(task);
    _queue.add(completer);
    _dequeue();
    return completer.future;
  }

  Future<void> waitIdle() {
    final completer = _Task<void>(() async {});
    _queue.add(completer);
    return completer.future;
  }

  bool _isClosed = false;
  int _runningTasks = 0;
  final int _maxConcurrentTasks = 1;
  int get runningTasks => _runningTasks;

  Future<void> _dequeue() async {
    if (_isClosed || _runningTasks == _maxConcurrentTasks || _queue.isEmpty) {
      return;
    }

    while (!_isClosed &&
        _queue.isNotEmpty &&
        _runningTasks < _maxConcurrentTasks) {
      _runningTasks++;
      final task = _queue.removeFirst();
      try {
        await task.run();
        if (_isClosed) {
          task.completeError(TaskCancelledException());
        } else {
          task.complete();
        }
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        task.completeError(e);
      }
      _runningTasks--;
    }

    while (_isClosed && _queue.isNotEmpty) {
      _queue.removeFirst().completeError(TaskCancelledException());
    }
  }

  void closeTasks() {
    _isClosed = true;
  }

  static VoidCallback scheduled(VoidCallback callback) {
    var targetVersion = 0;
    var currentVersion = 0;
    return () {
      if (targetVersion == currentVersion) {
        targetVersion++;
        scheduleMicrotask(() {
          targetVersion = ++currentVersion;
          callback();
        });
      }
    };
  }
}
