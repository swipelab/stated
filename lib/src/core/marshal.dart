typedef Marshal<T> = T Function(dynamic);

extension MarshalExtension<T> on Marshal<T> {
  List<T> Function(dynamic) get list => (e) => (e as List).map(this).toList();
}