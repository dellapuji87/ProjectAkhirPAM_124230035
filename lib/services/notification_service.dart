import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';

class NotificationService {

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final Random _random = Random();

  static const String _favoriteChannelId = 'favorit_channel';
  static const String _favoriteChannelName = 'Favorit Instan';

  static const String _applyChannelId = 'apply_channel';
  static const String _applyChannelName = 'Lamaran Terkirim';

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('notification_icon');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initSettings);

    await _createChannels();

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  Future<void> _createChannels() async {
    const AndroidNotificationChannel favoriteChannel = AndroidNotificationChannel(
      _favoriteChannelId,
      _favoriteChannelName,
      description: 'Notifikasi saat menyimpan favorit',
      importance: Importance.high,
    );

    const AndroidNotificationChannel applyChannel = AndroidNotificationChannel(
      _applyChannelId,
      _applyChannelName,
      description: 'Notifikasi saat lamaran terkirim',
      importance: Importance.high,
    );

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.createNotificationChannel(favoriteChannel);
    await androidImpl?.createNotificationChannel(applyChannel);
  }

  Future<void> showFavoriteNotification(String jobTitle) async {
    const AndroidNotificationDetails details = AndroidNotificationDetails(
      _favoriteChannelId,
      _favoriteChannelName,
      channelDescription: 'Notifikasi saat menyimpan favorit',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'notification_icon',
      showWhen: true,
    );

    await _plugin.show(
      _random.nextInt(100000),
      'Berhasil Disimpan!',
      '$jobTitle ditambahkan ke favorit',
      const NotificationDetails(android: details),
    );
  }

  Future<void> showApplyNotification(int jobId, String jobTitle) async {
    const AndroidNotificationDetails details = AndroidNotificationDetails(
      _applyChannelId,
      _applyChannelName,
      channelDescription: 'Notifikasi saat lamaran terkirim',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'notification_icon',
      showWhen: true,
      playSound: true,
      enableVibration: true,
    );

    final int notificationId = jobId + 1000000; 

    await _plugin.show(
      notificationId,
      'Lamaran Terkirim!',
      'Lamaran Anda untuk $jobTitle telah berhasil diproses.',
      const NotificationDetails(android: details),
    );
  }

  // Opsional: cancel
  Future<void> cancelAll() async => await _plugin.cancelAll();
}