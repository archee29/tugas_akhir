import 'dart:io';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as s;
import 'package:firebase_database/firebase_database.dart';
import './../../../../app/widgets/dialog/custom_notification.dart';
import './../../../../app/routes/app_pages.dart';

class UpdateProfileController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nkController = TextEditingController();
  TextEditingController tpController = TextEditingController();
  TextEditingController wpController = TextEditingController();
  TextEditingController tmController = TextEditingController();
  TextEditingController wmController = TextEditingController();
  TextEditingController bkController = TextEditingController();
  TextEditingController pbbController = TextEditingController();
  TextEditingController baController = TextEditingController();
  TextEditingController putaranServoController = TextEditingController();
  TextEditingController waktuPumpController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  s.FirebaseStorage storage = s.FirebaseStorage.instance;
  final ImagePicker picker = ImagePicker();
  XFile? image;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  @override
  void onInit() {
    super.onInit();
    if (auth.currentUser == null) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }
    final user = Get.arguments;
    nameController.text = user["name"] ?? "";
    emailController.text = user["email"] ?? "";
    nkController.text = user["namaKandang"] ?? "";
    tpController.text = user["tabungPakan"]?.toString() ?? "";
    wpController.text = user["wadahPakan"]?.toString() ?? "";
    tmController.text = user["tabungMinum"]?.toString() ?? "";
    wmController.text = user["wadahMinum"]?.toString() ?? "";
    bkController.text = user["beratKucing"]?.toString() ?? "";
    pbbController.text = user['beratKucingAf']?.toString() ?? "";
    baController.text = user['beratAkhir']?.toString() ?? "";
    putaranServoController.text = user['putaranServo']?.toString() ?? "";
    waktuPumpController.text = user['waktuPump']?.toString() ?? "";
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    nkController.dispose();
    tpController.dispose();
    wpController.dispose();
    tmController.dispose();
    wmController.dispose();
    bkController.dispose();
    pbbController.dispose();
    baController.dispose();
    putaranServoController.dispose();
    waktuPumpController.dispose();
    super.onClose();
  }

  Future<void> updateProfile() async {
    User? currentUser = auth.currentUser;
    if (currentUser == null) {
      CustomNotification.errorNotification(
          "Terjadi Kesalahan", "User Tidak Terdaftar");
      Get.offAllNamed(Routes.LOGIN);
      return;
    }
    String uid = currentUser.uid;
    if (!_validateNumericInputs()) {
      return;
    }

    if (_validateAllFields()) {
      isLoading.value = true;
      try {
        Map<String, dynamic> data = {
          "name": nameController.text.trim(),
          "namaKandang": nkController.text.trim(),
          "tabungPakan": int.parse(tpController.text.trim()),
          "wadahPakan": int.parse(wpController.text.trim()),
          "tabungMinum": int.parse(tmController.text.trim()),
          "wadahMinum": int.parse(wmController.text.trim()),
          "beratKucing": int.parse(bkController.text.trim()),
          "beratKucingAf": int.parse(pbbController.text.trim()),
          "beratAkhir": int.parse(baController.text.trim()),
          "putaranServo": int.parse(putaranServoController.text.trim()),
          "waktuPump": int.parse(waktuPumpController.text.trim()),
        };

        if (image != null) {
          String avatarUrl = await _uploadAvatar(uid);
          data["avatar"] = avatarUrl;
        }

        await _updateUserProfileData(uid, data);
        image = null;
        Get.back();
        CustomNotification.successNotification(
            "Sukses", "Berhasil Update Profile");
      } catch (e) {
        CustomNotification.errorNotification(
            "Terjadi Kesalahan", "Tidak Bisa Update Profile. Error: $e");
      } finally {
        isLoading.value = false;
      }
    } else {
      CustomNotification.errorNotification(
          "Terjadi Kesalahan", "Isi Semua Form Terlebih Dahulu");
    }
  }

  bool _validateNumericInputs() {
    final numericControllers = [
      tpController,
      wpController,
      tmController,
      wmController,
      bkController,
      pbbController,
      baController,
      putaranServoController,
      waktuPumpController,
    ];
    for (var controller in numericControllers) {
      if (controller.text.trim().isEmpty) {
        CustomNotification.errorNotification(
            "Terjadi Kesalahan", "Semua field numerik harus diisi");
        return false;
      }

      if (int.tryParse(controller.text.trim()) == null) {
        CustomNotification.errorNotification(
            "Terjadi Kesalahan", "Input harus berupa angka");
        return false;
      }
    }
    return true;
  }

  bool _validateAllFields() {
    return nameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        nkController.text.trim().isNotEmpty &&
        tpController.text.trim().isNotEmpty &&
        wpController.text.trim().isNotEmpty &&
        tmController.text.trim().isNotEmpty &&
        wmController.text.trim().isNotEmpty &&
        bkController.text.trim().isNotEmpty &&
        pbbController.text.trim().isNotEmpty &&
        putaranServoController.text.trim().isNotEmpty &&
        waktuPumpController.text.trim().isNotEmpty &&
        baController.text.trim().isNotEmpty;
  }

  Future<String> _uploadAvatar(String uid) async {
    File file = File(image!.path);
    String ext = image!.name.split(".").last;
    String upDir = "$uid/avatar.$ext";
    try {
      await storage.ref(upDir).putFile(file);
      return await storage.ref(upDir).getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updateUserProfileData(
      String uid, Map<String, dynamic> data) async {
    try {
      await databaseReference.child("UsersData/$uid/UsersProfile").update(data);
    } catch (e) {
      rethrow;
    }
  }

  void pickImage() async {
    try {
      image = await picker.pickImage(source: ImageSource.gallery);
      update();
    } catch (e) {
      Get.snackbar("Terjadi Kesalahan", "Tidak Bisa Menambahkan Gambar");
    }
  }

  void deleteProfile() async {
    User? currentUser = auth.currentUser;
    if (currentUser == null) {
      CustomNotification.errorNotification(
          "Terjadi Kesalahan", "User Tidak Terdaftar");
      Get.offAllNamed(Routes.LOGIN);
      return;
    }
    String uid = currentUser.uid;
    try {
      await databaseReference.child("UsersData/$uid/UsersProfile").update({
        "avatar": null,
      });
      Get.back();
      Get.snackbar("Sukses", "Avatar Berhasil Dihapus");
    } catch (e) {
      Get.snackbar("Terjadi Kesalahan", "Tidak Bisa Menghapus Avatar");
    } finally {
      update();
    }
  }
}
