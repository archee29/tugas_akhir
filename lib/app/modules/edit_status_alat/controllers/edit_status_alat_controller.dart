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

  // Data yang akan diedit
  late Map<dynamic, dynamic> statusAlatData;
  late String selectedDate;

  @override
  void onInit() {
    super.onInit();
    Map<String, dynamic>? arguments = Get.arguments;
    if (arguments != null) {
      selectedDate = arguments['date'];
      statusAlatData = arguments['statusAlat'];
      selectedServoStatus.value = statusAlatData['servo_status'] ?? '';
      selectedPumpStatus.value = statusAlatData['pump_status'] ?? '';
      catatanController.text = statusAlatData['catatan'] ?? '';
    }
  }

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

  Future<void> editStatusAlat() async {
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

      // Jika ada gambar baru, upload gambar baru
      if (image != null) {
        avatarUrl = await _uploadAvatar(uid);
      }

      final Map<String, dynamic> data = {
        "servo_status": selectedServoStatus.value,
        "pump_status": selectedPumpStatus.value,
        "catatan": catatanController.text,
        "created_at": DateTime.now().toIso8601String(),
      };

      // Tambahkan URL gambar jika ada
      if (avatarUrl != null) {
        data["gambarAlat"] = avatarUrl;
      } else if (statusAlatData['gambarAlat'] != null) {
        // Gunakan URL gambar lama jika tidak ada gambar baru
        data["gambarAlat"] = statusAlatData['gambarAlat'];
      }

      await _updateStatusToDatabase(user.uid, data);
      Get.back();
      Get.back();
      CustomNotification.successNotification(
          "Berhasil", "Status Alat Berhasil Diubah");
    } catch (e) {
      CustomNotification.errorNotification("Terjadi Kesalahan", "$e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> _updateStatusToDatabase(
      String uid, Map<String, dynamic> data) async {
    await databaseReference
        .child("UsersData/$uid/statusAlat/$selectedDate")
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
