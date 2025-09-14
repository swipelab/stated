import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:stated/src/core/core.dart';
export 'package:stated/src/core/marshal.dart';

abstract class HttpClient {
  String get host;
  String get scheme;
  Map<String, String> get headers;

  http.Client get client;

  String encode(Object value) => jsonEncode(value);
  dynamic decode(String value) => jsonDecode(value);

  void check(String method, Uri url, http.Response response) {
    if (response.statusCode < 400) return;
    throw Exception('$method $url -> ${response.statusCode} ${response.body}');
  }

  Future<T?> get<T>(
    String path, {
    Marshal? marshal,
    Map<String, String> headers = const {},
  }) async {
    final uri = Uri.parse('$scheme://$host$path');
    final result = await client.get(
      uri,
      headers: {...this.headers, ...headers},
    );

    check('GET', uri, result);

    if (marshal == null) return null;
    return marshal(decode(result.body));
  }

  Future<T?> post<T>(
    String path, {
    Object? body,
    Marshal? marshal,
    Map<String, String> headers = const {},
  }) async {
    final uri = Uri.parse('$scheme://$host$path');
    final result = await client.post(
      uri,
      body: body?.pipe(encode),
      headers: {...this.headers, ...headers},
    );
    check('POST', uri, result);

    if (marshal == null) return null;
    return marshal(decode(result.body));
  }

  Future<T?> put<T>(
    String path, {
    Object? body,
    Marshal? marshal,
    Map<String, String> headers = const {},
  }) async {
    final uri = Uri.parse('$scheme://$host$path');
    final result = await client.put(
      uri,
      body: body?.pipe(encode),
      headers: {...this.headers, ...headers},
    );
    check('PUT', uri, result);

    if (marshal == null) return null;
    return marshal(decode(result.body));
  }

  Future<T?> postBuffer<T>(
    String path,
    Uint8List body, {
    Marshal? marshal,
    Map<String, String> headers = const {},
  }) async {
    final uri = Uri.parse('$scheme://$host$path');
    final result = await client.post(
      uri,
      body: body,
      headers: {
        'content-type': 'application/octet-stream',
        ...this.headers,
        ...headers,
      },
    );
    check('POST', uri, result);

    if (marshal == null) return null;
    return marshal(decode(result.body));
  }

  Future<T?> delete<T>(
    String path, {
    Object? body,
    Marshal? marshal,
    Map<String, String> headers = const {},
  }) async {
    final uri = Uri.parse('$scheme://$host$path');
    final result = await client.delete(
      uri,
      body: body?.pipe(encode),
      headers: {...this.headers, ...headers},
    );
    check('DELETE', uri, result);

    if (marshal == null) return null;
    return marshal(decode(result.body));
  }
}
