import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String _baseUrl =
      'https://apiruangints3q67vtombd3ztzr98jkgsu.soundofiwu.com/api';
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'token';

  // Private constructor untuk singleton pattern
  ApiService._();
  static final ApiService _instance = ApiService._();

  factory ApiService() {
    return _instance;
  }

  // Get token dari secure storage
  Future<String?> _getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('SecureStorage read error: $e');
      try {
        await _storage.deleteAll();
      } catch (_) {}
      return null;
    }
  }

  // Set token ke secure storage
  Future<void> _setToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('SecureStorage write error: $e');
      try {
        await _storage.deleteAll();
        await _storage.write(key: _tokenKey, value: token);
      } catch (_) {}
    }
  }

  // Delete token dari secure storage
  Future<void> _deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      debugPrint('SecureStorage delete error: $e');
      try {
        await _storage.deleteAll();
      } catch (_) {}
    }
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    late http.Response response;

    try {
      final token = await _getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      response = await http
          .get(Uri.parse('$_baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw _handleError(e);
    }

    return _handleResponse(response);
  }

  // Generic GET request for endpoints that return non-map JSON payloads.
  Future<dynamic> getDynamic(String endpoint) async {
    late http.Response response;

    try {
      final token = await _getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      response = await http
          .get(Uri.parse('$_baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw _handleError(e);
    }

    return _handleDynamicResponse(response);
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    late http.Response response;

    try {
      final token = await _getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      response = await http
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw _handleError(e);
    }

    return _handleResponse(response);
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    late http.Response response;

    try {
      final token = await _getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      response = await http
          .put(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw _handleError(e);
    }

    return _handleResponse(response);
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    late http.Response response;

    try {
      final token = await _getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      response = await http
          .delete(Uri.parse('$_baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw _handleError(e);
    }

    return _handleResponse(response);
  }

  // Generic PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    late http.Response response;

    try {
      final token = await _getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      response = await http
          .patch(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw _handleError(e);
    }

    return _handleResponse(response);
  }

  dynamic _handleDynamicResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      _deleteToken();
      throw Exception('Unauthorized. Please login again.');
    } else if (response.statusCode == 400) {
      try {
        final error = jsonDecode(response.body);
        final message = error['message'] ?? 'Nomor induk atau password salah.';
        throw Exception(message);
      } catch (e) {
        throw Exception('Nomor induk atau password salah.');
      }
    } else if (response.statusCode == 422) {
      try {
        final error = jsonDecode(response.body);
        final errors = error['errors'];

        if (errors is Map && errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final firstError = errors[firstKey];
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first.toString());
          }
        }

        final message = error['message'] ?? 'Validasi gagal';
        throw Exception(message);
      } catch (e) {
        if (e is Exception) {
          rethrow;
        }
        throw Exception('Validasi gagal');
      }
    } else if (response.statusCode == 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      throw Exception(
        'Error: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  // Handle response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired atau invalid
      _deleteToken();
      throw Exception('Unauthorized. Please login again.');
    } else if (response.statusCode == 400) {
      try {
        final error = jsonDecode(response.body);
        final message = error['message'] ?? 'Nomor induk atau password salah.';
        throw Exception(message);
      } catch (e) {
        throw Exception('Nomor induk atau password salah.');
      }
    } else if (response.statusCode == 422) {
      try {
        final error = jsonDecode(response.body);
        final errors = error['errors'];

        if (errors is Map && errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final firstError = errors[firstKey];
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first.toString());
          }
        }

        final message = error['message'] ?? 'Validasi gagal';
        throw Exception(message);
      } catch (e) {
        if (e is Exception) {
          rethrow;
        }
        throw Exception('Validasi gagal');
      }
    } else if (response.statusCode == 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      throw Exception(
        'Error: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  // Handle error with better diagnostics
  Exception _handleError(dynamic error) {
    String errorMessage = 'Network error. Please check your connection.';
    final rawMessage = error.toString();
    final normalizedMessage = rawMessage.toLowerCase();

    if (error is http.ClientException) {
      final clientMessage = error.message.toLowerCase();

      if (clientMessage.contains('connection refused')) {
        errorMessage =
            'Server tidak dapat diakses. Pastikan server sudah berjalan.';
      } else if (clientMessage.contains('certificate') ||
          clientMessage.contains('handshake') ||
          clientMessage.contains('certificate_verify_failed')) {
        errorMessage =
            'SSL handshake gagal. Sertifikat backend mungkin tidak dipercaya perangkat.';
      } else if (clientMessage.contains('failed host lookup') ||
          clientMessage.contains('no address associated with hostname') ||
          clientMessage.contains('name or service not known')) {
        errorMessage =
            'Domain tidak dapat dijangkau. Periksa koneksi internet.';
      }
    } else if (error is HandshakeException ||
        normalizedMessage.contains('handshake') ||
        normalizedMessage.contains('certificate_verify_failed') ||
        normalizedMessage.contains('certificate')) {
      errorMessage =
          'SSL handshake gagal. Sertifikat backend mungkin tidak dipercaya perangkat.';
    } else if (error is SocketException) {
      errorMessage = 'Koneksi internet tidak tersedia.';
    } else if (normalizedMessage.contains('timeoutexception') ||
        normalizedMessage.contains('timed out')) {
      errorMessage = 'Permintaan timeout. Server merespons terlalu lambat.';
    }

    if (kDebugMode) {
      debugPrint('API Error: $error');
    }

    return Exception(errorMessage);
  }

  // Store token
  Future<void> storeToken(String token) async {
    await _setToken(token);
  }

  // Get stored token
  Future<String?> getStoredToken() async {
    return await _getToken();
  }

  // Clear all data on logout
  Future<void> clearAll() async {
    await _deleteToken();
  }
}
