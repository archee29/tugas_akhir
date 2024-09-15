import 'package:get/get.dart';

import '../controllers/detail_feeder_controller.dart';

class DetailFeederBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailFeederController>(
      () => DetailFeederController(),
    );
  }
}
