import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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

  void logout() async {
    try {
      await auth.signOut();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      // Handle logout error
      Get.snackbar("Error", "Unable to logout: ${e.toString()}");
    }
  }
}
