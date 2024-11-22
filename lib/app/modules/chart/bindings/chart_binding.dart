import 'package:get/get.dart';

import '../controllers/chart_controller.dart';

class DetailJadwalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChartController>(
      () => ChartController(),
    );
  }
}
