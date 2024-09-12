import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import './app/modules/data/controllers/data_controller.dart';
import './app/modules/edit_jadwal/controllers/edit_jadwal_controller.dart';
import './app/routes/app_pages.dart';
import './app/controllers/page_index_controller.dart';
import './app/controllers/feeder_controller.dart';
import './app/widgets/splash_screen.dart';
import './app/controllers/notification_service.dart';
import './app/modules/home/controllers/home_controller.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  LocalNotificationService localNotificationService =
      LocalNotificationService();
  await localNotificationService.init();
  await localNotificationService.requestPermissions();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  print("FCM Token: $token");
  // fcm token : fhtQQQNrQz2d5p3O1Ehgjw:APA91bFByRqo6lMvdLHu4lnqnYzEOLEsA8ggLfpL1NlUNTplCtzLxsn-GAu_n5xd0gxnFtAwRet50Fo-0yZdPQ_ldK76DRYXiLjKqUQxnj8aGFaQX9lzRcWUVgNiaJLPdVU3a58al9ZQ

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Pesan diterima saat di foreground: ${message.notification?.title}');
  });

  Get.put(LocalNotificationService(), permanent: true);
  Get.put(FeederController(), permanent: true);
  Get.put(PageIndexController(), permanent: true);
  Get.put(DataController(), permanent: true);
  Get.put(HomeController(), permanent: true);
  Get.put(EditJadwalController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
          );
        }
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
