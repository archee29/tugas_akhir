import 'dart:io';
import 'dart:math';
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

    int notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000) +
            Random().nextInt(1000);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
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

/*
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("User tapped on notification: ${response.payload}");
      },
    );

    // Initialize timezone and set to Asia/Jakarta
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

  Future<void> scheduleNotification(int id, TimeOfDay time, String title, String body) async {
    final now = DateTime.now();
    DateTime scheduledDateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    // Adjust the date to tomorrow if the scheduled time is already passed today
    if (scheduledDateTime.isBefore(now)) {
      scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
    }

    final tz.TZDateTime tzScheduledDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);
    print("Notifikasi dijadwalkan pada: $tzScheduledDateTime dengan judul: $title");

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      channelDescription: 'Channel Description',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000) + Random().nextInt(1000);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      tzScheduledDateTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Method to reschedule notifications after device reboot
  Future<void> rescheduleNotificationAfterBoot() async {
    // Retrieve saved notification details from local storage or database
    // and reschedule them using scheduleNotification method.
    // Example (You need to implement logic to get saved notifications):
    List<Map<String, dynamic>> savedNotifications = await retrieveSavedNotifications();
    for (var notification in savedNotifications) {
      int id = notification['id'];
      TimeOfDay time = notification['time'];
      String title = notification['title'];
      String body = notification['body'];
      await scheduleNotification(id, time, title, body);
    }
  }

  // Dummy method to retrieve saved notifications (implement as needed)
  Future<List<Map<String, dynamic>>> retrieveSavedNotifications() async {
    // Example structure: {"id": 1, "time": TimeOfDay(hour: 7, minute: 0), "title": "Jadwal Pagi", "body": "Sudah Waktunya Makan Pagi"}
    return [];
  }
}

*/
