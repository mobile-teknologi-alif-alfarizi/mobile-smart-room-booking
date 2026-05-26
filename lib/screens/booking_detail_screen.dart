import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_colors.dart';

class BookingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingDetailScreen({
    super.key,
    required this.booking,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
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
          'Detail Booking',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              _buildHeaderCard(isMobile),
              SizedBox(height: isMobile ? 20 : 24),

              // Room Information Section
              _buildSectionTitle('Informasi Ruang', isMobile),
              SizedBox(height: isMobile ? 12 : 16),
              _buildRoomInfoSection(isMobile),
              SizedBox(height: isMobile ? 20 : 24),

              // Booking Details Section
              _buildSectionTitle('Detail Booking', isMobile),
              SizedBox(height: isMobile ? 12 : 16),
              _buildBookingDetailsSection(isMobile),
              SizedBox(height: isMobile ? 20 : 24),

              // Booking Notes Section
              _buildSectionTitle('Catatan Booking', isMobile),
              SizedBox(height: isMobile ? 12 : 16),
              _buildNotesSection(isMobile),
              SizedBox(height: isMobile ? 24 : 32),

              // Action Buttons
              if (widget.booking['status'] == 'Confirmed' ||
                  widget.booking['status'] == 'Pending') ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showRescheduleDialog();
                        },
                        icon: const Icon(Icons.edit_calendar_rounded),
                        label: Text(
                          'Ubah Jadwal',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 10 : 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showCancelDialog();
                        },
                        icon: const Icon(Icons.close_rounded),
                        label: Text(
                          'Batalkan',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 16 : 20),
              ],

              // Info Box
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 12 : 14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: isMobile ? 18 : 20,
                    ),
                    SizedBox(width: isMobile ? 10 : 12),
                    Expanded(
                      child: Text(
                        'Pembatalan dapat dilakukan hingga 1 jam sebelum jadwal booking dimulai.',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 16 : 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 10 : 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.booking['icon'],
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
                            widget.booking['room_name'],
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ID: ${widget.booking['id']}',
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
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 12,
                  vertical: isMobile ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.booking['status'])
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(widget.booking['status']),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _getStatusLabel(widget.booking['status']),
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(widget.booking['status']),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomInfoSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.domain_rounded,
            label: 'Tipe Ruang',
            value: widget.booking['room_type'],
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 12 : 14),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderLight,
          ),
          SizedBox(height: isMobile ? 12 : 14),
          _buildDetailRow(
            icon: Icons.layers_rounded,
            label: 'Lokasi Lantai',
            value: widget.booking['floor'],
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 12 : 14),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderLight,
          ),
          SizedBox(height: isMobile ? 12 : 14),
          _buildDetailRow(
            icon: Icons.group_rounded,
            label: 'Kapasitas',
            value: widget.booking['capacity'],
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Tanggal',
            value: widget.booking['date'],
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 12 : 14),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderLight,
          ),
          SizedBox(height: isMobile ? 12 : 14),
          _buildDetailRow(
            icon: Icons.access_time_rounded,
            label: 'Waktu',
            value: widget.booking['time'],
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 12 : 14),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderLight,
          ),
          SizedBox(height: isMobile ? 12 : 14),
          _buildDetailRow(
            icon: Icons.calendar_month_rounded,
            label: 'Durasi',
            value: _calculateDuration(widget.booking['time']),
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kebutuhan Khusus (Opsional)',
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 10),
          Text(
            'Tidak ada catatan khusus untuk booking ini.',
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
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
          size: isMobile ? 16 : 18,
        ),
        SizedBox(width: isMobile ? 10 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
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

  String _calculateDuration(String timeRange) {
    try {
      final times = timeRange.split(' - ');
      if (times.length == 2) {
        final start = times[0].split(':');
        final end = times[1].split(':');

        if (start.length == 2 && end.length == 2) {
          final startHour = int.parse(start[0]);
          final endHour = int.parse(end[0]);
          final duration = endHour - startHour;
          return '${duration} jam';
        }
      }
    } catch (e) {
      // Silent fail
    }
    return 'N/A';
  }

  void _showRescheduleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final isMobile = MediaQuery.of(context).size.width < 600;

        return AlertDialog(
          title: Text(
            'Ubah Jadwal Booking',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Fitur untuk mengubah jadwal booking akan segera tersedia. Silakan batalkan booking ini dan buat booking baru dengan jadwal yang Anda inginkan.',
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Mengerti',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog() {
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
            'Apakah Anda yakin ingin membatalkan booking untuk ${widget.booking['room_name']}?',
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              color: AppColors.textSecondary,
              height: 1.6,
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
                    backgroundColor: AppColors.accent,
                    duration: Duration(seconds: 2),
                  ),
                );
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) Navigator.pop(context);
                });
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
