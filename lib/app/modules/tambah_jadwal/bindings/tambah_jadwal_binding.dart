import 'package:get/get.dart';

import '../controllers/tambah_jadwal_controller.dart';

class TambahJadwalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TambahJadwalController>(
      () => TambahJadwalController(),
    );
  }
}
