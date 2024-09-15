import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import './../../../../app/widgets/dialog/custom_notification.dart';
import './../../../../app/routes/app_pages.dart';

class MainController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  RxBool servoSwitched = false.obs;
  RxBool pumpSwitched = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (auth.currentUser != null) {
      _fetchInitialSwitchStates();
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void _fetchInitialSwitchStates() {
    String uid = auth.currentUser!.uid;
    databaseReference
        .child("UsersData/$uid/iot/control/servoControl")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        servoSwitched.value = event.snapshot.value as bool;
      }
    });
    databaseReference
        .child("UsersData/$uid/iot/control/pumpControl")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        pumpSwitched.value = event.snapshot.value as bool;
      }
    });
  }

  void servoControl() {
    String uid = auth.currentUser!.uid;
    bool newValue = !servoSwitched.value;
    servoSwitched.value = newValue;
    databaseReference
        .child("UsersData/$uid/iot/control/servoControl")
        .set(newValue)
        .catchError((error) {
      servoSwitched.value = !newValue;
      CustomNotification.errorNotification("Terjadi Kesalahan", "$error");
    });
  }

  void pumpControl() {
    String uid = auth.currentUser!.uid;
    bool newValue = !pumpSwitched.value;
    pumpSwitched.value = newValue;
    databaseReference
        .child("UsersData/$uid/iot/control/pumpControl")
        .set(newValue)
        .catchError((error) {
      pumpSwitched.value = !newValue;
      CustomNotification.errorNotification("Terjadi Kesalahan", "$error");
    });
  }

  Stream<DatabaseEvent> streamUser() {
    String uid = auth.currentUser!.uid;
    return databaseReference.child("UsersData/$uid/UsersProfile").onValue;
  }

  Stream<Map<String, double>> calculateTotals() {
    String uid = auth.currentUser!.uid;

    Stream<DatabaseEvent> monitoringStream =
        databaseReference.child('UsersData/$uid/iot/monitoring').onValue;

    return monitoringStream.asyncMap((snapshotMonitoring) async {
      final monitoringData =
          Map<String, dynamic>.from(snapshotMonitoring.snapshot.value as Map);

      double totalFoodDay = 0;
      double totalWaterDay = 0;
      double totalFoodWeek = 0;
      double totalWaterWeek = 0;

      totalFoodDay =
          double.parse(monitoringData['beratWadah']?.toString() ?? '0');
      totalWaterDay =
          double.parse(monitoringData['volumeMLWadah']?.toString() ?? '0');

      for (int i = 0; i < 7; i++) {
        final weeklySnapshot = await databaseReference
            .child('UsersData/$uid/iot/monitoring/day$i')
            .once();
        final weeklyData =
            weeklySnapshot.snapshot.value as Map<String, dynamic>? ?? {};

        totalFoodWeek +=
            double.parse(weeklyData['beratWadah']?.toString() ?? '0');
        totalWaterWeek +=
            double.parse(weeklyData['volumeMLWadah']?.toString() ?? '0');
      }

      return {
        'totalFoodDay': totalFoodDay,
        'totalWaterDay': totalWaterDay,
        'totalFoodWeek': totalFoodWeek,
        'totalWaterWeek': totalWaterWeek,
      };
    });
  }

  String formatOutput(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)} Kg';
    } else {
      return '${value.toStringAsFixed(0)} Gram';
    }
  }

  String formatWaterOutput(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)} liter';
    } else {
      return '${value.toStringAsFixed(0)} mL';
    }
  }
}
