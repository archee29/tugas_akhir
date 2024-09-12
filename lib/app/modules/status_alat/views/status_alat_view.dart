import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_pages.dart';
import '../../edit_status_alat/views/edit_status_alat_view.dart';
import './../../../../app/styles/app_colors.dart';
import './../../../../app/widgets/CustomWidgets/custom_bottom_navbar.dart';
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
                  Map<String, dynamic> statusAlat = Map<String, dynamic>.from(
                      alatSnapshot.data!.snapshot.value as Map);
                  String servoStatus = statusAlat['servo_status'] ?? 'UNKNOWN';
                  String pumpStatus = statusAlat['pump_status'] ?? 'UNKNOWN';
                  String catatan = statusAlat['catatan'] ?? 'Tidak ada catatan';

                  // Date key untuk status alat (sesuai format yang digunakan di controller)
                  String formattedDate =
                      DateFormat('MM-dd-yyyy').format(DateTime.now());

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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/tools.svg',
                                    color: Colors.white,
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Container(
                                  width: 150,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 2.0),
                                    color: Colors.pink,
                                  ),
                                  child: Image.network(
                                    (statusAlat["gambarAlat"] == null ||
                                            statusAlat['gambarAlat'].isEmpty)
                                        ? "https://ui-avatars.com/api/?name=Alat"
                                        : statusAlat['gambarAlat'],
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
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: servoStatus == 'GOOD'
                                            ? Colors.green
                                            : Colors.redAccent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 3,
                                        ),
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
                                                  width: 2,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  servoStatus,
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
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: pumpStatus == 'GOOD'
                                            ? Colors.green
                                            : Colors.redAccent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 3,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          const Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Pump",
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
                                                  width: 2,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  pumpStatus,
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
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.only(
                                    left: 14, right: 14, top: 4),
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryExtraSoft,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    width: 1,
                                    color: AppColors.secondaryExtraSoft,
                                  ),
                                ),
                                child: TextField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    suffixIcon:
                                        const Icon(Icons.text_snippet_outlined),
                                    label: Text(
                                      "Catatan",
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    border: InputBorder.none,
                                    hintText: catatan,
                                    hintStyle: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'poppins',
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Get.toNamed(
                                        Routes.EDIT_STATUS_ALAT,
                                        arguments: {
                                          'date': formattedDate,
                                          'statusAlat': statusAlat,
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text(
                                      "Edit",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyan,
                                      minimumSize: const Size(140, 50),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      controller
                                          .deleteStatusAlat(formattedDate);
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
