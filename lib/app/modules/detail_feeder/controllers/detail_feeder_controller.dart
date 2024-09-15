import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import './../../../../app/routes/app_pages.dart';

class DetailFeederController extends GetxController
    with GetSingleTickerProviderStateMixin {
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  // List untuk menyimpan data pagi dan sore
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
          print('Error streaming user data: $error');
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
      databaseReference.child("UsersData/$uid/manual").onValue.listen((event) {
        isLoading.value = true;
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final todayDocId =
              DateFormat.yMd().format(DateTime.now()).replaceAll("/", "-");
          final todayData = data[todayDocId];
          if (todayData != null) {
            final morningFeeder = todayData["morningFeeder"];
            if (morningFeeder != null) {
              final parsedValues = Map<String, dynamic>.from(morningFeeder);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                listDataMf.assignAll([parsedValues]);
                isLoading.value = false;
              });
            } else {
              listDataMf.clear();
              isLoading.value = false;
            }
          } else {
            listDataMf.clear();
            isLoading.value = false;
          }
        } else {
          listDataMf.clear();
          isLoading.value = false;
        }
      }, onError: (error) {
        print('Error retrieving morning feeder data: $error');
        isLoading.value = false;
      });
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> retrieveDataFeederAF() async {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      databaseReference.child("UsersData/$uid/manual").onValue.listen((event) {
        isLoading.value = true;
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final todayDocId =
              DateFormat.yMd().format(DateTime.now()).replaceAll("/", "-");
          final todayData = data[todayDocId];
          if (todayData != null) {
            final afternoonFeeder = todayData["afternoonFeeder"];
            if (afternoonFeeder != null) {
              final parsedValues = Map<String, dynamic>.from(afternoonFeeder);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                listDataAf.assignAll([parsedValues]);
                isLoading.value = false;
              });
            } else {
              listDataAf.clear();
              isLoading.value = false;
            }
          } else {
            listDataAf.clear();
            isLoading.value = false;
          }
        } else {
          listDataAf.clear();
          isLoading.value = false;
        }
      }, onError: (error) {
        print('Error retrieving afternoon feeder data: $error');
        isLoading.value = false;
      });
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
