import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../../app/styles/app_colors.dart';
import './../../../../app/widgets/CustomWidgets/custom_input.dart';
import '../controllers/edit_status_alat_controller.dart';

class EditStatusAlatView extends GetView<EditStatusAlatController> {
  final Map<String, dynamic> statusAlat = Get.arguments != null
      ? Map<String, dynamic>.from(Get.arguments['statusAlat'])
      : {};
  EditStatusAlatView({super.key});

  @override
  Widget build(BuildContext context) {
    String formattedDate = statusAlat['formattedDate'] ?? '';
    // Load existing status when view is opened
    controller.loadExistingStatus(formattedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Status Alat',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 14,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: SvgPicture.asset('assets/icons/arrow-left.svg'),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 1,
            color: AppColors.secondaryExtraSoft,
          ),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              children: [
                GetBuilder<EditStatusAlatController>(
                  builder: (controller) {
                    if (controller.image != null) {
                      return ClipOval(
                        child: Container(
                          width: 98,
                          height: 98,
                          color: AppColors.primary,
                          child: Image.file(
                            File(controller.image!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    } else {
                      return ClipOval(
                        child: Container(
                          width: 98,
                          height: 98,
                          color: AppColors.primary,
                          child: Image.network(
                            (statusAlat["gambarAlat"] == null ||
                                    statusAlat['gambarAlat'] == "")
                                ? "https://ui-avatars.com/api/?name=${statusAlat['gambarAlat']}/"
                                : statusAlat['gambarAlat'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }
                  },
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.pickImage();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: SvgPicture.asset('assets/icons/camera.svg'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Obx(
            () => Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(
                  left: 14, right: 14, top: 4, bottom: 10),
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.primaryExtraSoft,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(width: 1, color: AppColors.secondaryExtraSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pilih Kondisi Servo",
                      style: TextStyle(color: AppColors.primary)),
                  ListTile(
                    title: const Text('Berfungsi'),
                    leading: Radio<String>(
                      value: 'GOOD',
                      groupValue: controller.selectedServoStatus.value,
                      onChanged: (value) {
                        controller.onServoStatusChanged(value!);
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Tidak Berfungsi'),
                    leading: Radio<String>(
                      value: 'NOT GOOD',
                      groupValue: controller.selectedServoStatus.value,
                      onChanged: (value) {
                        controller.onServoStatusChanged(value!);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(
                  left: 14, right: 14, top: 4, bottom: 10),
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.primaryExtraSoft,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(width: 1, color: AppColors.secondaryExtraSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pilih Kondisi Pump",
                      style: TextStyle(color: AppColors.primary)),
                  ListTile(
                    title: const Text('Berfungsi'),
                    leading: Radio<String>(
                      value: 'GOOD',
                      groupValue: controller.selectedPumpStatus.value,
                      onChanged: (value) {
                        controller.onPumpStatusChanged(value!);
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Tidak Berfungsi'),
                    leading: Radio<String>(
                      value: 'NOT GOOD',
                      groupValue: controller.selectedPumpStatus.value,
                      onChanged: (value) {
                        controller.onPumpStatusChanged(value!);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomInput(
            controller: controller.catatanController,
            label: "Catatan",
            hint: "Masukkan Catatan",
            margin: const EdgeInsets.all(5),
          ),
          const SizedBox(height: 16),
          Obx(
            () => SizedBox(
              width: Get.width,
              child: ElevatedButton(
                onPressed: () async {
                  if (controller.isLoading.isFalse) {
                    await controller.editStatusAlat(formattedDate);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  (controller.isLoading.isFalse)
                      ? 'Edit Status Alat'
                      : 'Loading ....',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
