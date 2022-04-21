abstract class Storage {
  T? get<T>(String path);

  void set<T>(String path, T? value);
}
