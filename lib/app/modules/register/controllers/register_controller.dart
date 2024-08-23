import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/dialog/custom_alert_dialog.dart';
import '../../../widgets/dialog/custom_notification.dart';
import './../../../../../data_pengguna.dart';

class RegisterController extends GetxController {
  @override
  void onClose() {
    idC.dispose();
    nameC.dispose();
    emailC.dispose();
    jobC.dispose();
    adminPassC.dispose();
    super.onClose();
  }

  RxBool isLoading = false.obs;
  RxBool isLoadingCreateUser = false.obs;

  TextEditingController idC = TextEditingController();
  TextEditingController nameC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController jobC = TextEditingController();
  TextEditingController adminPassC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  String getDefaultPassword() {
    return DataPengguna.defaultPassword;
  }

  String getDefaultRole() {
    return DataPengguna.defaultRole;
  }

  Future<void> addUser() async {
    if (idC.text.isNotEmpty &&
        nameC.text.isNotEmpty &&
        emailC.text.isNotEmpty &&
        jobC.text.isNotEmpty) {
      isLoading.value = true;
      CustomAlertDialog.confirmAdmin(
        title: 'Konfirmasi Admin',
        message: 'Anda Perlu Konfirmasi Admin',
        onCancel: () {
          isLoading.value = false;
          Get.back();
        },
        onConfirm: () async {
          if (isLoadingCreateUser.isFalse) {
            await createUserData();
            isLoading.value = false;
          }
        },
        controller: adminPassC,
      );
    } else {
      isLoading.value = false;
      CustomNotification.errorNotification(
          'Terjadi Kesalahan', 'Isi Form Terlebih Dahulu');
    }
  }

  Future<void> createUserData() async {
    if (adminPassC.text.isNotEmpty) {
      isLoadingCreateUser.value = true;
      String adminEmail = auth.currentUser!.email!;
      try {
        await auth.signInWithEmailAndPassword(
            email: adminEmail, password: adminPassC.text);
        String defaultPassword = getDefaultPassword();
        String defaultRole = getDefaultRole();
        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: emailC.text,
          password: defaultPassword,
        );

        if (userCredential.user != null) {
          String uid = userCredential.user!.uid;
          DatabaseReference userRef =
              databaseReference.child("UsersData").child(uid);
          await userRef.set({
            "user_id": idC.text,
            "name": nameC.text,
            "email": emailC.text,
            "role": defaultRole,
            "job": jobC.text,
            "created_at": DateTime.now().toIso8601String(),
          });
          await userCredential.user!.sendEmailVerification();
          await auth.signOut();
          await auth.signInWithEmailAndPassword(
              email: adminEmail, password: adminPassC.text);
          Get.back();
          Get.back();
          CustomNotification.successNotification(
              'Sukses', 'Berhasil Menambahkan User');
          isLoadingCreateUser.value = false;
        }
      } on FirebaseAuthException catch (e) {
        isLoadingCreateUser.value = false;
        if (e.code == 'weak-password') {
          CustomNotification.errorNotification(
              'Terjadi Kesalahan', 'Password Terlalu Lemah');
        } else if (e.code == 'email-already-in-use') {
          CustomNotification.errorNotification(
              'Terjadi Kesalahan', 'User Sudah Terdaftar');
        } else if (e.code == 'wrong-password') {
          CustomNotification.errorNotification(
              'Terjadi Kesalahan', 'Password Salah');
        } else {
          CustomNotification.errorNotification(
              'Terjadi Kesalahan', 'Terjadi Kesalahan: ${e.code}');
        }
      } catch (e) {
        isLoadingCreateUser.value = false;
        CustomNotification.errorNotification(
            'Terjadi Kesalahan', 'Terjadi Kesalahan: ${e.toString()}');
      }
    } else {
      CustomNotification.errorNotification('Terjadi Kesalahan',
          'Anda Membutuhkan Password Admin Untuk Membuat User');
    }
  }
}
