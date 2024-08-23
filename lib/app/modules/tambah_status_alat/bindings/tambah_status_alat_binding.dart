import 'package:get/get.dart';

import '../controllers/tambah_status_alat_controller.dart';

class TambahStatusAlatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TambahStatusAlatController>(
      () => TambahStatusAlatController(),
    );
  }
}
