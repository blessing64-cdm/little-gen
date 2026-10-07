import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationManager {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initializes the local notifications plugin and timezones
  static Future<void> initialize() async {
    if (kIsWeb || _initialized) return;

    // 1. Initialize time zones for local scheduling
    tz.initializeTimeZones();

    // 2. Configure Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // 3. Configure iOS settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 4. Combine initialization settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // 5. Initialize the plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle tapping on notification if needed
      },
    );

    // 6. Request notification permissions (vital for Android 13+ and iOS)
    await requestPermissions();

    _initialized = true;
  }

  /// Request permissions for Android and iOS
  static Future<void> requestPermissions() async {
    // Request Android post notifications permission
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Request iOS permissions
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Cancel all scheduled and active notifications
  static Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancelAll();
  }

  /// Schedules local notifications to remind user to return to app
  static Future<void> scheduleBackgroundReminders() async {
    if (kIsWeb) return;
    try {
      // Cancel existing scheduled ones to avoid duplicates
      await cancelAllNotifications();

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'little_gen_reminders',
        'Little Gen Reminders',
        channelDescription: 'Educational reminders to continue learning',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final now = tz.TZDateTime.now(tz.local);

      // Reminder 1: 10 seconds later (Demonstration reminder)
      await _notificationsPlugin.zonedSchedule(
        1,
        'We miss you already! 🦊',
        'Come back and play to earn more Gold Stars! 🌟',
        now.add(const Duration(seconds: 10)),
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      // Reminder 2: 5 minutes later
      await _notificationsPlugin.zonedSchedule(
        2,
        'Time to learn! 📚',
        'Sam the Seal is waiting for you in Story Time! 🌊',
        now.add(const Duration(minutes: 5)),
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      // Reminder 3: 1 hour later
      await _notificationsPlugin.zonedSchedule(
        3,
        'Little Gen is Calling! 💖',
        'Let\'s build some words and track your gold star progress! 👑',
        now.add(const Duration(hours: 1)),
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint("Notification schedule error: $e");
    }
  }
}
