import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/schedule_button_controller.dart';
import './../../../../app/styles/app_colors.dart';
import '../CustomWidgets/custom_input.dart';
import '../CustomWidgets/custom_schedule_input.dart';
import '../CustomWidgets/custom_time_input.dart';

class ScheduleInputWidget extends StatelessWidget {
  final ScheduleButtonController controller;

  const ScheduleInputWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tambah Jadwal",
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            CustomScheduleInput(
              controller: controller.dateController,
              suffixIcon: const Icon(Icons.calendar_month_outlined),
              label: "Tanggal",
              hint: DateFormat("dd-MM-yyyy")
                  .format(controller.selectedDate.value)
                  .toString(),
              onTap: () => controller.chooseDate(),
            ),
            const SizedBox(height: 16),
            CustomTimeInput(
              controller: controller.timeController,
              suffixIcon: const Icon(Icons.access_time_outlined),
              label: "Waktu",
              hint: "Pilih Waktu",
              onTimeChanged: controller.onTimeChanged,
              onTap: () => controller.handleTimeSelection(),
            ),
            const SizedBox(height: 16),
            CustomInput(
              controller: controller.titleController,
              suffixIcon: const Icon(Icons.title_outlined),
              label: "Judul",
              hint: "Masukkan Judul Jadwal",
            ),
            const SizedBox(height: 16),
            CustomInput(
              controller: controller.deskripsiController,
              suffixIcon: const Icon(Icons.description_outlined),
              label: "Deskripsi",
              hint: "Masukkan Deskripsi Jadwal",
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      backgroundColor: AppColors.primaryExtraSoft,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Batal",
                      style: TextStyle(color: AppColors.secondarySoft),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.isFalse
                          ? () => controller.handleScheduleConfirm()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        controller.isLoading.isFalse ? "Simpan" : "Loading...",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
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
