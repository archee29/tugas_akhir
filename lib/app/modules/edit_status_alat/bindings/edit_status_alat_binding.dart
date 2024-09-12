import 'package:get/get.dart';

import '../controllers/edit_status_alat_controller.dart';

class EditStatusAlatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditStatusAlatController>(
      () => EditStatusAlatController(),
    );
  }
}
