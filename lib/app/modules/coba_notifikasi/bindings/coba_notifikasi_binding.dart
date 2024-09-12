import 'package:get/get.dart';

import '../controllers/coba_notifikasi_controller.dart';

class CobaNotifikasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CobaNotifikasiController>(
      () => CobaNotifikasiController(),
    );
  }
}
