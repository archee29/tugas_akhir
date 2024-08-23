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
  StreamSubscription<User?>? _authStreamSubscription;
  late TabController dataTabController;

  final List<Tab> dataTabs = <Tab>[
    const Tab(text: 'Data Jadwal Pagi'),
    const Tab(text: 'Data Jadwal Sore'),
  ];

  @override
  void onInit() {
    super.onInit();
    _authStreamSubscription = auth.authStateChanges().listen((user) {
      if (user != null) {
        streamUser().listen((event) {
          userData.value =
              Map<String, dynamic>.from(event.snapshot.value as Map);
        });
        dataTabController = TabController(length: 2, vsync: this);
        retrieveData();
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

  Stream<DatabaseEvent> streamTodayFeeder() {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      String todayDocId =
          DateFormat.yMd().format(DateTime.now()).replaceAll("/", "-");
      return databaseReference
          .child('UsersData/$uid/iot/feeder/$todayDocId')
          .onValue;
    } else {
      return const Stream.empty();
    }
  }

  Future<void> retrieveData() async {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      databaseReference.child("UsersData/$uid/iot").onValue.listen((event) {
        if (event.snapshot.value != null) {
          final values = Map<String, dynamic>.from(event.snapshot.value as Map);
          makananValue.value = values['makanan'] ?? 0;
          minumanValue.value = values['minuman'] ?? 0;
        } else {
          makananValue.value = 0;
          minumanValue.value = 0;
        }
      });
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> retrieveDataMF() async {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      databaseReference
          .child("UsersData/$uid/manual/jadwalPagi")
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
          listDataMf.assignAll(parsedValues);
        } else {
          listDataMf.clear();
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
          .child("UsersData/$uid/manual/jadwalSore")
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
          listDataAf.assignAll(parsedValues);
        } else {
          listDataAf.clear();
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

  void deleteDataMF(String key) async {
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
                .child("UsersData/$uid/manual/jadwalPagi/$key")
                .remove();
            listDataMf.removeWhere((element) => element['key'] == key);
            update();
            CustomNotification.successNotification(
                "Berhasil", "Menghapus Data Jadwal Pagi");
          } catch (e) {
            CustomNotification.errorNotification("Terjadi Kesalahan", "$e");
          }
        },
      );
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void deleteDataAF(String key) async {
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
                .child("UsersData/$uid/manual/jadwalSore/$key")
                .remove();
            listDataAf.removeWhere((element) => element['key'] == key);
            update();
            CustomNotification.successNotification(
                "Berhasil", "Menghapus Data Jadwal Sore");
          } catch (e) {
            CustomNotification.errorNotification("Terjadi Kesalahan", "$e");
          }
        },
      );
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
