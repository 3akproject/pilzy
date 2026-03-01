import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:android_intent_plus/android_intent.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const AndroidNotificationChannel channel =
        AndroidNotificationChannel(
      'medicine_channel',
      'Medicine Reminders',
      description: 'Channel for medicine reminders',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('samsung'),
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload != null) {
          navigatorKey.currentState
              ?.pushNamed('/alarm', arguments: payload);
        }
      },
    );
  }

  /// 🔔 MEDICINE REMINDER
  Future<void> scheduleMedicineReminder({
    required int id,
    required DateTime dateTime,
    required String medicineName,
    required String doseAmount,
    required String doseUnit,
  }) async {
    final scheduledTZ = tz.TZDateTime.from(dateTime, tz.local);

    await _local.zonedSchedule(
      id,
      'Medicine Reminder',
      '$medicineName - $doseAmount $doseUnit',
      scheduledTZ,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_channel',
          'Medicine Reminders',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('samsung'),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload:
          '$medicineName|$doseAmount|$doseUnit|${dateTime.toIso8601String()}',
    );
  }

  /// 🔔 GENERAL DAILY ALERT (Alerts Page)
  Future<void> scheduleDailyGeneralAlert({
    required int id,
    required DateTime dateTime,
  }) async {
    final scheduledTZ = tz.TZDateTime.from(dateTime, tz.local);

    await _local.zonedSchedule(
      id,
      'Pilzy Alert',
      'This is your scheduled daily alert',
      scheduledTZ,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_channel',
          'Medicine Reminders',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('samsung'),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload:
          'Daily Alert|1|Time|${dateTime.toIso8601String()}',
    );
  }

  Future<void> instantTest() async {
    final now = DateTime.now();
    await _local.show(
      999,
      'Test Alarm',
      'Take 1 Tablet',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_channel',
          'Medicine Reminders',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('samsung'),
        ),
      ),
      payload: 'Test Med|1|Tablet|${now.toIso8601String()}',
    );
  }

  Future<bool> isExactAlarmAllowed() async {
    if (Platform.isAndroid) {
      final androidPlugin = _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  Future<void> openExactAlarmSettings() async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
          action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM');
      await intent.launch();
    }
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required tz.TZDateTime dateTime,
    required String medicineName,
    required String doseAmount,
    required String doseUnit,
  }) async {
    await _local.zonedSchedule(
      id,
      'Medicine Reminder',
      '$medicineName - $doseAmount $doseUnit',
      dateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_channel',
          'Medicine Reminders',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('samsung'),
        ),
      ),
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime,
      payload:
          '$medicineName|$doseAmount|$doseUnit|${dateTime.toIso8601String()}',
    );
  }

  Future<void> cancelNotification(int id) async {
  await _local.cancel(id);
}
}