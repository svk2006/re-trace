import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {},
    );

    // Explicitly register notification channel on Android (required for Android 8.0+)
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_reminder_channel',
          'Daily Check-in',
          description: 'Reminds you to log your daily check-in',
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
        ),
      );
    }
  }

  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    
    bool? granted = false;
    if (androidPlugin != null) {
      granted = await androidPlugin.requestNotificationsPermission();
      try {
        await androidPlugin.requestExactAlarmsPermission();
      } catch (_) {}
    } else if (iosPlugin != null) {
      granted = await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
    }
    return granted ?? false;
  }

  Future<void> showInstantNotification({String? title, String? body}) async {
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Check-in',
      channelDescription: 'Reminds you to log your daily check-in',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      id: 999,
      title: title ?? 'RE:TRACE Active',
      body: body ?? 'Your daily check-in reminder is configured and working.',
      notificationDetails: details,
    );
  }

  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await _notifications.cancelAll();

    final deviceNow = DateTime.now();
    var target = DateTime(
      deviceNow.year,
      deviceNow.month,
      deviceNow.day,
      time.hour,
      time.minute,
    );

    if (target.isBefore(deviceNow)) {
      target = target.add(const Duration(days: 1));
    }

    // Accurately calculate duration difference to bypass any tz location mismatches
    final difference = target.difference(deviceNow);
    final scheduledDate = tz.TZDateTime.now(tz.local).add(difference);

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Check-in',
      channelDescription: 'Reminds you to log your daily check-in',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _notifications.zonedSchedule(
        id: 0,
        title: 'Time to check in',
        body: 'Take a moment to record your energy and symptoms.',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Fallback to inexact if exact alarm permission is denied on strict Android 13/14
      await _notifications.zonedSchedule(
        id: 0,
        title: 'Time to check in',
        body: 'Take a moment to record your energy and symptoms.',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelReminders() async {
    await _notifications.cancelAll();
  }
}
