import 'package:flutter/material.dart';
import '../../routes/app_pages.dart';
import './../../../../app/styles/app_colors.dart';
import 'package:get/get.dart';

class DayCard extends StatelessWidget {
  final String value1;
  final String value2;
  final String value3;
  final String value4;

  const DayCard({
    super.key,
    required this.value1,
    required this.value2,
    required this.value3,
    required this.value4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: 130, // Sedikit dinaikkan untuk memberi ruang lebih
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: 3,
          color: AppColors.primaryExtraSoft,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildInfoColumn(
            label1: "Daily Feed",
            value1: value1,
            label2: "Daily Water",
            value2: value2,
          ),
          _buildInfoColumn(
            label1: "Pagi & Sore",
            value1: value3,
            label2: "Pagi & Sore",
            value2: value4,
          ),
          _buildActionColumn(),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({
    required String label1,
    required String value1,
    required String label2,
    required String value2,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelValuePair(label1, value1),
        const SizedBox(height: 10),
        _buildLabelValuePair(label2, value2),
      ],
    );
  }

  Widget _buildLabelValuePair(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Get.toNamed(Routes.CHART);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
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
    );
  }
}
