import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String _baseUrl = 'https://apiruangints3q67vtombd3ztzr98jkgsu.soundofiwu.com/api';
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
    return await _storage.read(key: _tokenKey);
  }

  // Set token ke secure storage
  Future<void> _setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Delete token dari secure storage
  Future<void> _deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = await _getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final token = await _getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final token = await _getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .put(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final token = await _getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .delete(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
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
    } else if (response.statusCode == 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      throw Exception(
          'Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  // Handle error with better diagnostics
  Exception _handleError(dynamic error) {
    String errorMessage = 'Network error. Please check your connection.';
    
    if (error is http.ClientException) {
      if (error.message.contains('Connection refused')) {
        errorMessage = 'Server tidak dapat diakses. Pastikan server sudah berjalan.';
      } else if (error.message.contains('certificate')) {
        errorMessage = 'SSL Certificate error. Periksa koneksi internet Anda.';
      } else if (error.message.contains('Failed host lookup')) {
        errorMessage = 'Domain tidak dapat dijangkau. Periksa koneksi internet.';
      }
    } else if (error is SocketException) {
      errorMessage = 'Koneksi internet tidak tersedia.';
    } else if (error.toString().contains('TimeoutException')) {
      errorMessage = 'Permintaan timeout. Server merespons terlalu lambat.';
    }
    
    print('API Error: $error'); // For debugging
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
