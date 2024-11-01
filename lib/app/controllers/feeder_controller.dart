import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import './../../../../app/widgets/dialog/custom_alert_dialog.dart';
import './../../../../app/widgets/dialog/custom_notification.dart';
import './../../data_pengguna.dart';

class FeederController extends GetxController {
  RxBool isLoading = false.obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference database = FirebaseDatabase.instance.ref();
  String? currentTime;

  @override
  Future<void> onInit() async {
    super.onInit();
    _listenToRealtimeClock();
  }

  void _listenToRealtimeClock() {
    String uid = auth.currentUser!.uid;
    database
        .child("UsersData/$uid/iot/monitoring/ketWaktu")
        .onValue
        .listen((event) {
      currentTime = event.snapshot.value?.toString();
    });
  }

  feeder() async {
    isLoading.value = true;
    if (currentTime == null) {
      isLoading.value = false;
      CustomNotification.errorNotification(
          "Terjadi Kesalahan", "Gagal mendapatkan waktu saat ini.");
      return;
    }
    Map<String, dynamic> determinePosition = await _determinePosition();
    if (!determinePosition["error"]) {
      Position position = determinePosition["position"];
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      String alamat =
          "${placemarks.first.street}, ${placemarks.first.subLocality}, ${placemarks.first.locality}";
      double distance = Geolocator.distanceBetween(
        DataPengguna.house['latitude'],
        DataPengguna.house['longtitude'],
        position.latitude,
        position.longitude,
      );
      bool isValidMorning = _isWithinFeedingTime(currentTime!, "07:00", 15, 60);
      bool isValidAfternoon =
          _isWithinFeedingTime(currentTime!, "17:00", 15, 60);
      if (!isValidMorning && !isValidAfternoon) {
        isLoading.value = false;
        CustomNotification.errorNotification("Terjadi Kesalahan",
            "Tidak berada dalam rentang waktu (07:00 & 17:00) untuk memberi makan dan minum kucing.");
        return;
      }
      if (isValidAfternoon && !isValidMorning) {
        await processFeeder(position, alamat, distance, "afternoon");
      } else if (isValidMorning) {
        await processFeeder(position, alamat, distance, "morning");
      }
      await updatePumpAndServoStatus(true, true);
      isLoading.value = false;
    } else {
      isLoading.value = false;
      CustomNotification.errorNotification(
          "Terjadi Kesalahan", determinePosition["message"]);
    }
  }

  bool _isWithinFeedingTime(String currentTime, String feedTime,
      int toleranceBefore, int toleranceAfter) {
    DateTime current = DateFormat("HH:mm").parse(currentTime);
    DateTime feed = DateFormat("HH:mm").parse(feedTime);

    DateTime startValidTime = feed.subtract(Duration(minutes: toleranceBefore));
    DateTime endValidTime = feed.add(Duration(minutes: toleranceAfter));

    return current.isAfter(startValidTime) && current.isBefore(endValidTime);
  }

  firstFeeder(
    DatabaseReference feederRef,
    String todayDocId,
    Position position,
    String alamat,
    double distance,
    bool inArea,
  ) async {
    CustomAlertDialog.showFeederAlert(
      title: "Add Feeder",
      message:
          "Konfirmasi Terlebih Dahulu \n Untuk Memberi makan dan Minum Sekarang",
      onCancel: () => Get.back(),
      onConfirm: () async {
        await feederRef.child(todayDocId).set({
          "morningFeeder": {
            "date": DateTime.now().toIso8601String(),
            "latitude": position.latitude,
            "longtitude": position.longitude,
            "alamat": alamat,
            "in_area": inArea,
            "distance": distance,
          }
        });
        Get.back();
        CustomNotification.successNotification(
            "Sukses", "Tambah Feeder Berhasil");
      },
    );
  }

  morningFeeder(
    DatabaseReference feederRef,
    String todayDocId,
    Position position,
    String alamat,
    double distance,
    bool inArea,
  ) async {
    CustomAlertDialog.showFeederAlert(
      title: "Tambah Jadwal Pagi",
      message:
          "Konfirmasi Terlebih Dahulu \n Untuk Melakukan Pengisian Tempat Makan dan Minum Kucing",
      onCancel: () => Get.back(),
      onConfirm: () async {
        await feederRef.child(todayDocId).set({
          "morningFeeder": {
            "date": DateTime.now().toIso8601String(),
            "latitude": position.latitude,
            "longtitude": position.longitude,
            "alamat": alamat,
            "in_area": inArea,
            "distance": distance,
          }
        });
        Get.back();
        CustomNotification.successNotification(
            "Sukses", "Berhasil memberikan makan dan minum di Jadwal Pagi");
      },
    );
  }

  afternoonFeeder(
    DatabaseReference feederRef,
    String todayDocId,
    Position position,
    String alamat,
    double distance,
    bool inArea,
  ) async {
    CustomAlertDialog.showFeederAlert(
      title: "Tambah Jadwal Sore",
      message:
          "Konfirmasi Terlebih dahulu\nUntuk Melakukan Pengisian Pakan di Sore Hari",
      onCancel: () => Get.back(),
      onConfirm: () async {
        await feederRef.child(todayDocId).update({
          "afternoonFeeder": {
            "date": DateTime.now().toIso8601String(),
            "latitude": position.latitude,
            "longtitude": position.longitude,
            "alamat": alamat,
            "in_area": inArea,
            "distance": distance,
          }
        });
        Get.back();
        CustomNotification.successNotification(
            "Sukses", "Berhasil Memberi Makan di Sore Hari");
      },
    );
  }

  Future<void> processFeeder(Position position, String alamat, double distance,
      String feederType) async {
    String uid = auth.currentUser!.uid;
    String todayDocId =
        DateFormat.yMd().format(DateTime.now()).replaceAll("/", "-");
    DatabaseReference feederRef = database.child("UsersData/$uid/iot/feeder");
    DatabaseEvent snapshotPreference = await feederRef.once();
    bool inArea = distance <= 200;
    if (snapshotPreference.snapshot.value == null) {
      firstFeeder(feederRef, todayDocId, position, alamat, distance, inArea);
    } else {
      DatabaseEvent todayDoc = await feederRef.child(todayDocId).once();
      if (todayDoc.snapshot.value != null) {
        Map<String, dynamic> dataFeederToday =
            Map<String, dynamic>.from(todayDoc.snapshot.value as Map);

        if (dataFeederToday["morningFeeder"] != null &&
            dataFeederToday["afternoonFeeder"] != null) {
          CustomNotification.errorNotification(
            "Terjadi Kesalahan",
            "Anda sudah melakukan pemberian makan dan minum kucing pada hari ini.",
          );
        } else if (dataFeederToday["morningFeeder"] != null &&
            feederType == "afternoon") {
          afternoonFeeder(
              feederRef, todayDocId, position, alamat, distance, inArea);
        } else if (feederType == "morning") {
          morningFeeder(
              feederRef, todayDocId, position, alamat, distance, inArea);
        }
      } else {
        if (feederType == "morning") {
          morningFeeder(
              feederRef, todayDocId, position, alamat, distance, inArea);
        } else {
          afternoonFeeder(
              feederRef, todayDocId, position, alamat, distance, inArea);
        }
      }
    }
  }

  Future<void> updatePosisi(Position position, String alamat) async {
    String uid = auth.currentUser!.uid;
    await database.child("UsersData/$uid/UsersProfile").update({
      "position": {
        "latitude": position.latitude,
        "longtitude": position.longitude,
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

  Future<Map<String, dynamic>> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {
        "message": "location service are disabled.",
        "error": true,
      };
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {
          "message":
              "Tidak dapat mengakses lokasi, karena anda menolak permintaan akses lokasi",
          "error": true,
        };
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return {
        "message":
            "Akses Lokasi ditolak secara permanen oleh user, kami tidak dapat melakukan proses input lokasi",
        "error": true,
      };
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    return {
      "position": position,
      "message": "Berhasil Mendapatkan Posisi Device",
      "error": false,
    };
  }
}
