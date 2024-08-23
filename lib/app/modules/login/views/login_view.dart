import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import './../../../../app/styles/app_colors.dart';
import './../../../../app/routes/app_pages.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          children: [
            const SizedBox(height: 30),
            TextButton.icon(
              onPressed: () {},
              icon: Image.asset('assets/icons/icon-kucing-black.png'),
              label: Text(
                "Automatic Cat Feeder",
                style: TextStyle(
                  decorationColor: AppColors.primary,
                  decorationThickness: 3,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              alignment: Alignment.center,
              height: 150,
              child: Image.asset(
                'assets/images/icon-kucing.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                hintText: "Masukkan Email",
                icon: Icon(
                  Icons.email_outlined,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => TextField(
                controller: controller.passwordController,
                obscureText: controller.obsecureText.value,
                keyboardType: TextInputType.visiblePassword,
                autocorrect: false,
                decoration: InputDecoration(
                  // ignore: unrelated_type_equality_checks
                  suffixIcon: IconButton(
                    color: AppColors.primarySoft,
                    // ignore: unrelated_type_equality_checks
                    icon: (controller.obsecureText != false)
                        ? SvgPicture.asset('assets/icons/show.svg')
                        : SvgPicture.asset('assets/icons/hide.svg'),
                    onPressed: () {
                      controller.obsecureText.value =
                          !(controller.obsecureText.value);
                    },
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  hintText: "Masukkan Password",
                  icon: Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Obx(
              () => SizedBox(
                width: Get.width,
                child: ElevatedButton(
                  onPressed: () async {
                    if (controller.isLoading.isFalse) {
                      await controller.login();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    (controller.isLoading.isFalse) ? 'Masuk' : 'Loading ....',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.toNamed(Routes.RESET),
                child: const Text(
                  "Lupa Password ?",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFFF92C85),
                    decorationStyle: TextDecorationStyle.solid,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              textAlign: TextAlign.center,
              "Dengan melanjutkan, kamu menerima dan Syarat Penggunaan Kebijakan Privasi Kami",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
