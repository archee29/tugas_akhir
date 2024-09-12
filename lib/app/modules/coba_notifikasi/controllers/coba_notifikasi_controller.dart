import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../../routes/app_pages.dart';

import '../../../controllers/notification_service.dart';

class CobaNotifikasiController extends GetxController {
  RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> statusAlatList = <Map<String, dynamic>>[].obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  Timer? timer;

  // Tambahkan Notification Service
  final LocalNotificationService _localNotificationService =
      Get.find<LocalNotificationService>();

  @override
  void onInit() {
    super.onInit();
    _localNotificationService.init();
    _localNotificationService.requestPermissions();

    Future.delayed(Duration.zero, () {
      if (auth.currentUser != null) {
        streamUser().listen((event) {
          userData.value =
              Map<String, dynamic>.from(event.snapshot.value as Map);
        }, onError: (error) {
          print('Error streaming user data: $error');
        });
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }

  // Fungsi untuk menampilkan notifikasi ketika tombol diklik
  void showNotification() {
    _localNotificationService.scheduleNotification(
      DateTime.now().millisecondsSinceEpoch,
      TimeOfDay.now(),
      "Notifikasi Tes",
      "Ini adalah notifikasi percobaan ketika tombol diklik.",
    );
  }

  Stream<DatabaseEvent> streamUser() {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      return database.ref('UsersData/$uid/UsersProfile').onValue;
    } else {
      return const Stream.empty();
    }
  }
}
