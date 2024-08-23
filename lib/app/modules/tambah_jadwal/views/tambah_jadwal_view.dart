import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/CustomWidgets/custom_all_time_input.dart';
import './../../../../app/styles/app_colors.dart';
import './../../../../app/widgets/CustomWidgets/custom_time_input.dart';

import '../../../routes/app_pages.dart';
import '../../../widgets/CustomWidgets/custom_input.dart';
import '../../../widgets/CustomWidgets/custom_schedule_input.dart';
import '../controllers/tambah_jadwal_controller.dart';

class TambahJadwalView extends GetView<TambahJadwalController> {
  const TambahJadwalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Jadwal',
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
          // Kalender
          CustomScheduleInput(
            controller: controller.dateController,
            suffixIcon: const Icon(Icons.calendar_month_outlined),
            label: "Kalender",
            hint: DateFormat("dd-MM-yyyy")
                .format(controller.selectedDate.value)
                .toString(),
            onTap: () {
              controller.chooseDate();
            },
          ),

          // Custom Time Input 07/17
          CustomTimeInput(
            controller: controller.timeController,
            label: "Pilih Waktu",
            hint: "Pilih Waktu",
            onTap: controller.handleTimeSelection,
            onTimeChanged: controller.onTimeChanged,
            disabled: true,
          ),

          // custom time input for test all time schedule
          // CustomAllTimeInput(
          //   controller: controller,
          //   label: "Test Waktu",
          //   hint: "Test Waktu",
          //   onTap: controller.selectedTime,
          //   onTimeChanged: onTimeChanged,
          // ),

          // Input Judul
          CustomInput(
            controller: controller.titleController,
            suffixIcon: const Icon(Icons.text_snippet_outlined),
            label: "Judul",
            hint: "Masukkan Judul",
          ),
          // Input Deskripsi
          CustomInput(
            controller: controller.deskripsiController,
            suffixIcon: const Icon(Icons.text_snippet_outlined),
            label: "Deskripsi",
            hint: "Masukkan Deskripsi",
          ),
          // Input Makanan
          CustomInput(
            controller: controller.makananController,
            suffixIcon: const Icon(Icons.fastfood_outlined),
            label: "Makanan",
            hint: "Masukkan Jumlah Makanan",
            keyboardType: TextInputType.number,
          ),
          // Input Minuman
          CustomInput(
            controller: controller.minumanController,
            suffixIcon: const Icon(Icons.fastfood_outlined),
            label: "Minuman",
            hint: "Masukkan Jumlah Minuman",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          // Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Cancel Button
              SizedBox(
                width: 120,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed(Routes.MAIN);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side:
                          const BorderSide(width: 1, color: Color(0xFFFF39B0)),
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
              // Tambah Button
              SizedBox(
                width: 200,
                height: 60,
                child: Obx(
                  () => ElevatedButton.icon(
                    onPressed: () {
                      if (controller.isLoading.isFalse) {
                        controller.addManualDataBasedOnTime();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          width: 1,
                          color: Colors.white,
                        ),
                      ),
                      shadowColor: const Color(0x3F000000),
                    ),
                    icon: SvgPicture.asset('assets/icons/tambah_button.svg'),
                    label: Text(
                      (controller.isLoading.isFalse)
                          ? 'Tambah Jadwal'
                          : 'Loading ...',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'poppins',
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
    );
  }
}
