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
  TextEditingController userIdController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

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
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {});
    }
  }

  @override
  void onClose() {
    userIdController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> updateProfile() async {
    User? currentUser = auth.currentUser;
    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomNotification.errorNotification(
            "Terjadi Kesalahan", "User Tidak Terdaftar");
      });
      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    String uid = currentUser.uid;
    if (userIdController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty) {
      isLoading.value = true;
      try {
        Map<String, dynamic> data = {
          "name": nameController.text,
        };
        if (image != null) {
          String avatarUrl = await _uploadAvatar(uid);
          data["avatar"] = avatarUrl;
        }
        await _updateUserProfileData(uid, data);
        image = null;
        Get.back();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          CustomNotification.successNotification(
              "Sukses", "Berhasil Update Profile");
        });
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          CustomNotification.errorNotification("Terjadi Kesalahan",
              "Tidak Bisa Update Profile. Error: ${e.toString()}");
        });
      } finally {
        isLoading.value = false;
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomNotification.errorNotification(
            "Terjadi Kesalahan", "Isi Form Terlebih Dahulu");
      });
    }
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomNotification.errorNotification(
            "Terjadi Kesalahan", "User Tidak Terdaftar");
      });
      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    String uid = currentUser.uid;
    try {
      await databaseReference.child("UsersData/$uid/UsersProfile").update({
        "avatar": null,
      });
      Get.back();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Sukses", "Avatar Berhasil Dihapuas");
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Terjadi Kesalahan", "Tidak Bisa Menghapuas Avatar");
      });
    } finally {
      update();
    }
  }
}
