import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import './../../../../app/widgets/CustomWidgets/custom_input.dart';
import './../../../../app/styles/app_colors.dart';
import 'package:get/get.dart';

import '../controllers/new_password_controller.dart';

class NewPasswordView extends GetView<NewPasswordController> {
  const NewPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ubah Password",
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 14,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: SvgPicture.asset('assets/icons/arrow-left.svg'),
        ),
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
          Obx(
            () => CustomInput(
              controller: controller.currentPasswordController,
              label: 'Password Lama',
              hint: '******',
              obsecureText: controller.oldPasswordObs.value,
              suffixIcon: IconButton(
                icon: (controller.oldPasswordObs.value != false)
                    ? SvgPicture.asset('assets/icons/show.svg')
                    : SvgPicture.asset('assets/icons/hide.svg'),
                onPressed: () {
                  controller.oldPasswordObs.value =
                      !(controller.oldPasswordObs.value);
                },
              ),
            ),
          ),
          Obx(
            () => CustomInput(
              controller: controller.newPasswordController,
              label: 'Password Baru',
              hint: '******',
              obsecureText: controller.newPasswordObs.value,
              suffixIcon: IconButton(
                icon: (controller.newPasswordObs.value != false)
                    ? SvgPicture.asset('assets/icons/show.svg')
                    : SvgPicture.asset('assets/icons/hide.svg'),
                onPressed: () {
                  controller.newPasswordObs.value =
                      !(controller.newPasswordObs.value);
                },
              ),
            ),
          ),
          Obx(
            () => CustomInput(
              controller: controller.confirmNewPasswordController,
              label: 'Konfirmasi Password Baru',
              hint: '******',
              obsecureText: controller.newPasswordControllerObs.value,
              suffixIcon: IconButton(
                icon: (controller.newPasswordControllerObs.value != false)
                    ? SvgPicture.asset('assets/icons/show.svg')
                    : SvgPicture.asset('assets/icons/hide.svg'),
                onPressed: () {
                  controller.newPasswordControllerObs.value =
                      !(controller.newPasswordControllerObs.value);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Obx(
              () => ElevatedButton(
                onPressed: () async {
                  if (controller.isLoading.isFalse) {
                    await controller.updatePassword();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  (controller.isLoading.isFalse)
                      ? "Ubah Password"
                      : "Loading ... ",
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'poppins',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
