import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
}
