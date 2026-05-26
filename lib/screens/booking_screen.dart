import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_colors.dart';
import 'package:mobile_app/widgets/custom_calendar_picker.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '09:00 - 11:00';
  String? _selectedRoom;

  final List<Map<String, dynamic>> _availableRooms = [
    {
      'id': 1,
      'name': 'Ruang A1',
      'type': 'Kelas',
      'capacity': 40,
      'floor': 1,
      'icon': Icons.school_rounded,
    },
    {
      'id': 2,
      'name': 'Ruang Meeting 201',
      'type': 'Ruang Meeting',
      'capacity': 10,
      'floor': 2,
      'icon': Icons.table_chart_rounded,
    },
    {
      'id': 3,
      'name': 'Lab Komputer',
      'type': 'Lab',
      'capacity': 30,
      'floor': 3,
      'icon': Icons.computer_rounded,
    },
    {
      'id': 4,
      'name': 'Ruang B2',
      'type': 'Kelas',
      'capacity': 50,
      'floor': 1,
      'icon': Icons.school_rounded,
    },
  ];

  final List<String> _timeSlots = [
    '07:00 - 09:00',
    '09:00 - 11:00',
    '11:00 - 13:00',
    '13:00 - 15:00',
    '15:00 - 17:00',
    '17:00 - 19:00',
  ];

  final List<Map<String, dynamic>> _bookingHistory = [
    {
      'room': 'Ruang A1',
      'date': '25 May 2026',
      'time': '10:00 - 12:00',
      'status': 'Selesai',
      'attendees': 35,
    },
    {
      'room': 'Ruang Meeting 201',
      'date': '23 May 2026',
      'time': '14:00 - 15:00',
      'status': 'Selesai',
      'attendees': 8,
    },
    {
      'room': 'Lab Komputer',
      'date': '20 May 2026',
      'time': '09:00 - 11:00',
      'status': 'Selesai',
      'attendees': 25,
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Text(
                'Buat Booking',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Riwayat',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Buat Booking
          _buildBookingForm(context, isMobile),
          // Tab 2: Riwayat Booking
          _buildBookingHistory(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildBookingForm(BuildContext context, bool isMobile) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Selection
                _buildSectionTitle('Pilih Tanggal', isMobile),
                SizedBox(height: isMobile ? 10 : 12),
                _buildDatePicker(context, isMobile),
                SizedBox(height: isMobile ? 20 : 24),

                // Time Selection
                _buildSectionTitle('Pilih Waktu', isMobile),
                SizedBox(height: isMobile ? 10 : 12),
                _buildTimeSlots(isMobile),
                SizedBox(height: isMobile ? 20 : 24),

                // Room Selection
                _buildSectionTitle('Pilih Ruang', isMobile),
                SizedBox(height: isMobile ? 10 : 12),
                _buildRoomList(isMobile),
                SizedBox(height: isMobile ? 24 : 32),

                // Booking Summary
                if (_selectedRoom != null) ...[
                  _buildSectionTitle('Ringkasan Booking', isMobile),
                  SizedBox(height: isMobile ? 10 : 12),
                  _buildBookingSummary(isMobile),
                  SizedBox(height: isMobile ? 20 : 24),
                ],

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedRoom != null
                        ? () {
                            _showConfirmDialog(context, isMobile);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.disabled,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 12 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
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
          ),
        ],
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

  Widget _buildDatePicker(BuildContext context, bool isMobile) {
    return GestureDetector(
      onTap: () async {
        final selectedDate = await showCustomCalendarPicker(
          context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (selectedDate != null) {
          setState(() {
            _selectedDate = selectedDate;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: isMobile ? 20 : 24,
              color: AppColors.primary,
            ),
            SizedBox(width: isMobile ? 10 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
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

  Widget _buildTimeSlots(bool isMobile) {
    return Wrap(
      spacing: isMobile ? 8 : 10,
      runSpacing: isMobile ? 8 : 10,
      children: _timeSlots.map((time) {
        final isSelected = _selectedTime == time;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTime = time;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoomList(bool isMobile) {
    return Column(
      children: _availableRooms.map((room) {
        final isSelected = _selectedRoom == room['name'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRoom = room['name'];
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(isMobile ? 12 : 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: isMobile ? 45 : 50,
                  height: isMobile ? 45 : 50,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    room['icon'] as IconData,
                    size: isMobile ? 22 : 24,
                    color: isSelected ? AppColors.white : AppColors.primary,
                  ),
                ),
                SizedBox(width: isMobile ? 10 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room['name'] as String,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: isMobile ? 12 : 14,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: isMobile ? 3 : 4),
                          Text(
                            '${room['type']} • Lantai ${room['floor']}',
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: isMobile ? 14 : 16,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: isMobile ? 2 : 4),
                        Text(
                          '${room['capacity']}',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 6 : 8,
                        vertical: isMobile ? 2 : 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successSurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Tersedia',
                        style: TextStyle(
                          fontSize: isMobile ? 9 : 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBookingSummary(bool isMobile) {
    final selectedRoom = _availableRooms.firstWhere(
      (room) => room['name'] == _selectedRoom,
      orElse: () => _availableRooms[0],
    );

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Tanggal', _formatDate(_selectedDate), isMobile),
          Divider(
            color: AppColors.borderLight,
            height: isMobile ? 16 : 20,
          ),
          _buildSummaryRow('Waktu', _selectedTime, isMobile),
          Divider(
            color: AppColors.borderLight,
            height: isMobile ? 16 : 20,
          ),
          _buildSummaryRow('Ruang', _selectedRoom!, isMobile),
          Divider(
            color: AppColors.borderLight,
            height: isMobile ? 16 : 20,
          ),
          _buildSummaryRow(
            'Kapasitas',
            '${selectedRoom['capacity']} orang',
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
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingHistory(BuildContext context, bool isMobile) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          children: _bookingHistory.map((booking) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(isMobile ? 12 : 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['room'] as String,
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: isMobile ? 12 : 14,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: isMobile ? 4 : 6),
                                Text(
                                  booking['date'] as String,
                                  style: TextStyle(
                                    fontSize: isMobile ? 10 : 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 10,
                          vertical: isMobile ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking['status'] as String,
                          style: TextStyle(
                            fontSize: isMobile ? 9 : 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 10 : 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: isMobile ? 12 : 14,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: isMobile ? 4 : 6),
                          Text(
                            booking['time'] as String,
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.people_rounded,
                            size: isMobile ? 12 : 14,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: isMobile ? 4 : 6),
                          Text(
                            '${booking['attendees']} orang',
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showConfirmDialog(BuildContext context, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Booking',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow('Ruang', _selectedRoom!, isMobile),
            const SizedBox(height: 12),
            _buildDialogRow('Tanggal', _formatDate(_selectedDate), isMobile),
            const SizedBox(height: 12),
            _buildDialogRow('Waktu', _selectedTime, isMobile),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking "$_selectedRoom" berhasil dikonfirmasi!'),
                  backgroundColor: AppColors.accent,
                  duration: const Duration(seconds: 2),
                ),
              );
              // Reset form
              setState(() {
                _selectedRoom = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'Konfirmasi',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
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
}
