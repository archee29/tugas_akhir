import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:tugas_akhir/app/widgets/dialog/custom_notification.dart';

class CobaNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    print("Notification Plugin Initialized Successfully");
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (status != PermissionStatus.granted) {
        print("Notification Permission Denied");
        throw Exception("Notifikasi Tidak Diizinkan");
      }
      await Permission.scheduleExactAlarm.request();
    }
    print("Notification Permission Granted");
  }

  Future<void> scheduleNotification(
      DateTime scheduleTime, String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        title,
        body,
        tz.TZDateTime.from(scheduleTime, tz.local),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print("Notification scheduled successfully for $scheduleTime");
    } catch (e) {
      print("Error scheduling notification: $e");
      CustomNotification.errorNotification("Terjadi Kesalahan", "Error: $e");
    }
  }

  Future<void> fetchAndScheduleNotification(String userId) async {
    try {
      final snapshot =
          await databaseReference.child("UsersData/$userId/penjadwalan").get();
      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> schedules =
            snapshot.value as Map<dynamic, dynamic>;
        schedules.forEach((key, value) {
          String? tanggal = value['tanggal'];
          String? waktu = value['waktu'];
          String title = value['title'] ?? 'No Title';
          String body = value['deskripsi'] ?? 'No Description';

          if (tanggal != null && waktu != null) {
            try {
              DateTime scheduleTime =
                  DateFormat('MM-dd-yyyy HH:mm').parse('$tanggal $waktu');
              scheduleNotification(scheduleTime, title, body);
            } catch (e) {
              print("Error parsing schedule time: $e");
              CustomNotification.errorNotification(
                  "Terjadi Kesalahan", "Error parsing waktu: $e");
            }
          } else {
            print("Incomplete schedule data: tanggal=$tanggal, waktu=$waktu");
          }
        });
      } else {
        print("No schedules found for userId: $userId");
      }
    } catch (e) {
      print("Error fetching schedule from Firebase: $e");
      CustomNotification.errorNotification("Terjadi Kesalahan", "$e");
    }
  }

  void showSuccessNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'success_channel_id',
      'success_channel_name',
      channelDescription: 'Notifikasi sukses',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
    print("Success notification shown: $title - $body");
  }
}
