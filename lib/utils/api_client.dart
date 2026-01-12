import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../services/storage_service.dart';

class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final Duration timeout;
  final http.Client _client;

  ApiClient({
    String? baseUrl,
    Map<String, String>? headers,
    this.timeout = const Duration(seconds: 30),
    http.Client? client,
  }) : baseUrl = baseUrl ?? Env.apiBaseUrl,
       _client = client ?? http.Client(),
       defaultHeaders = {
         'Content-Type': 'application/json',
         'Accept': 'application/json',
         ...?headers,
       };

  Map<String, String> _getHeaders({Map<String, String>? customHeaders}) {
    final headers = {...defaultHeaders};

    final token = StorageService.getAuthToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }
    return uri;
  }

  Future<T> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final request = http.Request('GET', uri);
      request.headers.addAll(_getHeaders(customHeaders: headers));
      final response = await _client
          .send(request)
          .timeout(timeout)
          .then(
            (streamedResponse) => http.Response.fromStream(streamedResponse),
          );

      return _handleResponse<T>(response);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<T> post<T>(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final request = http.Request('POST', uri);
      request.headers.addAll(_getHeaders(customHeaders: headers));
      if (body != null) {
        request.body = jsonEncode(body);
      }
      final response = await _client
          .send(request)
          .timeout(timeout)
          .then(
            (streamedResponse) => http.Response.fromStream(streamedResponse),
          );

      return _handleResponse<T>(response);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<T> put<T>(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final request = http.Request('PUT', uri);
      request.headers.addAll(_getHeaders(customHeaders: headers));
      if (body != null) {
        request.body = jsonEncode(body);
      }
      final response = await _client
          .send(request)
          .timeout(timeout)
          .then(
            (streamedResponse) => http.Response.fromStream(streamedResponse),
          );

      return _handleResponse<T>(response);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<T> patch<T>(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final request = http.Request('PATCH', uri);
      request.headers.addAll(_getHeaders(customHeaders: headers));
      if (body != null) {
        request.body = jsonEncode(body);
      }
      final response = await _client
          .send(request)
          .timeout(timeout)
          .then(
            (streamedResponse) => http.Response.fromStream(streamedResponse),
          );

      return _handleResponse<T>(response);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<T> delete<T>(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final request = http.Request('DELETE', uri);
      request.headers.addAll(_getHeaders(customHeaders: headers));
      if (body != null) {
        request.body = jsonEncode(body);
      }
      final response = await _client
          .send(request)
          .timeout(timeout)
          .then(
            (streamedResponse) => http.Response.fromStream(streamedResponse),
          );

      return _handleResponse<T>(response);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  T _handleResponse<T>(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return {} as T;
      }
      try {
        final decoded = jsonDecode(response.body);
        return decoded as T;
      } catch (e) {
        throw ApiException(
          message: 'Failed to parse JSON: $e',
          statusCode: response.statusCode,
          response: response.body,
        );
      }
    } else {
      throw ApiException(
        message: 'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
        response: response.body,
      );
    }
  }

  void close() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? response;

  ApiException({required this.message, this.statusCode, this.response});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException: $message (Status: $statusCode)';
    }
    return 'ApiException: $message';
  }
}
