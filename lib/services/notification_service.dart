import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:android_intent_plus/android_intent.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  if (response.actionId == 'increase_a') {
    NotificationService.counterA.value++;
  }

  if (response.actionId == 'increase_b') {
    NotificationService.counterB.value++;
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // 🔥 Counters for test notification
  static final ValueNotifier<int> counterA = ValueNotifier(0);
  static final ValueNotifier<int> counterB = ValueNotifier(0);

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
        if (details.actionId == 'increase_a') {
          counterA.value++;
        }

        if (details.actionId == 'increase_b') {
          counterB.value++;
        }

        final payload = details.payload;
        if (details.actionId == null && payload != null && payload.contains('|')) {
          navigatorKey.currentState
              ?.pushNamed('/alarm', arguments: payload);
        }
      },
      onDidReceiveBackgroundNotificationResponse:
          notificationTapBackground,
    );
  }

  // 🔥 TEST NOTIFICATION WITH 2 BUTTONS
  Future<void> showCounterTestNotification() async {
    await _local.show(
      777,
      'Counter Test',
      'Choose which counter to increase',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_channel',
          'Medicine Reminders',
          importance: Importance.max,
          priority: Priority.high,
          autoCancel: true,
          actions: [
            AndroidNotificationAction(
              'increase_a',
              'Increase Counter A',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              'increase_b',
              'Increase Counter B',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
    );
  }

  // ================= EXISTING MEDICINE METHODS =================

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
      NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_channel',
          'Medicine Reminders',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          playSound: true,
          autoCancel: true,
          sound: const RawResourceAndroidNotificationSound('samsung'),
          actions: const [
            AndroidNotificationAction(
              'increase_a',
              'Increase Counter A',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              'increase_b',
              'Increase Counter B',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload:
          '$id|$medicineName|$doseAmount|$doseUnit|${dateTime.toIso8601String()}',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _local.cancel(id);
  }

  Future<void> cancelAll() async {
    await _local.cancelAll();
  }
}