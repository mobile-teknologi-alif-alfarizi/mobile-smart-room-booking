import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/services/notification_service.dart';
import 'package:mobile_app/theme/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with WidgetsBindingObserver {
  final NotificationService _notificationService = NotificationService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Timer? _pollTimer;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  int _unreadCount = 0;
  int? _latestKnownNotificationId;
  List<_NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotifications(playSoundForNew: false);
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadNotifications(playSoundForNew: true, silent: true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNotifications(playSoundForNew: true, silent: true);
    }
  }

  Future<void> _loadNotifications({
    required bool playSoundForNew,
    bool silent = false,
  }) async {
    try {
      if (!silent) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final results = await Future.wait([
        _notificationService.getMyNotifications(),
        _notificationService.getUnreadCount(),
      ]);

      final rawNotifications = results[0] as List<dynamic>;
      final unreadCount = results[1] as int;

      final mappedNotifications = rawNotifications
          .map((item) => _NotificationItem.fromApi(item as Map<String, dynamic>))
          .toList()
        ..sort((left, right) => right.sortKey.compareTo(left.sortKey));

      final previousLatestId = _latestKnownNotificationId;
      final currentLatestId = mappedNotifications.isNotEmpty
          ? mappedNotifications.first.id
          : null;

      if (mounted) {
        setState(() {
          _notifications = mappedNotifications;
          _unreadCount = unreadCount;
          _latestKnownNotificationId = currentLatestId;
          _isLoading = false;
          _isRefreshing = false;
        });
      }

      if (playSoundForNew &&
          previousLatestId != null &&
          currentLatestId != null &&
          currentLatestId > previousLatestId) {
        await _playNotificationSound();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = _extractErrorMessage(e);
      });
    }
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/notifikasi.mp3'));
    } catch (_) {
      // Silent fail if the asset cannot be played.
    }
  }

  String _extractErrorMessage(Object error) {
    final text = error.toString();
    if (text.contains('Exception:')) {
      return text.replaceAll('Exception: ', '');
    }
    return text;
  }

  Future<void> _handleRefresh() async {
    if (!mounted) return;
    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    await _loadNotifications(playSoundForNew: true, silent: true);
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      await _loadNotifications(playSoundForNew: false, silent: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_extractErrorMessage(e)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _openNotificationDetail(_NotificationItem item) async {
    if (!item.isRead) {
      await _notificationService.markAsRead(item.id);
      await _loadNotifications(playSoundForNew: false, silent: true);
    }

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final isMobile = MediaQuery.of(sheetContext).size.width < 600;

        return Container(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 20,
            12,
            isMobile ? 16 : 20,
            MediaQuery.of(sheetContext).padding.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.timeLabel,
                          style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Sumber', item.sourceLabel),
              const SizedBox(height: 8),
              _buildInfoRow('Kategori', item.typeLabel),
              if (item.detailText.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow('Keterangan', item.detailText),
              ],
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  item.message,
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifikasi',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Notifikasi terbaru muncul di atas dan bisa dibuka kapan saja.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                if (_unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$_unreadCount baru',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aktivitas terbaru',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Semua update penting dari sistem dan admin akan muncul di sini.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.white.withValues(alpha: 0.88),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_unreadCount > 0)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _markAllAsRead,
                  icon: const Icon(Icons.done_all_rounded),
                  label: const Text('Tandai semua dibaca'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 56),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              )
            else if (_errorMessage != null)
              _buildErrorState(isMobile)
            else if (_notifications.isEmpty)
              _buildEmptyState(isMobile)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _notifications[index];
                  return _NotificationTile(
                    item: item,
                    onTap: () => _openNotificationDetail(item),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 54),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Notifikasi baru dari sistem atau admin akan tampil di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 54, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 34,
          ),
          const SizedBox(height: 14),
          Text(
            _errorMessage ?? 'Gagal memuat notifikasi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _handleRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  _NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.detailText,
    required this.timeLabel,
    required this.sourceLabel,
    required this.typeLabel,
    required this.icon,
    required this.color,
    required this.isRead,
    required this.sortKey,
  });

  factory _NotificationItem.fromApi(Map<String, dynamic> data) {
    final id = _asInt(data['id']);
    final title = _asText(data['judul'], fallback: 'Notifikasi');
    final message = _asText(data['pesan']);
    final detailText = _asText(data['keterangan']);
    final source = _asText(data['sumber'], fallback: 'system');
    final type = _asText(data['jenis'], fallback: 'general');
    final sentAt = data['dikirim_pada'];
    final timeLabel = _formatRelativeTime(sentAt);
    final isRead = data['dibaca_pada'] != null;

    return _NotificationItem(
      id: id,
      title: title,
      message: message,
      detailText: detailText,
      timeLabel: timeLabel,
      sourceLabel: source == 'admin' ? 'Admin' : 'Sistem',
      typeLabel: _typeLabel(type),
      icon: _iconFor(type, source),
      color: _colorFor(type, source),
      isRead: isRead,
      sortKey: _sortKeyFromDate(sentAt) * 1000000 + id,
    );
  }

  final int id;
  final String title;
  final String message;
  final String detailText;
  final String timeLabel;
  final String sourceLabel;
  final String typeLabel;
  final IconData icon;
  final Color color;
  final bool isRead;
  final int sortKey;

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _asText(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String _typeLabel(String type) {
    switch (type) {
      case 'booking_success':
        return 'Booking';
      case 'kelas_reminder':
        return 'Pengingat Kelas';
      case 'admin_manual':
        return 'Pengumuman';
      default:
        return 'Umum';
    }
  }

  static IconData _iconFor(String type, String source) {
    if (source == 'admin') {
      return Icons.campaign_rounded;
    }

    switch (type) {
      case 'booking_success':
        return Icons.event_available_rounded;
      case 'kelas_reminder':
        return Icons.notifications_active_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  static Color _colorFor(String type, String source) {
    if (source == 'admin') {
      return AppColors.primary;
    }

    switch (type) {
      case 'booking_success':
        return AppColors.accent;
      case 'kelas_reminder':
        return AppColors.primary;
      default:
        return AppColors.warning;
    }
  }

  static String _formatRelativeTime(dynamic value) {
    if (value == null) return '-';

    try {
      final date = DateTime.parse(value.toString()).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) return 'Baru saja';
      if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
      if (difference.inHours < 24) return '${difference.inHours} jam lalu';
      if (difference.inDays < 7) return '${difference.inDays} hari lalu';

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];

      return '${date.day} ${months[date.month - 1]}';
    } catch (_) {
      return value.toString();
    }
  }

  static int _sortKeyFromDate(dynamic value) {
    if (value == null) return 0;
    try {
      return DateTime.parse(value.toString()).millisecondsSinceEpoch;
    } catch (_) {
      return 0;
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final _NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead ? AppColors.white : item.color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: item.isRead ? AppColors.borderLight : item.color.withValues(alpha: 0.22),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                              ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.timeLabel,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                          ),
                          if (!item.isRead) ...[
                            const SizedBox(height: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(item.sourceLabel),
                      _buildChip(item.typeLabel),
                      if (item.isRead)
                        _buildChip('Sudah dibaca', isActive: false)
                      else
                        _buildChip('Belum dibaca', isActive: true),
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

  Widget _buildChip(String text, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? AppColors.error.withValues(alpha: 0.08) : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isActive ? AppColors.error : AppColors.primary,
        ),
      ),
    );
  }
}