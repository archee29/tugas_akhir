import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../styles/app_colors.dart';
import '../../../widgets/CustomWidgets/custom_bottom_navbar.dart';
import '../controllers/coba_notifikasi_controller.dart';

class CobaNotifikasiView extends GetView<CobaNotifikasiController> {
  const CobaNotifikasiView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: const CustomBottomNavigationBar(),
        extendBody: true,
        body: StreamBuilder<DatabaseEvent>(
          stream: controller.streamUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error loading data"));
            } else if (!snapshot.hasData ||
                snapshot.data!.snapshot.value == null) {
              return const Center(child: Text("No Data"));
            } else {
              Map<String, dynamic> user = Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map);
              String avatarUrl = user["avatar"] ?? "";
              if (avatarUrl.isEmpty) {
                avatarUrl = "https://ui-avatars.com/api/?name=${user['name']}";
              }
              return ListView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                children: [
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 42,
                            height: 42,
                            child: Image.network(
                              (user["avatar"] == null || user['avatar'] == "")
                                  ? "https://ui-avatars.com/api/?name=${user['name']}/"
                                  : user['avatar'],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
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
                              user["name"] ?? "",
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
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      controller.showNotification();
                    },
                    child: const Text("Coba Notifikasi"),
                  ),
                ],
              );
            }
          },
        ));
  }
}
