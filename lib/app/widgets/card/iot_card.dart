import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './../../../../app/routes/app_pages.dart';
import './../../../../app/styles/app_colors.dart';

class IotCard extends StatelessWidget {
  final Map<String, dynamic>? dataJadwalPagi;
  final Map<String, dynamic>? dataJadwalSore;
  const IotCard({
    super.key,
    required this.dataJadwalPagi,
    required this.dataJadwalSore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: 3,
          color: AppColors.primaryExtraSoft,
        ),
      ),
      padding: const EdgeInsets.only(left: 24, top: 20, right: 29, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Deskripsi 1 Info  Feeder
          Column(
            children: [
              // Daily Feed (food)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daily Feed (gr)",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    // jadwalPagi['tabungMakan'] + 'Gr',
                    // '${snapshot.child('wadahMakan').value} Gr',
                    dataJadwalPagi?['wadahMakan'] + 'Gr',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Daily Water (water)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daily Water (mL)",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    // jadwalPagi['tabungMinum'] + 'mL',
                    // '${snapshot.child('wadahMinum').value} mL',
                    dataJadwalPagi?['tabungMinum'] + "mL",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Deskripsi 2 Info Feeder
          Column(
            children: [
              // Output Feed (food)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Feed (Kg)",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    // jadwalPagi['wadahMakan'] + 'Gr',
                    // '${snapshot.child('tabungMakan').value} Kg',
                    dataJadwalPagi?['tabungMakan'] + "Kg",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Output Water
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Water (L)",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    // jadwalPagi['wadahMinum'] + 'L',
                    // '${snapshot.child('tabungMinum').value} L',
                    dataJadwalPagi?['tabungMinum'] + "L",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Button Detail Feeder
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Button Setting
              SizedBox(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed(Routes.CHART);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.white),
                    ),
                    shadowColor: const Color(0x3F000000),
                  ),
                  icon: Icon(Icons.arrow_circle_right_outlined,
                      color: AppColors.primary),
                  label: const Text(
                    "",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'poppins',
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
