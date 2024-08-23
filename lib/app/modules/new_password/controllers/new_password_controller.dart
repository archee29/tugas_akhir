import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './../../../../app/widgets/dialog/custom_notification.dart';

class NewPasswordController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();

  RxBool oldPasswordObs = true.obs;
  RxBool newPasswordObs = true.obs;
  RxBool newPasswordControllerObs = true.obs;

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> updatePassword() async {
    if (currentPasswordController.text.isNotEmpty &&
        newPasswordController.text.isNotEmpty &&
        confirmNewPasswordController.text.isNotEmpty) {
      if (newPasswordController.text == confirmNewPasswordController.text) {
        isLoading.value = true;
        try {
          User? currentUser = auth.currentUser;
          if (currentUser != null) {
            String emailUser = currentUser.email!;
            await auth.signInWithEmailAndPassword(
                email: emailUser, password: currentPasswordController.text);
            await currentUser.updatePassword(newPasswordController.text);
            Get.back();
            CustomNotification.successNotification(
                "Sukses", "Berhasil Ubah Password");
          } else {
            CustomNotification.errorNotification(
                "Terjadi Kesalahan", "User Tidak Terdaftar");
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'wrong-password') {
            CustomNotification.errorNotification(
                "Terjadi Kesalahan", 'Password Lama Salah');
          } else {
            CustomNotification.errorNotification(
                "error", "Tidak Dapat Mengubah Password Karena : ${e.code}");
          }
        } catch (e) {
          CustomNotification.errorNotification(
              "Terjadi Kesalahan", "Karena : ${e.toString()}");
        } finally {
          isLoading.value = false;
        }
      } else {
        CustomNotification.errorNotification("Terjadi Kesalahan",
            "Password Baru dan Konfirmasi Password yang Dimasukkan Tidak Sama");
      }
    } else {
      CustomNotification.errorNotification(
          "Terjadi Kesalahan", "Isi Formulir Terlebih Dahulu");
    }
  }
}
