import 'package:stated/src/core/core.dart';

/// TODO: add int, double, num, DateTime, ...

abstract class Serializer {
  static T? decode<T>(String? value) {
    if (T == String) {
      return value as T?;
    } else if (T is bool) {
      return value.parseBool() as T?;
    }
    return null;
  }

  static String? encode<T>(T? value) {
    if (value is String) {
      return value;
    } else if (value is bool) {
      return value.serialize();
    }
    return null;
  }
}
