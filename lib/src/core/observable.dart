import 'core.dart';

/// Observable is a basic base class for building Listenable Bloc
/// 1. Has an easy disposing method for subscriptions
/// Eg:
/// class Bloc extends Observable {
///   Bloc(AListenableDependency dependency) {
///     // we create a subscription that will call [foo]
///     // and delegate the disposal to the [Disposer]
///     // using [disposeBy]
///     dependency.subscribe(foo).disposedBy(this);
///   }
///
///   void foo() {
///   }
/// }
/// 2. Provides an execution queue for tasks using the [Tasks] mixin
/// 3. Uses [Notifier] implementation of Listenable to ensure the Listeners
/// will not be notified more than once if [notifyListeners] is called during
/// the same frame
abstract class Observable with Disposer, Tasks, Notifier {}
