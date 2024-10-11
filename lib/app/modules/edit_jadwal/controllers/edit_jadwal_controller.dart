import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import './../../../../app/styles/app_colors.dart';
import './../../../../app/widgets/dialog/custom_notification.dart';
import './../../../../app/controllers/notification_service.dart';

class EditJadwalController extends GetxController {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController makananController = TextEditingController();
  final TextEditingController minumanController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingUpdateSchedule = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final NotificationService notificationService = NotificationService();

  String? nodePath;
  String? scheduleKey;

  @override
  void onInit() {
    super.onInit();
    notificationService.init();
  }

  void setInitialValues(Map<String, dynamic> scheduleData) {
    dateController.text = scheduleData['tanggal'] ?? '';
    timeController.text = scheduleData['waktu'] ?? '';
    titleController.text = scheduleData['title'] ?? '';
    deskripsiController.text = scheduleData['deskripsi'] ?? '';
    makananController.text = scheduleData['makanan'] ?? '';
    minumanController.text = scheduleData['minuman'] ?? '';

    selectedDate.value = DateFormat.yMd().parse(dateController.text);
    selectedTime.value = TimeOfDay(
      hour: int.parse(timeController.text.split(':')[0]),
      minute: int.parse(timeController.text.split(':')[1]),
    );
  }

  Future<void> updateManualDataBasedOnTime() async {
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
          await _updateDataToDatabase(user.uid, nodePath, data);
          DateTime notificationTime = DateTime(
              selectedDate.value.year,
              selectedDate.value.month,
              selectedDate.value.day,
              selectedTime.value.hour,
              selectedTime.value.minute);
          await notificationService.scheduleNotification(
              notificationTime,
              "Alarm Notifikasi | Jadwal ${nodePath == 'jadwalPagi' ? 'Pagi' : 'Sore'} |  ${selectedTime.value.format(Get.context!)}",
              "Sudah Saatnya Memberikan Makan di ${nodePath == 'jadwalPagi' ? 'Pagi' : 'Sore'} Hari");

          await notificationService.fetchAndScheduleNotification(user.uid);
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            Get.until((route) => route.isFirst);
            _clearEditingControllers();
            notificationService.showSuccessNotification(
                "Jadwal Berhasil Diperbarui",
                "Jadwal untuk ${data['title']} | pada ${data['tanggal']} | pukul ${data['waktu']} | Berhasil Diperbarui.");
            CustomNotification.successNotification("Berhasil",
                "Berhasil Memperbarui Jadwal ${nodePath == 'jadwalPagi' ? 'Pagi' : 'Sore'}");
          });
        } else {
          CustomNotification.errorNotification(
              "Terjadi Kesalahan", "Jadwal tidak ditemukan untuk diperbarui");
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
      "updated_at": DateTime.now().toIso8601String(),
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

  Future<void> _updateDataToDatabase(
      String uid, String nodePath, Map<String, dynamic> data) async {
    DateTime date = DateFormat.yMd().parse(dateController.text);
    String formattedDate = DateFormat('MM-dd-yyyy').format(date);
    await databaseReference
        .child("UsersData/$uid/penjadwalan/$nodePath/$formattedDate")
        .update(data);
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
    DateTime initialDate = selectedDate.value;
    DateTime firstDate = DateTime.now();

    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }
    final DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: firstDate,
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
            const Text(
              "Jadwal Pagi : ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(morningSchedule),
            const SizedBox(height: 16),
            const Text(
              "Jadwal Sore: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(eveningSchedule),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  Future<void> chooseTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: Get.context!,
      initialTime: selectedTime.value,
    );
    if (pickedTime != null && pickedTime != selectedTime.value) {
      selectedTime.value = pickedTime;
      timeController.text =
          "${selectedTime.value.hour}:${selectedTime.value.minute}";
    }
  }

  void onTimeChanged(String value) {
    timeController.text = value;
    update();
  }
}
