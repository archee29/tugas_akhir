import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:intl/intl.dart';

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
          userData.value =
              Map<String, dynamic>.from(event.snapshot.value as Map);
        }, onError: (error) {
          CustomNotification.errorNotification(
              "Terjadi Kesalahan", "Error : $error");
        });
        streamStatusAlat().listen((event) {
          if (event.snapshot.value != null) {
            Map<String, dynamic> data =
                Map<String, dynamic>.from(event.snapshot.value as Map);
            statusAlatList.clear();
            data.forEach((key, value) {
              Map<String, dynamic> statusData =
                  Map<String, dynamic>.from(value);
              statusData['date'] = key;
              statusAlatList.add(statusData);
            });
          } else {
            statusAlatList.clear();
          }
        });
      } else {
        Get.offAllNamed(Routes.LOGIN);
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
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MM-dd-yyyy').format(now);
    return databaseReference
        .child("UsersData/$uid/statusAlat/$formattedDate")
        .onValue;
  }

  Future<void> deleteStatusAlat(String date) async {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      CustomAlertDialog.showFeederAlert(
        title: "Hapus Data",
        message: "Apakah Anda Yakin Untuk Menghapus Data?",
        onCancel: () => Get.back(),
        onConfirm: () async {
          try {
            await databaseReference
                .child('UsersData/$uid/statusAlat/$date')
                .remove();
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
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
