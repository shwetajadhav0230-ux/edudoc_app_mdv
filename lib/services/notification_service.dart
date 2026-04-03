// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Android Initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/macOS Initialization
    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<bool> requestPermissions() async {
    // iOS Permission Request
    final bool? iosResult = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android 13+ Permission Request
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final bool? androidResult =
    await androidImplementation?.requestNotificationsPermission();

    return iosResult ?? androidResult ?? false;
  }

  // --- 1. Basic Notification (Your existing method) ---
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'edudoc_main_channel', // id
      'EduDoc Notifications', // title
      channelDescription: 'Main channel for app notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  // --- 2. Progress Bar Notification (Added for Downloads) ---
  Future<void> showProgressNotification({
    required int id,
    required int progress,
    required String title,
    required String body,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'edudoc_download_channel', // Separate channel for downloads
      'File Downloads',
      channelDescription: 'Progress of file downloads',
      importance: Importance.low, // Low importance prevents "dinging" sound on every 1% update
      priority: Priority.low,
      onlyAlertOnce: true, // Crucial: Only alert on the first notification
      showProgress: true,
      maxProgress: 100,
      progress: progress,
    );

    final NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(id, title, body, details);
  }

  // --- 3. Completion Notification (Added for Downloads) ---
  Future<void> showCompletionNotification({
    required int id,
    required String title,
    required String body,
    required bool isSuccess,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'edudoc_download_channel',
      'File Downloads',
      channelDescription: 'Progress of file downloads',
      importance: Importance.high, // High importance so user sees the result
      priority: Priority.high,
      onlyAlertOnce: false,
      showProgress: false, // Turn off the progress bar
    );

    final NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      isSuccess ? "Download Complete" : "Download Failed",
      isSuccess ? title : "Could not download $title",
      details,
    );
  }
}