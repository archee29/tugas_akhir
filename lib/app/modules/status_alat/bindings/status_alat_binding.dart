import 'package:get/get.dart';

import '../controllers/status_alat_controller.dart';

class StatusAlatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatusAlatController>(
      () => StatusAlatController(),
    );
  }
}
