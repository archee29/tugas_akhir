import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../styles/app_colors.dart';
import '../../../widgets/dialog/custom_notification.dart';
import '../../../routes/app_pages.dart';

class StatistikController extends GetxController {
  RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  RxBool systemsStatus = false.obs;
  RxBool servoSwitched = false.obs;
  RxBool pumpSwitched = false.obs;
  final listDataMf = <Map<String, dynamic>>[].obs;
  final listDataAf = <Map<String, dynamic>>[].obs;
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  final DateTime startDate = DateTime(2024, 12, 3);
  final DateTime endDate = DateTime(2024, 12, 17);

  var events = <DateTime, List<String>>{}.obs;
  var selectedDay = Rx<DateTime?>(null);
  var focusedDay = DateTime.now().obs;
  var isLoading = true.obs;

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
        _listenToSystemsStatus();
        _fetchInitialSwitchStates();
        calculateTotals();
        retrieveDataFeederMF();
        retrieveDataFeederAF();
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
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
        .listen(
      (event) {
        if (event.snapshot.value != null) {
          pumpSwitched.value = event.snapshot.value as bool;
        }
      },
    );
  }

  void _listenToSystemsStatus() {
    String uid = auth.currentUser!.uid;
    databaseReference
        .child("UsersData/$uid/iot/systemsStatus/isConnected")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        systemsStatus.value = event.snapshot.value as bool;
      }
    });
  }

  void servoControl() {
    if (systemsStatus.value) {
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
    } else {
      CustomNotification.errorNotification("Perangkat Tidak Aktif",
          "Button Servo hanya dapat digunakan saat perangkat hidup.");
    }
  }

  void pumpControl() {
    if (systemsStatus.value) {
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
    } else {
      CustomNotification.errorNotification("Perangkat Tidak Aktif",
          "Button Pump hanya dapat digunakan saat perangkat hidup.");
    }
  }

  Stream<DatabaseEvent> streamUser() {
    String uid = auth.currentUser!.uid;
    return databaseReference.child("UsersData/$uid/UsersProfile").onValue;
  }

  Stream<Map<String, dynamic>> calculateTotals() {
    String uid = auth.currentUser!.uid;
    return databaseReference.child('UsersData/$uid/iot/feeder').onValue.map(
      (DatabaseEvent snapshot) {
        double parseDouble(dynamic value, {double defaultValue = 0.0}) {
          if (value == null) return defaultValue;
          return double.tryParse(value.toString()) ?? defaultValue;
        }

        double beratKucingAsli = parseDouble(userData['beratKucing']);
        double beratKucingAf = parseDouble(userData['beratKucingAf']);

        double beratAkhir = beratKucingAsli + beratKucingAf;

        double pertumbuhanKucing = beratKucingAsli > 0
            ? ((beratAkhir - beratKucingAsli) / beratKucingAsli) * 100
            : 0.0;

        Map<String, dynamic> updateData = {
          'beratAkhir': beratAkhir,
        };

        if (pertumbuhanKucing.isFinite) {
          updateData['pertumbuhanKucing'] = pertumbuhanKucing;
        }

        databaseReference
            .child('UsersData/$uid/UsersProfile')
            .update(updateData);

        double beratKucing = beratKucingAsli / 1000;

        double rER = 70 * pow(beratKucing, 0.75);
        double kebutuhanKaloriTerkoreksi = rER * 1.8;

        double rataRataKaloriMakananKering = 375;
        double kebutuhanMakananHarian =
            kebutuhanKaloriTerkoreksi / (rataRataKaloriMakananKering / 100);

        double kebutuhanAirHarian = beratKucing * 60;

        double totalFoodPeriod = 0;
        double totalWaterPeriod = 0;
        Map<String, Map<String, double>> dailyTotals = {};

        if (snapshot.snapshot.value != null) {
          final data =
              Map<String, dynamic>.from(snapshot.snapshot.value as Map);
          void processScheduleData(Map<String, dynamic> scheduleData) {
            scheduleData.forEach((key, value) {
              if (value is Map) {
                DateTime entryDate = dateFormat.parse(value['ketHari']);
                if (entryDate
                        .isAfter(startDate.subtract(const Duration(days: 1))) &&
                    entryDate.isBefore(endDate.add(const Duration(days: 1)))) {
                  double foodAmount =
                      double.parse(value['beratWadah']?.toString() ?? '0');
                  double waterAmount =
                      double.parse(value['volumeMLWadah']?.toString() ?? '0');
                  totalFoodPeriod += foodAmount;
                  totalWaterPeriod += waterAmount;
                  String dateKey = dateFormat.format(entryDate);
                  dailyTotals[dateKey] ??= {'food': 0, 'water': 0};
                  dailyTotals[dateKey]!['food'] =
                      (dailyTotals[dateKey]!['food'] ?? 0) + foodAmount;
                  dailyTotals[dateKey]!['water'] =
                      (dailyTotals[dateKey]!['water'] ?? 0) + waterAmount;
                }
              }
            });
          }

          if (data.containsKey('jadwalPagi')) {
            processScheduleData(Map<String, dynamic>.from(data['jadwalPagi']));
          }

          if (data.containsKey('jadwalSore')) {
            processScheduleData(Map<String, dynamic>.from(data['jadwalSore']));
          }
        }

        double avgFoodPerDay =
            dailyTotals.isEmpty ? 0 : totalFoodPeriod / dailyTotals.length;
        double avgWaterPerDay =
            dailyTotals.isEmpty ? 0 : totalWaterPeriod / dailyTotals.length;

        bool cukupMakananHarian = avgFoodPerDay >= kebutuhanMakananHarian;
        bool cukupAirHarian = avgWaterPerDay >= kebutuhanAirHarian;

        return {
          'totalFoodPeriod': totalFoodPeriod,
          'totalWaterPeriod': totalWaterPeriod,
          'avgFoodPerDay': avgFoodPerDay,
          'avgWaterPerDay': avgWaterPerDay,
          'dailyTotals': dailyTotals,
          'daysCount': dailyTotals.length,
          'kebutuhanMakananHarian': kebutuhanMakananHarian,
          'kebutuhanAirHarian': kebutuhanAirHarian,
          'cukupMakananHarian': cukupMakananHarian,
          'cukupAirHarian': cukupAirHarian,
          'beratKucing': beratAkhir,
          'pertumbuhanKucing': pertumbuhanKucing,
        };
      },
    );
  }

  String formatPertumbuhanOutput(double value) {
    return '${value.toStringAsFixed(2)}%';
  }

  String formatFoodOutput(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(3)} Kg';
    } else {
      return '${value.toStringAsFixed(0)} Gram';
    }
  }

  String formatWaterOutput(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(3)} Liter';
    } else {
      return '${value.toStringAsFixed(0)} mL';
    }
  }

  double pow(double base, double exponent) {
    return math.pow(base, exponent).toDouble();
  }

  Future<void> retrieveDataFeederMF() async {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      databaseReference
          .child("UsersData/$uid/iot/feeder/jadwalPagi")
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          final values = Map<String, dynamic>.from(event.snapshot.value as Map);
          final parsedValues = values.entries
              .map((e) {
                var value = Map<String, dynamic>.from(e.value);
                value['key'] = e.key;
                if (value.containsKey('ketHari')) {
                  return value;
                }
                return null;
              })
              .where((element) => element != null)
              .cast<Map<String, dynamic>>()
              .toList();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            listDataMf.assignAll(parsedValues);
            isLoading.value = false;
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            listDataMf.clear();
            isLoading.value = false;
          });
        }
      });
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> retrieveDataFeederAF() async {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      databaseReference
          .child("UsersData/$uid/iot/feeder/jadwalSore")
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          final values = Map<String, dynamic>.from(event.snapshot.value as Map);
          final parsedValues = values.entries
              .map((e) {
                var value = Map<String, dynamic>.from(e.value);
                value['key'] = e.key;
                if (value.containsKey('ketHari')) {
                  return value;
                }
                return null;
              })
              .where((element) => element != null)
              .cast<Map<String, dynamic>>()
              .toList();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            listDataAf.assignAll(parsedValues);
            isLoading.value = false;
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            listDataAf.clear();
            isLoading.value = false;
          });
        }
      });
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  List getEvents(DateTime day) {
    List events = [];
    for (var event in listDataMf) {
      DateTime eventDate = dateFormat.parse(event['ketHari']);
      if (isSameDay(eventDate, day)) {
        events.add(event);
      }
    }
    for (var event in listDataAf) {
      DateTime eventDate = dateFormat.parse(event['ketHari']);
      if (isSameDay(eventDate, day)) {
        events.add(event);
      }
    }
    return events;
  }

  void showEventDetails(List events) {
    Get.defaultDialog(
      title: "Detail Feeder",
      content: SingleChildScrollView(
        child: Column(
          children: events.map((event) {
            DateTime eventTime = DateFormat('H:m:s').parse(event['ketWaktu']);
            String feeder =
                eventTime.hour < 12 ? "Morning Feeder" : "Afternoon Feeder";
            return Card(
              child: ListTile(
                title: Text(
                  feeder,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tanggal\t\t\t\t: ${event['ketHari']}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      "Waktu\t\t\t\t\t\t\t: ${DateFormat('HH:mm:ss').format(
                        DateFormat('H:m:s').parse(event['ketWaktu']),
                      )}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      "Makanan\t\t: ${event['beratWadah']} Gr",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      "Minuman\t\t: ${event['volumeMLWadah']} mL",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        child: const Text("Close"),
      ),
    );
  }
}
