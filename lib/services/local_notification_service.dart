import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audioPlayer = AudioPlayer();

  // Initialize notifications settings
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    try {
      await _notificationsPlugin.initialize(
        settings: initializationSettings,
      );

      // Request permission on Android 13+
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Error initializing local notifications: $e');
    }
  }

  // Play notification sound manually using audioplayers as fallback/in-app audio
  static Future<void> playNotificationSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/notifikasi.mp3'));
    } catch (e) {
      debugPrint('Error playing sound with audioplayers: $e');
    }
  }

  // Show a notification specifically for booking success
  static Future<void> showBookingNotification({
    required String roomName,
    required String time,
  }) async {
    // 1. Play sound
    await playNotificationSound();

    // 2. Show native system notification bar
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'booking_channel_id',
      'Booking Notifications',
      channelDescription: 'Notifications for smart room booking confirmation',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notifikasi'),
      playSound: true,
      visibility: NotificationVisibility.public,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    try {
      await _notificationsPlugin.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Booking Berhasil! 🎉',
        body: 'Booking untuk $roomName ($time) telah dikirim.',
        notificationDetails: platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }
}
