import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../modules/data/controllers/data_controller.dart';
import '../../routes/app_pages.dart';
import '../../styles/app_colors.dart';

class DataJadwalPagi extends StatelessWidget {
  final DataController controller = Get.put(DataController());
  DataJadwalPagi({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.TAMBAH_JADWAL),
        child: Icon(Icons.add, color: AppColors.primary, size: 28),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.listDataMf.isEmpty) {
            return const Center(child: Text('Data Jadwal Pagi Tidak Tersedia'));
          } else {
            return ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: controller.listDataMf.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                var mfData = controller.listDataMf[index];
                var key = mfData['key'];
                return ManualMfDataTile(
                  mfData: mfData,
                  mfDataKey: key,
                );
              },
            );
          }
        }),
      ),
    );
  }
}

class ManualMfDataTile extends GetView<DataController> {
  final Map<String, dynamic> mfData;
  final String mfDataKey;
  const ManualMfDataTile(
      {super.key, required this.mfData, required this.mfDataKey});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(Routes.DETAIL_JADWAL),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding:
                const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: 3,
                color: AppColors.primaryExtraSoft,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Tanggal
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tanggal",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (mfData["tanggal"] == null)
                                ? "-"
                                : (mfData["tanggal"]),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      // Waktu
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Waktu",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (mfData["waktu"] == null) ? "-" : (mfData["waktu"]),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      // Makanan
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Makanan",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (mfData["makanan"] == null)
                                ? "-"
                                : (mfData["makanan"]),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      // Minuman
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Minuman",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (mfData["minuman"] == null)
                                ? "-"
                                : (mfData["minuman"]),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // BUTTON DATA edit
              SizedBox(
                width: 140,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed(Routes.EDIT_JADWAL, arguments: {
                      'scheduleType': 'jadwalPagi',
                      'scheduleKey': mfDataKey,
                      'scheduleData': mfData,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                          width: 3, color: AppColors.primaryExtraSoft),
                    ),
                  ),
                  icon: SvgPicture.asset('assets/icons/icon-edit.svg'),
                  label: const Text(
                    "Edit",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'poppins'),
                  ),
                ),
              ),

              // BUTTON DATA delete
              SizedBox(
                width: 140,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Future.delayed(Duration.zero, () {
                      controller.deleteDataMF(mfDataKey);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        width: 3,
                        color: AppColors.primaryExtraSoft,
                      ),
                    ),
                  ),
                  icon: SvgPicture.asset('assets/icons/icon-delete.svg'),
                  label: const Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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

class DataJadwalSore extends StatelessWidget {
  final DataController controller = Get.put(DataController());
  DataJadwalSore({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.TAMBAH_JADWAL),
        child: Icon(Icons.add, color: AppColors.primary, size: 28),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.listDataAf.isEmpty) {
            return const Center(child: Text('Data Jadwal Sore Tidak Tersedia'));
          } else {
            return ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: controller.listDataAf.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                var afData = controller.listDataAf[index];
                var key = afData['key'];
                return ManualAfDataTile(
                  afData: afData,
                  afDataKey: key,
                );
              },
            );
          }
        }),
      ),
    );
  }
}

class ManualAfDataTile extends GetView<DataController> {
  final Map<String, dynamic> afData;
  final String afDataKey;
  const ManualAfDataTile(
      {super.key, required this.afData, required this.afDataKey});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(Routes.DETAIL_JADWAL),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding:
                const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: 3,
                color: AppColors.primaryExtraSoft,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Tanggal
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tanggal",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (afData["tanggal"] == null)
                                ? "-"
                                : (afData["tanggal"]),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      // Waktu
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Waktu",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (afData["waktu"] == null) ? "-" : (afData["waktu"]),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      // Makanan
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Makanan",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (afData["makanan"] == null)
                                ? "-"
                                : (afData["makanan"]),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      // Minuman
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Minuman",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (afData["minuman"] == null)
                                ? "-"
                                : (afData["minuman"]),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // BUTTON DATA edit
              SizedBox(
                width: 140,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed(Routes.EDIT_JADWAL, arguments: {
                      'scheduleType': 'jadwalPagi',
                      'scheduleKey': afDataKey,
                      'scheduleData': afData,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                          width: 3, color: AppColors.primaryExtraSoft),
                    ),
                  ),
                  icon: SvgPicture.asset('assets/icons/icon-edit.svg'),
                  label: const Text(
                    "Edit",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'poppins'),
                  ),
                ),
              ),

              // BUTTON DATA delete
              SizedBox(
                width: 140,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Future.delayed(Duration.zero, () {
                      controller.deleteDataAF(afDataKey);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        width: 3,
                        color: AppColors.primaryExtraSoft,
                      ),
                    ),
                  ),
                  icon: SvgPicture.asset('assets/icons/icon-delete.svg'),
                  label: const Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
