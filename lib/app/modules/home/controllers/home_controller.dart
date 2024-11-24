import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'dart:async';

import '../../../routes/app_pages.dart';
import '../../../widgets/dialog/custom_notification.dart';

class HomeController extends GetxController {
  RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  RxBool isLoading = false.obs;
  RxString houseDistance = "-".obs;
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
          CustomNotification.errorNotification(
              "Terjadi Kesalahan", "Error : $error");
        });
        streamBothSchedules();
        calculateTotals();
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }

  Stream<DatabaseEvent> streamUser() {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      return database.ref('UsersData/$uid/UsersProfile').onValue;
    } else {
      return const Stream.empty();
    }
  }

  Stream<Map<String, DatabaseEvent>> streamBothSchedules() {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      String todayDocId = DateFormat('MM-dd-yyyy').format(DateTime.now());

      Stream<DatabaseEvent> morningStream = database
          .ref('UsersData/$uid/iot/feeder/jadwalPagi/$todayDocId')
          .onValue;

      Stream<DatabaseEvent> eveningStream = database
          .ref('UsersData/$uid/iot/feeder/jadwalSore/$todayDocId')
          .onValue;

      return rx.Rx.combineLatest2(
        morningStream,
        eveningStream,
        (DatabaseEvent morning, DatabaseEvent evening) => {
          'morning': morning,
          'evening': evening,
        },
      );
    } else {
      return Stream.value({});
    }
  }

  Stream<Map<String, double>> calculateTotals() {
    String uid = auth.currentUser!.uid;
    return databaseReference
        .child('UsersData/$uid/iot/feeder')
        .onValue
        .map((DatabaseEvent snapshot) {
      double totalFoodDay = 0;
      double totalWaterDay = 0;

      if (snapshot.snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        if (data.containsKey('jadwalPagi')) {
          final morningData = Map<String, dynamic>.from(data['jadwalPagi']);
          morningData.forEach((key, value) {
            if (value is Map) {
              totalFoodDay +=
                  double.parse(value['beratWadah']?.toString() ?? '0');
              totalWaterDay +=
                  double.parse(value['volumeMLWadah']?.toString() ?? '0');
            }
          });
        }
        if (data.containsKey('jadwalSore')) {
          final afternoonData = Map<String, dynamic>.from(data['jadwalSore']);
          afternoonData.forEach((key, value) {
            if (value is Map) {
              totalFoodDay +=
                  double.parse(value['beratWadah']?.toString() ?? '0');
              totalWaterDay +=
                  double.parse(value['volumeMLWadah']?.toString() ?? '0');
            }
          });
        }
      }
      return {
        'totalFoodDay': totalFoodDay,
        'totalWaterDay': totalWaterDay,
      };
    });
  }

  String formatOutput(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)} Kg';
    } else {
      return '${value.toStringAsFixed(0)} Gr';
    }
  }

  String formatWaterOutput(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)} L';
    } else {
      return '${value.toStringAsFixed(0)} mL';
    }
  }
}
