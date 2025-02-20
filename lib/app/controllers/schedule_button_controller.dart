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
    }
  }

  Future<void> handleTimeSelection() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: selectedTime.value,
    );

    if (picked != null) {
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

      String uid = auth.currentUser!.uid;

      DatabaseReference monitoringRef =
          database.child("UsersData/$uid/iot/monitoring");
      DatabaseEvent monitoringSnapshot = await monitoringRef.once();
      Map<String, dynamic> monitoringData =
          Map<String, dynamic>.from(monitoringSnapshot.snapshot.value as Map);

      String scheduleDate = DateFormat("MM-dd-yyyy").format(selectedDate.value);
      String scheduledTime =
          "${selectedTime.value.hour.toString().padLeft(2, '0')}:${selectedTime.value.minute.toString().padLeft(2, '0')}";

      bool isValidMorning =
          _isWithinFeedingTime(scheduledTime, "07:00", 15, 60);
      bool isValidAfternoon =
          _isWithinFeedingTime(scheduledTime, "17:00", 15, 60);

      if (!isValidMorning && !isValidAfternoon) {
        isLoading.value = false;
        CustomNotification.errorNotification("Terjadi Kesalahan",
            "Jadwal harus berada dalam rentang waktu 07:00 atau 17:00 (±1 jam)");
        return;
      }

      DatabaseReference feederRef = database.child("UsersData/$uid/iot/feeder");
      DatabaseEvent morningFeedEvent =
          await feederRef.child("jadwalPagi/$scheduleDate").once();
      DatabaseEvent afternoonFeedEvent =
          await feederRef.child("jadwalSore/$scheduleDate").once();

      if ((isValidMorning && morningFeedEvent.snapshot.value != null) ||
          (isValidAfternoon && afternoonFeedEvent.snapshot.value != null)) {
        isLoading.value = false;
        CustomNotification.errorNotification("Terjadi Kesalahan",
            "Sudah terdapat jadwal pemberian makan pada tanggal ini.");
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
          "ketHari": DateFormat('d/MM/yyyy').format(selectedDate.value),
          "ketWaktu": isValidMorning ? "7:0:0" : "17:0:0",
          "volumeMLTabung": monitoringData['volumeMLTabung'],
          "volumeMLWadah": monitoringData['volumeMLWadah'],
          "title": titleController.text,
          "description": deskripsiController.text,
          "created_at": DateTime.now().toIso8601String(),
        };

        String feedPath = isValidMorning ? "jadwalPagi" : "jadwalSore";
        await feederRef.child("$feedPath/$scheduleDate").set(scheduleData);

        Get.back();
        CustomNotification.successNotification(
            "Sukses", "Jadwal berhasil ditambahkan");
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

  bool _isWithinFeedingTime(String scheduledTime, String feedTime,
      int toleranceBefore, int toleranceAfter) {
    DateTime scheduled = DateFormat("HH:mm").parse(scheduledTime);
    DateTime feed = DateFormat("HH:mm").parse(feedTime);
    DateTime startValidTime = feed.subtract(Duration(minutes: toleranceBefore));
    DateTime endValidTime = feed.add(Duration(minutes: toleranceAfter));

    return scheduled.isAfter(startValidTime) &&
        scheduled.isBefore(endValidTime);
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
