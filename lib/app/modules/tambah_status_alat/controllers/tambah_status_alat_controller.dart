import 'dart:io';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as s;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import './../../../../app/widgets/dialog/custom_notification.dart';

class TambahStatusAlatController extends GetxController {
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
      Get.snackbar("Terjadi Kesalahan", "Tidak Bisa Menambahkan Gambar");
    }
  }

  Future<void> tambahStatusAlat() async {
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
        "created_at": DateTime.now().toIso8601String(),
      };

      if (avatarUrl != null) {
        data["avatar"] = avatarUrl;
      }

      await _saveStatusToDatabase(uid, data);
      Get.back();
      Get.back();
      Get.back();
      CustomNotification.successNotification(
          "Berhasil", "Status Alat Berhasil Ditambahkan");
    } catch (e) {
      CustomNotification.errorNotification("Terjadi Kesalahan", "$e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> _saveStatusToDatabase(
      String uid, Map<String, dynamic> data) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MM-dd-yyyy').format(now);
    await databaseReference
        .child("UsersData/$uid/manual/statusAlat/$formattedDate")
        .set(data);
  }

  Future<String> _uploadAvatar(String uid) async {
    File file = File(image!.path);
    String ext = image!.name.split(".").last;
    String upDir = "$uid/statusAlat/avatar.$ext";
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
