import 'package:flutter/material.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/services/booking_service.dart';
import 'package:mobile_app/theme/app_colors.dart';
import 'package:mobile_app/widgets/custom_calendar_picker.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  static const int _bookingStartHour = 7;
  static const int _bookingEndHour = 17;
  static const int _bookingStepMinutes = 30;

  late TabController _tabController;
  final BookingService _bookingService = BookingService();
  final AuthService _authService = AuthService();
  final TextEditingController _roomSearchController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  DateTime _selectedDate = DateTime.now();
  String? _selectedCampusName;
  String? _selectedStartTime;
  String? _selectedEndTime;
  int? _selectedRoomId;
  String _bookingType = 'peminjaman_mandiri';
  String _roomSearchQuery = '';

  List<Map<String, dynamic>> _campuses = [];
  List<Map<String, dynamic>> _rooms = [];
  List<Map<String, dynamic>> _allBookings = [];
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _roomSearchController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final results = await Future.wait([
        _bookingService.getCampuses(),
        _bookingService.getRooms(),
        _bookingService.getMyBookings(),
        _bookingService.getAllBookings(),
      ]);

      final campuses = (results[0] as List)
          .cast<Map<String, dynamic>>()
          .map(_mapCampus)
          .toList();
      final rooms = (results[1] as List)
          .cast<Map<String, dynamic>>()
          .map(_mapRoom)
          .toList();
      final bookings = (results[2] as List)
          .cast<Map<String, dynamic>>()
          .map(_mapBooking)
          .toList();
      final allBookings = (results[3] as List)
          .cast<Map<String, dynamic>>()
          .map(_mapBooking)
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _campuses = campuses;
        _rooms = rooms;
        _bookings = bookings;
        _allBookings = allBookings;
        _selectedCampusName ??= campuses.isNotEmpty
            ? campuses.first['name'] as String
            : null;
        _selectedRoomId ??= rooms.isNotEmpty ? rooms.first['id'] as int : null;
        _selectedStartTime ??= _buildTimeOptions().first;
        _selectedEndTime ??= _defaultEndTimeFor(_selectedStartTime!);
        _ensureValidTimeSelection();
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
      'id': item['id'],
      'name': roomName,
      'campus': campusName,
      'label': _getRoomLabel(roomName),
      'icon': _getRoomIcon(roomName),
    };
  }

  Map<String, dynamic> _mapCampus(Map<String, dynamic> item) {
    return {
      'id': item['id'],
      'name': item['nama_kampus']?.toString() ?? '-',
      'address': item['alamat']?.toString() ?? '-',
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
      'id': 'BK${item['id']}',
      'room_name': roomName,
      'campus_name': campusName,
      'date': _formatDateIndonesia(tanggal),
      'time': '$startTime - $endTime',
      'status': status,
      'status_label': _getStatusLabel(status),
      'status_color': _getStatusColor(status),
      'keperluan': item['keperluan']?.toString() ?? '-',
      'icon': _getRoomIcon(roomName),
      'room_id': _toInt(item['ruangan_id']) ?? _toInt(item['ruangan']?['id']),
      'date_key': tanggal,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  String _extractErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('Exception:')) {
      return message.replaceAll('Exception: ', '');
    }
    return message;
  }

  Map<String, dynamic>? get _selectedRoom {
    if (_selectedRoomId == null) {
      return null;
    }

    try {
      return _rooms.firstWhere((room) => room['id'] == _selectedRoomId);
    } catch (_) {
      return _rooms.isNotEmpty ? _rooms.first : null;
    }
  }

  List<Map<String, dynamic>> get _filteredRooms {
    final searchQuery = _roomSearchQuery;

    if (_selectedCampusName == null || _selectedCampusName == 'Semua Kampus') {
      return _rooms.where((room) {
        if (searchQuery.isEmpty) {
          return true;
        }

        final roomName = (room['name'] as String).toLowerCase();
        final campusName = (room['campus'] as String).toLowerCase();
        return roomName.contains(searchQuery) ||
            campusName.contains(searchQuery);
      }).toList();
    }

    return _rooms.where((room) {
      final matchesCampus = room['campus'] == _selectedCampusName;
      if (!matchesCampus) {
        return false;
      }

      if (searchQuery.isEmpty) {
        return true;
      }

      final roomName = (room['name'] as String).toLowerCase();
      final campusName = (room['campus'] as String).toLowerCase();
      return roomName.contains(searchQuery) || campusName.contains(searchQuery);
    }).toList();
  }

  List<List<int>> get _freeIntervalsForSelectedRoom {
    final busyRanges = <List<int>>[];
    final roomId = _selectedRoomId;
    if (roomId == null) {
      return [];
    }

    final selectedDateKey = _formatIsoDate(_selectedDate);
    for (final booking in _allBookings) {
      final bookingRoomId = booking['room_id'] as int?;
      final bookingDateKey = booking['date_key']?.toString() ?? '';

      if (bookingRoomId != roomId || bookingDateKey != selectedDateKey) {
        continue;
      }

      if (booking['status'] == 'rejected') {
        continue;
      }

      final startMinutes = _timeToMinutes(booking['start_time'] as String);
      final endMinutes = _timeToMinutes(booking['end_time'] as String);
      if (endMinutes > startMinutes) {
        busyRanges.add([startMinutes, endMinutes]);
      }
    }

    busyRanges.sort((left, right) => left.first.compareTo(right.first));

    final freeRanges = <List<int>>[];
    var cursor = _bookingStartHour * 60;
    final limit = _bookingEndHour * 60;

    for (final range in busyRanges) {
      final busyStart = range.first.clamp(cursor, limit);
      final busyEnd = range.last.clamp(cursor, limit);

      if (busyStart > cursor) {
        freeRanges.add([cursor, busyStart]);
      }

      if (busyEnd > cursor) {
        cursor = busyEnd;
      }
    }

    if (cursor < limit) {
      freeRanges.add([cursor, limit]);
    }

    return freeRanges.where((range) => range.last > range.first).toList();
  }

  List<String> get _availableStartTimes {
    final startTimes = <String>[];

    for (final range in _freeIntervalsForSelectedRoom) {
      var current = range.first;
      while (current + _bookingStepMinutes <= range.last) {
        startTimes.add(_minutesToTime(current));
        current += _bookingStepMinutes;
      }
    }

    return startTimes;
  }

  List<String> get _availableEndTimes {
    final startTime = _selectedStartTime;
    if (startTime == null) {
      return [];
    }

    final startMinutes = _timeToMinutes(startTime);
    final endTimes = <String>[];

    for (final range in _freeIntervalsForSelectedRoom) {
      if (startMinutes < range.first || startMinutes >= range.last) {
        continue;
      }

      var current = startMinutes + _bookingStepMinutes;
      while (current <= range.last) {
        endTimes.add(_minutesToTime(current));
        current += _bookingStepMinutes;
      }
    }

    return endTimes;
  }

  List<String> _buildTimeOptions() {
    final options = <String>[];
    var currentMinutes = _bookingStartHour * 60;
    final endMinutes = _bookingEndHour * 60;

    while (currentMinutes <= endMinutes) {
      final hour = currentMinutes ~/ 60;
      final minute = currentMinutes % 60;
      options.add(
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
      );
      currentMinutes += _bookingStepMinutes;
    }

    return options;
  }

  String _defaultEndTimeFor(String startTime) {
    final options = _availableEndTimes;
    if (options.isEmpty) {
      return startTime;
    }

    return options.first;
  }

  int _timeIndex(String time) {
    final options = _buildTimeOptions();
    return options.indexOf(time);
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) {
      return 0;
    }

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  String _normalizeDateKey(dynamic value) {
    final rawValue = value?.toString() ?? '';
    if (rawValue.isEmpty) {
      return '';
    }

    final parsedDate = DateTime.tryParse(rawValue);
    if (parsedDate == null) {
      return rawValue.split(' ').first;
    }

    return _formatIsoDate(parsedDate.toLocal());
  }

  String _minutesToTime(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String _formatIsoDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _onCampusChanged(String? campusName) {
    setState(() {
      _selectedCampusName = campusName;
      final availableRooms = _filteredRooms;
      if (availableRooms.isEmpty) {
        _selectedRoomId = null;
        _ensureValidTimeSelection();
        return;
      }

      final selectedRoomStillValid = availableRooms.any(
        (room) => room['id'] == _selectedRoomId,
      );
      if (!selectedRoomStillValid) {
        _selectedRoomId = availableRooms.first['id'] as int;
      }

      _ensureValidTimeSelection();
    });
  }

  void _onStartTimeChanged(String? value) {
    if (value == null) {
      return;
    }

    setState(() {
      _selectedStartTime = value;
      if (_selectedEndTime == null ||
          _timeIndex(_selectedEndTime!) <= _timeIndex(value)) {
        _selectedEndTime = _defaultEndTimeFor(value);
      }
    });
  }

  void _onEndTimeChanged(String? value) {
    if (value == null) {
      return;
    }

    final startTime = _selectedStartTime;
    if (startTime != null && _timeIndex(value) <= _timeIndex(startTime)) {
      return;
    }

    setState(() {
      _selectedEndTime = value;
    });
  }

  void _onRoomSearchChanged(String value) {
    setState(() {
      _roomSearchQuery = value.trim().toLowerCase();
    });
  }

  void _ensureValidTimeSelection() {
    final startOptions = _availableStartTimes;
    if (startOptions.isEmpty) {
      _selectedStartTime = null;
      _selectedEndTime = null;
      return;
    }

    if (_selectedStartTime == null ||
        !startOptions.contains(_selectedStartTime)) {
      _selectedStartTime = startOptions.first;
    }

    final endOptions = _availableEndTimes;
    if (endOptions.isEmpty) {
      _selectedEndTime = null;
      return;
    }

    if (_selectedEndTime == null ||
        !endOptions.contains(_selectedEndTime) ||
        _timeIndex(_selectedEndTime!) <= _timeIndex(_selectedStartTime!)) {
      _selectedEndTime = endOptions.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        centerTitle: false,
        title: Text(
          'Pemesanan Ruang',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: TextStyle(
                fontSize: isMobile ? 12 : 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: isMobile ? 12 : 13,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Buat Booking'),
                Tab(text: 'Riwayat'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingFormTab(isMobile),
          _buildBookingHistoryTab(isMobile),
        ],
      ),
    );
  }

  Widget _buildBookingFormTab(bool isMobile) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState(isMobile);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildHeroCard(isMobile),
          SizedBox(height: isMobile ? 18 : 22),
          _buildSectionTitle('Pilih Kampus', isMobile),
          SizedBox(height: isMobile ? 10 : 12),
          _buildCampusSelector(isMobile),
          SizedBox(height: isMobile ? 18 : 22),
          _buildSectionTitle('Pilih Tanggal', isMobile),
          SizedBox(height: isMobile ? 10 : 12),
          _buildDatePickerCard(isMobile),
          SizedBox(height: isMobile ? 18 : 22),
          _buildSectionTitle('Pilih Ruang', isMobile),
          SizedBox(height: isMobile ? 10 : 12),
          _buildRoomSearchField(isMobile),
          SizedBox(height: isMobile ? 12 : 14),
          _buildRoomList(isMobile),
          if (_selectedRoom != null) ...[
            SizedBox(height: isMobile ? 18 : 22),
            _buildSectionTitle('Pilih Waktu', isMobile),
            SizedBox(height: isMobile ? 10 : 12),
            _buildFlexibleTimeSelector(isMobile),
          ],
          SizedBox(height: isMobile ? 18 : 22),
          _buildSectionTitle('Jenis Booking', isMobile),
          SizedBox(height: isMobile ? 10 : 12),
          _buildBookingTypeSelector(isMobile),
          SizedBox(height: isMobile ? 18 : 22),
          _buildSectionTitle('Keperluan', isMobile),
          SizedBox(height: isMobile ? 10 : 12),
          _buildPurposeField(isMobile),
          if (_selectedRoom != null) ...[
            SizedBox(height: isMobile ? 18 : 22),
            _buildSectionTitle('Ringkasan Booking', isMobile),
            SizedBox(height: isMobile ? 10 : 12),
            _buildBookingSummary(isMobile),
          ],
          SizedBox(height: isMobile ? 20 : 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit() && !_isSubmitting
                  ? () => _submitBooking(context, isMobile)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.disabled,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: isMobile ? 18 : 20,
                      width: isMobile ? 18 : 20,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    )
                  : Text(
                      'Konfirmasi Booking',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
        ],
      ),
    );
  }

  Widget _buildBookingHistoryTab(bool isMobile) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState(isMobile);
    }

    if (_bookings.isEmpty) {
      return _buildEmptyState(
        isMobile,
        Icons.history_rounded,
        'Belum ada riwayat booking',
        'Booking yang Anda buat akan muncul di sini setelah tersimpan.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _bookings.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: isMobile ? 10 : 12),
        itemBuilder: (context, index) {
          return _buildHistoryCard(_bookings[index], isMobile);
        },
      ),
    );
  }

  Widget _buildHeroCard(bool isMobile) {
    final selectedRoom = _selectedRoom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.meeting_room_rounded,
              color: AppColors.white,
              size: isMobile ? 24 : 28,
            ),
          ),
          SizedBox(width: isMobile ? 12 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Ruangan',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: isMobile ? 4 : 6),
                Text(
                  'Semua data ruangan dan booking diambil langsung dari backend.',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: AppColors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: isMobile ? 10 : 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildHeroChip('${_rooms.length} ruangan'),
                    _buildHeroChip('${_bookings.length} riwayat'),
                    if (selectedRoom != null)
                      _buildHeroChip(selectedRoom['campus']?.toString() ?? '-'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isMobile) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isMobile ? 14 : 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDatePickerCard(bool isMobile) {
    return GestureDetector(
      onTap: () async {
        final selectedDate = await showCustomCalendarPicker(
          context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );

        if (selectedDate != null && mounted) {
          setState(() {
            _selectedDate = selectedDate;
          });
          _ensureValidTimeSelection();
        }
      },
      child: Container(
        padding: EdgeInsets.all(isMobile ? 14 : 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 10 : 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: isMobile ? 18 : 20,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: isMobile ? 12 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal booking',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(_selectedDate),
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: isMobile ? 20 : 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusSelector(bool isMobile) {
    final campusOptions = [
      {'name': 'Semua Kampus'},
      ..._campuses,
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedCampusName ?? 'Pilih kampus',
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: campusOptions.map((campus) {
              final campusName = campus['name'].toString();
              final isSelected =
                  _selectedCampusName == campusName ||
                  (_selectedCampusName == null && campusName == 'Semua Kampus');

              return ChoiceChip(
                label: Text(campusName),
                selected: isSelected,
                onSelected: (_) => _onCampusChanged(campusName),
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primaryDark
                      : AppColors.textPrimary,
                ),
                side: const BorderSide(color: AppColors.borderLight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFlexibleTimeSelector(bool isMobile) {
    final selectedRoom = _selectedRoom;
    final startOptions = _availableStartTimes;
    final endOptions = _availableEndTimes;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.white, AppColors.primary.withValues(alpha: 0.04)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 10 : 11),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: AppColors.primaryDark,
                  size: isMobile ? 18 : 20,
                ),
              ),
              SizedBox(width: isMobile ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Slot kosong tersedia',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedRoom == null
                          ? 'Pilih ruangan dulu untuk melihat jam yang tersedia.'
                          : '${selectedRoom['name']} • ${_formatDate(_selectedDate)}',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 12,
                  vertical: isMobile ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${startOptions.length} jam',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    color: AppColors.accentDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 14 : 16),
          if (selectedRoom == null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 14 : 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Silakan pilih ruang terlebih dahulu agar waktu yang tampil hanya yang masih kosong.',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            )
          else if (startOptions.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 14 : 16),
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Tidak ada slot kosong untuk ruang dan tanggal ini.',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            )
          else ...[
            _buildTimeOptionGroup(
              title: 'Jam Mulai',
              subtitle: 'Pilih dari slot yang benar-benar kosong',
              options: startOptions,
              selectedValue: _selectedStartTime,
              isMobile: isMobile,
              onSelected: _onStartTimeChanged,
            ),
            SizedBox(height: isMobile ? 14 : 16),
            _buildTimeOptionGroup(
              title: 'Jam Selesai',
              subtitle: 'Menyesuaikan dengan jam mulai yang dipilih',
              options: endOptions,
              selectedValue: _selectedEndTime,
              isMobile: isMobile,
              onSelected: _onEndTimeChanged,
            ),
            SizedBox(height: isMobile ? 12 : 14),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 12 : 14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Yang ditampilkan hanya jam kosong untuk ruang terpilih. Kalau jam mulai berubah, jam selesai ikut menyesuaikan.',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeOptionGroup({
    required String title,
    required String subtitle,
    required List<String> options,
    required String? selectedValue,
    required bool isMobile,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 10 : 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((time) {
              final isSelected = selectedValue == time;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => onSelected(time),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 14 : 16,
                      vertical: isMobile ? 10 : 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: AppColors.primaryGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.borderLight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.25)
                              : Colors.black.withValues(alpha: 0.03),
                          blurRadius: isSelected ? 14 : 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '30 menit',
                          style: TextStyle(
                            fontSize: isMobile ? 9 : 10,
                            color: isSelected
                                ? AppColors.white.withValues(alpha: 0.82)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomSearchField(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _roomSearchController,
        onChanged: _onRoomSearchChanged,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _roomSearchQuery.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _roomSearchController.clear();
                    _onRoomSearchChanged('');
                  },
                ),
          hintText: 'Cari ruang atau kampus',
          hintStyle: TextStyle(
            color: AppColors.textTertiary,
            fontSize: isMobile ? 12 : 13,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 16,
            vertical: isMobile ? 14 : 16,
          ),
        ),
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: isMobile ? 13 : 14,
        ),
      ),
    );
  }

  Widget _buildBookingTypeSelector(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 11),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.lock_rounded,
              color: AppColors.primaryDark,
              size: isMobile ? 18 : 20,
            ),
          ),
          SizedBox(width: isMobile ? 12 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peminjaman Mandiri',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mode booking mobile dikunci ke peminjaman mandiri agar alur pengajuan lebih cepat dan konsisten.',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeField(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextField(
        controller: _purposeController,
        maxLines: 3,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          hintText:
              'Contoh: Seminar internal prodi, rapat organisasi, kelas pengganti',
          hintStyle: TextStyle(
            color: AppColors.textTertiary,
            fontSize: isMobile ? 12 : 13,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(isMobile ? 14 : 16),
        ),
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: isMobile ? 13 : 14,
        ),
      ),
    );
  }

  Widget _buildRoomList(bool isMobile) {
    if (_filteredRooms.isEmpty) {
      final hasSearch = _roomSearchQuery.isNotEmpty;
      return _buildEmptyState(
        isMobile,
        Icons.meeting_room_outlined,
        hasSearch ? 'Ruangan tidak ditemukan' : 'Belum ada ruangan',
        hasSearch
            ? 'Coba ubah kata kunci pencarian atau pilih kampus lain.'
            : 'Data ruangan belum tersedia untuk kampus yang dipilih.',
      );
    }

    return Column(
      children: _filteredRooms.map((room) {
        final isSelected = _selectedRoomId == room['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRoomId = room['id'] as int;
            });
            _ensureValidTimeSelection();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(isMobile ? 14 : 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: isMobile ? 46 : 52,
                  height: isMobile ? 46 : 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    room['icon'] as IconData,
                    size: isMobile ? 22 : 24,
                    color: isSelected ? AppColors.white : AppColors.primary,
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room['name'] as String,
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: isMobile ? 12 : 14,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: isMobile ? 4 : 6),
                          Expanded(
                            child: Text(
                              room['campus'] as String,
                              style: TextStyle(
                                fontSize: isMobile ? 10 : 11,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 10,
                    vertical: isMobile ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    room['label'] as String,
                    style: TextStyle(
                      fontSize: isMobile ? 9 : 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBookingSummary(bool isMobile) {
    final selectedRoom = _selectedRoom;
    if (selectedRoom == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Tanggal', _formatDate(_selectedDate), isMobile),
          Divider(color: AppColors.borderLight, height: isMobile ? 18 : 22),
          _buildSummaryRow(
            'Waktu',
            '${_selectedStartTime ?? '-'} - ${_selectedEndTime ?? '-'}',
            isMobile,
          ),
          Divider(color: AppColors.borderLight, height: isMobile ? 18 : 22),
          _buildSummaryRow('Ruang', selectedRoom['name'] as String, isMobile),
          Divider(color: AppColors.borderLight, height: isMobile ? 18 : 22),
          _buildSummaryRow(
            'Kampus',
            selectedRoom['campus'] as String,
            isMobile,
          ),
          Divider(color: AppColors.borderLight, height: isMobile ? 18 : 22),
          _buildSummaryRow(
            'Jenis',
            _bookingType == 'jadwal_kelas'
                ? 'Jadwal Kelas'
                : 'Peminjaman Mandiri',
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> booking, bool isMobile) {
    final statusColor = booking['status_color'] as Color;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  booking['icon'] as IconData,
                  color: AppColors.primary,
                  size: isMobile ? 18 : 20,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['room_name'] as String,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: isMobile ? 4 : 6),
                    Text(
                      booking['campus_name'] as String,
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: isMobile ? 8 : 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip(
                          Icons.calendar_today_rounded,
                          booking['date'] as String,
                          isMobile,
                        ),
                        _buildInfoChip(
                          Icons.access_time_rounded,
                          booking['time'] as String,
                          isMobile,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 12,
                  vertical: isMobile ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  booking['status_label'] as String,
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 14),
          Text(
            booking['keperluan'] as String,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 10,
        vertical: isMobile ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 11 : 12, color: AppColors.textSecondary),
          SizedBox(width: isMobile ? 4 : 5),
          Text(
            text,
            style: TextStyle(
              fontSize: isMobile ? 10 : 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: isMobile ? 44 : 52,
              color: AppColors.error,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              'Gagal memuat data booking',
              style: TextStyle(
                fontSize: isMobile ? 15 : 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: isMobile ? 8 : 10),
            Text(
              _errorMessage ?? 'Terjadi kesalahan tidak dikenal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: isMobile ? 16 : 18),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 18,
                  vertical: isMobile ? 10 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    bool isMobile,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isMobile ? 44 : 52,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 15 : 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: isMobile ? 8 : 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canSubmit() {
    return _selectedRoom != null && _purposeController.text.trim().isNotEmpty;
  }

  Future<void> _submitBooking(BuildContext context, bool isMobile) async {
    final selectedRoom = _selectedRoom;
    if (selectedRoom == null) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    final purpose = _purposeController.text.trim();
    if (purpose.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Isi keperluan booking terlebih dahulu.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      Map<String, dynamic>? user = await _authService.getStoredUser();
      if (user == null) {
        final profile = await _authService.getProfile();
        user = profile['user'] as Map<String, dynamic>?;
      }

      final userId = user?['id'] as int?;
      if (userId == null) {
        throw Exception('Data pengguna tidak ditemukan. Silakan login ulang.');
      }

      final selectedStartTime = _selectedStartTime;
      final selectedEndTime = _selectedEndTime;

      if (selectedStartTime == null || selectedEndTime == null) {
        throw Exception('Pilih jam mulai dan jam selesai terlebih dahulu.');
      }

      await _bookingService.createBooking(
        userId: userId,
        ruanganId: selectedRoom['id'] as int,
        tanggal: _formatDateForApi(_selectedDate),
        waktuMulai: selectedStartTime,
        waktuSelesai: selectedEndTime,
        keperluan: purpose,
        tipeBooking: 'peminjaman_mandiri',
      );

      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text('Booking ${selectedRoom['name']} berhasil dikirim.'),
          backgroundColor: AppColors.accent,
        ),
      );

      setState(() {
        _purposeController.clear();
        _bookingType = 'peminjaman_mandiri';
      });

      await _loadData();
      if (!mounted) {
        return;
      }

      final goToHistory = await _showBookingSuccessModal(
        context,
        selectedRoom['name'] as String,
      );
      if (mounted && goToHistory == true) {
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(_extractErrorMessage(e)),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<bool?> _showBookingSuccessModal(
    BuildContext context,
    String roomName,
  ) async {
    final selectedTime = '${_selectedStartTime ?? '-'} - ${_selectedEndTime ?? '-'}';

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Booking berhasil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking untuk ruangan $roomName sudah tersimpan dengan mode peminjaman mandiri.',
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              _buildModalInfoRow('Tanggal', _formatDate(_selectedDate)),
              const SizedBox(height: 8),
              _buildModalInfoRow('Waktu', selectedTime),
              const SizedBox(height: 8),
              _buildModalInfoRow(
                'Jenis',
                'Peminjaman Mandiri',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Lihat Riwayat'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModalInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 68,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(color: AppColors.textSecondary)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getRoomIcon(String roomName) {
    final normalized = roomName.toLowerCase();
    if (normalized.contains('lab')) {
      return Icons.computer_rounded;
    }
    if (normalized.contains('meeting') || normalized.contains('rapat')) {
      return Icons.table_chart_rounded;
    }
    if (normalized.contains('aula')) {
      return Icons.domain_rounded;
    }
    return Icons.school_rounded;
  }

  String _getRoomLabel(String roomName) {
    final normalized = roomName.toLowerCase();
    if (normalized.contains('lab')) {
      return 'Lab';
    }
    if (normalized.contains('meeting') || normalized.contains('rapat')) {
      return 'Rapat';
    }
    if (normalized.contains('aula')) {
      return 'Aula';
    }
    return 'Ruang';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'confirmed':
        return AppColors.accent;
      case 'rejected':
      case 'cancelled':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      case 'completed':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Disetujui';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'rejected':
      case 'cancelled':
        return 'Dibatalkan';
      case 'pending':
        return 'Menunggu';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  String _normalizeTime(String rawTime) {
    if (rawTime.length >= 5) {
      return rawTime.substring(0, 5);
    }
    return rawTime;
  }

  String _formatDateIndonesia(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
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

      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDate(DateTime date) {
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
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
