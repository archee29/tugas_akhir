import 'package:flutter/material.dart';
import './../../../../app/styles/app_colors.dart';

class WeeklyCard extends StatelessWidget {
  final String title;
  final String value;

  const WeeklyCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width *
          0.4, // Sesuaikan ukuran sesuai dengan gambar
      padding: const EdgeInsets.all(
          10), // Tambahkan padding untuk ruang di sekitar konten
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Colors.black,
            width: 2), // Tambahkan border hitam dengan ketebalan 2
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12, // Sesuaikan ukuran teks agar pas di dalam card
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5), // Ruang antara nilai dan ikon
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.bar_chart_rounded,
              color: Colors.white,
              size: 24, // Sesuaikan ukuran ikon
            ),
          ),
        ],
      ),
    );
  }
}
