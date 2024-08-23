import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import '../../../routes/app_pages.dart';

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
          print('Error streaming user data: $error');
        });

        // Mulai streaming status alat
        streamStatusAlat().listen((event) {
          if (event.snapshot.value != null) {
            Map<String, dynamic> data =
                Map<String, dynamic>.from(event.snapshot.value as Map);
            statusAlatList.clear();

            // Parsing setiap data status alat berdasarkan tanggal
            data.forEach((key, value) {
              Map<String, dynamic> statusData =
                  Map<String, dynamic>.from(value);
              statusData['date'] = key; // Simpan kunci sebagai tanggal
              statusAlatList.add(statusData);
            });
          } else {
            statusAlatList.clear(); // Jika tidak ada data, kosongkan list
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

    // Return stream from Firebase Realtime Database
    return databaseReference
        .child("UsersData/$uid/manual/statusAlat/$formattedDate")
        .onValue;
  }

  // Fungsi untuk mengedit status alat
  Future<void> editStatusAlat(
      String date, Map<String, dynamic> statusData) async {
    try {
      String? uid = auth.currentUser?.uid;
      if (uid != null) {
        await databaseReference
            .child('UsersData/$uid/manual/statusAlat/$date')
            .update(statusData);
        Get.snackbar("Success", "Data status alat berhasil diubah");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengubah data status alat: $e");
    }
  }

  // Fungsi untuk menghapus status alat berdasarkan tanggal
  Future<void> deleteStatusAlat(String date) async {
    try {
      String? uid = auth.currentUser?.uid;
      if (uid != null) {
        await databaseReference
            .child('UsersData/$uid/manual/statusAlat/$date')
            .remove();
        Get.snackbar("Success", "Data status alat berhasil dihapus");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus data status alat: $e");
    }
  }

  // Fungsi untuk menambahkan status alat baru (opsional)
  Future<void> addStatusAlat(Map<String, dynamic> newStatus) async {
    try {
      String? uid = auth.currentUser?.uid;
      if (uid != null) {
        DateTime now = DateTime.now();
        String formattedDate =
            DateFormat('MM-dd-yyyy').format(now); // Format tanggal

        await databaseReference
            .child('UsersData/$uid/manual/statusAlat/$formattedDate')
            .set(newStatus);

        Get.snackbar("Success", "Status alat berhasil ditambahkan");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menambahkan status alat: $e");
    }
  }
}
