import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
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
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid && (await Permission.scheduleExactAlarm.isDenied)) {
      await Permission.scheduleExactAlarm.request();
    }
    PermissionStatus status = await Permission.notification.request();
    if (status != PermissionStatus.granted) {
      throw Exception("Notifikasi Tidak Diizinkan");
    }
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

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.from(scheduleTime, tz.local),
      platformChannelSpecifics,
      // ignore: deprecated_member_use
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> fetchAndScheduleNotification(String userId) async {
    final snapshot =
        await databaseReference.child("UsersData/$userId/cobaNotifikasi").get();

    if (snapshot.exists && snapshot.value != null) {
      Map<dynamic, dynamic> schedules = snapshot.value as Map<dynamic, dynamic>;

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
            CustomNotification.errorNotification("Error", "Parsing Waktu :$e");
            print("Error : $e");
          }
        } else {
          CustomNotification.errorNotification(
              "Error", "Tangal/Waktu tidak tersedia :$title");
        }
      });
    } else {
      CustomNotification.errorNotification(
          "Error", "Tidak Ada Jadwal Yang Ditemukan");
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
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
