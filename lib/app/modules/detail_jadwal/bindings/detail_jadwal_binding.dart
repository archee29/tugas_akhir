import 'package:get/get.dart';

import '../controllers/detail_jadwal_controller.dart';

class DetailJadwalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailJadwalController>(
      () => DetailJadwalController(),
    );
  }
}
