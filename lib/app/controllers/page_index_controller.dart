import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './../controllers/feeder_controller.dart';
import './../routes/app_pages.dart';

class PageIndexController extends GetxController {
  final feederController = Get.find<FeederController>();

  RxInt pageIndex = 0.obs;
  FirebaseAuth auth = FirebaseAuth.instance;

  Stream<User?> get streamAuthStatus => auth.authStateChanges();

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }

  void changePage(int index) async {
    pageIndex.value = index;

    switch (index) {
      case 1:
        feederController.feeder();
        break;
      case 2:
        Get.offAllNamed(Routes.SETTING);
      case 3:
        Get.offAllNamed(Routes.STATISTIK);
      case 4:
        logout();
      default:
        Get.offAllNamed(Routes.HOME);
        break;
    }
  }
}
