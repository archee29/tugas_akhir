import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../widgets/dialog/custom_notification.dart';
import './../../../../app/routes/app_pages.dart';

class SettingController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  Stream<DatabaseEvent> streamUser() {
    User? currentUser = auth.currentUser;
    if (currentUser == null) {
      Get.offAllNamed(Routes.LOGIN);
      return const Stream.empty();
    }
    String uid = currentUser.uid;
    return databaseReference.child('UsersData/$uid/UsersProfile').onValue;
  }

  Future<void> checkAndNavigate() async {
    try {
      User? currentUser = auth.currentUser;
      if (currentUser == null) {
        Get.offAllNamed(Routes.LOGIN);
        return;
      }

      String uid = currentUser.uid;
      DatabaseReference ref =
          databaseReference.child('UsersData/$uid/manual/statusAlat');

      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists && snapshot.value != null) {
        Get.toNamed(Routes.STATUS_ALAT);
      } else {
        Get.toNamed(Routes.TAMBAH_STATUS_ALAT);
      }
    } catch (e) {
      CustomNotification.errorNotification(
          "Terjadi Kesalahan!", "Gagal memeriksa status alat: $e");
    }
  }

  void logout() async {
    try {
      await auth.signOut();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar("Error", "Unable to logout: ${e.toString()}");
    }
  }
}
