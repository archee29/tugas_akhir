import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/card/day_card.dart';
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
      extendBody: true,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
              children: [
                const SizedBox(height: 16),
                // Menampilkan Foto dan Nama Admin
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
                // Menampilkan Card Welcome Feeder
                StreamBuilder<DatabaseEvent>(
                  stream: controller.streamTodayFeeder(),
                  builder: (context, feederSnapshot) {
                    if (feederSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (feederSnapshot.hasError) {
                      return const Center(
                          child: Text("Error loading data Admin"));
                    } else if (!feederSnapshot.hasData ||
                        feederSnapshot.data!.snapshot.value == null) {
                      return FeederCard(
                        userData: user,
                        todayFeederData: null,
                      );
                    } else {
                      var todayFeederData = Map<String, dynamic>.from(
                          feederSnapshot.data!.snapshot.value as Map);
                      return FeederCard(
                        userData: user,
                        todayFeederData: todayFeederData,
                      );
                    }
                  },
                ),

                Obx(() {
                  return DayCard(
                    latestMakanan: controller.latestMakanan.value,
                    latestMinuman: controller.latestMinuman.value,
                    totalMakanan: controller.totalMakananToday.value,
                    totalMinuman: controller.totalMinumanToday.value,
                  );
                }),

                const SizedBox(height: 12),
                // Card Main Menu
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
                              Get.toNamed(Routes.MAIN);
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
                              Get.toNamed(Routes.DETAIL_JADWAL);
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
                // Menampilkan Alamat Feeder
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 24, left: 4),
                  child: Text(
                    (user["address"] != null)
                        ? "${user['address']}"
                        : "Belum Ada Lokasi",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondarySoft,
                    ),
                  ),
                ),
                // Menampilkan Card Info Feeder
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width: 3,
                      color: AppColors.primaryExtraSoft,
                    ),
                  ),
                  padding: const EdgeInsets.only(
                      left: 24, top: 20, right: 29, bottom: 20),
                  child: Column(
                    children: [
                      // Header Info Feeder
                      Row(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Info Feeder",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 80),
                              Row(
                                children: [
                                  // Button Setting
                                  SizedBox(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Get.toNamed(Routes.SETTING);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        elevation: 0,
                                        shadowColor: const Color(0x3F000000),
                                      ),
                                      icon: const Icon(
                                        Icons.settings,
                                        color: Colors.black,
                                      ),
                                      label: const Text(
                                        "Settings",
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
                        ],
                      ),
                      const Divider(
                        color: Colors.black,
                        thickness: 1,
                      ),
                      const SizedBox(height: 15),
                      // Deskripsi 1 Info  Feeder
                      const Row(
                        children: [
                          // Nama Kandang
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nama Kandang",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Kandang Kucing",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          // Tabung Pakan
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tabung Pakan",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "1 Kg",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          // Output
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Output",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "120 Gr",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Deskripsi 2 Info Feeder
                      const Row(
                        children: [
                          // Jenis Makanan
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Jenis Makanan",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Makanan Kering",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          // Tabung Minum
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tabung Minum",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "1 Liter",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          // Output
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Output",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "300 mL",
                                style: TextStyle(
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
              ],
            );
          }
        },
      ),
    );
  }
}
