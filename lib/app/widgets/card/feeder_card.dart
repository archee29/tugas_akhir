import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './../../../../app/styles/app_colors.dart';

class FeederCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final Map<String, dynamic>? morningSchedule;
  final Map<String, dynamic>? eveningSchedule;

  const FeederCard({
    super.key,
    required this.userData,
    this.morningSchedule,
    this.eveningSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(
        left: 24,
        top: 24,
        right: 24,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/pattern-1.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Halo, ${userData["name"]}",
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 12),
            child: const Text(
              "Cek Kondisi Pakan Hari ini.\nPastikan Stok Pakan Cukup, Untuk Hari Ini!",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: const Text(
                          "Morning Feeder",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        morningSchedule?["ketWaktu"] != null
                            ? DateFormat('HH:mm:ss').format(DateFormat('H:m:s')
                                .parse(morningSchedule!["ketWaktu"]))
                            : "-",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1.5,
                  height: 24,
                  color: Colors.white,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: const Text(
                          "Afternoon Feeder",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        eveningSchedule?["ketWaktu"] != null
                            ? DateFormat('HH:mm:ss').format(DateFormat('H:m:s')
                                .parse(eveningSchedule!["ketWaktu"]))
                            : "-",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
