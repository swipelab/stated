import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stated/stated.dart';

/// Token allowing async work to cooperatively check for cancellation.
abstract class CancellationToken {
  /// if(isCancelled) throw [TaskCancelledException]
  void ensureRunning();

  bool get isCancelled;
}

typedef TaskDelegate = Future<void> Function();
typedef CancellableTaskDelegate = Future<void> Function(CancellationToken token);
typedef TypedTaskDelegate<T> = Future<T> Function();

/// Thrown when a queued task is cancelled (explicitly or during disposal).
class TaskCancelledException implements Exception {}

class _Task<T> implements CancellationToken {
  _Task(
    this.task, {
    this.onDone,
  }) : _isCancelled = false;

  final CancellableTaskDelegate task;
  final VoidCallback? onDone;
  bool _isCancelled;

  bool get isCancelled => _isCancelled;

  final _completer = Completer<T?>();

  void done() {
    onDone?.call();
  }

  void cancel() {
    _isCancelled = true;
  }

  void complete([FutureOr<T?> value]) {
    _completer.complete(value);
    done();
  }

  void completeError(Object error) {
    _completer.completeError(error);
    done();
  }

  Future<void> run() => task.call(this);

  Future<T?> get future => _completer.future;

  @override
  void ensureRunning() {
    if (isCancelled) {
      throw TaskCancelledException();
    }
  }
}

/// [Tasks] mixin provides an easy way to sequence async work
/// Eg:
/// ...
///     enqueue(() async { await Future.delayed(Duration(seconds: 10)); print('10 secs'); });
///     enqueue(() async { await Future.delayed(Duration(seconds: 10)); print('1 sec'); });
/// Output:
///     10 secs
///     1 sec
/// Provides a FIFO async task queue (single concurrency) with cancellation.
mixin Tasks on Dispose {
  final _queue = <_Task<void>>[];

  /// Enqueues [task] for execution and return the completion future
  /// Throws: [TaskCancelledException]
  @nonVirtual
  Future<void> enqueue(TaskDelegate task) => enqueueCancellable((_) => task());

  /// Enqueues [task] for execution and return the completion future
  /// Also provides the [CancellationToken] to the closure
  /// Throws: [TaskCancelledException]
  @nonVirtual
  Future<void> enqueueCancellable(CancellableTaskDelegate task) {
    if (!_isActive) {
      _isActive = true;
      disposeTasks.disposeBy(this);
    }

    final completer = _Task<void>(task);
    _queue.add(completer);
    _dequeue();
    return completer.future;
  }

  /// Provides a future that will complete when the current queue completes
  /// Throws: [TaskCancelledException]
  @nonVirtual
  Future<void> waitIdle() => enqueue(() async {});

  /// Cancels all enqueued tasks
  @nonVirtual
  void cancelTasks() {
    _queue.forEach((e) => e.cancel());
  }

  bool _isActive = false;
  bool _isClosed = false;
  int _runningTasks = 0;
  final int _maxConcurrentTasks = 1;

  /// Concurrently running tasks count
  int get runningTasks => _runningTasks;

  Future<void> _dequeue() async {
    if (_isClosed || _runningTasks >= _maxConcurrentTasks || _queue.isEmpty) {
      return;
    }
    _runningTasks++;

    while (!_isClosed && _queue.isNotEmpty) {
      final task = _queue.removeAt(0);
      if (task.isCancelled) {
        task.completeError(TaskCancelledException());
      } else {
        try {
          await task.run();
          if (_isClosed || task.isCancelled) {
            task.completeError(TaskCancelledException());
          } else {
            task.complete();
          }
        } catch (e) {
          task.completeError(e);
        }
      }
    }

    while (_isClosed && _queue.isNotEmpty) {
      _queue.removeAt(0).completeError(TaskCancelledException());
    }

    _runningTasks--;
  }

  @protected
  @nonVirtual
  void disposeTasks() {
    _isClosed = true;
  }
}
