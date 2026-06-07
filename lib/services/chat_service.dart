import 'api_service.dart';

class ChatService {
  final ApiService _apiService = ApiService();

  // Get all active conversations
  Future<List<dynamic>> getConversations() async {
    try {
      final response = await _apiService.get('/messages');
      return response['data'] ?? [];
    } catch (e) {
      throw Exception('Gagal mengambil data percakapan: $e');
    }
  }

  // Get messages for a specific conversation
  Future<List<dynamic>> getConversation(int userId) async {
    try {
      final response = await _apiService.get('/messages/conversation/$userId');
      return response['data'] ?? [];
    } catch (e) {
      throw Exception('Gagal mengambil detail percakapan: $e');
    }
  }

  // Get list of admins to start a new chat
  Future<List<dynamic>> getAdmins() async {
    try {
      final response = await _apiService.get('/messages/admins');
      return response['data'] ?? [];
    } catch (e) {
      throw Exception('Gagal mengambil daftar admin: $e');
    }
  }

  // Send a new message
  Future<Map<String, dynamic>> sendMessage(int receiveId, String message) async {
    try {
      final response = await _apiService.post(
        '/messages/send',
        body: {
          'receive_id': receiveId,
          'message': message,
        },
      );
      return response['data'] ?? {};
    } catch (e) {
      throw Exception('Gagal mengirim pesan: $e');
    }
  }

  // Mark all messages in conversation as seen
  Future<Map<String, dynamic>> markConversationAsSeen(int userId) async {
    try {
      final response = await _apiService.patch('/messages/conversation/$userId/seen-all');
      return response;
    } catch (e) {
      throw Exception('Gagal menandai pesan dibaca: $e');
    }
  }

  // Delete message
  Future<Map<String, dynamic>> deleteMessage(String messageId) async {
    try {
      final response = await _apiService.delete('/messages/$messageId');
      return response;
    } catch (e) {
      throw Exception('Gagal menghapus pesan: $e');
    }
  }
}
