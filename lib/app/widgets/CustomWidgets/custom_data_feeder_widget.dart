import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../modules/detail_feeder/controllers/detail_feeder_controller.dart';
import '../../routes/app_pages.dart';
import '../../styles/app_colors.dart';

class DataFeederPagi extends StatelessWidget {
  final DetailFeederController controller = Get.find<DetailFeederController>();

  DataFeederPagi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.HOME),
        child: Icon(Icons.home_filled, color: AppColors.primary, size: 28),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (controller.listDataMf.isEmpty) {
            return const Center(child: Text('Data Feeder Pagi Tidak Tersedia'));
          } else {
            return ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: controller.listDataMf.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                var mfData = controller.listDataMf[index];
                return FeederMFDataCard(mfData: mfData);
              },
            );
          }
        }),
      ),
    );
  }
}

class FeederMFDataCard extends StatelessWidget {
  final Map<String, dynamic> mfData;

  const FeederMFDataCard({super.key, required this.mfData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondaryExtraSoft, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Morning Feeder',
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      (mfData["ketWaktu"] == null)
                          ? "-"
                          : DateFormat('HH:mm:ss').format(
                              DateFormat('H:m:s').parse(mfData["ketWaktu"])),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  (mfData["ketHari"] == null)
                      ? "-"
                      : DateFormat('yMMMMEEEEd').format(
                          DateFormat('dd/MM/yyyy').parse(mfData["ketHari"])),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Pakan Wadah', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            (mfData["beratWadah"] == null) ? "-" : "${mfData["beratWadah"]} Gr",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          const Text('Air Wadah', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            (mfData["volumeMLWadah"] == null)
                ? "-"
                : "${mfData["volumeMLWadah"]} mL",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          const Text('Air Tabung', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            (mfData["volumeMLTabung"] == null)
                ? "-"
                : "${mfData["volumeMLTabung"]} mL",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class DataFeederSore extends StatelessWidget {
  final DetailFeederController controller = Get.find<DetailFeederController>();

  DataFeederSore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.HOME),
        child: Icon(Icons.home_filled, color: AppColors.primary, size: 28),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (controller.listDataAf.isEmpty) {
            return const Center(child: Text('Data Feeder Sore Tidak Tersedia'));
          } else {
            return ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: controller.listDataAf.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                var afData = controller.listDataAf[index];
                return FeederAFDataCard(afData: afData);
              },
            );
          }
        }),
      ),
    );
  }
}

class FeederAFDataCard extends StatelessWidget {
  final Map<String, dynamic> afData;

  const FeederAFDataCard({super.key, required this.afData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Afternoon Feeder',
                        style: TextStyle(color: Colors.black)),
                    const SizedBox(height: 4),
                    Text(
                      (afData["ketWaktu"] == null)
                          ? "-"
                          : DateFormat('HH:mm:ss').format(
                              DateFormat('H:m:s').parse(afData["ketWaktu"])),
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  (afData["ketHari"] == null)
                      ? "-"
                      : DateFormat('yMMMMEEEEd').format(
                          DateFormat('dd/MM/yyyy').parse(afData["ketHari"])),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Pakan Wadah', style: TextStyle(color: Colors.black)),
          const SizedBox(height: 4),
          Text(
            (afData["beratWadah"] == null) ? "-" : "${afData["beratWadah"]} Gr",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          const Text('Air Wadah', style: TextStyle(color: Colors.black)),
          const SizedBox(height: 4),
          Text(
            (afData["volumeMLWadah"] == null)
                ? "-"
                : "${afData["volumeMLWadah"]} mL",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          const Text('Air Tabung', style: TextStyle(color: Colors.black)),
          const SizedBox(height: 4),
          Text(
            (afData["volumeMLTabung"] == null)
                ? "-"
                : "${afData["volumeMLTabung"]} mL",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
