import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
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
    return databaseReference
        .child('UsersData/$uid/iot/feeder')
        .onValue
        .map((DatabaseEvent snapshot) {
      double totalFoodDay = 0;
      double totalWaterDay = 0;
      double totalFoodWeek = 0;
      double totalWaterWeek = 0;
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
              DateTime entryDate =
                  DateFormat('dd/MM/yyyy').parse(value['ketHari']);
              if (DateTime.now().difference(entryDate).inDays <= 7) {
                totalFoodWeek +=
                    double.parse(value['beratWadah']?.toString() ?? '0');
                totalWaterWeek +=
                    double.parse(value['volumeMLWadah']?.toString() ?? '0');
              }
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
              DateTime entryDate =
                  DateFormat('dd/MM/yyyy').parse(value['ketHari']);
              if (DateTime.now().difference(entryDate).inDays <= 7) {
                totalFoodWeek +=
                    double.parse(value['beratWadah']?.toString() ?? '0');
                totalWaterWeek +=
                    double.parse(value['volumeMLWadah']?.toString() ?? '0');
              }
            }
          });
        }
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
      return '${(value / 1000).toStringAsFixed(1)} Liter';
    } else {
      return '${value.toStringAsFixed(0)} mL';
    }
  }
}
