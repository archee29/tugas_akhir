import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/dialog/custom_notification.dart';
import './../../../../app/routes/app_pages.dart';

class ChartController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  StreamSubscription<User?>? _authStreamSubscription;
  final listDataMf = <Map<String, dynamic>>[].obs;
  final listDataAf = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  RxMap<String, dynamic> userData = <String, dynamic>{}.obs;

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
    isLoading.value = true;
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      databaseReference
          .child("UsersData/$uid/iot/feeder/jadwalPagi")
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          final values = Map<String, dynamic>.from(event.snapshot.value as Map);
          final parsedValues = values.entries.map((e) {
            var value = Map<String, dynamic>.from(e.value);
            value['key'] = e.key;
            return value;
          }).toList()
            ..sort((a, b) => DateFormat('dd/MM/yyyy')
                .parse(a['ketHari'])
                .compareTo(DateFormat('dd/MM/yyyy').parse(b['ketHari'])));

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
    isLoading.value = true;
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      databaseReference
          .child("UsersData/$uid/iot/feeder/jadwalSore")
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          final values = Map<String, dynamic>.from(event.snapshot.value as Map);
          final parsedValues = values.entries.map((e) {
            var value = Map<String, dynamic>.from(e.value);
            value['key'] = e.key;
            return value;
          }).toList()
            ..sort((a, b) => DateFormat('dd/MM/yyyy')
                .parse(a['ketHari'])
                .compareTo(DateFormat('dd/MM/yyyy').parse(b['ketHari'])));

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
}
