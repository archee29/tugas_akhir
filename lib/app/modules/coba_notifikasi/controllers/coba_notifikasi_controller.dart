import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../controllers/notification_service.dart';
import '../../../styles/app_colors.dart';
import '../../../widgets/dialog/custom_notification.dart';

class CobaNotifikasiController extends GetxController {
  RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> statusAlatList = <Map<String, dynamic>>[].obs;

  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController makananController = TextEditingController();
  final TextEditingController minumanController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingCreateSchedule = false.obs;

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;

  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase database = FirebaseDatabase.instance;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final NotificationService notificationService = NotificationService();

  @override
  void onInit() {
    super.onInit();
    notificationService.init();
  }

  Future<void> cobaNotifikasi() async {
    final User? user = auth.currentUser;
    if (user == null) {
      CustomNotification.errorNotification(
        "Terjadi Kesalahan",
        "User Tidak Terdaftar",
      );
      return;
    } else if (_validateInputs()) {
      isLoading.value = true;
      try {
        final data = _prepareData();
        final String formattedDate =
            DateFormat('MM-dd-yyyy').format(selectedDate.value);
        final existingScheduleQuery =
            _getExistingScheduleQuery(user.uid, formattedDate);
        final snapshot = await existingScheduleQuery.get();
        if (snapshot.exists) {
          CustomNotification.errorNotification(
            "Terjadi Kesalahan",
            "Anda sudah memiliki jadwal pada tanggal tersebut",
          );
        } else {
          await _saveDataToDatabase(user.uid, formattedDate, data);
          await notificationService.fetchAndScheduleNotification(user.uid);
          notificationService.showSuccessNotification(
            "Notifikasi",
            "Jadwal untuk ${data['title']} pada ${data['tanggal']} pukul ${data['waktu']} berhasil ditambahkan.",
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.back();
            Get.back();
            _clearEditingControllers();
            CustomNotification.successNotification(
                "Berhasil", "Berhasil Menambahkan Jadwal");
          });
        }
      } catch (e) {
        CustomNotification.errorNotification("Terjadi Kesalahan", "$e");
      } finally {
        isLoading.value = false;
        update();
      }
    }
  }

  bool _validateInputs() {
    if (dateController.text.isEmpty ||
        timeController.text.isEmpty ||
        titleController.text.isEmpty ||
        deskripsiController.text.isEmpty ||
        makananController.text.isEmpty ||
        minumanController.text.isEmpty) {
      CustomNotification.errorNotification(
        "Terjadi Kesalahan",
        "Isi Form Terlebih Dahulu",
      );
      return false;
    }
    final int? makananValue = int.tryParse(makananController.text);
    final int? minumanValue = int.tryParse(minumanController.text);
    if (makananValue == null || makananValue < 0 || makananValue > 120) {
      CustomNotification.errorNotification("Terjadi Kesalahan",
          "Masukan Jumlah Makanan dengan nilai 0-120 Gram saja");
      return false;
    }
    if (minumanValue == null || minumanValue < 0 || minumanValue > 300) {
      CustomNotification.errorNotification("Terjadi Kesalahan",
          "Masukan Jumlah Minuman dengan nilai 0-300 Mililiter saja");
      return false;
    }
    return true;
  }

  Map<String, dynamic> _prepareData() {
    return {
      "date": DateTime.now().toIso8601String(),
      "tanggal": dateController.text,
      "waktu": timeController.text,
      "title": titleController.text,
      "deskripsi": deskripsiController.text,
      "makanan": makananController.text,
      "minuman": minumanController.text,
      "created_at": DateTime.now().toIso8601String(),
    };
  }

  Query _getExistingScheduleQuery(String uid, String formattedDate) {
    return databaseReference
        .child("UsersData/$uid/cobaNotifikasi/$formattedDate");
  }

  Future<void> _saveDataToDatabase(
      String uid, String formattedDate, Map<String, dynamic> data) async {
    await databaseReference
        .child("UsersData/$uid/cobaNotifikasi/$formattedDate")
        .set(data);
  }

  void _clearEditingControllers() {
    dateController.clear();
    timeController.clear();
    titleController.clear();
    deskripsiController.clear();
    makananController.clear();
    minumanController.clear();
  }

  Future<void> chooseDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != selectedDate.value) {
      selectedDate.value = pickedDate;
      dateController.text = DateFormat.yMd().format(selectedDate.value);
      await displayScheduleDetails(selectedDate.value);
    }
  }

  Future<void> displayScheduleDetails(DateTime date) async {
    final User? user = auth.currentUser;
    if (user == null) {
      return;
    }
    final String uid = user.uid;
    String formattedDate = DateFormat('MM-dd-yyyy').format(date);
    final DatabaseReference scheduleRef =
        databaseReference.child("UsersData/$uid/cobaNotifikasi/$formattedDate");
    DataSnapshot? snapshot;
    try {
      snapshot = await scheduleRef.get();
    } catch (e) {
      CustomNotification.errorNotification("Terjadi Kesalahan", "$e");
    }
    String scheduleDetails = "Jadwal Tidak Tersedia";
    if (snapshot?.exists ?? false) {
      final data = snapshot!.value as Map<dynamic, dynamic>;
      scheduleDetails =
          "${data['title']} - ${data['deskripsi']} pada ${data['waktu']}";
    }
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text("Detail Jadwal"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Jadwal: $scheduleDetails"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> chooseTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: Get.context!,
      initialTime: selectedTime.value,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (pickedTime != null && pickedTime != selectedTime.value) {
      selectedTime.value = pickedTime;
      final now = DateTime.now();
      final formattedTime = DateFormat.Hm().format(DateTime(
          now.year, now.month, now.day, pickedTime.hour, pickedTime.minute));
      timeController.text = formattedTime;
    }
  }

  void handleTimeSelection() async {
    await chooseTime();
  }
}
