import 'dart:io';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as s;
import 'package:image_picker/image_picker.dart';
import './../../../../app/widgets/dialog/custom_notification.dart';

class EditStatusAlatController extends GetxController {
  final RxBool isLoading = false.obs;
  final TextEditingController catatanController = TextEditingController();
  final RxString selectedServoStatus = ''.obs;
  final RxString selectedPumpStatus = ''.obs;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final ImagePicker picker = ImagePicker();
  final s.FirebaseStorage storage = s.FirebaseStorage.instance;
  XFile? image;

  @override
  void onClose() {
    catatanController.dispose();
    super.onClose();
  }

  void pickImage() async {
    try {
      image = await picker.pickImage(source: ImageSource.gallery);
      update();
    } catch (e) {
      CustomNotification.errorNotification(
          "Terjadi Kesalahan", "Tidak Bisa Menambahkan Gambar");
    }
  }

  Future<void> loadExistingStatus(String formattedDate) async {
    final User? user = auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await databaseReference
          .child("UsersData/${user.uid}/statusAlat/$formattedDate")
          .get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<String, dynamic>;
        selectedServoStatus.value = data["servo_status"] ?? '';
        selectedPumpStatus.value = data["pump_status"] ?? '';
        catatanController.text = data["catatan"] ?? '';
      } else {
        CustomNotification.errorNotification(
            "Data Tidak Ditemukan", "Status alat tidak tersedia.");
      }
    } catch (e) {
      CustomNotification.errorNotification("Terjadi Kesalahan", "$e");
    }
  }

  Future<void> editStatusAlat(String formattedDate) async {
    final User? user = auth.currentUser;
    if (user == null) {
      CustomNotification.errorNotification(
          "Terjadi Kesalahan", "User Tidak Terdaftar");
      return;
    }

    if (selectedServoStatus.value.isEmpty ||
        selectedPumpStatus.value.isEmpty ||
        catatanController.text.isEmpty) {
      CustomNotification.errorNotification(
          "Terjadi Kesalahan", "Isi Semua Data");
      return;
    }
    isLoading.value = true;
    try {
      final String uid = user.uid;
      String? avatarUrl;
      if (image != null) {
        avatarUrl = await _uploadAvatar(uid);
      }
      final Map<String, dynamic> data = {
        "servo_status": selectedServoStatus.value,
        "pump_status": selectedPumpStatus.value,
        "catatan": catatanController.text,
        "updated_at": DateTime.now().toIso8601String(),
      };
      if (avatarUrl != null) {
        data["gambarAlat"] = avatarUrl;
      }
      await _updateStatusToDatabase(uid, formattedDate, data);
      Get.back();
      CustomNotification.successNotification(
          "Berhasil", "Status Alat Berhasil Diperbarui");
    } catch (e) {
      CustomNotification.errorNotification("Terjadi Kesalahan", "$e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> _updateStatusToDatabase(
      String uid, String formattedDate, Map<String, dynamic> data) async {
    await databaseReference
        .child("UsersData/$uid/statusAlat/$formattedDate")
        .update(data);
  }

  Future<String> _uploadAvatar(String uid) async {
    File file = File(image!.path);
    String ext = image!.name.split(".").last;
    String upDir = "$uid/statusAlat/gambarAlat.$ext";
    await storage.ref(upDir).putFile(file);
    return await storage.ref(upDir).getDownloadURL();
  }

  void onServoStatusChanged(String value) {
    selectedServoStatus.value = value;
  }

  void onPumpStatusChanged(String value) {
    selectedPumpStatus.value = value;
  }
}
