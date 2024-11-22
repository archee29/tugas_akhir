import 'package:flutter/material.dart';
import '../../routes/app_pages.dart';
import './../../../../app/styles/app_colors.dart';
import 'package:get/get.dart';

class DayCard extends StatelessWidget {
  final int latestMakanan;
  final int latestMinuman;
  final int totalMakanan;
  final int totalMinuman;

  const DayCard({
    super.key,
    required this.latestMakanan,
    required this.latestMinuman,
    required this.totalMakanan,
    required this.totalMinuman,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: 3,
          color: AppColors.primaryExtraSoft,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daily Feed",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "120 Gr",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daily Water",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "300 mL",
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
          Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Feed (Gr)",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "$totalMakanan Gr",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Water (mL)",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "$totalMinuman mL",
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
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
                icon: Icon(
                  Icons.arrow_circle_right_outlined,
                  color: AppColors.primary,
                ),
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
            ],
          ),
        ],
      ),
    );
  }
}
