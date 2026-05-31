import 'package:flutter/material.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/services/booking_service.dart';
import 'package:mobile_app/services/notification_service.dart';
import 'package:mobile_app/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final BookingService _bookingService = BookingService();
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'Semua';
  String _roomSearchQuery = '';
  Map<String, dynamic>? _user;
  int _unreadNotifications = 0;

  List<Map<String, dynamic>> _rooms = [];
  List<Map<String, dynamic>> _allBookings = [];
  List<Map<String, dynamic>> _myBookings = [];

  List<String> get _filters => const ['Semua', 'Kelas', 'Aula', 'Lab'];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      Map<String, dynamic>? user = await _authService.getStoredUser();

      try {
        final profile = await _authService.getProfile();
        if (profile['success'] == true &&
            profile['user'] is Map<String, dynamic>) {
          user = Map<String, dynamic>.from(profile['user'] as Map);
        }
      } catch (_) {
        // fallback ke data yang sudah ada di storage
      }

      List<dynamic> roomsRaw = [];
      try {
        roomsRaw = await _bookingService.getRooms();
      } catch (_) {}

      List<dynamic> myBookingsRaw = [];
      try {
        myBookingsRaw = await _bookingService.getMyBookings();
      } catch (_) {}

      List<dynamic> allBookingsRaw = [];
      try {
        allBookingsRaw = await _bookingService.getAllBookings();
      } catch (_) {}

      int unreadNotifications = 0;
      try {
        unreadNotifications = await _notificationService.getUnreadCount();
      } catch (_) {}

      if (!mounted) {
        return;
      }

      setState(() {
        _user = user;
        _rooms = roomsRaw
            .whereType<Map<String, dynamic>>()
            .map(_mapRoom)
            .toList();
        _myBookings = myBookingsRaw
            .whereType<Map<String, dynamic>>()
            .map(_mapBooking)
            .toList();
        _allBookings = allBookingsRaw
            .whereType<Map<String, dynamic>>()
            .map(_mapBooking)
            .toList();
        _unreadNotifications = unreadNotifications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _extractErrorMessage(e);
      });
    }
  }

  Map<String, dynamic> _mapRoom(Map<String, dynamic> item) {
    final roomName = item['nama_ruangan']?.toString() ?? '-';
    final campusName = item['kampus']?['nama_kampus']?.toString() ?? '-';

    return {
      'id': _toInt(item['id']),
      'name': roomName,
      'campus': campusName,
      'type': _getRoomLabel(roomName),
      'capacity': _guessCapacity(roomName),
      'floor': _guessFloor(roomName),
      'icon': _getRoomIcon(roomName),
    };
  }

  Map<String, dynamic> _mapBooking(Map<String, dynamic> item) {
    final tanggal = _normalizeDateKey(item['tanggal']);
    final status = item['status']?.toString() ?? 'pending';
    final roomName = item['ruangan']?['nama_ruangan']?.toString() ?? '-';
    final campusName =
        item['ruangan']?['kampus']?['nama_kampus']?.toString() ?? '-';
    final startTime = _normalizeTime(
      item['waktu_mulai']?.toString() ?? '00:00',
    );
    final endTime = _normalizeTime(
      item['waktu_selesai']?.toString() ?? '00:00',
    );

    return {
      'id': item['id'],
      'room_id': _toInt(item['ruangan_id']) ?? _toInt(item['ruangan']?['id']),
      'room': roomName,
      'campus': campusName,
      'date_key': tanggal,
      'date': _formatFriendlyDate(tanggal),
      'time': '$startTime - $endTime',
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'status_label': _getBookingStatusLabel(status),
      'status_color': _getBookingStatusColor(status),
      'type': _getRoomLabel(roomName),
      'capacity': _guessCapacity(roomName),
      'floor': _guessFloor(roomName),
      'icon': _getRoomIcon(roomName),
      'keperluan': item['keperluan']?.toString() ?? '-',
    };
  }

  String _extractErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('Exception:')) {
      return message.replaceAll('Exception: ', '');
    }
    return message;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.light_mode_rounded;
    if (hour < 15) return Icons.wb_sunny_rounded;
    if (hour < 18) return Icons.wb_twilight_rounded;
    return Icons.nights_stay_rounded;
  }

  String get _userName {
    final name = _user?['name']?.toString().trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return 'Pengguna';
  }

  int get _activeBookingCount {
    return _myBookings.where((booking) {
      final status = (booking['status']?.toString() ?? '').toLowerCase();
      return status != 'rejected' && status != 'cancelled';
    }).length;
  }

  int get _availableRoomCount {
    return _filteredRooms.where((room) => room['available'] == true).length;
  }

  List<Map<String, dynamic>> get _filteredRooms {
    final query = _roomSearchQuery.toLowerCase();
    final selectedFilter = _selectedFilter;

    return _rooms
        .where((room) {
          final matchesFilter =
              selectedFilter == 'Semua' || room['type'] == selectedFilter;
          final matchesQuery =
              query.isEmpty ||
              (room['name'] as String).toLowerCase().contains(query) ||
              (room['campus'] as String).toLowerCase().contains(query);
          return matchesFilter && matchesQuery;
        })
        .map((room) {
          return {...room, 'available': _isRoomAvailable(room['id'] as int?)};
        })
        .toList();
  }

  List<Map<String, dynamic>> get _upcomingBookings {
    final today = DateTime.now();
    final todayKey = _formatIsoDate(today);
    final nowMinutes = today.hour * 60 + today.minute;

    final upcoming = _myBookings.where((booking) {
      final dateKey = booking['date_key']?.toString() ?? '';
      if (dateKey.isEmpty) return false;
      if (dateKey.compareTo(todayKey) > 0) return true;
      if (dateKey == todayKey) {
        return _timeToMinutes(booking['start_time']?.toString() ?? '00:00') >=
            nowMinutes;
      }
      return false;
    }).toList();

    upcoming.sort((left, right) {
      final leftKey = '${left['date_key']} ${left['start_time']}';
      final rightKey = '${right['date_key']} ${right['start_time']}';
      return leftKey.compareTo(rightKey);
    });

    return upcoming.take(3).toList();
  }

  bool _isRoomAvailable(int? roomId) {
    if (roomId == null) {
      return false;
    }

    final todayKey = _formatIsoDate(DateTime.now());
    final nowMinutes = DateTime.now().hour * 60 + DateTime.now().minute;

    for (final booking in _allBookings) {
      if (booking['room_id'] != roomId || booking['date_key'] != todayKey) {
        continue;
      }

      final status = booking['status']?.toString().toLowerCase();
      if (status == 'rejected' || status == 'cancelled') {
        continue;
      }

      final startMinutes = _timeToMinutes(
        booking['start_time']?.toString() ?? '00:00',
      );
      final endMinutes = _timeToMinutes(
        booking['end_time']?.toString() ?? '00:00',
      );
      if (nowMinutes >= startMinutes && nowMinutes < endMinutes) {
        return false;
      }
    }

    return true;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _normalizeDateKey(dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.isEmpty) return '';

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw.split(' ').first;
    }

    return _formatIsoDate(parsed.toLocal());
  }

  String _formatIsoDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatFriendlyDate(String dateKey) {
    if (dateKey.isEmpty) return '-';

    final parsed = DateTime.tryParse(dateKey);
    if (parsed == null) return dateKey;

    final today = _formatIsoDate(DateTime.now());
    final tomorrow = _formatIsoDate(
      DateTime.now().add(const Duration(days: 1)),
    );
    if (dateKey == today) return 'Hari ini';
    if (dateKey == tomorrow) return 'Besok';

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  String _normalizeTime(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String _getRoomLabel(String roomName) {
    final normalized = roomName.toLowerCase();
    if (normalized.contains('lab')) return 'Lab';
    if (normalized.contains('aula') ||
        normalized.contains('meeting') ||
        normalized.contains('rapat')) {
      return 'Aula';
    }
    return 'Kelas';
  }

  int _guessCapacity(String roomName) {
    final normalized = roomName.toLowerCase();
    if (normalized.contains('lab')) return 30;
    if (normalized.contains('meeting')) return 12;
    if (normalized.contains('aula')) return 120;
    return 40;
  }

  int _guessFloor(String roomName) {
    final digits = RegExp(r'\d+').firstMatch(roomName)?.group(0);
    if (digits == null) return 1;
    return int.tryParse(digits[0]) ?? 1;
  }

  IconData _getRoomIcon(String roomName) {
    final normalized = roomName.toLowerCase();
    if (normalized.contains('lab')) return Icons.computer_rounded;
    if (normalized.contains('meeting') || normalized.contains('rapat'))
      return Icons.table_chart_rounded;
    if (normalized.contains('aula')) return Icons.domain_rounded;
    return Icons.school_rounded;
  }

  String _getBookingStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'confirmed':
        return 'Aktif';
      case 'pending':
        return 'Menunggu';
      case 'rejected':
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status.isEmpty ? '-' : status;
    }
  }

  Color _getBookingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'confirmed':
        return AppColors.accent;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getGreetingIconLabel() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Pagi';
    if (hour < 15) return 'Siang';
    if (hour < 18) return 'Sore';
    return 'Malam';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 52,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal memuat dashboard',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Terjadi kesalahan tidak dikenal.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.white,
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getGreetingIcon(),
                                  size: isMobile ? 20 : 24,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _getGreeting(),
                                    style: TextStyle(
                                      fontSize: isMobile ? 18 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _userName,
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 14,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: isMobile ? 45 : 50,
                        height: isMobile ? 45 : 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            isMobile ? 12 : 16,
                          ),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: isMobile ? 24 : 28,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                          size: isMobile ? 18 : 20,
                        ),
                        SizedBox(width: isMobile ? 10 : 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _roomSearchQuery = value.trim();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Cari ruang atau kampus...',
                              hintStyle: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: isMobile ? 12 : 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: isMobile ? 10 : 12,
                              ),
                            ),
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMiniChip(
                        '${_upcomingBookings.length} booking aktif',
                      ),
                      _buildMiniChip('$_unreadNotifications notifikasi'),
                      _buildMiniChip('${_rooms.length} ruangan'),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_month_rounded,
                      title: 'Booking Aktif',
                      value: _activeBookingCount.toString(),
                      color: AppColors.primary,
                      isCompact: isMobile,
                    ),
                  ),
                  SizedBox(width: isMobile ? 10 : 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.meeting_room_rounded,
                      title: 'Ruang Tersedia',
                      value: _availableRoomCount.toString(),
                      color: AppColors.accent,
                      isCompact: isMobile,
                    ),
                  ),
                ],
              ),
            ),
            if (_upcomingBookings.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 20,
                  0,
                  isMobile ? 16 : 20,
                  isMobile ? 16 : 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Terjadwal',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: isMobile ? 10 : 12),
                    ..._upcomingBookings.map(
                      (booking) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _BookingCard(
                          booking: booking,
                          isCompact: isMobile,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 20,
                isMobile ? 10 : 12,
                isMobile ? 16 : 20,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ruang Tersedia',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: isMobile ? 10 : 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              filter,
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            backgroundColor: AppColors.lightGray,
                            selectedColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide.none,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 10 : 12,
                              vertical: isMobile ? 6 : 8,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: _filteredRooms.isEmpty
                  ? _buildEmptyRoomsState(isMobile)
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 2 : 3,
                        crossAxisSpacing: isMobile ? 10 : 12,
                        mainAxisSpacing: isMobile ? 10 : 12,
                        childAspectRatio: isMobile ? 0.92 : 0.95,
                      ),
                      itemCount: _filteredRooms.length,
                      itemBuilder: (context, index) {
                        return _RoomCard(
                          room: _filteredRooms[index],
                          isCompact: isMobile,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  Widget _buildEmptyRoomsState(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(
            Icons.meeting_room_outlined,
            size: isMobile ? 42 : 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 10),
          const Text(
            'Ruangan tidak ditemukan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Coba ubah pencarian atau filter ruang yang dipilih.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isCompact;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: isCompact ? 20 : 24, color: color),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 8 : 12),
          Text(
            title,
            style: TextStyle(
              fontSize: isCompact ? 10 : 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isCompact ? 2 : 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isCompact ? 22 : 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final bool isCompact;

  const _BookingCard({required this.booking, required this.isCompact});

  @override
  Widget build(BuildContext context) {
    final status = (booking['status']?.toString() ?? '').toLowerCase();
    final isConfirmed = status == 'approved' || status == 'confirmed';
    final statusLabel = booking['status_label']?.toString() ?? 'Menunggu';
    final statusColor = booking['status_color'] as Color? ?? AppColors.warning;

    return Container(
      padding: EdgeInsets.all(isCompact ? 10 : 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: isCompact ? 45 : 50,
            height: isCompact ? 45 : 50,
            decoration: BoxDecoration(
              color: isConfirmed
                  ? AppColors.successSurface
                  : AppColors.warningSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isConfirmed ? Icons.check_circle_rounded : Icons.schedule_rounded,
              size: isCompact ? 22 : 24,
              color: isConfirmed ? AppColors.accentDark : statusColor,
            ),
          ),
          SizedBox(width: isCompact ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['room'] as String,
                  style: TextStyle(
                    fontSize: isCompact ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: isCompact ? 2 : 2),
                Text(
                  '${booking['date']} • ${booking['time']}',
                  style: TextStyle(
                    fontSize: isCompact ? 10 : 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 6 : 8,
              vertical: isCompact ? 3 : 4,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: isCompact ? 9 : 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Map<String, dynamic> room;
  final bool isCompact;

  const _RoomCard({required this.room, required this.isCompact});

  @override
  Widget build(BuildContext context) {
    final isAvailable = room['available'] as bool? ?? false;
    final roomName = room['name']?.toString() ?? '-';
    final campusName = room['campus']?.toString() ?? '-';
    final roomType = room['type']?.toString() ?? 'Ruang';
    final roomFloor = room['floor']?.toString() ?? '1';
    final roomCapacity = room['capacity']?.toString() ?? '0';

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$roomName dipilih. Buka tab booking untuk lanjut.'),
            duration: const Duration(milliseconds: 800),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAvailable ? AppColors.primary : AppColors.disabled,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Image Area
            Container(
              width: double.infinity,
              height: isCompact ? 85 : 100,
              decoration: BoxDecoration(
                color: isAvailable ? AppColors.primary : AppColors.disabled,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Icon(
                room['icon'] as IconData,
                size: isCompact ? 40 : 48,
                color: AppColors.white,
              ),
            ),
            // Room Details
            Padding(
              padding: EdgeInsets.all(isCompact ? 10 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roomName,
                    style: TextStyle(
                      fontSize: isCompact ? 11 : 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isCompact ? 3 : 4),
                  Text(
                    '$roomType • Lt $roomFloor',
                    style: TextStyle(
                      fontSize: isCompact ? 9 : 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: isCompact ? 6 : 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people_rounded,
                            size: isCompact ? 12 : 14,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: isCompact ? 2 : 4),
                          Text(
                            roomCapacity,
                            style: TextStyle(
                              fontSize: isCompact ? 10 : 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 6 : 8,
                          vertical: isCompact ? 2 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? AppColors.successSurface
                              : AppColors.errorSurface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isAvailable ? 'Tersedia' : 'Terpakai',
                          style: TextStyle(
                            fontSize: isCompact ? 8 : 10,
                            fontWeight: FontWeight.w600,
                            color: isAvailable
                                ? AppColors.accentDark
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 4 : 6),
                  Text(
                    campusName,
                    style: TextStyle(
                      fontSize: isCompact ? 8 : 10,
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
