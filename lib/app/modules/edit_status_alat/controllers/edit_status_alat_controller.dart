import 'dart:io';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as s;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_pages.dart';
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
  void onInit() {
    super.onInit();
    if (auth.currentUser == null) {
      Get.offAllNamed(Routes.LOGIN);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {});
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
    }
    isLoading.value = true;
    try {
      final String uid = user.uid;

      final Map<String, dynamic> data = {
        "servo_status": selectedServoStatus.value,
        "pump_status": selectedPumpStatus.value,
        "catatan": catatanController.text,
      };

      if (image != null) {
        String avatarUrl = await _uploadAvatar(uid);
        data["gambarAlat"] = avatarUrl;
      }

      await updateStatusAlatToDatabase(uid, data);
      image = null;
      Get.back();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomNotification.successNotification(
            "Berhasil", "Data Berhasil Diedit");
      });
    } catch (e) {
      CustomNotification.errorNotification(
          "Terjadi Kesalahan", "Gagal Mengedit Data");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatusAlatToDatabase(
      String uid, Map<String, dynamic> data) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MM-dd-yyyy').format(now);
    await databaseReference
        .child("UsersData/$uid/statusAlat/$formattedDate")
        .update(data);
  }

  Future<String> _uploadAvatar(String uid) async {
    File file = File(image!.path);
    String ext = image!.name.split(".").last;
    String upDir = "$uid/statusAlat/gambarAlat.$ext";
    try {
      await storage.ref(upDir).putFile(file);
      return await storage.ref(upDir).getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  void onServoStatusChanged(String value) {
    selectedServoStatus.value = value;
  }

  void onPumpStatusChanged(String value) {
    selectedPumpStatus.value = value;
  }
}
