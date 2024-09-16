import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("User tapped on notification: ${response.payload}");
      },
    );
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid && (await Permission.scheduleExactAlarm.isDenied)) {
      await Permission.scheduleExactAlarm.request();
    }

    PermissionStatus status = await Permission.notification.request();
    print('Permission Status: $status');
    if (status != PermissionStatus.granted) {
      throw Exception("Notifikasi Tidak Diizinkan");
    }
  }

  Future<void> scheduleNotification(
      int id, TimeOfDay time, String title, String body) async {
    final now = DateTime.now();
    DateTime scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDateTime.isBefore(now)) {
      scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
    }

    final tz.TZDateTime tzScheduledDateTime =
        tz.TZDateTime.from(scheduledDateTime, tz.local);
    print(
        "Notifikasi dijadwalkan pada: $tzScheduledDateTime dengan judul: $title");

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      channelDescription: 'Channel Description',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDateTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
