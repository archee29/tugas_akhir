import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../widgets/card/day_card.dart';
import './../../../../app/routes/app_pages.dart';
import './../../../../app/styles/app_colors.dart';
import './../../../../app/widgets/CustomWidgets/custom_bottom_navbar.dart';
import './../../../../app/widgets/card/feeder_card.dart';
import '../controllers/status_alat_controller.dart';

class StatusAlatView extends GetView<StatusAlatController> {
  const StatusAlatView({super.key});

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

            // StreamBuilder untuk status alat
            return StreamBuilder<DatabaseEvent>(
              stream: controller.streamStatusAlat(),
              builder: (context, alatSnapshot) {
                if (alatSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (alatSnapshot.hasError) {
                  return const Center(
                      child: Text("Error streaming status alat"));
                } else if (!alatSnapshot.hasData ||
                    alatSnapshot.data!.snapshot.value == null) {
                  return const Center(
                      child: Text("Tidak ada data status alat"));
                } else {
                  // Data status alat dari Firebase
                  Map<String, dynamic> statusAlat = Map<String, dynamic>.from(
                      alatSnapshot.data!.snapshot.value as Map);
                  String servoStatus = statusAlat['servo_status'] ?? 'UNKNOWN';
                  String pumpStatus = statusAlat['pump_status'] ?? 'UNKNOWN';
                  String catatan = statusAlat['catatan'] ?? 'Tidak ada catatan';

                  return ListView(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 36),
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
                                  (user["avatar"] == null ||
                                          user['avatar'] == "")
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
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Status Alat",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: AppColors.primaryExtraSoft,
                                thickness: 2.5,
                              ),
                              const SizedBox(height: 10),
                              ClipOval(
                                child: SizedBox(
                                  width: 150,
                                  height: 100,
                                  child: Image.network(
                                    (statusAlat["avatar"] == null ||
                                            statusAlat['avatar'].isEmpty)
                                        ? "https://ui-avatars.com/api/?name=Alat" // Gambar default jika avatar tidak ada
                                        : statusAlat[
                                            'avatar'], // URL gambar dari Firebase
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Text(
                                          "Gambar Tidak Tersedia",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
                              // Status Servo
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.black, width: 3),
                                      ),
                                      child: Stack(
                                        children: [
                                          const Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Servo",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.black,
                                                    width: 2),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  servoStatus, // Menampilkan status servo dari data stream
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Status Pump
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.black, width: 3),
                                      ),
                                      child: Stack(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.black,
                                                    width: 2),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  pumpStatus, // Menampilkan status pump dari data stream
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "PUMP",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Catatan
                              Container(
                                padding: const EdgeInsets.all(10),
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Catatan",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      catatan, // Menampilkan catatan dari data stream
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Tombol Edit dan Delete
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Aksi Edit
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text(
                                      "Edit",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyan,
                                      minimumSize: const Size(140, 50),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Aksi Delete
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      "Delete",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      minimumSize: const Size(140, 50),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
