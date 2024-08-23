import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  RxMap<String, dynamic> dataMorningFeeder = <String, dynamic>{}.obs;
  RxBool isLoading = false.obs;
  RxString houseDistance = "-".obs;
  RxInt totalMakananToday = 0.obs;
  RxInt totalMinumanToday = 0.obs;
  RxInt latestMakanan = 0.obs;
  RxInt latestMinuman = 0.obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  Timer? timer;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () {
      if (auth.currentUser != null) {
        streamUser().listen((event) {
          userData.value =
              Map<String, dynamic>.from(event.snapshot.value as Map);
        }, onError: (error) {
          print('Error streaming user data: $error');
        });
        streamTodayFeeder().listen((event) {
          if (event.snapshot.value != null) {
            dataMorningFeeder.value =
                Map<String, dynamic>.from(event.snapshot.value as Map);
          } else {
            dataMorningFeeder.value = {};
          }
        }, onError: (error) {
          print('Error streaming feeder data: $error');
        });
        streamOutput();
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }

  void streamOutput() {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      String todayDate = DateFormat.yMd().format(DateTime.now());
      fetchScheduleData("jadwalPagi", uid, todayDate);
      fetchScheduleData("jadwalSore", uid, todayDate);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void fetchScheduleData(String scheduleNode, String uid, String todayDate) {
    databaseReference
        .child("UsersData/$uid/manual/$scheduleNode")
        .orderByChild("tanggal")
        .equalTo(todayDate)
        .onValue
        .listen((event) {
      int makananSum = totalMakananToday.value;
      int minumanSum = totalMinumanToday.value;
      int latestMakananValue = latestMakanan.value;
      int latestMinumanValue = latestMinuman.value;
      if (event.snapshot.value != null) {
        Map<String, dynamic> values =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        values.forEach((key, value) {
          makananSum += int.parse(value['makanan']);
          minumanSum += int.parse(value['minuman']);
          latestMakananValue = int.parse(value['makanan']);
          latestMinumanValue = int.parse(value['minuman']);
        });
      }
      totalMakananToday.value = makananSum;
      totalMinumanToday.value = minumanSum;
      latestMakanan.value = latestMakananValue;
      latestMinuman.value = latestMinumanValue;
    }, onError: (error) {
      print('Error fetching schedule data: $error');
    });
  }

  Stream<Map<String, int>> streamDayCardData() {
    return CombineLatestStream.combine4<int, int, int, int, Map<String, int>>(
      latestMakanan.stream,
      latestMinuman.stream,
      totalMakananToday.stream,
      totalMinumanToday.stream,
      (latestMakanan, latestMinuman, totalMakanan, totalMinuman) => {
        "latestMakanan": latestMakanan,
        "latestMinuman": latestMinuman,
        "totalMakanan": totalMakanan,
        "totalMinuman": totalMinuman,
      },
    ).asBroadcastStream();
  }

  Stream<DatabaseEvent> streamUser() {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      return database.ref('UsersData/$uid/UsersProfile').onValue;
    } else {
      return const Stream.empty();
    }
  }

  Stream<DatabaseEvent> streamTodayFeeder() {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      String todayDocId =
          DateFormat.yMd().format(DateTime.now()).replaceAll("/", "-");
      return database.ref('UsersData/$uid/feeder/$todayDocId').onValue;
    } else {
      return const Stream.empty();
    }
  }
}
