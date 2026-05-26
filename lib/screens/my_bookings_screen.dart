import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_colors.dart';
import 'package:mobile_app/screens/booking_detail_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample upcoming bookings
  final List<Map<String, dynamic>> _upcomingBookings = [
    {
      'id': 'BK001',
      'room_name': 'Ruang Meeting A',
      'room_type': 'Meeting Room',
      'floor': '3rd Floor',
      'date': '26 Mei 2026',
      'time': '09:00 - 11:00',
      'capacity': '8-10 orang',
      'status': 'Confirmed',
      'icon': Icons.people_rounded,
    },
    {
      'id': 'BK002',
      'room_name': 'Kelas 201',
      'room_type': 'Class',
      'floor': '2nd Floor',
      'date': '27 Mei 2026',
      'time': '13:00 - 15:00',
      'capacity': '30 orang',
      'status': 'Confirmed',
      'icon': Icons.school_rounded,
    },
    {
      'id': 'BK003',
      'room_name': 'Lab Komputer 3',
      'room_type': 'Computer Lab',
      'floor': '4th Floor',
      'date': '28 Mei 2026',
      'time': '14:00 - 17:00',
      'capacity': '25 orang',
      'status': 'Pending',
      'icon': Icons.computer_rounded,
    },
  ];

  // Sample past bookings
  final List<Map<String, dynamic>> _pastBookings = [
    {
      'id': 'BK004',
      'room_name': 'Ruang Meeting B',
      'room_type': 'Meeting Room',
      'floor': '3rd Floor',
      'date': '25 Mei 2026',
      'time': '10:00 - 12:00',
      'capacity': '8-10 orang',
      'status': 'Completed',
      'icon': Icons.people_rounded,
    },
    {
      'id': 'BK005',
      'room_name': 'Kelas 102',
      'room_type': 'Class',
      'floor': '1st Floor',
      'date': '24 Mei 2026',
      'time': '08:00 - 10:00',
      'capacity': '30 orang',
      'status': 'Completed',
      'icon': Icons.school_rounded,
    },
    {
      'id': 'BK006',
      'room_name': 'Ruang Meeting C',
      'room_type': 'Meeting Room',
      'floor': '2nd Floor',
      'date': '23 Mei 2026',
      'time': '15:00 - 16:00',
      'capacity': '6-8 orang',
      'status': 'Cancelled',
      'icon': Icons.people_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    if (_upcomingBookings.isEmpty) {
      return _buildEmptyState(
        isMobile,
        Icons.calendar_today_rounded,
        'Tidak ada booking mendatang',
        'Mulai buat booking untuk ruang yang Anda butuhkan',
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          children: List.generate(
            _upcomingBookings.length,
            (index) {
              final booking = _upcomingBookings[index];
              return _buildBookingCard(booking, isMobile, isUpcoming: true);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab(bool isMobile) {
    if (_pastBookings.isEmpty) {
      return _buildEmptyState(
        isMobile,
        Icons.history_rounded,
        'Tidak ada riwayat booking',
        'Booking Anda akan muncul di sini setelah selesai',
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          children: List.generate(
            _pastBookings.length,
            (index) {
              final booking = _pastBookings[index];
              return _buildBookingCard(booking, isMobile, isUpcoming: false);
            },
          ),
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
                      _showCancelDialog(booking['room_name']);
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailScreen(
                            booking: booking,
                          ),
                        ),
                      );
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

  void _showCancelDialog(String roomName) {
    showDialog(
      context: context,
      builder: (context) {
        final isMobile = MediaQuery.of(context).size.width < 600;

        return AlertDialog(
          title: Text(
            'Batalkan Booking',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin membatalkan booking untuk $roomName?',
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tidak',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking telah dibatalkan'),
                    backgroundColor: AppColors.error,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text(
                'Batalkan',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
