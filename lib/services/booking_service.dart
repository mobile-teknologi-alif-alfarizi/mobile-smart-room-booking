import 'api_service.dart';

class BookingService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getRooms() async {
    try {
      final response = await _apiService.getDynamic('/ruangan/public');
      if (response is List) {
        return response;
      }

      if (response is Map<String, dynamic> && response['data'] is List) {
        return response['data'] as List<dynamic>;
      }

      return [];
    } catch (e) {
      throw Exception('Gagal mengambil data ruangan: $e');
    }
  }

  Future<List<dynamic>> getCampuses() async {
    try {
      final response = await _apiService.getDynamic('/kampus/public');
      if (response is List) {
        return response;
      }

      if (response is Map<String, dynamic> && response['data'] is List) {
        return response['data'] as List<dynamic>;
      }

      return [];
    } catch (e) {
      throw Exception('Gagal mengambil data kampus: $e');
    }
  }

  Future<List<dynamic>> getMyBookings() async {
    try {
      final response = await _apiService.get('/bookings/my');
      return response['data'] ?? [];
    } catch (e) {
      throw Exception('Gagal mengambil data booking: $e');
    }
  }

  Future<List<dynamic>> getAllBookings() async {
    try {
      final response = await _apiService.get('/bookings');
      return response['data'] ?? [];
    } catch (e) {
      throw Exception('Gagal mengambil data booking: $e');
    }
  }

  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    try {
      final response = await _apiService.patch('/bookings/$bookingId/cancel');
      return response;
    } catch (e) {
      throw Exception('Gagal membatalkan booking: $e');
    }
  }

  Future<Map<String, dynamic>> createBooking({
    required int userId,
    required int ruanganId,
    required String tanggal,
    required String waktuMulai,
    required String waktuSelesai,
    required String keperluan,
    required String tipeBooking,
  }) async {
    try {
      final response = await _apiService.post(
        '/bookings',
        body: {
          'user_id': userId,
          'ruangan_id': ruanganId,
          'tanggal': tanggal,
          'waktu_mulai': waktuMulai,
          'waktu_selesai': waktuSelesai,
          'keperluan': keperluan,
          'tipe_booking': tipeBooking,
        },
      );

      return response;
    } catch (e) {
      throw Exception('Gagal membuat booking: $e');
    }
  }
}
