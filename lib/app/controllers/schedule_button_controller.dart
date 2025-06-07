import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../widgets/dialog/custom_schedule_dialog.dart';
import './../../../../app/widgets/dialog/custom_notification.dart';
import './../../data_pengguna.dart';

class ScheduleButtonController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference database = FirebaseDatabase.instance.ref();
  RxBool isLoading = false.obs;
  RxString currentTime = RxString('');
  RxBool isTimeInitialized = RxBool(false);

  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final titleController = TextEditingController();
  final deskripsiController = TextEditingController();
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeTimeListener();
  }

  @override
  void onClose() {
    dateController.dispose();
    timeController.dispose();
    titleController.dispose();
    deskripsiController.dispose();
    super.onClose();
  }

  Future<void> _initializeTimeListener() async {
    try {
      String uid = auth.currentUser!.uid;
      database.child("UsersData/$uid/iot/monitoring").onValue.listen(
        (event) {
          if (event.snapshot.value != null) {
            Map<String, dynamic> data =
                Map<String, dynamic>.from(event.snapshot.value as Map);
            currentTime.value = data['ketWaktu']?.toString() ?? '';
            isTimeInitialized.value = true;
          }
        },
        onError: (error) {
          CustomNotification.errorNotification("Kesalahan Koneksi",
              "Gagal mendapatkan data waktu: ${error.toString()}");
        },
      );
    } catch (e) {
      CustomNotification.errorNotification("Terjadi Kesalahan",
          "Error inisialisasi listener waktu: ${e.toString()}");
    }
  }

  void showAddScheduleDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ScheduleInputWidget(controller: this),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> chooseDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      dateController.text = DateFormat("dd-MM-yyyy").format(picked);
      if (DateFormat("dd-MM-yyyy").format(picked) ==
          DateFormat("dd-MM-yyyy").format(DateTime.now())) {
        DateTime now = DateTime.now();
        selectedTime.value = TimeOfDay(hour: now.hour, minute: now.minute + 15);
        timeController.text =
            "${selectedTime.value.hour.toString().padLeft(2, '0')}:${selectedTime.value.minute.toString().padLeft(2, '0')}";
      }
    }
  }

  Future<void> handleTimeSelection() async {
    TimeOfDay initialTime = selectedTime.value;
    if (DateFormat("dd-MM-yyyy").format(selectedDate.value) ==
        DateFormat("dd-MM-yyyy").format(DateTime.now())) {
      DateTime now = DateTime.now();
      if (initialTime.hour < now.hour ||
          (initialTime.hour == now.hour && initialTime.minute < now.minute)) {
        initialTime = TimeOfDay(hour: now.hour, minute: now.minute + 5);
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (DateFormat("dd-MM-yyyy").format(selectedDate.value) ==
          DateFormat("dd-MM-yyyy").format(DateTime.now())) {
        DateTime now = DateTime.now();
        DateTime selectedDateTime =
            DateTime(now.year, now.month, now.day, picked.hour, picked.minute);

        if (selectedDateTime.isBefore(now)) {
          CustomNotification.errorNotification("Waktu Tidak Valid",
              "Waktu yang dipilih tidak boleh lebih awal dari waktu sekarang.");
          return;
        }
      }

      selectedTime.value = picked;
      timeController.text =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    }
  }

  void onTimeChanged(String value) {
    timeController.text = value;
  }

  Future<void> handleScheduleConfirm() async {
    if (!_validateInputs()) {
      CustomNotification.errorNotification(
          "Validasi Error", "Mohon lengkapi semua field yang diperlukan");
      return;
    }

    isLoading.value = true;
    try {
      if (!isTimeInitialized.value || currentTime.value.isEmpty) {
        isLoading.value = false;
        CustomNotification.errorNotification("Terjadi Kesalahan",
            "Gagal mendapatkan waktu saat ini. Periksa koneksi database.");
        return;
      }
      if (DateFormat("dd-MM-yyyy").format(selectedDate.value) ==
          DateFormat("dd-MM-yyyy").format(DateTime.now())) {
        DateTime now = DateTime.now();
        DateTime selectedDateTime = DateTime(now.year, now.month, now.day,
            selectedTime.value.hour, selectedTime.value.minute);

        if (selectedDateTime.isBefore(now)) {
          isLoading.value = false;
          CustomNotification.errorNotification("Waktu Tidak Valid",
              "Waktu yang dipilih tidak boleh lebih awal dari waktu sekarang.");
          return;
        }
      }

      String uid = auth.currentUser!.uid;

      DatabaseReference monitoringRef =
          database.child("UsersData/$uid/iot/monitoring");
      DatabaseEvent monitoringSnapshot = await monitoringRef.once();
      Map<String, dynamic> monitoringData =
          Map<String, dynamic>.from(monitoringSnapshot.snapshot.value as Map);

      String scheduleDate = DateFormat("MM-dd-yyyy").format(selectedDate.value);
      String scheduledTime =
          "${selectedTime.value.hour.toString().padLeft(2, '0')}:${selectedTime.value.minute.toString().padLeft(2, '0')}";
      bool isMorningSchedule = selectedTime.value.hour < 12;
      String feedPath = isMorningSchedule ? "jadwalPagi" : "jadwalSore";

      DatabaseReference feederRef = database.child("UsersData/$uid/iot/feeder");
      DatabaseEvent feedEvent =
          await feederRef.child("$feedPath/$scheduleDate").once();

      if (feedEvent.snapshot.value != null) {
        isLoading.value = false;
        CustomNotification.errorNotification("Terjadi Kesalahan",
            "Sudah terdapat jadwal ${isMorningSchedule ? 'pagi' : 'sore'} pada tanggal ini.");
        return;
      }

      Map<String, dynamic> determinePosition = await _determinePosition();
      if (!determinePosition["error"]) {
        Position position = determinePosition["position"];
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);

        String alamat =
            "${placemarks.first.street}, ${placemarks.first.subLocality}, ${placemarks.first.locality}";
        double distance = Geolocator.distanceBetween(
          DataPengguna.house['latitude'],
          DataPengguna.house['longtitude'],
          position.latitude,
          position.longitude,
        );

        Map<String, dynamic> scheduleData = {
          "date": selectedDate.value.toIso8601String(),
          "latitude": position.latitude,
          "longtitude": position.longitude,
          "alamat": alamat,
          "in_area": distance <= 200,
          "distance": distance,
          "beratWadah": monitoringData['beratWadah'],
          "ketHari": DateFormat('d/M/yyyy').format(selectedDate.value),
          "ketWaktu":
              "${selectedTime.value.hour}:${selectedTime.value.minute}:0",
          "volumeMLTabung": monitoringData['volumeMLTabung'],
          "volumeMLWadah": monitoringData['volumeMLWadah'],
          "title": titleController.text,
          "description": deskripsiController.text,
          "created_at": DateTime.now().toIso8601String(),
          "feedingType": "byApplication",
        };

        await feederRef.child("$feedPath/$scheduleDate").set(scheduleData);

        Get.back();
        CustomNotification.successNotification("Sukses",
            "Jadwal ${isMorningSchedule ? 'pagi' : 'sore'} berhasil ditambahkan");
        _clearInputs();
      } else {
        CustomNotification.errorNotification(
            "Terjadi Kesalahan", determinePosition["message"]);
      }
    } catch (e) {
      CustomNotification.errorNotification(
          "Terjadi Kesalahan", "Error: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateInputs() {
    return dateController.text.isNotEmpty &&
        timeController.text.isNotEmpty &&
        titleController.text.isNotEmpty &&
        deskripsiController.text.isNotEmpty;
  }

  void _clearInputs() {
    dateController.clear();
    timeController.clear();
    titleController.clear();
    deskripsiController.clear();
    selectedDate.value = DateTime.now();
    selectedTime.value = TimeOfDay.now();
  }

  Future<Map<String, dynamic>> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return {
        "message": "Layanan lokasi dinonaktifkan.",
        "error": true,
      };
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {
          "message":
              "Akses lokasi ditolak. Izinkan akses lokasi untuk melanjutkan.",
          "error": true,
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {
        "message":
            "Akses lokasi ditolak secara permanen. Buka pengaturan untuk mengubah izin.",
        "error": true,
      };
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    return {
      "position": position,
      "message": "Berhasil mendapatkan posisi perangkat",
      "error": false,
    };
  }

  Future<void> updatePosisi(Position position, String alamat) async {
    String uid = auth.currentUser!.uid;
    await database.child("UsersData/$uid/UsersProfile").update({
      "position": {
        "latitude": position.latitude,
        "longitude": position.longitude,
      },
      "address": alamat,
    });
  }

  Future<void> updatePumpAndServoStatus(
      bool pumpControl, bool servoControl) async {
    String uid = auth.currentUser!.uid;
    await database.child("UsersData/$uid/iot/control").update({
      "pumpControl": pumpControl,
      "servoControl": servoControl,
    });
  }
}
