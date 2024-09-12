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

  feeder() async {
    isLoading.value = true;
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
          position.longitude);
      await updatePosisi(position, alamat);
      await processFeeder(position, alamat, distance);
      isLoading.value = false;
    } else {
      isLoading.value = false;
      Get.snackbar("Terjadi Kesalahan", determinePosition["message"]);
    }
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
        await feederRef.child(todayDocId).set(
          {
            "date": DateTime.now().toIso8601String(),
            "morningFeeder": {
              "date": DateTime.now().toIso8601String(),
              "latitude": position.latitude,
              "longtitude": position.longitude,
              "alamat": alamat,
              "in_area": inArea,
              "distance": distance,
            }
          },
        );
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
        await feederRef.child(todayDocId).set(
          {
            "date": DateTime.now().toIso8601String(),
            "morningFeeder": {
              "date": DateTime.now().toIso8601String(),
              "latitude": position.latitude,
              "longtitude": position.longitude,
              "alamat": alamat,
              "in_area": inArea,
              "distance": distance,
            }
          },
        );
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
        await feederRef.child(todayDocId).update(
          {
            "afternoonFeeder": {
              "date": DateTime.now().toIso8601String(),
              "latitude": position.latitude,
              "longtitude": position.longitude,
              "alamat": alamat,
              "in_area": inArea,
              "distance": distance,
            }
          },
        );
        Get.back();
        CustomNotification.successNotification(
          "Sukses",
          "Berhasil Memberi Makan di Sore Hari",
        );
      },
    );
  }

  Future<void> processFeeder(
      Position position, String alamat, double distance) async {
    String uid = auth.currentUser!.uid;
    String todayDocId =
        DateFormat.yMd().format(DateTime.now()).replaceAll("/", "-");
    DatabaseReference feederRef = database.child("UsersData/$uid/manual");
    DatabaseEvent snapshotPreference = await feederRef.once();
    bool inArea = false;

    if (distance <= 200) {
      inArea = true;
    }
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
            "Anda sudah memiliki jadwal Pagi dan Sore pada tanggal tersebut",
          );
        } else if (dataFeederToday["morningFeeder"] != null) {
          afternoonFeeder(
              feederRef, todayDocId, position, alamat, distance, inArea);
        } else {
          morningFeeder(
              feederRef, todayDocId, position, alamat, distance, inArea);
        }
      } else {
        morningFeeder(
            feederRef, todayDocId, position, alamat, distance, inArea);
      }
    }
  }

  Future<void> updatePosisi(Position position, String alamat) async {
    String uid = auth.currentUser!.uid;
    await database.child("UsersData/$uid/UsersProfile").update(
      {
        "position": {
          "latitude": position.latitude,
          "longtitude": position.longitude,
        },
        "address": alamat,
      },
    );
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
