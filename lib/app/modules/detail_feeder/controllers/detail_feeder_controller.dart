import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../styles/app_colors.dart';
import '../../../widgets/dialog/custom_notification.dart';
import './../../../../app/routes/app_pages.dart';

class DetailFeederController extends GetxController
    with GetSingleTickerProviderStateMixin {
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  final listDataMf = <Map<String, dynamic>>[].obs;
  final listDataAf = <Map<String, dynamic>>[].obs;

  RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  RxMap<String, dynamic> monitoringData = <String, dynamic>{}.obs;
  StreamSubscription<User?>? _authStreamSubscription;
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  var events = <DateTime, List<String>>{}.obs;
  var selectedDay = Rx<DateTime?>(null);
  var focusedDay = DateTime.now().obs;

  late TabController dataTabController;
  var isLoading = true.obs;

  final List<Tab> dataTabs = <Tab>[
    const Tab(text: 'Data Feeder Pagi'),
    const Tab(text: 'Data Feeder Sore'),
  ];

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
          CustomNotification.errorNotification(
              "Terjadi Kesalahan", "Error : $error");
        });
        streamMonitoring();
        retrieveDataFeederMF();
        retrieveDataFeederAF();
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

    Stream<DatabaseEvent> monitoringStream =
        databaseReference.child('UsersData/$uid/iot/monitoring').onValue;

    return monitoringStream.map((snapshotMonitoring) {
      final monitoringData =
          Map<String, dynamic>.from(snapshotMonitoring.snapshot.value as Map);

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
            String feeder = event['ketWaktu'] == '7:0:0'
                ? "Morning Feeder"
                : "Afternoon Feeder";
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
                      "Tanggal\t\t\t: ${event['ketHari']}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      "Waktu\t\t\t\t\t\t\t: ${event['ketWaktu']}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      "Makanan\t: ${event['beratWadah']}Gr",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      "Minuman\t: ${event['volumeMLWadah']}mL",
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
