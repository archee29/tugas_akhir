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

  Future<Map<String, dynamic>> fetchSchedules() async {
    String uid = auth.currentUser!.uid;
    final snapshotPagi = await databaseReference
        .child('UsersData/$uid/manual/jadwalPagi')
        .once();
    final snapshotSiang = await databaseReference
        .child('UsersData/$uid/manual/jadwalSore')
        .once();

    final pagiData = snapshotPagi.snapshot.value as Map<String, dynamic>? ?? {};
    final siangData =
        snapshotSiang.snapshot.value as Map<String, dynamic>? ?? {};

    return {
      'jadwalPagi': pagiData,
      'jadwalSore': siangData,
    };
  }

  Future<Map<String, double>> calculateTotals() async {
    final schedules = await fetchSchedules();

    double totalFoodDay = 0;
    double totalWaterDay = 0;
    double totalFoodWeek = 0;
    double totalWaterWeek = 0;

    schedules['jadwalPagi'].forEach((key, value) {
      totalFoodDay += double.parse(value['makanan'] ?? '0');
      totalWaterDay += double.parse(value['minuman'] ?? '0');
    });

    schedules['jadwalSore'].forEach((key, value) {
      totalFoodDay += double.parse(value['makanan'] ?? '0');
      totalWaterDay += double.parse(value['minuman'] ?? '0');
    });

    totalFoodWeek = totalFoodDay * 7;
    totalWaterWeek = totalWaterDay * 7;

    return {
      'totalFoodDay': totalFoodDay,
      'totalWaterDay': totalWaterDay,
      'totalFoodWeek': totalFoodWeek,
      'totalWaterWeek': totalWaterWeek,
    };
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
