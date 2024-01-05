# 2.0.1
* added Rx.map
* added debouncer
* added BlocBuilder
* increased the min dart sdk

# 1.3.0
* Stated now implements Task & Disposer by default
* General cleanup

# 1.2.10

* Fixed store.init - re-entrant

# 1.2.9

* Remove history from stated
* Pass bloc through StatedBuilder

# 1.2.8

* Fix ListenableBuilder

# 1.2.7

* Added StoreProvider

# 1.2.6

* Relaxed contract
* Improved docs
* Replaced Observer with ListenableBuilder
* Removed Observable
* Stated no longer has Tasks by default

# 1.1.4+2

* Improved docs
* Relaxed the Observer constraints, now accepting Listenable

# 1.1.4

* Added Observer (similar to AnimatedBuilder)
* Renamed BlocBuilder -> StatedBuilder
* Renamed Bloc -> Stated
* Renamed FutureBlocBuilder -> FutureStatedBuilder
* Exported ObservableBuilder

# 1.0.13

* Added core components (wip)
* BlocBuilder no longer re-creates bloc
* Added ObservableBuilder

# 0.0.8

* scheduled Bloc.notifyListeners

# 0.0.5

* Added Bloc.dispose

# 0.0.3

* Now Bloc.setState has the callback as optional for easier listeners
* Added BlocBuilder
