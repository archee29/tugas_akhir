import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import './../../../../app/styles/app_colors.dart';
import './../../../../app/widgets/dialog/custom_notification.dart';
import './../../../../app/controllers/notification_service.dart';

class TambahJadwalController extends GetxController {
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
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  final LocalNotificationService _localNotificationService =
      Get.find<LocalNotificationService>();

  @override
  void onInit() {
    super.onInit();
    _localNotificationService.init();
    _localNotificationService.requestPermissions();
  }

  Future<void> addManualDataBasedOnTime() async {
    final User? user = auth.currentUser;
    if (user == null) {
      CustomNotification.errorNotification(
          "Terjadi Kesalahan", "User Tidak Terdaftar");
      return;
    } else if (_validateInputs()) {
      isLoading.value = true;
      try {
        final data = _prepareData();
        final String nodePath = _getNodePath();
        final existingScheduleQuery =
            _getExistingScheduleQuery(user.uid, nodePath);
        final snapshot = await existingScheduleQuery.get();

        if (snapshot.exists) {
          CustomNotification.errorNotification("Terjadi Kesalahan",
              "Anda sudah memiliki jadwal ${nodePath == 'jadwalPagi' ? 'Pagi' : 'Sore'} pada tanggal tersebut");
        } else {
          await _saveDataToDatabase(user.uid, nodePath, data);
          await _scheduleNotification(nodePath);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.back();
            Get.back();
            Get.back();
            _clearEditingControllers();
            CustomNotification.successNotification("Berhasil",
                "Berhasil Menambahkan Jadwal ${nodePath == 'jadwalPagi' ? 'Pagi' : 'Sore'}");
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
          "Terjadi Kesalahan", "Isi Form Terlebih Dahulu");
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

  String _getNodePath() {
    return selectedTime.value.hour == 7 ? "jadwalPagi" : "jadwalSore";
  }

  Query _getExistingScheduleQuery(String uid, String nodePath) {
    DateTime date = DateFormat.yMd().parse(dateController.text);
    String formattedDate = DateFormat('MM-dd-yyyy').format(date);
    return databaseReference
        .child("UsersData/$uid/penjadwalan/$nodePath/$formattedDate");
  }

  Future<void> _saveDataToDatabase(
      String uid, String nodePath, Map<String, dynamic> data) async {
    DateTime date = DateFormat.yMd().parse(dateController.text);
    String formattedDate = DateFormat('MM-dd-yyyy').format(date);
    await databaseReference
        .child("UsersData/$uid/penjadwalan/$nodePath/$formattedDate")
        .set(data);
  }

  Future<void> _scheduleNotification(String nodePath) async {
    final String scheduleTitle =
        nodePath == "jadwalPagi" ? "Jadwal Pagi" : "Jadwal Sore";
    print(
        "Scheduling notification for $scheduleTitle at ${selectedTime.value.format(Get.context!)}");
    await _localNotificationService.scheduleNotification(
      0,
      selectedTime.value,
      scheduleTitle,
      "Sudah Waktunya Makan ${nodePath == 'jadwalPagi' ? 'Pagi' : 'Sore'}",
    );
    print("Notification scheduled successfully for $scheduleTitle.");
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

    final DatabaseReference morningScheduleRef = databaseReference
        .child("UsersData/$uid/penjadwalan/jadwalPagi/$formattedDate");
    final DatabaseReference eveningScheduleRef = databaseReference
        .child("UsersData/$uid/penjadwalan/jadwalSore/$formattedDate");

    DataSnapshot? morningSnapshot;
    DataSnapshot? eveningSnapshot;

    try {
      morningSnapshot = await morningScheduleRef.get();
      eveningSnapshot = await eveningScheduleRef.get();
    } catch (e) {
      CustomNotification.errorNotification("Terjadi Kesalahan", "$e");
    }

    String morningSchedule = "Jadwal Tidak Tersedia";
    String eveningSchedule = "Jadwal Tidak Tersedia";

    if (morningSnapshot?.exists ?? false) {
      final morningData = morningSnapshot!.value as Map<dynamic, dynamic>;
      morningSchedule = "${morningData['title']} - ${morningData['deskripsi']}";
    }

    if (eveningSnapshot?.exists ?? false) {
      final eveningData = eveningSnapshot!.value as Map<dynamic, dynamic>;
      eveningSchedule = "${eveningData['title']} - ${eveningData['deskripsi']}";
    }

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text("Detail Jadwal"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Jadwal Pagi: $morningSchedule"),
            const SizedBox(height: 10),
            Text("Jadwal Sore: $eveningSchedule"),
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
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != selectedTime.value) {
      selectedTime.value = pickedTime;
      timeController.text = selectedTime.value.format(Get.context!);
    }
  }

  void handleTimeSelection() async {
    await chooseTime();
  }

  void onTimeChanged(String newTime) {
    timeController.text = newTime;
    if (newTime == '07:00') {
      selectedTime.value = const TimeOfDay(hour: 7, minute: 0);
    } else if (newTime == '17:00') {
      selectedTime.value = const TimeOfDay(hour: 17, minute: 0);
    }
  }
}
