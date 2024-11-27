import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '../../../routes/app_pages.dart';
import '../../../widgets/dialog/custom_alert_dialog.dart';
import '../../../widgets/dialog/custom_notification.dart';

class StatusAlatController extends GetxController {
  RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> statusAlatList = <Map<String, dynamic>>[].obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  Timer? timer;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () {
      if (auth.currentUser != null) {
        streamUser().listen((event) {
          userData.value = Map<String, dynamic>.from(
              event.snapshot.value as Map<dynamic, dynamic>);
        }, onError: (error) {
          CustomNotification.errorNotification(
              "Terjadi Kesalahan", "Error : $error");
        });
        streamStatusAlat().listen((event) {
          if (event.snapshot.value != null) {
            statusAlatList.clear();
            Map<String, dynamic> data =
                Map<String, dynamic>.from(event.snapshot.value as Map);

            data.forEach((key, value) {
              Map<String, dynamic> statusData =
                  Map<String, dynamic>.from(value);
              statusAlatList.add(statusData);
            });
          } else {
            statusAlatList.clear();
          }
        });
      }
    });
  }

  Stream<DatabaseEvent> streamUser() {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      return database.ref('UsersData/$uid/UsersProfile').onValue;
    } else {
      return const Stream.empty();
    }
  }

  Stream<DatabaseEvent> streamStatusAlat() {
    final User? user = auth.currentUser;
    if (user == null) {
      return Stream.error("User not authenticated");
    }
    String uid = user.uid;
    return databaseReference.child("UsersData/$uid/statusAlat").onValue;
  }

  Future<void> deleteStatusAlat() async {
    String? uid = auth.currentUser?.uid;
    if (uid == null) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    CustomAlertDialog.showFeederAlert(
      title: "Hapus Data Status Alat",
      message: "Apakah Anda Yakin Untuk Menghapus Data Status Alat?",
      onCancel: () => Get.back(),
      onConfirm: () async {
        try {
          await databaseReference.child('UsersData/$uid/statusAlat').remove();
          statusAlatList.clear();
          Get.back();
          Get.back();
          CustomNotification.successNotification(
              "Success", "Data status alat berhasil dihapus");
        } catch (e) {
          CustomNotification.errorNotification(
              "Error", "Gagal menghapus data status alat: $e");
        }
      },
    );
  }
}
