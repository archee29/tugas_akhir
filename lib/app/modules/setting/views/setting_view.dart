import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../controllers/page_index_controller.dart';
import './../../../../app/routes/app_pages.dart';
import './../../../../app/styles/app_colors.dart';
import './../../../../app/widgets/CustomWidgets/custom_bottom_navbar.dart';

import '../controllers/setting_controller.dart';

class SettingView extends GetView<SettingController> {
  final pageIndexController = Get.find<PageIndexController>();

  SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: StreamBuilder<DatabaseEvent>(
        stream: controller.streamUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData &&
              snapshot.data!.snapshot.value != null) {
            Map<String, dynamic> userData =
                Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
            return ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 36),
              children: [
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Container(
                        width: 124,
                        height: 124,
                        color: Colors.pink,
                        child: Image.network(
                          (userData["avatar"] == null ||
                                  userData['avatar'] == "")
                              ? "https://ui-avatars.com/api/?name=${userData['name']}/"
                              : userData['avatar'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 16, bottom: 4),
                      child: Text(
                        userData["name"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      userData["job"],
                      style: TextStyle(color: AppColors.secondarySoft),
                    )
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(top: 42),
                  child: Column(
                    children: [
                      MenuTile(
                        title: 'Update Profile',
                        icon: SvgPicture.asset(
                          'assets/icons/profile-1.svg',
                        ),
                        onTap: () => Get.toNamed(
                          Routes.UPDATE_PROFILE,
                          arguments: userData,
                        ),
                      ),
                      if (userData["role"] == "admin")
                        MenuTile(
                            title: "Status Alat",
                            icon: SvgPicture.asset(
                              'assets/icons/tools-setting.svg',
                            ),
                            onTap: () async {
                              controller.checkAndNavigate();
                            }),
                      MenuTile(
                        title: "Ubah Password",
                        icon: SvgPicture.asset(
                          'assets/icons/password.svg',
                        ),
                        onTap: () => Get.toNamed(Routes.NEW_PASSWORD),
                      ),
                      MenuTile(
                        title: "History Feeder",
                        icon: SvgPicture.asset(
                          'assets/icons/history.svg',
                        ),
                        onTap: () => Get.toNamed(Routes.DETAIL_FEEDER),
                      ),
                      MenuTile(
                        isDanger: true,
                        title: 'Keluar',
                        icon: SvgPicture.asset(
                          'assets/icons/logout.svg',
                        ),
                        onTap: controller.logout,
                      ),
                      Container(
                        height: 1,
                        color: AppColors.primaryExtraSoft,
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text("No user data found"));
          }
        },
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final String title;
  final Widget icon;
  final void Function() onTap;
  final bool isDanger;

  const MenuTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.secondaryExtraSoft,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              margin: const EdgeInsets.only(right: 24),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryExtraSoft,
                borderRadius: BorderRadius.circular(100),
              ),
              child: icon,
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: (isDanger == false)
                      ? AppColors.secondary
                      : AppColors.error,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 24),
              child: SvgPicture.asset(
                'assets/icons/arrow-right.svg',
                // ignore: deprecated_member_use
                color:
                    (isDanger == false) ? AppColors.secondary : AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
