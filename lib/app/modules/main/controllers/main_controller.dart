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
    Stream<DatabaseEvent> feederStream =
        databaseReference.child('UsersData/$uid/feeder').onValue;

    return feederStream.asyncMap((snapshotFeeder) async {
      final feederEntries = Map<String, dynamic>.from(
          snapshotFeeder.snapshot.value as Map? ?? {});

      double totalFoodDay = 0;
      double totalWaterDay = 0;
      double totalFoodWeek = 0;
      double totalWaterWeek = 0;

      feederEntries.forEach((dateId, feederData) {
        if (feederData.containsKey('morningFeeder')) {
          totalFoodDay += double.parse(
              feederData['morningFeeder']['beratWadah']?.toString() ?? '0');
          totalWaterDay += double.parse(
              feederData['morningFeeder']['volumeMLWadah']?.toString() ?? '0');
        }
        if (feederData.containsKey('afternoonFeeder')) {
          totalFoodDay += double.parse(
              feederData['afternoonFeeder']['beratWadah']?.toString() ?? '0');
          totalWaterDay += double.parse(
              feederData['afternoonFeeder']['volumeMLWadah']?.toString() ??
                  '0');
        }
      });
      int counter = 0;
      feederEntries.forEach((dateId, feederData) {
        if (counter < 7) {
          if (feederData.containsKey('morningFeeder')) {
            totalFoodWeek += double.parse(
                feederData['morningFeeder']['beratWadah']?.toString() ?? '0');
            totalWaterWeek += double.parse(
                feederData['morningFeeder']['volumeMLWadah']?.toString() ??
                    '0');
          }
          if (feederData.containsKey('afternoonFeeder')) {
            totalFoodWeek += double.parse(
                feederData['afternoonFeeder']['beratWadah']?.toString() ?? '0');
            totalWaterWeek += double.parse(
                feederData['afternoonFeeder']['volumeMLWadah']?.toString() ??
                    '0');
          }
          counter++;
        }
      });
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
