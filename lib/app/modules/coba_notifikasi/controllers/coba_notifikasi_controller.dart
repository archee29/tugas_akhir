import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../../routes/app_pages.dart';

import '../../../controllers/foreground_service.dart';

class CobaNotifikasiController extends GetxController {
  RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> statusAlatList = <Map<String, dynamic>>[].obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  Timer? timer;

  final ForegroundNotification _foregroundNotification =
      Get.find<ForegroundNotification>();

  @override
  void onInit() {
    super.onInit();
    _foregroundNotification.init();
    _foregroundNotification.requestPermissions();

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

  void showNotification() {
    // _foregroundNotification.showNotification(
    //   "NOTIFIKASI",
    //   "TES NOTIFIKASI",
    //    ,
    // );
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
