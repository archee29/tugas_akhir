import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../../app/styles/app_colors.dart';
import './../../../../app/widgets/CustomWidgets/custom_input.dart';
import '../controllers/update_profile_controller.dart';

class UpdateProfileView extends GetView<UpdateProfileController> {
  final Map<String, dynamic> user = Get.arguments;

  UpdateProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 14,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: SvgPicture.asset('assets/icons/arrow-left.svg'),
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed: () {
                if (controller.isLoading.isFalse) {
                  controller.updateProfile();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
              child:
                  Text((controller.isLoading.isFalse) ? 'Done' : 'Loading...'),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 1,
            color: AppColors.secondaryExtraSoft,
          ),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              children: [
                GetBuilder<UpdateProfileController>(
                  builder: (controller) {
                    if (controller.image != null) {
                      return ClipOval(
                        child: Container(
                          width: 98,
                          height: 98,
                          color: AppColors.primary,
                          child: Image.file(
                            File(controller.image!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    } else {
                      return ClipOval(
                        child: Container(
                          width: 98,
                          height: 98,
                          color: AppColors.primary,
                          child: Image.network(
                            (user["avatar"] == null || user['avatar'] == "")
                                ? "https://ui-avatars.com/api/?name=${user['name']}/"
                                : user['avatar'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }
                  },
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.pickImage();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: SvgPicture.asset('assets/icons/camera.svg'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomInput(
            controller: controller.nameController,
            label: "Nama Lengkap",
            hint: "Masukkan Nama Lengkap",
            margin: const EdgeInsets.only(bottom: 16, top: 42),
          ),
          CustomInput(
            controller: controller.emailController,
            label: "Email",
            hint: "youremail@email.com",
            disabled: true,
          ),
          CustomInput(
            controller: controller.nkController,
            label: "Nama Kandang",
            hint: "Masukkan Nama Kandang",
          ),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CustomInput(
                        controller: controller.tpController,
                        label: "Tabung Pakan",
                        hint: "Masukkan Berat Tabung Pakan",
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: CustomInput(
                        controller: controller.wpController,
                        label: "Wadah Pakan",
                        hint: "Masukkan Berat Wadah Pakan",
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CustomInput(
                        controller: controller.tmController,
                        label: "Tabung Minum",
                        hint: "Masukkan Berat Tabung Minum",
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: CustomInput(
                        controller: controller.wmController,
                        label: "Wadah Minum",
                        hint: "Masukkan Berat Wadah Minum",
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          CustomInput(
            controller: controller.bkController,
            label: "Berat Badan Kucing",
            hint: "Masukkan Berat Badan Kucing",
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
