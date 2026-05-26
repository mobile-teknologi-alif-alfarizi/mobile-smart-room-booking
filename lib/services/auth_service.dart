import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'api_service.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  static const String _userKey = 'user';

  final ApiService _apiService = ApiService();

  // Login dengan nomor_induk dan password
  Future<Map<String, dynamic>> login({
    required String nomorInduk,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        body: {
          'nomor_induk': nomorInduk,
          'password': password,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final token = data['token'];
        final user = data['user'];

        // Simpan token dan user data
        await _apiService.storeToken(token);
        await _storage.write(key: _userKey, value: jsonEncode(user));

        return {
          'success': true,
          'token': token,
          'user': user,
          'message': 'Login berhasil'
        };
      } else {
        throw Exception(
          response['message'] ?? 'Nomor induk atau password salah.',
        );
      }
    } catch (e) {
      // Extract error message from exception
      String errorMsg = e.toString();
      if (errorMsg.contains('Exception:')) {
        errorMsg = errorMsg.replaceAll('Exception: ', '');
      }
      throw Exception(errorMsg);
    }
  }

  // Get profile pengguna yang sedang login
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiService.get('/auth/me');

      if (response['success'] == true && response['data'] != null) {
        final user = response['data'];
        // Update user data di local storage
        await _storage.write(key: _userKey, value: jsonEncode(user));

        return {
          'success': true,
          'user': user,
        };
      } else {
        throw Exception('Gagal mengambil profil');
      }
    } catch (e) {
      throw Exception('Get profile error: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout', body: {});

      // Hapus token dan user data
      await _apiService.clearAll();
      await _storage.delete(key: _userKey);
    } catch (e) {
      // Tetap hapus local data meskipun request gagal
      await _apiService.clearAll();
      await _storage.delete(key: _userKey);
      throw Exception('Logout error: $e');
    }
  }

  // Refresh token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final response = await _apiService.post('/auth/refresh', body: {});

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final token = data['token'];

        // Update token
        await _apiService.storeToken(token);

        return {
          'success': true,
          'token': token,
        };
      } else {
        throw Exception('Refresh token gagal');
      }
    } catch (e) {
      throw Exception('Refresh token error: $e');
    }
  }

  // Get stored user
  Future<Map<String, dynamic>?> getStoredUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson != null) {
        return jsonDecode(userJson);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get stored token
  Future<String?> getStoredToken() async {
    return await _apiService.getStoredToken();
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    try {
      final user = await getStoredUser();
      return user != null && user['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final token = await getStoredToken();
      final user = await getStoredUser();
      return token != null && user != null;
    } catch (e) {
      return false;
    }
  }

  // Get user role
  Future<String> getUserRole() async {
    try {
      final user = await getStoredUser();
      return user?['role'] ?? 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  // Get user info
  Future<Map<String, dynamic>?> getUserInfo() async {
    return await getStoredUser();
  }
}
