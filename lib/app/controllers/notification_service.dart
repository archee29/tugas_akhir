import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
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
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print("Notifikasi berhasil dijadwalkan pada: $scheduleTime untuk $title");
  }

  Future<void> fetchAndScheduleNotification(String userId) async {
    final snapshot =
        await databaseReference.child("UsersData/$userId/penjadwalan").get();

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

            print(
                "Notifikasi dijadwalkan: $title pada $scheduleTime dengan deskripsi: $body");
          } catch (e) {
            print("Error parsing date or time: $e");
          }
        } else {
          print("Tanggal atau waktu tidak tersedia untuk $title.");
        }
      });
    } else {
      print("Tidak ada jadwal yang ditemukan.");
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

    print("Notifikasi sukses ditampilkan: $title - $body");
  }
}
