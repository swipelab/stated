# 1.2.4
* Relaxed contract
* Improved docs
* Replaced Observer with ListenableBuilder
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
## 0.0.8
* scheduled Bloc.notifyListeners
## 0.0.5
* Added Bloc.dispose  
## 0.0.3
* Now Bloc.setState has the callback as optional for easier listeners
* Added BlocBuilder