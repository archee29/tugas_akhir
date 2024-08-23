import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import './../../../styles/app_colors.dart';
import './../../../widgets/CustomWidgets/custom_input.dart';
import './../../../widgets/CustomWidgets/custom_schedule_input.dart';
import './../../../widgets/CustomWidgets/custom_time_input.dart';
import '../controllers/edit_jadwal_controller.dart';

class EditJadwalView extends GetView<EditJadwalController> {
  const EditJadwalView({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>;
    final String scheduleType = arguments['scheduleType'];
    final String scheduleKey = arguments['scheduleKey'];
    final Map<String, dynamic> scheduleData = arguments['scheduleData'];

    controller.nodePath = scheduleType;
    controller.scheduleKey = scheduleKey;
    controller.setInitialValues(scheduleData);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Jadwal',
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
      body: Obx(
        () => ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            CustomScheduleInput(
              controller: controller.dateController,
              suffixIcon: const Icon(Icons.calendar_month_outlined),
              label: "Kalender",
              hint: controller.dateController.text.isNotEmpty
                  ? controller.dateController.text
                  : 'Pilih Tanggal',
              onTap: () {
                controller.chooseDate();
              },
            ),
            CustomTimeInput(
              controller: controller.timeController,
              label: "Waktu",
              hint:
                  "${controller.selectedTime.value.hour}:${controller.selectedTime.value.minute}",
              onTap: () {
                controller.chooseTime();
              },
              onTimeChanged: (String value) {
                controller.onTimeChanged(value);
              },
            ),
            CustomInput(
              controller: controller.titleController,
              suffixIcon: const Icon(Icons.text_snippet_outlined),
              label: "Judul",
              hint: "Masukkan Judul",
            ),
            CustomInput(
              controller: controller.deskripsiController,
              suffixIcon: const Icon(Icons.text_snippet_outlined),
              label: "Deskripsi",
              hint: "Masukkan Deskripsi",
            ),
            CustomInput(
              controller: controller.makananController,
              suffixIcon: const Icon(Icons.fastfood_outlined),
              label: "Makanan",
              hint: "Masukkan Jumlah Makanan",
              keyboardType: TextInputType.number,
            ),
            CustomInput(
              controller: controller.minumanController,
              suffixIcon: const Icon(Icons.fastfood_outlined),
              label: "Minuman",
              hint: "Masukkan Jumlah Minuman",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 120,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                            width: 1, color: Color(0xFFFF39B0)),
                      ),
                      shadowColor: const Color(0x3F000000),
                    ),
                    icon: SvgPicture.asset('assets/icons/cancel_button.svg'),
                    label: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFamily: 'poppins',
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.updateManualDataBasedOnTime(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(width: 1, color: Colors.white),
                      ),
                      shadowColor: const Color(0x3F000000),
                    ),
                    icon: SvgPicture.asset('assets/icons/edit_button.svg'),
                    label: Text(
                      controller.isLoading.isFalse
                          ? 'Edit Jadwal'
                          : 'Loading ...',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'poppins',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
