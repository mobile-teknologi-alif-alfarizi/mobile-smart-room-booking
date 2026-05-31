import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_colors.dart';
import 'package:mobile_app/screens/booking_detail_screen.dart';
import 'package:mobile_app/services/booking_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = BookingService();
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _upcomingBookings = [];
  List<Map<String, dynamic>> _pastBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final rawBookings = await _bookingService.getMyBookings();
      final now = DateTime.now();

      final mappedBookings = rawBookings.map((item) {
        final tanggal = item['tanggal']?.toString() ?? '';
        final startTime = _normalizeTime(item['waktu_mulai']?.toString() ?? '00:00');
        final endTime = _normalizeTime(item['waktu_selesai']?.toString() ?? '00:00');
        final backendStatus = item['status']?.toString() ?? 'pending';

        DateTime? endDateTime;
        try {
          endDateTime = DateTime.parse('${tanggal} ${endTime}:00');
        } catch (_) {
          endDateTime = null;
        }

        String status = 'Pending';
        if (backendStatus == 'rejected') {
          status = 'Cancelled';
        } else if (backendStatus == 'approved') {
          status = (endDateTime != null && endDateTime.isBefore(now)) ? 'Completed' : 'Confirmed';
        }

        return {
          'raw_id': item['id'],
          'id': 'BK${item['id']}',
          'room_name': item['ruangan']?['nama_ruangan'] ?? '-',
          'room_type': item['tipe_booking'] == 'jadwal_kelas' ? 'Jadwal Kelas' : 'Peminjaman Mandiri',
          'floor': item['ruangan']?['kampus']?['nama_kampus'] ?? '-',
          'date': _formatDateIndonesia(tanggal),
          'time': '$startTime - $endTime',
          'capacity': '-',
          'status': status,
          'icon': item['tipe_booking'] == 'jadwal_kelas' ? Icons.school_rounded : Icons.meeting_room_rounded,
          'keperluan': item['keperluan']?.toString() ?? '-',
        };
      }).toList();

      final upcoming = <Map<String, dynamic>>[];
      final history = <Map<String, dynamic>>[];

      for (final booking in mappedBookings) {
        final status = booking['status']?.toString() ?? '';
        if (status == 'Confirmed' || status == 'Pending') {
          upcoming.add(booking);
        } else {
          history.add(booking);
        }
      }

      if (!mounted) return;
      setState(() {
        _upcomingBookings = upcoming;
        _pastBookings = history;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString();
      if (errorMsg.contains('Exception:')) {
        errorMsg = errorMsg.replaceAll('Exception: ', '');
      }

      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return AppColors.accent;
      case 'Completed':
        return AppColors.textSecondary;
      case 'Cancelled':
        return AppColors.error;
      case 'Pending':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'Confirmed':
        return 'Dikonfirmasi';
      case 'Completed':
        return 'Selesai';
      case 'Cancelled':
        return 'Dibatalkan';
      case 'Pending':
        return 'Menunggu';
      default:
        return status;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
        title: Text(
          'Booking Saya',
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
                Tab(text: 'Mendatang'),
                Tab(text: 'Riwayat'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upcoming Bookings Tab
          _buildUpcomingBookingsTab(isMobile),
          // History Tab
          _buildHistoryTab(isMobile),
        ],
      ),
    );
  }

  Widget _buildUpcomingBookingsTab(bool isMobile) {
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

    if (_upcomingBookings.isEmpty) {
      return _buildEmptyState(
        isMobile,
        Icons.calendar_today_rounded,
        'Tidak ada booking mendatang',
        'Mulai buat booking untuk ruang yang Anda butuhkan',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        children: List.generate(
          _upcomingBookings.length,
          (index) {
            final booking = _upcomingBookings[index];
            return _buildBookingCard(booking, isMobile, isUpcoming: true);
          },
        ),
      ),
    );
  }

  Widget _buildHistoryTab(bool isMobile) {
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

    if (_pastBookings.isEmpty) {
      return _buildEmptyState(
        isMobile,
        Icons.history_rounded,
        'Tidak ada riwayat booking',
        'Booking Anda akan muncul di sini setelah selesai',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        children: List.generate(
          _pastBookings.length,
          (index) {
            final booking = _pastBookings[index];
            return _buildBookingCard(booking, isMobile, isUpcoming: false);
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    Map<String, dynamic> booking,
    bool isMobile, {
    required bool isUpcoming,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 10 : 12),
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Room name and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 8 : 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        booking['icon'],
                        color: AppColors.primary,
                        size: isMobile ? 16 : 18,
                      ),
                    ),
                    SizedBox(width: isMobile ? 10 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['room_name'],
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            booking['room_type'],
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isMobile ? 8 : 10),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 10,
                  vertical: isMobile ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking['status']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getStatusColor(booking['status']),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getStatusLabel(booking['status']),
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(booking['status']),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 12),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderLight,
          ),
          SizedBox(height: isMobile ? 10 : 12),

          // Details Grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.calendar_today_rounded,
                      label: 'Tanggal',
                      value: booking['date'],
                      isMobile: isMobile,
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 10),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.access_time_rounded,
                      label: 'Waktu',
                      value: booking['time'],
                      isMobile: isMobile,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 8 : 10),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.layers_rounded,
                      label: 'Lantai',
                      value: booking['floor'],
                      isMobile: isMobile,
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 10),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.group_rounded,
                      label: 'Kapasitas',
                      value: booking['capacity'],
                      isMobile: isMobile,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 12),

          // Action Buttons
          if (isUpcoming) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.borderLight,
            ),
            SizedBox(height: isMobile ? 10 : 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showCancelDialog(booking);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 8 : 10,
                      ),
                    ),
                    child: Text(
                      'Batalkan',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailScreen(
                            booking: booking,
                          ),
                        ),
                      );

                      if (result == true) {
                        _loadBookings();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 8 : 10,
                      ),
                    ),
                    child: Text(
                      'Detail',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isMobile,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: isMobile ? 14 : 16,
        ),
        SizedBox(width: isMobile ? 6 : 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 9 : 10,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    bool isMobile,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isMobile ? 48 : 56,
            color: AppColors.borderLight,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: AppColors.error,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              _errorMessage ?? 'Gagal memuat data booking',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: isMobile ? 16 : 20),
            ElevatedButton(
              onPressed: _loadBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(Map<String, dynamic> booking) {
    final parentContext = context;

    showDialog(
      context: context,
      builder: (context) {
        final isMobile = MediaQuery.of(context).size.width < 600;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isMobile ? 44 : 50,
                  height: isMobile ? 44 : 50,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 14),
                Text(
                  'Batalkan Booking?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: isMobile ? 8 : 10),
                Text(
                  'Booking untuk ${booking['room_name']} akan dibatalkan. Pembatalan hanya bisa dilakukan maksimal H-2 dari jadwal booking.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.borderLight),
                          padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Tidak Jadi'),
                      ),
                    ),
                    SizedBox(width: isMobile ? 10 : 12),
                    Expanded(
                      child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                try {
                  await _bookingService.cancelBooking(booking['raw_id'] as int);
                  if (!mounted) return;

                  _loadBookings();
                  await _showCancelSuccessModal(parentContext);
                } catch (e) {
                  if (!mounted) return;

                  String errorMsg = e.toString();
                  if (errorMsg.contains('Exception:')) {
                    errorMsg = errorMsg.replaceAll('Exception: ', '');
                  }

                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text(errorMsg),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Ya, Batalkan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCancelSuccessModal(BuildContext parentContext) async {
    final isMobile = MediaQuery.of(parentContext).size.width < 600;

    await showDialog(
      context: parentContext,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isMobile ? 44 : 50,
                  height: isMobile ? 44 : 50,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.accent,
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 14),
                Text(
                  'Booking Dibatalkan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: isMobile ? 8 : 10),
                Text(
                  'Booking kamu berhasil dibatalkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
