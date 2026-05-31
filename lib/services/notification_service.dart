import 'api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getMyNotifications({String? statusBaca}) async {
    try {
      final endpoint = statusBaca != null && statusBaca.isNotEmpty
          ? '/notifications?status_baca=${Uri.encodeComponent(statusBaca)}'
          : '/notifications';

      final response = await _apiService.get(endpoint);

      return response['data'] ?? [];
    } catch (e) {
      throw Exception('Gagal mengambil notifikasi: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get('/notifications/unread-count');
      return response['data']?['unread_count'] ?? 0;
    } catch (e) {
      throw Exception('Gagal mengambil jumlah notifikasi: $e');
    }
  }

  Future<Map<String, dynamic>> markAsRead(int id) async {
    try {
      final response = await _apiService.patch('/notifications/$id/read');
      return response;
    } catch (e) {
      throw Exception('Gagal menandai notifikasi: $e');
    }
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await _apiService.patch('/notifications/read-all');
      return response;
    } catch (e) {
      throw Exception('Gagal menandai semua notifikasi: $e');
    }
  }
}
