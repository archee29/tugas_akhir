import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tugas_akhir/app/widgets/card/day_card.dart';
import '../../../widgets/CustomWidgets/custom_info_feeder.dart';
import './../../../../app/routes/app_pages.dart';
import './../../../../app/styles/app_colors.dart';
import './../../../../app/widgets/CustomWidgets/custom_bottom_navbar.dart';
import './../../../../app/widgets/card/feeder_card.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: StreamBuilder<DatabaseEvent>(
        stream: controller.streamUser(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (userSnapshot.hasError) {
            return const Center(child: Text("Error 404"));
          } else if (!userSnapshot.hasData ||
              userSnapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Data Tidak Ada"));
          } else {
            Map<String, dynamic> user = Map<String, dynamic>.from(
                userSnapshot.data!.snapshot.value as Map);
            return ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 36, bottom: 15),
              children: [
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      // menampilkan Poto user
                      ClipOval(
                        child: SizedBox(
                          width: 42,
                          height: 42,
                          child: Image.network(
                            (user["avatar"] == null || user['avatar'] == "")
                                ? "https://ui-avatars.com/api/?name=${user['name']}/"
                                : user['avatar'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // menampilkan nama user
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selamat Datang",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondarySoft,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user["name"],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontFamily: 'poppins',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                StreamBuilder<Map<String, DatabaseEvent>>(
                  stream: controller.streamBothSchedules(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("Error loading data"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return FeederCard(
                        userData: user,
                        morningSchedule: null,
                        eveningSchedule: null,
                      );
                    } else {
                      // Mengambil data jadwal pagi
                      var morningData =
                          snapshot.data!['morning']?.snapshot.value;
                      var morningSchedule = morningData != null
                          ? Map<String, dynamic>.from(morningData as Map)
                          : null;

                      // Mengambil data jadwal sore
                      var eveningData =
                          snapshot.data!['evening']?.snapshot.value;
                      var eveningSchedule = eveningData != null
                          ? Map<String, dynamic>.from(eveningData as Map)
                          : null;

                      return FeederCard(
                        userData: user,
                        morningSchedule: morningSchedule,
                        eveningSchedule: eveningSchedule,
                      );
                    }
                  },
                ),
                StreamBuilder<Map<String, dynamic>>(
                  stream: controller.calculateTotals(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("Error loading data: ${snapshot.error}"),
                      );
                    } else if (!snapshot.hasData) {
                      return const Center(child: Text("No Data"));
                    } else {
                      final data = snapshot.data!;
                      return DayCard(
                        value1: controller
                            .formatFoodOutput(data['kebutuhanMakananHarian']!),
                        value2: controller
                            .formatFoodOutput(data['kebutuhanAirHarian']!),
                        value3: controller.formatCombinedOutput(
                          data['porsiMakanPagi']!,
                          data['porsiMakanSore']!,
                          'Gr',
                        ),
                        value4: controller.formatCombinedOutput(
                          data['porsiAirPagi']!,
                          data['porsiAirSore']!,
                          'mL',
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width: 3,
                      color: AppColors.primaryExtraSoft,
                    ),
                  ),
                  padding: const EdgeInsets.only(
                      left: 24, top: 20, right: 29, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Main Menu",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Divider(
                        color: AppColors.primaryExtraSoft,
                        thickness: 2.5,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Button Main Menu
                          TextButton.icon(
                            onPressed: () {
                              Get.toNamed(Routes.STATISTIK);
                            },
                            icon: SvgPicture.asset(
                                "assets/icons/icon-menu-kucing.svg"),
                            label: Text(
                              "Feeder&\nPool",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: AppColors.primaryExtraSoft,
                                width: 2,
                                strokeAlign: BorderSide.strokeAlignOutside,
                              ),
                            ),
                          ),
                          // Button Detail Food Menu
                          TextButton.icon(
                            onPressed: () {
                              Get.toNamed(Routes.CHART);
                            },
                            icon: SvgPicture.asset(
                                "assets/icons/icon-menu-food.svg"),
                            label: const Text(
                              "Makanan&\nMinuman",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              side: BorderSide(
                                color: AppColors.primaryExtraSoft,
                                width: 2,
                                strokeAlign: BorderSide.strokeAlignOutside,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 24, left: 4),
                  child: Text(
                    (user["address"] != null)
                        ? "${user['address']}"
                        : "Belum Ada Lokasi",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.secondarySoft,
                    ),
                  ),
                ),
                StreamBuilder<Map<String, dynamic>>(
                  stream: controller.streamInfoFeeder(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            "Error loading feeder info: ${snapshot.error}"),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text("No Info Feeder Information"));
                    } else {
                      final data = snapshot.data!;
                      return CustomInfoFeeder(
                        namaKandang: data['namaKandang'] ?? 'N/A',
                        tabungPakan: '${data['tabungPakan']}',
                        wadahPakan: '${data['wadahPakan']} ',
                        jenisMakanan: 'Dry Food',
                        tabungMinum: '${data['tabungMinum']} ',
                        wadahMinum: '${data['wadahMinum']} ',
                        bbKucing: '${data['beratKucing']}',
                        pbbKucing: '${data['beratKucingAf']}',
                        pKucing: '${data['beratAkhir']}',
                        onPressed: () => Get.toNamed(
                          Routes.UPDATE_PROFILE,
                          arguments: user,
                        ),
                      );
                    }
                  },
                )
              ],
            );
          }
        },
      ),
    );
  }
}
