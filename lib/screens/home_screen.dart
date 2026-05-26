import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Kelas', 'Ruang Meeting', 'Lab'];
  
  // Current user data (dummy - dapat diganti dengan data dari API)
  final String _userName = 'Ghaida Alfarizi';

  // Dummy data for available rooms
  final List<Map<String, dynamic>> _availableRooms = [
    {
      'name': 'Ruang A1',
      'type': 'Kelas',
      'capacity': 40,
      'available': true,
      'floor': 1,
      'icon': Icons.school_rounded,
    },
    {
      'name': 'Ruang Meeting 201',
      'type': 'Ruang Meeting',
      'capacity': 10,
      'available': true,
      'floor': 2,
      'icon': Icons.table_chart_rounded,
    },
    {
      'name': 'Lab Komputer',
      'type': 'Lab',
      'capacity': 30,
      'available': false,
      'floor': 3,
      'icon': Icons.computer_rounded,
    },
    {
      'name': 'Ruang B2',
      'type': 'Kelas',
      'capacity': 50,
      'available': true,
      'floor': 1,
      'icon': Icons.school_rounded,
    },
  ];

  // Dummy data for upcoming bookings
  final List<Map<String, dynamic>> _upcomingBookings = [
    {
      'room': 'Ruang A1',
      'date': 'Hari ini',
      'time': '10:00 - 12:00',
      'status': 'Terkonfirmasi',
    },
    {
      'room': 'Ruang Meeting 201',
      'date': 'Besok',
      'time': '14:00 - 15:00',
      'status': 'Menunggu Konfirmasi',
    },
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return Icons.light_mode_rounded;
    } else if (hour < 15) {
      return Icons.wb_sunny_rounded;
    } else if (hour < 18) {
      return Icons.wb_twilight_rounded;
    } else {
      return Icons.nights_stay_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Section
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
                          // Dynamic Greeting with Icon
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
                          // User Name - Responsive
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
                    // Profile Avatar - Responsive
                    Container(
                      width: isMobile ? 45 : 50,
                      height: isMobile ? 45 : 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
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
                // Search Bar - Responsive
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
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
                          decoration: InputDecoration(
                            hintText: 'Cari ruang atau kelas...',
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
              ],
            ),
          ),

          // Quick Stats Section - Responsive
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Booking Aktif',
                    value: '2',
                    color: AppColors.primary,
                    isCompact: isMobile,
                  ),
                ),
                SizedBox(width: isMobile ? 10 : 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_rounded,
                    title: 'Tersedia',
                    value: '3',
                    color: AppColors.accent,
                    isCompact: isMobile,
                  ),
                ),
              ],
            ),
          ),

          // Upcoming Bookings Section
          if (_upcomingBookings.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(isMobile ? 16 : 20, 0, isMobile ? 16 : 20, isMobile ? 16 : 20),
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
                  ..._upcomingBookings.map((booking) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BookingCard(
                        booking: booking,
                        isCompact: isMobile,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

          // Filter Chips
          Padding(
            padding: EdgeInsets.fromLTRB(isMobile ? 16 : 20, isMobile ? 10 : 12, isMobile ? 16 : 20, 0),
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
                          onSelected: (value) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          backgroundColor: AppColors.lightGray,
                          selectedColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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

          // Available Rooms Grid - Responsive
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 3,
                crossAxisSpacing: isMobile ? 10 : 12,
                mainAxisSpacing: isMobile ? 10 : 12,
                childAspectRatio: isMobile ? 0.9 : 0.95,
              ),
              itemCount: _availableRooms.length,
              itemBuilder: (context, index) {
                return _RoomCard(
                  room: _availableRooms[index],
                  isCompact: isMobile,
                );
              },
            ),
          ),

          // Bottom padding
          const SizedBox(height: 20),
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
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: isCompact ? 20 : 24,
                color: color,
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
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

  const _BookingCard({
    required this.booking,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final isConfirmed = booking['status'] == 'Terkonfirmasi';

    return Container(
      padding: EdgeInsets.all(isCompact ? 10 : 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConfirmed ? AppColors.accent : AppColors.warning,
          width: 1.5,
        ),
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
              color: isConfirmed ? AppColors.accentDark : AppColors.warning,
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
              color: isConfirmed
                  ? AppColors.successSurface
                  : AppColors.warningSurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isConfirmed ? 'Aktif' : 'Pending',
              style: TextStyle(
                fontSize: isCompact ? 9 : 11,
                fontWeight: FontWeight.w600,
                color: isConfirmed ? AppColors.accentDark : AppColors.warning,
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

  const _RoomCard({
    required this.room,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = room['available'] as bool;

    return GestureDetector(
      onTap: () {
        // Navigate to booking screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking ${room['name']} - Coming soon'),
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
                    room['name'] as String,
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
                    '${room['type']} • Lt ${room['floor']}',
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
                            '${room['capacity']}',
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
                          isAvailable ? 'Tersedia' : 'Penuh',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
