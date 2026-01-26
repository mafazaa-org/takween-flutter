import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'storage.dart';

class ApiClient {
  String get _baseUrl => Env.apiBaseUrl;

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (includeAuth) {
      final accessToken = Storage.getString('accessToken');
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    return headers;
  }

  Future<void> _refreshToken() async {
    final refreshToken = Storage.getString('refreshToken');
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final newAccessToken = data['accessToken'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;

      if (newAccessToken != null) {
        await Storage.setString('accessToken', newAccessToken);
      }
      if (newRefreshToken != null) {
        await Storage.setString('refreshToken', newRefreshToken);
      }
    } else {
      await Storage.remove('accessToken');
      await Storage.remove('refreshToken');
      throw Exception('Token refresh failed: ${response.statusCode}');
    }
  }

  Future<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return Future.value(fromJson({}));
      }
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Future.value(fromJson(data));
      } catch (e) {
        return Future.value(fromJson({}));
      }
    } else {
      throw Exception(
        'Request failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<T> _request<T>(
    Future<http.Response> Function() makeRequest,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    var response = await makeRequest();

    if (response.statusCode == 401) {
      await _refreshToken();
      response = await makeRequest();
    }

    return _handleResponse(response, fromJson);
  }

  Uri _buildUri(String path, Map<String, String>? queryParameters) {
    var uri = Uri.parse('$_baseUrl$path');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }
    return uri;
  }

  Future<T> get<T>(
    String path, {
    Map<String, String>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    final uri = _buildUri(path, queryParameters);
    return _request(
      () => http.get(uri, headers: _getHeaders()),
      fromJson ?? (data) => data as T,
    );
  }

  Future<T> post<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    final uri = _buildUri(path, null);
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _request(
      () => http.post(uri, headers: _getHeaders(), body: encodedBody),
      fromJson ?? (data) => data as T,
    );
  }

  Future<T> put<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    final uri = _buildUri(path, null);
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _request(
      () => http.put(uri, headers: _getHeaders(), body: encodedBody),
      fromJson ?? (data) => data as T,
    );
  }

  Future<T> delete<T>(
    String path, {
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    final uri = _buildUri(path, null);
    return _request(
      () => http.delete(uri, headers: _getHeaders()),
      fromJson ?? (data) => data as T,
    );
  }
}
