import 'package:flutter/material.dart';
import './../../../../app/styles/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String title;
  final String subTitle;
  final String titleNilai;
  final String valueNilai;
  final String titlePertumbuhan;
  final String valuePertumbuhan;

  const CustomTextField({
    super.key,
    required this.title,
    required this.subTitle,
    required this.titleNilai,
    required this.valueNilai,
    required this.titlePertumbuhan,
    required this.valuePertumbuhan,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.95,
          ),
          padding:
              const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primarySoft, width: 5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  subTitle,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.minWidth,
                  maxWidth: constraints.maxWidth,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: MediaQuery.of(context).size.width > 350
                      ? _buildWideLayout()
                      : _buildNarrowLayout(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                titleNilai,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'poppins',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valueNilai,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1.5,
          height: 24,
          color: AppColors.primary,
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                titlePertumbuhan,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'poppins',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valuePertumbuhan,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    titleNilai,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valueNilai,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    titlePertumbuhan,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valuePertumbuhan,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
