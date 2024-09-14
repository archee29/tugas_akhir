import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import './../../../widgets/dialog/custom_alert_dialog.dart';
import '../../../widgets/dialog/custom_notification.dart';
import './../../../../app/routes/app_pages.dart';

class DataController extends GetxController
    with GetSingleTickerProviderStateMixin {
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  final listDataMf = <Map<String, dynamic>>[].obs;
  final listDataAf = <Map<String, dynamic>>[].obs;

  var events = <DateTime, List<String>>{}.obs;
  var selectedDay = Rx<DateTime?>(null);
  var focusedDay = DateTime.now().obs;

  final DateFormat dateFormat = DateFormat('M/d/yyyy');

  RxInt makananValue = 0.obs;
  RxInt minumanValue = 0.obs;

  RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  RxMap<String, dynamic> monitoringData = <String, dynamic>{}.obs;

  StreamSubscription<User?>? _authStreamSubscription;

  late TabController dataTabController;
  final List<Tab> dataTabs = <Tab>[
    const Tab(text: 'Data Jadwal Pagi'),
    const Tab(text: 'Data Jadwal Sore'),
  ];

  // Variabel untuk status pemuatan
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    dataTabController = TabController(length: 2, vsync: this);
    Future.delayed(Duration.zero, () {
      if (auth.currentUser != null) {
        streamUser().listen((event) {
          userData.value =
              Map<String, dynamic>.from(event.snapshot.value as Map);
        }, onError: (error) {
          print('Error streaming user data: $error');
        });
        streamMonitoring();
        retrieveDataMF();
        retrieveDataAf();
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }

  @override
  void onClose() {
    _authStreamSubscription?.cancel();
    dataTabController.dispose();
    super.onClose();
  }

  Stream<DatabaseEvent> streamUser() {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      return databaseReference.child('UsersData/$uid/UsersProfile').onValue;
    } else {
      return const Stream.empty();
    }
  }

  Stream<Map<String, double>> streamMonitoring() {
    String uid = auth.currentUser!.uid;

    // Stream untuk monitoring
    Stream<DatabaseEvent> monitoringStream =
        databaseReference.child('UsersData/$uid/iot/monitoring').onValue;

    return monitoringStream.map((snapshotMonitoring) {
      // Mendapatkan data monitoring dari snapshot
      final monitoringData =
          Map<String, dynamic>.from(snapshotMonitoring.snapshot.value as Map);

      // Parsing data monitoring
      double beratWadah =
          double.parse(monitoringData['beratWadah']?.toString() ?? '0');
      double volumeMLWadah =
          double.parse(monitoringData['volumeMLWadah']?.toString() ?? '0');

      return {
        'beratWadah': beratWadah,
        'volumeMLWadah': volumeMLWadah,
      };
    });
  }

  Future<void> retrieveDataMF() async {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      databaseReference
          .child("UsersData/$uid/penjadwalan/jadwalPagi")
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          final values = Map<String, dynamic>.from(event.snapshot.value as Map);
          final parsedValues = values.entries
              .map((e) {
                var value = Map<String, dynamic>.from(e.value);
                value['key'] = e.key;
                if (value.containsKey('tanggal')) {
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

  Future<void> retrieveDataAf() async {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      databaseReference
          .child("UsersData/$uid/penjadwalan/jadwalSore")
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          final values = Map<String, dynamic>.from(event.snapshot.value as Map);
          final parsedValues = values.entries
              .map((e) {
                var value = Map<String, dynamic>.from(e.value);
                value['key'] = e.key;
                if (value.containsKey('tanggal')) {
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
      DateTime eventDate = dateFormat.parse(event['tanggal']);
      if (isSameDay(eventDate, day)) {
        events.add(event);
      }
    }
    for (var event in listDataAf) {
      DateTime eventDate = dateFormat.parse(event['tanggal']);
      if (isSameDay(eventDate, day)) {
        events.add(event);
      }
    }
    return events;
  }

  void showEventDetails(List events) {
    Get.defaultDialog(
      title: "Detail Jadwal",
      content: SingleChildScrollView(
        child: Column(
          children: events.map((event) {
            return Card(
              child: ListTile(
                title: Text("Judul\t\t\t\t\t: ${event['title']}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Deskripsi\t: ${event['deskripsi']}"),
                    Text("Tanggal\t\t\t: ${event['tanggal']}"),
                    Text("Waktu\t\t\t\t\t\t: ${event['waktu']}"),
                    Text("Makanan\t: ${event['makanan']}Gr"),
                    Text("Minuman\t: ${event['minuman']}mL"),
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

  Future<void> deleteDataMF(String key) async {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      CustomAlertDialog.showFeederAlert(
        title: "Hapus Data",
        message: "Apakah Anda Yakin Untuk Menghapus Data?",
        onCancel: () => Get.back(),
        onConfirm: () async {
          try {
            await databaseReference
                .child("UsersData/$uid/penjadwalan/jadwalPagi/$key")
                .remove();
            listDataMf.removeWhere((element) => element['key'] == key);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.back();
              Get.back();
              Get.back();
              CustomNotification.successNotification(
                  "Berhasil", "Berhasil Menghapus Data Jadwal Pagi");
            });
          } catch (e) {
            CustomNotification.errorNotification(
                "Terjadi Kesalahan", e.toString());
          }
        },
      );
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> deleteDataAF(String key) async {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      CustomAlertDialog.showFeederAlert(
        title: "Hapus Data",
        message: "Apakah Anda Yakin Untuk Menghapus Data?",
        onCancel: () => Get.back(),
        onConfirm: () async {
          try {
            await databaseReference
                .child("UsersData/$uid/penjadwalan/jadwalSore/$key")
                .remove();
            listDataAf.removeWhere((element) => element['key'] == key);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.back();
              Get.back();
              Get.back();
              CustomNotification.successNotification(
                  "Berhasil", "Berhasil Menghapus Data Jadwal Sore");
            });
            CustomNotification.successNotification(
                "Berhasil", "Menghapus Data Jadwal Sore");
          } catch (e) {
            CustomNotification.errorNotification(
                "Terjadi Kesalahan", e.toString());
          }
        },
      );
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
