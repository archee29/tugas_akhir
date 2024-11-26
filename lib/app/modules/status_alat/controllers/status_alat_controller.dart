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
          userData.value = Map<String, dynamic>.from(
              event.snapshot.value as Map<dynamic, dynamic>);
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
            statusAlatList.sort((a, b) {
              DateTime dateA = DateFormat('MM-dd-yyyy').parse(a['date']);
              DateTime dateB = DateFormat('MM-dd-yyyy').parse(b['date']);
              return dateB.compareTo(dateA);
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

  Stream<DatabaseEvent> streamStatusAlat({String? specificDate}) {
    final User? user = auth.currentUser;
    if (user == null) {
      return Stream.error("User not authenticated");
    }

    String uid = user.uid;
    String formattedDate =
        specificDate ?? DateFormat('MM-dd-yyyy').format(DateTime.now());

    return databaseReference
        .child("UsersData/$uid/statusAlat/$formattedDate")
        .onValue;
  }

  Future<void> deleteStatusAlat(String date) async {
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
          await databaseReference
              .child('UsersData/$uid/statusAlat/$date')
              .remove();
          statusAlatList.removeWhere((item) => item['date'] == date);
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
