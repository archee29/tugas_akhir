import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'dart:async';

import '../../../routes/app_pages.dart';
import '../../../widgets/dialog/custom_notification.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;
  RxString houseDistance = "-".obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  Timer? timer;
  RxBool systemSwitched = false.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () {
      if (auth.currentUser != null) {
        _fetchInitialSwitchStates();
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }

  void _fetchInitialSwitchStates() {
    String uid = auth.currentUser!.uid;
    databaseReference
        .child("UsersData/$uid/iot/monitoring/systemsStatus")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        systemSwitched.value = event.snapshot.value as bool;
      }
    });
  }

  void systemControl() {
    String uid = auth.currentUser!.uid;
    bool newValue = !systemSwitched.value;
    systemSwitched.value = newValue;
    databaseReference
        .child("UsersData/$uid/iot/monitoring/systemsStatus")
        .set(newValue)
        .catchError((error) {
      systemSwitched.value = !newValue;
      CustomNotification.errorNotification("Terjadi Kesalahan", "$error");
    });
  }

  Stream<DatabaseEvent> streamUser() {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      return database.ref('UsersData/$uid/UsersProfile').onValue.distinct();
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
          .onValue
          .distinct();

      Stream<DatabaseEvent> eveningStream = database
          .ref('UsersData/$uid/iot/feeder/jadwalSore/$todayDocId')
          .onValue
          .distinct();

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
        .child('UsersData/$uid/UsersProfile/beratKucing')
        .onValue
        .map((DatabaseEvent snapshot) {
      double beratKucingAsli =
          double.tryParse(snapshot.snapshot.value.toString()) ?? 0;

      double beratKucing = beratKucingAsli / 1000;

      double rER = 70 * pow(beratKucing, 0.75);
      double kebutuhanKaloriTerkoreksi = rER * 1.0;

      double rataRataKaloriMakananKering = 375;
      double kebutuhanMakananHarian =
          kebutuhanKaloriTerkoreksi / (rataRataKaloriMakananKering / 100);

      double porsiMakanPagi = kebutuhanMakananHarian / 2;
      double porsiMakanSore = kebutuhanMakananHarian / 2;

      double kebutuhanAirHarian = beratKucing * 60;
      double porsiAirPagi = kebutuhanAirHarian / 2;
      double porsiAirSore = kebutuhanAirHarian / 2;

      return {
        'kebutuhanMakananHarian': kebutuhanMakananHarian,
        'kebutuhanAirHarian': kebutuhanAirHarian,
        'porsiMakanPagi': porsiMakanPagi,
        'porsiMakanSore': porsiMakanSore,
        'porsiAirPagi': porsiAirPagi,
        'porsiAirSore': porsiAirSore,
      };
    });
  }

  String formatFoodOutput(double value) {
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

  String formatCombinedOutput(double value1, double value2, String unit) {
    String formatted1 = value1 >= 1000
        ? (value1 / 1000).toStringAsFixed(1)
        : value1.toStringAsFixed(0);
    String formatted2 = value2 >= 1000
        ? (value2 / 1000).toStringAsFixed(1)
        : value2.toStringAsFixed(0);
    String unitSuffix = value1 >= 1000 || value2 >= 1000
        ? unit == 'Gr'
            ? 'Kg'
            : 'L'
        : unit;
    return '($formatted1 & $formatted2) $unitSuffix';
  }

  double pow(double base, double exponent) {
    return math.pow(base, exponent).toDouble();
  }

  Stream<Map<String, dynamic>> streamInfoFeeder() {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      return database
          .ref('UsersData/$uid/UsersProfile')
          .onValue
          .map((DatabaseEvent snapshot) {
        if (snapshot.snapshot.value != null) {
          final data =
              Map<String, dynamic>.from(snapshot.snapshot.value as Map);
          return {
            'namaKandang': data['namaKandang'],
            'tabungMinum':
                formatLargeNumberOutput(data['tabungMinum'], unit: ' mL'),
            'tabungPakan':
                formatLargeNumberOutput(data['tabungPakan'], unit: ' Gr'),
            'wadahMinum':
                formatLargeNumberOutput(data['wadahMinum'], unit: ' mL'),
            'wadahPakan':
                formatLargeNumberOutput(data['wadahPakan'], unit: ' Gr'),
            'beratKucing':
                formatLargeNumberOutput(data['beratKucing'], unit: ' Gr'),
            'beratKucingAf':
                formatLargeNumberOutput(data['beratKucingAf'], unit: ' Gr'),
            'beratAkhir':
                formatLargeNumberOutput(data['beratAkhir'], unit: ' Gr'),
          };
        }
        return {};
      });
    } else {
      return Stream.value({});
    }
  }

  String formatLargeNumberOutput(dynamic value, {String unit = ''}) {
    if (value == null) return '0 $unit';
    double numValue = double.parse(value.toString());
    if (unit == ' Gr' && numValue >= 1000) {
      return '${(numValue / 1000).toStringAsFixed(1)} Kg';
    }
    if (unit == ' mL' && numValue >= 1000) {
      return '${(numValue / 1000).toStringAsFixed(1)} L';
    }
    return '${numValue.toStringAsFixed(0)}$unit';
  }
}
