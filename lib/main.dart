import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './app/modules/chart/controllers/chart_controller.dart';
import './app/modules/detail_feeder/controllers/detail_feeder_controller.dart';
import './app/modules/statistik/controllers/statistik_controller.dart';
import './app/routes/app_pages.dart';
import 'app/controllers/schedule_button_controller.dart';
import './app/controllers/page_index_controller.dart';
import './app/controllers/notification_service.dart';
import './app/modules/home/controllers/home_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(HomeController(), permanent: true);
  Get.put(NotificationService(), permanent: true);
  Get.put(ScheduleButtonController(), permanent: true);
  Get.put(StatistikController(), permanent: true);
  Get.put(PageIndexController(), permanent: true);
  Get.put(DetailFeederController(), permanent: true);
  Get.put(ChartController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return GetMaterialApp(
          title: "Tugas Akhir",
          debugShowCheckedModeBanner: false,
          initialRoute: snapshot.data != null ? Routes.HOME : Routes.LOGIN,
          getPages: AppPages.routes,
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'inter',
          ),
        );
      },
    );
  }
}
