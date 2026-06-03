import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Android emulator: http://10.0.2.2:3000/api
  /// Physical device: run with --dart-define=API_BASE_URL=http://YOUR_LAPTOP_IP:3000/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  final http.Client _client;
  String? _token;

  void setToken(String? token) => _token = token;

  Uri _uri(String path, {Map<String, dynamic>? query}) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final qp = <String, String>{};
    query?.forEach((key, value) {
      if (value == null) return;
      final text = value.toString();
      if (text.isNotEmpty) qp[key] = text;
    });
    return Uri.parse('$normalizedBase$cleanPath').replace(queryParameters: qp.isEmpty ? null : qp);
  }

  Map<String, String> _headers({bool json = true}) => {
        'Accept': 'application/json',
        if (json) 'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _client
          .get(_uri(path, query: query), headers: _headers(json: false))
          .timeout(const Duration(seconds: 25));
      return _handle(response.statusCode, response.body);
    } catch (e) {
      throw _normalize(e);
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client
          .post(_uri(path), headers: _headers(), body: jsonEncode(body ?? <String, dynamic>{}))
          .timeout(const Duration(seconds: 25));
      return _handle(response.statusCode, response.body);
    } catch (e) {
      throw _normalize(e);
    }
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client
          .patch(_uri(path), headers: _headers(), body: jsonEncode(body ?? <String, dynamic>{}))
          .timeout(const Duration(seconds: 25));
      return _handle(response.statusCode, response.body);
    } catch (e) {
      throw _normalize(e);
    }
  }

  Future<dynamic> multipart(String path, {required Map<String, String> fields}) async {
    try {
      final request = http.MultipartRequest('POST', _uri(path));
      request.headers.addAll(_headers(json: false));
      request.fields.addAll(fields);
      final streamed = await request.send().timeout(const Duration(seconds: 45));
      final body = await streamed.stream.bytesToString();
      return _handle(streamed.statusCode, body);
    } catch (e) {
      throw _normalize(e);
    }
  }

  dynamic _handle(int statusCode, String body) {
    dynamic data;
    if (body.trim().isEmpty) {
      data = <String, dynamic>{};
    } else {
      try {
        data = jsonDecode(body);
      } catch (_) {
        throw ApiException('Response server tidak valid.', statusCode: statusCode);
      }
    }

    if (statusCode < 200 || statusCode >= 300) {
      final message = data is Map<String, dynamic>
          ? (data['message'] ?? data['error'] ?? 'Request gagal').toString()
          : 'Request gagal';
      throw ApiException(message, statusCode: statusCode);
    }
    return data;
  }

  ApiException _normalize(Object e) {
    if (e is ApiException) return e;
    final text = e.toString();
    if (text.contains('Connection refused') || text.contains('Failed host lookup') || text.contains('SocketException')) {
      return ApiException('Tidak bisa terhubung ke backend. Pastikan ExpressJS berjalan dan API_BASE_URL benar.');
    }
    if (text.contains('TimeoutException')) {
      return ApiException('Koneksi ke server timeout. Coba ulangi.');
    }
    return ApiException(text.replaceFirst('Exception: ', ''));
  }
}
