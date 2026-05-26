import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _bookingConfirmation = true;
  bool _bookingReminder = true;
  bool _bookingCancellation = true;
  bool _systemUpdates = false;
  bool _promotions = false;

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
          'Pengaturan Notifikasi',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // General Settings
                  _buildSectionTitle('Pengaturan Umum', isMobile),
                  SizedBox(height: isMobile ? 12 : 16),
                  _buildNotificationTile(
                    'Push Notifications',
                    'Terima notifikasi push di perangkat Anda',
                    _pushNotifications,
                    (value) {
                      setState(() => _pushNotifications = value);
                    },
                    isMobile,
                  ),
                  SizedBox(height: isMobile ? 10 : 12),
                  _buildNotificationTile(
                    'Email Notifications',
                    'Terima notifikasi melalui email',
                    _emailNotifications,
                    (value) {
                      setState(() => _emailNotifications = value);
                    },
                    isMobile,
                  ),
                  SizedBox(height: isMobile ? 24 : 32),

                  // Booking Notifications
                  _buildSectionTitle('Notifikasi Booking', isMobile),
                  SizedBox(height: isMobile ? 12 : 16),
                  _buildNotificationTile(
                    'Konfirmasi Booking',
                    'Notifikasi ketika booking berhasil dikonfirmasi',
                    _bookingConfirmation,
                    (value) {
                      setState(() => _bookingConfirmation = value);
                    },
                    isMobile,
                    enabled: _pushNotifications,
                  ),
                  SizedBox(height: isMobile ? 10 : 12),
                  _buildNotificationTile(
                    'Pengingat Booking',
                    'Ingatkan 1 jam sebelum jadwal booking',
                    _bookingReminder,
                    (value) {
                      setState(() => _bookingReminder = value);
                    },
                    isMobile,
                    enabled: _pushNotifications,
                  ),
                  SizedBox(height: isMobile ? 10 : 12),
                  _buildNotificationTile(
                    'Pembatalan Booking',
                    'Notifikasi jika booking dibatalkan',
                    _bookingCancellation,
                    (value) {
                      setState(() => _bookingCancellation = value);
                    },
                    isMobile,
                    enabled: _pushNotifications,
                  ),
                  SizedBox(height: isMobile ? 24 : 32),

                  // Other Notifications
                  _buildSectionTitle('Lainnya', isMobile),
                  SizedBox(height: isMobile ? 12 : 16),
                  _buildNotificationTile(
                    'Update Sistem',
                    'Notifikasi tentang pembaruan dan perbaikan sistem',
                    _systemUpdates,
                    (value) {
                      setState(() => _systemUpdates = value);
                    },
                    isMobile,
                  ),
                  SizedBox(height: isMobile ? 10 : 12),
                  _buildNotificationTile(
                    'Promosi & Tips',
                    'Terima tips berguna dan penawaran spesial',
                    _promotions,
                    (value) {
                      setState(() => _promotions = value);
                    },
                    isMobile,
                  ),
                  SizedBox(height: isMobile ? 24 : 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pengaturan notifikasi tersimpan'),
                            backgroundColor: AppColors.accent,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Future.delayed(const Duration(milliseconds: 800), () {
                          if (mounted) Navigator.pop(context);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 12 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Simpan Pengaturan',
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

  Widget _buildNotificationTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isMobile, {
    bool enabled = true,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w600,
                    color: enabled ? AppColors.textPrimary : AppColors.disabled,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    color: enabled ? AppColors.textSecondary : AppColors.disabled,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isMobile ? 10 : 12),
          Switch(
            value: enabled ? value : false,
            onChanged: enabled ? onChanged : null,
            activeColor: AppColors.primary,
            inactiveTrackColor: AppColors.borderLight,
          ),
        ],
      ),
    );
  }
}
