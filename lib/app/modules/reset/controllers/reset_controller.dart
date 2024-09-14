import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './../../../../app/widgets/dialog/custom_notification.dart';

class ResetController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController emailController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> sendEmail() async {
    if (emailController.text.isNotEmpty) {
      isLoading.value = true;
      try {
        await auth.sendPasswordResetEmail(email: emailController.text);
        Get.back();
        CustomNotification.successNotification("Sukses",
            "Kami Telah mengirimkan link untuk ubah Password Ke Email Anda");
      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'user-not-found') {
          CustomNotification.errorNotification("Terjadi Kesalahan",
              "Email tidak terdaftar. Silakan periksa kembali email Anda.");
        } else {
          CustomNotification.errorNotification("Terjadi Kesalahan",
              "Tidak Dapat Mengirimkan Link Untuk Ubah Password Karena : ${e.toString()}");
        }
      } finally {
        isLoading.value = false;
      }
    } else {
      CustomNotification.errorNotification(
          "Terjadi Kesalahan", "Masukkan Email Terlebih Dahulu");
    }
  }
}
