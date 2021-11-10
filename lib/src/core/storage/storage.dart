
import 'package:stated/src/core/core.dart';

abstract class Storage with AsyncInit, Disposer, Notifier {
  T? get<T>(String path);

  void set<T>(String path, T? value);
}

/// Example of Local Storage using Shared Preferences
// class LocalStorage extends Observable implements Storage {
//   Map<String, String?> _store = {};
//   SharedPreferences? _sharedPreferences;

//   static Future<LocalStorage> create(Resolver resolver) async => LocalStorage();

//   Future<void> init() async {
//     final instance = await SharedPreferences.getInstance();
//     for (final key in instance.getKeys()) {
//       _store[key] = instance.getString(key);
//     }
//     _sharedPreferences = instance;
//   }

//   @override
//   T? get<T>(String path) => Serializer.decode(_store[path]);

//   @override
//   void set<T>(String path, T? value) {
//     final serial = Serializer.encode(value);
//     _store[path] = serial;
//     if (serial == null) {
//       _sharedPreferences?.remove(path);
//     } else {
//       _sharedPreferences?.setString(path, serial);
//     }
//     setState();
//   }
// }
